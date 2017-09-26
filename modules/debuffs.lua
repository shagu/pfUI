pfUI:RegisterModule("debuffs", function ()
  if C.appearance.cd.debuffs ~= "1" then return end

  pfUI.debuffs = CreateFrame("Frame", "pfdebuffsScanner", UIParent)
  pfUI.debuffs.pfDebuffNameScan = CreateFrame('GameTooltip', "pfDebuffNameScan", UIParent, "GameTooltipTemplate")

  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_FAILED_LOCALPLAYER")
  pfUI.debuffs:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
  pfUI.debuffs:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.debuffs:RegisterEvent("UNIT_AURA")

  pfUI.debuffs.active = true

  -- CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE // CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE
  pfUI.debuffs.AURAADDEDOTHERHARMFUL = SanitizePattern(AURAADDEDOTHERHARMFUL)

  -- CHAT_MSG_SPELL_FAILED_LOCALPLAYER
  pfUI.debuffs.SPELLFAILCASTSELF = SanitizePattern(SPELLFAILCASTSELF)
  pfUI.debuffs.SPELLFAILPERFORMSELF = SanitizePattern(SPELLFAILPERFORMSELF)
  pfUI.debuffs.SPELLIMMUNESELFOTHER = SanitizePattern(SPELLIMMUNESELFOTHER)

  -- CHAT_MSG_SPELL_SELF_DAMAGE
  pfUI.debuffs.IMMUNEDAMAGECLASSSELFOTHER = SanitizePattern(IMMUNEDAMAGECLASSSELFOTHER)
  pfUI.debuffs.SPELLMISSSELFOTHER = SanitizePattern(SPELLMISSSELFOTHER)
  pfUI.debuffs.SPELLRESISTSELFOTHER = SanitizePattern(SPELLRESISTSELFOTHER)
  pfUI.debuffs.SPELLEVADEDSELFOTHER = SanitizePattern(SPELLEVADEDSELFOTHER)
  pfUI.debuffs.SPELLDODGEDSELFOTHER = SanitizePattern(SPELLDODGEDSELFOTHER)
  pfUI.debuffs.SPELLDEFLECTEDSELFOTHER = SanitizePattern(SPELLDEFLECTEDSELFOTHER)
  pfUI.debuffs.SPELLREFLECTSELFOTHER = SanitizePattern(SPELLREFLECTSELFOTHER)
  pfUI.debuffs.SPELLPARRIEDSELFOTHER = SanitizePattern(SPELLPARRIEDSELFOTHER)
  pfUI.debuffs.SPELLLOGABSORBSELFOTHER = SanitizePattern(SPELLLOGABSORBSELFOTHER)

  pfUI.debuffs.objects = {}

  -- Gather Data by Events
  pfUI.debuffs:SetScript("OnEvent", function()
    -- Add Combat Log
    if event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
      for unit, effect in string.gfind(arg1, pfUI.debuffs.AURAADDEDOTHERHARMFUL) do
        if UnitName("target") == unit then
          this:AddEffect(unit, UnitLevel("target"), effect)
        else
          this:AddEffect(unit, 0, effect)
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

    -- Remove Pending Spells on Failure
    elseif event == "SPELLCAST_FAILED" or event == "CHAT_MSG_SPELL_FAILED_LOCALPLAYER" or event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
      -- CHAT_MSG_SPELL_FAILED_LOCALPLAYER
      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLFAILCASTSELF) do -- "You fail to cast %s: %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLFAILPERFORMSELF) do -- "You fail to perform %s: %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLIMMUNESELFOTHER) do -- "Your %s failed. %s is immune.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      -- CHAT_MSG_SPELL_SELF_DAMAGE
      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLMISSSELFOTHER) do -- "Your %s was resisted by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLEVADEDSELFOTHER) do -- "Your %s was evaded by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLDODGEDSELFOTHER) do -- "Your %s was deflected by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLDODGEDSELFOTHER) do -- "Your %s was dodged by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLDEFLECTEDSELFOTHER) do -- "Your %s was deflected by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLREFLECTSELFOTHER) do -- "Your %s is reflected back by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLPARRIEDSELFOTHER) do -- "Your %s is parried by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

      for effect, _ in string.gfind(arg1, pfUI.debuffs.SPELLLOGABSORBSELFOTHER) do --  "Your %s is absorbed by %s.";
        pfUI.debuffs:RemovePending(pfUI.debuffs.lastUnit, pfUI.debuffs.lastLevel, effect)
        return
      end

    end
  end)

  -- Gather Data by User Actions
  hooksecurefunc("CastSpell", function(id, bookType)
    local effect = GetSpellName(id, bookType)
    pfUI.debuffs:AddPending(UnitName("target"), UnitLevel("target"), effect)
  end, true)

  hooksecurefunc("CastSpellByName", function(effect, target)
    pfUI.debuffs:AddPending(UnitName("target"), UnitLevel("target"), effect)
  end, true)

  local scanner = CreateFrame("GameTooltip", "pfDebuffSpellScanner", nil, "GameTooltipTemplate")
  scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
  hooksecurefunc("UseAction", function(slot, target, button)
    if GetActionText(slot) or not IsCurrentAction(slot) then return end
    scanner:ClearLines()
    scanner:SetAction(slot)
    local effect = pfDebuffSpellScannerTextLeft1:GetText()
    pfUI.debuffs:AddPending(UnitName("target"), UnitLevel("target"), effect)
  end, true)

  function pfUI.debuffs:RemovePending(unit, unitlevel, effect)
    if unit and unitlevel and effect then
      if pfUI.debuffs.objects[unit] and
        pfUI.debuffs.objects[unit][unitlevel] and
        pfUI.debuffs.objects[unit][unitlevel][effect] and
        pfUI.debuffs.objects[unit][unitlevel][effect].old and
        pfUI.debuffs.objects[unit][unitlevel][effect].old.start
      then
        local new = floor(pfUI.debuffs.objects[unit][unitlevel][effect].start + pfUI.debuffs.objects[unit][unitlevel][effect].duration - GetTime())
        local saved = floor(pfUI.debuffs.objects[unit][unitlevel][effect].old.start + pfUI.debuffs.objects[unit][unitlevel][effect].old.duration  - GetTime())

        pfUI.debuffs.objects[unit][unitlevel][effect].start = pfUI.debuffs.objects[unit][unitlevel][effect].old.start
        pfUI.debuffs.objects[unit][unitlevel][effect].duration = pfUI.debuffs.objects[unit][unitlevel][effect].old.duration
        pfUI.debuffs.objects[unit][unitlevel][effect].old = {}

        if pfUI.uf.target then
          pfUI.uf:RefreshUnit(pfUI.uf.target, "aura")
        end
      end
    end
  end

  function pfUI.debuffs:AddPending(unit, unitlevel, effect)
    if not unit then return end
    if not L["debuffs"][effect] then return end

    unitlevel = unitlevel or 0
    --message("add  pending effect " .. unit .. "("  .. unitlevel .. ") - " .. effect)
    if not pfUI.debuffs.objects[unit] then pfUI.debuffs.objects[unit] = {} end
    if not pfUI.debuffs.objects[unit][unitlevel] then pfUI.debuffs.objects[unit][unitlevel] = {} end
    if not pfUI.debuffs.objects[unit][unitlevel][effect] then pfUI.debuffs.objects[unit][unitlevel][effect] = {} end
    if pfUI.debuffs.objects[unit][unitlevel][effect].old and
      pfUI.debuffs.objects[unit][unitlevel][effect].old.start then
      --message("already pending")
      return
    end

    -- save old values in case of failure
    pfUI.debuffs.objects[unit][unitlevel][effect].old = {}
    pfUI.debuffs.objects[unit][unitlevel][effect].old.start = pfUI.debuffs.objects[unit][unitlevel][effect].start
    pfUI.debuffs.objects[unit][unitlevel][effect].old.duration = pfUI.debuffs.objects[unit][unitlevel][effect].duration

    -- set new ones
    pfUI.debuffs.objects[unit][unitlevel][effect].start = GetTime()
    pfUI.debuffs.objects[unit][unitlevel][effect].duration = L["debuffs"][effect] or 0

    -- save last unit
    pfUI.debuffs.lastUnit = unit
    pfUI.debuffs.lastLevel = unitlevel

    if pfUI.uf.target then
      pfUI.uf:RefreshUnit(pfUI.uf.target, "aura")
    end
  end

  function pfUI.debuffs:AddEffect(unit, unitlevel, effect)
    if not unit or not effect then return end
    unitlevel = unitlevel or 0
    if not pfUI.debuffs.objects[unit] then pfUI.debuffs.objects[unit] = {} end
    if not pfUI.debuffs.objects[unit][unitlevel] then pfUI.debuffs.objects[unit][unitlevel] = {} end
    if not pfUI.debuffs.objects[unit][unitlevel][effect] then pfUI.debuffs.objects[unit][unitlevel][effect] = {} end

    pfUI.debuffs.objects[unit][unitlevel][effect].old = {}
    pfUI.debuffs.objects[unit][unitlevel][effect].start = GetTime()
    pfUI.debuffs.objects[unit][unitlevel][effect].duration = L["debuffs"][effect] or 0

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
      if pfUI.debuffs.objects[unitname][unitlevel][effect].duration + pfUI.debuffs.objects[unitname][unitlevel][effect].start < GetTime() then
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
      if pfUI.debuffs.objects[unitname][0][effect].duration + pfUI.debuffs.objects[unitname][0][effect].start < GetTime() then
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
