pfUI:RegisterModule("castbar", "vanilla:tbc", function ()
  local font = C.castbar.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.castbar.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
  local rawborder, default_border = GetBorderSize("unitframes")
  local cbtexture = pfUI.media[C.appearance.castbar.texture]

  local function CreateCastbar(name, parent, unitstr, unitname)
    local cb = CreateFrame("Frame", name, parent or UIParent)

    cb:SetHeight(C.global.font_size * 1.5)
    cb:SetFrameStrata("MEDIUM")
    cb:SetFrameLevel(8)

    cb.unitstr = unitstr
    cb.unitname = unitname

    -- icon
    cb.icon = CreateFrame("Frame", nil, cb)
    cb.icon:SetPoint("TOPLEFT", 0, 0)
    cb.icon:SetHeight(16)
    cb.icon:SetWidth(16)

    cb.icon.texture = cb.icon:CreateTexture(nil, "OVERLAY")
    cb.icon.texture:SetAllPoints()
    cb.icon.texture:SetTexCoord(.08, .92, .08, .92)
    CreateBackdrop(cb.icon, default_border)

    -- statusbar
    cb.bar = CreateFrame("StatusBar", nil, cb)
    cb.bar:SetStatusBarTexture(cbtexture)
    cb.bar:ClearAllPoints()
    cb.bar:SetAllPoints(cb)
    cb.bar:SetMinMaxValues(0, 100)
    cb.bar:SetValue(20)
    local r,g,b,a = strsplit(",", C.appearance.castbar.castbarcolor)
    cb.bar:SetStatusBarColor(r,g,b,a)
    CreateBackdrop(cb.bar, default_border)
    CreateBackdropShadow(cb.bar)

    -- text left
    cb.bar.left = cb.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    cb.bar.left:ClearAllPoints()
    cb.bar.left:SetPoint("TOPLEFT", cb.bar, "TOPLEFT", 3 + C.castbar[unitstr].txtleftoffx, C.castbar[unitstr].txtleftoffy)
    cb.bar.left:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", -3 + C.castbar[unitstr].txtleftoffx, C.castbar[unitstr].txtleftoffy)
    cb.bar.left:SetNonSpaceWrap(false)
    cb.bar.left:SetFontObject(GameFontWhite)
    cb.bar.left:SetTextColor(1,1,1,1)
    cb.bar.left:SetFont(font, font_size, "OUTLINE")
    cb.bar.left:SetJustifyH("left")

    -- text right
    cb.bar.right = cb.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    cb.bar.right:ClearAllPoints()
    cb.bar.right:SetPoint("TOPLEFT", cb.bar, "TOPLEFT", 3 + C.castbar[unitstr].txtrightoffx, C.castbar[unitstr].txtrightoffy)
    cb.bar.right:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", -3 + C.castbar[unitstr].txtrightoffx, C.castbar[unitstr].txtrightoffy)
    cb.bar.right:SetNonSpaceWrap(false)
    cb.bar.right:SetFontObject(GameFontWhite)
    cb.bar.right:SetTextColor(1,1,1,1)
    cb.bar.right:SetFont(font, font_size, "OUTLINE")
    cb.bar.right:SetJustifyH("right")

    cb.bar.lag = cb.bar:CreateTexture(nil, "OVERLAY")
    cb.bar.lag:SetPoint("TOPRIGHT", cb.bar, "TOPRIGHT", 0, 0)
    cb.bar.lag:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", 0, 0)
    cb.bar.lag:SetTexture(1,.2,.2,.2)

    cb:SetScript("OnUpdate", function()
      if this.drag and this.drag:IsShown() then
        this:SetAlpha(1)
        return
      end

      if not UnitExists(this.unitstr) then
        this:SetAlpha(0)
      end

      if this.fadeout and this:GetAlpha() > 0 then
        if this:GetAlpha() == 0 then
          this.fadeout = nil
        end

        this:SetAlpha(this:GetAlpha()-0.05)
      end

      local channel = nil
      local query = this.unitstr ~= "" and this.unitstr or this.unitname
      if not query then return end

      -- transform all non player unitstrings to unit guids
      if superwow_active and this.unitstr and not UnitIsUnit(this.unitstr, 'player') then
        local _, guid = UnitExists(this.unitstr)
        query = guid or query
      end

      local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(query)
      if not cast then
        -- scan for channel spells if no cast was found
        channel, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(query)
        cast = channel
      end

      if cast then
        local duration = endTime - startTime
        local max = duration / 1000
        local cur = GetTime() - startTime / 1000

        this:SetAlpha(1)

        local spellname = this.showname and cast and cast .. " " or ""
        local rank = this.showrank and nameSubtext and nameSubtext ~= "" and string.format("|cffaaffcc[%s]|r", nameSubtext) or ""

        if this.endTime ~= endTime then
          this.bar:SetStatusBarColor(strsplit(",", C.appearance.castbar[(channel and "channelcolor" or "castbarcolor")]))
          this.bar:SetMinMaxValues(0, duration / 1000)
          this.bar.left:SetText(spellname .. rank)
          this.fadeout = nil
          this.endTime = endTime

          -- set texture
          if texture and this.showicon then
            local size = this:GetHeight()
            this.icon:Show()
            this.icon:SetHeight(size)
            this.icon:SetWidth(size)
            this.icon.texture:SetTexture(texture)
            this.bar:SetPoint("TOPLEFT", this.icon, "TOPRIGHT", this.spacing, 0)
          else
            this.bar:SetPoint("TOPLEFT", this, 0, 0)
            this.icon:Hide()
          end

          if this.showlag then
            local _, _, lag = GetNetStats()
            local width = this:GetWidth() / (duration/1000) * (lag/1000)
            this.bar.lag:SetWidth(math.min(this:GetWidth(), width))
          else
            this.bar.lag:Hide()
          end
        end

        if channel then
          cur = max + startTime/1000 - GetTime()
        end

        cur = cur > max and max or cur
        cur = cur < 0 and 0 or cur

        this.bar:SetValue(cur)

        if this.showtimer then
          if this.delay and this.delay > 0 then
            local delay = "|cffffaaaa" .. (channel and "-" or "+") .. round(this.delay,1) .. " |r "
            this.bar.right:SetText(delay .. string.format("%.1f",cur) .. " / " .. round(max,1))
          else
            this.bar.right:SetText(string.format("%.1f",cur) .. " / " .. round(max,1))
          end
        end

        this.fadeout = nil
      else
        this.bar:SetMinMaxValues(1,100)
        this.bar:SetValue(100)
        this.fadeout = 1
        this.delay = 0
      end
    end)

    -- register for spell delay
    local playerarg = nil
    cb:RegisterEvent(CASTBAR_EVENT_CAST_DELAY)
    cb:RegisterEvent(CASTBAR_EVENT_CHANNEL_DELAY)
    cb:RegisterEvent(CASTBAR_EVENT_CAST_START)
    cb:RegisterEvent(CASTBAR_EVENT_CHANNEL_START)
    cb:SetScript("OnEvent", function()
      if this.unitstr and not UnitIsUnit(this.unitstr, "player") then return end
      playerarg = pfUI.client <= 11200 or arg1 == "player" and true or nil

      if event == CASTBAR_EVENT_CAST_DELAY and playerarg then
        local isCast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unitstr or this.unitname)
        if not isCast then return end
        if not this.endTime then return end
        this.delay = this.delay + (endTime - this.endTime) / 1000
      elseif event == CASTBAR_EVENT_CHANNEL_DELAY and playerarg then
        local isChannel, _, _, _, startTime, endTime = UnitChannelInfo(this.unitstr or this.unitname)
        if not isChannel then return end
        this.delay = ( this.delay or 0 ) + this.bar:GetValue() - (endTime/1000 - GetTime())
      elseif playerarg then
        this.delay = 0
      end
    end)

    cb:SetAlpha(0)
    return cb
  end

  pfUI.castbar = CreateFrame("Frame", "pfCastBar", UIParent)

  -- hide blizzard
  if C.castbar.player.hide_blizz == "1" then
    CastingBarFrame:SetScript("OnShow", function() CastingBarFrame:Hide() end)
    CastingBarFrame:UnregisterAllEvents()
    CastingBarFrame:Hide()
  end

  -- [[ pfPlayerCastbar ]] --
  if C.castbar.player.hide_pfui == "0" then
    pfUI.castbar.player = CreateCastbar("pfPlayerCastbar", UIParent, "player")
    pfUI.castbar.player.showicon = C.castbar.player.showicon == "1" and true or nil
    pfUI.castbar.player.showname = C.castbar.player.showname == "1" and true or nil
    pfUI.castbar.player.showtimer = C.castbar.player.showtimer == "1" and true or nil
    pfUI.castbar.player.showlag = C.castbar.player.showlag == "1" and true or nil
    pfUI.castbar.player.showrank = C.castbar.player.showrank == "1" and true or nil
    pfUI.castbar.player.spacing = default_border * 2 + tonumber(C.unitframes.player.pspace) * GetPerfectPixel()

    if pfUI.uf.player then
      local anchor = pfUI.uf.player.portrait:GetHeight() > pfUI.uf.player:GetHeight() and pfUI.uf.player.power or pfUI.uf.player
      local width = C.castbar.player.width ~= "-1" and C.castbar.player.width or anchor:GetWidth()
      pfUI.castbar.player:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -pfUI.castbar.player.spacing)
      pfUI.castbar.player:SetWidth(width)
    else
      local width = C.castbar.player.width ~= "-1" and C.castbar.player.width or 200
      pfUI.castbar.player:SetPoint("CENTER", 0, -200)
      pfUI.castbar.player:SetWidth(width)
    end

    if C.castbar.player.height ~= "-1" then
      pfUI.castbar.player:SetHeight(C.castbar.player.height)
    end

    UpdateMovable(pfUI.castbar.player)
  end

  -- [[ pfTargetCastbar ]] --
  if C.castbar.target.hide_pfui == "0" then
    pfUI.castbar.target = CreateCastbar("pfTargetCastbar", UIParent, "target")
    pfUI.castbar.target.showicon = C.castbar.target.showicon == "1" and true or nil
    pfUI.castbar.target.showname = C.castbar.target.showname == "1" and true or nil
    pfUI.castbar.target.showtimer = C.castbar.target.showtimer == "1" and true or nil
    pfUI.castbar.target.showlag = C.castbar.target.showlag == "1" and true or nil
    pfUI.castbar.target.showrank = C.castbar.target.showrank == "1" and true or nil
    pfUI.castbar.target.spacing = default_border * 2 + tonumber(C.unitframes.target.pspace) * GetPerfectPixel()

    if pfUI.uf.target then
      local anchor = pfUI.uf.target.portrait:GetHeight() > pfUI.uf.target:GetHeight() and pfUI.uf.target.power or pfUI.uf.target
      local width = C.castbar.target.width ~= "-1" and C.castbar.target.width or anchor:GetWidth()
      pfUI.castbar.target:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -pfUI.castbar.target.spacing)
      pfUI.castbar.target:SetWidth(width)
    else
      local width = C.castbar.target.width ~= "-1" and C.castbar.target.width or 200
      pfUI.castbar.target:SetPoint("CENTER", 0, -225)
      pfUI.castbar.target:SetWidth(width)
    end

    if C.castbar.target.height ~= "-1" then
      pfUI.castbar.target:SetHeight(C.castbar.target.height)
    end

    UpdateMovable(pfUI.castbar.target)
  end

  -- [[ pfFocusCastbar ]] --
  if C.castbar.focus.hide_pfui == "0" and pfUI.uf.focus then
    pfUI.castbar.focus = CreateCastbar("pfFocusCastbar", UIParent, "focus")
    pfUI.castbar.focus.showicon = C.castbar.focus.showicon == "1" and true or nil
    pfUI.castbar.focus.showname = C.castbar.focus.showname == "1" and true or nil
    pfUI.castbar.focus.showtimer = C.castbar.focus.showtimer == "1" and true or nil
    pfUI.castbar.focus.showlag = C.castbar.focus.showlag == "1" and true or nil
    pfUI.castbar.focus.showrank = C.castbar.focus.showrank == "1" and true or nil
    pfUI.castbar.focus.spacing = default_border * 2 + tonumber(C.unitframes.focus.pspace) * GetPerfectPixel()

    -- reset unitstr for vanilla focus frame emulation
    if pfUI.client <= 11200 then
      pfUI.castbar.focus.unitstr = nil
    end

    local anchor = pfUI.uf.focus.portrait:GetHeight() > pfUI.uf.focus:GetHeight() and pfUI.uf.focus.power or pfUI.uf.focus
    local width = C.castbar.focus.width ~= "-1" and C.castbar.focus.width or anchor:GetWidth()
    pfUI.castbar.focus:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -pfUI.castbar.focus.spacing)
    pfUI.castbar.focus:SetWidth(width)

    if C.castbar.focus.height ~= "-1" then
      pfUI.castbar.focus:SetHeight(C.castbar.focus.height)
    end

    -- keep unit values in sync with focus unitframe
    HookScript(pfUI.castbar.focus, "OnUpdate", function()
      if pfUI.uf.focus.unitname == "focus" then return end
      if pfUI.uf.focus.unitname == "" then return end

      -- try to obtain a unitstr
      pfUI.castbar.focus.unitstr = string.format("%s%s", (pfUI.uf.focus.label or ""), (pfUI.uf.focus.id or ""))
      pfUI.castbar.focus.unitstr = pfUI.castbar.focus.unitstr == "" and nil or pfUI.castbar.focus.unitstr

      if pfUI.castbar.focus.unitstr then
        -- read non-lowercase unitname when possible
        pfUI.castbar.focus.unitname = UnitName(pfUI.castbar.focus.unitstr) or pfUI.castbar.focus.unitname
      elseif strlower(pfUI.castbar.focus.unitname) ~= strlower(pfUI.uf.focus.unitname) then
        -- sync unitname with focus frame's lowercase value
        pfUI.castbar.focus.unitname = pfUI.uf.focus.unitname
      end
    end)

    UpdateMovable(pfUI.castbar.focus)
  end
end)
