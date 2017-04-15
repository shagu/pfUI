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
    pfUI.uf.group[i] = pfUI.uf:CreateUnitFrame("Party", i, C.unitframes.group)
    pfUI.uf.group[i]:UpdateFrameSize()
    pfUI.uf.group[i]:SetPoint("TOPLEFT", 5, -5 - ((i-1)*75))
    UpdateMovable(pfUI.uf.group[i])

    pfUI.uf.group[i].target = pfUI.uf:CreateUnitFrame("Party" .. i .. "Target", nil, C.unitframes.grouptarget, 0.2)

    pfUI.uf.group[i].target:UpdateFrameSize()
    pfUI.uf.group[i].target:SetPoint("TOPLEFT", pfUI.uf.group[i], "TOPRIGHT", 3*default_border, 0)
    UpdateMovable(pfUI.uf.group[i].target)

    pfUI.uf.group[i].pet = pfUI.uf:CreateUnitFrame("PartyPet", i, C.unitframes.grouppet, 0.2)
    pfUI.uf.group[i].pet:UpdateFrameSize()
    pfUI.uf.group[i].pet:SetPoint("BOTTOMLEFT", pfUI.uf.group[i], "BOTTOMRIGHT", 3*default_border, -default_border)
    UpdateMovable(pfUI.uf.group[i].pet)
  end

  pfUI.uf.partytargetScanner = CreateFrame("Button",nil,UIParent)
  pfUI.uf.partytargetScanner:SetScript("OnUpdate", function()
    for i=1, 4 do
      if UnitExists("party" .. i .. "target") or (pfUI.gitter and pfUI.gitter:IsShown()) then
        pfUI.uf.group[i].target:Show()
      else
        pfUI.uf.group[i].target:Hide()
      end

      if UnitExists("partypet" .. i) or (pfUI.gitter and pfUI.gitter:IsShown()) then
        pfUI.uf.group[i].pet:Show()
      else
        pfUI.uf.group[i].pet:Hide()
      end
    end
  end)

end)
