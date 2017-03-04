pfUI:RegisterModule("group", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.groupframes ~= "-1" then
    default_border = C.appearance.border.groupframes
  end

  local spacing = C.unitframes.group.pspace

  -- hide blizzard group frames
  for i=1, 4 do
    if _G["PartyMemberFrame" .. i] then
      _G["PartyMemberFrame" .. i]:Hide()
      _G["PartyMemberFrame" .. i].Show = function () return end
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
      if C.unitframes.group.hide_in_raid == "1" and UnitInRaid("player") then
        pfUI.uf.group[i]:Hide()
      else
        if event == "RAID_TARGET_UPDATE" or event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" then
          local raidIcon = GetRaidTargetIndex("party" .. i)
          if raidIcon and UnitExists("party" .. i) then
            SetRaidTargetIconTexture(pfUI.uf.group[i].hp.raidIcon.texture, raidIcon)
            pfUI.uf.group[i].hp.raidIcon:Show()
          else
            pfUI.uf.group[i].hp.raidIcon:Hide()
          end
        end

        if event == "PARTY_LEADER_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" then
          if UnitIsPartyLeader("party"..i) then
            pfUI.uf.group[i].hp.leaderIcon:Show()
          else
            pfUI.uf.group[i].hp.leaderIcon:Hide()
          end
        end

        if event == "PARTY_LOOT_METHOD_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "PARTY_MEMBERS_CHANGED" then
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
    end
  end)

  for i=1, 4 do
    pfUI.uf.group[i] = CreateFrame("Button","pfGroup" .. i,UIParent)

    pfUI.uf.group[i]:SetWidth(175)
    pfUI.uf.group[i]:SetHeight(40 + 2*default_border + spacing)
    pfUI.uf.group[i]:SetPoint("TOPLEFT", 5, -5 - ((i-1)*55))
    UpdateMovable(pfUI.uf.group[i])
    pfUI.uf.group[i]:Hide()
    pfUI.uf.group[i].id = i
    pfUI.uf.group[i].label = "party"


    pfUI.uf.group[i].hp = CreateFrame("Frame",nil, pfUI.uf.group[i])
    pfUI.uf.group[i].hp:SetWidth(175)
    pfUI.uf.group[i].hp:SetHeight(30)
    pfUI.uf.group[i].hp:SetPoint("TOP", 0, 0)
    CreateBackdrop(pfUI.uf.group[i].hp, default_border)

    pfUI.uf.group[i].hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.group[i].hp)
    pfUI.uf.group[i].hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    pfUI.uf.group[i].hp.bar:SetAllPoints(pfUI.uf.group[i].hp)
    pfUI.uf.group[i].hp.bar:SetMinMaxValues(0, 100)

    if C.unitframes.custombg == "1" then
      local cr, cg, cb, ca = strsplit(",", C.unitframes.custombgcolor)
      cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
      pfUI.uf.group[i].hp.bar.texture = pfUI.uf.group[i].hp.bar:CreateTexture(nil,"BACKGROUND")
      pfUI.uf.group[i].hp.bar.texture:SetTexture(cr,cg,cb,ca)
      pfUI.uf.group[i].hp.bar.texture:SetAllPoints(pfUI.uf.group[i].hp.bar)
    end

    pfUI.uf.group[i].power = CreateFrame("Frame",nil, pfUI.uf.group[i])
    pfUI.uf.group[i].power:SetWidth(175)
    pfUI.uf.group[i].power:SetHeight(10)
    pfUI.uf.group[i].power:SetPoint("BOTTOM", 0, 0)
    CreateBackdrop(pfUI.uf.group[i].power, default_border)

    pfUI.uf.group[i].power.bar = CreateFrame("StatusBar", nil, pfUI.uf.group[i].power)
    pfUI.uf.group[i].power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    pfUI.uf.group[i].power.bar:SetAllPoints(pfUI.uf.group[i].power)
    pfUI.uf.group[i].power.bar:SetMinMaxValues(0, 100)

    pfUI.uf:CreatePortrait(pfUI.uf.group[i], C.unitframes.group.portrait, spacing)

    pfUI.uf.group[i].caption = pfUI.uf.group[i]:CreateFontString("Status", "OVERLAY", "GameFontNormal")
    pfUI.uf.group[i].caption:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
    pfUI.uf.group[i].caption:ClearAllPoints()
    pfUI.uf.group[i].caption:SetParent(pfUI.uf.group[i].hp.bar)
    pfUI.uf.group[i].caption:SetPoint("LEFT",pfUI.uf.group[i].hp.bar, "LEFT", 10, 0)
    pfUI.uf.group[i].caption:SetJustifyH("LEFT")
    pfUI.uf.group[i].caption:SetFontObject(GameFontWhite)

    pfUI.uf.group[i].hp.leaderIcon = CreateFrame("Frame",nil,pfUI.uf.group[i].hp.bar)
    pfUI.uf.group[i].hp.leaderIcon:SetWidth(10)
    pfUI.uf.group[i].hp.leaderIcon:SetHeight(10)
    pfUI.uf.group[i].hp.leaderIcon.texture = pfUI.uf.group[i].hp.leaderIcon:CreateTexture(nil,"BACKGROUND")
    pfUI.uf.group[i].hp.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-LeaderIcon")
    pfUI.uf.group[i].hp.leaderIcon.texture:SetAllPoints(pfUI.uf.group[i].hp.leaderIcon)
    pfUI.uf.group[i].hp.leaderIcon:SetPoint("TOPLEFT", pfUI.uf.group[i].hp, "TOPLEFT", -4, 4)
    pfUI.uf.group[i].hp.leaderIcon:Hide()

    pfUI.uf.group[i].hp.lootIcon = CreateFrame("Frame",nil,pfUI.uf.group[i].hp.bar)
    pfUI.uf.group[i].hp.lootIcon:SetWidth(10)
    pfUI.uf.group[i].hp.lootIcon:SetHeight(10)
    pfUI.uf.group[i].hp.lootIcon.texture = pfUI.uf.group[i].hp.lootIcon:CreateTexture(nil,"BACKGROUND")
    pfUI.uf.group[i].hp.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Group-MasterLooter")
    pfUI.uf.group[i].hp.lootIcon.texture:SetAllPoints(pfUI.uf.group[i].hp.lootIcon)
    pfUI.uf.group[i].hp.lootIcon:SetPoint("TOPLEFT", pfUI.uf.group[i].hp, "LEFT", -4, 4)
    pfUI.uf.group[i].hp.lootIcon:Hide()

    pfUI.uf.group[i].hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.group[i].hp.bar.bar)
    pfUI.uf.group[i].hp.raidIcon:SetFrameStrata("HIGH")
    pfUI.uf.group[i].hp.raidIcon:SetWidth(24)
    pfUI.uf.group[i].hp.raidIcon:SetHeight(24)
    pfUI.uf.group[i].hp.raidIcon.texture = pfUI.uf.group[i].hp.raidIcon:CreateTexture(nil,"ARTWORK")
    pfUI.uf.group[i].hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
    pfUI.uf.group[i].hp.raidIcon.texture:SetAllPoints(pfUI.uf.group[i].hp.raidIcon)
    pfUI.uf.group[i].hp.raidIcon:SetPoint("TOP", pfUI.uf.group[i].hp, "TOP", -4, 4)
    pfUI.uf.group[i].hp.raidIcon:Hide()

    pfUI.uf.group[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')

    pfUI.uf:CreateUnit(pfUI.uf.group[i])
  end
end)
