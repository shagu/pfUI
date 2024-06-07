-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libcast ]]--
-- A pfUI library that detects and saves all ongoing castbars of players, NPCs and enemies.
-- The library also includes spells that usually don't have a castbar like Multi-Shot and Aimed Shot.
-- This is exclusivly used for vanilla in order to provide UnitChannelInfo and UnitCastingInfo functions.
--
-- External functions:
--   UnitChannelInfo(unit)
--     Returns information on the spell currently cast by the specified unit.
--     Returns nil if no spell is being cast.
--
--     cast[String] - The name of the spell, or nil if no spell is being cast.
--     nameSubtext[String] - (DUMMY) The string describing the rank of the spell, e.g. "Rank 1".
--     text[String] - The name to be displayed.
--     texture[String] - The texture path associated with the spell.
--     startTime[Number] - Specifies when casting has begun, in milliseconds.
--     endTime[Number] - Specifies when casting will end, in milliseconds.
--     isTradeSkill[Boolean] - (DUMMY) Specifies if the cast is a tradeskill
--
--   UnitCastingInfo(unit)
--     Returns information on the spell currently channeled by the specified unit.
--     Returns nil if no spell is being channeled.
--
--     cast[String] - The name of the spell, or nil if no spell is being cast.
--     nameSubtext[String] - (DUMMY) The string describing the rank of the spell, e.g. "Rank 1".
--     text[String] - The name to be displayed.
--     texture[String] - The texture path associated with the spell.
--     startTime[Number] - Specifies when casting has begun, in milliseconds.
--     endTime[Number] - Specifies when casting will end, in milliseconds.
--     isTradeSkill[Boolean] - (DUMMY) Specifies if the cast is a tradeskill
--
-- Internal functions:
--   libcast:AddAction(mob, spell, channel)
--     Adds a spell to the database by using pfUI's spell database
--     to obtain durations and icons
--
--   libcast:RemoveAction(mob, spell)
--     Removes the castbar of a given mob, if `spell` is an interrupt.
--     spell can be set to "INTERRUPT" to force remove an action.
--

-- return instantly if we're not on a vanilla client
if pfUI.client > 11200 then return end

-- return instantly when another libcast is already active
if pfUI.api.libcast then return end

local lastcasttex, lastrank, _
local scanner = libtipscan:GetScanner("libcast")

local libcast = CreateFrame("Frame", "pfEnemyCast")
local player = UnitName("player")

UnitChannelInfo = _G.UnitChannelInfo or function(unit)
  -- convert to name if unitstring was given
  unit = pfValidUnits[unit] and UnitName(unit) or unit

  local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill
  local db = libcast.db[unit]

  -- clean legacy values
  if db and db.cast and db.start + db.casttime / 1000 > GetTime() then
    if not db.channel then return end
    cast = db.cast
    nameSubtext = db.rank
    text = ""
    texture = db.icon
    startTime = db.start * 1000
    endTime = startTime + db.casttime
    isTradeSkill = nil
  elseif db then
    -- remove cast action to the database
    db.cast = nil
    db.rank = nil
    db.start = nil
    db.casttime = nil
    db.icon = nil
    db.channel = nil
  end

  return cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill
end

UnitCastingInfo = _G.UnitCastingInfo or function(unit)
  -- convert to name if unitstring was given
  unit = pfValidUnits[unit] and UnitName(unit) or unit

  local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill
  local db = libcast.db[unit]

  -- clean legacy values
  if db and db.cast and db.start + db.casttime / 1000 > GetTime() then
    if db.channel then return end
    cast = db.cast
    nameSubtext = db.rank or ""
    text = ""
    texture = db.icon
    startTime = db.start * 1000
    endTime = startTime + db.casttime
    isTradeSkill = nil
  elseif db then
    -- remove cast action to the database
    db.cast = nil
    db.rank = nil
    db.start = nil
    db.casttime = nil
    db.icon = nil
    db.channel = nil
  end

  return cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill
end

function libcast:AddAction(mob, spell, channel)
  if not mob or not spell then return nil end

  if L["spells"][spell] ~= nil then
    local casttime = L["spells"][spell].t
    local icon = L["spells"][spell].icon and string.format("%s%s", "Interface\\Icons\\", L["spells"][spell].icon) or nil

    -- add cast action to the database
    if not self.db[mob] then self.db[mob] = {} end
    self.db[mob].cast = spell
    self.db[mob].rank = nil
    self.db[mob].start = GetTime()
    self.db[mob].casttime = casttime
    self.db[mob].icon = icon
    self.db[mob].channel = channel

    return true
  end

  return nil
