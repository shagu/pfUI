pfUI:RegisterModule("castbar", function ()

    local default_border = pfUI_config.appearance.border.default
    if pfUI_config.appearance.border.unitframes ~= "-1" then
      default_border = pfUI_config.appearance.border.unitframes
    end

    pfUI.castbar = CreateFrame("Frame")

    if pfUI.uf.player then

      -- hide blizzard
      if pfUI_config.castbar.player.hide_blizz == "1" then
        CastingBarFrame:UnregisterAllEvents()
        CastingBarFrame:Hide()
      end

      -- setup player castbar
      pfUI.castbar.player = CreateFrame("Frame",nil, pfUI.uf.player)
      pfUI.utils:CreateBackdrop(pfUI.castbar.player, default_border)
      pfUI.castbar.player:SetHeight(pfUI_config.global.font_size * 2)
      pfUI.castbar.player:SetPoint("TOPRIGHT",pfUI.uf.player,"BOTTOMRIGHT",0,-default_border*3)
      pfUI.castbar.player:SetPoint("TOPLEFT",pfUI.uf.player,"BOTTOMLEFT",0,-default_border*3)
      pfUI.castbar.player:Hide()
      pfUI.castbar.player.delay = 0

      -- statusbar
      pfUI.castbar.player.bar = CreateFrame("StatusBar", nil, pfUI.castbar.player)
      pfUI.castbar.player.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.castbar.player.bar:ClearAllPoints()
      pfUI.castbar.player.bar:SetAllPoints(pfUI.castbar.player)
      pfUI.castbar.player.bar:SetMinMaxValues(0, 100)
      pfUI.castbar.player.bar:SetValue(20)
      pfUI.castbar.player.bar:SetStatusBarColor(.7,.7,.9,.8)

      -- text left
      pfUI.castbar.player.bar.left = pfUI.castbar.player.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      pfUI.castbar.player.bar.left:ClearAllPoints()
      pfUI.castbar.player.bar.left:SetPoint("TOPLEFT", pfUI.castbar.player.bar, "TOPLEFT", 3, 0)
      pfUI.castbar.player.bar.left:SetPoint("BOTTOMRIGHT", pfUI.castbar.player.bar, "BOTTOMRIGHT", -3, 0)
      pfUI.castbar.player.bar.left:SetNonSpaceWrap(false)
      pfUI.castbar.player.bar.left:SetFontObject(GameFontWhite)
      pfUI.castbar.player.bar.left:SetTextColor(1,1,1,1)
      pfUI.castbar.player.bar.left:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.castbar.player.bar.left:SetText("left")
      pfUI.castbar.player.bar.left:SetJustifyH("left")

      -- text right
      pfUI.castbar.player.bar.right = pfUI.castbar.player.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      pfUI.castbar.player.bar.right:ClearAllPoints()
      pfUI.castbar.player.bar.right:SetPoint("TOPLEFT", pfUI.castbar.player.bar, "TOPLEFT", 3, 0)
      pfUI.castbar.player.bar.right:SetPoint("BOTTOMRIGHT", pfUI.castbar.player.bar, "BOTTOMRIGHT", -3, 0)
      pfUI.castbar.player.bar.right:SetNonSpaceWrap(false)
      pfUI.castbar.player.bar.right:SetFontObject(GameFontWhite)
      pfUI.castbar.player.bar.right:SetTextColor(1,1,1,1)
      pfUI.castbar.player.bar.right:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.castbar.player.bar.right:SetText("right")
      pfUI.castbar.player.bar.right:SetJustifyH("right")

      -- events
      pfUI.castbar.player:RegisterEvent("SPELLCAST_START")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_STOP")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_DELAYED")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_START")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_STOP")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_FAILED")
      pfUI.castbar.player:RegisterEvent("SPELLCAST_INTERRUPTED")

      pfUI.castbar.player:SetScript("OnEvent", function ()
        if ( event == "SPELLCAST_START" ) then
          pfUI.castbar.player.delay = 0
          pfUI.castbar.player.spell = arg1
          pfUI.castbar.player.bar.left:SetText(arg1)
          pfUI.castbar.player.bar:SetStatusBarColor(.7,.7,.9,.8)
          pfUI.castbar.player.startTime = GetTime()
          pfUI.castbar.player.maxValue = pfUI.castbar.player.startTime + (arg2 / 1000)
          pfUI.castbar.player.endTime = nil
          pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.maxValue)
          pfUI.castbar.player.bar:SetValue(pfUI.castbar.player.startTime)
          pfUI.castbar.player.holdTime = 0
          pfUI.castbar.player.casting = 1
          pfUI.castbar.player.mode = "casting"
          pfUI.castbar.player.fadeout = nil
          pfUI.castbar.player:SetAlpha(1)
          pfUI.castbar.player:Show()

        elseif ( event == "SPELLCAST_CHANNEL_START" ) then
          pfUI.castbar.player.delay = 0
          pfUI.castbar.player.spell = arg2
          pfUI.castbar.player.bar.left:SetText(arg2)
          pfUI.castbar.player.bar:SetStatusBarColor(.9,.9,.7,.8)
          pfUI.castbar.player.maxValue = nil
          pfUI.castbar.player.startTime = GetTime()
          pfUI.castbar.player.endTime = pfUI.castbar.player.startTime + (arg1 / 1000)
          pfUI.castbar.player.duration = arg1 / 1000
          pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.endTime)
          pfUI.castbar.player.bar:SetValue(pfUI.castbar.player.endTime)
          pfUI.castbar.player.holdTime = 0
          pfUI.castbar.player.casting = nil
          pfUI.castbar.player.channeling = 1
          pfUI.castbar.player.fadeout = nil
          pfUI.castbar.player:SetAlpha(1)
          pfUI.castbar.player:Show()

        elseif event == "SPELLCAST_STOP" then
          if pfUI.castbar.player.casting then
            pfUI.castbar.player.fadeout = 1
            pfUI.castbar.player.bar:SetMinMaxValues(1,pfUI.castbar.player.bar:GetValue())
          end

        elseif event == "SPELLCAST_CHANNEL_STOP" then
          if pfUI.castbar.player.channeling then
            pfUI.castbar.player.fadeout = 1
            pfUI.castbar.player.bar:SetMinMaxValues(1,pfUI.castbar.player.bar:GetValue())
          end

        elseif event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" then
            pfUI.castbar.player.fadeout = 1
            pfUI.castbar.player.bar:SetStatusBarColor(1,.5,.5,1)
            pfUI.castbar.player.bar:SetMinMaxValues(1,100)
            pfUI.castbar.player.bar:SetValue(100)

        elseif ( event == "SPELLCAST_DELAYED" ) then
          if( pfUI.castbar.player:IsShown() ) then
            pfUI.castbar.player.delay = pfUI.castbar.player.delay + arg1/1000
            pfUI.castbar.player.startTime = pfUI.castbar.player.startTime + (arg1 / 1000)
            pfUI.castbar.player.maxValue = pfUI.castbar.player.maxValue + (arg1 / 1000)
            pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.maxValue)
          end

        elseif ( event == "SPELLCAST_CHANNEL_UPDATE" ) then
          if ( pfUI.castbar.player:IsShown() ) then
            pfUI.castbar.player.delay = pfUI.castbar.player.delay + arg1/1000
            local origDuration = pfUI.castbar.player.endTime - pfUI.castbar.player.startTime
            pfUI.castbar.player.endTime = GetTime() + (arg1 / 1000)
            pfUI.castbar.player.startTime = pfUI.castbar.player.endTime - origDuration
            pfUI.castbar.player.bar:SetMinMaxValues(pfUI.castbar.player.startTime, pfUI.castbar.player.endTime)
          end
        end
      end)

      pfUI.castbar.player:SetScript("OnUpdate", function ()
        if pfUI_config.castbar.player.hide_pfui == "1" then pfUI.castbar.player:Hide() return end

        -- fadeout
        if pfUI.castbar.player.fadeout and pfUI.castbar.player:GetAlpha() > 0 then
          pfUI.castbar.player:SetAlpha(pfUI.castbar.player:GetAlpha()-0.025)
          if pfUI.castbar.player:GetAlpha() == 0 then
            pfUI.castbar.player:Hide()
            pfUI.castbar.player.fadeout = nil
          end
        end

        -- cast
        if ( pfUI.castbar.player.casting ) then
          local status = GetTime()
          local cur = round(GetTime() - pfUI.castbar.player.startTime,1)
          local max = round(pfUI.castbar.player.maxValue - pfUI.castbar.player.startTime,1)
          local delay = pfUI.castbar.player.delay
          if cur > max then cur = max end
          if ( status > pfUI.castbar.player.maxValue ) then
            status = pfUI.castbar.player.maxValue
          end
          if delay > 0 then
            delay = "|cffffaaaa+" .. round(delay,1) .. " |r "
            pfUI.castbar.player.bar.right:SetText(delay .. cur .. " / " .. max)
          else
            pfUI.castbar.player.bar.right:SetText(cur .. " / " .. max)
          end
          pfUI.castbar.player.bar:SetValue(status)

        -- channel
        elseif ( pfUI.castbar.player.channeling ) then
          local time = GetTime()
          local barValue = pfUI.castbar.player.startTime + (pfUI.castbar.player.endTime - time)
          local cur = round(pfUI.castbar.player.endTime - GetTime(),1)
          local max = round(pfUI.castbar.player.endTime - pfUI.castbar.player.startTime,1)
          local delay = pfUI.castbar.player.delay
          if cur > max then cur = max end
          if ( time > pfUI.castbar.player.endTime ) then
            time = pfUI.castbar.player.endTime
          end
          if ( time == pfUI.castbar.player.endTime ) then
            pfUI.castbar.player.channeling = nil
            pfUI.castbar.player.fadeout = 1
            return
          end
          if delay > 0 then
            delay = "|cffffaaaa-" .. round(delay,1) .. " |r "
            pfUI.castbar.player.bar.right:SetText(delay .. cur)
          else
            pfUI.castbar.player.bar.right:SetText(cur)
          end
          pfUI.castbar.player.bar:SetValue( barValue )
        end
      end)
    end

    if pfUI.uf.target then
      pfUI.castbar.target = CreateFrame("Frame",nil, pfUI.uf.target)
      pfUI.utils:CreateBackdrop(pfUI.castbar.target, default_border)
      pfUI.castbar.target:SetHeight(pfUI_config.global.font_size * 2)
      pfUI.castbar.target:SetPoint("TOPRIGHT",pfUI.uf.target,"BOTTOMRIGHT",0,-default_border*3)
      pfUI.castbar.target:SetPoint("TOPLEFT",pfUI.uf.target,"BOTTOMLEFT",0,-default_border*3)

      -- statusbar
      pfUI.castbar.target.bar = CreateFrame("StatusBar", nil, pfUI.castbar.target)
      pfUI.castbar.target.bar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
      pfUI.castbar.target.bar:ClearAllPoints()
      pfUI.castbar.target.bar:SetAllPoints(pfUI.castbar.target)
      pfUI.castbar.target.bar:SetMinMaxValues(0, 100)
      pfUI.castbar.target.bar:SetValue(20)
      pfUI.castbar.target.bar:SetStatusBarColor(.7,.7,.9,.8)

      -- text left
      pfUI.castbar.target.bar.left = pfUI.castbar.target.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      pfUI.castbar.target.bar.left:ClearAllPoints()
      pfUI.castbar.target.bar.left:SetPoint("TOPLEFT", pfUI.castbar.target.bar, "TOPLEFT", 3, 0)
      pfUI.castbar.target.bar.left:SetPoint("BOTTOMRIGHT", pfUI.castbar.target.bar, "BOTTOMRIGHT", -3, 0)
      pfUI.castbar.target.bar.left:SetNonSpaceWrap(false)
      pfUI.castbar.target.bar.left:SetFontObject(GameFontWhite)
      pfUI.castbar.target.bar.left:SetTextColor(1,1,1,1)
      pfUI.castbar.target.bar.left:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.castbar.target.bar.left:SetText("left")
      pfUI.castbar.target.bar.left:SetJustifyH("left")

      -- text right
      pfUI.castbar.target.bar.right = pfUI.castbar.target.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      pfUI.castbar.target.bar.right:ClearAllPoints()
      pfUI.castbar.target.bar.right:SetPoint("TOPLEFT", pfUI.castbar.target.bar, "TOPLEFT", 3, 0)
      pfUI.castbar.target.bar.right:SetPoint("BOTTOMRIGHT", pfUI.castbar.target.bar, "BOTTOMRIGHT", -3, 0)
      pfUI.castbar.target.bar.right:SetNonSpaceWrap(false)
      pfUI.castbar.target.bar.right:SetFontObject(GameFontWhite)
      pfUI.castbar.target.bar.right:SetTextColor(1,1,1,1)
      pfUI.castbar.target.bar.right:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.castbar.target.bar.right:SetText("right")
      pfUI.castbar.target.bar.right:SetJustifyH("right")

      pfUI.castbar.target.bar:SetScript("OnUpdate", function()
        if UnitExists("target") and pfUI.castbar.target.casterDB[UnitName("target")] then
          local spellname = pfUI.castbar.target.casterDB[UnitName("target")].cast or 0
          local starttime = pfUI.castbar.target.casterDB[UnitName("target")].starttime or 0
          local casttime = pfUI.castbar.target.casterDB[UnitName("target")].casttime or 0

          if starttime + casttime > GetTime() then
            if pfUI_config.castbar.target.hide_pfui == "1" then
              pfUI.castbar.target:Hide()
            end

            if pfUI.castbar.target.bar then
              pfUI.castbar.target.bar:SetMinMaxValues(0, casttime)
              pfUI.castbar.target.bar:SetValue(GetTime() - starttime)
              pfUI.castbar.target.bar.left:SetText(spellname)
              pfUI.castbar.target.bar.right:SetText(round(GetTime() - starttime,1) .. " / " .. casttime)
            end
          else
            pfUI.castbar.target.casterDB[UnitName("target")] = nil
            pfUI.castbar.target:Hide()
          end
        else
          pfUI.castbar.target:Hide()
        end
      end)
    else
      pfUI.castbar.target = CreateFrame("Frame")
    end

    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
    pfUI.castbar.target:RegisterEvent("CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE")
    pfUI.castbar.target:RegisterEvent("PLAYER_TARGET_CHANGED")

    pfUI.castbar.target.casterDB = {}

    pfUI.castbar.target:SetScript("OnEvent", function()
      if (arg1 ~= nil) then
        for mob, spell in string.gfind(arg1, pfLocaleSpellEvents[pfUI.cache["locale"]]['SPELL_CAST']) do
          pfUI.castbar.target:Action(mob, spell)
          return
        end
        for mob, spell in string.gfind(arg1, pfLocaleSpellEvents[pfUI.cache["locale"]]['SPELL_PERFORM']) do
          pfUI.castbar.target:Action(mob, spell)
          return
        end
        for mob, spell in string.gfind(arg1, pfLocaleSpellEvents[pfUI.cache["locale"]]['SPELL_GAINS']) do
          pfUI.castbar.target:Action(mob, spell, true)
          return
        end
        -- this part will be used for interruption of spells
        --for mob, spell in string.gfind(arg1, pfLocaleSpellEvents[pfUI.cache["locale"]]['SPELL_AFFLICTED']) do
        --  pfUI.castbar.target:Action(mob, spell, "afflicted")
        --  return
        --end
        --for spell, mob in string.gfind(arg1, pfLocaleSpellEvents[pfUI.cache["locale"]]['SPELL_HIT']) do
        --  -- you hit mob with XX
        --  -- pfUI.castbar.target:Action(mob, spell, "hit")
        --  return
        --end
        --for spell, mob in string.gfind(arg1, pfLocaleSpellEvents[pfUI.cache["locale"]]['OTHER_SPELL_HIT']) do
        --  -- someone hits mob with XX
        --  -- pfUI.castbar.target:Action(mob, spell, "hit")
        --  return
        --end
      end

      if UnitExists("target") and pfUI.castbar.target.casterDB[UnitName("target")] then
        local starttime = pfUI.castbar.target.casterDB[UnitName("target")].starttime or 0
        local casttime = pfUI.castbar.target.casterDB[UnitName("target")].casttime or 0
        if starttime + casttime > GetTime() then
          if pfUI_config.castbar.target.hide_pfui == "1" then
            pfUI.castbar.target:Hide()
          else
            pfUI.castbar.target:Show()
          end
        else
          pfUI.castbar.target.casterDB[UnitName("target")] = nil
          pfUI.castbar.target:Hide()
        end
      end
    end)

    function pfUI.castbar.target:Action(mob, spell, gains)
      if pfLocaleSpells[pfUI.cache["locale"]][spell] ~= nil then
        if gains and pfUI.castbar.target.casterDB[mob] and pfUI.castbar.target.casterDB[mob]["cast"] == spell then
          pfUI.castbar.target.casterDB[mob] = nil
          return
        end
        local casttime = pfLocaleSpells[pfUI.cache["locale"]][spell].t / 1000
        local icon = pfLocaleSpells[pfUI.cache["locale"]][spell].icon
        pfUI.castbar.target.casterDB[mob] = {cast = spell, starttime = GetTime(), casttime = casttime, icon = icon}
        if UnitExists("target") and pfUI.castbar.target.casterDB[UnitName("target")] then
          if pfUI_config.castbar.target.hide_pfui == "1" then
            pfUI.castbar.target:Hide()
          else
            pfUI.castbar.target:Show()
          end
        else
          pfUI.castbar.target:Hide()
        end
      end
    end
end)
