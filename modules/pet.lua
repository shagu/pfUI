pfUI:RegisterModule("pet", function ()
  pfUI.uf.pet = CreateFrame("Button","pfPet",UIParent)

  pfUI.uf.pet:SetWidth(100)
  pfUI.uf.pet:SetHeight(23)
  pfUI.uf.pet:ClearAllPoints()
  pfUI.uf.pet:SetPoint("TOPLEFT", pfUI.uf.player.hp , "TOPRIGHT", 0, 0)
  pfUI.uf.pet:SetPoint("BOTTOMRIGHT", pfUI.uf.target.hp, "BOTTOMLEFT", 0, 0)

  pfUI.uf.pet:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  pfUI.uf.pet:SetScript("OnClick", function ()
      TargetUnit("pet")
    end)

  pfUI.uf.pet:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.uf.pet:RegisterEvent("UNIT_PET")
  pfUI.uf.pet:RegisterEvent("UNIT_COMBAT");
  pfUI.uf.pet:RegisterEvent("UNIT_AURA");
  pfUI.uf.pet:RegisterEvent("PET_ATTACK_START");
  pfUI.uf.pet:RegisterEvent("PET_ATTACK_STOP");
  pfUI.uf.pet:RegisterEvent("UNIT_HAPPINESS");

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

  pfUI.uf.pet:SetScript("OnEvent", function(arg1)
      if UnitExists("pet") then pfUI.uf.pet:Show() else pfUI.uf.pet:Hide() end
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

      PowerColor = ManaBarColor[UnitPowerType("pet")];
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
      elseif hpDisplay > hpReal then
        pfUI.uf.pet.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      end
    end)

  pfUI.uf.pet.hp = CreateFrame("Frame",nil, pfUI.uf.pet)
  pfUI.uf.pet.hp:SetBackdrop(pfUI.backdrop)
  pfUI.uf.pet.hp:SetWidth(100)
  pfUI.uf.pet.hp:SetHeight(20)
  pfUI.uf.pet.hp:SetPoint("TOP",pfUI.uf.pet,"TOP")
  pfUI.uf.pet.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.pet.hp)
  pfUI.uf.pet.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.pet.hp.bar:ClearAllPoints()
  pfUI.uf.pet.hp.bar:SetPoint("TOPLEFT", pfUI.uf.pet.hp, "TOPLEFT", 3, -3)
  pfUI.uf.pet.hp.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.pet.hp, "BOTTOMRIGHT", -3, 3)
  pfUI.uf.pet.hp.bar:SetMinMaxValues(0, 100)
  pfUI.uf.pet.hp.bar:SetValue(100)

  pfUI.uf.pet.power = CreateFrame("Frame",nil, pfUI.uf.pet)
  pfUI.uf.pet.power:SetBackdrop(pfUI.backdrop)
  pfUI.uf.pet.power:SetWidth(100)
  pfUI.uf.pet.power:SetHeight(8)
  pfUI.uf.pet.power:SetPoint("TOPLEFT",pfUI.uf.pet.hp,"BOTTOMLEFT",0,3)
  pfUI.uf.pet.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.pet.power)
  pfUI.uf.pet.power.bar:ClearAllPoints()
  pfUI.uf.pet.power.bar:SetPoint("TOPLEFT", pfUI.uf.pet.power, "TOPLEFT", 3, -3)
  pfUI.uf.pet.power.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.pet.power, "BOTTOMRIGHT", -3, 3)
  pfUI.uf.pet.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.pet.power.bar:SetBackdropColor(0,0,0,1)
  pfUI.uf.pet.power.bar:SetStatusBarColor(0,0,0)
  pfUI.uf.pet.power.bar:SetMinMaxValues(0, 100)
  pfUI.uf.pet.power.bar:SetValue(100)

  pfUI.uf.pet.hp.text = pfUI.uf.pet.hp.bar:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.uf.pet.hp.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 8, "OUTLINE")
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
    pfUI.uf.pet.buff.buffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
    pfUI.uf.pet.buff.buffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.pet.buff.buffs[i], 2, -2)
    pfUI.uf.pet.buff.buffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.pet.buff.buffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.pet.buff.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.pet.buff.buffs[i].stacks:SetTextColor(1,1,.5)

    pfUI.uf.pet.buff.buffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.pet.buff.buffs[i]:ClearAllPoints()
    pfUI.uf.pet.buff.buffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.pet.hp, "TOPLEFT", (i-8*row)*1 + (i-8*row)*buffsize - buffsize -1 , 1*row + buffsize*row +1)
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
      pfUI.uf.pet.buff.buffs[i]:SetBackdrop(
        { bgFile = texture, tile = false, tileSize = buffsize,
          edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
          insets = { left = 0, right = 0, top = 0, bottom = 0}
        })

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
    pfUI.uf.pet.debuff.debuffs[i] = CreateFrame("Button", "pfUITargetDebuff" .. i, pfUI.uf.pet)
    pfUI.uf.pet.debuff.debuffs[i].stacks = pfUI.uf.pet.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.pet.debuff.debuffs[i])
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.pet.debuff.debuffs[i], 2, -2)
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.pet.debuff.debuffs[i].stacks:SetTextColor(1,1,.5)
    pfUI.uf.pet.debuff.debuffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.pet.debuff.debuffs[i]:ClearAllPoints()

    local row = 0;
    local top = 0;
    local debuffsize = pfUI.uf.pet.hp:GetWidth()/8 - 1
    if i > 8 then row = 1 end
    if pfUI.uf.pet.buff.buffs[1]:IsShown() then top = top + 1 end
    if pfUI.uf.pet.buff.buffs[9]:IsShown() then top = top + 1 end

    pfUI.uf.pet.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.pet.hp, "TOPLEFT",
      (i-8*row)*1 + (i-8*row)*debuffsize - debuffsize -1 ,
      1*row + debuffsize*row +1 + (top*(debuffsize+1))
    )

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
      local row = 0;
      local top = 0;
      if i > 8 then row = 1 end
      if pfUI.uf.pet.buff.buffs[1]:IsShown() then top = top + 1 end
      if pfUI.uf.pet.buff.buffs[9]:IsShown() then top = top + 1 end

      pfUI.uf.pet.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.pet.hp, "TOPLEFT",
        (i-8*row)*1 + (i-8*row)*debuffsize - debuffsize -1 ,
        1*row + debuffsize*row +1 + (top*(debuffsize+1))
      )
      local texture, stacks = UnitDebuff("pet",i)
      pfUI.uf.pet.debuff.debuffs[i]:SetBackdrop(
        { bgFile = texture, tile = false, tileSize = debuffsize,
          edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
          insets = { left = 0, right = 0, top = 0, bottom = 0}
        })

      local _,_,dtype = UnitDebuff("pet", i)
      if dtype == "Magic" then
        pfUI.uf.pet.debuff.debuffs[i]:SetBackdropBorderColor(0,1,1,1)
      elseif dtype == "Poison" then
        pfUI.uf.pet.debuff.debuffs[i]:SetBackdropBorderColor(0,1,0,1)
      elseif dtype == "Curse" then
        pfUI.uf.pet.debuff.debuffs[i]:SetBackdropBorderColor(1,0,1,1)
      else
        pfUI.uf.pet.debuff.debuffs[i]:SetBackdropBorderColor(1,0,0,1)
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
