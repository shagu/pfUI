-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

-- return instantly when another libspell is already active
if pfUI.api.libspell then return end

local scanner = libtipscan:GetScanner("libspell")
local libspell = {}

-- [ GetSpellMaxRank ]
-- Returns the maximum rank of a players spell.
-- 'name'       [string]            spellname to query
-- return:      [string],[number]   maximum rank in characters and the number
--                                  e.g "Rank 1" and "1"
local spellmaxrank = {}
function libspell.GetSpellMaxRank(name)
  local cache = spellmaxrank[name]
  if cache then return cache[1], cache[2] end
  local name = string.lower(name)

  local rank = { 0, nil}
  for i = 1, GetNumSpellTabs() do
    local _, _, offset, num = GetSpellTabInfo(i)
    local bookType = BOOKTYPE_SPELL
    for id = offset + 1, offset + num do
      local spellName, spellRank = GetSpellName(id, bookType)
      if name == string.lower(spellName) then
        if not rank[2] then rank[2] = spellRank end

        local _, _, numRank = string.find(spellRank, " (%d+)$")
        if numRank and tonumber(numRank) > rank[1] then
          rank = { tonumber(numRank), spellRank}
        end
      end
    end
  end

  spellmaxrank[name] = { rank[2], rank[1] }
  return rank[2], rank[1]
end

-- [ GetSpellIndex ]
-- Returns the spellbook index and bookid of the given spell.
-- 'name'       [string]            spellname to query
-- 'rank'       [string]            rank to query (optional)
-- return:      [number],[string]   spell index and spellbook id
local spellindex = {}
function libspell.GetSpellIndex(name, rank)
  if not name then return end
  name = string.lower(name)
  local cache = spellindex[name..(rank and ("("..rank..")") or "")]
  if cache then return cache[1], cache[2] end

  if not rank then rank = libspell.GetSpellMaxRank(name) end

  for i = 1, GetNumSpellTabs() do
    local _, _, offset, num = GetSpellTabInfo(i)
    local bookType = BOOKTYPE_SPELL
    for id = offset + 1, offset + num do
      local spellName, spellRank = GetSpellName(id, bookType)
      if rank and rank == spellRank and name == string.lower(spellName) then
        spellindex[name.."("..rank..")"] = { id, bookType }
        return id, bookType
      elseif not rank and name == string.lower(spellName) then
        spellindex[name] = { id, bookType }
        return id, bookType
      end
    end
  end

  spellindex[name..(rank and ("("..rank..")") or "")] = { nil }
  return nil
end

-- [ GetSpellInfo ]
-- Returns several information about a spell.
-- 'index'      [string/number]     Spellname or Index of a spell in the spellbook
-- 'bookType'   [string]            Type of spellbook (optional)
-- return:
--              [string]            Name of the spell
--              [string]            Secondary text associated with the spell
--                                  (e.g."Rank 5", "Racial", etc.)
--              [string]            Path to an icon texture for the spell
--              [number]            Casting time of the spell in milliseconds
--              [number]            Minimum range from the target required to cast the spell
--              [number]            Maximum range from the target at which you can cast the spell
--              [number]            The numeric spell-id of the spell
--              [number]            The type of the spellbook that the spell is in
local spellinfo = {}
function libspell.GetSpellInfo(index, bookType)
  local cache = spellinfo[index]
  if cache then return cache[1], cache[2], cache[3], cache[4], cache[5], cache[6], cache[7], cache[8] end

  local name, rank, id
  local icon = ""
  local castingTime = 0
  local minRange = 0
  local maxRange = 0

  if type(index) == "string" then
    local _, _, sname, srank = string.find(index, '(.+)%((.+)%)')
    name = sname or index
    rank = srank or libspell.GetSpellMaxRank(name)
    id, bookType = libspell.GetSpellIndex(name, rank)

    -- correct name in case of wrong upper/lower cases
    if id and bookType then
      name = GetSpellName(id, bookType)
    end
  else
    name, rank = GetSpellName(index, bookType)
    id, bookType = libspell.GetSpellIndex(name, rank)
  end

  if name and id then
    icon = GetSpellTexture(id, bookType)
  end

  if id then
    scanner:SetSpell(id, bookType)
    local _, sec = scanner:Find(gsub(SPELL_CAST_TIME_SEC, "%%.3g", "%(.+%)"), false)
    local _, min = scanner:Find(gsub(SPELL_CAST_TIME_MIN, "%%.3g", "%(.+%)"), false)
    local _, range = scanner:Find(gsub(SPELL_RANGE, "%%s", "%(.+%)"), false)

    castingTime = (tonumber(sec) or tonumber(min) or 0) * 1000
    if range then
      local _, _, min, max = string.find(range, "(.+)-(.+)")
      if min and max then
        minRange = tonumber(min)
        maxRange = tonumber(max)
      else
        minRange = 0
        maxRange = tonumber(range)
      end
    end
  end

  spellinfo[index] = { name, rank, icon, castingTime, minRange, maxRange, id, bookType }
  return name, rank, icon, castingTime, minRange, maxRange, id, bookType
end

-- Reset all spell caches whenever new spells are learned/unlearned
local resetcache = CreateFrame("Frame")
resetcache:RegisterEvent("LEARNED_SPELL_IN_TAB")
resetcache:SetScript("OnEvent", function()
  spellmaxrank, spellindex, spellinfo = {}, {}, {}
end)

-- add libspell to pfUI API
pfUI.api.libspell = libspell
