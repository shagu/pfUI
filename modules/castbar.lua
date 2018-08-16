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
    cb:Hide()

    cb.unitstr = unitstr
    cb.unitname = unitname

    cb.delay = 0

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
        return
      end

      if not UnitExists(this.unitstr) then
        this:Hide()
        this.fadeout = nil
      end

      local name = this.unitstr and UnitName(this.unitstr) or this.unitname

      if this.fadeout and this:GetAlpha() > 0 then
        if this:GetAlpha() == 0 or this.playername ~= name then
          this:Hide()
          this.fadeout = nil
        end

        this:SetAlpha(this:GetAlpha()-0.05)
        return
      end

      local spellname, start, duration, icon, delay, channel = libcast:GetCastInfo(name)
      if spellname then
        local max = duration / 1000
        local cur = channel and duration / 1000 - delay + start - GetTime() or
                    GetTime() - start - delay
        cur = cur > max and max or cur
        cur = cur < 0 and 0 or cur

        this.bar:SetValue(cur)

        if delay > 0 then
          delay = "|cffffaaaa" .. (channel and "-" or "+") .. round(delay,1) .. " |r "
          this.bar.right:SetText(delay .. string.format("%.1f",cur) .. " / " .. round(max,1))
        else
          this.bar.right:SetText(string.format("%.1f",cur) .. " / " .. round(max,1))
        end

        this.fadeout = nil
      else
        this.bar:SetMinMaxValues(1,100)
        this.bar:SetValue(100)
        this.fadeout = 1
      end
    end)

    function cb.OnEvent(self)
      local name = self.unitstr and UnitName(self.unitstr) or self.unitname

      local spellname, start, casttime, icon, delay, channel = libcast:GetCastInfo(name)
      if spellname then
        self.bar:SetStatusBarColor(strsplit(",", C.appearance.castbar[(channel and "channelcolor" or "castbarcolor")]))
        self.bar:SetMinMaxValues(0, casttime / 1000)
        self.bar.left:SetText(spellname)

        self:SetAlpha(1)
        self:Show()
        self.fadeout = nil
        self.playername = name
      else
        self.bar:SetMinMaxValues(1,100)
        self.bar:SetValue(100)
        self.fadeout = 1
      end
    end

    libcast:RegisterEventFunc(cb.OnEvent, cb)
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
