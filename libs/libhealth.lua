-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

if pfUI.libhealth then return end

local mobdb = {}
local target, dmg, perc, diff = nil, 0, 0, 0, 0
local UnitHealth, UnitHealthMax
local libhealth = CreateFrame("Frame")
libhealth.enabled = true
libhealth.reqhit = 4
libhealth.reqdmg = 5
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
    libhealth.enabled = pfUI_config["global"]["libhealth"] == "1" and true or nil
    libhealth.reqhit = (tonumber(pfUI_config["global"]["libhealth_hit"]) or 4)
    libhealth.reqdmg = (tonumber(pfUI_config["global"]["libhealth_dmg"]) or 0.5) * 100
  end

  -- return as we're not supposed to be here
  if not libhealth.enabled then this:UnregisterAllEvents() return end

  -- try to estimate mob health based on combat and health events
  if event == "PLAYER_TARGET_CHANGED" then
    dmg, perc = 0, _G.UnitHealth("target")
    if UnitName("target") and UnitLevel("target") and _G.UnitHealthMax("target") == 100 then
      target = string.format("%s:%d",UnitName("target"), UnitLevel("target"))
    else
      target = nil
    end
  elseif target and event == "UNIT_COMBAT" and arg1 == "target" then
    if arg2 and arg2 == "HEAL" then return end
    dmg = dmg + arg4
  elseif target and event == "UNIT_HEALTH" and arg1 == "target" then
    diff = perc-_G.UnitHealth("target")
    if dmg > 0 and diff > 0 then
      mobdb[target] = mobdb[target] or {}
      if not mobdb[target][2] or diff > mobdb[target][2] then
        mobdb[target][1] = ceil(dmg / diff * 100)
        mobdb[target][2] = diff
        mobdb[target][3] = mobdb[target][3] and mobdb[target][3] + 1 or 1
      end
    end
  end
end)

-- core function to query the generated database
local unit, level, cur, max, dbstring
local function GetUnitHealth(self, unitstr)
  unit = UnitName(unitstr)
  level = UnitLevel(unitstr)
  cur = _G.UnitHealth(unitstr)
  max = _G.UnitHealthMax(unitstr)

  -- return raw values if another addon is replacing global API calls
  if cur > 100 or max > 100 or max < 100 then
    return cur, max, true
  end

  -- return raw values if no unit data could be found (unlikely but happened...)
  if not unit or not level then
    return cur, max
  end

  -- query the database for known values
  dbstring = string.format("%s:%s", unit, level)
  if mobdb[dbstring] and mobdb[dbstring][1] and mobdb[dbstring][2] > libhealth.reqdmg and (not mobdb[dbstring][3] or mobdb[dbstring][3] > libhealth.reqhit) then
    return ceil(mobdb[dbstring][1]/100*cur), mobdb[dbstring][1], true
  end

  -- return raw values as fallback
  return cur, max
end

local function GetUnitHealthByName(self, unit, level, cur, max)
  -- return raw values if another addon is replacing global API calls
  if cur > 100 or max > 100 or max < 100 then
    return cur, max, true
  end

  -- return raw values if no unit data could be found (unlikely but happened...)
  if not unit or not level then
    return cur, max
  end

  -- query the database for known values
  dbstring = string.format("%s:%s", unit, level)
  if mobdb[dbstring] and mobdb[dbstring][1] and mobdb[dbstring][2] > libhealth.reqdmg and (not mobdb[dbstring][3] or mobdb[dbstring][3] > libhealth.reqhit) then
    return ceil(mobdb[dbstring][1]/100*cur), mobdb[dbstring][1], true
  end

  -- return raw values as fallback
  return cur, max
end

-- add api calls to global tree
pfUI.libhealth = libhealth
pfUI.libhealth.GetUnitHealth = GetUnitHealth
pfUI.libhealth.GetUnitHealthByName = GetUnitHealthByName
