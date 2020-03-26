-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

local mobdb, enabled = {}, true
local target, dmg, perc, diff = nil, 0, 0, 0, 0
local UnitHealth, UnitHealthMax
local libhealth = CreateFrame("Frame")
libhealth:RegisterEvent("UNIT_HEALTH")
libhealth:RegisterEvent("UNIT_COMBAT")
libhealth:RegisterEvent("PLAYER_TARGET_CHANGED")
libhealth:RegisterEvent("PLAYER_ENTERING_WORLD")
libhealth:SetScript("OnEvent", function()
  if event == "PLAYER_ENTERING_WORLD" then
    -- create initial health cache tables
    pfUI_cache["libhealth"] = pfUI_cache["libhealth"] or {}
    mobdb = pfUI_cache["libhealth"]

    -- load enable state and set functions
    enabled = pfUI_config["global"]["libhealth"] == "1" and true or nil
    pfUI.api.UnitHealth = enabled and UnitHealth or nil
    pfUI.api.UnitHealthMax = enabled and UnitHealthMax or nil
  end

  -- return as we're not supposed to be here
  if not enabled then this:UnregisterAllEvents() return end

  -- try to estimate mob health based on combat and health events
  if event == "PLAYER_TARGET_CHANGED" then
    dmg, perc = 0, _G.UnitHealth("target")
    if UnitName("target") and UnitLevel("target") and _G.UnitHealthMax("target") == 100 then
      target = string.format("%s:%d",UnitName("target"), UnitLevel("target"))
    else
      target = nil
    end
  elseif target and event == "UNIT_COMBAT" and arg1 == "target" then
    dmg = dmg + arg4
  elseif target and event == "UNIT_HEALTH" and arg1 == "target" then
    diff = perc-_G.UnitHealth("target")
    if dmg > 0 and diff > 0 then
      mobdb[target] = mobdb[target] or {}
      if not mobdb[target][2] or diff > mobdb[target][2] then
        mobdb[target][1] = ceil(dmg / diff * 100)
        mobdb[target][2] = diff
      end
    end
  end
end)

-- core function to query the generated database
local unit, level, cur, max, dbstring
local function GetHealthPairs(unitstr)
  unit = UnitName(unitstr)
  level = UnitLevel(unitstr)
  cur = _G.UnitHealth(unitstr)
  max = _G.UnitHealthMax(unitstr)

  if unit and level and max == 100 then
    dbstring = string.format("%s:%s", unit, level)
    if mobdb[dbstring] and mobdb[dbstring][1] and mobdb[dbstring][2] > 5 then
      return ceil(mobdb[dbstring][1]/100*cur), mobdb[dbstring][1]
    end
  end

  return nil
end

-- functions to overwrite the default health api with estimated values
pfUI.api.UnitHealth = function(unitstr)
  cur, max = GetHealthPairs(unitstr)
  return cur or _G.UnitHealth(unitstr)
end

pfUI.api.UnitHealthMax = function(unitstr)
  cur, max = GetHealthPairs(unitstr)
  return max or _G.UnitHealthMax(unitstr)
end
