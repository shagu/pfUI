-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ librange ]]--
-- A pfUI library that detects and caches distance to units.
--
--  librange:UnitInSpellRange(unit)
--    Returns `1` if the unit is within a 40y range
--

-- return instantly when another librange is already active
if pfUI.api.librange then return end

local _, class = UnitClass("player")
local librange = CreateFrame("Frame", "pfRangecheck", UIParent)

-- table of 40y spells per class
local spells = {
  ["PALADIN"] = {
    "Interface\\Icons\\Spell_Holy_FlashHeal",
    "Interface\\Icons\\Spell_Holy_HolyBolt",
  },
  ["PRIEST"] = {
    "Interface\\Icons\\Spell_Holy_FlashHeal",
    "Interface\\Icons\\Spell_Holy_LesserHeal",
    "Interface\\Icons\\Spell_Holy_Heal",
    "Interface\\Icons\\Spell_Holy_GreaterHeal",
    "Interface\\Icons\\Spell_Holy_Renew",
  },
  ["DRUID"] = {
    "Interface\\Icons\\Spell_Nature_HealingTouch",
    "Interface\\Icons\\Spell_Nature_ResistNature",
    "Interface\\Icons\\Spell_Nature_Rejuvenation",
  },
  ["SHAMAN"] = {
    "Interface\\Icons\\Spell_Nature_MagicImmunity",
    "Interface\\Icons\\Spell_Nature_HealingWaveLesser",
    "Interface\\Icons\\Spell_Nature_HealingWaveGreater",
  },
}

-- use native IsSpellInRange checker for tbc and skip
-- the whole targeting approach that is required for vanilla
if pfUI.expansion == "tbc" then
  local spell
  librange:RegisterEvent("LEARNED_SPELL_IN_TAB")
  librange:RegisterEvent("PLAYER_ENTERING_WORLD")
  librange:SetScript("OnEvent", function()
    -- abort on non healing classes
    if not spells[class] then return end

    for i = 1, GetNumSpellTabs() do
      local _, _, offset, num = GetSpellTabInfo(i)
      for id = offset + 1, offset + num do
        local name, rank = GetSpellName(id, BOOKTYPE_SPELL)
        local texture = GetSpellTexture(name)

        for _, tex in pairs(spells[class]) do
          if tex == texture then
            spell = name
            return
          end
        end
      end
    end
  end)

  function librange:UnitInSpellRange(unit)
    if not spell then return nil end
    return IsSpellInRange(spell, unit) == 1 and true or nil
  end

  -- add librange to pfUI API
  pfUI.api.librange = librange
  return
end

-- units that should be scanned
local units = {}
table.insert(units, "pet")
for i=1,4 do table.insert(units, "party" .. i) end
for i=1,4 do table.insert(units, "partypet" .. i) end
for i=1,40 do table.insert(units, "raid" .. i) end
for i=1,40 do table.insert(units, "raidpet" .. i) end
local numunits = table.getn(units)

-- cache for unit relations
local unitcache = {}

-- actual unit-range table
local unitdata = { }

-- setup sound function switches
local SoundOn = PlaySound
local SoundOff = function() return end

librange.id = 1

-- Shooting with wands does not make the PlayerFrame inCombat attribute change.
-- This frame makes wand attacks accesible via wandCombat on the PlayerFrame.
local wand = CreateFrame("Frame", "pfWandShootDetect")
wand:RegisterEvent("START_AUTOREPEAT_SPELL")
wand:RegisterEvent("STOP_AUTOREPEAT_SPELL")
wand:SetScript("OnEvent", function()
  PlayerFrame.wandCombat = event == "START_AUTOREPEAT_SPELL" and true or nil
end)

--Players with combo points aren't necessarily auto attacking, meaning we can't use inCombat.
--This allows us to avoid rangechecking when the player has combo points to avoid losing them.
local hascombopoints
local combo = CreateFrame("Frame", "pfComboPointsDetect")
combo:RegisterEvent("PLAYER_COMBO_POINTS")
combo:SetScript("OnEvent", function()
  hascombopoints = GetComboPoints() > 0
end)

