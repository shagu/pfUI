-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libcast ]]--
-- A pfUI library that detects and saves all ongoing castbars of players, NPCs and enemies.
-- This also includes spells that usually don't have a castbar like Multi-Shot and Aimed Shot.
--
--  libcast:GetCastInfo(unit)
--    Returns all ongoing casts of a unit (name)
--    cast, start, casttime, icon, delay, channel
--
--  libcast:RegisterEventFunc(func, frame)
--    Triggers the given function `func` with `frame` as arg1,
--    whenever a new cast-event was detected
--
--  libcast:TriggerEvents()
--    Triggers all registered event functions.
--
--  libcast:AddAction(mob, spell, channel)
--    Adds a spell to the database by using pfUI's spell database
--    to obtain durations and icons
--
--  libcast:RemoveAction(mob, spell)
--    Removes the castbar of a given mob, if `spell` is an interrupt.
--    spell can be set to "INTERRUPT" to force remove an action.
--

local libcast = CreateFrame("Frame", "pfEnemyCast")

function libcast:GetCastInfo(unit)
  local db = self.db[unit]

  -- clean legacy values
  if db and db.start + db.delay + db.casttime / 1000 > GetTime() then
    return db.cast, db.start, db.casttime, db.icon, db.delay, db.channel
  elseif db then
    self.db[unit] = nil
  end

  return nil, 0, 0, "", 0, nil
end

function libcast:RegisterEventFunc(func, frame)
  table.insert(self.frames, { func, frame })
end

function libcast:TriggerEvents()
  for id, ft in pairs(self.frames) do ft[1](ft[2]) end
end

function libcast:AddAction(mob, spell, channel)
  if L["spells"][spell] ~= nil then
    local casttime = L["spells"][spell].t
    local icon = L["spells"][spell].icon
    self.db[mob] = {cast = spell, start = GetTime(), casttime = casttime, icon = icon, delay = 0, channel = channel}
    self:TriggerEvents()
  end
end

function libcast:RemoveAction(mob, spell)
  if self.db[mob] and ( L["interrupts"][spell] ~= nil or spell == "INTERRUPT" ) then
    self.db[mob] = nil
    self:TriggerEvents()
  end
end

-- Combatlog parser strings
libcast.SPELL_CAST = SanitizePattern(SPELLCASTOTHERSTART)
libcast.SPELL_PERFORM = SanitizePattern(SPELLPERFORMOTHERSTART)
libcast.SPELL_GAINS = SanitizePattern(AURAADDEDOTHERHELPFUL)
libcast.SPELL_AFFLICTED = SanitizePattern(AURAADDEDOTHERHARMFUL)
libcast.SPELL_HIT = SanitizePattern(SPELLLOGSELFOTHER)
libcast.SPELL_CRIT = SanitizePattern(SPELLLOGCRITSELFOTHER)
libcast.OTHER_SPELL_HIT = SanitizePattern(SPELLLOGOTHEROTHER)
libcast.OTHER_SPELL_CRIT = SanitizePattern(SPELLLOGCRITOTHEROTHER)
libcast.SPELL_INTERRUPT = SanitizePattern(SPELLINTERRUPTSELFOTHER)
libcast.OTHER_SPELL_INTERRUPT = SanitizePattern(SPELLINTERRUPTOTHEROTHER)

-- main data
libcast.db = {}
libcast.frames = {}

-- environmental casts
libcast:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
libcast:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
libcast:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
libcast:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF")

-- player spells
libcast:RegisterEvent("SPELLCAST_START")
libcast:RegisterEvent("SPELLCAST_STOP")
libcast:RegisterEvent("SPELLCAST_FAILED")
libcast:RegisterEvent("SPELLCAST_INTERRUPTED")
libcast:RegisterEvent("SPELLCAST_DELAYED")
libcast:RegisterEvent("SPELLCAST_CHANNEL_START")
libcast:RegisterEvent("SPELLCAST_CHANNEL_STOP")
libcast:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
libcast:RegisterEvent("PLAYER_TARGET_CHANGED")

