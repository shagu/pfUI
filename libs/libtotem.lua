-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libtotem ]]--
-- A pfUI library that tries to emulate the TotemAPI that was introduced in Patch 2.4.
-- It detects and saves all current totems of the player and returns information based
-- on the totem slot ID. The function GetTotemInfo is supposed to work as it would
-- on later expansions.
--
--  GetTotemInfo(id)
--    Returns totem informations on the givent totem slot
--    active, name, start, duration, icon

-- return instantly if we're not on a vanilla client
if pfUI.client > 11200 then return end

-- return instantly when another libtotem is already active
if pfUI.api.libtotem then return end

MAX_TOTEMS       = MAX_TOTEMS       or 4
FIRE_TOTEM_SLOT  = FIRE_TOTEM_SLOT  or 1
EARTH_TOTEM_SLOT = EARTH_TOTEM_SLOT or 2
WATER_TOTEM_SLOT = WATER_TOTEM_SLOT or 3
AIR_TOTEM_SLOT   = AIR_TOTEM_SLOT   or 4

local _, class = UnitClass("player")

local libtotem
local queue = { ["slot"] = nil, ["name"] = nil, ["start"] = nil, ["duration"] = nil, ["icon"] = nil }
local active = { [1] = {}, [2] = {}, [3] = {}, [4] = {} }
local totems = {
  [FIRE_TOTEM_SLOT] = {
    --Fire Nova Totem (Fire)
    ["Spell_Fire_SealOfFire"] = {[-1] = 5},
    --Flametongue Totem (Fire)
    ["Spell_Nature_GuardianWard"] = {[-1] = 120},
    --Frost Resistance Totem (Fire)
    ["Spell_FrostResistanceTotem_01"] = {[-1] = 120},
    --Magma Totem (Fire)
    ["Spell_Fire_SelfDestruct"] = {[-1] = 20},
    --Searing Totem (Fire)
    ["Spell_Fire_SearingTotem"] = {[-1] = 55,[1] = 30,[2] = 35,[3] = 40,[4] = 45,[5] = 50,[6] = 55},
  },
  [EARTH_TOTEM_SLOT] = {
    --Earthbind Totem (Earth)
    ["Spell_Nature_StrengthOfEarthTotem02"] = {[-1] = 45},
    --Stoneclaw Totem (Earth)
    ["Spell_Nature_StoneClawTotem"] = {[-1] = 15},
    --Stoneskin Totem (Earth)
    ["Spell_Nature_StoneSkinTotem"] = {[-1] = 120},
    --Strength of Earth Totem (Earth)
    ["Spell_Nature_EarthBindTotem"] = {[-1] = 120},
    --Tremor Totem (Earth)
    ["Spell_Nature_TremorTotem"] = {[-1] = 120},
  },
  [WATER_TOTEM_SLOT] = {
    -- Disease Cleansing Totem (Water)
    ["Spell_Nature_DiseaseCleansingTotem"] = {[-1] = 120},
    --Fire Resistance Totem (Water)
    ["Spell_FireResistanceTotem_01"] = {[-1] = 120},
    --Healing Stream Totem (Water)
    ["INV_Spear_04"] = {[-1] = 60},
    --Mana Spring Totem (Water)
    ["Spell_Nature_ManaRegenTotem"] = {[-1] = 60},
    --Mana Tide Totem (Water)
    ["Spell_Frost_SummonWaterElemental"] = {[-1] = 12},
    --Poison Cleansing Totem (Water)
    ["Spell_Nature_PoisonCleansingTotem"] = {[-1] = 120},
  },
  [AIR_TOTEM_SLOT] = {
    --Grace of Air Totem (Air)
    ["Spell_Nature_InvisibilityTotem"] = {[-1] = 120},
    --Grounding Totem (Air)
    ["Spell_Nature_GroundingTotem"] = {[-1] = 45},
    --Nature Resistance Totem (Air)
    ["Spell_Nature_NatureResistanceTotem"] = {[-1] = 120},
    --Tranquil Air Totem (Air)
    ["Spell_Nature_Brilliance"] = {[-1] = 120},
    --Windfury Totem (Air)
    ["Spell_Nature_Windfury"] = {[-1] = 120},
    --Windwall Totem (Air)
    ["Spell_Nature_EarthBind"] = {[-1] = 120},
  },
}

GetTotemInfo = function(id)
  if not active[id] or not active[id].name then return end
  if active[id].start + active[id].duration - GetTime() < 0 then
    libtotem:Clean(id)
    return nil
  end

  return 1, active[id].name, active[id].start, active[id].duration, active[id].icon
end

if class ~= "SHAMAN" then return end

libtotem = CreateFrame("Frame")
libtotem:RegisterEvent("SPELLCAST_STOP")
libtotem:RegisterEvent("PLAYER_DEAD")
libtotem:SetScript("OnEvent", function()
  if event == "PLAYER_DEAD" then
    for i = 1,4 do
      libtotem:Clean(i)
    end
  elseif event == "SPELLCAST_STOP" then
    if queue.slot and queue.name then
      active[queue.slot].name = queue.name
      active[queue.slot].duration = queue.duration
      active[queue.slot].icon = queue.icon
      active[queue.slot].start = GetTime()
    end

    queue.slot = nil
    queue.name = nil
  end
end)

libtotem.totems = totems

libtotem.Clean = function(self, slot)
  active[slot].name = nil
  active[slot].start = nil
  active[slot].duration = nil
  active[slot].icon = nil
end

libtotem.CheckAddQueue = function(self, name, rank, icon)
  for slot = 1, 4 do
    for texture, data in pairs(totems[slot]) do
      if string.find(icon, texture, 1) then
        if rank then -- try to obtain plain rank number
          _, _, rank = string.find(rank,"%s(%d+)")
        end

        queue.slot = slot
        queue.name = name
        queue.icon = icon
        if rank and tonumber(rank) and data[tonumber(rank)] then
          queue.duration = data[tonumber(rank)]
        else
          queue.duration = data[-1]
        end

        return true
      end
    end
  end

  return nil
end

-- assign library to global space
pfUI.api.libtotem = libtotem

-- Check for totem spell casts
hooksecurefunc("CastSpell", function(id, bookType)
  local name, rank, icon = libspell.GetSpellInfo(id, bookType)
  if not name then return end
  if libtotem:CheckAddQueue(name, rank, icon) then return end
end, true)

hooksecurefunc("CastSpellByName", function(effect, target)
  local name, rank, icon = libspell.GetSpellInfo(effect)
  if not name then return end
  if libtotem:CheckAddQueue(name, rank, icon) then return end
end, true)

local scanner = libtipscan:GetScanner("prediction")
hooksecurefunc("UseAction", function(slot, target, selfcast)
  if GetActionText(slot) or not IsCurrentAction(slot) then return end
  scanner:SetAction(slot)
  local name, rank = scanner:Line(1)
  local icon = GetActionTexture(slot)
  if not name then return end
  if libtotem:CheckAddQueue(name, rank, icon) then return end
end, true)
