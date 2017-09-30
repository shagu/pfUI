pfUI:RegisterModule("group", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.group.pspace

  -- hide blizzard group frames
  for i=1, 4 do
    if _G["PartyMemberFrame" .. i] then
      _G["PartyMemberFrame" .. i]:Hide()
      _G["PartyMemberFrame" .. i].Show = function () return end
    end
  end

  pfUI.uf.group = {}

  local startid = C.unitframes.selfingroup == "1" and 0 or 1

  for i=startid, 4 do
    pfUI.uf.group[i] = pfUI.uf:CreateUnitFrame("Party", i, C.unitframes.group)
    pfUI.uf.group[i]:UpdateFrameSize()
    pfUI.uf.group[i]:SetPoint("TOPLEFT", 5, -5 - ((i-startid)*75))
    UpdateMovable(pfUI.uf.group[i])

    if C.unitframes.grouptarget.visible == "1" then
      pfUI.uf.group[i].target = pfUI.uf:CreateUnitFrame("Party" .. i .. "Target", nil, C.unitframes.grouptarget, 0.2)
      pfUI.uf.group[i].target:UpdateFrameSize()
      pfUI.uf.group[i].target:SetPoint("TOPLEFT", pfUI.uf.group[i], "TOPRIGHT", 3*default_border, 0)
      UpdateMovable(pfUI.uf.group[i].target)
    end

    if C.unitframes.grouppet.visible == "1" then
      pfUI.uf.group[i].pet = pfUI.uf:CreateUnitFrame("PartyPet", i, C.unitframes.grouppet, 0.5)
      pfUI.uf.group[i].pet:UpdateFrameSize()
      pfUI.uf.group[i].pet:SetPoint("BOTTOMLEFT", pfUI.uf.group[i], "BOTTOMRIGHT", 3*default_border, -default_border)
      UpdateMovable(pfUI.uf.group[i].pet)
    end
  end

  -- scan for group targets
  if C.unitframes.grouptarget.visible == "1" then
    pfUI.uf.groupscanner = CreateFrame("Frame", nil, UIParent)
    pfUI.uf.groupscanner:SetScript("OnUpdate", function()
      if ( this.limit or 1) > GetTime() then return else this.limit = GetTime() + .2 end
      for i=1, 4 do
        if UnitExists("party" .. i .. "target") or (pfUI.unlock and pfUI.unlock:IsShown()) then
          pfUI.uf.group[i].target:Show()
        else
          pfUI.uf.group[i].target:Hide()
        end
      end
    end)
  end
end)
