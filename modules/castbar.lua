pfUI:RegisterModule("castbar", function ()
  local font = C.castbar.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.castbar.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local function CreateCastbar(name, parent, unitstr, unitname)
    local cb = CreateFrame("Frame", name, parent or UIParent)

    CreateBackdrop(cb, default_border)

    cb:SetHeight(C.global.font_size * 1.5)
    cb:SetFrameStrata("MEDIUM")

    cb.unitstr = unitstr
    cb.unitname = unitname

    -- statusbar
    cb.bar = CreateFrame("StatusBar", nil, cb)
    cb.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    cb.bar:ClearAllPoints()
    cb.bar:SetAllPoints(cb)
    cb.bar:SetMinMaxValues(0, 100)
    cb.bar:SetValue(20)
    local r,g,b,a = strsplit(",", C.appearance.castbar.castbarcolor)
    cb.bar:SetStatusBarColor(r,g,b,a)

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

      local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(name)
      if not cast then
        -- scan for channel spells if no cast was found
        cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(name)
      end

      if cast then
        local duration = endTime - startTime
        local max = duration / 1000
        local cur = GetTime() - startTime / 1000
        local channel = UnitChannelInfo(name)

        this:SetAlpha(1)

        if this.endTime ~= endTime then
          this.bar:SetStatusBarColor(strsplit(",", C.appearance.castbar[(channel and "channelcolor" or "castbarcolor")]))
          this.bar:SetMinMaxValues(0, duration / 1000)
          this.bar.left:SetText(cast)
          this.fadeout = nil
          this.endTime = endTime
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
    cb:RegisterEvent(CASTBAR_DELAY_EVENT)
    cb:SetScript("OnEvent", function()
      this.delay = ( this.delay or 0 ) + arg1/1000
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

    if pfUI.uf.player then
      local pspace = tonumber(C.unitframes.player.pspace)
      pfUI.castbar.player:SetPoint("TOPLEFT", pfUI.uf.player, "BOTTOMLEFT", 0, -default_border * 2 - pspace)
      pfUI.castbar.player:SetWidth(pfUI.uf.player:GetWidth())
    else
      pfUI.castbar.player:SetPoint("CENTER", 0, -200)
      pfUI.castbar.player:SetWidth(200)
    end

    UpdateMovable(pfUI.castbar.player)
  end

  -- [[ pfTargetCastbar ]] --
  if C.castbar.target.hide_pfui == "0" then
    pfUI.castbar.target = CreateCastbar("pfTargetCastbar", UIParent, "target")

    if pfUI.uf.target then
      local pspace = tonumber(C.unitframes.target.pspace)
      pfUI.castbar.target:SetPoint("TOPLEFT", pfUI.uf.target, "BOTTOMLEFT", 0, -default_border * 2 - pspace)
      pfUI.castbar.target:SetWidth(pfUI.uf.target:GetWidth())
    else
      pfUI.castbar.target:SetPoint("CENTER", 0, -225)
      pfUI.castbar.target:SetWidth(200)
    end

    UpdateMovable(pfUI.castbar.target)
  end
end)
