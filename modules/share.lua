pfUI:RegisterModule("share", "vanilla:tbc", function ()
  local function serialize(tbl, comp, name, ignored, spacing)
    local spacing = spacing or ""
    local match = nil
    local tname = ( spacing == "" and "" or "[\"" ) .. name .. ( spacing == "" and "" or "\"]" )
    local str = spacing .. tname .. " = {\n"

    for k, v in pairs(tbl) do
      if not ( ignored[k] and spacing == "" ) and ( not comp or not comp[k] or comp[k] ~= tbl[k] ) then
        if type(v) == "table" then
          local result = serialize(tbl[k], comp and comp[k], k, ignored, spacing .. "  ")
          if result then
            match = true
            str = str .. result
          end
        elseif type(v) == "string" then
          match = true
          str = str .. spacing .. "  [\""..k.."\"] = \"".. string.gsub(v, "\\", "\\\\") .."\",\n"
        elseif type(v) == "number" then
          match = true
          str = str .. spacing .. "  [\""..k.."\"] = ".. string.gsub(v, "\\", "\\\\") ..",\n"
        end
      end
    end

    str = str .. spacing .. "}" .. ( spacing == "" and "" or "," ) .. "\n"
    return match and str or nil
  end

  local function compress(input)
    -- based on Rochet2's lzw compression
    if type(input) ~= "string" then
      return nil
    end
    local len = strlen(input)
    if len <= 1 then
      return "u"..input
    end

    local dict = {}
    for i = 0, 255 do
      local ic, iic = strchar(i), strchar(i, 0)
      dict[ic] = iic
    end
    local a, b = 0, 1

    local result = {"c"}
    local resultlen = 1
    local n = 2
    local word = ""
    for i = 1, len do
      local c = strsub(input, i, i)
      local wc = word..c
      if not dict[wc] then
        local write = dict[word]
        if not write then
          return nil
        end
        result[n] = write
        resultlen = resultlen + strlen(write)
        n = n+1
        if  len <= resultlen then
          return "u"..input
        end
        local str = wc
        if a >= 256 then
          a, b = 0, b+1
          if b >= 256 then
            dict = {}
            b = 1
          end
        end
        dict[str] = strchar(a,b)
        a = a+1
        word = c
      else
        word = wc
      end
    end
    result[n] = dict[word]
    resultlen = resultlen+strlen(result[n])
    n = n+1
    if  len <= resultlen then
      return "u"..input
    end
    return table.concat(result)
  end

  local function decompress(input)
    -- based on Rochet2's lzw compression
    if type(input) ~= "string" or strlen(input) < 1 then
      return nil
    end

    local control = strsub(input, 1, 1)
    if control == "u" then
      return strsub(input, 2)
    elseif control ~= "c" then
      return nil
    end
    input = strsub(input, 2)
    local len = strlen(input)

    if len < 2 then
      return nil
    end

    local dict = {}
    for i = 0, 255 do
      local ic, iic = strchar(i), strchar(i, 0)
      dict[iic] = ic
    end

    local a, b = 0, 1

    local result = {}
    local n = 1
    local last = strsub(input, 1, 2)
    result[n] = dict[last]
    n = n+1
    for i = 3, len, 2 do
      local code = strsub(input, i, i+1)
      local lastStr = dict[last]
      if not lastStr then
        return nil
      end
      local toAdd = dict[code]
      if toAdd then
        result[n] = toAdd
        n = n+1
        local str = lastStr..strsub(toAdd, 1, 1)
        if a >= 256 then
          a, b = 0, b+1
          if b >= 256 then
            dict = {}
            b = 1
          end
        end
        dict[strchar(a,b)] = str
        a = a+1
      else
        local str = lastStr..strsub(lastStr, 1, 1)
        result[n] = str
        n = n+1
        if a >= 256 then
          a, b = 0, b+1
          if b >= 256 then
            dict = {}
            b = 1
          end
        end
        dict[strchar(a,b)] = str
        a = a+1
      end
      last = code
    end
    return table.concat(result)
  end

  local function enc(to_encode)
    local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local bit_pattern = ''
    local encoded = ''
    local trailing = ''

    for i = 1, string.len(to_encode) do
      local remaining = tonumber(string.byte(string.sub(to_encode, i, i)))
      local bin_bits = ''
      for i = 7, 0, -1 do
        local current_power = math.pow(2, i)
        if remaining >= current_power then
          bin_bits = bin_bits .. '1'
          remaining = remaining - current_power
        else
          bin_bits = bin_bits .. '0'
        end
      end
      bit_pattern = bit_pattern .. bin_bits
    end

    if mod(string.len(bit_pattern), 3) == 2 then
      trailing = '=='
      bit_pattern = bit_pattern .. '0000000000000000'
    elseif mod(string.len(bit_pattern), 3) == 1 then
      trailing = '='
      bit_pattern = bit_pattern .. '00000000'
    end

    local count = 0
    for i = 1, string.len(bit_pattern), 6 do
      local byte = string.sub(bit_pattern, i, i+5)
      local offset = tonumber(tonumber(byte, 2))
      encoded = encoded .. string.sub(index_table, offset+1, offset+1)
      count = count + 1
      if count >= 92 then
        encoded = encoded .. "\n"
        count = 0
      end
    end

    return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
  end

  local function dec(to_decode)
    local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local padded = gsub(to_decode,"%s", "")
    local unpadded = gsub(padded,"=", "")
    local bit_pattern = ''
    local decoded = ''

    to_decode = gsub(to_decode,"\n", "")
    to_decode = gsub(to_decode," ", "")

    for i = 1, string.len(unpadded) do
      local char = string.sub(to_decode, i, i)
      local offset, _ = string.find(index_table, char)
      if offset == nil then return nil end

      local remaining = tonumber(offset-1)
      local bin_bits = ''
      for i = 7, 0, -1 do
        local current_power = math.pow(2, i)
        if remaining >= current_power then
          bin_bits = bin_bits .. '1'
          remaining = remaining - current_power
        else
          bin_bits = bin_bits .. '0'
        end
      end

      bit_pattern = bit_pattern .. string.sub(bin_bits, 3)
    end

    for i = 1, string.len(bit_pattern), 8 do
      local byte = string.sub(bit_pattern, i, i+7)
      decoded = decoded .. strchar(tonumber(byte, 2))
    end

    local padding_length = string.len(padded)-string.len(unpadded)

    if (padding_length == 1 or padding_length == 2) then
      decoded = string.sub(decoded,1,-2)
    end

    return decoded
  end

  do -- Window
    local f = CreateFrame("Frame", "pfShare", UIParent)
    f:Hide()
    f:SetPoint("CENTER", 0, 0)
    f:SetWidth(580)
    f:SetHeight(420)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() f:StartMoving() end)
    f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
    f:SetFrameStrata("DIALOG")

    f:SetScript("OnShow", function()
      if pfUI.gui and pfUI.gui:IsShown() then
        f.hadGUI = true
        pfUI.gui:Hide()
      else
        f.hadGUI = nil
      end
    end)

    f:SetScript("OnHide", function()
      if f.hadGUI then
        pfUI.gui:Show()
      end
    end)

    CreateBackdrop(f, nil, true, 0.8)
    CreateBackdropShadow(f)
    table.insert(UISpecialFrames, "pfShare")

    do -- Edit Box
      f.scroll = pfUI.api.CreateScrollFrame("pfShareScroll", f)
      f.scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -30)
      f.scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 50)
      f.scroll:SetWidth(560)
      f.scroll:SetHeight(400)

      f.scroll.backdrop = CreateFrame("Frame", "pfShareScrollBackdrop", f.scroll)
      f.scroll.backdrop:SetFrameLevel(1)
      f.scroll.backdrop:SetPoint("TOPLEFT", f.scroll, "TOPLEFT", -5, 5)
      f.scroll.backdrop:SetPoint("BOTTOMRIGHT", f.scroll, "BOTTOMRIGHT", 5, -5)
      pfUI.api.CreateBackdrop(f.scroll.backdrop, nil, true)

      f.scroll.text = CreateFrame("EditBox", "pfShareEditBox", f.scroll)
      f.scroll.text.bg = f.scroll.text:CreateTexture(nil, "OVERLAY")
      f.scroll.text.bg:SetAllPoints(f.scroll.text)
      f.scroll.text.bg:SetTexture(1,1,1,.05)
      f.scroll.text:SetMultiLine(true)
      f.scroll.text:SetWidth(560)
      f.scroll.text:SetHeight(400)
      f.scroll.text:SetAllPoints(f.scroll)
      f.scroll.text:SetTextInsets(15,15,15,15)
      f.scroll.text:SetFont(pfUI.media["font:RobotoMono.ttf"], 9)
      f.scroll.text:SetAutoFocus(false)
      f.scroll.text:SetJustifyH("LEFT")
      f.scroll.text:SetScript("OnEscapePressed", function() this:ClearFocus() end)
      f.scroll.text:SetScript("OnTextChanged", function()
        this:GetParent():UpdateScrollChildRect()
        this:GetParent():UpdateScrollState()

        local _, error = loadstring(f.scroll.text:GetText())
        if error or string.gsub(this:GetText(), " ", "") == "" then
          f.loadButton:Disable()
          f.loadButton.text:SetTextColor(1,.5,.5,1)
        else
          f.loadButton:Enable()
          f.loadButton.text:SetTextColor(.5,1,.5,1)
        end

        local trydec = dec(this:GetText())
        if string.gsub(this:GetText(), " ", "") == "" then
          f.readButton.text:SetText(T["N/A"])
          f.readButton:Disable()
        elseif not trydec or trydec == "" then
          f.readButton:Enable()
          f.readButton.text:SetText(T["Encode"])
          f.readButton.func = function()
            local compressed = enc(compress(f.scroll.text:GetText()))
            f.scroll.text:SetText(compressed)
          end
        else
          f.readButton:Enable()
          f.readButton.text:SetText(T["Decode"])
          f.readButton.func = function()
            local uncompressed = decompress(dec(f.scroll.text:GetText()))
            f.scroll.text:SetText(uncompressed)
          end
        end
      end)
      f.scroll:SetScrollChild(f.scroll.text)
    end

    do -- button: close
      f.closeButton = CreateFrame("Button", "pfShareClose", f)
      f.closeButton:SetPoint("TOPRIGHT", -5, -5)
      f.closeButton:SetHeight(12)
      f.closeButton:SetWidth(12)
      f.closeButton.texture = f.closeButton:CreateTexture("pfQuestionDialogCloseTex")
      f.closeButton.texture:SetTexture(pfUI.media["img:close"])
      f.closeButton.texture:ClearAllPoints()
      f.closeButton.texture:SetAllPoints(f.closeButton)
      f.closeButton.texture:SetVertexColor(1,.25,.25,1)
      pfUI.api.SkinButton(f.closeButton, 1, .5, .5)
      f.closeButton:SetScript("OnClick", function()
       this:GetParent():Hide()
      end)
    end

    do -- checkbox: ignore positions
      f.ignorePosition = CreateFrame("CheckButton", "pfShareIgnorePosition", f, "UICheckButtonTemplate")
      f.ignorePosition:SetNormalTexture("")
      f.ignorePosition:SetPushedTexture("")
      f.ignorePosition:SetHighlightTexture("")
      CreateBackdrop(f.ignorePosition, nil, true)
      f.ignorePosition:SetWidth(14)
      f.ignorePosition:SetHeight(14)
      f.ignorePosition:SetPoint("BOTTOMLEFT", 10, 10)

      f.ignorePositionCaption = f.ignorePosition:CreateFontString("Status", "LOW", "GameFontNormal")
      f.ignorePositionCaption:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
      f.ignorePositionCaption:SetPoint("LEFT", f.ignorePosition, "RIGHT", 5, 0)
      f.ignorePositionCaption:SetFontObject(GameFontWhite)
      f.ignorePositionCaption:SetJustifyH("LEFT")
      f.ignorePositionCaption:SetText(T["Ignore Layout"])
    end


    do -- button: load
      f.loadButton = CreateFrame("Button", "pfShareLoad", f)
      pfUI.api.SkinButton(f.loadButton)
      f.loadButton:SetPoint("BOTTOMRIGHT", -5, 5)
      f.loadButton:SetWidth(75)
      f.loadButton:SetHeight(25)
      f.loadButton.text = f.loadButton:CreateFontString("Caption", "LOW", "GameFontWhite")
      f.loadButton.text:SetAllPoints(f.loadButton)
      f.loadButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
      f.loadButton.text:SetText(T["Import"])
      f.loadButton:SetScript("OnClick", function()
        local ImportConfig, error = loadstring(f.scroll.text:GetText())
        if not error and f.scroll.text:GetText() ~= "" then
          ImportConfig()
          pfUI:LoadConfig()
          CreateQuestionDialog(T["Some settings need to reload the UI to take effect.\nDo you want to reloadUI now?"], ReloadUI)
        end
      end)
    end

    do -- button: read
      f.readButton = CreateFrame("Button", "pfShareDecode", f)
      pfUI.api.SkinButton(f.readButton)
      f.readButton:SetPoint("RIGHT", f.loadButton, "LEFT", -10, 0)
      f.readButton:SetWidth(75)
      f.readButton:SetHeight(25)
      f.readButton.text = f.readButton:CreateFontString("Caption", "LOW", "GameFontWhite")
      f.readButton.text:SetAllPoints(f.readButton)
      f.readButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
      f.readButton.text:SetText(T["N/A"])
      f.readButton:SetScript("OnClick", function()
        this.func()
      end)
    end

    do -- button: export
      f.exportButton = CreateFrame("Button", "pfShareExport", f)
      pfUI.api.SkinButton(f.exportButton)
      f.exportButton:SetPoint("RIGHT", f.readButton, "LEFT", -10, 0)
      f.exportButton:SetWidth(75)
      f.exportButton:SetHeight(25)
      f.exportButton.text = f.exportButton:CreateFontString("Caption", "LOW", "GameFontWhite")
      f.exportButton.text:SetAllPoints(f.exportButton)
      f.exportButton.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
      f.exportButton.text:SetText(T["Export"])
      f.exportButton:SetScript("OnClick", function()
        -- generate a default config
        local myconfig = CopyTable(pfUI_config)
        _G.pfUI_config = {}
        pfUI:LoadConfig()
        local defconfig = CopyTable(pfUI_config)

        -- restore config and references
        _G.pfUI_config = CopyTable(myconfig)
        C = _G.pfUI_config

        local ignored = {}
        ignored["position"] = f.ignorePosition:GetChecked()
        ignored["disabled"] = f.ignorePosition:GetChecked()

        local compressed = enc(compress(serialize(myconfig, defconfig, "pfUI_config", ignored)))
        f.scroll.text:SetText(compressed)
        f.scroll.text.value = compressed
        f.scroll:SetVerticalScroll(0)
      end)
    end

    _G.SLASH_PFEXPORT1, _G.SLASH_PFEXPORT2, _G.SLASH_PFEXPORT3 = "/export", "/import", "/share"
    function SlashCmdList.PFEXPORT(msg, editbox)
      f:Show()
    end
  end
end)
