pfUI:RegisterModule("autoshift", function ()
  pfUI.autoshift = CreateFrame("Frame")
  pfUI.autoshift:RegisterEvent("UI_ERROR_MESSAGE")

  pfUI.autoshift.lastError = ""
  pfUI.autoshift.CastSpellByName = _G["CastSpellByName"]
  pfUI.autoshift.scanString = string.gsub(SPELL_FAILED_ONLY_SHAPESHIFT, "%%s", "(.+)")

  function pfUI.autoshift:SwitchStance()
    for stance in string.gfind(pfUI.autoshift.lastError, pfUI.autoshift.scanString) do
      for _, stance in pairs({ strsplit(",", stance)}) do
        pfUI.autoshift.CastSpellByName(string.gsub(stance,"^%s*(.-)%s*$", "%1"))
      end
    end
    pfUI.autoshift.lastError = ""
  end

  hooksecurefunc("CastSpell", function(spellId, spellbookTabNum)
    pfUI.autoshift:SwitchStance()
  end)

  hooksecurefunc("CastSpellByName", function(spellName, onSelf)
    pfUI.autoshift:SwitchStance()
  end)

  hooksecurefunc("UseAction", function(slot, checkCursor, onSelf)
    pfUI.autoshift:SwitchStance()
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
