pfUI:RegisterModule("rangecheck", function ()

  if C.unitframes.rangecheck == "0" then return end

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

  local _, class = UnitClass("player")
  if not spells[class] then return end

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

  -- the interval between each range check
  local interval = tonumber(C.unitframes.rangechecki)/numunits

  pfUI.rangecheck = CreateFrame("Frame", "pfRangecheck", UIParent)
  pfUI.rangecheck.id = 1
  pfUI.rangecheck:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
  pfUI.rangecheck:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.rangecheck:SetScript("OnEvent", function()
    pfUI.rangecheck.slot = this:GetRangeSlot()
  end)

  pfUI.rangecheck:SetScript("OnUpdate", function()
    if ( this.tick or 1) > GetTime() then
      return
    else
      this.tick = GetTime() + interval
    end

    -- skip invalid units
    while not this:NeedRangeScan(units[this.id]) and this.id <= numunits do
      this.id = this.id + 1
    end

    if this.id <= numunits and pfUI.rangecheck.slot then
      local unit = units[this.id]
      if not UnitIsUnit("target", unit) then
        -- don't break looting
        if pfUI.loot and pfUI.loot:IsShown() then return nil end
        if LootFrame and LootFrame:IsShown() then return nil end

        -- don't break auto-attacks
        if PlayerFrame.inCombat and UnitCanAttack("player", "target") then
          return nil
        end

        pfScanActive = true
        TargetUnit(unit)
        unitdata[unit] = IsActionInRange(pfUI.rangecheck.slot)
        TargetLastTarget()
        pfScanActive = false
      else
        unitdata[unit] = IsActionInRange(pfUI.rangecheck.slot)
      end

      this.id = this.id + 1
    else
      this.id = 1
    end
  end)

  function pfUI.rangecheck:NeedRangeScan(unit)
    if not UnitExists(unit) then return nil end
    if not UnitIsVisible(unit) then return nil end
    if CheckInteractDistance(unit, 4) then return nil end
    return true
  end

  function pfUI.rangecheck:GetRealUnit(unit)
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

  function pfUI.rangecheck:GetRangeSlot()
    for i=1,120 do
      local texture = GetActionTexture(i)
      for _, check in pairs(spells[class]) do
        if check == texture then
          return i
        end
      end
    end

    return nil
  end

  function pfUI.rangecheck:UnitInSpellRange(unit)
    local unit = pfUI.rangecheck:GetRealUnit(unit)

    if unitdata[unit] and unitdata[unit] == 1 then
      return 1
    elseif not unitdata[unit] then
      return 1
    else
      return nil
    end
  end
end)
