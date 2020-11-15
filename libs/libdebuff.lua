-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

--[[ libdebuff ]]--
-- A pfUI library that detects and saves all ongoing debuffs of players, NPCs and enemies.
-- The functions UnitDebuff is exposed to the modules which allows to query debuffs like you
-- would on later expansions.
--
--  libdebuff:UnitDebuff(unit, id)
--    Returns debuff informations on the given effect of the specified unit.
--    name, rank, texture, stacks, dtype, duration, timeleft

-- return instantly if we're not on a vanilla client
if pfUI.client > 11200 then return end

-- return instantly when another libdebuff is already active
if pfUI.api.libdebuff then return end

-- fix a typo (missing $) in ruRU capture index
if GetLocale() == "ruRU" then
  SPELLREFLECTSELFOTHER = gsub(SPELLREFLECTSELFOTHER, "%%2s", "%%2%$s")
end

local libdebuff = CreateFrame("Frame", "pfdebuffsScanner", UIParent)
local scanner = libtipscan:GetScanner("libdebuff")
local _, class = UnitClass("player")
local lastspell

function libdebuff:GetDuration(effect, rank)
  if L["debuffs"][effect]then
    local rank = rank and tonumber((string.gsub(rank, RANK .. " ", ""))) or 0
    local rank = L["debuffs"][effect][rank] and rank or libdebuff:GetMaxRank(effect)
    local duration = L["debuffs"][effect][rank]
	local _, class = UnitClass("player")
	
    
	
	--ROGUE
	
    if class == "ROGUE" then
	--  Total Control and Improved Gouge
		if effect == L["dyndebuffs"]["Gouge"] then
	       local _,_,_,_,countIG = GetTalentInfo(2,1)
	       local _,_,_,_,countTC = GetTalentInfo(1,16)
	       if (countIG and countIG == 0 and countTC and countTC > 0) then duration = duration + (countTC*.5)  end
		   if (countIG and countIG > 0 and countTC and countTC == 0) then duration = duration + (countIG*.5)  end
		   if (countIG and countIG > 0 and countTC and countTC > 0) then duration = duration + (countIG*.5) + (countTC*.5)  end
	--  Rupture with Serrated Blades and Exhaustion
		elseif effect == L["dyndebuffs"]["Rupture"] then
		   local _,_,_,_,countSB = GetTalentInfo(3,13)
		   local _,_,_,_,countEx = GetTalentInfo(1,6)
		   if (countEx and countEx == 0 and  countSB and countSB == 0) then duration = (duration + GetComboPoints() * 2)  end
		   if (countEx and countEx == 0 and  countSB and countSB > 0) then duration = (duration + GetComboPoints() * 2) + (countSB*2)  end
		   if (countEx and countEx == 1 and  countSB and countSB == 0) then duration = (duration + GetComboPoints() * 2) * 1.25  end
		   if (countEx and countEx == 1 and  countSB and countSB > 0) then duration = (duration + GetComboPoints() * 2) * 1.25 + (countSB*2) end
		   if (countEx and countEx == 2 and  countSB and countSB == 0) then duration = (duration + GetComboPoints() * 2) * 1.5 end
	--  Garotte with Serrated Blades 
		elseif effect == L["dyndebuffs"]["Garrote"] then
		   local _,_,_,_,countSB = GetTalentInfo(3,13)
		   if countSB and countSB > 1 then duration = duration + 2*countSB end
		   if (countEx and countEx == 2 and  countSB and countSB > 0) then duration = (duration + GetComboPoints() * 2) * 1.5 + (countSB*2)end
	--  Total Control for Kidney Shot(1,16)
		elseif effect == L["dyndebuffs"]["Kidney Shot"] then
		   local _,_,_,_,countTC = GetTalentInfo(1,16)
		   if countTC and countTC == 0 then duration = duration + GetComboPoints()*1 end
		   if countTC and countTC > 0 then duration = duration + GetComboPoints()*1 + (countTC*.5) end
	--  Expose Armor with Exhaustion (1,6)
		elseif effect == L["dyndebuffs"]["Expose Armor"] then
		   local _,_,_,_,countEx = GetTalentInfo(1,6)
		   if countEx and countEx > 0 then duration = duration + ( duration / 100 * (countEx*25)) end
	--  Total Control for Cheap Shot, Blind and Sap (1,16)
		elseif effect == L["dyndebuffs"]["Cheap Shot"] or L["dyndebuffs"]["Blind"]or L["dyndebuffs"]["Sap"] then
		   local _,_,_,_,countTC = GetTalentInfo(1,16)
		   if countTC and countTC > 0 then duration = duration + (countTC*.5) end
		end
	--MAGE	
	elseif class == "MAGE" then
	--  Permafrost (3/3)
		if effect == L["dyndebuffs"]["Frostbolt"] then
		   local _,_,_,_,countIFB = GetTalentInfo(3,3)
		   if countIFB and countIFB > 0 then duration = duration + countIFB end
		end
	--HUNTER	   
	elseif class == "HUNTER" then
	--  Improved Hunters Mark
		if effect == L["dyndebuffs"]["Hunter\'s Mark"] then
		   local _,_,_,_,countIHM = GetTalentInfo(2,1)
		   if countIHM and countIHM > 0 then duration = duration + (60 * countIHM) end
		end
	--PRIEST	   
	elseif class == "PRIEST" then
	--  Improved Shadow Word: Pain 
		if effect == L["dyndebuffs"]["Shadow Word: Pain"] then
           local _,_,_,_,countSWP = GetTalentInfo(3,2)
           if countSWP and countSWP > 0 then duration = duration + countSWP * 3 end
		end
	--WARLOCK
	elseif class == "WARLOCK" then
	--  Jinx with 4 Curses
		if effect == L["dyndebuffs"]["Curse of Weakness"]or L["dyndebuffs"]["Curse of Recklessness"] or L["dyndebuffs"]["Curse of the Elements"]or L["dyndebuffs"]["Curse of Shadow"] then
		   local _,_,_,_,countJ = GetTalentInfo(1,2)
		   if countJ and countJ > 0 then duration = duration + (countJ * 30) end
	--  Curse of Exhaustion with Jinx
		elseif effect == L["dyndebuffs"]["Curse of Exhaustion"] then
		   local _,_,_,_,countJ = GetTalentInfo(1,2)
		   if countJ and countJ > 0 then duration = duration + (countJ * 3) end
	--  Prolonged Misery
		elseif effect == L["dyndebuffs"]["Curse of Agony"] or L["dyndebuffs"]["Immolate"] or L["dyndebuffs"]["Corruption"] then   
		   local _,_,_,_,countPM = GetTalentInfo(1,8)
		   if countPM and countPM > 0 then duration = duration + countPM * 3 end
		end
	--WARRIOR
	elseif class == "WARRIOR" then
	--  Booming Voice  
		if effect == L["dyndebuffs"]["Demoralizing Shout"] or effect == L["dyndebuffs"]["Challenging Shout"]or effect == L["dyndebuffs"]["Intimidating Shout"] then 
		   local _,_,_,_,countBV = GetTalentInfo(2,2)
		   if countBV and countBV == 1 then duration = duration * 1.3 end
		   if countBV and countBV == 2 then duration = duration * 1.5 end
	--  Improved Hamstring
		elseif effect == L["dyndebuffs"]["Hamstring"] then
		   local _,_,_,_,countIHS = GetTalentInfo(1,7)
		   if countIHS and countIHS > 0 then duration = duration + (3 * countIHS) end
		end  
	--DRUID
	elseif class == "DRUID" then
	--	Power of Nature
		if effect == L["dyndebuffs"]["Moonfire"] or L["dyndebuffs"]["Insect Swarm"] or L["dyndebuffs"]["Soothe Animal"]or L["dyndebuffs"]["Faerie Fire"] or L["dyndebuffs"]["Hibernate"]then
		   local _,_,_,_,countPON = GetTalentInfo(1,12)
		   if countPON and countPON == 1 then duration = duration*1.25 end
		   if countPON and countPON == 2 then duration = duration*1.5 end
	--	Mighty Roots
		elseif effect == L["dyndebuffs"]["Entangling Roots"] then
			local _,_,_,_,countMR = GetTalentInfo(1,4)
			if countMR and countMR == 1 then duration = duration*1.4 end
			if countMR and countMR == 1 then duration = duration*1.7 end
			if countMR and countMR == 1 then duration = duration*2.0 end
		end 
	--PALADIN
	elseif class == "PALADIN" then
	--	Improved Hammer of Justice
		if effect == L["dyndebuffs"]["Hammer of Justice"] then
		   local _,_,_,_,countHOJ = GetTalentInfo(2,6)
		   if countHOJ and countHOJ > 0 then duration = duration + (countHOJ*.5) end
		end
	end
    return duration
  else
    return 0
  end
