pfUI:RegisterModule("buffwatch", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize("panels")
  local scanner = libtipscan:GetScanner("buffwatch")

  local fcache = {}
  local function BuffIsVisible(config, name)
    -- return if all buffs should be shown
    if config.filter == "none" then return true end

    local index = tostring(config)
    local mode = config.filter

    if not fcache[index] then
      fcache[index] = {}
      for _, val in pairs({strsplit("#", config[mode])}) do
        fcache[index][val] = true
      end
    end

    if mode == "whitelist" then
      return fcache[index][name]
    elseif mode == "blacklist" then
      return not fcache[index][name]
    end
  end

  local rgbcache = setmetatable({},{__mode="kv"})
  local function str2rgb(text)
    if not text then return 1, 1, 1 end
    if rgbcache[text] then return unpack(rgbcache[text]) end
    local counter = 1
    local l = string.len(text)
    for i = 1, l, 3 do
      counter = mod(counter*8161, 4294967279) + (string.byte(text,i)*16776193) + ((string.byte(text,i+1) or (l-i+256))*8372226) + ((string.byte(text,i+2) or (l-i+256))*3932164)
    end
    counter = mod(8161, 4294967279) + (string.byte(text,l)*16776193) + ((string.byte(text,l+1) or (l-l+256))*8372226) + ((string.byte(text,l+2) or (l+256))*3932164)

    local hash = mod(mod(counter, 4294967291),16777216)
    local r = (hash - (mod(hash,65536))) / 65536
    local g = ((hash - r*65536) - ( mod((hash - r*65536),256)) ) / 256
    local b = hash - r*65536 - g*256
    rgbcache[text] = { r / 255, g / 255, b / 255 }
    return unpack(rgbcache[text])
  end


  local function GetSafeTop(frame)
    if frame and frame.IsShown and frame:IsShown() and frame:IsVisible() then
      return frame:GetTop(), frame
    end

    return 0
  end

  -- iterate over given tables and return the first frame that is shown
  local function GetTopAnchor(anchors)
    local top, anchor = 0, anchors[1]

    for _, tbl in pairs(anchors) do

      -- in case of multiple anchor elements, iterate over each one
      for i=32, 1, -1 do
        if GetSafeTop(tbl[i]) > top then
          top, anchor = GetSafeTop(tbl[i])
        end
      end

      -- check top of regular anchor elements
      if GetSafeTop(tbl) > top then
        top, anchor = GetSafeTop(tbl)
      end
    end

    return anchor
  end

  local function GetBuffData(unit, id, type, selfdebuff)
    if unit == "player" then
      local bid = GetPlayerBuff(PLAYER_BUFF_START_ID+id, type)
      local stacks = GetPlayerBuffApplications(bid)
      local remaining = GetPlayerBuffTimeLeft(bid)
      local texture = GetPlayerBuffTexture(bid)
      local name

      if texture then
        scanner:SetPlayerBuff(bid)
        name = scanner:Line(1)
      end

      return remaining, texture, name, stacks
    elseif libdebuff and selfdebuff then
      local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitOwnDebuff(unit, id)
      return timeleft, texture, name, stacks
    elseif libdebuff then
      local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff(unit, id)
      return timeleft, texture, name, stacks
    end
  end

  local function StatusBarOnClick()
    if arg1 == "LeftButton" then
      local config = this.parent.config
      local skill = this.text:GetText()
      if IsControlKeyDown() then
        for _, val in pairs({strsplit("#", config.whitelist)}) do
          if val == skill then return end
        end
        config.whitelist = config.whitelist .. "#" .. skill
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc" .. skill .. "|r" .. T["is now whitelisted."])
      elseif IsShiftKeyDown() then
        for _, val in pairs({strsplit("#", config.blacklist)}) do
          if val == skill then return end
        end
        config.blacklist = config.blacklist .. "#" .. skill
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffcc" .. skill .. "|r" .. T["is now blacklisted."])
      end
    elseif this.parent.unit == "player" then
      CancelPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,this.type))
    end
  end

  local function StatusBarOnEnter()
    GameTooltip:SetOwner(this, "NONE")

    if this.unit == "player" then
      GameTooltip:SetPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,this.type))
    elseif this.type == "HARMFUL" then
      GameTooltip:SetUnitDebuff(this.unit, this.id)
    elseif this.type == "HELPFUL" then
      GameTooltip:SetUnitBuff(this.unit, this.id)
    end

    if IsShiftKeyDown() then
      GameTooltip:AddLine(" ")
      GameTooltip:AddDoubleLine(T["Ctrl-Click"], T["Add to Whitelist"], 1,1,1, .2,1,.8)
      GameTooltip:AddDoubleLine(T["Shift-Click"], T["Add to Blacklist"], 1,1,1, .2,1,.8)
    end

    GameTooltip:Show()
  end

  local function StatusBarOnLeave()
    GameTooltip:Hide()
  end

  local function StatusBarOnUpdate()
    local remaining = this.endtime - GetTime()
    this.bar:SetValue(remaining > 0 and remaining or 0)

    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end
    this.time:SetText(remaining > 0 and GetColoredTimeString(remaining) or "")
  end

  local function StatusBarRefreshParent()
    this.parent:RefreshPosition()
  end

  local function CreateStatusBar(bar, parent)
    local color = parent.color
    local bordercolor = parent.bordercolor
    local textcolor = parent.textcolor
    local width = parent:GetWidth()
    local height = parent:GetHeight()
    local framename = "pf" .. parent.unit .. ( parent.type == "HARMFUL" and "Debuff" or "Buff" ) .. "Bar" .. bar

    local font = parent.config.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default

    local frame = _G[framename] or CreateFrame("Button", framename, parent)
    frame:EnableMouse(1)
    frame:Hide()
    frame:SetPoint("BOTTOM", 0, (bar-1)*(height+2*border+1))
    frame:SetWidth(width)
    frame:SetHeight(height)

    frame.bar = CreateFrame("StatusBar", "pfBuffBar" .. bar, frame)
    frame.bar:SetPoint("TOPLEFT", frame, "TOPLEFT", height+1, 0)
    frame.bar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.bar:SetStatusBarTexture(pfUI.media["img:bar"])
    frame.bar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    frame.text = frame.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    frame.text:ClearAllPoints()
    frame.text:SetPoint("TOPLEFT", frame.bar, "TOPLEFT", 3, 0)
    frame.text:SetPoint("BOTTOMRIGHT", frame.bar, "BOTTOMRIGHT", -3, 0)
    frame.text:SetNonSpaceWrap(false)
    frame.text:SetFontObject(GameFontWhite)
    frame.text:SetFont(font, C.global.font_size)
    frame.text:SetTextColor(textcolor.r,textcolor.g,textcolor.b,1)
    frame.text:SetJustifyH("LEFT")

    frame.time = frame.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    frame.time:ClearAllPoints()
    frame.time:SetPoint("TOPLEFT", frame.bar, "TOPLEFT", 3, 0)
    frame.time:SetPoint("BOTTOMRIGHT", frame.bar, "BOTTOMRIGHT", -3, 0)
    frame.time:SetNonSpaceWrap(false)
    frame.time:SetFontObject(GameFontWhite)
    frame.time:SetFont(font, C.global.font_size)
    frame.time:SetTextColor(1,1,1,1)
    frame.time:SetJustifyH("RIGHT")

    frame.icon = frame:CreateTexture(nil, "OVERLAY")
    frame.icon:SetWidth(height)
    frame.icon:SetHeight(height)
    frame.icon:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.icon:SetTexCoord(.07,.93,.07,.93)

    frame.stacks = frame.bar:CreateFontString("Status", "DIALOG", "GameFontWhite")
    frame.stacks:SetFont(font, C.global.font_size, "OUTLINE")
    frame.stacks:SetAllPoints(frame.icon)
    frame.stacks:SetJustifyH("CENTER")
    frame.stacks:SetJustifyV("CENTER")

    frame.parent = parent
    frame:SetScript("OnUpdate", StatusBarOnUpdate)
    frame:SetScript("OnShow", StatusBarRefreshParent)
    frame:SetScript("OnHide", StatusBarRefreshParent)

    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:SetScript("OnClick", StatusBarOnClick)
    frame:SetScript("OnEnter", StatusBarOnEnter)
    frame:SetScript("OnLeave", StatusBarOnLeave)

    CreateBackdrop(frame)
    CreateBackdropShadow(frame)
    if bordercolor.r ~= "0" and bordercolor.g ~= "0" and bordercolor.b ~= "0" and bordercolor.a ~= "0" then
      frame.backdrop:SetBackdropBorderColor(bordercolor.r,bordercolor.g,bordercolor.b,1)
    end

    return frame
  end

  local function RefreshBuffBarFrame(frame)
    -- reinitialize all active buffs
    local selfdebuff = frame.config.selfdebuff == "1"

    for i=1,32 do
      local timeleft, texture, name, stacks = GetBuffData(frame.unit, i, frame.type, selfdebuff)
      timeleft = timeleft or 0

      if texture and name and name ~= "" and BuffIsVisible(frame.config, name) then
        frame.buffs[i][1] = timeleft
        frame.buffs[i][2] = i
        frame.buffs[i][3] = name
        frame.buffs[i][4] = texture
        frame.buffs[i][5] = stacks
      else
        frame.buffs[i][1] = 0
        frame.buffs[i][2] = nil
        frame.buffs[i][3] = nil
        frame.buffs[i][4] = nil
        frame.buffs[i][5] = 0
      end
    end

    table.sort(frame.buffs, frame.buffcmp)

    -- create a buff bar for each below threshold
    local bar = 1
    for id, data in pairs(frame.buffs) do
      if data[1] and ((data[1] ~= 0 and data[1] < frame.threshold) or frame.threshold == -1) -- timeleft checks
        and data[3] and data[3] ~= "" -- buff has a name
        and data[4] and data[4] ~= "" -- buff has a texture
      then
        local uuid = data[4] .. data[3] -- we use that to cache some values for buffs

        -- update bar data
        frame.bars[bar] = frame.bars[bar] or CreateStatusBar(bar, frame)
        frame.bars[bar].id = data[2]
        frame.bars[bar].unit = frame.unit
        frame.bars[bar].type = frame.type
        frame.bars[bar].endtime = GetTime() + ( data[1] > 0 and data[1] or -1 )

        -- update max duration the cached remaining values is less than
        -- the real one, indicates a buff renewal
        frame.durations[uuid] = frame.durations[uuid] or {}
        if not frame.durations[uuid][1] or frame.durations[uuid][1] < data[1] then
          frame.durations[uuid][2] = data[1] -- max
        end
        frame.durations[uuid][1] = data[1] -- current

        -- cache max stacks for the buff
        if not frame.charges[uuid] or frame.charges[uuid] < data[5] then
          frame.charges[uuid] = data[5]
        end

        -- set name
        if frame.bars[bar].cacheName ~= data[3] then
          frame.bars[bar].cacheName = data[3]
          frame.bars[bar].text:SetText(data[3])

          -- calculate dynamic auto color
          local r, g, b
          if frame.type == "HARMFUL" then
            r, g, b = 1, .2, .2
            local _, _, dtype = UnitDebuff(frame.unit, data[2])
            if dtype and DebuffTypeColor[dtype] then
              r,g,b = DebuffTypeColor[dtype].r,DebuffTypeColor[dtype].g,DebuffTypeColor[dtype].b
            end
          else
            r,g,b = str2rgb(data[3])
          end

          -- set auto background color
          if frame.config.dtypebg == "1" then
            frame.bars[bar].bar:SetStatusBarColor(r,g,b,1)
          end

          -- set auto border color
          if frame.config.dtypeborder == "1" then
            frame.bars[bar].backdrop:SetBackdropBorderColor(r,g,b,1)
          end

          -- set auto text color
          if frame.config.dtypetext == "1" then
            frame.bars[bar].text:SetTextColor(r,g,b,1)
          end
        end

        -- set texture
        if frame.bars[bar].cacheTexture ~= data[4] then
          frame.bars[bar].cacheTexture = data[4]
          frame.bars[bar].icon:SetTexture(data[4])
        end

        -- cache maxduration
        if frame.bars[bar].cacheMaxDuration ~= frame.durations[uuid][2] then
          frame.bars[bar].cacheMaxDuration = frame.durations[uuid][2]
          frame.bars[bar].bar:SetMinMaxValues(0, frame.durations[uuid][2])
        end

        -- set stacks
        if data[5] > 1 then
          local stacks_percentage = data[5] / (frame.charges[uuid] * .01)
          local sr, sg, sb, sa
          if stacks_percentage >= 90 then
            sr, sg, sb, sa = .3, 1, .3, 1
          elseif stacks_percentage >= 60 then
            sr, sg, sb, sa = 1, 1, .3, 1
          elseif stacks_percentage >= 0 then
            sr, sg, sb, sa = 1, .3, .3, 1
          end
          if frame.config.colorstacks == "1" then
            frame.bars[bar].stacks:SetText(rgbhex(sr,sg,sb) .. data[5])
          else
            frame.bars[bar].stacks:SetText(data[5])
          end
        else
          frame.bars[bar].stacks:SetText("")
        end

        frame.bars[bar]:Show()
        bar = bar + 1
      end
    end

    -- hide remaining bars
    for i = bar, table.getn(frame.bars) do
      frame.bars[i]:Hide()
    end
  end

  -- Create a new Buff Bar
  local function BuffBarFrameOnUpdate()
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
    RefreshBuffBarFrame(this)
    this:RefreshPosition()
  end

  local function RefreshPosition(self)
    -- avoid position changes during unlock
    if pfUI.unlock and pfUI.unlock:IsShown() then return end

    if not pfUI_config["position"][self:GetName()] then
      local anchor = GetTopAnchor(self.anchors)

      if not self.lastanchor or self.lastanchor ~= anchor then
        self:ClearAllPoints()
        self:SetPoint("LEFT", self.anchors[1], "LEFT", 0, 0)
        self:SetPoint("BOTTOM", anchor, "TOP", 0, border*2+1)
        UpdateMovable(self, true)
        self.lastanchor = anchor
      end
    end
  end

  local function CreateBuffBarFrame(unit, type)
    local framename = "pf" .. unit .. ( type == "HARMFUL" and "Debuff" or "Buff" ) .. "Bar"
    local frame = _G[framename] or CreateFrame("Frame", framename, UIParent)

    frame.unit = strlower(unit)
    frame.type = type
    frame.bars = { }
    frame.durations = { }
    frame.charges = { }
    frame.buffs = { }
    for i=1,32 do
      frame.buffs[i] = { }
    end

    frame.RefreshPosition = RefreshPosition

    -- OnEvent (UNIT_AURA) doesn't trigger properly on buff refresh
    frame:SetScript("OnUpdate", BuffBarFrameOnUpdate)

    return frame
  end

  local function asc(a,b)
    return a[1] > b[1]
  end

  local function desc(a,b)
    return a[1] < b[1]
  end

  -- create player buffbars
  if pfUI.uf.player and C.buffbar.pbuff.enable == "1" then
    pfUI.uf.player.buffbar = CreateBuffBarFrame("Player", "HELPFUL")
    local config = C.buffbar.pbuff
    local r, g, b, a = strsplit(",", config.color)
    local br, bg, bb, ba = strsplit(",", config.bordercolor)
    local tr, tg, tb, ta = strsplit(",", config.textcolor)

    pfUI.uf.player.buffbar:SetWidth(config.width == "-1" and pfUI.uf.player:GetWidth() or config.width)
    pfUI.uf.player.buffbar:SetHeight(config.height)
    pfUI.uf.player.buffbar.threshold = tonumber(config.threshold)
    pfUI.uf.player.buffbar.config = config
    pfUI.uf.player.buffbar.buffcmp = config.sort == "asc" and asc or desc
    pfUI.uf.player.buffbar.color = { r = r, g = g, b = b, a = a }
    pfUI.uf.player.buffbar.bordercolor = { r = br, g = bg, b = bb, a = ba }
    pfUI.uf.player.buffbar.textcolor = { r = tr, g = tg, b = tb, a = ta }
    pfUI.uf.player.buffbar.anchors = {
      pfUI.uf.player,
      pfUI.uf.player and pfUI.uf.player.debuffs,
      pfUI.uf.player and pfUI.uf.player.buffs
    }

    pfUI.uf.player.buffbar:SetPoint("LEFT", pfUI.uf.player, "LEFT", 0, 0)
    pfUI.uf.player.buffbar:SetPoint("BOTTOM", pfUI.uf.player, "TOP", 0, border*2+1)
    UpdateMovable(pfUI.uf.player.buffbar)
  end

  -- create player debuffbars
  if pfUI.uf.player and C.buffbar.pdebuff.enable == "1" then
    local config = C.buffbar.pdebuff
    local r, g, b, a = strsplit(",", config.color)
    local br, bg, bb, ba = strsplit(",", config.bordercolor)
    local tr, tg, tb, ta = strsplit(",", config.textcolor)

    pfUI.uf.player.debuffbar = CreateBuffBarFrame("Player", "HARMFUL")
    pfUI.uf.player.debuffbar:SetWidth(config.width == "-1" and pfUI.uf.player:GetWidth() or config.width)
    pfUI.uf.player.debuffbar:SetHeight(config.height)
    pfUI.uf.player.debuffbar.threshold = tonumber(config.threshold)
    pfUI.uf.player.debuffbar.config = config
    pfUI.uf.player.debuffbar.buffcmp = config.sort == "asc" and asc or desc
    pfUI.uf.player.debuffbar.color = { r = r, g = g, b = b, a = a }
    pfUI.uf.player.debuffbar.bordercolor = { r = br, g = bg, b = bb, a = ba }
    pfUI.uf.player.debuffbar.textcolor = { r = tr, g = tg, b = tb, a = ta }
    pfUI.uf.player.debuffbar.anchors = {
      pfUI.uf.player,
      pfUI.uf.player and pfUI.uf.player.buffbar and pfUI.uf.player.buffbar.bars,
      pfUI.uf.player and pfUI.uf.player.debuffs,
      pfUI.uf.player and pfUI.uf.player.buffs
    }

    pfUI.uf.player.debuffbar:SetPoint("LEFT", pfUI.uf.player, "LEFT", 0, 0)
    pfUI.uf.player.debuffbar:SetPoint("BOTTOM", pfUI.uf.player, "TOP", 0, border*2+1)
    UpdateMovable(pfUI.uf.player.debuffbar)
  end

  -- create target debuffbars
  if pfUI.uf.target and C.buffbar.tdebuff.enable == "1" then
    local config = C.buffbar.tdebuff
    local r, g, b, a = strsplit(",", config.color)
    local br, bg, bb, ba = strsplit(",", config.bordercolor)
    local tr, tg, tb, ta = strsplit(",", config.textcolor)

    pfUI.uf.target.debuffbar = CreateBuffBarFrame("Target", "HARMFUL")
    pfUI.uf.target.debuffbar:SetWidth(config.width == "-1" and pfUI.uf.target:GetWidth() or config.width)
    pfUI.uf.target.debuffbar:SetHeight(config.height)
    pfUI.uf.target.debuffbar.config = config
    pfUI.uf.target.debuffbar.buffcmp = config.sort == "asc" and asc or desc
    pfUI.uf.target.debuffbar.color = { r = r, g = g, b = b, a = a }
    pfUI.uf.target.debuffbar.bordercolor = { r = br, g = bg, b = bb, a = ba }
    pfUI.uf.target.debuffbar.textcolor = { r = tr, g = tg, b = tb, a = ta }
    pfUI.uf.target.debuffbar.threshold = tonumber(config.threshold)
    pfUI.uf.target.debuffbar.anchors = {
      pfUI.uf.target,
      pfUI.uf.target and pfUI.uf.target.buffbar and pfUI.uf.target.buffbar.bars,
      pfUI.uf.target and pfUI.uf.target.debuffs,
      pfUI.uf.target and pfUI.uf.target.buffs
    }

    pfUI.uf.target.debuffbar:SetPoint("LEFT", pfUI.uf.target, "LEFT", 0, 0)
    pfUI.uf.target.debuffbar:SetPoint("BOTTOM", pfUI.uf.target, "TOP", 0, border*2+1)
    UpdateMovable(pfUI.uf.target.debuffbar)
  end
end)
