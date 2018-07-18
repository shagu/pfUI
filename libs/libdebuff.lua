-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libdebuff ]]--
-- A pfUI library that detects and saves all ongoing debuffs of players, NPCs and enemies.
--
--  libdebuff:GetDebuffName(unit, index)
--    Returns the debuff name with the given index of the specified unit
--
--  libdebuff:GetDebuffInfo(unit, effect)
--    Returns debuff informations on the given effect of the specified unit.
--    start, duration, timeleft

local libdebuff = CreateFrame("Frame", "pfdebuffsScanner", UIParent)
local scanner = libtipscan:GetScanner("libdebuff")

function libdebuff:GetDebuffName(unit, index)
  scanner:SetUnitDebuff(unit, index)
  local text = scanner:Line(1)
  return ( text ) and text or ""
end

function libdebuff:GetDebuffInfo(unit, effect)
  local unitname = UnitName(unit)
  local unitlevel = UnitLevel(unit)

  if libdebuff.objects[unitname] and libdebuff.objects[unitname][unitlevel] and libdebuff.objects[unitname][unitlevel][effect] then
    -- clean up db
    if libdebuff.objects[unitname][unitlevel][effect].duration and libdebuff.objects[unitname][unitlevel][effect].duration + libdebuff.objects[unitname][unitlevel][effect].start < GetTime() then
      libdebuff.objects[unitname][unitlevel][effect] = nil
      return 0, 0, 0
    end
    local start = libdebuff.objects[unitname][unitlevel][effect].start
    local duration = libdebuff.objects[unitname][unitlevel][effect].duration
    local timeleft = duration + start - GetTime()

    return start, duration, timeleft

  -- no level data
  elseif libdebuff.objects[unitname] and libdebuff.objects[unitname][0] and libdebuff.objects[unitname][0][effect] then
    -- clean up db
    if libdebuff.objects[unitname][0][effect].duration and libdebuff.objects[unitname][0][effect].duration + libdebuff.objects[unitname][0][effect].start < GetTime() then
      libdebuff.objects[unitname][0][effect] = nil
      return 0, 0, 0
    end
    local start = libdebuff.objects[unitname][0][effect].start
    local duration = libdebuff.objects[unitname][0][effect].duration
    local timeleft = duration + start - GetTime()

    return start, duration, timeleft
  else
    return 0, 0, 0
  end
end

function libdebuff:GetDuration(effect, rank)
  if L["debuffs"][effect] and rank then
    local rank = string.gsub(rank, RANK .. " ", "")
    local duration = L["debuffs"][effect][tonumber(rank)] or libdebuff:GetDuration(effect)
    if effect == L["dyndebuffs"]["Rupture"] then
      -- Rupture: +2 sec per combo point
      duration = duration + GetComboPoints()*2
    elseif effect == L["dyndebuffs"]["Kidney Shot"] then
      -- Kidney Shot: +1 sec per combo point
      duration = duration + GetComboPoints()*1
    elseif effect == L["dyndebuffs"]["Demoralizing Shout"] then
      -- Booming Voice: 10% per talent
      local _,_,_,_,count = GetTalentInfo(2,1)
      if count and count > 0 then duration = duration + ( duration / 100 * (count*10)) end
    elseif effect == L["dyndebuffs"]["Shadow Word: Pain"] then
      -- Improved Shadow Word: Pain: +3s per talent
      local _,_,_,_,count = GetTalentInfo(3,4)
      if count and count > 0 then duration = duration + count * 3 end
    elseif effect == L["dyndebuffs"]["Frostbolt"] then
      -- Permafrost: +1s per talent
      local _,_,_,_,count = GetTalentInfo(3,7)
      if count and count > 0 then duration = duration + count end
    end
    return duration
  elseif L["debuffs"][effect] and L["debuffs"][effect][0] then
    return L["debuffs"][effect][0]
  elseif L["debuffs"][effect] then
    return L["debuffs"][effect][libdebuff:GetMaxRank(effect)]
  else
    return 0
  end
end

function libdebuff:AddPending(unit, unitlevel, effect, duration)
  if not unit then return end
  if not L["debuffs"][effect] then return end
  local duration = duration or libdebuff:GetDuration(effect)
  local unitlevel = unitlevel or 0

  if duration > 0 then
    libdebuff.pending = { unit, unitlevel, effect, duration }
  end
end

function libdebuff:PersistPending(effect)
  if libdebuff.pending[3] == effect or ( effect == nil and libdebuff.pending[3] ) then

    local unit = libdebuff.pending[1]
    local unitlevel = libdebuff.pending[2]
    local effect = libdebuff.pending[3]
    local duration = libdebuff.pending[4]

    libdebuff:AddEffect(unit, unitlevel, effect, duration)
  end
end

function libdebuff:RemovePending(effect)
  if libdebuff.pending[3] == effect then
    libdebuff.pending = {}
  end
end

function libdebuff:GetMaxRank(effect)
  local max = 0
  for id in pairs(L["debuffs"][effect]) do
    if id > max then max = id end
  end
  return max
end

