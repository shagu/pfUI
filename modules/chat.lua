pfUI:RegisterModule("chat", function ()
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.chat ~= "-1" then
    default_border = pfUI_config.appearance.border.chat
  end

  pfUI.chat = CreateFrame("Frame",nil,UIParent)

  pfUI.chat.left = CreateFrame("Frame", "pfChatLeft", UIParent)
  pfUI.chat.left:SetFrameStrata("BACKGROUND")
  pfUI.chat.left:SetWidth(pfUI_config.chat.left.width)
  pfUI.chat.left:SetHeight(pfUI_config.chat.left.height)
  pfUI.chat.left:SetPoint("BOTTOMLEFT", 5,5)
  pfUI.utils:UpdateMovable(pfUI.chat.left)
  pfUI.utils:CreateBackdrop(pfUI.chat.left, default_border, nil, true)
  if pfUI_config.chat.global.custombg == "1" then
    local r, g, b, a = strsplit(",", pfUI_config.chat.global.background)
    pfUI.chat.left.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
  end

  pfUI.chat.left.panelTop = CreateFrame("Frame", "leftChatPanelTop", pfUI.chat.left)
  pfUI.chat.left.panelTop:ClearAllPoints()
  pfUI.chat.left.panelTop:SetHeight(pfUI_config.global.font_size+default_border*2)
  pfUI.chat.left.panelTop:SetPoint("TOPLEFT", pfUI.chat.left, "TOPLEFT", default_border, -default_border)
  pfUI.chat.left.panelTop:SetPoint("TOPRIGHT", pfUI.chat.left, "TOPRIGHT", -default_border, -default_border)
  pfUI.utils:CreateBackdrop(pfUI.chat.left.panelTop, default_border, nil, true)

  -- whisper forwarding
  pfUI.chat.left.panelTop.proxy = CreateFrame("Button", "leftChatWhisperProxy", pfUI.chat.left.panelTop)
  pfUI.chat.left.panelTop.proxy:RegisterEvent("CHAT_MSG_WHISPER")
  pfUI.chat.left.panelTop.proxy:SetPoint("TOPRIGHT", pfUI.chat.left, "TOPRIGHT", -20, -6)
  pfUI.chat.left.panelTop.proxy:SetWidth(12)
  pfUI.chat.left.panelTop.proxy:SetHeight(12)
  pfUI.chat.left.panelTop.proxy:SetNormalTexture("Interface\\AddOns\\pfUI\\img\\proxy")
  pfUI.chat.left.panelTop.proxy:SetAlpha(0.25)
  for i,v in ipairs({pfUI.chat.left.panelTop.proxy:GetRegions()}) do
    if v.SetVertexColor then v:SetVertexColor(1,1,1,1) end
  end

  pfUI.chat.left.panelTop.proxy.enabled = false
  pfUI.chat.left.panelTop.proxy.forwardto = ""

  function pfUI.chat.left.panelTop.proxy.toggle()
    if pfUI.chat.left.panelTop.proxy.enabled == true then
      -- redirect inactive
      pfUI.chat.left.panelTop.proxy.enabled = false
      pfUI.chat.left.panelTop.proxy:SetAlpha(0.25)
      for i,v in ipairs({pfUI.chat.left.panelTop.proxy:GetRegions()}) do
        if v.SetVertexColor then v:SetVertexColor(1,1,1,1) end
      end
      DEFAULT_CHAT_FRAME:AddMessage("Forwarding to |cff33ffcc" .. pfUI.chat.left.panelTop.proxy.forwardto .. "|r has been disabled")
    elseif pfUI.chat.left.panelTop.proxy.forwardto ~= "" then
      -- redirect active
      pfUI.chat.left.panelTop.proxy.enabled = true
      pfUI.chat.left.panelTop.proxy:SetAlpha(1)
      for i,v in ipairs({pfUI.chat.left.panelTop.proxy:GetRegions()}) do
        if v.SetVertexColor then v:SetVertexColor(1,.25,.25,1) end
      end
      DEFAULT_CHAT_FRAME:AddMessage("All messages will be forwarded to |cff33ffcc" .. pfUI.chat.left.panelTop.proxy.forwardto)
    end
  end

  pfUI.chat.left.panelTop.proxy:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  pfUI.chat.left.panelTop.proxy:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      if pfUI.chat.left.panelTop.proxyName:IsShown() then
        pfUI.chat.left.panelTop.proxyName:Hide()
      else
        pfUI.chat.left.panelTop.proxyName:Show()
      end
    else
      pfUI.chat.left.panelTop.proxy.toggle()
    end
  end)

  pfUI.chat.left.panelTop.proxy:SetScript("OnEvent", function()
    local forwardto = pfUI.chat.left.panelTop.proxy.forwardto
    if pfUI.chat.left.panelTop.proxy.enabled == false then return end

    if arg2 ~= UnitName("player") and arg2 ~=  forwardto  and forwardto ~= UnitName("player") then
      SendChatMessage("[" .. arg2 .. "]: " .. arg1, "WHISPER", nil, forwardto)
    end

    if arg2 == forwardto then
      local isForward, _, name, message = string.find(arg1, "(.*): (.*)")
      if isForward then
        SendChatMessage(message, "WHISPER", nil, name)
        SendChatMessage("-> " .. name, "WHISPER", nil, forwardto)
      end
    end
  end)

  pfUI.chat.left.panelTop.proxyName = CreateFrame("Frame", "leftChatWhisperProxyName")
  pfUI.chat.left.panelTop.proxyName:SetPoint("CENTER", 0, 0)
  pfUI.chat.left.panelTop.proxyName:SetHeight(100)
  pfUI.chat.left.panelTop.proxyName:SetWidth(200)
  pfUI.utils:CreateBackdrop(pfUI.chat.left.panelTop.proxyName, default_border)
  pfUI.chat.left.panelTop.proxyName:SetScript("OnShow", function()
    pfUI.chat.left.panelTop.proxyName.input:SetText(pfUI.chat.left.panelTop.proxy.forwardto)
  end)

  pfUI.chat.left.panelTop.proxyName.caption = pfUI.chat.left.panelTop.proxyName:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.chat.left.panelTop.proxyName.caption:SetFont(pfUI.font_default, pfUI_config.global.font_size + 2, "OUTLINE")
  pfUI.chat.left.panelTop.proxyName.caption:SetPoint("TOP", 0, -20)
  pfUI.chat.left.panelTop.proxyName.caption:SetFontObject(GameFontWhite)
  pfUI.chat.left.panelTop.proxyName.caption:SetJustifyH("CENTER")
  pfUI.chat.left.panelTop.proxyName.caption:SetText("Forward all whispers to:")

  pfUI.chat.left.panelTop.proxyName.input = CreateFrame("EditBox", nil, pfUI.chat.left.panelTop.proxyName)
  pfUI.chat.left.panelTop.proxyName.input:SetTextColor(.2,1.1,1)
  pfUI.chat.left.panelTop.proxyName.input:SetJustifyH("CENTER")
  pfUI.utils:CreateBackdrop(pfUI.chat.left.panelTop.proxyName.input, default_border)
  pfUI.chat.left.panelTop.proxyName.input:SetPoint("TOPLEFT" , pfUI.chat.left.panelTop.proxyName, "TOPLEFT", 20, -40)
  pfUI.chat.left.panelTop.proxyName.input:SetPoint("BOTTOMRIGHT" , pfUI.chat.left.panelTop.proxyName, "BOTTOMRIGHT", -20, 40)
  pfUI.chat.left.panelTop.proxyName.input:SetFontObject(GameFontWhite)
  pfUI.chat.left.panelTop.proxyName.input:SetAutoFocus(false)
  pfUI.chat.left.panelTop.proxyName.input:SetText(pfUI.chat.left.panelTop.proxy.forwardto)
  pfUI.chat.left.panelTop.proxyName.input:SetScript("OnEscapePressed", function(self)
    pfUI.chat.left.panelTop.proxyName:Hide()
  end)

  pfUI.chat.left.panelTop.proxyName.okay = CreateFrame("Button", nil, pfUI.chat.left.panelTop.proxyName)
  pfUI.chat.left.panelTop.proxyName.okay:SetWidth(80)
  pfUI.chat.left.panelTop.proxyName.okay:SetHeight(20)
  pfUI.chat.left.panelTop.proxyName.okay:SetPoint("BOTTOMRIGHT", -10, 10)
  pfUI.utils:CreateBackdrop(pfUI.chat.left.panelTop.proxyName.okay, default_border)
  pfUI.chat.left.panelTop.proxyName.okay.text = pfUI.chat.left.panelTop.proxyName.okay:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.chat.left.panelTop.proxyName.okay.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.chat.left.panelTop.proxyName.okay.text:ClearAllPoints()
  pfUI.chat.left.panelTop.proxyName.okay.text:SetAllPoints(pfUI.chat.left.panelTop.proxyName.okay)
  pfUI.chat.left.panelTop.proxyName.okay.text:SetPoint("CENTER", 0, 0)
  pfUI.chat.left.panelTop.proxyName.okay.text:SetFontObject(GameFontWhite)
  pfUI.chat.left.panelTop.proxyName.okay.text:SetText("Save")
  pfUI.chat.left.panelTop.proxyName.okay:SetScript("OnClick", function()
    pfUI.chat.left.panelTop.proxy.forwardto = pfUI.chat.left.panelTop.proxyName.input:GetText()
    if pfUI.chat.left.panelTop.proxy.enabled == true then
      DEFAULT_CHAT_FRAME:AddMessage("All messages will now be forwarded to |cff33ffcc" .. pfUI.chat.left.panelTop.proxy.forwardto)
    end
    pfUI.chat.left.panelTop.proxyName:Hide()
  end)

  pfUI.chat.left.panelTop.proxyName.abort = CreateFrame("Button", nil, pfUI.chat.left.panelTop.proxyName)
  pfUI.chat.left.panelTop.proxyName.abort:SetWidth(80)
  pfUI.chat.left.panelTop.proxyName.abort:SetHeight(20)
  pfUI.chat.left.panelTop.proxyName.abort:SetPoint("BOTTOMLEFT", 10, 10)
  pfUI.utils:CreateBackdrop(pfUI.chat.left.panelTop.proxyName.abort, default_border)
  pfUI.chat.left.panelTop.proxyName.abort.text = pfUI.chat.left.panelTop.proxyName.abort:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.chat.left.panelTop.proxyName.abort.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.chat.left.panelTop.proxyName.abort.text:ClearAllPoints()
  pfUI.chat.left.panelTop.proxyName.abort.text:SetAllPoints(pfUI.chat.left.panelTop.proxyName.abort)
  pfUI.chat.left.panelTop.proxyName.abort.text:SetPoint("CENTER", 0, 0)
  pfUI.chat.left.panelTop.proxyName.abort.text:SetFontObject(GameFontWhite)
  pfUI.chat.left.panelTop.proxyName.abort.text:SetText("Abort")
  pfUI.chat.left.panelTop.proxyName.abort:SetScript("OnClick", function()
    pfUI.chat.left.panelTop.proxyName:Hide()
  end)

  pfUI.chat.left.panelTop.proxyName:Hide()


  pfUI.chat.right = CreateFrame("Frame", "pfChatRight", UIParent)
  pfUI.chat.right:SetFrameStrata("BACKGROUND")
  pfUI.chat.right:SetWidth(pfUI_config.chat.right.width)
  pfUI.chat.right:SetHeight(pfUI_config.chat.right.height)
  pfUI.chat.right:SetPoint("BOTTOMRIGHT", -5,5)
  pfUI.utils:UpdateMovable(pfUI.chat.right)
  pfUI.utils:CreateBackdrop(pfUI.chat.right, default_border, nil, true)
  if pfUI_config.chat.global.custombg == "1" then
    local r, g, b, a = strsplit(",", pfUI_config.chat.global.background)
    pfUI.chat.right.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
  end

  pfUI.chat.right.panelTop = CreateFrame("Frame", "rightChatPanelTop", pfUI.chat.right)
  pfUI.chat.right.panelTop:ClearAllPoints()
  pfUI.chat.right.panelTop:SetHeight(pfUI_config.global.font_size+default_border*2)
  pfUI.chat.right.panelTop:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", default_border, -default_border)
  pfUI.chat.right.panelTop:SetPoint("TOPRIGHT", pfUI.chat.right, "TOPRIGHT", -default_border, -default_border)
  pfUI.utils:CreateBackdrop(pfUI.chat.right.panelTop, default_border, nil, true)

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
        local panelheight = pfUI_config.global.font_size+default_border*5

        for i,v in ipairs({ChatFrameMenuButton:GetRegions()}) do
          v:SetAllPoints(ChatFrameMenuButton)
          local _, class = UnitClass("player")
          v:SetTexture(.5,.5,.5, 1)
          v:SetVertexColor(RAID_CLASS_COLORS[class].r + .3 * .5, RAID_CLASS_COLORS[class].g +.3 * .5, RAID_CLASS_COLORS[class].b +.3 * .5,1)
        end

        ChatFrame1:ClearAllPoints()
        ChatFrame1:SetPoint("TOPLEFT", pfUI.chat.left ,"TOPLEFT", default_border, -panelheight)
        ChatFrame1:SetPoint("BOTTOMRIGHT", pfUI.chat.left ,"BOTTOMRIGHT", -default_border, panelheight)

        ChatFrame3:ClearAllPoints()
        ChatFrame3:SetPoint("TOPLEFT", pfUI.chat.right ,"TOPLEFT", default_border, -panelheight)
        ChatFrame3:SetPoint("BOTTOMRIGHT", pfUI.chat.right ,"BOTTOMRIGHT", -default_border, panelheight)

        if not pfUI_init["chat"] then
          pfUI.chat.SetupPositions()
          pfUI.chat.SetupChannels()
          pfUI_init["chat"] = true
        end

        for i=1, NUM_CHAT_WINDOWS do
          for j,v in ipairs({getglobal("ChatFrame" .. i .. "Tab"):GetRegions()}) do
            if j==5 then v:SetTexture(0,0,0,0) end
            v:SetHeight(pfUI_config.global.font_size+default_border*2)
          end

          getglobal("ChatFrame" .. i .. "ResizeBottom"):Hide()
          local _, relativeTo = getglobal("ChatFrame" .. i):GetPoint(1)
          if relativeTo == pfUI.chat.left then
            getglobal("ChatFrame" .. i .. "Tab"):SetParent(pfUI.chat.left.panelTop)
            getglobal("ChatFrame" .. i):SetParent(pfUI.chat.left)
          elseif relativeTo == pfUI.chat.right then
            getglobal("ChatFrame" .. i .. "Tab"):SetParent(pfUI.chat.right.panelTop)
            getglobal("ChatFrame" .. i):SetParent(pfUI.chat.right)
          else
            getglobal("ChatFrame" .. i .. "Tab"):SetParent(pfUI.chat.left.panelTop)
            getglobal("ChatFrame" .. i):SetParent(pfUI.chat.left)
          end
          getglobal("ChatFrame" .. i .. "TabText"):SetJustifyV("CENTER")
          getglobal("ChatFrame" .. i .. "TabText"):SetHeight(pfUI_config.global.font_size+default_border*2)
          getglobal("ChatFrame" .. i .. "TabText"):SetPoint("BOTTOM", 0, default_border)
          getglobal("ChatFrame" .. i .. "TabLeft"):SetAlpha(0)
          getglobal("ChatFrame" .. i .. "TabMiddle"):SetAlpha(0)
          getglobal("ChatFrame" .. i .. "TabRight"):SetAlpha(0)
          getglobal("ChatFrame" .. i .. "TabFlash"):SetAlpha(0)
          local _, class = UnitClass("player")
          getglobal("ChatFrame" .. i .. "TabText"):SetTextColor(RAID_CLASS_COLORS[class].r + .3 * .5, RAID_CLASS_COLORS[class].g + .3 * .5, RAID_CLASS_COLORS[class].b + .3 * .5, 1)
          getglobal("ChatFrame" .. i .. "TabText"):SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")

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
          if pfLocaleClass[pfUI.cache["locale"]] and pfLocaleClass[pfUI.cache["locale"]][Class] then
            Class = pfLocaleClass[pfUI.cache["locale"]][Class]
          end
          pfUI_playerDB[Name] = { class = Class, level = Level }
        end
      elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local Name, Class, Level
        for i = 1, GetNumGuildMembers() do
          Name, _, _, Level, Class = GetGuildRosterInfo(i)
          if pfLocaleClass[pfUI.cache["locale"]] and pfLocaleClass[pfUI.cache["locale"]][Class] then
            Class = pfLocaleClass[pfUI.cache["locale"]][Class]
          end
          if Name and Level and Class and pfUI_playerDB then
            pfUI_playerDB[Name] = { class = Class, level = Level }
          end
        end

      elseif event == "RAID_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        local Name, Class, SubGroup, Level
        for i = 1, GetNumRaidMembers() do
          Name, _, SubGroup, Level, Class = GetRaidRosterInfo(i)
          if pfLocaleClass[pfUI.cache["locale"]] and pfLocaleClass[pfUI.cache["locale"]].Class then
            Class = pfLocaleClass[pfUI.cache["locale"]][Class]
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
          if pfLocaleClass[pfUI.cache["locale"]] and pfLocaleClass[pfUI.cache["locale"]][Class] then
            Class = pfLocaleClass[pfUI.cache["locale"]][Class]
          end
          pfUI_playerDB[Name] = { class = Class, level = Level }
        end
      end
    end)

  for i=1, NUM_CHAT_WINDOWS do
    getglobal("ChatFrame" .. i .. "UpButton"):Hide()
    getglobal("ChatFrame" .. i .. "UpButton").Show = function() return end
    getglobal("ChatFrame" .. i .. "DownButton"):Hide()
    getglobal("ChatFrame" .. i .. "DownButton").Show = function() return end
    getglobal("ChatFrame" .. i .. "BottomButton"):Hide()
    getglobal("ChatFrame" .. i .. "BottomButton").Show = function() return end
  end

  function pfUI.chat.SetupPositions()
    -- close all chat windows
    for i=1, NUM_CHAT_WINDOWS do
      FCF_Close(getglobal("ChatFrame"..i))
    end

    -- set position of Main Window
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint("TOPLEFT", pfUI.chat.left ,"TOPLEFT", 5, -25)
    ChatFrame1:SetPoint("BOTTOMRIGHT", pfUI.chat.left ,"BOTTOMRIGHT", -5, 25)

    FCF_SetLocked(ChatFrame1, 1)
    FCF_SetWindowName(ChatFrame1, GENERAL)
    FCF_SetWindowColor(ChatFrame1, 0, 0, 0)
    FCF_SetWindowAlpha(ChatFrame1, 0)
    FCF_SetChatWindowFontSize(ChatFrame1, 12)

    -- set position of Combat
    if not ChatFrame2:IsShown() then
      FCF_OpenNewWindow("Combat Log")
    end
    FCF_SetLocked(ChatFrame2, 1)
    FCF_SetWindowName(ChatFrame2, COMBAT_LOG)
    FCF_SetWindowColor(ChatFrame2, 0, 0, 0)
    FCF_SetWindowAlpha(ChatFrame2, 0)
    FCF_SetChatWindowFontSize(ChatFrame2, 12)

    -- set position of Loot & Spam
    if not ChatFrame3:IsShown() then
      FCF_OpenNewWindow("Loot & Spam")
    end
    FCF_SetLocked(ChatFrame3, 1)
    FCF_SetWindowName(ChatFrame3, "Loot & Spam")
    FCF_SetWindowColor(ChatFrame3, 0, 0, 0)
    FCF_SetWindowAlpha(ChatFrame3, 0)
    FCF_SetChatWindowFontSize(ChatFrame3, 12)
    FCF_UnDockFrame(ChatFrame3)
    FCF_SetTabPosition(ChatFrame3, 0)
    ChatFrame3:ClearAllPoints()
    ChatFrame3:SetPoint("TOPLEFT", pfUI.chat.right ,"TOPLEFT", 5, -25)
    ChatFrame3:SetPoint("BOTTOMRIGHT", pfUI.chat.right ,"BOTTOMRIGHT", -5, 25)

    -- save positions on logout
    ChatFrame1:SetUserPlaced(1)
    ChatFrame2:SetUserPlaced(1)
    ChatFrame3:SetUserPlaced(1)
  end

  function pfUI.chat.SetupChannels()
    ChatFrame_RemoveAllMessageGroups(ChatFrame1)
    ChatFrame_RemoveAllMessageGroups(ChatFrame2)
    ChatFrame_RemoveAllMessageGroups(ChatFrame3)

    ChatFrame_RemoveAllChannels(ChatFrame1)
    ChatFrame_RemoveAllChannels(ChatFrame2)
    ChatFrame_RemoveAllChannels(ChatFrame3)

    local normalg = {"SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "WHISPER",
      "MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER",
      "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "BATTLEGROUND", "BATTLEGROUND_LEADER",
      "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "SYSTEM", "ERRORS", "AFK", "DND", "IGNORED", "BN_WHISPER", "BN_CONVERSATION"}
    for _,group in pairs(normalg) do
      ChatFrame_AddMessageGroup(ChatFrame1, group)
    end

    ChatFrame_ActivateCombatMessages(ChatFrame2)

    local spamg = { "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "MONEY" }
    for _,group in pairs(spamg) do
      ChatFrame_AddMessageGroup(ChatFrame3, group)
    end

    for _, chan in pairs({EnumerateServerChannels()}) do
      ChatFrame_AddChannel(ChatFrame3, chan)
      ChatFrame_RemoveChannel(ChatFrame1, chan)
    end

    JoinChannelByName("World")
    ChatFrame_AddChannel(ChatFrame3, "World")
  end

  -- orig. function but removed flashing
  function FCF_OnUpdate(elapsed)
    -- Need to draw the dock regions for a frame to define their rects
    if ( not ChatFrame1.init ) then
      for i=1, NUM_CHAT_WINDOWS do
        getglobal("ChatFrame"..i.."TabDockRegion"):Show()
        FCF_UpdateButtonSide(getglobal("ChatFrame"..i))
      end
      ChatFrame1.init = 1
      return
    elseif ( ChatFrame1.init == 1 ) then
      for i=1, NUM_CHAT_WINDOWS do
        getglobal("ChatFrame"..i.."TabDockRegion"):Hide()
      end
      ChatFrame1.init = 2
    end

    -- Detect if mouse is over any chat frames and if so show their tabs, if not hide them
    local chatFrame, chatTab

    if ( MOVING_CHATFRAME ) then
      -- Set buttons to the left or right side of the frame
      -- If the the side of the buttons changes and the frame is the default frame, then set every docked frames buttons to the same side
      local updateAllButtons = nil
      if (FCF_UpdateButtonSide(MOVING_CHATFRAME) and MOVING_CHATFRAME == DEFAULT_CHAT_FRAME ) then
        updateAllButtons = 1
      end
      local dockRegion
      for index, value in DOCKED_CHAT_FRAMES do
        if ( updateAllButtons ) then
          FCF_UpdateButtonSide(value)
        end

        dockRegion = getglobal(value:GetName().."TabDockRegion")
        if ( MouseIsOver(dockRegion) and MOVING_CHATFRAME ~= DEFAULT_CHAT_FRAME ) then
          dockRegion:Show()
        else
          dockRegion:Hide()
        end
      end
    end

    -- If the default chat frame is resizing, then resize the dock
    if ( DEFAULT_CHAT_FRAME.resizing ) then
      FCF_DockUpdate()
    end
  end

  ChatFrameMenuButton:SetNormalTexture("foo")
  ChatFrameMenuButton:ClearAllPoints()
  ChatFrameMenuButton:SetParent(pfUI.chat.left.panelTop)
  ChatFrameMenuButton:SetPoint("TOPRIGHT",-6,-6)
  ChatFrameMenuButton:SetHeight(6)
  ChatFrameMenuButton:SetWidth(6)

  pfUI.chat.editbox = CreateFrame("Frame", "pfChatInputBox", UIParent)
  if pfUI_config.chat.text.input_height == "0" then
    pfUI.chat.editbox:SetHeight(22)
  else
    pfUI.chat.editbox:SetHeight(pfUI_config.chat.text.input_height)
  end

  pfUI.chat.editbox:ClearAllPoints()
  local anchor
  if pfUI.bars then
    anchor = pfUI.bars.bottom
  else
    anchor = pfUI.chat.left
  end
  pfUI.chat.editbox:SetPoint("BOTTOM", anchor, "TOP", 0, default_border*4)
  pfUI.utils:UpdateMovable(pfUI.chat.editbox)

  if pfUI_config.chat.text.input_width == "0" then
    pfUI.chat.editbox:SetWidth(default_border*3 + pfUI_config.bars.icon_size * 12 + default_border * 12) -- actionbar size
  else
    pfUI.chat.editbox:SetWidth(pfUI_config.chat.text.input_width)
  end

  ChatFrameEditBox:SetParent(pfUI.chat.editbox)
  ChatFrameEditBox:SetAllPoints(pfUI.chat.editbox)
  pfUI.utils:CreateBackdrop(ChatFrameEditBox, default_border)

  for i,v in ipairs({ChatFrameEditBox:GetRegions()}) do
    if i==6 or i==7 or i==8 then v:Hide() end
    if v.SetFont then
      v:SetFont(pfUI.font_default, pfUI_config.global.font_size + 1, "OUTLINE")
    end
  end
  ChatFrameEditBox:SetAltArrowKeyMode(false)

  local default = " " .. "%s" .. "|r:" .. "\32"
  CHAT_CHANNEL_GET = "%s" .. "|r:" .. "\32"
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
    if not getglobal("ChatFrame"..i).HookAddMessage then
      getglobal("ChatFrame"..i).HookAddMessage = getglobal("ChatFrame"..i).AddMessage
    end
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
          text = string.gsub(text, pattern, "["..channel.."] ".."%1")
        end

        -- show timestamp in chat
        if pfUI_config.chat.text.time == "1" then
          local left = string.sub(pfUI_config.chat.text.timebracket, 1, 1)
          local right = string.sub(pfUI_config.chat.text.timebracket, 2, 2)

          local r,g,b,a = strsplit(",", pfUI_config.chat.text.timecolor)
          local chex = string.format("%02x%02x%02x%02x", a*255, r*255, g*255, b*255)
          text = "|c" .. chex .. left .. date(pfUI_config.chat.text.timeformat) .. right .. "|r " .. text
        end

        getglobal("ChatFrame"..i).HookAddMessage(frame, text, unpack(arg))
      end
    end
  end
end)
