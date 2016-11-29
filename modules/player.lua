pfUI:RegisterModule("player", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

  PlayerFrame:Hide()
  PlayerFrame:UnregisterAllEvents()

  pfUI.uf.player = CreateFrame("Button","pfPlayer",UIParent)
  pfUI.uf.player:SetWidth(pfUI_config.unitframes.player.width)
  pfUI.uf.player:SetHeight(pfUI_config.unitframes.player.height + pfUI_config.unitframes.player.pheight + 2*default_border + pfUI_config.unitframes.player.pspace)
  pfUI.uf.player:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -75, 125)
  pfUI.utils:UpdateMovable(pfUI.uf.player)
  pfUI.uf.player:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  pfUI.uf.player:SetScript("OnClick", function ()
      if arg1 == "RightButton" then
        ToggleDropDownMenu(1, nil, pfUI.uf.player.Dropdown,"cursor")
        if UnitIsPartyLeader("player") then
          UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
        end
      else
        TargetUnit("player")
      end
    end)

  pfUI.uf.player.Dropdown = getglobal("PlayerFrameDropDown")
  function pfUI.uf.player.Dropdowni()
    -- add reset button when alone
    if not (UnitInRaid("player") or GetNumPartyMembers() > 0) then
      UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
    end
    UnitPopup_ShowMenu(pfUI.uf.player.Dropdown, "SELF", "player")
  end
  UIDropDownMenu_Initialize(pfUI.uf.player.Dropdown, pfUI.uf.player.Dropdowni, "MENU")

  pfUI.uf.player:RegisterEvent("UPDATE_FACTION")
  pfUI.uf.player:RegisterEvent("RAID_TARGET_UPDATE")
  pfUI.uf.player:RegisterEvent("PARTY_LEADER_CHANGED")
  pfUI.uf.player:RegisterEvent("PARTY_MEMBERS_CHANGED")
  pfUI.uf.player:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

  pfUI.uf.player:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.uf.player:RegisterEvent("UNIT_DISPLAYPOWER")

  pfUI.uf.player:RegisterEvent("UNIT_HEALTH")
  pfUI.uf.player:RegisterEvent("UNIT_MAXHEALTH")
  pfUI.uf.player:RegisterEvent("UNIT_MANA")
  pfUI.uf.player:RegisterEvent("UNIT_MAXMANA")
  pfUI.uf.player:RegisterEvent("UNIT_RAGE")
  pfUI.uf.player:RegisterEvent("UNIT_MAXRAGE")
  pfUI.uf.player:RegisterEvent("UNIT_ENERGY")
  pfUI.uf.player:RegisterEvent("UNIT_MAXENERGY")

  pfUI.uf.player:SetScript("OnEvent", function()
      if event == "UPDATE_FACTION" then
        if pfUI_config.unitframes.player.showPVP == "1" and UnitIsPVP("player") then
          if pfUI.uf.player.pvpicon == nil then
            pfUI.uf.player.pvpicon = CreateFrame("Frame", "pfPvPIcon", UIParent)
            pfUI.uf.player.pvpicon:SetFrameStrata("HIGH")
            pfUI.uf.player.pvpicon.texture = pfUI.uf.player.pvpicon:CreateTexture(nil,"DIALOG")
            pfUI.uf.player.pvpicon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\pvp")
            pfUI.uf.player.pvpicon.texture:SetAllPoints(pfUI.uf.player.pvpicon)
          end

          if pfUI_config.unitframes.player.showPVPMinimap == "1" then
            pfUI.uf.player.pvpicon:SetWidth(16)
            pfUI.uf.player.pvpicon:SetHeight(16)
            pfUI.uf.player.pvpicon:SetParent(pfUI.minimap)
            pfUI.uf.player.pvpicon:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", -5, 5)
          else
            pfUI.uf.player.pvpicon:SetWidth(10)
            pfUI.uf.player.pvpicon:SetHeight(10)
            pfUI.uf.player.pvpicon:SetParent(pfUI.uf.player.hp.bar)
            pfUI.uf.player.pvpicon:SetPoint("CENTER", pfUI.uf.player, "BOTTOMLEFT", 0,0)
          end
          pfUI.uf.player.pvpicon:Show()
        elseif pfUI.uf.player.pvpicon then
          pfUI.uf.player.pvpicon:Hide()
        end
        return
      end

      if event == "RAID_TARGET_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local raidIcon = GetRaidTargetIndex("player")
        if raidIcon then
          SetRaidTargetIconTexture(pfUI.uf.player.hp.raidIcon.texture, raidIcon)
          pfUI.uf.player.hp.raidIcon:Show()
        else
          pfUI.uf.player.hp.raidIcon:Hide()
        end
        if event == "RAID_TARGET_UPDATE" then return end
      end

      if event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        if UnitIsPartyLeader("player") then
          pfUI.uf.player.hp.leaderIcon:Show()
        else
          pfUI.uf.player.hp.leaderIcon:Hide()
        end
        if event == "PARTY_LEADER_CHANGED" then return end
      end

      if event == "PARTY_LOOT_METHOD_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        local _, lootmaster = GetLootMethod()
        if lootmaster and pfUI.uf.player.id == lootmaster then
          pfUI.uf.player.hp.lootIcon:Show()
        else
          pfUI.uf.player.hp.lootIcon:Hide()
        end
        if event == "PARTY_LOOT_METHOD_CHANGED" then return end
      end

      if (arg1 and arg1 == "player") or event == "PLAYER_ENTERING_WORLD" then
        if event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" then
          pfUI.uf.player.power.bar:SetValue(0)
        end

        local hp, hpmax = UnitHealth("player"), UnitHealthMax("player")
        local power, powermax = UnitMana("player"), UnitManaMax("player")
        _, class = UnitClass("player")
        local color = RAID_CLASS_COLORS[class]

        local cr, cg, cb = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5
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

        PowerColor = ManaBarColor[UnitPowerType("player")]
        pfUI.uf.player.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
        pfUI.uf.player.power.bar:SetMinMaxValues(0, UnitManaMax("player"))

        pfUI.uf.player.powerText:SetTextColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5,1)

        pfUI.uf.player.powerText:SetText( UnitMana("player") )

        pfUI.uf.player.hpReal = hp
        pfUI.uf.player.powerReal = power
      end
    end)

  pfUI.uf.player:SetScript("OnUpdate", function()
      local hpDisplay = pfUI.uf.player.hp.bar:GetValue()
      local hpReal = pfUI.uf.player.hpReal
      local hpDiff = abs(hpReal - hpDisplay)

      if hpDisplay < hpReal then
        pfUI.uf.player.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI_config.unitframes.animation_speed))
      elseif hpDisplay > hpReal then
        pfUI.uf.player.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI_config.unitframes.animation_speed))
      elseif hpDisplay ~= hpReal then
        pfUI.uf.player.hp.bar:SetValue(hpReal)
      end

      local powerDisplay = pfUI.uf.player.power.bar:GetValue()
      local powerReal = pfUI.uf.player.powerReal
      local powerDiff = abs(powerReal - powerDisplay)

      if powerDisplay < powerReal then
        pfUI.uf.player.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      elseif powerDisplay > powerReal then
        pfUI.uf.player.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      end
    end)

  pfUI.uf.player.hp = CreateFrame("Frame",nil, pfUI.uf.player)
  pfUI.uf.player.hp:SetPoint("TOP", 0, 0)
  pfUI.uf.player.hp:SetWidth(pfUI_config.unitframes.player.width)
  pfUI.uf.player.hp:SetHeight(pfUI_config.unitframes.player.height)
  pfUI.utils:CreateBackdrop(pfUI.uf.player.hp, default_border)

  pfUI.uf.player.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.player.hp)
  pfUI.uf.player.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.player.hp.bar:SetAllPoints(pfUI.uf.player.hp)
  pfUI.uf.player.hp.bar:SetMinMaxValues(0, 100)

  pfUI.uf.player.hp.leaderIcon = CreateFrame("Frame",nil,pfUI.uf.player.hp)
  pfUI.uf.player.hp.leaderIcon:SetWidth(10)
  pfUI.uf.player.hp.leaderIcon:SetHeight(10)
  pfUI.uf.player.hp.leaderIcon:SetFrameStrata("HIGH")
  pfUI.uf.player.hp.leaderIcon.texture = pfUI.uf.player.hp.leaderIcon:CreateTexture(nil,"BACKGROUND")
  pfUI.uf.player.hp.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  pfUI.uf.player.hp.leaderIcon.texture:SetAllPoints(pfUI.uf.player.hp.leaderIcon)
  pfUI.uf.player.hp.leaderIcon:SetPoint("CENTER", pfUI.uf.player.hp, "TOPLEFT", 0, 0)
  pfUI.uf.player.hp.leaderIcon:Hide()

  pfUI.uf.player.hp.lootIcon = CreateFrame("Frame",nil,pfUI.uf.player.hp)
  pfUI.uf.player.hp.lootIcon:SetWidth(10)
  pfUI.uf.player.hp.lootIcon:SetHeight(10)
  pfUI.uf.player.hp.lootIcon:SetFrameStrata("HIGH")
  pfUI.uf.player.hp.lootIcon.texture = pfUI.uf.player.hp.lootIcon:CreateTexture(nil,"BACKGROUND")
  pfUI.uf.player.hp.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
  pfUI.uf.player.hp.lootIcon.texture:SetAllPoints(pfUI.uf.player.hp.lootIcon)
  pfUI.uf.player.hp.lootIcon:SetPoint("CENTER", pfUI.uf.player.hp, "LEFT", 0, 0)
  pfUI.uf.player.hp.lootIcon:Hide()

  pfUI.uf.player.hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.player.hp)
  pfUI.uf.player.hp.raidIcon:SetFrameStrata("HIGH")
  pfUI.uf.player.hp.raidIcon:SetWidth(24)
  pfUI.uf.player.hp.raidIcon:SetHeight(24)
  pfUI.uf.player.hp.raidIcon.texture = pfUI.uf.player.hp.raidIcon:CreateTexture(nil,"ARTWORK")
  pfUI.uf.player.hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  pfUI.uf.player.hp.raidIcon.texture:SetAllPoints(pfUI.uf.player.hp.raidIcon)
  pfUI.uf.player.hp.raidIcon:SetPoint("TOP", pfUI.uf.player.hp, "TOP", 0, 6)
  pfUI.uf.player.hp.raidIcon:Hide()

  if pfUI_config.unitframes.portrait == "1" then
    pfUI.uf.player.hp.bar.portrait = CreateFrame("PlayerModel",nil,pfUI.uf.player.hp.bar)
    pfUI.uf.player.hp.bar.portrait:SetAllPoints(pfUI.uf.player.hp.bar)
    pfUI.uf.player.hp.bar.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    pfUI.uf.player.hp.bar.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
    pfUI.uf.player.hp.bar.portrait:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.uf.player.hp.bar.portrait:SetScript("OnEvent", function() this:Update() end)
    pfUI.uf.player.hp.bar.portrait:SetScript("OnShow", function() this:Update() end)

    function pfUI.uf.player.hp.bar.portrait.Update()
      pfUI.uf.player.hp.bar.portrait:SetUnit("player")
      pfUI.uf.player.hp.bar.portrait:SetCamera(0)
      pfUI.uf.player.hp.bar.portrait:SetAlpha(0.10)
    end
  end

  pfUI.uf.player.power = CreateFrame("Frame",nil, pfUI.uf.player)
  pfUI.uf.player.power:SetPoint("BOTTOM", 0, 0)
  pfUI.uf.player.power:SetWidth(pfUI_config.unitframes.player.width)
  pfUI.uf.player.power:SetHeight(pfUI_config.unitframes.player.pheight)
  pfUI.utils:CreateBackdrop(pfUI.uf.player.power, default_border)

  pfUI.uf.player.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.player.power)
  pfUI.uf.player.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.player.power.bar:SetAllPoints(pfUI.uf.player.power)
  pfUI.uf.player.power.bar:SetMinMaxValues(0, 100)

  pfUI.uf.player.hpText = pfUI.uf.player:CreateFontString("Status", "HIGH", "GameFontNormal")
  pfUI.uf.player.hpText:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.uf.player.hpText:ClearAllPoints()
  pfUI.uf.player.hpText:SetJustifyH("RIGHT")
  pfUI.uf.player.hpText:SetFontObject(GameFontWhite)
  pfUI.uf.player.hpText:SetText("5000")

  pfUI.uf.player.powerText = pfUI.uf.player:CreateFontString("Status", "HIGH", "GameFontNormal")
  pfUI.uf.player.powerText:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
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
      pfUI.uf.player.buff.RefreshBuffs()
    end)

  pfUI.uf.player.buff.buffs = {}
  for i=1, 16 do
    local id = i
    local row = 0
    if i <= 8 then row = 0 else row = 1 end

    pfUI.uf.player.buff.buffs[i] = CreateFrame("Button", "pfUIPlayerBuff" .. i, pfUI.uf.player)
    pfUI.uf.player.buff.buffs[i]:SetID(i)

    pfUI.uf.player.buff.buffs[i].stacks = pfUI.uf.player.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.buff.buffs[i])
    pfUI.uf.player.buff.buffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.player.buff.buffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.player.buff.buffs[i], 2, -2)
    pfUI.uf.player.buff.buffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.player.buff.buffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.player.buff.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.player.buff.buffs[i].stacks:SetTextColor(1,1,.5)
    pfUI.uf.player.buff.buffs[i].cd = pfUI.uf.player.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.buff.buffs[i])
    pfUI.uf.player.buff.buffs[i].cd:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.player.buff.buffs[i].cd:SetPoint("CENTER", pfUI.uf.player.buff.buffs[i], 0, 0)
    pfUI.uf.player.buff.buffs[i].cd:SetJustifyH("LEFT")
    pfUI.uf.player.buff.buffs[i].cd:SetShadowColor(0, 0, 0)
    pfUI.uf.player.buff.buffs[i].cd:SetShadowOffset(0.8, -0.8)
    pfUI.uf.player.buff.buffs[i].cd:SetTextColor(1,1,1)

    pfUI.uf.player.buff.buffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.player.buff.buffs[i]:ClearAllPoints()
    pfUI.uf.player.buff.buffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.player, "TOPLEFT",
    (i-1-8*row)*((2*default_border) + pfUI_config.unitframes.buff_size + 1),
    (row)*((2*default_border) + pfUI_config.unitframes.buff_size + 1) + 2*default_border + 1)
    pfUI.uf.player.buff.buffs[i]:SetWidth(pfUI_config.unitframes.buff_size)
    pfUI.uf.player.buff.buffs[i]:SetHeight(pfUI_config.unitframes.buff_size)
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
      local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this:GetID()-1,"HELPFUL"))
      if timeleft ~= nil and timeleft ~= 0 then
        -- if there are more than 0 seconds left
        if timeleft < 60 then
          -- show seconds if less than 60 seconds
          this.cd:SetText(ceil(timeleft))
        elseif timeleft < 3600 then
          -- show minutes if less than 3600 seconds (1 hour)
          this.cd:SetText(ceil(timeleft/60) .. 'm')
        else
          -- otherwise show hours
          this.cd:SetText(ceil(timeleft/3600) .. 'h')
        end
      else
        -- if there's no time left or not set, empty buff text
        this.cd:SetText("")
      end
    end)
  end

  function pfUI.uf.player.buff.RefreshBuffs()
    for i=1, 16 do
      local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HELPFUL"))
      pfUI.utils:CreateBackdrop(pfUI.uf.player.buff.buffs[i], default_border)
      pfUI.uf.player.buff.buffs[i]:SetNormalTexture(GetPlayerBuffTexture(GetPlayerBuff(i-1,"HELPFUL")))
      for i,v in ipairs({pfUI.uf.player.buff.buffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

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
      pfUI.uf.player.debuff.RefreshBuffs()
    end)

  pfUI.uf.player.debuff.debuffs = {}
  for i=1, 16 do
    local id = i
    pfUI.uf.player.debuff.debuffs[i] = CreateFrame("Button", "pfUIPlayerDebuff" .. i, pfUI.uf.player)
    pfUI.uf.player.debuff.debuffs[i]:SetID(i)
    pfUI.uf.player.debuff.debuffs[i].stacks = pfUI.uf.player.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.debuff.debuffs[i])
    pfUI.uf.player.debuff.debuffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.player.debuff.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.player.debuff.debuffs[i], 2, -2)
    pfUI.uf.player.debuff.debuffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.player.debuff.debuffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.player.debuff.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.player.debuff.debuffs[i].stacks:SetTextColor(1,1,.5)
    pfUI.uf.player.debuff.debuffs[i].cd = pfUI.uf.player.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.player.debuff.debuffs[i])
    pfUI.uf.player.debuff.debuffs[i].cd:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.player.debuff.debuffs[i].cd:SetPoint("CENTER", pfUI.uf.player.debuff.debuffs[i], 0, 0)
    pfUI.uf.player.debuff.debuffs[i].cd:SetJustifyH("LEFT")
    pfUI.uf.player.debuff.debuffs[i].cd:SetShadowColor(0, 0, 0)
    pfUI.uf.player.debuff.debuffs[i].cd:SetShadowOffset(0.8, -0.8)
    pfUI.uf.player.debuff.debuffs[i].cd:SetTextColor(1,1,1)

    pfUI.uf.player.debuff.debuffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.player.debuff.debuffs[i]:ClearAllPoints()
    pfUI.uf.player.debuff.debuffs[i]:SetWidth(pfUI_config.unitframes.debuff_size)
    pfUI.uf.player.debuff.debuffs[i]:SetHeight(pfUI_config.unitframes.debuff_size)
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
      local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this:GetID()-1,"HARMFUL"))
      if timeleft ~= nil and timeleft ~= 0 then
        -- if there are more than 0 seconds left
        if timeleft < 60 then
          -- show seconds if less than 60 seconds
          pfUI.uf.player.debuff.debuffs[i].cd:SetText(ceil(timeleft))
        elseif timeleft < 3600 then
          -- show minutes if less than 3600 seconds (1 hour)
          pfUI.uf.player.debuff.debuffs[i].cd:SetText(ceil(timeleft/60)..'m')
        else
          -- otherwise show hours
          pfUI.uf.player.buff.buffs[i].cd:SetText(ceil(timeleft/3600) .. 'h')
        end
      else
        -- if there's no time left or not set, empty buff text
        pfUI.uf.player.buff.buffs[i].cd:SetText("")
      end
    end)

  end

  function pfUI.uf.player.debuff.RefreshBuffs()
    for i=1, 16 do
      local row = 0
      local top = 0
      if i > 8 then row = 1 end
      if pfUI.uf.player.buff.buffs[1]:IsShown() then top = top + 1 end
      if pfUI.uf.player.buff.buffs[9]:IsShown() then top = top + 1 end


      pfUI.uf.player.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.player, "TOPLEFT",
      (i-1-8*row)*((2*default_border) + pfUI_config.unitframes.debuff_size + 1),
      (top)*((2*default_border) + pfUI_config.unitframes.buff_size + 1) +
      (row)*((2*default_border) + pfUI_config.unitframes.debuff_size + 1) + (2*default_border + 1))


      local stacks = GetPlayerBuffApplications(GetPlayerBuff(i-1,"HARMFUL"))
      pfUI.utils:CreateBackdrop(pfUI.uf.player.debuff.debuffs[i], default_border)
      pfUI.uf.player.debuff.debuffs[i]:SetNormalTexture(GetPlayerBuffTexture(GetPlayerBuff(i-1,"HARMFUL")))
      for i,v in ipairs({pfUI.uf.player.debuff.debuffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      local _,_,dtype = UnitDebuff("player", i)
      if dtype == "Magic" then
        pfUI.uf.player.debuff.debuffs[i].backdrop:SetBackdropBorderColor(0,1,1,1)
      elseif dtype == "Poison" then
        pfUI.uf.player.debuff.debuffs[i].backdrop:SetBackdropBorderColor(0,1,0,1)
      elseif dtype == "Curse" then
        pfUI.uf.player.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,0,1,1)
      elseif dtype == "Disease" then
        pfUI.uf.player.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,1,0,1)
      else
        pfUI.uf.player.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,0,0,1)
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
end)
