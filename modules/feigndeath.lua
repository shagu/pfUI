pfUI:RegisterModule("feigndeath", function ()
  local cache = { }
  local healthscan = CreateFrame("GameTooltip", "pfHpScanner", UIParent, "GameTooltipTemplate")
  healthscan:SetOwner(healthscan,"ANCHOR_NONE")
  local healthbar = healthscan:GetChildren()

  local cache_update = CreateFrame("Frame")
  cache_update:RegisterEvent("UNIT_HEALTH")
  cache_update:RegisterEvent("PLAYER_TARGET_CHANGED")
  cache_update:SetScript("OnEvent", function()
    if event == "PLAYER_TARGET_CHANGED" and UnitIsDead("target") then
      healthscan:SetUnit("target")
      cache[UnitName("target")] = healthbar:GetValue()
    elseif event == "UNIT_HEALTH" and UnitIsDead(arg1) and UnitName(arg1) then
      healthscan:SetUnit(arg1)
      cache[UnitName(arg1)] = healthbar:GetValue()
    elseif event == "UNIT_HEALTH" and UnitName(arg1) then
      cache[UnitName(arg1)] = nil
    end
  end)

  local oldUnitHealth = UnitHealth
  function _G.UnitHealth(arg)
    if UnitIsDead(arg) and cache[UnitName(arg)] then
      return cache[UnitName(arg)]
    else
      return oldUnitHealth(arg)
    end
  end
end)