end

function libcast:RemoveAction(mob, spell)
  if self.db[mob] and ( L["interrupts"][spell] ~= nil or spell == "INTERRUPT" ) then

    -- remove cast action to the database
    self.db[mob].cast = nil
    self.db[mob].rank = nil
    self.db[mob].start = nil
    self.db[mob].casttime = nil
    self.db[mob].icon = nil
    self.db[mob].channel = nil
  end
end

-- main data
libcast.db = { [player] = {} }

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

local mob, spell, icon, _
libcast:SetScript("OnEvent", function()
  -- Fill database with player casts
  if event == "SPELLCAST_START" then
    icon = L["spells"][arg1] and L["spells"][arg1].icon and string.format("%s%s", "Interface\\Icons\\", L["spells"][arg1].icon) or lastcasttex
    -- add cast action to the database
    this.db[player].cast = arg1
    this.db[player].rank = lastrank
    this.db[player].start = GetTime()
    this.db[player].casttime = arg2
    this.db[player].icon = icon
    this.db[player].channel = nil
    if not L["spells"][arg1] or not L["spells"][arg1].icon or not L["spells"][arg1].t then
      L["spells"][arg1] = L["spells"][arg1] or { }
      L["spells"][arg1].icon = L["spells"][arg1].icon or icon
      L["spells"][arg1].t = L["spells"][arg1].t or arg2
    end
    lastcasttex, lastrank = nil, nil
  elseif event == "SPELLCAST_STOP" or event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
    if this.db[player] and not this.db[player].channel then
      -- remove cast action to the database
      this.db[player].cast = nil
      this.db[player].rank = nil
      this.db[player].rank = nil
      this.db[player].start = nil
      this.db[player].casttime = nil
      this.db[player].icon = nil
      this.db[player].channel = nil
    else
      lastcasttex, lastrank = nil, nil
    end
  elseif event == "SPELLCAST_DELAYED" then
    if this.db[player].cast then
      this.db[player].start = this.db[player].start + arg1/1000
    end
  elseif event == "SPELLCAST_CHANNEL_START" then
    -- add cast action to the database
    this.db[player].cast = arg2
    this.db[player].rank = lastrank
    this.db[player].start = GetTime()
    this.db[player].casttime = arg1
    this.db[player].icon = L["spells"][arg2] and L["spells"][arg2].icon and string.format("%s%s", "Interface\\Icons\\", L["spells"][arg2].icon) or lastcasttex
    this.db[player].channel = true
    lastcasttex, lastrank = nil, nil
  elseif event == "SPELLCAST_CHANNEL_STOP" then
    if this.db[player] and this.db[player].channel then
      -- remove cast action to the database
      this.db[player].cast = nil
      this.db[player].rank = nil
      this.db[player].start = nil
      this.db[player].casttime = nil
      this.db[player].icon = nil
      this.db[player].channel = nil
    end
  elseif event == "SPELLCAST_CHANNEL_UPDATE" then
    if this.db[player].cast then
      this.db[player].start = -this.db[player].casttime/1000 + GetTime() + arg1/1000
    end
  -- Fill database with environmental casts
  elseif arg1 then
    -- (.+) begins to cast (.+).
    mob, spell = cmatch(arg1, SPELLCASTOTHERSTART)
    if libcast:AddAction(mob, spell) then return end

    -- (.+) begins to perform (.+).
    mob, spell = cmatch(arg1, SPELLPERFORMOTHERSTART)
    if libcast:AddAction(mob, spell) then return end

    -- (.+) gains (.+).
    mob, spell = cmatch(arg1, AURAADDEDOTHERHELPFUL)
    if libcast:RemoveAction(mob, spell) then return end

    -- (.+) is afflicted by (.+).
    mob, spell = cmatch(arg1, AURAADDEDOTHERHARMFUL)
    if libcast:RemoveAction(mob, spell) then return end

    -- Your (.+) hits (.+) for (%d+).
    spell, mob = cmatch(arg1, SPELLLOGSELFOTHER)
    if libcast:RemoveAction(mob, spell) then return end

    -- Your (.+) crits (.+) for (%d+).
    spell, mob = cmatch(arg1, SPELLLOGCRITSELFOTHER)
    if libcast:RemoveAction(mob, spell) then return end

    -- (.+)'s (.+) %a hits (.+) for (%d+).
    _, spell, mob = cmatch(arg1, SPELLLOGOTHEROTHER)
    if libcast:RemoveAction(mob, spell) then return end

    -- (.+)'s (.+) %a crits (.+) for (%d+).
    _, spell, mob = cmatch(arg1, SPELLLOGCRITOTHEROTHER)
    if libcast:RemoveAction(mob, spell) then return end

    -- You interrupt (.+)'s (.+).
    mob, _ = cmatch(arg1, SPELLINTERRUPTSELFOTHER)
    if libcast:RemoveAction(mob, "INTERRUPT") then return end

    -- (.+) interrupts (.+)'s (.+).
    _, mob, _ = cmatch(arg1, SPELLINTERRUPTOTHEROTHER)
    if libcast:RemoveAction(mob, "INTERRUPT") then return end
  end
end)

