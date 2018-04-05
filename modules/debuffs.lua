pfUI:RegisterModule("debuffs", function ()
  if C.appearance.cd.debuffs ~= "1" then return end

  pfUI.debuffs = CreateFrame("Frame", "pfdebuffsScanner", UIParent)
  pfUI.debuffs.pfDebuffNameScan = CreateFrame('GameTooltip', "pfDebuffNameScan", UIParent, "GameTooltipTemplate")

  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")

  pfUI.debuffs:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.debuffs:RegisterEvent("SPELLCAST_STOP")
  pfUI.debuffs:RegisterEvent("UNIT_AURA")

  pfUI.debuffs.active = true

  -- CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
  pfUI.debuffs.combatlog = SanitizePattern(AURAADDEDOTHERHARMFUL)


  -- Remove Pending
  pfUI.debuffs.rp = { SanitizePattern(SPELLFAILCASTSELF), SanitizePattern(SPELLFAILPERFORMSELF), SanitizePattern(SPELLIMMUNESELFOTHER),
    SanitizePattern(IMMUNEDAMAGECLASSSELFOTHER), SanitizePattern(SPELLMISSSELFOTHER), SanitizePattern(SPELLRESISTSELFOTHER),
    SanitizePattern(SPELLEVADEDSELFOTHER), SanitizePattern(SPELLDODGEDSELFOTHER), SanitizePattern(SPELLDEFLECTEDSELFOTHER),
    SanitizePattern(SPELLREFLECTSELFOTHER), SanitizePattern(SPELLPARRIEDSELFOTHER), SanitizePattern(SPELLLOGABSORBSELFOTHER) }

  -- Persist Pending
  pfUI.debuffs.pp = { SanitizePattern(SPELLCASTGOSELF), SanitizePattern(SPELLPERFORMGOSELF), SanitizePattern(SPELLLOGSCHOOLSELFOTHER),
    SanitizePattern(SPELLLOGCRITSCHOOLSELFOTHER), SanitizePattern(SPELLLOGSELFOTHER), SanitizePattern(SPELLLOGCRITSELFOTHER) }

  pfUI.debuffs.objects = {}
  pfUI.debuffs.pending = {}

  -- Gather Data by Events
  pfUI.debuffs:SetScript("OnEvent", function()
    -- Add Combat Log
    if event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
      for unit, effect in string.gfind(arg1, pfUI.debuffs.combatlog) do
        local unitlevel = UnitName("target") == unit and UnitLevel("target") or 0

        if not pfUI.debuffs.objects[unit] or not pfUI.debuffs.objects[unit][unitlevel] or not pfUI.debuffs.objects[unit][unitlevel][effect] then
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
      for _, msg in pairs(pfUI.debuffs.pp) do
        for effect, _ in string.gfind(arg1, msg) do
          pfUI.debuffs:PersistPending(effect)
          return
        end
      end

      -- Remove pending spell
      for _, msg in pairs(pfUI.debuffs.rp) do
        for effect, _ in string.gfind(arg1, msg) do
          pfUI.debuffs:RemovePending(effect)
          return
        end
      end
    elseif event == "SPELLCAST_STOP" then
      -- Persist all spells that have not been removed till here
      pfUI.debuffs:PersistPending()
    end
  end)

  -- Gather Data by User Actions
  hooksecurefunc("CastSpell", function(id, bookType)
    local effect = GetSpellName(id, bookType)
    local _, rank = GetSpellInfo(id, bookType)
    local duration = pfUI.debuffs:GetDuration(effect, rank)
    pfUI.debuffs:AddPending(UnitName("target"), UnitLevel("target"), effect, duration)
  end, true)

  hooksecurefunc("CastSpellByName", function(effect, target)
    local _, rank = GetSpellInfo(effect)
    local duration = pfUI.debuffs:GetDuration(effect, rank)
    pfUI.debuffs:AddPending(UnitName("target"), UnitLevel("target"), effect, duration)
  end, true)

  local scanner = CreateFrame("GameTooltip", "pfDebuffSpellScanner", nil, "GameTooltipTemplate")
  scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
  hooksecurefunc("UseAction", function(slot, target, button)
    if GetActionText(slot) or not IsCurrentAction(slot) then return end
    scanner:ClearLines()
    scanner:SetAction(slot)
    local effect = pfDebuffSpellScannerTextLeft1:IsVisible() and pfDebuffSpellScannerTextLeft1:GetText()
    local rank = pfDebuffSpellScannerTextRight1:IsVisible() and pfDebuffSpellScannerTextRight1:GetText()
    local duration = pfUI.debuffs:GetDuration(effect, rank)
    pfUI.debuffs:AddPending(UnitName("target"), UnitLevel("target"), effect, duration)
  end, true)

  function pfUI.debuffs:GetDuration(effect, rank)
    if L["debuffs"][effect] and rank then
      local rank = string.gsub(rank, RANK .. " ", "")
      local duration = L["debuffs"][effect][tonumber(rank)] or pfUI.debuffs:GetDuration(effect)
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
      return L["debuffs"][effect][pfUI.debuffs:GetMaxRank(effect)]
    else
      return 0
    end
  end

  function pfUI.debuffs:AddPending(unit, unitlevel, effect, duration)
    if not unit then return end
    if not L["debuffs"][effect] then return end
    local duration = duration or pfUI.debuffs:GetDuration(effect)
    local unitlevel = unitlevel or 0

    if duration > 0 then
      pfUI.debuffs.pending = { unit, unitlevel, effect, duration }
    end
  end

  function pfUI.debuffs:PersistPending(effect)
    if pfUI.debuffs.pending[3] == effect or ( effect == nil and pfUI.debuffs.pending[3] ) then

      local unit = pfUI.debuffs.pending[1]
      local unitlevel = pfUI.debuffs.pending[2]
      local effect = pfUI.debuffs.pending[3]
      local duration = pfUI.debuffs.pending[4]

      pfUI.debuffs:AddEffect(unit, unitlevel, effect, duration)
    end
  end

  function pfUI.debuffs:RemovePending(effect)
    if pfUI.debuffs.pending[3] == effect then
      pfUI.debuffs.pending = {}
    end
  end

  function pfUI.debuffs:GetMaxRank(effect)
    local max = 0
    for id in pairs(L["debuffs"][effect]) do
      if id > max then max = id end
    end
    return max
  end

  function pfUI.debuffs:AddEffect(unit, unitlevel, effect, duration)
    if not unit or not effect then return end
    unitlevel = unitlevel or 0
    if not pfUI.debuffs.objects[unit] then pfUI.debuffs.objects[unit] = {} end
    if not pfUI.debuffs.objects[unit][unitlevel] then pfUI.debuffs.objects[unit][unitlevel] = {} end
    if not pfUI.debuffs.objects[unit][unitlevel][effect] then pfUI.debuffs.objects[unit][unitlevel][effect] = {} end

    pfUI.debuffs.objects[unit][unitlevel][effect].start = GetTime()
    pfUI.debuffs.objects[unit][unitlevel][effect].duration = duration or pfUI.debuffs:GetDuration(effect)

    pfUI.debuffs.pending = {}

    if pfUI.uf.target then
      pfUI.uf:RefreshUnit(pfUI.uf.target, "aura")
    end
  end


  -- [[ global debuff functions ]] --
  function pfUI.debuffs:GetDebuffName(unit, index)
    pfUI.debuffs.pfDebuffNameScan:SetOwner(UIParent, "ANCHOR_NONE")
    pfUI.debuffs.pfDebuffNameScan:SetUnitDebuff(unit, index)
    local text = getglobal("pfDebuffNameScanTextLeft1")
    return ( text ) and text:GetText() or ""
  end

  function pfUI.debuffs:GetDebuffInfo(unit, effect)
    local unitname = UnitName(unit)
    local unitlevel = UnitLevel(unit)

    if pfUI.debuffs.objects[unitname] and pfUI.debuffs.objects[unitname][unitlevel] and pfUI.debuffs.objects[unitname][unitlevel][effect] then
      -- clean up db
      if pfUI.debuffs.objects[unitname][unitlevel][effect].duration and pfUI.debuffs.objects[unitname][unitlevel][effect].duration + pfUI.debuffs.objects[unitname][unitlevel][effect].start < GetTime() then
        pfUI.debuffs.objects[unitname][unitlevel][effect] = nil
        return 0, 0, 0
      end
      local start = pfUI.debuffs.objects[unitname][unitlevel][effect].start
      local duration = pfUI.debuffs.objects[unitname][unitlevel][effect].duration
      local timeleft = duration + start - GetTime()

      return start, duration, timeleft

    -- no level data
    elseif pfUI.debuffs.objects[unitname] and pfUI.debuffs.objects[unitname][0] and pfUI.debuffs.objects[unitname][0][effect] then
      -- clean up db
      if pfUI.debuffs.objects[unitname][0][effect].duration and pfUI.debuffs.objects[unitname][0][effect].duration + pfUI.debuffs.objects[unitname][0][effect].start < GetTime() then
        pfUI.debuffs.objects[unitname][0][effect] = nil
        return 0, 0, 0
      end
      local start = pfUI.debuffs.objects[unitname][0][effect].start
      local duration = pfUI.debuffs.objects[unitname][0][effect].duration
      local timeleft = duration + start - GetTime()

      return start, duration, timeleft
    else
      return 0, 0, 0
    end
  end
end)
