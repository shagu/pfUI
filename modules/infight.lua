pfUI:RegisterModule("infight", "vanilla:tbc", function ()
  local function OnUpdate()
    if not this.infight and not this.aggro and not this.health then return end
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

    if not this.fadeValue then  this.fadeValue = 1 end
    if this.fadeValue >= 0.3 then
      this.fadeModifier = -0.1
    end
    if this.fadeValue <= 0 then
      this.fadeModifier = 0.1
    end
    this.fadeValue = this.fadeValue + this.fadeModifier

    local visible = nil
    if this.infight and UnitAffectingCombat("player") then visible = true end
    if this.aggro and UnitHasAggro("player") > 0 then visible = true end
    if this.health and UnitHealth("player")/UnitHealthMax("player")*100 <= 25 then visible = true end
    if UnitIsDeadOrGhost("player") then visible = nil end

    if visible then
      this.screen:Show()
      this.screen:SetBackdropBorderColor(1,0.2+this.fadeValue, this.fadeValue, 1-this.fadeValue)
    else
      this.screen:Hide()
    end
  end

  pfUI.infight = CreateFrame("Frame", "pfUICombat", UIParent)
  pfUI.infight:SetScript("OnUpdate", OnUpdate)

  pfUI.infight.screen = CreateFrame("Frame", "pfUICombatScreen", WorldFrame)
  pfUI.infight.screen:SetAllPoints(WorldFrame)
  pfUI.infight.screen:Hide()

  pfUI.infight.UpdateConfig = function(self)
    pfUI.infight.infight = C.appearance.infight.screen == "1" and true or nil
    pfUI.infight.aggro = C.appearance.infight.aggro == "1" and true or nil
    pfUI.infight.health = C.appearance.infight.health == "1" and true or nil

    pfUI.infight.screen:SetBackdrop({
      edgeFile = pfUI.media["img:glow"], edgeSize = tonumber(C.appearance.infight.intensity),
      insets = {left = 0, right = 0, top = 0, bottom = 0},
    })

    pfUI.infight.screen:Hide()
  end

  pfUI.infight.UpdateConfig()
end)
