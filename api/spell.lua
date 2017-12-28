-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

local pfSpellScan = CreateFrame("GameTooltip", "pfSpellScan", UIParent, "GameTooltipTemplate")
pfSpellScan:SetOwner(WorldFrame, "ANCHOR_NONE")

-- [ GetSpellMaxRank ]
-- Returns the maximum rank of a players spell.
-- 'name'       [string]            spellname to query
-- return:      [string],[number]   maximum rank in characters and the number
--                                  e.g "Rank 1" and "1"
local spellmaxrank = {}
function pfUI.api.GetSpellMaxRank(name)
  if spellmaxrank[name] then return unpack(spellmaxrank[name]) end

  local rank = { 0, nil}
  for i = 1, GetNumSpellTabs() do
    local _, _, offset, num = GetSpellTabInfo(i)
    local bookType = BOOKTYPE_SPELL
    for id = offset + 1, offset + num do
      local spellName, spellRank = GetSpellName(id, bookType)
      if spellName == name then
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
function pfUI.api.GetSpellIndex(name, rank)
  if spellindex[name..(rank or "")] then return unpack(spellindex[name..(rank or "")]) end
  if not rank then rank = GetSpellMaxRank(name) end

  for i = 1, GetNumSpellTabs() do
    local _, _, offset, num = GetSpellTabInfo(i)
    local bookType = BOOKTYPE_SPELL
    for id = offset + 1, offset + num do
      local spellName, spellRank = GetSpellName(id, bookType)
      if rank and rank == spellRank and name == spellName then
        spellindex[name..rank] = { id, bookType }
        return id, bookType
      elseif not rank and name == spellName then
        spellindex[name] = { id, bookType }
        return id, bookType
      end
    end
  end
  spellindex[name..(rank or "")] = { nil }
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
local spellinfo = {}
function pfUI.api.GetSpellInfo(index, bookType)
  if spellinfo[index] then return unpack(spellinfo[index]) end

  local name, rank
  local icon = ""
  local castingTime = 0
  local minRange = 0
  local maxRange = 0

  if type(index) == "string" then
    local _, _, sname, srank = string.find(index, '(.+)%((.+)%)')
    name = sname or index
    rank = srank or GetSpellMaxRank(name)
    index, bookType = GetSpellIndex(name, rank)
  else
    name, rank = GetSpellName(index, bookType)
  end

  if name and index then
    texture = GetSpellTexture(index, bookType)
  end

  if index then
    pfSpellScan:ClearLines()
    pfSpellScan:SetSpell(index, bookType)

    for i=1, 4 do
      for _, text in pairs({_G["pfSpellScanTextLeft"..i], _G["pfSpellScanTextRight"..i]}) do
        if text and text:IsVisible() and text:GetText() then
          local _, _, sec = string.find(text:GetText(), gsub(SPELL_CAST_TIME_SEC, "%%.3g", "%(.+%)"))
          local _, _, min = string.find(text:GetText(), gsub(SPELL_CAST_TIME_MIN, "%%.3g", "%(.+%)"))
          local _, _, range = string.find(text:GetText(), gsub(SPELL_RANGE, "%%s", "%(.+%)"))

          if sec or min then castingTime = tonumber(sec) * 1000 or tonumber(min) * 1000 end
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
      end
    end
  end
  spellinfo[index] = { name, rank, icon, castingTime, minRange, maxRange }
  return name, rank, icon, castingTime, minRange, maxRange
end