end

function libdebuff:GetMaxRank(effect)
  local max = 0
  for id in pairs(L["debuffs"][effect]) do
    if id > max then max = id end
  end
  return max
end

function libdebuff:UpdateUnits()
  if not pfUI.uf or not pfUI.uf.target then return end
  pfUI.uf:RefreshUnit(pfUI.uf.target, "aura")
end

function libdebuff:AddPending(unit, unitlevel, effect, duration)
  if not unit then return end
  if not L["debuffs"][effect] then return end

  if duration > 0 and libdebuff.pending[3] ~= effect then
    libdebuff.pending[1] = unit
    libdebuff.pending[2] = unitlevel or 0
    libdebuff.pending[3] = effect
    libdebuff.pending[4] = duration or libdebuff:GetDuration(effect)
  end
end

function libdebuff:RemovePending()
  libdebuff.pending[1] = nil
  libdebuff.pending[2] = nil
  libdebuff.pending[3] = nil
  libdebuff.pending[4] = nil
end

function libdebuff:PersistPending(effect)
  if not libdebuff.pending[3] then return end
  if libdebuff.pending[3] == effect or ( effect == nil and libdebuff.pending[3] ) then
    libdebuff:AddEffect(libdebuff.pending[1], libdebuff.pending[2], libdebuff.pending[3], libdebuff.pending[4])
    libdebuff:RemovePending()
  end
