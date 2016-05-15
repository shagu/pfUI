pfUI:RegisterModule("autoshift", function ()
  pfUI.autoshift = CreateFrame("Frame")
  pfUI.autoshift:RegisterEvent("UI_ERROR_MESSAGE")

  pfUI.autoshift.LastErr = ""
  Hook_CastSpell = CastSpell
  Hook_CastSpellByName = CastSpellByName
  Hook_UseAction = UseAction

  -- deDE
  pfUI.autoshift.wantBattleStance = "Muss in Kampfhaltung sein."
  pfUI.autoshift.wantBattleDefStance = "Muss in Kampfhaltung, Verteidigungshaltung sein."
  pfUI.autoshift.BattleStance = "Kampfhaltung"
  pfUI.autoshift.BattleStance = "Kampfhaltung"
  pfUI.autoshift.wantBerserkerStance = "Muss in Berserkerhaltung sein."
  pfUI.autoshift.BerserkerStance = "Berserkerhaltung"
  pfUI.autoshift.wantDefensiveStance = "Muss in Verteidigungshaltung sein."
  pfUI.autoshift.DefensiveStance = "Verteidigungshaltung"

  function CastSpell(spellId, spellbookTabNum)
    if pfUI.autoshift.LastErr == pfUI.autoshift.wantBattleStance then
      Hook_CastSpellByName(pfUI.autoshift.BattleStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantBattleDefStance then
      Hook_CastSpellByName(pfUI.autoshift.BattleStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantBerserkerStance then
      Hook_CastSpellByName(pfUI.autoshift.BerserkerStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantDefensiveStance then
      Hook_CastSpellByName(pfUI.autoshift.DefensiveStance)
    end
    pfUI.autoshift.LastErr = ""

    Hook_CastSpell(spellId, spellbookTabNum)
  end

  function CastSpellByName(spellName, onSelf)
    if pfUI.autoshift.LastErr == pfUI.autoshift.wantBattleStance then
      Hook_CastSpellByName(pfUI.autoshift.BattleStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantBattleDefStance then
      Hook_CastSpellByName(pfUI.autoshift.BattleStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantBerserkerStance then
      Hook_CastSpellByName(pfUI.autoshift.BerserkerStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantDefensiveStance then
      Hook_CastSpellByName(pfUI.autoshift.DefensiveStance)
    end
    pfUI.autoshift.LastErr = ""

    Hook_CastSpellByName(spellName, onSelf)
  end

  function UseAction(slot, checkCursor, onSelf)
    if pfUI.autoshift.LastErr == pfUI.autoshift.wantBattleStance then
      Hook_CastSpellByName(pfUI.autoshift.BattleStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantBattleDefStance then
      Hook_CastSpellByName(pfUI.autoshift.BattleStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantBerserkerStance then
      Hook_CastSpellByName(pfUI.autoshift.BerserkerStance)
    elseif pfUI.autoshift.LastErr == pfUI.autoshift.wantDefensiveStance then
      Hook_CastSpellByName(pfUI.autoshift.DefensiveStance)
    end
    pfUI.autoshift.LastErr = ""

    Hook_UseAction(slot, checkCursor, onSelf)
  end

  pfUI.autoshift.Buffs = { "spell_nature_swiftness", "_mount_", "_qirajicrystal_",
    "ability_racial_bearform", "ability_druid_catform", "ability_druid_travelform",
    "spell_nature_forceofnature", "ability_druid_aquaticform", "spell_shadow_shadowform",
    "spell_nature_spiritwolf" }

  pfUI.autoshift.Errors = { SPELL_FAILED_NOT_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_SHAPESHIFT, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED,
    SPELL_NOT_SHAPESHIFTED_NOSPACE, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED,
    ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,ERR_MOUNT_SHAPESHIFTED,
    ERR_EMBLEMERROR_NOTABARDGEOSET }

  pfUI.autoshift:SetScript("OnEvent", function()
      pfUI.autoshift.LastErr = arg1

      for id, errorstring in pairs(pfUI.autoshift.Errors) do
        if arg1 == errorstring then
          for i=0,15,1 do
            currBuffTex = GetPlayerBuffTexture(i);
            if (currBuffTex) then
              for id, bufftype in pairs(pfUI.autoshift.Buffs) do
                if string.find(string.lower(currBuffTex), bufftype) then
                  CancelPlayerBuff(i);
                end
              end
            end
          end
        end
      end
    end)
end)
