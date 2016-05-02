PlayerFrame:Hide()
PlayerFrame:UnregisterAllEvents()

pfUI.uf.player = CreateFrame("Button",nil,UIParent)
pfUI.uf.player:SetWidth(pfUI.config.unitframes.width)
pfUI.uf.player:SetHeight(pfUI.config.unitframes.height+pfUI.config.unitframes.pheight)
pfUI.uf.player:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -75, 125)
pfUI.uf.player:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
pfUI.uf.player:SetScript("OnClick", function ()
    if arg1 == "RightButton" then
      ToggleDropDownMenu(1, nil, pfUI.uf.player.dropdown,"cursor")
      if UnitIsPartyLeader("player") then
        UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
      end
    else
      TargetUnit("player")
    end
  end)

pfUI.uf.player.dropdown = getglobal("PlayerFrameDropDown")
pfUI.uf.player.dropdowni = function()
  -- add reset button when alone
  if not (UnitInRaid("player") or GetNumPartyMembers() > 0) then
    UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
  end
  UnitPopup_ShowMenu(pfUI.uf.player.dropdown, "SELF", "player")
end
UIDropDownMenu_Initialize(pfUI.uf.player.dropdown, pfUI.uf.player.dropdowni, "MENU")

pfUI.uf.player:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.uf.player:RegisterEvent("UNIT_HEALTH")
pfUI.uf.player:RegisterEvent("UNIT_MAXHEALTH")
pfUI.uf.player:RegisterEvent("UNIT_DISPLAYPOWER")
pfUI.uf.player:RegisterEvent("UNIT_MANA")
pfUI.uf.player:RegisterEvent("UNIT_MAXMANA")
pfUI.uf.player:RegisterEvent("UNIT_RAGE")
pfUI.uf.player:RegisterEvent("UNIT_MAXRAGE")
pfUI.uf.player:RegisterEvent("UNIT_ENERGY")
pfUI.uf.player:RegisterEvent("UNIT_MAXENERGY")

pfUI.uf.player:SetScript("OnEvent", function()
    if event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" then
      pfUI.uf.player.power.bar:SetValue(0)
    end

    local hp, hpmax = UnitHealth("player"), UnitHealthMax("player")
    local power, powermax = UnitMana("player"), UnitManaMax("player")

    local cr, cg, cb = pfUI.cache.class_r, pfUI.cache.class_g, pfUI.cache.class_b
    local perc = hp / hpmax

    pfUI.uf.player.hp.bar:SetMinMaxValues(0, hpmax)
    pfUI.uf.player.hp.bar:SetStatusBarColor(cr, cg, cb, hp / hpmax / 4 + .75)

    local r1, g1, b1, r2, g2, b2
    if perc <= 0.5 then
      perc = perc * 2; r1, g1, b1 = .9, .5, .5; r2, g2, b2 = .9, .9, .5
    else
      perc = perc * 2 - 1; r1, g1, b1 = .9, .9, .5; r2, g2, b2 = .5, .9, .5
    end
    local hr, hg, hb = r1 + (r2 - r1)*perc, g1 + (g2 - g1)*perc, b1 + (b2 - b1)*perc
    pfUI.uf.player.hpText:SetTextColor(hr, hg, hb,1)

    if hp ~= hpmax then
      pfUI.uf.player.hpText:SetText(hp .. " - " .. ceil(hp / hpmax * 100) .. "%")
    else
      pfUI.uf.player.hpText:SetText(hp)
    end

    PowerColor = ManaBarColor[UnitPowerType("player")];
    pfUI.uf.player.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
    pfUI.uf.player.power.bar:SetMinMaxValues(0, UnitManaMax("player"))

    pfUI.uf.player.powerText:SetTextColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5,1)

    pfUI.uf.player.powerText:SetText( UnitMana("player") )

    pfUI.uf.player.hpReal = hp
    pfUI.uf.player.powerReal = power
  end)

