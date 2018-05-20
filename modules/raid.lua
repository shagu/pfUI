pfUI:RegisterModule("raid", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  pfUI.uf.raid = CreateFrame("Button","pfRaid",UIParent)

  pfUI.uf.raid.tanksfirst = {
    ["PF_TANK_TOGGLE"] = { T["Toggle as Tank"], "toggleTank" }
  }

  -- no tank order for now, just "all tanks first"
  pfUI.uf.raid.tankrole = { }

  function pfUI.uf.raid:UpdateConfig()
    for i=1, 40 do
      pfUI.uf.raid[i]:UpdateConfig()
    end
  end

  for r=1, 8 do
    for g=1, 5 do
      i = g + 5*(r-1)
      pfUI.uf.raid[i] = pfUI.uf:CreateUnitFrame("Raid", i, C.unitframes.raid)
      pfUI.uf.raid[i]:UpdateFrameSize()

      local spacing = pfUI.uf.raid[i].config.pspace
      local width = pfUI.uf.raid[i].config.width
      local height = pfUI.uf.raid[i].config.height
      local pheight = pfUI.uf.raid[i].config.pheight
      local real_height = height + spacing + pheight + 2*default_border

      pfUI.uf.raid[i]:SetPoint("BOTTOMLEFT", (r-1) * (width+3*default_border) + 5, C.chat.left.height + default_border + 10 + (g-1)*(real_height+3*default_border))
      UpdateMovable(pfUI.uf.raid[i])
    end
  end

  -- add units to the beginning of their groups
  function pfUI.uf.raid:AddUnitToGroup(index, group)
    for subindex = 1, 5 do
      ids = subindex + 5*(group-1)
      if pfUI.uf.raid[ids].id == 0 and pfUI.uf.raid[ids].config.visible == "1" then
        pfUI.uf.raid[ids].id = index
        pfUI.uf.raid[ids]:Show()
        pfUI.uf:RefreshUnit(pfUI.uf.raid[ids], "all")
        break
      end
    end
  end

  function pfUI.uf.raid:RaidSetup()
    for i=1, 40 do
      pfUI.uf.raid[i].id = 0
      pfUI.uf.raid[i]:Hide()
    end

    -- sort tanks into their groups
    for i=1, GetNumRaidMembers() do
      local name, _, subgroup  = GetRaidRosterInfo(i)
      if name and pfUI.uf.raid.tankrole[name] then
        pfUI.uf.raid:AddUnitToGroup(i, subgroup)
      end
    end

    -- sort players into roster
    for i=1, GetNumRaidMembers() do
      local name, _, subgroup  = GetRaidRosterInfo(i)
      if name and not pfUI.uf.raid.tankrole[name] then
        pfUI.uf.raid:AddUnitToGroup(i, subgroup)
      end
    end
  end

  pfUI.uf.raid:Hide()
  pfUI.uf.raid:RegisterEvent("RAID_ROSTER_UPDATE")
  pfUI.uf.raid:RegisterEvent("VARIABLES_LOADED")
  pfUI.uf.raid:SetScript("OnEvent", function() pfUI.uf.raid:RaidSetup() end)

  -- raid popup option to toggle tank role
  local iupm = table.getn(UnitPopupMenus["RAID"])
  for label, data in pairs(pfUI.uf.raid.tanksfirst) do
    UnitPopupButtons[label] = { text = TEXT(data[1]), dist = 0 }
    table.insert(UnitPopupMenus["RAID"], iupm-1, label)
  end

  hooksecurefunc("UnitPopup_OnClick", function()
    local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU)
    local button = this.value
    local unit = dropdownFrame.unit
    local name = dropdownFrame.name

    if button and pfUI.uf.raid.tanksfirst[button] and name then
      pfUI.uf.raid.tankrole[name] = not pfUI.uf.raid.tankrole[name]
      pfUI.uf.raid:RaidSetup()
    end
  end)
end)