function libdebuff:AddEffect(unit, unitlevel, effect, duration)
  if not unit or not effect then return end
  unitlevel = unitlevel or 0
  if not libdebuff.objects[unit] then libdebuff.objects[unit] = {} end
  if not libdebuff.objects[unit][unitlevel] then libdebuff.objects[unit][unitlevel] = {} end
  if not libdebuff.objects[unit][unitlevel][effect] then libdebuff.objects[unit][unitlevel][effect] = {} end

  libdebuff.objects[unit][unitlevel][effect].start = GetTime()
  libdebuff.objects[unit][unitlevel][effect].duration = duration or libdebuff:GetDuration(effect)

  libdebuff.pending = {}

  if pfUI.uf.target then
    pfUI.uf:RefreshUnit(pfUI.uf.target, "aura")
  end
end

-- scan for debuff application
libdebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
libdebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
libdebuff:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
libdebuff:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
libdebuff:RegisterEvent("PLAYER_TARGET_CHANGED")
libdebuff:RegisterEvent("SPELLCAST_STOP")
libdebuff:RegisterEvent("UNIT_AURA")

-- Remove Pending
libdebuff.rp = { SanitizePattern(SPELLFAILCASTSELF), SanitizePattern(SPELLFAILPERFORMSELF), SanitizePattern(SPELLIMMUNESELFOTHER),
  SanitizePattern(IMMUNEDAMAGECLASSSELFOTHER), SanitizePattern(SPELLMISSSELFOTHER), SanitizePattern(SPELLRESISTSELFOTHER),
  SanitizePattern(SPELLEVADEDSELFOTHER), SanitizePattern(SPELLDODGEDSELFOTHER), SanitizePattern(SPELLDEFLECTEDSELFOTHER),
  SanitizePattern(SPELLREFLECTSELFOTHER), SanitizePattern(SPELLPARRIEDSELFOTHER), SanitizePattern(SPELLLOGABSORBSELFOTHER) }

-- Persist Pending
libdebuff.pp = { SanitizePattern(SPELLCASTGOSELF), SanitizePattern(SPELLPERFORMGOSELF), SanitizePattern(SPELLLOGSCHOOLSELFOTHER),
  SanitizePattern(SPELLLOGCRITSCHOOLSELFOTHER), SanitizePattern(SPELLLOGSELFOTHER), SanitizePattern(SPELLLOGCRITSELFOTHER) }

-- Aura Pending
libdebuff.combatlog = SanitizePattern(AURAADDEDOTHERHARMFUL)

libdebuff.objects = {}
libdebuff.pending = {}

-- Gather Data by Events
libdebuff:SetScript("OnEvent", function()
  -- Add Combat Log
  if event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
    for unit, effect in string.gfind(arg1, libdebuff.combatlog) do
      local unitlevel = UnitName("target") == unit and UnitLevel("target") or 0

      if not libdebuff.objects[unit] or not libdebuff.objects[unit][unitlevel] or not libdebuff.objects[unit][unitlevel][effect] then
        this:AddEffect(unit, unitlevel, effect)
      end
    end

  -- Add Missing Buffs by Iteration
  elseif ( event == "UNIT_AURA" and arg1 == "target" ) or event == "PLAYER_TARGET_CHANGED" then
    for i=1, 16 do
      texture, _, _ = UnitDebuff("target" , i)
      if texture then
        local effect = this:GetDebuffName("target", i)
        if effect ~= "" and this:GetDebuffInfo("target", effect) == 0 then
          this:AddEffect(UnitName("target"), UnitLevel("target"), effect)
        end
      end
    end

  -- Update Pending Spells
  elseif event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER" or event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
    -- Persist pending Spell
    for _, msg in pairs(libdebuff.pp) do
      for effect, _ in string.gfind(arg1, msg) do
        libdebuff:PersistPending(effect)
        return
      end
    end

    -- Remove pending spell
    for _, msg in pairs(libdebuff.rp) do
      for effect, _ in string.gfind(arg1, msg) do
        libdebuff:RemovePending(effect)
        return
      end
    end
  elseif event == "SPELLCAST_STOP" then
    -- Persist all spells that have not been removed till here
    libdebuff:PersistPending()
  end
end)

-- Gather Data by User Actions
hooksecurefunc("CastSpell", function(id, bookType)
  local effect = GetSpellName(id, bookType)
  local _, rank = libspell.GetSpellInfo(id, bookType)
  local duration = libdebuff:GetDuration(effect, rank)
  libdebuff:AddPending(UnitName("target"), UnitLevel("target"), effect, duration)
end, true)

hooksecurefunc("CastSpellByName", function(effect, target)
  local _, rank = libspell.GetSpellInfo(effect)
  local duration = libdebuff:GetDuration(effect, rank)
  libdebuff:AddPending(UnitName("target"), UnitLevel("target"), effect, duration)
end, true)

hooksecurefunc("UseAction", function(slot, target, button)
  if GetActionText(slot) or not IsCurrentAction(slot) then return end
  scanner:SetAction(slot)
  local effect, rank = scanner:Line(1)
  local duration = libdebuff:GetDuration(effect, rank)
  libdebuff:AddPending(UnitName("target"), UnitLevel("target"), effect, duration)
end, true)

-- add libdebuff to pfUI API
pfUI.api.libdebuff = libdebuff
