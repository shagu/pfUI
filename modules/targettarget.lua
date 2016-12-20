pfUI:RegisterModule("targettarget", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  pfUI.uf.targettargetNotify = CreateFrame("Button",nil,UIParent)
  pfUI.uf.targettargetNotify:SetScript("OnUpdate", function()
      if UnitExists("targettarget") or (pfUI.gitter and pfUI.gitter:IsShown()) then
        pfUI.uf.targettarget:Show()
      else
        pfUI.uf.targettarget:Hide()
      end
    end)

  pfUI.uf.targettarget = CreateFrame("Button","pfTargetTarget",UIParent)
  pfUI.uf.targettarget.label = "targettarget"
  pfUI.uf.targettarget.id = ""
  pfUI.uf.targettarget:SetFrameStrata("LOW")
  pfUI.uf.targettarget:SetWidth(100)
  pfUI.uf.targettarget:SetHeight(20 + 2*default_border + pfUI_config.unitframes.ttarget.pspace)
  pfUI.uf.targettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 125)
  pfUI.utils:UpdateMovable(pfUI.uf.targettarget)

  pfUI.uf.targettarget:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  pfUI.uf.targettarget:SetScript("OnEnter", function()
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetUnit(this.label .. this.id)
    GameTooltip:Show()
  end)

  pfUI.uf.targettarget:SetScript("OnLeave", function()
    GameTooltip:FadeOut()
  end)
  pfUI.uf.targettarget:SetScript("OnClick", function ()
    TargetUnit("targettarget")

    if pfUI_config.unitframes.globalclick == "0" then return end

    -- clickcast: shift modifier
    if IsShiftKeyDown() then
      if pfUI_config.unitframes.raid.clickcast_shift ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast_shift)
        pfUI.uf.target.noanim = "yes"
        TargetLastTarget()
        return
      end
    -- clickcast: alt modifier
    elseif IsAltKeyDown() then
      if pfUI_config.unitframes.raid.clickcast_alt ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast_alt)
        pfUI.uf.target.noanim = "yes"
        TargetLastTarget()
        return
      end
    -- clickcast: ctrl modifier
    elseif IsControlKeyDown() then
      if pfUI_config.unitframes.raid.clickcast_ctrl ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast_ctrl)
        pfUI.uf.target.noanim = "yes"
        TargetLastTarget()
        return
      end
    -- clickcast: default
    else
      if pfUI_config.unitframes.raid.clickcast ~= "" then
        CastSpellByName(pfUI_config.unitframes.raid.clickcast)
        pfUI.uf.target.noanim = "yes"
        TargetLastTarget()
        return
      else
        -- no clickcast: default action
        TargetUnit("targettarget")
      end
    end
  end)

  pfUI.uf.targettarget:SetScript("OnUpdate", function()
      if UnitExists("targettarget") then
        pfUI.uf.targettarget:Show()
      elseif (pfUI.gitter and pfUI.gitter:IsShown()) then
        pfUI.uf.targettarget:Show()
        return
      else
        pfUI.uf.targettarget:Hide()
        return
      end

      local raidIcon = GetRaidTargetIndex("targettarget")
      if raidIcon then
        SetRaidTargetIconTexture(pfUI.uf.targettarget.hp.raidIcon.texture, raidIcon)
        pfUI.uf.targettarget.hp.raidIcon:Show()
      else
        pfUI.uf.targettarget.hp.raidIcon:Hide()
      end

      local color
      if UnitIsPlayer("targettarget") then
        _, class = UnitClass("targettarget")
        color = RAID_CLASS_COLORS[class]
      else
        color = UnitReactionColor[UnitReaction("targettarget", "player")]
      end

      pfUI.uf.targettarget.hp.bar:SetMinMaxValues(0, UnitHealthMax("targettarget"))

      if color then
        local r, g, b = .2, .2, .2
        if pfUI_config.unitframes.dark == "1" then
          pfUI.uf.targettarget.hp.bar:SetStatusBarColor(r, g, b, UnitHealth("targettarget") / UnitHealthMax("targettarget") / 4 + .75)
          if pfUI_config.unitframes.pastel == "1" then
            r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
          else
            r, g, b = color.r, color.g, color.b
          end
        else
          if pfUI_config.unitframes.pastel == "1" then
            r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
          else
            r, g, b = color.r, color.g, color.b
          end
          pfUI.uf.targettarget.hp.bar:SetStatusBarColor(r, g, b, UnitHealth("targettarget") / UnitHealthMax("targettarget") / 4 + .75)
        end

        pfUI.uf.targettarget.hp.text:SetTextColor(r, g, b, 1)
      end
      pfUI.uf.targettarget.hp.text:SetText( UnitName("targettarget"))

      local display, real
      display = pfUI.uf.targettarget.hp.bar:GetValue()
      real = UnitHealth("targettarget")
      diff = abs(real - display)
      if display < real then
        pfUI.uf.targettarget.hp.bar:SetValue(display + ceil(diff / pfUI_config.unitframes.animation_speed))
      elseif display > real then
        pfUI.uf.targettarget.hp.bar:SetValue(display - ceil(diff / pfUI_config.unitframes.animation_speed))
      end

      PowerColor = ManaBarColor[UnitPowerType("targettarget")]
      pfUI.uf.targettarget.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
      pfUI.uf.targettarget.power.bar:SetMinMaxValues(0, UnitManaMax("targettarget"))

      local display, real
      display = pfUI.uf.targettarget.power.bar:GetValue()
      real = UnitMana("targettarget")
      diff = abs(real - display)
      if display < real then
        pfUI.uf.targettarget.power.bar:SetValue(display + ceil(diff / pfUI_config.unitframes.animation_speed))
      elseif display > real then
        pfUI.uf.targettarget.power.bar:SetValue(display - ceil(diff / pfUI_config.unitframes.animation_speed))
      else
        pfUI.uf.targettarget.power.bar:SetValue(real)
      end
    end)

  pfUI.uf.targettarget.hp = CreateFrame("Frame",nil, pfUI.uf.targettarget)
  pfUI.uf.targettarget.hp:SetPoint("TOP", 0, 0)
  pfUI.uf.targettarget.hp:SetWidth(100)
  pfUI.uf.targettarget.hp:SetHeight(17)
  pfUI.utils:CreateBackdrop(pfUI.uf.targettarget.hp, default_border)

  pfUI.uf.targettarget.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.targettarget.hp)
  pfUI.uf.targettarget.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.targettarget.hp.bar:SetAllPoints(pfUI.uf.targettarget.hp)
  pfUI.uf.targettarget.hp.bar:SetMinMaxValues(0, 100)

  pfUI.uf.targettarget.hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.targettarget.hp)
  pfUI.uf.targettarget.hp.raidIcon:SetFrameStrata("MEDIUM")
  pfUI.uf.targettarget.hp.raidIcon:SetParent(pfUI.uf.targettarget.hp.bar)
  pfUI.uf.targettarget.hp.raidIcon:SetWidth(16)
  pfUI.uf.targettarget.hp.raidIcon:SetHeight(16)
  pfUI.uf.targettarget.hp.raidIcon.texture = pfUI.uf.targettarget.hp.raidIcon:CreateTexture(nil,"ARTWORK")
  pfUI.uf.targettarget.hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  pfUI.uf.targettarget.hp.raidIcon.texture:SetAllPoints(pfUI.uf.targettarget.hp.raidIcon)
  pfUI.uf.targettarget.hp.raidIcon:SetPoint("TOP", pfUI.uf.targettarget.hp, "TOP", 0, 6)
  pfUI.uf.targettarget.hp.raidIcon:Hide()

  if pfUI_config.unitframes.portrait == "1" then
    pfUI.uf.targettarget.hp.bar.portrait = CreateFrame("PlayerModel",nil,pfUI.uf.targettarget.hp.bar)
    pfUI.uf.targettarget.hp.bar.portrait:SetAllPoints(pfUI.uf.targettarget.hp.bar)
    pfUI.uf.targettarget.hp.bar.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    pfUI.uf.targettarget.hp.bar.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
    pfUI.uf.targettarget.hp.bar.portrait:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.uf.targettarget.hp.bar.portrait:RegisterEvent("PLAYER_TARGET_CHANGED")

    pfUI.uf.targettarget.hp.bar.portrait:SetScript("OnEvent", function() this.Update() end)
    pfUI.uf.targettarget.hp.bar.portrait:SetScript("OnShow", function() this.Update() end)

    function pfUI.uf.targettarget.hp.bar.portrait.Update()
      pfUI.uf.targettarget.hp.bar.portrait:SetUnit("targettarget")
      pfUI.uf.targettarget.hp.bar.portrait:SetCamera(0)
      pfUI.uf.targettarget.hp.bar.portrait:SetAlpha(0.10)
    end
  end

  pfUI.uf.targettarget.power = CreateFrame("Frame",nil, pfUI.uf.targettarget)
  pfUI.utils:CreateBackdrop(pfUI.uf.targettarget.power, default_border)
  pfUI.uf.targettarget.power:SetPoint("BOTTOM", 0, 0)
  pfUI.uf.targettarget.power:SetWidth(100)
  pfUI.uf.targettarget.power:SetHeight(4)

  pfUI.uf.targettarget.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.targettarget.power)
  pfUI.uf.targettarget.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.targettarget.power.bar:SetAllPoints(pfUI.uf.targettarget.power)
  pfUI.uf.targettarget.power.bar:SetMinMaxValues(0, 100)

  pfUI.uf.targettarget.hp.text = pfUI.uf.targettarget.hp.bar:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.uf.targettarget.hp.text:SetFont(pfUI.font_square, pfUI_config.global.font_size - 2, "OUTLINE")
  pfUI.uf.targettarget.hp.text:ClearAllPoints()
  pfUI.uf.targettarget.hp.text:SetAllPoints(pfUI.uf.targettarget.hp.bar)
  pfUI.uf.targettarget.hp.text:SetPoint("CENTER", 0, 0)
  pfUI.uf.targettarget.hp.text:SetJustifyH("CENTER")
  pfUI.uf.targettarget.hp.text:SetFontObject(GameFontWhite)
  pfUI.uf.targettarget.hp.text:SetText("n/a")
end)
