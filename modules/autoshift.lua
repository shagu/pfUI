pfUI:RegisterModule("autoshift", function ()
  pfUI.autoshift = CreateFrame("Frame")
  pfUI.autoshift:RegisterEvent("UI_ERROR_MESSAGE")

  pfUI.autoshift.lastError = ""
  pfUI.autoshift.CastSpellByName = _G["CastSpellByName"]

  Hook("CastSpell", function(spellId, spellbookTabNum)
    if pfUI.autoshift.lastError == L["stances"]['wantBattleStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BattleStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBattleDefStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BattleStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBattleBerserkStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBerserkerStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantDefensiveStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['DefensiveStance'])
    end
    pfUI.autoshift.lastError = ""
  end)

  Hook("CastSpellByName", function(spellName, onSelf)
    if pfUI.autoshift.lastError == L["stances"]['wantBattleStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BattleStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBattleDefStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BattleStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBattleBerserkStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBerserkerStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantDefensiveStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['DefensiveStance'])
    end
    pfUI.autoshift.lastError = ""
  end)

  Hook("UseAction", function(slot, checkCursor, onSelf)
    if pfUI.autoshift.lastError == L["stances"]['wantBattleStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BattleStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBattleDefStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BattleStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBattleBerserkStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantBerserkerStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['BerserkerStance'])
    elseif pfUI.autoshift.lastError == L["stances"]['wantDefensiveStance'] then
      pfUI.autoshift.CastSpellByName(L["stances"]['DefensiveStance'])
    end
    pfUI.autoshift.lastError = ""
  end)

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
          for i=0,31,1 do
            currBuffTex = GetPlayerBuffTexture(i)
            if (currBuffTex) then
              for id, bufftype in pairs(pfUI.autoshift.buffs) do
                if string.find(string.lower(currBuffTex), bufftype, 1) then
                  if string.find(string.lower(currBuffTex), "spell_shadow_shadowform", 1) then
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
