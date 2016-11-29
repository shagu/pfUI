pfUI:RegisterModule("target", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.unitframes ~= "-1" then
    default_border = pfUI_config.appearance.border.unitframes
  end

    -- Hide Blizzard target frame and unregister all events to prevent it from popping up again
  TargetFrame:Hide()
  TargetFrame:UnregisterAllEvents()

  -- Hide Blizzard combo point frame and unregister all events to prevent it from popping up again
  ComboFrame:Hide()
  ComboFrame:UnregisterAllEvents()

  pfUI.uf.target = CreateFrame("Button","pfTarget",UIParent)
  pfUI.uf.target:Hide()
  pfUI.uf.target:SetWidth(pfUI_config.unitframes.target.width)
  pfUI.uf.target:SetHeight(pfUI_config.unitframes.target.height + pfUI_config.unitframes.target.pheight + 2*default_border + pfUI_config.unitframes.target.pspace)
  pfUI.uf.target:SetPoint("BOTTOMLEFT", UIParent, "BOTTOM", 75, 125)
  pfUI.utils:UpdateMovable(pfUI.uf.target)

  pfUI.uf.target:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
  pfUI.uf.target:SetScript("OnClick", function ()
      if arg1 == "RightButton" then
        ToggleDropDownMenu(1, nil, TargetFrameDropDown, "cursor")
      end
    end)

  pfUI.uf.target:RegisterEvent("RAID_TARGET_UPDATE")
  pfUI.uf.target:RegisterEvent("PARTY_LEADER_CHANGED")
  pfUI.uf.target:RegisterEvent("PARTY_MEMBERS_CHANGED")
  pfUI.uf.target:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
  pfUI.uf.target:RegisterEvent("PLAYER_TARGET_CHANGED")

  pfUI.uf.target:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.uf.target:RegisterEvent("UNIT_HEALTH")
  pfUI.uf.target:RegisterEvent("UNIT_MAXHEALTH")
  pfUI.uf.target:RegisterEvent("UNIT_DISPLAYPOWER")
  pfUI.uf.target:RegisterEvent("UNIT_MANA")
  pfUI.uf.target:RegisterEvent("UNIT_MAXMANA")
  pfUI.uf.target:RegisterEvent("UNIT_RAGE")
  pfUI.uf.target:RegisterEvent("UNIT_MAXRAGE")
  pfUI.uf.target:RegisterEvent("UNIT_ENERGY")
  pfUI.uf.target:RegisterEvent("UNIT_MAXENERGY")
  pfUI.uf.target:RegisterEvent("UNIT_FOCUS")

  pfUI.uf.target:SetScript("OnEvent", function()
      if UnitExists("target") then
        pfUI.uf.target:Show()
      elseif (pfUI.gitter and pfUI.gitter:IsShown()) then
        pfUI.uf.target:Show()
        return
      else
        pfUI.uf.target:Hide()
        return
      end

      if event == "RAID_TARGET_UPDATE" or event == "PLAYER_TARGET_CHANGED" then
        local raidIcon = GetRaidTargetIndex("target")
        if raidIcon then
          SetRaidTargetIconTexture(pfUI.uf.target.hp.raidIcon.texture, raidIcon)
          pfUI.uf.target.hp.raidIcon:Show()
        else
          pfUI.uf.target.hp.raidIcon:Hide()
        end
      end

      if event == "PARTY_LEADER_CHANGED" or event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
        if UnitIsPartyLeader("target") then
          pfUI.uf.target.hp.leaderIcon:Show()
        else
          pfUI.uf.target.hp.leaderIcon:Hide()
        end
      end

      if event == "PARTY_LOOT_METHOD_CHANGED" or event == "PLAYER_TARGET_CHANGED" then
        local _, lootmaster = GetLootMethod()
        if lootmaster and pfUI.uf.target.id == lootmaster then
          pfUI.uf.target.hp.lootIcon:Show()
        else
          pfUI.uf.target.hp.lootIcon:Hide()
        end
      end

      if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        pfUI.uf.target.power.bar:SetValue(0)
        pfUI.uf.target.hp.bar:SetValue(0)
      end

      if (arg1 and arg1 == "target") or event == "PLAYER_TARGET_CHANGED" then
        local hp, hpmax
        if MobHealth3 then
          hp, hpmax = MobHealth3:GetUnitHealth("target")
        else
          hp, hpmax = UnitHealth("target"), UnitHealthMax("target")
        end
        local power, powermax = UnitMana("target"), UnitManaMax("target")

        if hp ~= hpmax and hpmax ~= 100 then
          pfUI.uf.target.hpText:SetText( hp .. " - " .. ceil(hp / hpmax * 100) .. "%")
        else
          pfUI.uf.target.hpText:SetText( hp)
        end

        local color = { r = 1, g = 1, b = 1 }
        if UnitIsPlayer("target") then
          _, class = UnitClass("target")
          color = RAID_CLASS_COLORS[class]
        else
          color = UnitReactionColor[UnitReaction("target", "player")]
        end

        local r, g, b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5

        pfUI.uf.target.hp.bar:SetMinMaxValues(0, hpmax)
        pfUI.uf.target.hp.bar:SetStatusBarColor(r, g, b, hp / hpmax / 4 + .75)
        pfUI.uf.target.powerText:SetTextColor(r, g, b, 1)

        local perc = hp / hpmax
        local r1, g1, b1, r2, g2, b2
        if perc <= 0.5 then
          perc = perc * 2; r1, g1, b1 = .9, .5, .5; r2, g2, b2 = .9, .9, .5
        else
          perc = perc * 2 - 1; r1, g1, b1 = .9, .9, .5; r2, g2, b2 = .5, .9, .5
        end
        local r, g, b = r1 + (r2 - r1)*perc, g1 + (g2 - g1)*perc, b1 + (b2 - b1)*perc
        pfUI.uf.target.hpText:SetTextColor(r, g, b,1)

        local leveldiff = UnitLevel("player") - UnitLevel("target")
        local levelcolor
        if leveldiff >= 9 then
          levelcolor = "555555"
        elseif leveldiff >= 3 then
          levelcolor = "55ff55"
        elseif leveldiff >= -2 then
          levelcolor = "aaff55"
        elseif leveldiff >= -4 then
          levelcolor = "ffaa55"
        else
          levelcolor = "ff5555"
        end

        local name = string.sub(UnitName("target"),1,25)
        if strlen(UnitName("target")) > 25 then
          name = name .. "..."
        end

        local level = UnitLevel("target")
        if level == -1 then level = "??" end

        if UnitClassification("target") == "worldboss" then
          level = level .. "B"
        elseif UnitClassification("target") == "rareelite" then
          level = level .. "R+"
        elseif UnitClassification("target") == "elite" then
          level = level .. "+"
        elseif UnitClassification("target") == "rare" then
          level = level .. "R"
        end

        pfUI.uf.target.powerText:SetText( "|cff" .. levelcolor .. level .. "|r " .. name)
        pfUI.uf.target.powerText:SetWidth(pfUI.uf.target:GetWidth() -30 - pfUI.uf.target.hpText:GetStringWidth())

        PowerColor = ManaBarColor[UnitPowerType("target")]
        pfUI.uf.target.power.bar:SetStatusBarColor(PowerColor.r + .5, PowerColor.g +.5, PowerColor.b +.5, 1)
        pfUI.uf.target.power.bar:SetMinMaxValues(0, UnitManaMax("target"))

        pfUI.uf.target.hpReal = hp
        pfUI.uf.target.powerReal = power
        pfUI.uf.target.tapped  = nil
      end
    end)

  pfUI.uf.target:SetScript("OnUpdate", function()
      if not UnitExists("target") then return end

      local hpDisplay = pfUI.uf.target.hp.bar:GetValue()
      local hpReal = pfUI.uf.target.hpReal
      local hpDiff = abs(hpReal - hpDisplay)

      if pfUI.uf.target.noanim == "yes" then
        pfUI.uf.target.hp.bar:SetValue(hpReal)
      elseif hpDisplay < hpReal then
        pfUI.uf.target.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI_config.unitframes.animation_speed))
      elseif hpDisplay > hpReal then
        pfUI.uf.target.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI_config.unitframes.animation_speed))
      end

      local powerDisplay = pfUI.uf.target.power.bar:GetValue()
      local powerReal = pfUI.uf.target.powerReal
      local powerDiff = abs(powerReal - powerDisplay)

      if pfUI.uf.target.noanim == "yes" then
        pfUI.uf.target.power.bar:SetValue(powerReal)
      elseif powerDisplay < powerReal then
        pfUI.uf.target.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      elseif powerDisplay > powerReal then
        pfUI.uf.target.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
      end

      pfUI.uf.target.noanim = "no"

      if not pfUI.uf.target.tapped and UnitIsTapped("target") and not UnitIsTappedByPlayer("target") then
        pfUI.uf.target.hp.bar:SetStatusBarColor(.5,.5,.5,.5)
        pfUI.uf.target.tapped = true
      end
    end)

  pfUI.uf.target.hp = CreateFrame("Frame",nil, pfUI.uf.target)
  pfUI.uf.target.hp:SetWidth(pfUI_config.unitframes.target.width)
  pfUI.uf.target.hp:SetHeight(pfUI_config.unitframes.target.height)
  pfUI.uf.target.hp:SetPoint("TOP", 0, 0)
  pfUI.utils:CreateBackdrop(pfUI.uf.target.hp, default_border)

  pfUI.uf.target.hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.target.hp)
  pfUI.uf.target.hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.target.hp.bar:SetAllPoints(pfUI.uf.target.hp)
  pfUI.uf.target.hp.bar:SetMinMaxValues(0, 100)

  pfUI.uf.target.hp.leaderIcon = CreateFrame("Frame",nil,pfUI.uf.target.hp)
  pfUI.uf.target.hp.leaderIcon:SetWidth(10)
  pfUI.uf.target.hp.leaderIcon:SetHeight(10)
  pfUI.uf.target.hp.leaderIcon:SetFrameStrata("HIGH")
  pfUI.uf.target.hp.leaderIcon.texture = pfUI.uf.target.hp.leaderIcon:CreateTexture(nil,"BACKGROUND")
  pfUI.uf.target.hp.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
  pfUI.uf.target.hp.leaderIcon.texture:SetAllPoints(pfUI.uf.target.hp.leaderIcon)
  pfUI.uf.target.hp.leaderIcon:SetPoint("TOPLEFT", pfUI.uf.target.hp, "TOPLEFT", -4, 4)
  pfUI.uf.target.hp.leaderIcon:Hide()

  pfUI.uf.target.hp.lootIcon = CreateFrame("Frame",nil,pfUI.uf.target.hp)
  pfUI.uf.target.hp.lootIcon:SetWidth(10)
  pfUI.uf.target.hp.lootIcon:SetHeight(10)
  pfUI.uf.target.hp.lootIcon:SetFrameStrata("HIGH")
  pfUI.uf.target.hp.lootIcon.texture = pfUI.uf.target.hp.lootIcon:CreateTexture(nil,"BACKGROUND")
  pfUI.uf.target.hp.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
  pfUI.uf.target.hp.lootIcon.texture:SetAllPoints(pfUI.uf.target.hp.lootIcon)
  pfUI.uf.target.hp.lootIcon:SetPoint("TOPLEFT", pfUI.uf.target.hp, "LEFT", -4, 4)
  pfUI.uf.target.hp.lootIcon:Hide()

  pfUI.uf.target.hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.target.hp)
  pfUI.uf.target.hp.raidIcon:SetFrameStrata("MEDIUM")
  pfUI.uf.target.hp.raidIcon:SetParent(pfUI.uf.target.hp.bar)
  pfUI.uf.target.hp.raidIcon:SetWidth(24)
  pfUI.uf.target.hp.raidIcon:SetHeight(24)
  pfUI.uf.target.hp.raidIcon.texture = pfUI.uf.target.hp.raidIcon:CreateTexture(nil,"ARTWORK")
  pfUI.uf.target.hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
  pfUI.uf.target.hp.raidIcon.texture:SetAllPoints(pfUI.uf.target.hp.raidIcon)
  pfUI.uf.target.hp.raidIcon:SetPoint("TOP", pfUI.uf.target.hp, "TOP", 0, 6)
  pfUI.uf.target.hp.raidIcon:Hide()


  if pfUI_config.unitframes.portrait == "1" then
    pfUI.uf.target.hp.bar.portrait = CreateFrame("PlayerModel",nil,pfUI.uf.target.hp.bar)
    pfUI.uf.target.hp.bar.portrait:SetAllPoints(pfUI.uf.target.hp.bar)
    pfUI.uf.target.hp.bar.portrait:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    pfUI.uf.target.hp.bar.portrait:RegisterEvent("UNIT_MODEL_CHANGED")
    pfUI.uf.target.hp.bar.portrait:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.uf.target.hp.bar.portrait:RegisterEvent("PLAYER_TARGET_CHANGED")

    pfUI.uf.target.hp.bar.portrait:SetScript("OnEvent", function() this:Update() end)
    pfUI.uf.target.hp.bar.portrait:SetScript("OnShow", function() this:Update() end)

    function pfUI.uf.target.hp.bar.portrait.Update()
      pfUI.uf.target.hp.bar.portrait:SetUnit("target")
      pfUI.uf.target.hp.bar.portrait:SetCamera(0)
      pfUI.uf.target.hp.bar.portrait:SetAlpha(0.10)
    end
  end

  pfUI.uf.target.power = CreateFrame("Frame",nil, pfUI.uf.target)
  pfUI.uf.target.power:SetPoint("BOTTOM", 0, 0)
  pfUI.uf.target.power:SetWidth(pfUI_config.unitframes.target.width)
  pfUI.uf.target.power:SetHeight(pfUI_config.unitframes.target.pheight)
  pfUI.utils:CreateBackdrop(pfUI.uf.target.power, default_border)

  pfUI.uf.target.power.bar = CreateFrame("StatusBar", nil, pfUI.uf.target.power)
  pfUI.uf.target.power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
  pfUI.uf.target.power.bar:SetAllPoints(pfUI.uf.target.power)
  pfUI.uf.target.power.bar:SetMinMaxValues(0, 100)

  pfUI.uf.target.hpText = pfUI.uf.target:CreateFontString("Status", "HIGH", "GameFontNormal")
  pfUI.uf.target.hpText:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.uf.target.hpText:ClearAllPoints()
  pfUI.uf.target.hpText:SetParent(pfUI.uf.target.hp.bar)
  pfUI.uf.target.hpText:SetPoint("RIGHT",pfUI.uf.target.hp.bar, "RIGHT", -10, 0)
  pfUI.uf.target.hpText:SetJustifyH("RIGHT")
  pfUI.uf.target.hpText:SetFontObject(GameFontWhite)
  pfUI.uf.target.hpText:SetText("5000")

  pfUI.uf.target.powerText = pfUI.uf.target:CreateFontString("Status", "HIGH", "GameFontNormal")
  pfUI.uf.target.powerText:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.uf.target.powerText:ClearAllPoints()
  pfUI.uf.target.powerText:SetParent(pfUI.uf.target.hp.bar)
  pfUI.uf.target.powerText:SetPoint("LEFT",pfUI.uf.target.hp.bar, "LEFT", 10, 0)
  pfUI.uf.target.powerText:SetJustifyH("LEFT")
  pfUI.uf.target.powerText:SetFontObject(GameFontWhite)
  pfUI.uf.target.powerText:SetHeight(pfUI_config.global.font_size)
  pfUI.uf.target.powerText:SetNonSpaceWrap(true)
  pfUI.uf.target.powerText:SetText("5000")

  pfUI.uf.target.combopoints = CreateFrame("Frame")

  pfUI.uf.target.combopoints:RegisterEvent("UNIT_COMBO_POINTS")
  pfUI.uf.target.combopoints:RegisterEvent("PLAYER_COMBO_POINTS")
  pfUI.uf.target.combopoints:RegisterEvent("UNIT_DISPLAYPOWER")
  pfUI.uf.target.combopoints:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.uf.target.combopoints:RegisterEvent('UNIT_ENERGY')
  pfUI.uf.target.combopoints:RegisterEvent("PLAYER_ENTERING_WORLD")

  pfUI.uf.target.combopoint1 = CreateFrame("Frame")
  pfUI.uf.target.combopoint2 = CreateFrame("Frame")
  pfUI.uf.target.combopoint3 = CreateFrame("Frame")
  pfUI.uf.target.combopoint4 = CreateFrame("Frame")
  pfUI.uf.target.combopoint5 = CreateFrame("Frame")

  pfUI.uf.target.combopoints:SetScript("OnEvent", function()
      if event == "PLAYER_ENTERING_WORLD" then
        for point=1, 5 do
          pfUI.uf.target["combopoint" .. point]:SetFrameStrata("HIGH")
          pfUI.uf.target["combopoint" .. point]:SetWidth(5)
          pfUI.uf.target["combopoint" .. point]:SetHeight(5)
          pfUI.utils:CreateBackdrop(pfUI.uf.target["combopoint" .. point])
          pfUI.uf.target["combopoint" .. point]:SetPoint("TOPLEFT", pfUI.uf.target, "TOPRIGHT", pfUI_config.appearance.border.default*3, -(point - 1) * (5 + pfUI_config.appearance.border.default*3))
          if point < 3 then
            local tex = pfUI.uf.target["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(pfUI.uf.target["combopoint" .. point])
            tex:SetTexture(1, .3, .3, .75)
          elseif point < 4 then
            local tex = pfUI.uf.target["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(pfUI.uf.target["combopoint" .. point])
            tex:SetTexture(1, 1, .3, .75)
          else
            local tex = pfUI.uf.target["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(pfUI.uf.target["combopoint" .. point])
            tex:SetTexture(.3, 1, .3, .75)
          end
          pfUI.uf.target["combopoint" .. point]:Hide()
        end
      else
        local combopoints = GetComboPoints("target")
        for point=1, 5 do
          pfUI.uf.target["combopoint" .. point]:Hide()
        end
        for point=1, combopoints do
          pfUI.uf.target["combopoint" .. point]:Show()
        end
      end
    end)

  pfUI.uf.target.buff = CreateFrame("Frame", nil)
  pfUI.uf.target.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.uf.target.buff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.uf.target.buff:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.uf.target.buff:RegisterEvent("UNIT_AURA")
  pfUI.uf.target.buff:SetScript("OnEvent", function()
      pfUI.uf.target.buff.RefreshBuffs()
    end)

  pfUI.uf.target.buff.buffs = {}
  for i=1, 16 do
    local id = i
    local row = 0
    if i <= 8 then row = 0 else row = 1 end

    pfUI.uf.target.buff.buffs[i] = CreateFrame("Button", "pfUITargetBuff" .. i, pfUI.uf.target)
    pfUI.uf.target.buff.buffs[i].stacks = pfUI.uf.target.buff.buffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.target.buff.buffs[i])
    pfUI.uf.target.buff.buffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.target.buff.buffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.target.buff.buffs[i], 2, -2)
    pfUI.uf.target.buff.buffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.target.buff.buffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.target.buff.buffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.target.buff.buffs[i].stacks:SetTextColor(1,1,.5)

    pfUI.uf.target.buff.buffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.target.buff.buffs[i]:ClearAllPoints()
    pfUI.uf.target.buff.buffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.target, "TOPLEFT",
    (i-1-8*row)*((2*default_border) + pfUI_config.unitframes.buff_size + 1),
    (row)*((2*default_border) + pfUI_config.unitframes.buff_size + 1) + 2*default_border + 1)
    pfUI.uf.target.buff.buffs[i]:SetWidth(pfUI_config.unitframes.buff_size)
    pfUI.uf.target.buff.buffs[i]:SetHeight(pfUI_config.unitframes.buff_size)
    pfUI.uf.target.buff.buffs[i]:SetNormalTexture(nil)
    pfUI.uf.target.buff.buffs[i]:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitBuff("target", id)
      end)

    pfUI.uf.target.buff.buffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
  end

  function pfUI.uf.target.buff.RefreshBuffs()
    for i=1, 16 do
      local texture, stacks = UnitBuff("target",i)
      pfUI.utils:CreateBackdrop(pfUI.uf.target.buff.buffs[i], default_border)
      pfUI.uf.target.buff.buffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({pfUI.uf.target.buff.buffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      if texture then
        pfUI.uf.target.buff.buffs[i]:Show()
        if stacks > 1 then
          pfUI.uf.target.buff.buffs[i].stacks:SetText(stacks)
        else
          pfUI.uf.target.buff.buffs[i].stacks:SetText("")
        end
      else
        pfUI.uf.target.buff.buffs[i]:Hide()
      end
    end
  end

  pfUI.uf.target.debuff = CreateFrame("Frame", nil)
  pfUI.uf.target.debuff:RegisterEvent("PLAYER_AURAS_CHANGED")
  pfUI.uf.target.debuff:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.uf.target.debuff:RegisterEvent("UNIT_AURA")
  pfUI.uf.target.debuff:SetScript("OnEvent", function()
      pfUI.uf.target.debuff.RefreshBuffs()
    end)

  pfUI.uf.target.debuff.debuffs = {}
  for i=1, 16 do
    local id = i
    pfUI.uf.target.debuff.debuffs[i] = CreateFrame("Button", "pfUITargetDebuff" .. i, pfUI.uf.target)
    pfUI.uf.target.debuff.debuffs[i].stacks = pfUI.uf.target.debuff.debuffs[i]:CreateFontString(nil, "OVERLAY", pfUI.uf.target.debuff.debuffs[i])
    pfUI.uf.target.debuff.debuffs[i].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.target.debuff.debuffs[i].stacks:SetPoint("BOTTOMRIGHT", pfUI.uf.target.debuff.debuffs[i], 2, -2)
    pfUI.uf.target.debuff.debuffs[i].stacks:SetJustifyH("LEFT")
    pfUI.uf.target.debuff.debuffs[i].stacks:SetShadowColor(0, 0, 0)
    pfUI.uf.target.debuff.debuffs[i].stacks:SetShadowOffset(0.8, -0.8)
    pfUI.uf.target.debuff.debuffs[i].stacks:SetTextColor(1,1,.5)
    pfUI.uf.target.debuff.debuffs[i]:RegisterForClicks("RightButtonUp")
    pfUI.uf.target.debuff.debuffs[i]:ClearAllPoints()

    pfUI.uf.target.debuff.debuffs[i]:SetWidth(pfUI_config.unitframes.debuff_size)
    pfUI.uf.target.debuff.debuffs[i]:SetHeight(pfUI_config.unitframes.debuff_size)
    pfUI.uf.target.debuff.debuffs[i]:SetNormalTexture(nil)
    pfUI.uf.target.debuff.debuffs[i]:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetUnitDebuff("target", id)
      end)
    pfUI.uf.target.debuff.debuffs[i]:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
    pfUI.uf.target.debuff.debuffs[i]:SetScript("OnClick", function()
        CancelPlayerBuff(GetPlayerBuff(id-1,"HARMFUL"))
      end)
  end

  function pfUI.uf.target.debuff.RefreshBuffs()
    for i=1, 16 do
      local row = 0
      local top = 0
      if i > 8 then row = 1 end
      if pfUI.uf.target.buff.buffs[1]:IsShown() then top = top + 1 end
      if pfUI.uf.target.buff.buffs[9]:IsShown() then top = top + 1 end

      pfUI.uf.target.debuff.debuffs[i]:SetPoint("BOTTOMLEFT", pfUI.uf.target, "TOPLEFT",
      (i-1-8*row)*((2*default_border) + pfUI_config.unitframes.debuff_size + 1),
      (top)*((2*default_border) + pfUI_config.unitframes.buff_size + 1) +
      (row)*((2*default_border) + pfUI_config.unitframes.debuff_size + 1) + (2*default_border + 1))

      local texture, stacks = UnitDebuff("target",i)
      pfUI.utils:CreateBackdrop(pfUI.uf.target.debuff.debuffs[i], default_border)
      pfUI.uf.target.debuff.debuffs[i]:SetNormalTexture(texture)
      for i,v in ipairs({pfUI.uf.target.debuff.debuffs[i]:GetRegions()}) do
        if v.SetTexCoord then v:SetTexCoord(.08, .92, .08, .92) end
      end

      local _,_,dtype = UnitDebuff("target", i)
      if dtype == "Magic" then
        pfUI.uf.target.debuff.debuffs[i].backdrop:SetBackdropBorderColor(0,1,1,1)
      elseif dtype == "Poison" then
        pfUI.uf.target.debuff.debuffs[i].backdrop:SetBackdropBorderColor(0,1,0,1)
      elseif dtype == "Curse" then
        pfUI.uf.target.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,0,1,1)
      else
        pfUI.uf.target.debuff.debuffs[i].backdrop:SetBackdropBorderColor(1,0,0,1)
      end

      if texture then
        pfUI.uf.target.debuff.debuffs[i]:Show()
        if stacks > 1 then
          pfUI.uf.target.debuff.debuffs[i].stacks:SetText(stacks)
        else
          pfUI.uf.target.debuff.debuffs[i].stacks:SetText("")
        end
      else
        pfUI.uf.target.debuff.debuffs[i]:Hide()
      end
    end
  end
end)
