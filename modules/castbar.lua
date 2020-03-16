pfUI:RegisterModule("castbar", "vanilla:tbc", function ()
  local font = C.castbar.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.castbar.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
  local rawborder, default_border = GetBorderSize("unitframes")
  local cbtexture = pfUI.media[C.appearance.castbar.texture]

  local function CreateCastbar(name, parent, unitstr, unitname)
    local cb = CreateFrame("Frame", name, parent or UIParent)

    cb:SetHeight(C.global.font_size * 1.5)
    cb:SetFrameStrata("MEDIUM")

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
    cb.bar.left:SetPoint("TOPLEFT", cb.bar, "TOPLEFT", 3, 0)
    cb.bar.left:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", -3, 0)
    cb.bar.left:SetNonSpaceWrap(false)
    cb.bar.left:SetFontObject(GameFontWhite)
    cb.bar.left:SetTextColor(1,1,1,1)
    cb.bar.left:SetFont(font, font_size, "OUTLINE")
    cb.bar.left:SetText("left")
    cb.bar.left:SetJustifyH("left")

    -- text right
    cb.bar.right = cb.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
    cb.bar.right:ClearAllPoints()
    cb.bar.right:SetPoint("TOPLEFT", cb.bar, "TOPLEFT", 3, 0)
    cb.bar.right:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", -3, 0)
    cb.bar.right:SetNonSpaceWrap(false)
    cb.bar.right:SetFontObject(GameFontWhite)
    cb.bar.right:SetTextColor(1,1,1,1)
    cb.bar.right:SetFont(font, font_size, "OUTLINE")
    cb.bar.right:SetText("right")
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

      local name = this.unitstr and UnitName(this.unitstr) or this.unitname
      if not name then return end

      local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unitstr or this.unitname)
      if not cast then
        -- scan for channel spells if no cast was found
        cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(this.unitstr or this.unitname)
      end

      if cast then
        local duration = endTime - startTime
        local max = duration / 1000
        local cur = GetTime() - startTime / 1000
        local channel = UnitChannelInfo(name)

        this:SetAlpha(1)

        local rank = this.showrank and nameSubtext and nameSubtext ~= "" and string.format(" |cffaaffcc[%s]|r", nameSubtext) or ""
        if this.endTime ~= endTime then
          this.bar:SetStatusBarColor(strsplit(",", C.appearance.castbar[(channel and "channelcolor" or "castbarcolor")]))
          this.bar:SetMinMaxValues(0, duration / 1000)
          this.bar.left:SetText(cast .. rank)
          this.fadeout = nil
          this.endTime = endTime

          -- set texture
          if texture and this.showicon then
            local size = this:GetHeight()
            this.icon:Show()
            this.icon:SetHeight(size)
            this.icon:SetWidth(size)
            this.icon.texture:SetTexture(texture)
            this.bar:SetPoint("TOPLEFT", this.icon, "TOPRIGHT", 3, 0)
          else
            this.bar:SetPoint("TOPLEFT", this, 0, 0)
            this.icon:Hide()
          end

          if this.showlag then
            local _, _, lag = GetNetStats()
            local width = this:GetWidth() / (duration/1000) * (lag/1000)
            this.bar.lag:SetWidth(width)
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

        if this.delay and this.delay > 0 then
          local delay = "|cffffaaaa" .. (channel and "-" or "+") .. round(this.delay,1) .. " |r "
          this.bar.right:SetText(delay .. string.format("%.1f",cur) .. " / " .. round(max,1))
        else
          this.bar.right:SetText(string.format("%.1f",cur) .. " / " .. round(max,1))
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
    cb:RegisterEvent(CASTBAR_EVENT_CAST_DELAY)
    cb:RegisterEvent(CASTBAR_EVENT_CHANNEL_DELAY)
    cb:SetScript("OnEvent", function()
      if this.unitstr and not UnitIsUnit(this.unitstr, "player") then return end

      if event == CASTBAR_EVENT_CAST_DELAY then
        local isCast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unitstr or this.unitname)
        if not isCast then return end
        if not this.endTime then return end
        this.delay = this.delay + (endTime - this.endTime) / 1000
      elseif event == CASTBAR_EVENT_CHANNEL_DELAY then
        local isChannel, _, _, _, startTime, endTime = UnitChannelInfo(this.unitstr or this.unitname)
        if not isChannel then return end
        this.delay = ( this.delay or 0 ) + this.bar:GetValue() - (endTime/1000 - GetTime())
      end
    end)

    cb:SetAlpha(0)
    return cb
  end

  pfUI.castbar = CreateFrame("Frame", "pfCastBar", UIParent)

  -- hide blizzard
  if C.castbar.player.hide_blizz == "1" then
    CastingBarFrame:UnregisterAllEvents()
    CastingBarFrame:Hide()
  end

  -- [[ pfPlayerCastbar ]] --
  if C.castbar.player.hide_pfui == "0" then
    pfUI.castbar.player = CreateCastbar("pfPlayerCastbar", UIParent, "player")
    pfUI.castbar.player.showicon = C.castbar.player.showicon == "1" and true or nil
    pfUI.castbar.player.showlag = C.castbar.player.showlag == "1" and true or nil
    pfUI.castbar.player.showrank = C.castbar.player.showrank == "1" and true or nil

    if pfUI.uf.player then
      local pspace = tonumber(C.unitframes.player.pspace)
      local width = C.castbar.player.width ~= "-1" and C.castbar.player.width or pfUI.uf.player:GetWidth()
      pfUI.castbar.player:SetPoint("TOPLEFT", pfUI.uf.player, "BOTTOMLEFT", 0, -default_border * 2 - pspace)
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
    pfUI.castbar.target.showlag = C.castbar.target.showlag == "1" and true or nil
    pfUI.castbar.target.showrank = C.castbar.target.showrank == "1" and true or nil

    if pfUI.uf.target then
      local pspace = tonumber(C.unitframes.target.pspace)
      local width = C.castbar.target.width ~= "-1" and C.castbar.target.width or pfUI.uf.target:GetWidth()
      pfUI.castbar.target:SetPoint("TOPLEFT", pfUI.uf.target, "BOTTOMLEFT", 0, -default_border * 2 - pspace)
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
    pfUI.castbar.focus.showlag = C.castbar.focus.showlag == "1" and true or nil
    pfUI.castbar.focus.showrank = C.castbar.focus.showrank == "1" and true or nil

    -- reset unitstr for vanilla focus frame emulation
    if pfUI.client <= 11200 then
      pfUI.castbar.focus.unitstr = nil
    end

    local pspace = tonumber(C.unitframes.focus.pspace)
    local width = C.castbar.focus.width ~= "-1" and C.castbar.focus.width or pfUI.uf.focus:GetWidth()
    pfUI.castbar.focus:SetPoint("TOPLEFT", pfUI.uf.focus, "BOTTOMLEFT", 0, -default_border * 2 - pspace)
    pfUI.castbar.focus:SetWidth(width)

    if C.castbar.focus.height ~= "-1" then
      pfUI.castbar.focus:SetHeight(C.castbar.focus.height)
    end

    -- make sure the castbar is set to the same name as the focus frame is
    HookScript(pfUI.castbar.focus, "OnUpdate", function()
      -- remove unitname when focus unit changed
      if this.lastunit ~= pfUI.uf.focus.unitname then
        this.lastunit = pfUI.uf.focus.unitname
        pfUI.castbar.focus.unitname = nil
      end

      -- attach a proper unitname as soon as we get a unitstr
      if not pfUI.castbar.focus.unitname and pfUI.uf.focus.unitname ~= "focus" and pfUI.uf.focus.label and pfUI.uf.focus.id then
        local unitstr = string.format("%s%s", pfUI.uf.focus.label, pfUI.uf.focus.id)
        if UnitExists(unitstr) and strlower(UnitName(unitstr)) == pfUI.uf.focus.unitname then
          pfUI.castbar.focus.unitname = UnitName(unitstr)
        end
      end
    end)

    UpdateMovable(pfUI.castbar.focus)
  end
end)
