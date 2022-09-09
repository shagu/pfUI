pfUI:RegisterModule("energytick", "vanilla:tbc", function ()
  if not pfUI.uf or not pfUI.uf.player then return end

  local energytick = CreateFrame("Frame", nil, pfUI.uf.player.power.bar)
  energytick:SetAllPoints(pfUI.uf.player.power.bar)
  energytick:RegisterEvent("PLAYER_ENTERING_WORLD")
  energytick:RegisterEvent("UNIT_DISPLAYPOWER")
  energytick:RegisterEvent("UNIT_ENERGY")
  energytick:RegisterEvent("UNIT_MANA")
  energytick:SetScript("OnEvent", function()
    if UnitPowerType("player") == 0 and C.unitframes.player.manatick == "1" then
      this.mode = "MANA"
      this:Show()
    elseif UnitPowerType("player") == 3 and C.unitframes.player.energy == "1" then
      this.mode = "ENERGY"
      this:Show()
    else
      this:Hide()
    end

    if event == "PLAYER_ENTERING_WORLD" then
      this.lastMana = UnitMana("player")
    end

    if (event == "UNIT_MANA" or event == "UNIT_ENERGY") and arg1 == "player" then
      this.currentMana = UnitMana("player")
      local diff = 0
      if this.lastMana then
        diff = this.currentMana - this.lastMana
      end

      if this.mode == "MANA" and diff < 0 then
        this.target = 5
      elseif this.mode == "MANA" and diff > 0 then
        if this.max ~= 5 and diff > (this.badtick and this.badtick*1.2 or 5) then
          this.target = 2
        else
          this.badtick = diff
        end
      elseif this.mode == "ENERGY" and diff > 0 then
        this.target = 2
      end
      this.lastMana = this.currentMana
    end
  end)

  energytick:SetScript("OnUpdate", function()
    if this.target then
      this.start, this.max = GetTime(), this.target
      this.target = nil
    end

    if not this.start then return end

    this.current = GetTime() - this.start

    if this.current > this.max then
      this.start, this.max, this.current = GetTime(), 2, 0
    end

    local pos = (C.unitframes.player.pwidth ~= "-1" and C.unitframes.player.pwidth or C.unitframes.player.width) * (this.current / this.max)
    if not C.unitframes.player.pheight then return end
    this.spark:SetPoint("LEFT", pos-((C.unitframes.player.pheight+5)/2), 0)
  end)

  energytick.spark = energytick:CreateTexture(nil, 'OVERLAY')
  energytick.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  energytick.spark:SetHeight(C.unitframes.player.pheight + 15)
  energytick.spark:SetWidth(C.unitframes.player.pheight + 5)
  energytick.spark:SetBlendMode('ADD')

  -- update spark size on player frame changes
  local hookUpdateConfig = pfUI.uf.player.UpdateConfig
  function pfUI.uf.player.UpdateConfig()
    -- update spark sizes
    energytick.spark:SetHeight(C.unitframes.player.pheight + 15)
    energytick.spark:SetWidth(C.unitframes.player.pheight + 5)

    -- run default unitframe update function
    hookUpdateConfig(pfUI.uf.player)
  end
end)