pfUI.uf.player:SetScript("OnUpdate", function()
    local hpDisplay = pfUI.uf.player.hp.bar:GetValue()
    local hpReal = pfUI.uf.player.hpReal
    local hpDiff = abs(hpReal - hpDisplay)

    if hpDisplay < hpReal then
      pfUI.uf.player.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI.config.unitframes.animation_speed))
    elseif hpDisplay > hpReal then
      pfUI.uf.player.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI.config.unitframes.animation_speed))
    end

    local powerDisplay = pfUI.uf.player.power.bar:GetValue()
    local powerReal = pfUI.uf.player.powerReal
    local powerDiff = abs(powerReal - powerDisplay)

    if powerDisplay < powerReal then
      pfUI.uf.player.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI.config.unitframes.animation_speed))
    elseif powerDisplay > powerReal then
      pfUI.uf.player.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI.config.unitframes.animation_speed))
    end
  end)

pfUI.uf.player.hp = CreateFrame("Frame",nil, pfUI.uf.player)
pfUI.uf.player.hp:SetBackdrop(pfUI.backdrop)
pfUI.uf.player.hp:SetHeight(pfUI.config.unitframes.height)
pfUI.uf.player.hp:SetPoint("TOPRIGHT",pfUI.uf.player,"TOPRIGHT")
pfUI.uf.player.hp:SetPoint("TOPLEFT",pfUI.uf.player,"TOPLEFT")

pfUI.uf.player.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.player.hp)
pfUI.uf.player.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

pfUI.uf.player.hp.bar:ClearAllPoints()
pfUI.uf.player.hp.bar:SetPoint("TOPLEFT", pfUI.uf.player.hp, "TOPLEFT", 3, -3)
pfUI.uf.player.hp.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.player.hp, "BOTTOMRIGHT", -3, 3)

pfUI.uf.player.hp.bar:SetMinMaxValues(0, 100)

pfUI.uf.player.hp.bar.portrait = CreateFrame("PlayerModel",nil,pfUI.uf.player.hp.bar)
pfUI.uf.player.hp.bar.portrait:SetAllPoints(pfUI.uf.player.hp.bar)
pfUI.uf.player.hp.bar.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
pfUI.uf.player.hp.bar.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
pfUI.uf.player.hp.bar.portrait:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.uf.player.hp.bar.portrait:SetScript("OnEvent", function() this.update() end)
pfUI.uf.player.hp.bar.portrait:SetScript("OnShow", function() this.update() end)

pfUI.uf.player.hp.bar.portrait.update = function ()
  pfUI.uf.player.hp.bar.portrait:SetUnit("player");
  pfUI.uf.player.hp.bar.portrait:SetCamera(0)
  pfUI.uf.player.hp.bar.portrait:SetAlpha(0.10)
end

pfUI.uf.player.power = CreateFrame("Frame",nil, pfUI.uf.player)
pfUI.uf.player.power:SetBackdrop(pfUI.backdrop)
pfUI.uf.player.power:SetPoint("TOPLEFT",pfUI.uf.player.hp,"BOTTOMLEFT",0,3)
pfUI.uf.player.power:SetPoint("BOTTOMRIGHT",pfUI.uf.player,"BOTTOMRIGHT",0,0)

pfUI.uf.player.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.player.power)
pfUI.uf.player.power.bar:ClearAllPoints()
pfUI.uf.player.power.bar:SetPoint("TOPLEFT", pfUI.uf.player.power, "TOPLEFT", 3, -3)
pfUI.uf.player.power.bar:SetPoint("BOTTOMRIGHT", pfUI.uf.player.power, "BOTTOMRIGHT", -3, 3)

pfUI.uf.player.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

pfUI.uf.player.power.bar:SetBackdropColor(0,0,0,1)
pfUI.uf.player.power.bar:SetStatusBarColor(0,1,0)
pfUI.uf.player.power.bar:SetMinMaxValues(0, 100)

