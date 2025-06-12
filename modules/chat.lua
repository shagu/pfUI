pfUI:RegisterModule("chat", "vanilla:tbc", function ()
  local panelfont = C.panel.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local panelfont_size = C.panel.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
  local rawborder, default_border = GetBorderSize("chat")

  if pfUI.client <= 11200 then
    -- The 'GetChatWindowInfo' function returns shown as 'false' while the UIParent is hidden (Alt+Z).
    -- Based on that return value, the 'FloatingChatFrame_Update' would remove every chat frame,
    -- that isn't tabbed while the interface is hidden. With this hook we prevent the original
    -- 'FloatingChatFrame_Update' function from being called during that time.

    local HookFloatingChatFrame_Update = _G.FloatingChatFrame_Update
    _G.FloatingChatFrame_Update = function(id, onUpdateEvent)
      if not UIParent:IsShown() then return end
      HookFloatingChatFrame_Update(id, onUpdateEvent)
    end
  end

  _G.CHAT_FONT_HEIGHTS = { 8, 10, 12, 14, 16, 18, 20 }

  -- add dropdown menu button to ignore player
  UnitPopupButtons["IGNORE_PLAYER"] = { text = IGNORE_PLAYER, dist = 0 }
  for index,value in ipairs(UnitPopupMenus["FRIEND"]) do
    if value == "GUILD_LEAVE" then
      table.insert(UnitPopupMenus["FRIEND"], index+1, "IGNORE_PLAYER")
    end
  end

  hooksecurefunc("UnitPopup_OnClick", function(self)
    if this.value == "IGNORE_PLAYER" then
      AddIgnore(_G[UIDROPDOWNMENU_INIT_MENU].name)
    end
  end)

  local realm = GetRealmName()
  local player = UnitName("player")
  local history
  local function SaveChatHistory(id, msg, r, g, b)
    -- create cache tables if not existing
    pfUI_cache = pfUI_cache or {}
    pfUI_cache["chathistory"] = pfUI_cache["chathistory"] or {}
    pfUI_cache["chathistory"][realm] = pfUI_cache["chathistory"][realm] or {}
    pfUI_cache["chathistory"][realm][player] = pfUI_cache["chathistory"][realm][player] or {}
    pfUI_cache["chathistory"][realm][player][id] = pfUI_cache["chathistory"][realm][player][id] or {}

    if r and g and b then
      local color = rgbhex(r*.5+.2, g*.5+.2, b*.5+.2)
      msg = string.gsub(msg, "^", color)
      msg = string.gsub(msg, "|r", "|r" .. color)
    end

    history = pfUI_cache["chathistory"][realm][player][id]
    table.insert(history, 1, msg)
    if history[30] then table.remove(history, 30) end
  end

  local function GetChatHistory(id)
    -- create cache tables if not existing
    pfUI_cache = pfUI_cache or {}
    pfUI_cache["chathistory"] = pfUI_cache["chathistory"] or {}
    pfUI_cache["chathistory"][realm] = pfUI_cache["chathistory"][realm] or {}
    pfUI_cache["chathistory"][realm][player] = pfUI_cache["chathistory"][realm][player] or {}
    pfUI_cache["chathistory"][realm][player][id] = pfUI_cache["chathistory"][realm][player][id] or {}

    return pfUI_cache["chathistory"][realm][player][id]
  end

  pfUI.chat = CreateFrame("Frame",nil,UIParent)

  pfUI.chat.left = CreateFrame("Frame", "pfChatLeft", UIParent)
  pfUI.chat.left.OnMove = function()
    pfUI.chat:RefreshChat()
  end

  pfUI.chat.left:SetFrameStrata("BACKGROUND")
  pfUI.chat.left:SetWidth(C.chat.left.width)
  pfUI.chat.left:SetHeight(C.chat.left.height)
  pfUI.chat.left:SetPoint("BOTTOMLEFT", 2*default_border,2*default_border)
  pfUI.chat.left:SetScript("OnShow", function() pfUI.chat:RefreshChat() end)
  UpdateMovable(pfUI.chat.left)
  CreateBackdrop(pfUI.chat.left, default_border, nil, .8)
  if C.chat.global.frameshadow == "1" then
    CreateBackdropShadow(pfUI.chat.left)
  end

  if C.chat.global.custombg == "1" then
    local r, g, b, a = strsplit(",", C.chat.global.background)
    pfUI.chat.left.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

    local r, g, b, a = strsplit(",", C.chat.global.border)
    pfUI.chat.left.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
  end

  pfUI.chat.left.panelTop = CreateFrame("Frame", "leftChatPanelTop", pfUI.chat.left)
  pfUI.chat.left.panelTop:ClearAllPoints()
  pfUI.chat.left.panelTop:SetHeight(C.global.font_size+default_border*2)
  pfUI.chat.left.panelTop:SetPoint("TOPLEFT", pfUI.chat.left, "TOPLEFT", default_border, -default_border)
  pfUI.chat.left.panelTop:SetPoint("TOPRIGHT", pfUI.chat.left, "TOPRIGHT", -default_border, -default_border)
  if C.chat.global.tabdock == "1" then
    CreateBackdrop(pfUI.chat.left.panelTop, default_border, nil, .8)
  end

  pfUI.chat.URLPattern = {
    WWW = {
      ["rx"]=" (www%d-)%.([_A-Za-z0-9-]+)%.(%S+)%s?",
      ["fm"]="%s.%s.%s"},
    PROTOCOL = {
      ["rx"]=" (%a+)://(%S+)%s?",
      ["fm"]="%s://%s"},
    EMAIL = {
      ["rx"]=" ([_A-Za-z0-9-%.:]+)@([_A-Za-z0-9-]+)(%.)([_A-Za-z0-9-]+%.?[_A-Za-z0-9-]*)%s?",
      ["fm"]="%s@%s%s%s"},
    PORTIP = {
      ["rx"]=" (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?",
      ["fm"]="%s.%s.%s.%s:%s"},
    IP = {
      ["rx"]=" (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?",
      ["fm"]="%s.%s.%s.%s"},
    SHORTURL = {
      ["rx"]=" (%a+)%.(%a+)/(%S+)%s?",
      ["fm"]="%s.%s/%s"},
    URLIP = {
      ["rx"]=" ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%:([_0-9-]+)%s?",
      ["fm"]="%s.%s.%s:%s"},
    URL = {
      ["rx"]=" ([_A-Za-z0-9-]+)%.([_A-Za-z0-9-]+)%.(%S+)%s?",
      ["fm"]="%s.%s.%s"},
  }

  pfUI.chat.URLFuncs = {
    ["WWW"] = function(a1,a2,a3) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.WWW.fm,a1,a2,a3) end,
    ["PROTOCOL"] = function(a1,a2) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.PROTOCOL.fm,a1,a2) end,
    ["EMAIL"] = function(a1,a2,a3,a4) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.EMAIL.fm,a1,a2,a3,a4) end,
    ["PORTIP"] = function(a1,a2,a3,a4,a5) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.PORTIP.fm,a1,a2,a3,a4,a5) end,
    ["IP"] = function(a1,a2,a3,a4) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.IP.fm,a1,a2,a3,a4) end,
    ["SHORTURL"] = function(a1,a2,a3) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.SHORTURL.fm,a1,a2,a3) end,
    ["URLIP"] = function(a1,a2,a3,a4) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.URLIP.fm,a1,a2,a3,a4) end,
    ["URL"] = function(a1,a2,a3) return pfUI.chat:FormatLink(pfUI.chat.URLPattern.URL.fm,a1,a2,a3) end,
  }

  -- url copy dialog
  function pfUI.chat:FormatLink(formatter,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
    if not (formatter and a1) then return end
    local newtext = string.format(formatter,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)

    -- check the last capture index for consecutive trailing dots (invalid top level domain)
    local invalidtld
    for _, arg in pairs({a10,a9,a8,a7,a6,a5,a4,a3,a2,a1}) do
      if arg then
        invalidtld = string.find(arg, "(%.%.)$")
        break
      end
    end

    if (invalidtld) then return newtext end
    if formatter == self.URLPattern.EMAIL.fm then -- email parser
      local colon = string.find(a1,":")
      if (colon) and string.len(a1) > colon then
        if not (string.sub(a1,1,6) == "mailto") then
          local prefix,address = string.sub(newtext,1,colon),string.sub(newtext,colon+1)
          return string.format(" %s|cffccccff|Hurl:%s|h[%s]|h|r ",prefix,address,address)
        end
      end
    end
    return " |cffccccff|Hurl:" .. newtext .. "|h[" .. newtext .. "]|h|r "
  end

  function pfUI.chat:HandleLink(text)
    local URLPattern = pfUI.chat.URLPattern
    text = string.gsub (text, URLPattern.WWW.rx, pfUI.chat.URLFuncs.WWW)
    text = string.gsub (text, URLPattern.PROTOCOL.rx, pfUI.chat.URLFuncs.PROTOCOL)
    text = string.gsub (text, URLPattern.EMAIL.rx, pfUI.chat.URLFuncs.EMAIL)
    text = string.gsub (text, URLPattern.PORTIP.rx, pfUI.chat.URLFuncs.PORTIP)
    text = string.gsub (text, URLPattern.IP.rx, pfUI.chat.URLFuncs.IP)
    text = string.gsub (text, URLPattern.SHORTURL.rx, pfUI.chat.URLFuncs.SHORTURL)
    text = string.gsub (text, URLPattern.URLIP.rx, pfUI.chat.URLFuncs.URLIP)
    text = string.gsub (text, URLPattern.URL.rx, pfUI.chat.URLFuncs.URL)
    return text
  end

  pfUI.chat.urlcopy = CreateFrame("Frame", "pfURLCopy", UIParent)
  pfUI.chat.urlcopy:Hide()
  pfUI.chat.urlcopy:SetWidth(270)
  pfUI.chat.urlcopy:SetHeight(65)
  pfUI.chat.urlcopy:SetFrameStrata("FULLSCREEN")
  pfUI.chat.urlcopy:SetPoint("CENTER", 0, 0)
  CreateBackdrop(pfUI.chat.urlcopy, nil, nil, 0.8)

  pfUI.chat.urlcopy:SetMovable(true)
  pfUI.chat.urlcopy:EnableMouse(true)
  pfUI.chat.urlcopy:RegisterForDrag("LeftButton")
  pfUI.chat.urlcopy:SetScript("OnDragStart",function()
    this:StartMoving()
  end)

  pfUI.chat.urlcopy:SetScript("OnDragStop",function()
    this:StopMovingOrSizing()
  end)

  pfUI.chat.urlcopy:SetScript("OnShow", function()
    this.text:HighlightText()
  end)

  pfUI.chat.urlcopy.text = CreateFrame("EditBox", "pfURLCopyEditBox", pfUI.chat.urlcopy)
  pfUI.chat.urlcopy.text:SetTextColor(.2,1,.8,1)
  pfUI.chat.urlcopy.text:SetJustifyH("CENTER")

  pfUI.chat.urlcopy.text:SetWidth(250)
  pfUI.chat.urlcopy.text:SetHeight(20)
  pfUI.chat.urlcopy.text:SetPoint("TOP", pfUI.chat.urlcopy, "TOP", 0, -10)
  pfUI.chat.urlcopy.text:SetFontObject(GameFontNormal)
  CreateBackdrop(pfUI.chat.urlcopy.text)

  pfUI.chat.urlcopy.text:SetScript("OnEscapePressed", function(self)
    pfUI.chat.urlcopy:Hide()
  end)

  pfUI.chat.urlcopy.text:SetScript("OnEditFocusLost", function(self)
    pfUI.chat.urlcopy:Hide()
  end)

  pfUI.chat.urlcopy.close = CreateFrame("Button", "pfURLCopyClose", pfUI.chat.urlcopy, "UIPanelButtonTemplate")
  pfUI.api.SkinButton(pfUI.chat.urlcopy.close)
  pfUI.chat.urlcopy.close:SetWidth(70)
  pfUI.chat.urlcopy.close:SetHeight(18)
  pfUI.chat.urlcopy.close:SetPoint("BOTTOMRIGHT", pfUI.chat.urlcopy, "BOTTOMRIGHT", -10, 10)

  pfUI.chat.urlcopy.close:SetText(T["Close"])
  pfUI.chat.urlcopy.close:SetScript("OnClick", function()
    pfUI.chat.urlcopy:Hide()
  end)

  pfUI.chat.urlcopy.SetItemRef = SetItemRef
  pfUI.chat.urlcopy.CopyText = function(text)
    pfUI.chat.urlcopy.text:SetText(text)
    pfUI.chat.urlcopy:Show()
  end

  function _G.SetItemRef(link, text, button)
    if (strsub(link, 1, 3) == "url") then
      if string.len(link) > 4 and string.sub(link,1,4) == "url:" then
        pfUI.chat.urlcopy.CopyText(string.sub(link,5, string.len(link)))
      end
      return
    end
    pfUI.chat.urlcopy.SetItemRef(link, text, button)
  end

  pfUI.chat.right = CreateFrame("Frame", "pfChatRight", UIParent)
  pfUI.chat.right:SetFrameStrata("BACKGROUND")
  pfUI.chat.right:SetWidth(C.chat.right.width)
  pfUI.chat.right:SetHeight(C.chat.right.height)
  pfUI.chat.right:SetPoint("BOTTOMRIGHT", -2*default_border,2*default_border)
  pfUI.chat.right:SetScript("OnShow", function() pfUI.chat:RefreshChat() end)
  UpdateMovable(pfUI.chat.right)
  CreateBackdrop(pfUI.chat.right, default_border, nil, .8)
  if C.chat.global.frameshadow == "1" then
    CreateBackdropShadow(pfUI.chat.right)
  end

  if C.chat.global.custombg == "1" then
    local r, g, b, a = strsplit(",", C.chat.global.background)
    pfUI.chat.right.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

    local r, g, b, a = strsplit(",", C.chat.global.border)
    pfUI.chat.right.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
  end

  pfUI.chat.right.panelTop = CreateFrame("Frame", "rightChatPanelTop", pfUI.chat.right)
  pfUI.chat.right.panelTop:ClearAllPoints()
  pfUI.chat.right.panelTop:SetHeight(C.global.font_size+default_border*2)
  pfUI.chat.right.panelTop:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", default_border, -default_border)
  pfUI.chat.right.panelTop:SetPoint("TOPRIGHT", pfUI.chat.right, "TOPRIGHT", -default_border, -default_border)
  if C.chat.global.tabdock == "1" then
    CreateBackdrop(pfUI.chat.right.panelTop, default_border, nil, .8)
  end

  pfUI.chat:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.chat:RegisterEvent("UI_SCALE_CHANGED")

  local function ChatOnMouseWheel()
    if (arg1 > 0) then
      if IsShiftKeyDown() then
        this:ScrollToTop()
      else
        for i=1, C.chat.global.scrollspeed do
          this:ScrollUp()
        end
      end
    elseif (arg1 < 0) then
      if IsShiftKeyDown() then
        this:ScrollToBottom()
      else
        for i=1, C.chat.global.scrollspeed do
          this:ScrollDown()
        end
      end
    end
  end

  function pfUI.chat:RefreshChat()
    local panelheight = C.global.font_size*1.5 + default_border*2 + 2

    if C.chat.global.sticky == "1" then
      ChatTypeInfo.WHISPER.sticky = 1
      ChatTypeInfo.OFFICER.sticky = 1
      ChatTypeInfo.RAID_WARNING.sticky = 1
      ChatTypeInfo.CHANNEL.sticky = 1
    end

    ChatFrameMenuButton:Hide()
    ChatMenu:SetClampedToScreen(true)
    CreateBackdrop(ChatMenu)
    CreateBackdrop(EmoteMenu)
    CreateBackdrop(LanguageMenu)
    CreateBackdrop(VoiceMacroMenu)

    local combatlogpanel = (CombatLogQuickButtonFrame_Custom and CombatLogQuickButtonFrame_Custom:GetHeight() or 0)

    for i=1, NUM_CHAT_WINDOWS do
      local frame = _G["ChatFrame"..i]
      local tab = _G["ChatFrame"..i.."Tab"]

      local combat = 0
      for _, msg in pairs(_G["ChatFrame"..i].messageTypeList) do
        if strfind(msg, "SPELL", 1) or strfind(msg, "COMBAT", 1) then
          combat = combat + 1
        end
      end

      if combat > 5 then
        frame.pfCombatLog = true
      else
        frame.pfCombatLog = nil
      end


      if not frame.pfStartMoving then
        frame.pfStartMoving = frame.StartMoving
        frame.StartMoving = function(a1)
          pfUI.chat.hideLock = true
          frame.pfStartMoving(a1)
        end
      end

      if not frame.pfStopMovingOrSizing then
        frame.pfStopMovingOrSizing = frame.StopMovingOrSizing
        frame.StopMovingOrSizing = function(a1)
          frame.pfStopMovingOrSizing(a1)
          pfUI.chat.RefreshChat()
          pfUI.chat.hideLock = false
        end
      end

      if C.chat.global.fadeout == "1" then
        frame:SetFading(true)
        frame:SetTimeVisible(tonumber(C.chat.global.fadetime))
      else
        frame:SetFading(false)
      end

      if i == 3 and C.chat.right.enable == "1" then
        -- Loot & Spam
        local bottompadding = pfUI.panel and pfUI.panel.right:IsShown() and not pfUI_config.position["pfPanelRight"] and panelheight or default_border
        tab:SetParent(pfUI.chat.right.panelTop)
        frame:SetParent(pfUI.chat.right)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", pfUI.chat.right ,"TOPLEFT", default_border, -panelheight)
        frame:SetPoint("BOTTOMRIGHT", pfUI.chat.right ,"BOTTOMRIGHT", -default_border, bottompadding)
        frame:Show()
      elseif frame.isDocked then
        -- Left Chat
        local bottompadding = pfUI.panel and pfUI.panel.left:IsShown() and not pfUI_config.position["pfPanelLeft"] and panelheight or default_border
        FCF_DockFrame(frame)
        tab:SetParent(pfUI.chat.left.panelTop)
        frame:SetParent(pfUI.chat.left)
        frame:ClearAllPoints()
        if i == 2 then
          frame:SetPoint("TOPLEFT", pfUI.chat.left ,"TOPLEFT", default_border, -panelheight - combatlogpanel)
        else
          frame:SetPoint("TOPLEFT", pfUI.chat.left ,"TOPLEFT", default_border, -panelheight)
        end
        frame:SetPoint("BOTTOMRIGHT", pfUI.chat.left ,"BOTTOMRIGHT", -default_border, bottompadding)
      else
        FCF_UnDockFrame(frame)
        frame:SetParent(UIParent)
        tab:SetParent(UIParent)
      end

      -- Combat Log
      if C.chat.global.combathide == "1" and frame.pfCombatLog then
        FCF_UnDockFrame(frame)
        FCF_Close(frame)
      end

      -- hide textures
      for j,v in ipairs({tab:GetRegions()}) do
        if j==5 then v:SetTexture(0,0,0,0) end
        v:SetHeight(C.global.font_size+default_border*2)
      end

      -- remove background on docked frames
      for _, tex in pairs(CHAT_FRAME_TEXTURES) do
        local texture = _G["ChatFrame"..i..tex]
        if tex == "Background" then
          texture.oldTexture = texture.oldTexture or texture:GetTexture()
          if frame:GetParent() == pfUI.chat.left or frame:GetParent() == pfUI.chat.right then
            texture:SetTexture()
            texture:Hide()
          else
            texture:SetTexture(texture.oldTexture)
            texture:Show()
          end
        else
          texture:SetTexture()
          texture:Hide()
        end
      end

      _G["ChatFrame" .. i .. "ResizeBottom"]:Hide()
      _G["ChatFrame" .. i .. "TabText"]:SetJustifyV("CENTER")
      _G["ChatFrame" .. i .. "TabText"]:SetHeight(C.global.font_size+default_border*2)
      _G["ChatFrame" .. i .. "TabText"]:SetPoint("BOTTOM", 0, default_border)
      _G["ChatFrame" .. i .. "TabLeft"]:SetAlpha(0)
      _G["ChatFrame" .. i .. "TabMiddle"]:SetAlpha(0)
      _G["ChatFrame" .. i .. "TabRight"]:SetAlpha(0)

      if C.chat.global.chatflash == "1" then
        _G["ChatFrame" .. i .. "TabFlash"]:SetAllPoints(_G["ChatFrame" .. i .. "TabText"])
      else
        _G["ChatFrame" .. i .. "TabFlash"].Show = function() return end
      end

      local _, class = UnitClass("player")
      _G["ChatFrame" .. i .. "TabText"]:SetTextColor((RAID_CLASS_COLORS[class].r + .3) * .5, (RAID_CLASS_COLORS[class].g + .3) * .5, (RAID_CLASS_COLORS[class].b + .3) * .5, 1)
      _G["ChatFrame" .. i .. "TabText"]:SetFont(panelfont,panelfont_size, "OUTLINE")

      if _G["ChatFrame" .. i].isDocked or _G["ChatFrame" .. i]:IsVisible() then
        _G["ChatFrame" .. i .. "Tab"]:Show()
      end

      frame:EnableMouseWheel(true)
      frame:SetScript("OnMouseWheel", ChatOnMouseWheel)
    end


    -- update dock frame for all windows
    for index, value in pairs(DOCKED_CHAT_FRAMES) do
      FCF_UpdateButtonSide(value)
    end
  end

  hooksecurefunc("FCF_SaveDock", pfUI.chat.RefreshChat)

  if C.chat.global.tabmouse == "1" then
    pfUI.chat.mouseovertab = CreateFrame("Frame")
    pfUI.chat.mouseovertab:SetScript("OnUpdate", function()

      if pfUI.chat.hideLock then return end

      if MouseIsOver(pfUI.chat.left, 10, -10, -10, 10) then
        pfUI.chat.left.panelTop:Show()
        FCF_DockUpdate()
      elseif MouseIsOver(pfUI.chat.right, 10, -10, -10, 10) then
        -- disable while dock is active
        if pfUI.chat.right:GetAlpha() == 0 then return end

        pfUI.chat.right.panelTop:Show()
        FCF_DockUpdate()
      else
        pfUI.chat.left.panelTop:Hide()
        pfUI.chat.right.panelTop:Hide()
      end
    end)
  end

  function pfUI.chat.SetupRightChat(state)
    if state then
      C.chat.right.enable = "1"
      pfUI.chat.right:Show()
    else
      C.chat.right.enable = "0"
      pfUI.chat.right:Hide()
    end
  end

  function pfUI.chat.SetupPositions()
    -- close all chat windows
    for i=1, NUM_CHAT_WINDOWS do
      FCF_Close(_G["ChatFrame"..i])
      FCF_DockUpdate()
    end

    -- Main Window
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint("TOPLEFT", pfUI.chat.left ,"TOPLEFT", 5, -25)
    ChatFrame1:SetPoint("BOTTOMRIGHT", pfUI.chat.left ,"BOTTOMRIGHT", -5, 25)

    FCF_SetLocked(ChatFrame1, 1)
    FCF_SetWindowName(ChatFrame1, GENERAL)
    FCF_SetWindowColor(ChatFrame1, 0, 0, 0)
    FCF_SetWindowAlpha(ChatFrame1, 0)
    FCF_SetChatWindowFontSize(ChatFrame1, 12)
    ChatFrame1:SetUserPlaced(1)

    -- Combat Log
    FCF_SetLocked(ChatFrame2, 1)
    FCF_SetWindowName(ChatFrame2, COMBAT_LOG)
    FCF_SetWindowColor(ChatFrame2, 0, 0, 0)
    FCF_SetWindowAlpha(ChatFrame2, 0)
    FCF_SetChatWindowFontSize(ChatFrame2, 12)
    ChatFrame2:SetUserPlaced(1)

    -- Loot & Spam
    if C.chat.right.enable == "1" then
      -- set position of Loot & Spam
      FCF_SetLocked(ChatFrame3, 1)
      FCF_SetWindowName(ChatFrame3, T["Loot & Spam"])
      FCF_SetWindowColor(ChatFrame3, 0, 0, 0)
      FCF_SetWindowAlpha(ChatFrame3, 0)
      FCF_SetChatWindowFontSize(ChatFrame3, 12)
      FCF_UnDockFrame(ChatFrame3)
      FCF_SetTabPosition(ChatFrame3, 0)
      ChatFrame3:ClearAllPoints()
      ChatFrame3:SetPoint("TOPLEFT", pfUI.chat.right ,"TOPLEFT", 5, -25)
      ChatFrame3:SetPoint("BOTTOMRIGHT", pfUI.chat.right ,"BOTTOMRIGHT", -5, 25)
      ChatFrame3:SetUserPlaced(1)
    end

    pfUI.chat:RefreshChat()
    FCF_DockUpdate()
  end

  function pfUI.chat.SetupChannels()
    ChatFrame_RemoveAllMessageGroups(ChatFrame1)
    ChatFrame_RemoveAllMessageGroups(ChatFrame2)
    ChatFrame_RemoveAllMessageGroups(ChatFrame3)

    ChatFrame_RemoveAllChannels(ChatFrame1)
    ChatFrame_RemoveAllChannels(ChatFrame2)
    ChatFrame_RemoveAllChannels(ChatFrame3)

    local normalg = { "SYSTEM", "SAY", "YELL", "WHISPER", "PARTY", "GUILD", "GUILD_OFFICER", "CREATURE", "CHANNEL", "EMOTE", "RAID", "RAID_LEADER", "RAID_WARNING", "BATTLEGROUND", "BATTLEGROUND_LEADER", "MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER" }
    for _,group in pairs(normalg) do
      ChatFrame_AddMessageGroup(ChatFrame1, group)
    end

    ChatFrame_ActivateCombatMessages(ChatFrame2)

    if C.chat.right.enable == "1" then
      local spamg = { "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT" }
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
    pfUI.chat:RefreshChat()
  end

  pfUI.chat:SetScript("OnEvent", function()
    -- set the default chat
    FCF_SelectDockFrame(SELECTED_CHAT_FRAME)

    -- update all chat settings
    pfUI.chat:RefreshChat()
    FCF_DockUpdate()
    if C.chat.right.enable == "0" then
      pfUI.chat.right:Hide()
    end
  end)

  local function SkipFading(self, alpha)
    UIFrameFadeRemoveFrame(self)
    if SELECTED_CHAT_FRAME:GetID() == self:GetID() then
      self:_SetAlpha(1)
    else
      self:_SetAlpha(0.5)
    end
  end

  for i=1, NUM_CHAT_WINDOWS do
    _G["ChatFrame" .. i .. "UpButton"]:Hide()
    _G["ChatFrame" .. i .. "UpButton"].Show = function() return end
    _G["ChatFrame" .. i .. "DownButton"]:Hide()
    _G["ChatFrame" .. i .. "DownButton"].Show = function() return end
    _G["ChatFrame" .. i .. "BottomButton"]:Hide()
    _G["ChatFrame" .. i .. "BottomButton"].Show = function() return end
    _G["ChatFrame" .. i .. "Tab"]._SetAlpha = _G["ChatFrame" .. i .. "Tab"].SetAlpha
    _G["ChatFrame" .. i .. "Tab"].SetAlpha = SkipFading
  end

  pfUI.chat.editbox = CreateFrame("Frame", "pfChatInputBox", UIParent)
  pfUI.chat.editbox:SetFrameStrata("DIALOG")
  if C.chat.text.input_height == "0" then
    pfUI.chat.editbox:SetHeight(22)

    if ChatFrameEditBoxLanguage then
      SkinButton(ChatFrameEditBoxLanguage)
      ChatFrameEditBoxLanguage:SetWidth(22)
      ChatFrameEditBoxLanguage:SetHeight(22)
    end
  else
    pfUI.chat.editbox:SetHeight(C.chat.text.input_height)

    if ChatFrameEditBoxLanguage then
      SkinButton(ChatFrameEditBoxLanguage)
      ChatFrameEditBoxLanguage:SetWidth(C.chat.text.input_height)
      ChatFrameEditBoxLanguage:SetHeight(C.chat.text.input_height)
    end
  end

  -- to make sure the bars are set up properly, we need to wait.
  local pfChatArrangeFrame = CreateFrame("Frame", "pfChatArrange", UIParent)
  pfChatArrangeFrame:RegisterEvent("CVAR_UPDATE")
  pfChatArrangeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfChatArrangeFrame:SetScript("OnEvent", function()
    pfUI.chat.editbox:ClearAllPoints()

    local anchor = pfUI.chat.left
    if pfUI.bars and pfUI.bars[6]:IsShown() then
      anchor = pfUI.bars[6]
    elseif pfUI.bars and pfUI.bars[1]:IsShown() then
      anchor = pfUI.bars[1]
    end

    if C.chat.text.input_width ~= "0" then
      pfUI.chat.editbox:SetPoint("BOTTOM", anchor, "TOP", 0, default_border*3)
      pfUI.chat.editbox:SetWidth(C.chat.text.input_width)
    else
      pfUI.chat.editbox:SetWidth(anchor:GetWidth())
      pfUI.chat.editbox:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, default_border*3)
      pfUI.chat.editbox:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, default_border*3)
    end

    UpdateMovable(pfUI.chat.editbox)
  end)


  ChatFrameEditBox:SetParent(pfUI.chat.editbox)
  ChatFrameEditBox:SetAllPoints(pfUI.chat.editbox)
  CreateBackdrop(ChatFrameEditBox, default_border)

  for i,v in ipairs({ChatFrameEditBox:GetRegions()}) do
    if i==6 or i==7 or i==8 then v:Hide() end
    if v.SetFont then
      v:SetFont(pfUI.font_default, C.global.font_size + 1, "OUTLINE")
    end
  end
  ChatFrameEditBox:SetAltArrowKeyMode(false)

  if C.chat.text.mouseover == "1" then
    for i=1, NUM_CHAT_WINDOWS do
      local frame = _G["ChatFrame" .. i]
      frame:SetScript("OnHyperlinkEnter", function()
        local _, _, linktype = string.find(arg1, "^(.-):(.+)$")
        if linktype == "item" then
          GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
          GameTooltip:SetHyperlink(arg1)
          GameTooltip:Show()
        end
      end)

      frame:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
      end)
    end
  end

  -- read and parse whisper color settings
  local cr, cg, cb, ca = strsplit(",", C.chat.global.whisper)
  cr, cg, cb = tonumber(cr), tonumber(cg), tonumber(cb)
  local wcol = rgbhex(cr, cg, cb)

  -- read and parse chat bracket settings
  local left = "|r" .. string.sub(C.chat.text.bracket, 1, 1)
  local right = string.sub(C.chat.text.bracket, 2, 2) .. "|r"

  -- read and parse chat time bracket settings
  local tleft = string.sub(C.chat.text.timebracket, 1, 1)
  local tright = string.sub(C.chat.text.timebracket, 2, 2)

  -- shorten chat channel indicators
  local default = " " .. "%s" .. "|r:" .. "\32"
  _G.CHAT_CHANNEL_GET = "%s" .. "|r:" .. "\32"
  _G.CHAT_GUILD_GET = left .. "G" .. right .. default
  _G.CHAT_OFFICER_GET = left .. "O" .. right .. default
  _G.CHAT_PARTY_GET = left .. "P" .. right .. default
  _G.CHAT_RAID_GET = left .. "R" .. right .. default
  _G.CHAT_RAID_LEADER_GET = left .. "RL" .. right .. default
  _G.CHAT_RAID_WARNING_GET = left .. "RW" .. right .. default
  _G.CHAT_BATTLEGROUND_GET = left .. "BG" .. right .. default
  _G.CHAT_BATTLEGROUND_LEADER_GET = left .. "BL" .. right .. default
  _G.CHAT_SAY_GET = left .. "S" .. right .. default
  _G.CHAT_YELL_GET = left .. "Y" .. right ..default

  if C.chat.global.whispermod == "1" then
    _G.CHAT_WHISPER_GET = wcol .. '[W]' .. default
    _G.CHAT_WHISPER_INFORM_GET = '[W]' .. default
  end

  local r,g,b,a = strsplit(",", C.chat.text.timecolor)
  local timecolorhex = rgbhex(r,g,b,a)

  local r,g,b = strsplit(",", C.chat.text.unknowncolor)
  local unknowncolorhex = rgbhex(r,g,b)

  local nothing = function() return end
  local original = FriendsFrame_OnEvent

  local who_query = CreateFrame("Frame")
  who_query:RegisterEvent("WHO_LIST_UPDATE")
  who_query:SetScript("OnEvent", function()
    if this.pending then
      -- restore everything once a query is received
      _G.FriendsFrame_OnEvent = original
      this.pending = nil
      SetWhoToUI(0)
    end
  end)

  local function ScanWhoName(name)
    -- abort if another query is ongoing
    if who_query.pending then return end
    who_query.pending = true

    -- prepare and send the who query
    _G.FriendsFrame_OnEvent = nothing
    SetWhoToUI(1)
    SendWho("n-"..name)
  end

  local function AddMessage(frame, text, a1, a2, a3, a4, a5)
    if not text then return end

    -- skip chat parsing on combat log
    if frame.pfCombatLog then
      return frame:HookAddMessage(text, a1, a2, a3, a4, a5)
    end

    -- Remove prat CLINKs
    text = gsub(text, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r") -- tbc
    text = gsub(text, "{CLINK:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r") -- vanilla

    -- Remove chatter CLINKs
    text = gsub(text, "{CLINK:item:(%x+):([%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-:[%d-]-):([^}]-)}", "|c%1|Hitem:%2|h[%3]|h|r")
    text = gsub(text, "{CLINK:enchant:(%x+):([%d-]-):([^}]-)}", "|c%1|Henchant:%2|h[%3]|h|r")
    text = gsub(text, "{CLINK:spell:(%x+):([%d-]-):([^}]-)}", "|c%1|Hspell:%2|h[%3]|h|r")
    text = gsub(text, "{CLINK:quest:(%x+):([%d-]-):([%d-]-):([^}]-)}", "|c%1|Hquest:%2:%3|h[%4]|h|r")

    -- detect urls
    if C.chat.text.detecturl == "1" then
      text = pfUI.chat:HandleLink(text)
    end

    -- display class colors if already indexed
    if C.chat.text.classcolor == "1" then
      for name in gfind(text, "|Hplayer:(.-)|h") do
        local real, _ = strsplit(":", name)
        local color = unknowncolorhex
        local match = false
        local class = GetUnitData(real)

        if class then
          if class ~= UNKNOWN then
            color = rgbhex(RAID_CLASS_COLORS[class])
            match = true
          end
        elseif C.chat.text.whosearchunknown == "1" then
          ScanWhoName(name)
        end

        if C.chat.text.tintunknown == "1" or match then
          text = string.gsub(text, "|Hplayer:"..name.."|h%["..real.."%]|h(.-:-)",
            left..color.."|Hplayer:"..name.."|h" .. color .. real .. "|h|r"..right.."%1")
        end
      end
    end

    -- reduce channel name to number
    if C.chat.text.channelnumonly == "1" then
      local channel = string.gsub(text, ".*%[(.-)%]%s+(.*|Hplayer).+", "%1")
      if string.find(channel, "%d+%. ") then
        channel = string.gsub(channel, "(%d+)%..*", "channel%1")
        channel = string.gsub(channel, "channel", "")
        text = string.gsub(text, "%[%d+%..-%]%s+(.*|Hplayer)", left .. channel .. right .. " %1")
      end
    end

    -- show timestamp in chat
    if C.chat.text.time == "1" then
      text = timecolorhex .. tleft .. date(C.chat.text.timeformat) .. tright .. "|r " .. text
    end

    -- save chat history
    if C.chat.global.whispermod == "1" and string.find(text, wcol, 1) == 1 then
      SaveChatHistory(frame:GetID(), string.gsub(text, wcol, ""), cr, cg, cb)
    else
      SaveChatHistory(frame:GetID(), text, a1, a2, a3)
    end

    if C.chat.global.whispermod == "1" then
      -- patch incoming whisper string to match the colors
      if string.find(text, wcol, 1) == 1 then
        text = string.gsub(text, "|r", "|r" .. wcol)
      end
    end

    frame:HookAddMessage(text, a1, a2, a3, a4, a5)
  end

  for i=1,NUM_CHAT_WINDOWS do
    if C.chat.global.maxlines ~= "128" then
      _G["ChatFrame"..i]:SetMaxLines(tonumber(C.chat.global.maxlines) or 128)
    end

    if not _G["ChatFrame"..i].HookAddMessage then
      if C.chat.text.history == "1" then
        -- write history to chat
        local history = GetChatHistory(i)
        for j=30,0,-1 do
          if history[j] then
            _G["ChatFrame"..i]:AddMessage(history[j], .7,.7,.7)
          end
        end
      end

      -- add chat parse and history hooks
      _G["ChatFrame"..i].HookAddMessage = _G["ChatFrame"..i].AddMessage
      _G["ChatFrame"..i].AddMessage = AddMessage
    end
  end

  -- create playerlinks on shift-click
  if C.chat.text.playerlinks == "1" then
    local pfHookSetItemRef = SetItemRef
    _G.SetItemRef = function(link, text, button)
      if ( strsub(link, 1, 6) == "player" ) then
        local name = strsub(link, 8)
        if ( name and (strlen(name) > 0) ) then
          local name, _ = strsplit(":", name)
          name = gsub(name, "([^%s]*)%s+([^%s]*)%s+([^%s]*)", "%3")
          name = gsub(name, "([^%s]*)%s+([^%s]*)", "%2")
          if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
            ChatFrameEditBox:Insert("|cffffffff|Hplayer:"..name.."|h["..name.."]|h|r")
            return
          end
        end
      end
      pfHookSetItemRef(link, text, button)
    end
  end
end)