end

function libdebuff:RevertLastAction()
  lastspell.start = lastspell.start_old
  lastspell.start_old = nil
  libdebuff:UpdateUnits()
end

function libdebuff:AddEffect(unit, unitlevel, effect, duration)
  if not unit or not effect then return end
  unitlevel = unitlevel or 0
  if not libdebuff.objects[unit] then libdebuff.objects[unit] = {} end
  if not libdebuff.objects[unit][unitlevel] then libdebuff.objects[unit][unitlevel] = {} end
  if not libdebuff.objects[unit][unitlevel][effect] then libdebuff.objects[unit][unitlevel][effect] = {} end

  -- save current effect as lastspell
  lastspell = libdebuff.objects[unit][unitlevel][effect]

  libdebuff.objects[unit][unitlevel][effect].effect = effect
  libdebuff.objects[unit][unitlevel][effect].start_old = libdebuff.objects[unit][unitlevel][effect].start
  libdebuff.objects[unit][unitlevel][effect].start = GetTime()
  libdebuff.objects[unit][unitlevel][effect].duration = duration or libdebuff:GetDuration(effect)

  libdebuff:UpdateUnits()
end

-- scan for debuff application
libdebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
libdebuff:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
libdebuff:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
libdebuff:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
libdebuff:RegisterEvent("PLAYER_TARGET_CHANGED")
libdebuff:RegisterEvent("SPELLCAST_STOP")
libdebuff:RegisterEvent("UNIT_AURA")

-- register seal handler
if class == "PALADIN" then
  libdebuff:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
end

-- Remove Pending
libdebuff.rp = { SPELLIMMUNESELFOTHER, IMMUNEDAMAGECLASSSELFOTHER,
  SPELLMISSSELFOTHER, SPELLRESISTSELFOTHER, SPELLEVADEDSELFOTHER,
  SPELLDODGEDSELFOTHER, SPELLDEFLECTEDSELFOTHER, SPELLREFLECTSELFOTHER,
  SPELLPARRIEDSELFOTHER, SPELLLOGABSORBSELFOTHER }

libdebuff.objects = {}
libdebuff.pending = {}