pfUI.uf.player.hpText = pfUI.uf.player:CreateFontString("Status", "HIGH", "GameFontNormal")
pfUI.uf.player.hpText:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
pfUI.uf.player.hpText:ClearAllPoints()
pfUI.uf.player.hpText:SetJustifyH("RIGHT")
pfUI.uf.player.hpText:SetFontObject(GameFontWhite)
pfUI.uf.player.hpText:SetText("5000")

pfUI.uf.player.powerText = pfUI.uf.player:CreateFontString("Status", "HIGH", "GameFontNormal")
pfUI.uf.player.powerText:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
pfUI.uf.player.powerText:ClearAllPoints()
pfUI.uf.player.powerText:SetJustifyH("LEFT")
pfUI.uf.player.powerText:SetFontObject(GameFontWhite)
pfUI.uf.player.powerText:SetText("5000")

pfUI.uf.player.hpText:SetParent(pfUI.uf.player.hp.bar)
pfUI.uf.player.hpText:SetPoint("RIGHT",pfUI.uf.player.hp.bar, "RIGHT", -10, 0)
pfUI.uf.player.powerText:SetParent(pfUI.uf.player.hp.bar)
pfUI.uf.player.powerText:SetPoint("LEFT",pfUI.uf.player.hp.bar, "LEFT", 10, 0)

pfUI.uf.player.buff = CreateFrame("Frame", nil)
pfUI.uf.player.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
pfUI.uf.player.buff:SetScript("OnEvent", function()
    pfUI.uf.player.buff.refreshBuffs()
  end)

pfUI.uf.player.buff.buffs = {}
for i=1, 16 do
  local id = i
  local row = 0
  if i <= 8 then row = 0 else row = 1 end

  pfUI.uf.player.buff.buffs[i] = CreateFrame("Button", "pfUIPlayerBuff" .. i, pfUI.uf.player)
  pfUI.uf.player.buff.buffs[i].stacks = pfUI.uf.player.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.buff.buffs[i])
  pfUI.uf.player.buff.buffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
  pfUI.uf.player.buff.buffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.player.buff.buffs[i], 2, -2)
  pfUI.uf.player.buff.buffs[i].stacks:SetJustifyH("LEFT")
  pfUI.uf.player.buff.buffs[i].stacks:SetShadowColor(0, 0, 0)
  pfUI.uf.player.buff.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
  pfUI.uf.player.buff.buffs[i].stacks:SetTextColor(1,1,.5)
  pfUI.uf.player.buff.buffs[i].cd = pfUI.uf.player.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.buff.buffs[i])
  pfUI.uf.player.buff.buffs[i].cd:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
  pfUI.uf.player.buff.buffs[i].cd:SetPoint("CENTER", pfUI.uf.player.buff.buffs[i], 0, 0)
  pfUI.uf.player.buff.buffs[i].cd:SetJustifyH("LEFT")
  pfUI.uf.player.buff.buffs[i].cd:SetShadowColor(0, 0, 0)
  pfUI.uf.player.buff.buffs[i].cd:SetShadowOffset(0.8, -0.8)
  pfUI.uf.player.buff.buffs[i].cd:SetTextColor(1,1,1)

  pfUI.uf.player.buff.buffs[i]:RegisterForClicks("RightButtonUp")
  pfUI.uf.player.buff.buffs[i]:ClearAllPoints()
  pfUI.uf.player.buff.buffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.player, "TOPLEFT", (i-8*row)*1 + (i-8*row)*pfUI.config.unitframes.buff_size - pfUI.config.unitframes.buff_size -1 , 1*row + pfUI.config.unitframes.buff_size*row +1)
  pfUI.uf.player.buff.buffs[i]:SetWidth(pfUI.config.unitframes.buff_size)
  pfUI.uf.player.buff.buffs[i]:SetHeight(pfUI.config.unitframes.buff_size)
  pfUI.uf.player.buff.buffs[i]:SetNormalTexture(nil)
  pfUI.uf.player.buff.buffs[i]:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
      GameTooltip:SetPlayerBuff(GetPlayerBuff(id-1,"HELPFUL"))
    end)

  pfUI.uf.player.buff.buffs[i]:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

  pfUI.uf.player.buff.buffs[i]:SetScript("OnClick", function()
      CancelPlayerBuff(GetPlayerBuff(id-1,"HELPFUL"))
    end)
  pfUI.uf.player.buff.buffs[i]:SetScript("OnUpdate", function()
      for i=1, 16 do
        local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HELPFUL"))
        if timeleft ~= nil and timeleft < 99 and timeleft ~= 0 then
          pfUI.uf.player.buff.buffs[i].cd:SetText(ceil(timeleft))
        else
          pfUI.uf.player.buff.buffs[i].cd:SetText("")
        end
      end
    end)

