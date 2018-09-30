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

-- return instantly when another libcast is already active
if pfUI.api.libcast then return end

local libcast = CreateFrame("Frame", "pfEnemyCast")
local player = UnitName("player")

function libcast:GetCastInfo(unit)
  local db = self.db[unit]

  -- clean legacy values
  if db and db.cast and db.start + db.delay + db.casttime / 1000 > GetTime() then
    return db.cast, db.start, db.casttime, db.icon, db.delay, db.channel
  elseif db then
    -- remove cast action to the database
    self.db[unit].cast = nil
    self.db[unit].start = nil
    self.db[unit].casttime = nil
    self.db[unit].icon = nil
    self.db[unit].delay = nil
    self.db[unit].channel = nil
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

    -- add cast action to the database
    if not self.db[mob] then self.db[mob] = {} end
    self.db[mob].cast = spell
    self.db[mob].start = GetTime()
    self.db[mob].casttime = casttime
    self.db[mob].icon = icon
    self.db[mob].delay = 0
    self.db[mob].channel = channel

    self:TriggerEvents()
  end
end

function libcast:RemoveAction(mob, spell)
  if self.db[mob] and ( L["interrupts"][spell] ~= nil or spell == "INTERRUPT" ) then

    -- remove cast action to the database
    self.db[mob].cast = nil
    self.db[mob].start = nil
    self.db[mob].casttime = nil
    self.db[mob].icon = nil
    self.db[mob].delay = nil
    self.db[mob].channel = nil

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
libcast.db = { [player] = {} }
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
  -- Fill database with player casts
  if event == "PLAYER_TARGET_CHANGED" then
    if not pfScanActive then
      this:TriggerEvents()
    end
  elseif event == "SPELLCAST_START" then
    -- add cast action to the database
    this.db[player].cast = arg1
    this.db[player].start = GetTime()
    this.db[player].casttime = arg2
    this.db[player].icon = nil
    this.db[player].delay = 0
    this.db[player].channel = nil
    this:TriggerEvents()
  elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
    if this.db[player] and not this.db[player].channel then
      -- remove cast action to the database
      this.db[player].cast = nil
      this.db[player].start = nil
      this.db[player].casttime = nil
      this.db[player].icon = nil
      this.db[player].delay = nil
      this.db[player].channel = nil
      this:TriggerEvents()
    end
  elseif event == "SPELLCAST_DELAYED" then
    if this.db[player].cast then
      this.db[player].delay = this.db[player].delay + arg1/1000
      this:TriggerEvents()
    end
  elseif event == "SPELLCAST_CHANNEL_START" then
    -- add cast action to the database
    this.db[player].cast = arg2
    this.db[player].start = GetTime()
    this.db[player].casttime = arg1
    this.db[player].icon = nil
    this.db[player].delay = 0
    this.db[player].channel = true
    this:TriggerEvents()
  elseif event == "SPELLCAST_CHANNEL_STOP" then
    if this.db[player] and this.db[player].channel then
      -- remove cast action to the database
      this.db[player].cast = nil
      this.db[player].start = nil
      this.db[player].casttime = nil
      this.db[player].icon = nil
      this.db[player].delay = nil
      this.db[player].channel = nil
      this:TriggerEvents()
    end
  elseif event == "SPELLCAST_CHANNEL_UPDATE" then
    this.db[player].delay = this.db[player].delay + this.db[player].casttime / 1000 - this.db[player].delay + this.db[player].start - GetTime() - arg1 / 1000

  -- Fill database with environmental casts
  elseif arg1 then
    -- (.+) begins to cast (.+).
    for mob, spell in gfind(arg1, libcast.SPELL_CAST) do
      libcast:AddAction(mob, spell)
      return
    end

    -- (.+) begins to perform (.+).
    for mob, spell in gfind(arg1, libcast.SPELL_PERFORM) do
      libcast:AddAction(mob, spell)
      return
    end

    -- (.+) gains (.+).
    for mob, spell in gfind(arg1, libcast.SPELL_GAINS) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- (.+) is afflicted by (.+).
    for mob, spell in gfind(arg1, libcast.SPELL_AFFLICTED) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- Your (.+) hits (.+) for (%d+).
    for spell, mob in gfind(arg1, libcast.SPELL_HIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- Your (.+) crits (.+) for (%d+).
    for spell, mob in gfind(arg1, libcast.SPELL_CRIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- (.+)'s (.+) %a hits (.+) for (%d+).
    for _, spell, mob in gfind(arg1, libcast.OTHER_SPELL_HIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- (.+)'s (.+) %a crits (.+) for (%d+).
    for _, spell, mob in gfind(arg1, libcast.OTHER_SPELL_CRIT) do
      libcast:RemoveAction(mob, spell)
      return
    end

    -- You interrupt (.+)'s (.+).";
    for mob, spell in gfind(arg1, libcast.SPELL_INTERRUPT) do
      libcast:RemoveAction(mob, "INTERRUPT")
      return
    end

    -- (.+) interrupts (.+)'s (.+).
    for _, mob, spell in gfind(arg1, libcast.OTHER_SPELL_INTERRUPT) do
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
      end
    end

    local _,_, lag = GetNetStats()
    local start = GetTime() + lag/1000

    -- add cast action to the database
    libcast.db[player].cast = aimedshot
    libcast.db[player].start = start
    libcast.db[player].casttime = duration
    libcast.db[player].icon = icon
    libcast.db[player].delay = 0
    libcast.db[player].channel = nil
    libcast:TriggerEvents()
  else
    -- remove cast action to the database
    libcast.db[player].cast = nil
    libcast.db[player].start = nil
    libcast.db[player].casttime = nil
    libcast.db[player].icon = nil
    libcast.db[player].delay = nil
    libcast.db[player].channel = nil
    libcast:TriggerEvents()
  end
end

libcast.customcast[strlower(multishot)] = function(begin)
  if begin then
    local duration = 500
    local _,_, lag = GetNetStats()
    local start = GetTime() + lag/1000

    -- add cast action to the database
    libcast.db[player].cast = multishot
    libcast.db[player].start = start
    libcast.db[player].casttime = duration
    libcast.db[player].icon = icon
    libcast.db[player].delay = 0
    libcast.db[player].channel = nil
    libcast:TriggerEvents()
  else
    -- remove cast action to the database
    libcast.db[player].cast = nil
    libcast.db[player].start = nil
    libcast.db[player].casttime = nil
    libcast.db[player].icon = nil
    libcast.db[player].delay = nil
    libcast.db[player].channel = nil
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

local scanner = libtipscan:GetScanner("libcast")
hooksecurefunc("UseAction", function(slot, target, button)
  if GetActionText(slot) or not IsCurrentAction(slot) then return end
  scanner:SetAction(slot)
  local spellName = scanner:Line(1)
  CastCustom(spellName)
end, true)

-- add libcast to pfUI API
pfUI.api.libcast = libcast
