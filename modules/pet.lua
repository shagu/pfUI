pfUI:RegisterModule("pet", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  pfUI.uf.pet = CreateFrame("Button","pfPet",UIParent)

  pfUI.uf.pet:SetWidth(100)
  pfUI.uf.pet:SetHeight(20 + 2*default_border + pfUI_config.unitframes.pet.pspace)
  pfUI.uf.pet:ClearAllPoints()
  pfUI.uf.pet:SetPoint("BOTTOM", UIParent , "BOTTOM", 0, 163)
  pfUI.utils:UpdateMovable(pfUI.uf.pet)

  pfUI.uf.pet:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  pfUI.uf.pet:SetScript("OnClick", function ()
      TargetUnit("pet")
    end)

  pfUI.uf.pet:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.uf.pet:RegisterEvent("UNIT_PET")
  pfUI.uf.pet:RegisterEvent("UNIT_COMBAT")
  pfUI.uf.pet:RegisterEvent("UNIT_AURA")
  pfUI.uf.pet:RegisterEvent("PET_ATTACK_START")
  pfUI.uf.pet:RegisterEvent("PET_ATTACK_STOP")
  pfUI.uf.pet:RegisterEvent("UNIT_HAPPINESS")

  pfUI.uf.pet:RegisterEvent("UNIT_HEALTH")
  pfUI.uf.pet:RegisterEvent("UNIT_MAXHEALTH")
  pfUI.uf.pet:RegisterEvent("UNIT_MANA")
  pfUI.uf.pet:RegisterEvent("UNIT_MAXMANA")
  pfUI.uf.pet:RegisterEvent("UNIT_RAGE")
  pfUI.uf.pet:RegisterEvent("UNIT_MAXRAGE")
  pfUI.uf.pet:RegisterEvent("UNIT_ENERGY")
  pfUI.uf.pet:RegisterEvent("UNIT_MAXENERGY")
  pfUI.uf.pet:RegisterEvent("UNIT_FOCUS")
  pfUI.uf.pet:RegisterEvent("UNIT_MAXFOCUS")
  pfUI.uf.pet:RegisterEvent("RAID_TARGET_UPDATE")

  pfUI.uf.pet:SetScript("OnEvent", function(arg1)
      if UnitExists("pet") then
        pfUI.uf.pet:Show()
      elseif (pfUI.gitter and pfUI.gitter:IsShown()) then
        pfUI.uf.pet:Show()
        return
      else
        pfUI.uf.pet:Hide()
      end

      local raidIcon = GetRaidTargetIndex("pet")
      if raidIcon then
        SetRaidTargetIconTexture(pfUI.uf.pet.hp.raidIcon.texture, raidIcon)
        pfUI.uf.pet.hp.raidIcon:Show()
      else
        pfUI.uf.pet.hp.raidIcon:Hide()
      end

      local hp, hpmax = UnitHealth("pet"), UnitHealthMax("pet")
      local power, powermax = UnitMana("pet"), UnitManaMax("pet")

      local happiness = GetPetHappiness()
      if happiness == 1 then
        color = { r = 1, g = 0, b = 0 }
      elseif happiness == 2 then
        color = { r = 1, g = 1, b = 0 }
      else
        color = { r = 0, g = 1, b = 0 }
      end
      local r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5

      pfUI.uf.pet.hp.bar:SetMinMaxValues(0, hpmax)
      pfUI.uf.pet.hp.bar:SetStatusBarColor(r, g, b, hp / hpmax / 4 + .75)
      pfUI.uf.pet.hp.text:SetTextColor(r+.3,g+.3,b+.3, 1)
      pfUI.uf.pet.hp.text:SetText(UnitName("pet"))

      pfUI.uf.pet.hpReal = hp
      pfUI.uf.pet.powerReal = power

      PowerColor = ManaBarColor[UnitPowerType("pet")]
      pfUI.uf.pet.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
      pfUI.uf.pet.power.bar:SetMinMaxValues(0, UnitManaMax("pet"))
    end)

  pfUI.uf.pet:SetScript("OnUpdate", function()
      -- animation hp
      local hpDisplay = pfUI.uf.pet.hp.bar:GetValue()
      local hpReal = pfUI.uf.pet.hpReal
      local hpDiff = abs(hpReal - hpDisplay)

      if hpDisplay < hpReal then
        pfUI.uf.pet.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI_config.unitframes.animation_speed))
      elseif hpDisplay > hpReal then
        pfUI.uf.pet.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI_config.unitframes.animation_speed))
      end

      -- animation power
      local powerDisplay = pfUI.uf.pet.power.bar:GetValue()
      local powerReal = pfUI.uf.pet.powerReal
      local powerDiff = abs(powerReal - powerDisplay)

      if powerDisplay < powerReal then
        pfUI.uf.pet.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      elseif powerDisplay > powerReal then
        pfUI.uf.pet.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      end
    end)

  pfUI.uf.pet.hp = CreateFrame("Frame",nil, pfUI.uf.pet)
  pfUI.uf.pet.hp:SetWidth(100)
  pfUI.uf.pet.hp:SetHeight(17)
  pfUI.uf.pet.hp:SetPoint("TOP", 0, 0)
  pfUI.utils:CreateBackdrop(pfUI.uf.pet.hp, default_border)

  pfUI.uf.pet.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.pet.hp)
  pfUI.uf.pet.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.pet.hp.bar:SetAllPoints(pfUI.uf.pet.hp)
  pfUI.uf.pet.hp.bar:SetMinMaxValues(0, 100)

  pfUI.uf.pet.hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.pet.hp)
  pfUI.uf.pet.hp.raidIcon:SetFrameStrata("MEDIUM")
  pfUI.uf.pet.hp.raidIcon:SetParent(pfUI.uf.pet.hp.bar)
  pfUI.uf.pet.hp.raidIcon:SetWidth(16)
  pfUI.uf.pet.hp.raidIcon:SetHeight(16)
  pfUI.uf.pet.hp.raidIcon.texture = pfUI.uf.pet.hp.raidIcon:CreateTexture(nil,"ARTWORK")
  pfUI.uf.pet.hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  pfUI.uf.pet.hp.raidIcon.texture:SetAllPoints(pfUI.uf.pet.hp.raidIcon)
  pfUI.uf.pet.hp.raidIcon:SetPoint("TOP", pfUI.uf.pet.hp, "TOP", 0, 6)
  pfUI.uf.pet.hp.raidIcon:Hide()

  pfUI.uf.pet.power = CreateFrame("Frame",nil, pfUI.uf.pet)
  pfUI.uf.pet.power:SetPoint("BOTTOM", 0, 0)
  pfUI.uf.pet.power:SetWidth(100)
  pfUI.uf.pet.power:SetHeight(3)
  pfUI.utils:CreateBackdrop(pfUI.uf.pet.power, default_border)

  pfUI.uf.pet.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.pet.power)
  pfUI.uf.pet.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.pet.power.bar:SetAllPoints(pfUI.uf.pet.power)
  pfUI.uf.pet.power.bar:SetMinMaxValues(0, 100)

  pfUI.uf.pet.hp.text = pfUI.uf.pet.hp.bar:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.uf.pet.hp.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size - 2, "OUTLINE")
  pfUI.uf.pet.hp.text:ClearAllPoints()
  pfUI.uf.pet.hp.text:SetAllPoints(pfUI.uf.pet.hp.bar)
  pfUI.uf.pet.hp.text:SetPoint("CENTER", 0, 0)
  pfUI.uf.pet.hp.text:SetJustifyH("CENTER")
  pfUI.uf.pet.hp.text:SetFontObject(GameFontWhite)
  pfUI.uf.pet.hp.text:SetText("n/a")

  pfUI.uf.pet.buff = CreateFrame("Frame", nil)
  pfUI.uf.pet.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.uf.pet.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.uf.pet.buff:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.uf.pet.buff:RegisterEvent("UNIT_AURA")
  pfUI.uf.pet.buff:SetScript("OnEvent", function()
      pfUI.uf.pet.buff.RefreshBuffs()
    end)

  pfUI.uf.pet.buff.buffs = {}
  for i=1, 16 do
    local id = i
    local row = 0
    if i <= 8 then row = 0 else row = 1 end
    local buffsize = pfUI.uf.pet.hp:GetWidth()/8 - 1

    pfUI.uf.pet.buff.buffs[i] = CreateFrame("Button", "pfUITargetBuff" .. i, pfUI.uf.pet)
    pfUI.uf.pet.buff.buffs[i].stacks = pfUI.uf.pet.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.pet.buff.buffs[i])
    pfUI.uf.pet.buff.buffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.pet.buff.buffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.pet.buff.buffs[i], 2, -2)
    pfUI.uf.pet.buff.buffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.pet.buff.buffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.pet.buff.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.pet.buff.buffs[i].stacks:SetTextColor(1,1,.5)

    pfUI.uf.pet.buff.buffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.pet.buff.buffs[i]:ClearAllPoints()
    pfUI.uf.pet.buff.buffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.pet.hp, "TOPLEFT",
    (i-1-8*row)*((2*default_border) + buffsize + 1),
    (row)*((2*default_border) + buffsize + 1) + 2*default_border + 1)
    pfUI.uf.pet.buff.buffs[i]:SetWidth(buffsize)
    pfUI.uf.pet.buff.buffs[i]:SetHeight(buffsize)
    pfUI.uf.pet.buff.buffs[i]:SetNormalTexture(nil)
    pfUI.uf.pet.buff.buffs[i]:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitBuff("pet", id)
      end)

    pfUI.uf.pet.buff.buffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
  end

  function pfUI.uf.pet.buff.RefreshBuffs()
    local buffsize = pfUI.uf.pet.hp:GetWidth()/8 - 1
    for i=1, 16 do
      local texture, stacks = UnitBuff("pet",i)
      pfUI.utils:CreateBackdrop(pfUI.uf.pet.buff.buffs[i], default_border)
      pfUI.uf.pet.buff.buffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({pfUI.uf.pet.buff.buffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      if texture then
        pfUI.uf.pet.buff.buffs[i]:Show()
        if stacks > 1 then
          pfUI.uf.pet.buff.buffs[i].stacks:SetText(stacks)
        else
          pfUI.uf.pet.buff.buffs[i].stacks:SetText("")
        end
      else
        pfUI.uf.pet.buff.buffs[i]:Hide()
      end
    end
  end

  pfUI.uf.pet.debuff = CreateFrame("Frame", nil)
  pfUI.uf.pet.debuff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.uf.pet.debuff:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.uf.pet.debuff:RegisterEvent("UNIT_AURA")
  pfUI.uf.pet.debuff:SetScript("OnEvent", function()
      pfUI.uf.pet.debuff.RefreshBuffs()
    end)

  pfUI.uf.pet.debuff.debuffs = {}
  for i=1, 16 do
    local id = i
    local debuffsize = pfUI.uf.pet.hp:GetWidth()/8 - 1

    pfUI.uf.pet.debuff.debuffs[i] = CreateFrame("Button", "pfUITargetDebuff" .. i, pfUI.uf.pet)
    pfUI.uf.pet.debuff.debuffs[i].stacks = pfUI.uf.pet.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.pet.debuff.debuffs[i])
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.pet.debuff.debuffs[i], 2, -2)
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetTextColor(1,1,.5)
    pfUI.uf.pet.debuff.debuffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.pet.debuff.debuffs[i]:ClearAllPoints()

    pfUI.uf.pet.debuff.debuffs[i]:SetWidth(debuffsize)
    pfUI.uf.pet.debuff.debuffs[i]:SetHeight(debuffsize)
    pfUI.uf.pet.debuff.debuffs[i]:SetNormalTexture(nil)
    pfUI.uf.pet.debuff.debuffs[i]:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitDebuff("pet", id)
      end)
    pfUI.uf.pet.debuff.debuffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    pfUI.uf.pet.debuff.debuffs[i]:SetScript("OnClick", function()
        CancelPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
      end)
  end

  function pfUI.uf.pet.debuff.RefreshBuffs()
    local debuffsize = pfUI.uf.pet.hp:GetWidth()/8 - 1
    for i=1, 16 do
      local row = 0
      local top = 0
      if i > 8 then row = 1 end
      if pfUI.uf.pet.buff.buffs[1]:IsShown() then top = top + 1 end
      if pfUI.uf.pet.buff.buffs[9]:IsShown() then top = top + 1 end
      local buffsize = pfUI.uf.pet.hp:GetWidth()/8 - 1

      pfUI.uf.pet.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.pet.hp, "TOPLEFT",
      (i-1-row)*((2*default_border) + buffsize + 1),
      (top)*((2*default_border) + buffsize + 1) +
      (row)*((2*default_border) + buffsize + 1) + (2*default_border + 1))

      local texture, stacks = UnitDebuff("pet",i)
      pfUI.utils:CreateBackdrop(pfUI.uf.pet.debuff.debuffs[i], default_border)
      pfUI.uf.pet.debuff.debuffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({pfUI.uf.pet.debuff.debuffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      local _,_,dtype = UnitDebuff("pet", i)
      if dtype == "Magic" then
        pfUI.uf.pet.debuff.debuffs[i].backdrop:SetBackdropBorderColor(0,1,1,1)
      elseif dtype == "Poison" then
        pfUI.uf.pet.debuff.debuffs[i].backdrop:SetBackdropBorderColor(0,1,0,1)
      elseif dtype == "Curse" then
        pfUI.uf.pet.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,0,1,1)
      else
        pfUI.uf.pet.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,0,0,1)
      end

      if texture then
        pfUI.uf.pet.debuff.debuffs[i]:Show()
        if stacks > 1 then
          pfUI.uf.pet.debuff.debuffs[i].stacks:SetText(stacks)
        else
          pfUI.uf.pet.debuff.debuffs[i].stacks:SetText("")
        end
      else
        pfUI.uf.pet.debuff.debuffs[i]:Hide()
      end
    end
  end
end)