--[[ Custom Casts
  Enable Castbars for spells that don't have a castbar by default
  (e.g Multi-Shot and Aimed Shot)
]]--
local aimedshot = L["customcast"]["AIMEDSHOT"]
local multishot = L["customcast"]["MULTISHOT"]

libcast.customcast = {}
libcast.customcast[strlower(aimedshot)] = function(begin, duration)
  if begin then
    local duration = duration or 3000

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
    libcast.db[player].rank = lastrank
    libcast.db[player].start = start
    libcast.db[player].casttime = duration
    libcast.db[player].icon = "Interface\\Icons\\Inv_spear_07"
    libcast.db[player].channel = nil
  else
    -- remove cast action to the database
    libcast.db[player].cast = nil
    libcast.db[player].rank = nil
    libcast.db[player].start = nil
    libcast.db[player].casttime = nil
    libcast.db[player].icon = nil
    libcast.db[player].channel = nil
  end
end

libcast.customcast[strlower(multishot)] = function(begin, duration)
  if begin then
    local duration = duration or 500

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
    libcast.db[player].cast = multishot
    libcast.db[player].rank = lastrank
    libcast.db[player].start = start
    libcast.db[player].casttime = duration
    libcast.db[player].icon = "Interface\\Icons\\Ability_upgrademoonglaive"
    libcast.db[player].channel = nil
  else
    -- remove cast action to the database
    libcast.db[player].cast = nil
    libcast.db[player].rank = nil
    libcast.db[player].start = nil
    libcast.db[player].casttime = nil
    libcast.db[player].icon = nil
    libcast.db[player].channel = nil
  end
end

local function CastCustom(id, bookType, rawSpellName, rank, texture, castingTime)
  if not id or not rawSpellName or not castingTime then return end -- ignore if the spell is not found or if it is instant-cast

  lastrank = rank
  lastcasttex = texture

  local func = libcast.customcast[strlower(rawSpellName)]
  if not func then return end

  if GetSpellCooldown(id, bookType) == 0 or UnitCastingInfo(player) then return end -- detect casting

  func(true)
end

hooksecurefunc("UseContainerItem", function(id, index)
  lastcasttex = GetContainerItemInfo(id, index)
end)

hooksecurefunc("CastSpell", function(id, bookType)
  local cachedRawSpellName, cachedRank, cachedTexture, cachedCastingTime, _, _, cachedSpellId, cachedBookType = libspell.GetSpellInfo(id, bookType)

  CastCustom(cachedSpellId, cachedBookType, cachedRawSpellName, cachedRank, cachedTexture, cachedCastingTime)
end, true)

hooksecurefunc("CastSpellByName", function(spellCasted, target)
  local cachedRawSpellName, cachedRank, cachedTexture, cachedCastingTime, _, _, cachedSpellId, cachedBookType = libspell.GetSpellInfo(spellCasted)

  CastCustom(cachedSpellId, cachedBookType, cachedRawSpellName, cachedRank, cachedTexture, cachedCastingTime)
end, true)

hooksecurefunc("UseAction", function(slot, target, button)
  if GetActionText(slot) or not IsCurrentAction(slot) then return end
  
  scanner:SetAction(slot)
  local rawSpellName, rank = scanner:Line(1)
  if not rawSpellName then return end -- ignore if the spell is not found

  local cachedRawSpellName, cachedRank, cachedTexture, cachedCastingTime, _, _, cachedSpellId, cachedBookType = libspell.GetSpellInfo(rawSpellName .. (rank and ("(" .. rank .. ")") or ""))

  CastCustom(cachedSpellId, cachedBookType, cachedRawSpellName, cachedRank, cachedTexture, cachedCastingTime)
end, true)

-- add libcast to pfUI API
pfUI.api.libcast = libcast