end

pfUI.uf.player.buff.refreshBuffs = function ()
  for i=1, 16 do
    local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
    pfUI.uf.player.buff.buffs[i]:SetBackdrop(
      { bgFile = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL")), tile = false, tileSize = pfUI.config.unitframes.buff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })

    if GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL")) then
      pfUI.uf.player.buff.buffs[i]:Show()
      local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
      if stacks > 1 then
        pfUI.uf.player.buff.buffs[i].stacks:SetText(stacks)
      else
        pfUI.uf.player.buff.buffs[i].stacks:SetText("")
      end
    else
      pfUI.uf.player.buff.buffs[i]:Hide()
    end

  end
end

pfUI.uf.player.debuff = CreateFrame("Frame", nil)
pfUI.uf.player.debuff:RegisterEvent("PLAYER_AURAS_CHANGED")
pfUI.uf.player.debuff:SetScript("OnEvent", function()
    pfUI.uf.player.debuff.refreshBuffs()
  end)

pfUI.uf.player.debuff.debuffs = {}
for i=1, 16 do
  local id = i
  pfUI.uf.player.debuff.debuffs[i] = CreateFrame("Button", "pfUIPlayerDebuff" .. i, pfUI.uf.player)
  pfUI.uf.player.debuff.debuffs[i].stacks = pfUI.uf.player.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.debuff.debuffs[i])
  pfUI.uf.player.debuff.debuffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
  pfUI.uf.player.debuff.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.player.debuff.debuffs[i], 2, -2)
  pfUI.uf.player.debuff.debuffs[i].stacks:SetJustifyH("LEFT")
  pfUI.uf.player.debuff.debuffs[i].stacks:SetShadowColor(0, 0, 0)
  pfUI.uf.player.debuff.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
  pfUI.uf.player.debuff.debuffs[i].stacks:SetTextColor(1,1,.5)
  pfUI.uf.player.debuff.debuffs[i].cd = pfUI.uf.player.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.debuff.debuffs[i])
  pfUI.uf.player.debuff.debuffs[i].cd:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", 10, "OUTLINE")
  pfUI.uf.player.debuff.debuffs[i].cd:SetPoint("CENTER", pfUI.uf.player.debuff.debuffs[i], 0, 0)
  pfUI.uf.player.debuff.debuffs[i].cd:SetJustifyH("LEFT")
  pfUI.uf.player.debuff.debuffs[i].cd:SetShadowColor(0, 0, 0)
  pfUI.uf.player.debuff.debuffs[i].cd:SetShadowOffset(0.8, -0.8)
  pfUI.uf.player.debuff.debuffs[i].cd:SetTextColor(1,1,1)

  pfUI.uf.player.debuff.debuffs[i]:RegisterForClicks("RightButtonUp")
  pfUI.uf.player.debuff.debuffs[i]:ClearAllPoints()

  local row = 0;
  local top = 0;
  if i > 8 then row = 1 end
  if pfUI.uf.player.buff.buffs[1]:IsShown() then top = top + 1 end
  if pfUI.uf.player.buff.buffs[9]:IsShown() then top = top + 1 end

  pfUI.uf.player.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.player, "TOPLEFT", (i-8*row)*1 + (i-8*row)*pfUI.config.unitframes.debuff_size - pfUI.config.unitframes.debuff_size -1 , 1*row + pfUI.config.unitframes.debuff_size*row +1)

  pfUI.uf.player.debuff.debuffs[i]:SetWidth(pfUI.config.unitframes.debuff_size)
  pfUI.uf.player.debuff.debuffs[i]:SetHeight(pfUI.config.unitframes.debuff_size)
  pfUI.uf.player.debuff.debuffs[i]:SetNormalTexture(nil)
  pfUI.uf.player.debuff.debuffs[i]:SetScript("OnEnter", function()
      GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
      GameTooltip:SetPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
    end)

  pfUI.uf.player.debuff.debuffs[i]:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)

  pfUI.uf.player.debuff.debuffs[i]:SetScript("OnClick", function()
      CancelPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
    end)
  pfUI.uf.player.debuff.debuffs[i]:SetScript("OnUpdate", function()
      for i=1, 16 do
        local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(i-1,"HARMFUL"))
        if timeleft ~= nil and timeleft < 99 and timeleft ~= 0 then
          pfUI.uf.player.debuff.debuffs[i].cd:SetText(ceil(timeleft))
        else
          pfUI.uf.player.debuff.debuffs[i].cd:SetText("")
        end
      end
    end)

