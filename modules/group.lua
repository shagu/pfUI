pfUI:RegisterModule("group", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.groupframes ~= "-1" then
    default_border = pfUI_config.appearance.border.groupframes
  end

  -- hide blizzard group frames
  for i=1, 4 do
    if getglobal("PartyMemberFrame" .. i) then
      getglobal("PartyMemberFrame" .. i):Hide()
      getglobal("PartyMemberFrame" .. i).Show = function () return end
    end
  end

  pfUI.uf.group = CreateFrame("Button","pfGroup",UIParent)
  pfUI.uf.group:Hide()

  pfUI.uf.group:RegisterEvent("RAID_TARGET_UPDATE")
  pfUI.uf.group:RegisterEvent("PARTY_LEADER_CHANGED")
  pfUI.uf.group:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")

  pfUI.uf.group:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.uf.group:RegisterEvent("PARTY_MEMBERS_CHANGED")
  pfUI.uf.group:RegisterEvent("PARTY_MEMBER_ENABLE")
  pfUI.uf.group:RegisterEvent("PARTY_MEMBER_DISABLE")
  pfUI.uf.group:RegisterEvent("RAID_ROSTER_UPDATE")
  pfUI.uf.group:RegisterEvent("GROUP_ROSTER_UPDATE")

  pfUI.uf.group:SetScript("OnEvent", function()
    PartyMemberBackground:Hide()

    for i=1, 4 do
      if pfUI_config.unitframes.group.hide_in_raid == "1" and UnitInRaid("player") then
        pfUI.uf.group[i]:Hide()
        return
      end

      if event == "RAID_TARGET_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local raidIcon = GetRaidTargetIndex("party" .. i)
        if raidIcon then
          SetRaidTargetIconTexture(pfUI.uf.group[i].hp.raidIcon.texture, raidIcon)
          pfUI.uf.group[i].hp.raidIcon:Show()
        else
          pfUI.uf.group[i].hp.raidIcon:Hide()
        end
      end

      if event == "PARTY_LEADER_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        if UnitIsPartyLeader("party"..i) then
          pfUI.uf.group[i].hp.leaderIcon:Show()
        else
          pfUI.uf.group[i].hp.leaderIcon:Hide()
        end
      end

      if event == "PARTY_LOOT_METHOD_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        local _, lootmaster = GetLootMethod()
        if lootmaster and pfUI.uf.group[i].id == lootmaster then
          pfUI.uf.group[i].hp.lootIcon:Show()
        else
          pfUI.uf.group[i].hp.lootIcon:Hide()
        end
      end

      if GetNumPartyMembers() >= i then
        pfUI.uf.group[i]:Show()
        if UnitIsConnected("party"..i) or not UnitName("party"..i) then
          pfUI.uf.group[i]:SetAlpha(1)
        else
          pfUI.uf.group[i]:SetAlpha(.25)
        end
      else
        if pfUI.uf.group[i] then
          pfUI.uf.group[i]:Hide()
        end
      end
    end
  end)

  for i=1, 4 do
    pfUI.uf.group[i] = CreateFrame("Button","pfGroup" .. i,UIParent)

    pfUI.uf.group[i]:SetWidth(175)
    pfUI.uf.group[i]:SetHeight(40 + 2*default_border + pfUI_config.unitframes.group.pspace)
    pfUI.uf.group[i]:SetPoint("TOPLEFT", 5, -5 - ((i-1)*55))
    pfUI.utils:UpdateMovable(pfUI.uf.group[i])
    pfUI.uf.group[i]:Hide()
    pfUI.uf.group[i].id = i

    pfUI.uf.group[i].hp = CreateFrame("Frame",nil, pfUI.uf.group[i])
    pfUI.uf.group[i].hp:SetWidth(175)
    pfUI.uf.group[i].hp:SetHeight(30)
    pfUI.uf.group[i].hp:SetPoint("TOP", 0, 0)
    pfUI.utils:CreateBackdrop(pfUI.uf.group[i].hp, default_border)

    pfUI.uf.group[i].hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.group[i].hp)
    pfUI.uf.group[i].hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    pfUI.uf.group[i].hp.bar:SetAllPoints(pfUI.uf.group[i].hp)
    pfUI.uf.group[i].hp.bar:SetMinMaxValues(0, 100)

    pfUI.uf.group[i].power = CreateFrame("Frame",nil, pfUI.uf.group[i])
    pfUI.uf.group[i].power:SetWidth(175)
    pfUI.uf.group[i].power:SetHeight(10)
    pfUI.uf.group[i].power:SetPoint("BOTTOM", 0, 0)
    pfUI.utils:CreateBackdrop(pfUI.uf.group[i].power, default_border)

    pfUI.uf.group[i].power.bar = CreateFrame("StatusBar", nil, pfUI.uf.group[i].power)
    pfUI.uf.group[i].power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    pfUI.uf.group[i].power.bar:SetAllPoints(pfUI.uf.group[i].power)
    pfUI.uf.group[i].power.bar:SetMinMaxValues(0, 100)

    pfUI.uf.group[i].caption = pfUI.uf.group[i]:CreateFontString("Status", "HIGH", "GameFontNormal")
    pfUI.uf.group[i].caption:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
    pfUI.uf.group[i].caption:ClearAllPoints()
    pfUI.uf.group[i].caption:SetParent(pfUI.uf.group[i].hp.bar)
    pfUI.uf.group[i].caption:SetPoint("LEFT",pfUI.uf.group[i].hp.bar, "LEFT", 10, 0)
    pfUI.uf.group[i].caption:SetJustifyH("LEFT")
    pfUI.uf.group[i].caption:SetFontObject(GameFontWhite)

    pfUI.uf.group[i].hp.leaderIcon = CreateFrame("Frame",nil,pfUI.uf.group[i].hp)
    pfUI.uf.group[i].hp.leaderIcon:SetWidth(10)
    pfUI.uf.group[i].hp.leaderIcon:SetHeight(10)
    pfUI.uf.group[i].hp.leaderIcon.texture = pfUI.uf.group[i].hp.leaderIcon:CreateTexture(nil,"BACKGROUND")
    pfUI.uf.group[i].hp.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
    pfUI.uf.group[i].hp.leaderIcon.texture:SetAllPoints(pfUI.uf.group[i].hp.leaderIcon)
    pfUI.uf.group[i].hp.leaderIcon:SetPoint("TOPLEFT", pfUI.uf.group[i].hp, "TOPLEFT", -4, 4)
    pfUI.uf.group[i].hp.leaderIcon:Hide()

    pfUI.uf.group[i].hp.lootIcon = CreateFrame("Frame",nil,pfUI.uf.group[i].hp)
    pfUI.uf.group[i].hp.lootIcon:SetWidth(10)
    pfUI.uf.group[i].hp.lootIcon:SetHeight(10)
    pfUI.uf.group[i].hp.lootIcon.texture = pfUI.uf.group[i].hp.lootIcon:CreateTexture(nil,"BACKGROUND")
    pfUI.uf.group[i].hp.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
    pfUI.uf.group[i].hp.lootIcon.texture:SetAllPoints(pfUI.uf.group[i].hp.lootIcon)
    pfUI.uf.group[i].hp.lootIcon:SetPoint("TOPLEFT", pfUI.uf.group[i].hp, "LEFT", -4, 4)
    pfUI.uf.group[i].hp.lootIcon:Hide()

    pfUI.uf.group[i].hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.group[i].hp.bar)
    pfUI.uf.group[i].hp.raidIcon:SetWidth(24)
    pfUI.uf.group[i].hp.raidIcon:SetHeight(24)
    pfUI.uf.group[i].hp.raidIcon.texture = pfUI.uf.group[i].hp.raidIcon:CreateTexture(nil,"ARTWORK")
    pfUI.uf.group[i].hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
    pfUI.uf.group[i].hp.raidIcon.texture:SetAllPoints(pfUI.uf.group[i].hp.raidIcon)
    pfUI.uf.group[i].hp.raidIcon:SetPoint("TOP", pfUI.uf.group[i].hp, "TOP", -4, 4)
    pfUI.uf.group[i].hp.raidIcon:Hide()

    pfUI.uf.group[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')

    pfUI.uf.group[i]:SetScript("OnEnter", function()
      GameTooltip_SetDefaultAnchor(GameTooltip, this)
      GameTooltip:SetUnit("party" .. this.id)
      GameTooltip:Show()
    end)

    pfUI.uf.group[i]:SetScript("OnLeave", function()
      GameTooltip:FadeOut()
    end)

    pfUI.uf.group[i]:SetScript("OnClick", function ()
      if ( SpellIsTargeting() and arg1 == "RightButton" ) then
        SpellStopTargeting()
        return
      end

      if ( arg1 == "LeftButton" ) then
        if ( SpellIsTargeting() ) then
          SpellTargetUnit("party" .. this.id)
        elseif ( CursorHasItem() ) then
          DropItemOnUnit("party" .. this.id)
        else
          TargetUnit("party" .. this.id)
        end
      else
        local x, y = GetCursorPosition()
        ToggleDropDownMenu(1, nil, getglobal("PartyMemberFrame" .. this.id .. "DropDown"), "cursor")
      end
    end)

    pfUI.uf.group[i]:SetScript("OnUpdate", function ()
      if CheckInteractDistance("party" .. this.id, 4) or not UnitName("party" .. this.id) then
        this:SetAlpha(1)
      else
        this:SetAlpha(.5)
      end

      if UnitIsConnected("party" .. this.id) then
        this.hp.bar:SetMinMaxValues(0, UnitHealthMax("party"..this.id))
        this.power.bar:SetMinMaxValues(0, UnitManaMax("party"..this.id))

        local hpDisplay = this.hp.bar:GetValue()
        local hpReal = UnitHealth("party"..this.id)
        local hpDiff = abs(hpReal - hpDisplay)

        if hpDisplay < hpReal then
          this.hp.bar:SetValue(hpDisplay + ceil(hpDiff / pfUI_config.unitframes.animation_speed))
        elseif hpDisplay > hpReal then
          this.hp.bar:SetValue(hpDisplay - ceil(hpDiff / pfUI_config.unitframes.animation_speed))
        end

        local powerDisplay = this.power.bar:GetValue()
        local powerReal = UnitMana("party"..this.id)
        local powerDiff = abs(powerReal - powerDisplay)

        if powerDisplay < powerReal then
          this.power.bar:SetValue(powerDisplay + ceil(powerDiff / pfUI_config.unitframes.animation_speed))
        elseif powerDisplay > powerReal then
          this.power.bar:SetValue(powerDisplay - ceil(powerDiff / pfUI_config.unitframes.animation_speed))
        end

        _, class = UnitClass("party"..this.id)
        local c = RAID_CLASS_COLORS[class]
        local cr, cg, cb = 0, 0, 0
        if c then cr, cg, cb =(c.r + .5) * .5, (c.g + .5) * .5, (c.b + .5) * .5 end

        this.hp.bar:SetStatusBarColor(cr, cg, cb)

        local pcolor = ManaBarColor[UnitPowerType("party"..this.id)]
        this.power.bar:SetStatusBarColor(pcolor.r + .5, pcolor.g +.5, pcolor.b +.5, 1)

        this.caption:SetText(UnitName("party"..this.id))

      else
        this.hp.bar:SetMinMaxValues(0, 100)
        this.power.bar:SetMinMaxValues(0, 100)
        this.hp.bar:SetValue(0)
        this.power.bar:SetValue(0)
        local name = UnitName("party"..this.id)
        if name then
          this.caption:SetText("[OFF]" .. name)
        end
      end
    end)
  end

end)
