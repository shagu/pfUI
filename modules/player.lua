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

  pfUI.uf.player.pvpicon = CreateFrame("Frame", nil, pfUI.uf.player)
  pfUI.uf.player.pvpicon:Hide()
  pfUI.uf.player.pvpicon:RegisterEvent("UPDATE_FACTION")
  pfUI.uf.player.pvpicon:RegisterEvent("UNIT_FACTION")
  pfUI.uf.player.pvpicon:SetFrameStrata("HIGH")
  pfUI.uf.player.pvpicon:SetWidth(16)
  pfUI.uf.player.pvpicon:SetHeight(16)
  pfUI.uf.player.pvpicon:SetAlpha(.25)
  pfUI.uf.player.pvpicon:SetParent(pfUI.uf.player.hp.bar)
  pfUI.uf.player.pvpicon:SetPoint("TOP", pfUI.uf.player.hp.bar, "TOP", 0, -5)
  pfUI.uf.player.pvpicon.texture = pfUI.uf.player.pvpicon:CreateTexture(nil,"DIALOG")
  pfUI.uf.player.pvpicon.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\pvp")
  pfUI.uf.player.pvpicon.texture:SetAllPoints(pfUI.uf.player.pvpicon)

  pfUI.uf.player.pvpicon:SetScript("OnEvent", function()
    if C.unitframes.player.showPVP == "1" and UnitIsPVP("player") then
      pfUI.uf.player.pvpicon:Show()
    else
      pfUI.uf.player.pvpicon:Hide()
    end
  end)

  pfUI.uf.player:UpdateFrameSize()
  pfUI.uf.player:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -75, 125)
  UpdateMovable(pfUI.uf.player)

  pfUI.uf.player.dropdown = {}
  function pfUI.uf.player.dropdown:Init()
    UnitPopup_ShowMenu(PlayerFrameDropDown, "SELF", "player")
    if pfUI.uf.player.dropdown.rebuild and not CanShowResetInstances() then
      UIDropDownMenu_AddButton({text = RESET_INSTANCES, func = ResetInstances, notCheckable = 1}, 1)
      pfUI.uf.player.dropdown.rebuild = nil
    end
  end

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