librange:Hide()
librange:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
librange:RegisterEvent("PLAYER_ENTERING_WORLD")
librange:RegisterEvent("PLAYER_ENTER_COMBAT")
librange:RegisterEvent("PLAYER_LEAVE_COMBAT")
librange:SetScript("OnEvent", function()
  -- disable range checking activities
  if pfUI_config.unitframes.rangecheck == "0" or not spells[class] then
    this:Hide()
    return
  end

  this.interval = tonumber(C.unitframes.rangechecki)/numunits

  if event == "ACTIONBAR_SLOT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
    librange.slot = this:GetRangeSlot()
    this:Show()
  elseif event == "PLAYER_ENTER_COMBAT" then
    this.lastattack = GetTime()
    this:Hide()
  elseif event == "PLAYER_LEAVE_COMBAT" then
    if not this:ReAttack() then
      this:Show()
    end
  end
end)

local _, class = UnitClass("player")
local druid = class == "DRUID"
local target_event = TargetFrame_OnEvent
local target_nop = function() return end

librange:SetScript("OnUpdate", function()
  if ( this.tick or 1) > GetTime() then
    return
  else
    this.tick = GetTime() + this.interval
  end

  -- skip invalid units
  while not this:NeedRangeScan(units[this.id]) and this.id <= numunits do
    this.id = this.id + 1
  end

  if this.id <= numunits and librange.slot then
    local unit = units[this.id]
    if not UnitIsUnit("target", unit) then
      -- try to read distance via superwow first
      if superwow_active then
        local x1, y1, z1 = UnitPosition("player")
        local x2, y2, z2 = UnitPosition(unit)
        -- only continue if we got position values
        if x1 and y1 and z1 and x2 and y2 and z2 then
          local distance = ((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)^.5
          unitdata[unit] = distance < 45 and 1 or 0
          this.id = this.id + 1
          return
        end
      end

      -- suspend for various conditions
      if pfUI.loot and pfUI.loot:IsShown() then return nil end
      if LootFrame and LootFrame:IsShown() then return nil end
      if InspectFrame and InspectFrame:IsShown() then return nil end
      if TradeFrame and TradeFrame:IsShown() then return nil end
      if PlayerFrame and PlayerFrame.inCombat then return nil end
      if PlayerFrame and PlayerFrame.wandCombat then return nil end
      if druid and UnitPowerType("player") == 3 then return nil end
      if hascombopoints then return nil end

      _G.PlaySound = SoundOff
      pfScanActive = true

      -- save and disable target frame events
      target_event = TargetFrame_OnEvent
      _G.TargetFrame_OnEvent = target_nop

      TargetUnit(unit)
      unitdata[unit] = IsActionInRange(librange.slot)
      TargetLastTarget()

      -- restore target events
      _G.TargetFrame_OnEvent = target_event

      _G.PlaySound = SoundOn
      pfScanActive = false

      this:ReAttack()
    end

    this.id = this.id + 1
  else
    this.id = 1
  end
end)

function librange:ReAttack()
  -- we accidentally broke the autoattack... restoring the old state
  if this.lastattack and this.lastattack + this.interval > GetTime() and UnitCanAttack("player", "target") then
    AttackTarget()
    return true
  else
    return nil
  end
end

function librange:NeedRangeScan(unit)
  if not UnitExists(unit) then return nil end
  if not UnitIsVisible(unit) then return nil end
  if CheckInteractDistance(unit, 4) then return nil end
  return true
end

function librange:GetRealUnit(unit)
  if unitdata[unit] then return unit end

  if unitcache[unit] then
    if UnitIsUnit(unitcache[unit], unit) then
      return unitcache[unit]
    end
  end

  for id, realunit in pairs(units) do
    if UnitIsUnit(realunit, unit) then
      unitcache[unit] = realunit
      return realunit
    end
  end

  return unit
end

function librange:GetRangeSlot()
  local texture

  for i=1,120 do
    texture = GetActionTexture(i)
    if texture and not GetActionText(i) then
      for _, check in pairs(spells[class]) do
        if check == texture then
          return i
        end
      end
    end
  end

  return nil
end

function librange:UnitInSpellRange(unit)
  if not librange.slot then return nil end

  if UnitIsUnit("target", unit) then
    return IsActionInRange(librange.slot) == 1 and 1 or nil
  end

  local unit = librange:GetRealUnit(unit)

  if unitdata[unit] and unitdata[unit] == 1 then
    return 1
  elseif not unitdata[unit] then
    return 1
  else
    return nil
  end
end

-- add librange to pfUI API
pfUI.api.librange = librange
