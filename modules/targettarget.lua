pfUI:RegisterModule("targettarget", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.ttarget.pspace

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
  pfUI.uf.targettarget:SetHeight(20 + 2*default_border + spacing)
  pfUI.uf.targettarget:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 125)
  UpdateMovable(pfUI.uf.targettarget)

  pfUI.uf.targettarget:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')
  pfUI.uf.targettarget:SetScript("OnEnter", function()
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    GameTooltip:SetUnit(this.label .. this.id)
    GameTooltip:Show()
  end)

  pfUI.uf.targettarget:SetScript("OnLeave", function()
    GameTooltip:FadeOut()
  end)

  pfUI.uf.targettarget:SetScript("OnClick", function ()
    pfUI.uf:ClickAction(arg1)
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
      local r, g, b = .2, .2, .2
      if color then
        if C.unitframes.custom == "1" then
          local cr, cg, cb, ca = strsplit(",", C.unitframes.customcolor)
          cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
          pfUI.uf.targettarget.hp.bar:SetStatusBarColor(cr, cg, cb, UnitHealth("targettarget") / UnitHealthMax("targettarget") / 4 + .75)
          if C.unitframes.pastel == "1" then
            r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
          else
            r, g, b = color.r, color.g, color.b
          end
        else
          if C.unitframes.pastel == "1" then
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
        pfUI.uf.targettarget.hp.bar:SetValue(display + ceil(diff / C.unitframes.animation_speed))
      elseif display > real then
        pfUI.uf.targettarget.hp.bar:SetValue(display - ceil(diff / C.unitframes.animation_speed))
      else
        pfUI.uf.targettarget.hp.bar:SetValue(real)
      end

      PowerColor = ManaBarColor[UnitPowerType("targettarget")]
      pfUI.uf.targettarget.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
      pfUI.uf.targettarget.power.bar:SetMinMaxValues(0, UnitManaMax("targettarget"))

      local display, real
      display = pfUI.uf.targettarget.power.bar:GetValue()
      real = UnitMana("targettarget")
      diff = abs(real - display)
      if display < real then
        pfUI.uf.targettarget.power.bar:SetValue(display + ceil(diff / C.unitframes.animation_speed))
      elseif display > real then
        pfUI.uf.targettarget.power.bar:SetValue(display - ceil(diff / C.unitframes.animation_speed))
      else
        pfUI.uf.targettarget.power.bar:SetValue(real)
      end
    end)

  pfUI.uf.targettarget.hp = CreateFrame("Frame",nil, pfUI.uf.targettarget)
  pfUI.uf.targettarget.hp:SetPoint("TOP", 0, 0)
  pfUI.uf.targettarget.hp:SetWidth(100)
  pfUI.uf.targettarget.hp:SetHeight(16)
  CreateBackdrop(pfUI.uf.targettarget.hp, default_border)

  pfUI.uf.targettarget.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.targettarget.hp)
  pfUI.uf.targettarget.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.targettarget.hp.bar:SetAllPoints(pfUI.uf.targettarget.hp)
  pfUI.uf.targettarget.hp.bar:SetMinMaxValues(0, 100)

  if C.unitframes.custombg == "1" then
    local cr, cg, cb, ca = strsplit(",", C.unitframes.custombgcolor)
    cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
    pfUI.uf.targettarget.hp.bar.texture = pfUI.uf.targettarget.hp.bar:CreateTexture(nil,"BACKGROUND")
    pfUI.uf.targettarget.hp.bar.texture:SetTexture(cr,cg,cb,ca)
    pfUI.uf.targettarget.hp.bar.texture:SetAllPoints(pfUI.uf.targettarget.hp.bar)
  end

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

  pfUI.uf.targettarget.power = CreateFrame("Frame",nil, pfUI.uf.targettarget)
  CreateBackdrop(pfUI.uf.targettarget.power, default_border)
  pfUI.uf.targettarget.power:SetPoint("BOTTOM", 0, 0)
  pfUI.uf.targettarget.power:SetWidth(100)
  pfUI.uf.targettarget.power:SetHeight(4)

  pfUI.uf.targettarget.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.targettarget.power)
  pfUI.uf.targettarget.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.targettarget.power.bar:SetAllPoints(pfUI.uf.targettarget.power)
  pfUI.uf.targettarget.power.bar:SetMinMaxValues(0, 100)

  pfUI.uf:CreatePortrait(pfUI.uf.targettarget, C.unitframes.ttarget.portrait, spacing)

  pfUI.uf.targettarget.hp.text = pfUI.uf.targettarget.hp.bar:CreateFontString("Status", "OVERLAY", "GameFontNormal")
  pfUI.uf.targettarget.hp.text:SetFont(pfUI.font_square, C.global.font_size - 2, "OUTLINE")
  pfUI.uf.targettarget.hp.text:ClearAllPoints()
  pfUI.uf.targettarget.hp.text:SetAllPoints(pfUI.uf.targettarget.hp.bar)
  pfUI.uf.targettarget.hp.text:SetPoint("CENTER", 0, 0)
  pfUI.uf.targettarget.hp.text:SetJustifyH("CENTER")
  pfUI.uf.targettarget.hp.text:SetFontObject(GameFontWhite)
  pfUI.uf.targettarget.hp.text:SetText("n/a")
end)
