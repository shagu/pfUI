pfUI:RegisterModule("raid", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.raidframes ~= "-1" then
    default_border = C.appearance.border.raidframes
  end

  pfUI.uf.raid = CreateFrame("Button","pfRaid",UIParent)
  pfUI.uf.raid:Hide()

  pfUI.uf.raid:RegisterEvent("RAID_ROSTER_UPDATE")
  pfUI.uf.raid:RegisterEvent("VARIABLES_LOADED")
  pfUI.uf.raid:SetScript("OnEvent", function()
    for i=1, 40 do
      pfUI.uf.raid[i].label = "raid"
      pfUI.uf.raid[i].id = 0
      pfUI.uf.raid[i]:Hide()
    end

    -- sort players into roster
    for i=1, GetNumRaidMembers() do
      local name, _, subgroup  = GetRaidRosterInfo(i)
      if name then
        for subindex = 1, 5 do
          ids = subindex + 5*(subgroup-1)
          if pfUI.uf.raid[ids].id == 0 then
            pfUI.uf.raid[ids].id = i
            pfUI.uf.raid[ids]:Show()
            pfUI.uf:RefreshUnit(pfUI.uf.raid[ids])
            break
          end
        end
      end
    end
  end)

  for r=1, 8 do
    for g=1, 5 do
      i = g + 5*(r-1)
      pfUI.uf.raid[i] = CreateFrame("Button","pfRaid" .. i,UIParent)

      pfUI.uf.raid[i]:SetWidth(50)
      pfUI.uf.raid[i]:SetHeight(30 + 2*default_border + C.unitframes.raid.pspace)
      pfUI.uf.raid[i]:SetPoint("BOTTOMLEFT", (r-1) * (54+default_border) + 5, C.chat.left.height + 10 + ((g-1)*(37+default_border))+default_border)
      UpdateMovable(pfUI.uf.raid[i])
      pfUI.uf.raid[i]:Hide()
      pfUI.uf.raid[i].id = 0

      pfUI.uf.raid[i].hp = CreateFrame("Frame",nil, pfUI.uf.raid[i])
      pfUI.uf.raid[i].hp:SetPoint("TOP", 0, 0)
      pfUI.uf.raid[i].hp:SetWidth(50)
      pfUI.uf.raid[i].hp:SetHeight(27)
      CreateBackdrop(pfUI.uf.raid[i].hp, default_border)

      pfUI.uf.raid[i].hp.bar = CreateFrame("StatusBar", nil, pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.uf.raid[i].hp.bar:SetAllPoints(pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.bar:SetMinMaxValues(0, 100)

      if C.unitframes.custombg == "1" then
        local cr, cg, cb, ca = strsplit(",", C.unitframes.custombgcolor)
        cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
        pfUI.uf.raid[i].hp.bar.texture = pfUI.uf.raid[i].hp.bar:CreateTexture(nil,"BACKGROUND")
        pfUI.uf.raid[i].hp.bar.texture:SetTexture(cr,cg,cb,ca)
        pfUI.uf.raid[i].hp.bar.texture:SetAllPoints(pfUI.uf.raid[i].hp.bar)
      end

      pfUI.uf.raid[i].power = CreateFrame("Frame",nil, pfUI.uf.raid[i])
      pfUI.uf.raid[i].power:SetPoint("BOTTOM", 0, 0)
      pfUI.uf.raid[i].power:SetWidth(50)
      pfUI.uf.raid[i].power:SetHeight(3)
      CreateBackdrop(pfUI.uf.raid[i].power, default_border)

      pfUI.uf.raid[i].power.bar = CreateFrame("StatusBar", nil, pfUI.uf.raid[i].power)
      pfUI.uf.raid[i].power.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.uf.raid[i].power.bar:SetAllPoints(pfUI.uf.raid[i].power)
      pfUI.uf.raid[i].power.bar:SetMinMaxValues(0, 100)

      pfUI.uf.raid[i].caption = pfUI.uf.raid[i]:CreateFontString("Status", "HIGH", "GameFontNormal")
      pfUI.uf.raid[i].caption:SetFont(pfUI.font_square, C.global.font_size, "OUTLINE")
      pfUI.uf.raid[i].caption:SetAllPoints(pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].caption:ClearAllPoints()
      pfUI.uf.raid[i].caption:SetParent(pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].caption:SetPoint("CENTER",pfUI.uf.raid[i].hp.bar, "CENTER", 0, 0)
      pfUI.uf.raid[i].caption:SetJustifyH("CENTER")
      pfUI.uf.raid[i].caption:SetFontObject(GameFontWhite)

      pfUI.uf.raid[i].hp.leaderIcon = CreateFrame("Frame",nil,pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.leaderIcon:SetWidth(10)
      pfUI.uf.raid[i].hp.leaderIcon:SetHeight(10)
      pfUI.uf.raid[i].hp.leaderIcon.texture = pfUI.uf.raid[i].hp.leaderIcon:CreateTexture(nil,"BACKGROUND")
      pfUI.uf.raid[i].hp.leaderIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Raid-LeaderIcon")
      pfUI.uf.raid[i].hp.leaderIcon.texture:SetAllPoints(pfUI.uf.raid[i].hp.leaderIcon)
      pfUI.uf.raid[i].hp.leaderIcon:SetPoint("TOPLEFT", pfUI.uf.raid[i].hp, "TOPLEFT", -4, 4)
      pfUI.uf.raid[i].hp.leaderIcon:Hide()

      pfUI.uf.raid[i].hp.lootIcon = CreateFrame("Frame",nil,pfUI.uf.raid[i].hp)
      pfUI.uf.raid[i].hp.lootIcon:SetWidth(10)
      pfUI.uf.raid[i].hp.lootIcon:SetHeight(10)
      pfUI.uf.raid[i].hp.lootIcon.texture = pfUI.uf.raid[i].hp.lootIcon:CreateTexture(nil,"BACKGROUND")
      pfUI.uf.raid[i].hp.lootIcon.texture:SetTexture("Interface\\GROUPFRAME\\UI-Raid-MasterLooter")
      pfUI.uf.raid[i].hp.lootIcon.texture:SetAllPoints(pfUI.uf.raid[i].hp.lootIcon)
      pfUI.uf.raid[i].hp.lootIcon:SetPoint("TOPLEFT", pfUI.uf.raid[i].hp, "LEFT", -4, 4)
      pfUI.uf.raid[i].hp.lootIcon:Hide()

      pfUI.uf.raid[i].hp.raidIcon = CreateFrame("Frame",nil,pfUI.uf.raid[i].hp.bar)
      pfUI.uf.raid[i].hp.raidIcon:SetWidth(24)
      pfUI.uf.raid[i].hp.raidIcon:SetHeight(24)
      pfUI.uf.raid[i].hp.raidIcon.texture = pfUI.uf.raid[i].hp.raidIcon:CreateTexture(nil,"ARTWORK")
      pfUI.uf.raid[i].hp.raidIcon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\raidicons")
      pfUI.uf.raid[i].hp.raidIcon.texture:SetAllPoints(pfUI.uf.raid[i].hp.raidIcon)
      pfUI.uf.raid[i].hp.raidIcon:SetPoint("TOP", pfUI.uf.raid[i].hp, "TOP", -4, 4)
      pfUI.uf.raid[i].hp.raidIcon:Hide()

      pfUI.uf.raid[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonUp', 'Button4Up', 'Button5Up')

      pfUI.uf:CreateUnit(pfUI.uf.raid[i])
    end
  end
end)
