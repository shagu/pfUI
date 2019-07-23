pfUI:RegisterModule("feigndeath", "vanilla:tbc", function ()
  local cache = { }
  local scanner = libtipscan:GetScanner("feigndeath")
  local healthbar = scanner:GetChildren()

  local cache_update = CreateFrame("Frame")
  cache_update:RegisterEvent("UNIT_HEALTH")
  cache_update:RegisterEvent("PLAYER_TARGET_CHANGED")
  cache_update:SetScript("OnEvent", function()
    if event == "PLAYER_TARGET_CHANGED" and UnitIsDead("target") then
      scanner:SetUnit("target")
      cache[UnitName("target")] = healthbar:GetValue()
    elseif event == "UNIT_HEALTH" and UnitIsDead(arg1) and UnitName(arg1) then
      scanner:SetUnit(arg1)
      cache[UnitName(arg1)] = healthbar:GetValue()
    elseif event == "UNIT_HEALTH" and UnitName(arg1) then
      cache[UnitName(arg1)] = nil
    end
  end)

  local oldUnitHealth = UnitHealth
  function UnitHealth(arg)
    if UnitIsDead(arg) and cache[UnitName(arg)] then
      return cache[UnitName(arg)]
    else
      return oldUnitHealth(arg)
    end
  end
end)
