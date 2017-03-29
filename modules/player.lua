pfUI:RegisterModule("player", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local spacing = C.unitframes.player.pspace

  PlayerFrame:Hide()
  PlayerFrame:UnregisterAllEvents()

  pfUI.uf.player = pfUI.uf:CreateUnitFrame("Player", nil, C.unitframes.player)
  pfUI.uf.player:UpdateFrameSize()
  pfUI.uf.player:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -75, 125)
  UpdateMovable(pfUI.uf.player)

  pfUI.uf.player.Dropdown = getglobal("PlayerFrameDropDown")
  function pfUI.uf.player.Dropdowni()
    -- add reset button when alone
    if not (UnitInRaid("player") or GetNumPartyMembers() > 0) then
      UIDropDownMenu_AddButton({text = "Reset Instances", func = ResetInstances, notCheckable = 1}, 1)
    end
    UnitPopup_ShowMenu(pfUI.uf.player.Dropdown, "SELF", "player")
  end
  UIDropDownMenu_Initialize(pfUI.uf.player.Dropdown, pfUI.uf.player.Dropdowni, "MENU")

  pfUI.uf.player:RegisterEvent("UPDATE_FACTION") -- pvp icon
  pfUI.uf.player:RegisterEvent("UNIT_FACTION") -- pvp icon

  if C.unitframes.player.energy == "1" then
    pfUI.uf.player.power.tick = CreateFrame("Frame", nil, pfUI.uf.player.power.bar)
    pfUI.uf.player.power.tick:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.uf.player.power.tick:RegisterEvent("UNIT_DISPLAYPOWER")

    pfUI.uf.player.power.tick:SetScript("OnEvent", function()
      if event == "PLAYER_ENTERING_WORLD" then this.lastTick = GetTime() end
      if event == "PLAYER_ENTERING_WORLD" or ( event == "UNIT_DISPLAYPOWER" and arg1 == "player" ) then
        if UnitPowerType("player") ~= 3 then
          this.spark:Hide()
        else
          this.spark:Show()
        end
      end
    end)

    pfUI.uf.player.power.tick.spark = pfUI.uf.player.power.bar:CreateTexture(nil, 'OVERLAY')
    pfUI.uf.player.power.tick.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    pfUI.uf.player.power.tick.spark:SetHeight(C.unitframes.player.pheight + 15)
    pfUI.uf.player.power.tick.spark:SetWidth(C.unitframes.player.pheight + 5)
    pfUI.uf.player.power.tick.spark:SetBlendMode('ADD')

    pfUI.uf.player.power.tick:SetScript("OnUpdate", function()
      if not this.energy then this.energy = UnitMana("player") end

      if(UnitMana("player") > this.energy or GetTime() >= this.lastTick + 2) then
        this.lastTick = GetTime()
      end

      this.energy = UnitMana("player")

      local value = round((GetTime() - this.lastTick) * 100)
      local pos = C.unitframes.player.width / 200 * value
      if not C.unitframes.player.pheight then return end
      this.spark:SetPoint("LEFT", pos-((C.unitframes.player.pheight+5)/2), 0)
    end)
  end
end)