-- Gather Data by Events
libdebuff:SetScript("OnEvent", function()
  -- paladin seal refresh
  if event == "CHAT_MSG_COMBAT_SELF_HITS" then
    local hit = cmatch(arg1, COMBATHITSELFOTHER)
    local crit = cmatch(arg1, COMBATHITCRITSELFOTHER)
    if hit or crit then
      for seal in L["judgements"] do
        local name = UnitName("target")
        local level = UnitLevel("target")
        if name and libdebuff.objects[name] then
          if level and libdebuff.objects[name][level] and libdebuff.objects[name][level][seal] then
            libdebuff:AddEffect(name, level, seal)
          elseif libdebuff.objects[name][0] and libdebuff.objects[name][0][seal] then
            libdebuff:AddEffect(name, 0, seal)
          end
        end
      end
    end

  -- Add Combat Log
  elseif event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
    local unit, effect = cmatch(arg1, AURAADDEDOTHERHARMFUL)
    if unit and effect then
      local unitlevel = UnitName("target") == unit and UnitLevel("target") or 0
      if not libdebuff.objects[unit] or not libdebuff.objects[unit][unitlevel] or not libdebuff.objects[unit][unitlevel][effect] then
        libdebuff:AddEffect(unit, unitlevel, effect)
      end
    end

  -- Add Missing Buffs by Iteration
  elseif ( event == "UNIT_AURA" and arg1 == "target" ) or event == "PLAYER_TARGET_CHANGED" then
    for i=1, 16 do
      local effect, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", i)

      -- abort when no further debuff was found
      if not texture then return end

      if texture and effect and effect ~= "" then
        -- don't overwrite existing timers
        local unitlevel = UnitLevel("target") or 0
        local unit = UnitName("target")
        if not libdebuff.objects[unit] or not libdebuff.objects[unit][unitlevel] or not libdebuff.objects[unit][unitlevel][effect] then
          libdebuff:AddEffect(unit, unitlevel, effect)
        end
      end
    end

  -- Update Pending Spells
  elseif event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER" or event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
    -- Remove pending spell
    for _, msg in pairs(libdebuff.rp) do
      local effect = cmatch(arg1, msg)
      if effect and libdebuff.pending[3] == effect then
        -- instant removal of the pending spell
        libdebuff:RemovePending()
        return
      elseif effect and lastspell and lastspell.start_old and lastspell.effect == effect then
        -- late removal of debuffs (e.g hunter arrows as they hit late)
        libdebuff:RevertLastAction()
        return
      end
    end
  elseif event == "SPELLCAST_STOP" then
    QueueFunction(libdebuff.PersistPending)
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

function libdebuff:UnitDebuff(unit, id)
  local unitname = UnitName(unit)
  local unitlevel = UnitLevel(unit)
  local texture, stacks, dtype = UnitDebuff(unit, id)
  local duration, timeleft = nil, -1
  local rank = nil -- no backport
  local effect

  if texture then
    scanner:SetUnitDebuff(unit, id)
    effect = scanner:Line(1) or ""
  end

  if libdebuff.objects[unitname] and libdebuff.objects[unitname][unitlevel] and libdebuff.objects[unitname][unitlevel][effect] then
    -- clean up cache
    if libdebuff.objects[unitname][unitlevel][effect].duration and libdebuff.objects[unitname][unitlevel][effect].duration + libdebuff.objects[unitname][unitlevel][effect].start < GetTime() then
      libdebuff.objects[unitname][unitlevel][effect] = nil
    else
      duration = libdebuff.objects[unitname][unitlevel][effect].duration
      timeleft = duration + libdebuff.objects[unitname][unitlevel][effect].start - GetTime()
    end

  -- no level data
  elseif libdebuff.objects[unitname] and libdebuff.objects[unitname][0] and libdebuff.objects[unitname][0][effect] then
    -- clean up cache
    if libdebuff.objects[unitname][0][effect].duration and libdebuff.objects[unitname][0][effect].duration + libdebuff.objects[unitname][0][effect].start < GetTime() then
      libdebuff.objects[unitname][0][effect] = nil
    else
      duration = libdebuff.objects[unitname][0][effect].duration
      timeleft = duration + libdebuff.objects[unitname][0][effect].start - GetTime()
    end
  end

  return effect, rank, texture, stacks, dtype, duration, timeleft
end

-- add libdebuff to pfUI API
pfUI.api.libdebuff = libdebuff
