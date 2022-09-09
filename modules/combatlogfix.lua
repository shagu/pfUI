pfUI:RegisterModule("combatlogfix", "tbc", function ()
  -- Fixes the combatlog break bugs that exist since patch 2.4 by simply clearing the whole log
  -- on every update. This is required in order to receive new log events. Otherwise, addons like
  -- Omen or Recount won't work and simply don't receive any new data at a given time.
  local combatlog = CreateFrame("Frame", "pfCombatLogFix", UIParent)
  combatlog:SetScript("OnUpdate", CombatLogClearEntries)
end)
