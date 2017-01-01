pfUI:RegisterModule("autoshift", function ()
  pfUI.autoshift = CreateFrame("Frame")
  pfUI.autoshift:RegisterEvent("UI_ERROR_MESSAGE")

  pfUI.autoshift.lastError = ""

  if not pfUI.autoshift.hookCastSpell then
    pfUI.autoshift.hookCastSpell = CastSpell
  end

  if not pfUI.autoshift.hookCastSpellByName then
    pfUI.autoshift.hookCastSpellByName = CastSpellByName
  end

  if not pfUI.autoshift.hookUseAction then
    pfUI.autoshift.hookUseAction = UseAction
  end

  function CastSpell(spellId, spellbookTabNum)
    if pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BattleStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleDefStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BattleStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleBerserkStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBerserkerStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantDefensiveStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['DefensiveStance'])
    end
    pfUI.autoshift.lastError = ""

    pfUI.autoshift.hookCastSpell(spellId, spellbookTabNum)
  end

  function CastSpellByName(spellName, onSelf)
    if pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BattleStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleDefStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BattleStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleBerserkStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBerserkerStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantDefensiveStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['DefensiveStance'])
    end
    pfUI.autoshift.lastError = ""

    pfUI.autoshift.hookCastSpellByName(spellName, onSelf)
  end

  function UseAction(slot, checkCursor, onSelf)
    if pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BattleStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleDefStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BattleStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBattleBerserkStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantBerserkerStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == pfLocaleShift[pfUI.cache["locale"]]['wantDefensiveStance'] then
      pfUI.autoshift.hookCastSpellByName(pfLocaleShift[pfUI.cache["locale"]]['DefensiveStance'])
    end
    pfUI.autoshift.lastError = ""

    pfUI.autoshift.hookUseAction(slot, checkCursor, onSelf)
  end

  pfUI.autoshift.buffs = { "spell_nature_swiftness", "_mount_", "_qirajicrystal_",
    "ability_racial_bearform", "ability_druid_catform", "ability_druid_travelform",
    "spell_nature_forceofnature", "ability_druid_aquaticform", "spell_shadow_shadowform",
    "spell_nature_spiritwolf" }

  pfUI.autoshift.errors = { SPELL_FAILED_NOT_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_SHAPESHIFT, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED,
    SPELL_NOT_SHAPESHIFTED_NOSPACE, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED,
    ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,ERR_MOUNT_SHAPESHIFTED,
    ERR_EMBLEMERROR_NOTABARDGEOSET }

  pfUI.autoshift:SetScript("OnEvent", function()
      pfUI.autoshift.lastError = arg1
      local CancelLater = nil

      if arg1 == SPELL_FAILED_NOT_STANDING then
        SitOrStand()
        return
      end

      for id, errorstring in pairs(pfUI.autoshift.errors) do
        if arg1 == errorstring then
          for i=0,15,1 do
            currBuffTex = GetPlayerBuffTexture(i)
            if (currBuffTex) then
              for id, bufftype in pairs(pfUI.autoshift.buffs) do
                if string.find(string.lower(currBuffTex), bufftype) then
                  if string.find(string.lower(currBuffTex), "spell_shadow_shadowform") then
                    CancelLater = i
                  else
                    CancelPlayerBuff(i)
                    return
                  end
                end
              end
            end
          end
          if CancelLater then
            CancelPlayerBuff(CancelLater)
          end
        end
      end
    end)
end)
