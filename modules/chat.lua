pfUI:RegisterModule("chat", function ()
  pfUI.chat = CreateFrame("Frame",nil,UIParent)

  pfUI.chat.left = CreateFrame("Frame", "pfChatLeft", UIParent)
  pfUI.chat.left:SetFrameStrata("BACKGROUND")
  pfUI.chat.left:SetWidth(350)
  pfUI.chat.left:SetHeight(150)
  pfUI.chat.left:SetPoint("BOTTOMLEFT", 5,5)
  pfUI.utils:loadPosition(pfUI.chat.left)
  pfUI.chat.left:SetBackdrop(pfUI.backdrop)
  pfUI.chat.left:SetBackdropColor(0,0,0,.75)

  pfUI.chat.left.panelTop = CreateFrame("Frame", "leftChatPanelTop", pfUI.chat.left)
  pfUI.chat.left.panelTop:ClearAllPoints()
  pfUI.chat.left.panelTop:SetHeight(19)
  pfUI.chat.left.panelTop:SetPoint("TOPLEFT", pfUI.chat.left, "TOPLEFT", 2, -2)
  pfUI.chat.left.panelTop:SetPoint("TOPRIGHT", pfUI.chat.left, "TOPRIGHT", -2, -2)
  pfUI.chat.left.panelTop:SetBackdrop(pfUI.backdrop)
  pfUI.chat.left.panelTop:SetBackdropColor(0,0,0,.75)

  pfUI.chat.right = CreateFrame("Frame", "pfChatRight", UIParent)
  pfUI.chat.right:SetFrameStrata("BACKGROUND")
  pfUI.chat.right:SetWidth(350)
  pfUI.chat.right:SetHeight(150)
  pfUI.chat.right:SetPoint("BOTTOMRIGHT", -5,5)
  pfUI.utils:loadPosition(pfUI.chat.right)
  pfUI.chat.right:SetBackdrop(pfUI.backdrop)
  pfUI.chat.right:SetBackdropColor(0,0,0,.75)

  pfUI.chat.right.panelTop = CreateFrame("Frame", "rightChatPanelTop", pfUI.chat.right)
  pfUI.chat.right.panelTop:ClearAllPoints()
  pfUI.chat.right.panelTop:SetHeight(19)
  pfUI.chat.right.panelTop:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 2, -2)
  pfUI.chat.right.panelTop:SetPoint("TOPRIGHT", pfUI.chat.right, "TOPRIGHT", -2, -2)
  pfUI.chat.right.panelTop:SetBackdrop(pfUI.backdrop)
  pfUI.chat.right.panelTop:SetBackdropColor(0,0,0,.75)

  pfUI.chat:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.chat:RegisterEvent("UI_SCALE_CHANGED")
  pfUI.chat:RegisterEvent("FRIENDLIST_UPDATE")
  pfUI.chat:RegisterEvent("GUILD_ROSTER_UPDATE")
  pfUI.chat:RegisterEvent("RAID_ROSTER_UPDATE")
  pfUI.chat:RegisterEvent("PARTY_MEMBERS_CHANGED")
  pfUI.chat:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.chat:RegisterEvent("WHO_LIST_UPDATE")
  pfUI.chat:RegisterEvent("CHAT_MSG_SYSTEM")

  pfUI.chat:SetScript("OnEvent", function()
      if event == "PLAYER_ENTERING_WORLD" or event == "UI_SCALE_CHANGED" then
        for i,v in ipairs({ChatFrameMenuButton:GetRegions()}) do
          v:SetAllPoints(ChatFrameMenuButton)
          local _, class = UnitClass("player")
          v:SetTexture(.5,.5,.5, 1)
          v:SetVertexColor(RAID_CLASS_COLORS[class].r + .3 * .5, RAID_CLASS_COLORS[class].g +.3 * .5, RAID_CLASS_COLORS[class].b +.3 * .5,1)
        end

        pfUI.chat.SetupPositions()
        pfUI.chat.SetupChannels()

        for i=1, NUM_CHAT_WINDOWS do
          for j,v in ipairs({getglobal("ChatFrame" .. i .. "Tab"):GetRegions()}) do
            if j==5 then v:SetTexture(0,0,0,0) end
          end

          local _, relativeTo = getglobal("ChatFrame" .. i):GetPoint(1)
          getglobal("ChatFrame" .. i .. "Tab"):SetParent(pfUI.chat.left.panelTop)
          getglobal("ChatFrame" .. i .. "ResizeBottom"):Hide()

          if relativeTo == pfUI.chat.left then
            getglobal("ChatFrame" .. i .. "Tab"):SetParent(pfUI.chat.left.panelTop)
            getglobal("ChatFrame" .. i):SetParent(pfUI.chat.left.panelTop)
          elseif relativeTo == pfUI.chat.right then
            getglobal("ChatFrame" .. i .. "Tab"):SetParent(pfUI.chat.right.panelTop)
            getglobal("ChatFrame" .. i):SetParent(pfUI.chat.right.panelTop)
          end

          getglobal("ChatFrame" .. i .. "TabText"):SetJustifyV("TOP")
          getglobal("ChatFrame" .. i .. "TabLeft"):SetAlpha(0)
          getglobal("ChatFrame" .. i .. "TabMiddle"):SetAlpha(0)
          getglobal("ChatFrame" .. i .. "TabRight"):SetAlpha(0)
          getglobal("ChatFrame" .. i .. "TabFlash"):SetAlpha(0)
          local _, class = UnitClass("player")
          getglobal("ChatFrame" .. i .. "TabText"):SetTextColor(RAID_CLASS_COLORS[class].r + .3 * .5, RAID_CLASS_COLORS[class].g + .3 * .5, RAID_CLASS_COLORS[class].b + .3 * .5, 1)
          getglobal("ChatFrame" .. i .. "TabText"):SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")

          if getglobal("ChatFrame" .. i).isDocked or getglobal("ChatFrame" .. i):IsVisible() then
            getglobal("ChatFrame" .. i .. "Tab"):Show()
          end

          local cf = getglobal("ChatFrame" .. i)
          cf:EnableMouseWheel(true)
          cf:SetScript("OnMouseWheel", function()
              if (arg1 > 0) then
                if IsShiftKeyDown() then
                  cf:ScrollToTop()
                else
                  cf:ScrollUp()
                end
              elseif (arg1 < 0) then
                if IsShiftKeyDown() then
                  cf:ScrollToBottom()
                else
                  cf:ScrollDown()
                end
              end
            end)
        end

      elseif event == "FRIENDLIST_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local Name, Class, Level
        for i = 1, GetNumFriends() do
          Name, Level, Class = GetFriendInfo(i)
          if pfLocaleClass[GetLocale()] and pfLocaleClass[GetLocale()][Class] then
            Class = pfLocaleClass[GetLocale()][Class]
          end
          pfUI_playerDB[Name] = { class = Class, level = Level }
        end
      elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local Name, Class, Level
        for i = 1, GetNumGuildMembers() do
          Name, _, _, Level, Class = GetGuildRosterInfo(i)
          if pfLocaleClass[GetLocale()] and pfLocaleClass[GetLocale()][Class] then
            Class = pfLocaleClass[GetLocale()][Class]
          end
          if Name and Level and Class and pfUI_playerDB then
            pfUI_playerDB[Name] = { class = Class, level = Level }
          end
        end

      elseif event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local Name, Class, SubGroup, Level
        for i = 1, GetNumRaidMembers() do
          Name, _, SubGroup, Level, Class = GetRaidRosterInfo(i)
          if pfLocaleClass[GetLocale()] and pfLocaleClass[GetLocale()].Class then
            Class = pfLocaleClass[GetLocale()][Class]
          end
          pfUI_playerDB[Name] = { class = Class, level = Level }
        end

      elseif event == "PARTY_MEMBERS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        local Class, Unit
        for i = 1, GetNumPartyMembers() do
          Unit = "party" .. i
          _, Class = UnitClass(Unit)
          pfUI_playerDB[UnitName(Unit)] = { class = Class, level = UnitLevel(Unit) }
        end

      elseif event == "PLAYER_TARGET_CHANGED" then
        local Class
        if not UnitIsPlayer("target") or not UnitIsFriend("player", "target") then
          return
        end
        _, Class = UnitClass("target")
        pfUI_playerDB[UnitName("target")] = { class = Class, level = UnitLevel("target") }

      elseif event == "WHO_LIST_UPDATE" or event == "CHAT_MSG_SYSTEM" then
        local Name, Class, Level
        for i = 1, GetNumWhoResults() do
          Name, _, Level, _, Class, _ = GetWhoInfo(i)
          if pfLocaleClass[GetLocale()] and pfLocaleClass[GetLocale()][Class] then
            Class = pfLocaleClass[GetLocale()][Class]
          end
          pfUI_playerDB[Name] = { class = Class, level = Level }
        end
      end
    end)

  Hook_ChatFrame_OnUpdate = ChatFrame_OnUpdate
  function ChatFrame_OnUpdate (arg1)
    for i=1, NUM_CHAT_WINDOWS do
      getglobal("ChatFrame" .. i .. "UpButton"):Hide()
      getglobal("ChatFrame" .. i .. "DownButton"):Hide()
      getglobal("ChatFrame" .. i .. "BottomButton"):Hide()
    end
    Hook_ChatFrame_OnUpdate(arg1)
  end

  function pfUI.chat.SetupPositions()
    -- set position of Main Window
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint("TOPLEFT", pfUI.chat.left ,"TOPLEFT", 5, -25)
    ChatFrame1:SetPoint("BOTTOMRIGHT", pfUI.chat.left ,"BOTTOMRIGHT", -5, 25)

    FCF_SetLocked(ChatFrame1, 1)
    FCF_SetWindowColor(ChatFrame1, 0, 0, 0);
    FCF_SetWindowAlpha(ChatFrame1, 0);
    FCF_SetChatWindowFontSize(ChatFrame1, 12)
    -- set position of Loot & Spam
    if not ChatFrame3.isDocked == 1 or not ChatFrame3:IsShown() then
      FCF_OpenNewWindow("Loot & Spam")
    end

    FCF_SetWindowColor(ChatFrame3, 0, 0, 0);
    FCF_SetWindowAlpha(ChatFrame3, 0);
    FCF_SetChatWindowFontSize(ChatFrame3, 12)
    FCF_SetWindowName(ChatFrame3, "Loot & Spam", 1 )
    FCF_UnDockFrame(ChatFrame3)
    ChatFrame3:ClearAllPoints()
    ChatFrame3:SetPoint("TOPLEFT", pfUI.chat.right ,"TOPLEFT", 5, -25)
    ChatFrame3:SetPoint("BOTTOMRIGHT", pfUI.chat.right ,"BOTTOMRIGHT", -5, 25)
    FCF_SetLocked(ChatFrame3, 1)
    -- save positions on logout
    ChatFrame1:SetUserPlaced(1);
    ChatFrame3:SetUserPlaced(1);
  end

  function pfUI.chat.SetupChannels()
    ChatFrame_RemoveAllMessageGroups(ChatFrame1)
    ChatFrame_RemoveAllMessageGroups(ChatFrame3)

    local normalg = {"SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "WHISPER",
      "MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER",
      "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "BATTLEGROUND", "BATTLEGROUND_LEADER",
      "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "SYSTEM", "ERRORS", "AFK", "DND", "IGNORED", "BN_WHISPER", "BN_CONVERSATION"}
    for _,group in pairs(normalg) do
      ChatFrame_AddMessageGroup(ChatFrame1, group)
    end

    local spamg = { "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "LOOT", "MONEY" }
    for _,group in pairs(spamg) do
      ChatFrame_AddMessageGroup(ChatFrame3, group)
    end

    local spamc = { "Trade", "General", "LocalDefense", "GuildRecruitment", "LookingForGroup",
      "Handel", "Allgemein", "LokaleVerteidigung", "Gildenrekrutierung", "SucheNachGruppe", "World" }
    for _,channel in pairs(spamc) do
      ChatFrame_RemoveChannel(ChatFrame1, channel)
      ChatFrame_AddChannel(ChatFrame3, channel)
    end

    JoinChannelByName("World")
    ChatFrame_AddChannel(ChatFrame3, "World")
  end

  -- orig. function but removed flashing
  function FCF_OnUpdate(elapsed)
    -- Need to draw the dock regions for a frame to define their rects
    if ( not ChatFrame1.init ) then
      for i=1, NUM_CHAT_WINDOWS do
        getglobal("ChatFrame"..i.."TabDockRegion"):Show();
        FCF_UpdateButtonSide(getglobal("ChatFrame"..i));
      end
      ChatFrame1.init = 1;
      return;
    elseif ( ChatFrame1.init == 1 ) then
      for i=1, NUM_CHAT_WINDOWS do
        getglobal("ChatFrame"..i.."TabDockRegion"):Hide();
      end
      ChatFrame1.init = 2;
    end

    -- Detect if mouse is over any chat frames and if so show their tabs, if not hide them
    local chatFrame, chatTab;

    if ( MOVING_CHATFRAME ) then
      -- Set buttons to the left or right side of the frame
      -- If the the side of the buttons changes and the frame is the default frame, then set every docked frames buttons to the same side
      local updateAllButtons = nil;
      if (FCF_UpdateButtonSide(MOVING_CHATFRAME) and MOVING_CHATFRAME == DEFAULT_CHAT_FRAME ) then
        updateAllButtons = 1;
      end
      local dockRegion;
      for index, value in DOCKED_CHAT_FRAMES do
        if ( updateAllButtons ) then
          FCF_UpdateButtonSide(value);
        end

        dockRegion = getglobal(value:GetName().."TabDockRegion");
        if ( MouseIsOver(dockRegion) and MOVING_CHATFRAME ~= DEFAULT_CHAT_FRAME ) then
          dockRegion:Show();
        else
          dockRegion:Hide();
        end
      end
    end

    -- If the default chat frame is resizing, then resize the dock
    if ( DEFAULT_CHAT_FRAME.resizing ) then
      FCF_DockUpdate();
    end
  end

  ChatFrameMenuButton:SetNormalTexture("foo")
  ChatFrameMenuButton:ClearAllPoints()
  ChatFrameMenuButton:SetParent(pfUI.chat.left.panelTop)
  ChatFrameMenuButton:SetPoint("TOPRIGHT",-6,-6)
  ChatFrameMenuButton:SetHeight(6)
  ChatFrameMenuButton:SetWidth(6)

  ChatFrameEditBox:ClearAllPoints()
  ChatFrameEditBox:SetHeight(22)
  ChatFrameEditBox:SetPoint("BOTTOMLEFT", pfUI.bars.bottom, "TOPLEFT", 0, 5)
  ChatFrameEditBox:SetPoint("BOTTOMRIGHT", pfUI.bars.bottom, "TOPRIGHT", 0, 5)

  ChatFrameEditBox:SetBackdrop(pfUI.backdrop)

  for i,v in ipairs({ChatFrameEditBox:GetRegions()}) do
    if i==6 or i==7 or i==8 then
      v:SetTexture(0,0,0,1)
      v:SetHeight(ChatFrameEditBox:GetHeight())
    end
  end
  ChatFrameEditBox:SetAltArrowKeyMode(false)

  local shortnames = { channel1 = "[1]", channel2 = "[2]",
    channel3 = "[3]", channel4 = "[4]", channel5 = "[5]",
    channel6 = "[6]", channel7 = "[7]", channel8 = "[8]",
    channel9 = "[9]", channel10 = "[10]", }

  local default = " " .. "%s" .. "|r:" .. "\32"
  CHAT_CHANNEL_GET = "%s" .. "|r:" .. "\32";
  CHAT_GUILD_GET = '[G]' .. default
  CHAT_OFFICER_GET = '[O]'.. default
  CHAT_PARTY_GET = '[P]' .. default
  CHAT_RAID_GET = '[R]' .. default
  CHAT_RAID_LEADER_GET = '[RL]' .. default
  CHAT_RAID_WARNING_GET = '[RW]' .. default
  CHAT_BATTLEGROUND_GET = '[BG]' .. default
  CHAT_BATTLEGROUND_LEADER_GET = '[BL]' .. default
  CHAT_SAY_GET = '[S]' .. default
  CHAT_WHISPER_GET = '|cffffaaff[W]' .. default
  CHAT_WHISPER_INFORM_GET = '[W]' .. default
  CHAT_YELL_GET = '[Y]' .. default

  for i=1,NUM_CHAT_WINDOWS do
    local HookAddMessage = getglobal("ChatFrame"..i).AddMessage
    getglobal("ChatFrame"..i).AddMessage = function (frame, text, ...)
      if text then
        local Name = string.gsub(text, ".*|Hplayer:(.-)|h.*", "%1")
        if pfUI_playerDB[Name] and pfUI_playerDB[Name].class ~= nil then
          local Class = pfUI_playerDB[Name].class
          if RAID_CLASS_COLORS[Class] ~= nil then
            local Color = string.format("%02x%02x%02x",
              RAID_CLASS_COLORS[Class].r * 255,
              RAID_CLASS_COLORS[Class].g * 255,
              RAID_CLASS_COLORS[Class].b * 255)
            Name = "|cff" .. Color .. Name .. "|r"
          end
        end
        text = string.gsub(text, "|Hplayer:(.-)|h%[.-%]|h(.-:-)", "[|Hplayer:%1|h" .. Name .. "|h]" .. "%2")

        -- make incoming whispers lighter than outgoing
        if string.find(text, '|cffffaaff') == 1 then
          text = string.gsub(text, "|r", "|cffffaaff")
        end

        local pattern = "%]%s+(.*|Hplayer)"
        local channel = string.gsub(text, ".*%[(.-)" .. pattern ..".+", "%1")
        if string.find(channel, "%d+%. ") then
          channel = string.gsub(channel, "(%d+)%..*", "channel%1")
          channel = string.gsub(channel, "channel", "")
          pattern = "%[%d+%..-" .. pattern
          text = string.gsub(text, pattern, "["..channel.."]".."%1")
        end

        HookAddMessage(frame, text, unpack(arg))
      end
    end
  end
end)