libcast:SetScript("OnEvent", function()
  local player = UnitName("player")

  -- Fill database with player casts
  if event == "PLAYER_TARGET_CHANGED" then
    if not pfScanActive then
      this:TriggerEvents()
    end
  elseif event == "SPELLCAST_START" then
    this.db[player] = {cast = arg1, start = GetTime(), casttime = arg2, icon = nil, channel = nil, delay = 0}
    this:TriggerEvents()
  elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
    if this.db[player] and not this.db[player].channel then
      this.db[player] = nil
      this:TriggerEvents()
    end
  elseif ( event == "SPELLCAST_DELAYED" ) then
    if this.db[player] then
      this.db[player].delay = this.db[player].delay + arg1/1000
      this:TriggerEvents()
    end
  elseif ( event == "SPELLCAST_CHANNEL_START" ) then
    this.db[player] = {cast = arg2, start = GetTime(), casttime = arg1, icon = nil, channel = true, delay = 0}
    this:TriggerEvents()
  elseif event == "SPELLCAST_CHANNEL_STOP" then
    if this.db[player] and this.db[player].channel then
      this.db[player] = nil
      this:TriggerEvents()
    end
  elseif ( event == "SPELLCAST_CHANNEL_UPDATE" ) then
    this.db[player].delay = this.db[player].delay + this.db[player].casttime / 1000 - this.db[player].delay + this.db[player].start - GetTime() - arg1 / 1000

  -- Fill database with environmental casts
  elseif arg1 then
    -- (.+) begins to cast (.+).
    for mob, spell in string.gfind(arg1, libcast.SPELL_CAST) do
      libcast:AddAction(mob, spell)
      return
    end

    -- (.+) begins to perform (.+).
    for mob, spell in string.gfind(arg1, libcast.SPELL_PERFORM) do
      libcast:AddAction(mob, spell)
      return
    end

    -- (.+) gains (.+).
    for mob, spell in string.gfind(arg1, libcast.SPELL_GAINS) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- (.+) is afflicted by (.+).
    for mob, spell in string.gfind(arg1, libcast.SPELL_AFFLICTED) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- Your (.+) hits (.+) for (%d+).
    for spell, mob in string.gfind(arg1, libcast.SPELL_HIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- Your (.+) crits (.+) for (%d+).
    for spell, mob in string.gfind(arg1, libcast.SPELL_CRIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- (.+)'s (.+) %a hits (.+) for (%d+).
    for _, spell, mob in string.gfind(arg1, libcast.OTHER_SPELL_HIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- (.+)'s (.+) %a crits (.+) for (%d+).
    for _, spell, mob in string.gfind(arg1, libcast.OTHER_SPELL_CRIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- You interrupt (.+)'s (.+).";
    for mob, spell in string.gfind(arg1, libcast.SPELL_INTERRUPT) do
      libcast:RemoveAction(mob, "INTERRUPT")
      return
    end

    -- (.+) interrupts (.+)'s (.+).
    for _, mob, spell in string.gfind(arg1, libcast.OTHER_SPELL_INTERRUPT) do
      libcast:RemoveAction(mob, "INTERRUPT")
      return
    end
  end
end)

--[[ Custom Casts
  Enable Castbars for spells that don't have a castbar by default
  (e.g Multi-Shot and Aimed Shot)
]]--
local aimedshot = L["customcast"]["AIMEDSHOT"]
local multishot = L["customcast"]["MULTISHOT"]

libcast.customcast = {}
libcast.customcast[strlower(aimedshot)] = function(begin)
  if begin then
    local duration = 3000

    for i=1,32 do
      if UnitBuff("player", i) == "Interface\\Icons\\Racial_Troll_Berserk" then
        local berserk = 0.3
        if((UnitHealth("player")/UnitHealthMax("player")) >= 0.40) then
          berserk = (1.30 - (UnitHealth("player") / UnitHealthMax("player"))) / 3
        end
        duration = duration / (1 + berserk)
      elseif UnitBuff("player", i) == "Interface\\Icons\\Ability_Hunter_RunningShot" then
        duration = duration / 1.4
      elseif UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_InnerRage" then
        duration = duration / 1.3
      elseif UnitBuff("player", i) == "Interface\\Icons\\Inv_Trinket_Naxxramas04" then
        duration = duration / 1.2
      elseif UnitDebuff("player", i) == "Interface\\Icons\\Spell_Shadow_CurseOfTounges" then
        duration = duration / 0.5
      end
    end

    local _,_, lag = GetNetStats()
    local start = GetTime() + lag/1000

    libcast.db[UnitName("player")] = {cast = aimedshot, start = start, casttime = duration, icon = icon, delay = 0, channel = nil}
    libcast:TriggerEvents()
  else
    libcast.db[UnitName("player")] = nil
    libcast:TriggerEvents()
  end
end

libcast.customcast[strlower(multishot)] = function(begin)
  if begin then
    local duration = 500
    local _,_, lag = GetNetStats()
    local start = GetTime() + lag/1000

    libcast.db[UnitName("player")] = {cast = multishot, start = start, casttime = duration, icon = icon, delay = 0, channel = nil}
    libcast:TriggerEvents()
  else
    libcast.db[UnitName("player")] = nil
    libcast:TriggerEvents()
  end
end

local function CastCustom(spell)
  if not libcast:GetCastInfo(UnitName("player")) then
    for custom, func in pairs(libcast.customcast) do
      if strfind(strlower(spell), custom) or strlower(spell) == custom then
        func(true)
      end
    end
  end
end

hooksecurefunc("CastSpell", function(id, bookType)
  if GetSpellCooldown(id, bookType) ~= 0 then
    local spellName = GetSpellName(id, bookType)
    CastCustom(spellName)
  end
end, true)

hooksecurefunc("CastSpellByName", function(spellName, target)
  for i=1,120 do
    -- detect if any cast is ongoing
    if IsCurrentAction(i) then
      CastCustom(spellName)
      return
    end
  end
end, true)

local scanner = CreateFrame("GameTooltip", "pfSpellScanner", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
hooksecurefunc("UseAction", function(slot, target, button)
  if GetActionText(slot) or not IsCurrentAction(slot) then return end
  scanner:ClearLines()
  scanner:SetAction(slot)
  local spellName = pfSpellScannerTextLeft1:GetText()
  CastCustom(spellName)
end, true)

-- add libcast to pfUI API
pfUI.api.libcast = libcast
