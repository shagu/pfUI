pfUI:RegisterModule("socialmod", function ()
  do -- add colors to guild list
    hooksecurefunc("GuildStatus_Update", function()
      local playerzone = GetRealZoneText()
      local off = FauxScrollFrame_GetOffset(GuildListScrollFrame)
      for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
        local name, _, _, level, class, zone, _, _, online = GetGuildRosterInfo(off + i)
        class = L["class"][class]

        if name then
          if class then
            local color = RAID_CLASS_COLORS[class]
            if online then
              _G["GuildFrameButton"..i.."Class"]:SetTextColor(color.r,color.g,color.b,1)
            else
              _G["GuildFrameButton"..i.."Class"]:SetTextColor(color.r,color.g,color.b,.5)
            end
          end

          if level then
            local color = GetDifficultyColor(level)
            if online then
              _G["GuildFrameButton"..i.."Level"]:SetTextColor(color.r + .2, color.g + .2, color.b + .2, 1)
            else
              _G["GuildFrameButton"..i.."Level"]:SetTextColor(color.r + .2, color.g + .2, color.b + .2, .5)
            end
          end

          if zone and zone == playerzone then
            if online then
              _G["GuildFrameButton"..i.."Zone"]:SetTextColor(.5, 1, 1, 1)
            else
              _G["GuildFrameButton"..i.."Zone"]:SetTextColor(.5, 1, 1, .5)
            end
          end
        end
      end
    end, true)
  end

  do -- add colors to friend list
    hooksecurefunc("FriendsList_Update", function()
      if GetNumFriends() == 0 then return end

      local playerzone  = GetRealZoneText()
      local off = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)

      for i=1, FRIENDS_TO_DISPLAY do
        local name, level, class, zone, connected, status = GetFriendInfo(off + i)
        if not name then break end

        if connected then
          local ccolor = RAID_CLASS_COLORS[L["class"][class]] or { 1, 1, 1 }
          local lcolor = GetDifficultyColor(tonumber(level)) or { 1, 1, 1 }

          zone = ( zone == playerzone and "|cffffffff" or "|cffaaaaaa" ) .. zone .. "|r"
          name = "|cff" .. string.format("%02x%02x%02x", ccolor.r*255, ccolor.g*255, ccolor.b*255) .. name .. "|r"

          _G["FriendsFrameFriendButton"..i.."ButtonTextNameLocation"]:SetText(format(TEXT(FRIENDS_LIST_TEMPLATE), name, zone, status))
          _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"]:SetText(format(TEXT(FRIENDS_LEVEL_TEMPLATE), level, class))
          _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"]:SetTextColor(lcolor.r + .2, lcolor.g + .2, lcolor.b + .2)
        else
          _G["FriendsFrameFriendButton"..i.."ButtonTextNameLocation"]:SetText(format(TEXT(FRIENDS_LIST_OFFLINE_TEMPLATE), name))
          _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"]:SetText(TEXT(UNKNOWN))
          _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"]:SetTextColor(.2,.2,.2)
        end
      end
    end, true)
  end

  do -- add colors to who list
    hooksecurefunc("WhoList_Update", function()
      local num, max = GetNumWhoResults()
      local off = FauxScrollFrame_GetOffset(WhoListScrollFrame)

      local playerzone  = GetRealZoneText()
      local playerrace  = UnitRace("player")
      local playerguild = GetGuildInfo("player")

      for i=1, WHOS_TO_DISPLAY do
        local name, guild, level, race, class, zone = GetWhoInfo(off + i)
        local displayedText = ""

        if num + 1 >= MAX_WHOS_FROM_SERVER then
          displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER)
          WhoFrameTotals:SetText("|cffffffff" .. format(GetText("WHO_FRAME_TOTAL_TEMPLATE", nil, num), max).."  |cffaaaaaa"..displayedText)
        else
          displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, num)
          WhoFrameTotals:SetText("|cffffffff" .. format(GetText("WHO_FRAME_TOTAL_TEMPLATE", nil, num), num).."  |cffaaaaaa"..displayedText)
        end

        class = L["class"][class]

        _G["WhoFrameButton"..i.."Name"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)

        if (UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 1) then
          if (zone == playerzone) then
            _G["WhoFrameButton"..i.."Variable"]:SetTextColor(.5, 1, 1)
          else
            _G["WhoFrameButton"..i.."Variable"]:SetTextColor(1, 1, 1)
          end

        elseif (UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 2) then
          if (guild == playerguild) then
            _G["WhoFrameButton"..i.."Variable"]:SetTextColor(.5, 1, 1)
          else
            _G["WhoFrameButton"..i.."Variable"]:SetTextColor(1, 1, 1)
          end

        elseif (UIDropDownMenu_GetSelectedID(WhoFrameDropDown) == 3) then
          if (race == playerrace) then
            _G["WhoFrameButton"..i.."Variable"]:SetTextColor(.5, 1, 1)
          else
            _G["WhoFrameButton"..i.."Variable"]:SetTextColor(1, 1, 1)
          end
        end

        if class then
          local color = RAID_CLASS_COLORS[class]
          _G["WhoFrameButton"..i.."Class"]:SetTextColor(color.r,color.g,color.b,1)
        else
          _G["WhoFrameButton"..i.."Class"]:SetTextColor(1, 1, 1)
        end

        local color = GetDifficultyColor(level)
        _G["WhoFrameButton"..i.."Level"]:SetTextColor(color.r, color.g, color.b)
      end
    end, true)
  end
end)
