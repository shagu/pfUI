pfUI:RegisterModule("autoshift", "vanilla", function ()
  pfUI.autoshift = CreateFrame("Frame")
  pfUI.autoshift:RegisterEvent("UI_ERROR_MESSAGE")

  pfUI.autoshift.scanString = string.gsub(SPELL_FAILED_ONLY_SHAPESHIFT, "%%s", "(.+)")
  pfUI.autoshift.mounts = {
    -- deDE
    "^Erhöht Tempo um (.+)%%",
    -- enUS
    "^Increases speed by (.+)%%",
    -- esES
    "^Aumenta la velocidad en un (.+)%%",
    -- frFR
    "^Augmente la vitesse de (.+)%%",
    -- ruRU
    "^Скорость увеличена на (.+)%%",
    -- koKR
    "^이동 속도 (.+)%%만큼 증가",
    -- zhCN
    "^速度提高(.+)%%",
    -- turtle-wow
    "speed based on", "Slow and steady...", "Riding",
    "Lento y constante...", "Aumenta la velocidad según tu habilidad de Montar.",
    "根据您的骑行技能提高速度。", "根据骑术技能提高速度。", "又慢又稳......",
  }

  pfUI.autoshift.shapeshifts = {
    "ability_racial_bearform", "ability_druid_catform", "ability_druid_travelform",
    "ability_druid_aquaticform", "spell_shadow_shadowform", "spell_nature_spiritwolf",
  }

  -- an agility buff exists which has the same icon as the moonkin form
  -- therefore only add the moonkin icon to the removable buffs if
  -- moonkin is skilled and player is druid. Frame is required as talentpoints
  -- are only accessible after certain events.
  local moonkin_scan = CreateFrame("Frame")
  moonkin_scan:RegisterEvent("PLAYER_ENTERING_WORLD")
  moonkin_scan:RegisterEvent("UNIT_NAME_UPDATE")
  moonkin_scan:SetScript("OnEvent", function()
    local _, class = UnitClass("player")
    if class == "DRUID" then
      local _,_,_,_,moonkin = GetTalentInfo(1,16)
      if moonkin == 1 then
        table.insert(pfUI.autoshift.shapeshifts, "spell_nature_forceofnature")
        moonkin_scan:UnregisterAllEvents()
      end
    else
      moonkin_scan:UnregisterAllEvents()
    end
  end)

  pfUI.autoshift.errors = { SPELL_FAILED_NOT_MOUNTED, ERR_ATTACK_MOUNTED, ERR_TAXIPLAYERALREADYMOUNTED,
    SPELL_FAILED_NOT_SHAPESHIFT, SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED, SPELL_NOT_SHAPESHIFTED,
    SPELL_NOT_SHAPESHIFTED_NOSPACE, ERR_CANT_INTERACT_SHAPESHIFTED, ERR_NOT_WHILE_SHAPESHIFTED,
    ERR_NO_ITEMS_WHILE_SHAPESHIFTED, ERR_TAXIPLAYERSHAPESHIFTED,ERR_MOUNT_SHAPESHIFTED,
    ERR_EMBLEMERROR_NOTABARDGEOSET }

  pfUI.autoshift.scanner = libtipscan:GetScanner("dismount")

  pfUI.autoshift:SetScript("OnEvent", function()
    -- switch stance if required
    for stances in string.gfind(arg1, pfUI.autoshift.scanString) do
      for _, stance in pairs({ strsplit(",", stances)}) do
        CastSpellByName(string.gsub(stance,"^%s*(.-)%s*$", "%1"))
      end
    end

    -- check if we need to stand up
    if arg1 == SPELL_FAILED_NOT_STANDING then
      SitOrStand()
      return
    end

    -- delay shapeshift cancel
    local CancelLater = nil

    -- scan through buffs and cancel shapeshift/mount
    for id, errorstring in pairs(pfUI.autoshift.errors) do
      if arg1 == errorstring then
        -- dont's cancel form when clicking on npcs while in combat
        if arg1 == ERR_CANT_INTERACT_SHAPESHIFTED and UnitAffectingCombat("player") then
          return
        end

        for i=0,31,1 do
          -- detect mounts based on tooltip text
          pfUI.autoshift.scanner:SetPlayerBuff(i)
          for _, str in pairs(pfUI.autoshift.mounts) do
            if pfUI.autoshift.scanner:Find(str) then
              CancelPlayerBuff(i)
              return
            end
          end

          -- detect shapeshift based on texture
          local buff = GetPlayerBuffTexture(i)
          if buff then
            for id, bufftype in pairs(pfUI.autoshift.shapeshifts) do
              if string.find(string.lower(buff), bufftype, 1) then
                if string.find(string.lower(buff), "spell_shadow_shadowform", 1) then
                  -- only cancel shadow form if no other buff was hindering casting
                  CancelLater = i
                else
                  CancelPlayerBuff(i)
                  return
                end
              end
            end
          end
        end

        -- if nothing else was found, cancel shadowform
        if CancelLater then
          CancelPlayerBuff(CancelLater)
        end
      end
    end
  end)
end)
