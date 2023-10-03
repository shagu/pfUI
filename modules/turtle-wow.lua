-- skip module initialization on every other client than turtle-wow
if not TargetHPText or not TargetHPPercText then return end

pfUI:RegisterModule("turtle-wow", "vanilla", function ()
  local delay = CreateFrame("Frame")
  delay:SetScript("OnUpdate", function()
    this:Hide()

    -- disable turtle wow's map window implementation
    if pfUI.map and not Cartographer and not METAMAP_TITLE then
      _G.WorldMapFrame_Maximize()
      pfUI.map.loader:GetScript("OnEvent")()

      _G.WorldMapFrame_Minimize = function() return end
      _G.WorldMapFrame_Maximize = function() return end

      _G.WorldMapFrameMaximizeButton.Show = function() return end
      _G.WorldMapFrameMaximizeButton:Hide()

      _G.WorldMapFrameMinimizeButton.Show = function() return end
      _G.WorldMapFrameMinimizeButton:Hide()

      WorldMapFrameTitle.Show = function() return end
      WorldMapFrameTitle:Hide()
    end

    -- add Trueshot recognition to to custom castbars.
    if not libcast.customcast["trueshot"] then
      -- add trueshot to pfUI's custom casts
      local player = UnitName("player")

      libcast.customcast["trueshot"] = function(begin, duration)
        if begin then
          local duration = duration or 1000

          for i=1,32 do
            if UnitBuff("player", i) == "Interface\\Icons\\Racial_Troll_Berserk" then
              local berserk = 0.3
              if((UnitHealth("player")/UnitHealthMax("player")) >= 0.40) then
                berserk = (1.30 - (UnitHealth("player") / UnitHealthMax("player"))) / 3
              end
              duration = duration / (1 + berserk)
            elseif UnitBuff("player", i) == "Interface\\Icons\\Ability_Hunter_RunningShot" then
              duration = duration / 1.4
            elseif UnitBuff("player", i) == "Interface\\Icons\\Ability_Warrior_InnerRage" then
              duration = duration / 1.3
            elseif UnitBuff("player", i) == "Interface\\Icons\\Inv_Trinket_Naxxramas04" then
              duration = duration / 1.2
            end
          end

          local _,_, lag = GetNetStats()
          local start = GetTime() + lag/1000

          -- add cast action to the database
          libcast.db[player].cast = "Trueshot"
          libcast.db[player].rank = lastrank
          libcast.db[player].start = start
          libcast.db[player].casttime = duration
          libcast.db[player].icon = "Interface\\Icons\\Inv_spear_07"
          libcast.db[player].channel = nil
        else
          -- remove cast action to the database
          libcast.db[player].cast = nil
          libcast.db[player].rank = nil
          libcast.db[player].start = nil
          libcast.db[player].casttime = nil
          libcast.db[player].icon = nil
          libcast.db[player].channel = nil
        end
      end
    end

    -- refresh paladin judgements on holy strike
    -- taken from: https://github.com/doorknob6/pfUI-turtle/blob/master/modules/debuffs.lua
    HookScript(libdebuff, "OnEvent", function()
      if event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        local spell = string.find(string.sub(arg1,6,17), "Holy Strike")

        --arg2 is holy dmg when it hits, nil when it misses
        if spell and arg2 then
          for seal in L["judgements"] do
            local name = UnitName("target")
            local level = UnitLevel("target")
            if name and libdebuff.objects[name] then
              if level and
                libdebuff.objects[name][level] and
                libdebuff.objects[name][level][seal] then
                libdebuff:AddEffect(name, level, seal)
              elseif libdebuff.objects[name][0] and
                libdebuff.objects[name][0][seal] then
                libdebuff:AddEffect(name, 0, seal)
              end
            end
          end
        end
      end
    end)
  end)
end)