end

pfUI.uf.player.debuff.refreshBuffs = function ()
  for i=1, 16 do
    local row = 0;
    local top = 0;
    if i > 8 then row = 1 end
    if pfUI.uf.player.buff.buffs[1]:IsShown() then top = top + 1 end
    if pfUI.uf.player.buff.buffs[9]:IsShown() then top = top + 1 end

    pfUI.uf.player.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.player, "TOPLEFT",
      (i-8*row)*1 + (i-8*row)*pfUI.config.unitframes.debuff_size - pfUI.config.unitframes.debuff_size -1 ,
      1*row + pfUI.config.unitframes.debuff_size*row +1 + (top*(pfUI.config.unitframes.debuff_size+1))
    )

    local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HARMFUL"))
    pfUI.uf.player.debuff.debuffs[i]:SetBackdrop(
      { bgFile = GetPlayerBuffTexture(GetPlayerBuff(i-1,"HARMFUL")), tile = false, tileSize = pfUI.config.unitframes.debuff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })

    local _,_,dtype = UnitDebuff("player", i)
    if dtype == "Magic" then
      pfUI.uf.player.debuff.debuffs[i]:SetBackdropBorderColor(0,1,1,1)
    elseif dtype == "Poison" then
      pfUI.uf.player.debuff.debuffs[i]:SetBackdropBorderColor(0,1,0,1)
    elseif dtype == "Curse" then
      pfUI.uf.player.debuff.debuffs[i]:SetBackdropBorderColor(1,0,1,1)
    elseif dtype == "Disease" then
      pfUI.uf.player.debuff.debuffs[i]:SetBackdropBorderColor(1,1,0,1)

    else
      pfUI.uf.player.debuff.debuffs[i]:SetBackdropBorderColor(1,0,0,1)
    end

    if GetPlayerBuffTexture(GetPlayerBuff(i-1,"HARMFUL")) then
      pfUI.uf.player.debuff.debuffs[i]:Show()
      local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HARMFUL"))
      if stacks > 1 then
        pfUI.uf.player.debuff.debuffs[i].stacks:SetText(stacks)
      else
        pfUI.uf.player.debuff.debuffs[i].stacks:SetText("")
      end
    else
      pfUI.uf.player.debuff.debuffs[i]:Hide()
    end
  end
end
