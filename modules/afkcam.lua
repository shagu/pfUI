pfUI:RegisterModule("afkcam", "vanilla:tbc", function ()
  local MARKED_AFK_CAPTURE = SanitizePattern(MARKED_AFK_MESSAGE)
  local social_chats = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER"
  }

  local afkcam = CreateFrame("Frame", "pfAFKCam", WorldFrame)
  local overlay = CreateFrame("Button", "pfAFKCamOverlay", afkcam)
  overlay.top = overlay:CreateTexture("pfAFKGradientTop", "BACKGROUND")
  overlay.top:SetPoint("TOPLEFT", overlay, "TOPLEFT")
  overlay.top:SetPoint("TOPRIGHT", overlay, "TOPRIGHT")
  overlay.top:SetHeight(100)
  overlay.top:SetTexture(1,1,1,1)
  overlay.top:SetGradientAlpha("VERTICAL", 0,0,0,0,  0,0,0,1)

  overlay.bottom = overlay:CreateTexture("pfAFKGradientTop", "BACKGROUND")
  overlay.bottom:SetPoint("BOTTOMLEFT", overlay, "BOTTOMLEFT")
  overlay.bottom:SetPoint("BOTTOMRIGHT", overlay, "BOTTOMRIGHT")
  overlay.bottom:SetHeight(100)
  overlay.bottom:SetTexture(1,1,1,1)
  overlay.bottom:SetGradientAlpha("VERTICAL", 0,0,0,1,  0,0,0,0)

  overlay:SetFrameStrata("DIALOG")
  overlay:SetAllPoints(WorldFrame)

  overlay:SetScript("OnMouseUp",function()
    SendChatMessage("","AFK")
    this._parent:stop()
  end)
  overlay:SetScript("OnShow", function()
    this:EnableKeyboard(true)
  end)
  overlay:SetScript("OnHide", function()
    this:EnableKeyboard(false)
  end)
  overlay:SetScript("OnKeyUp",function()
    SendChatMessage("","AFK")
    this._parent:stop()
  end)
  overlay:Hide()

  local chat = CreateFrame("ScrollingMessageFrame", "pfAFKCamChat", overlay)
  chat:EnableMouse(false)
  chat:EnableMouseWheel(true)
  chat:SetHeight(150)
  chat:SetWidth(500)
  chat:SetPoint("BOTTOMLEFT",overlay,"BOTTOMLEFT", 10, 10)
  chat:SetTimeVisible(1800.0)
  chat:SetMaxLines(500)
  chat:SetFading(false)
  chat:SetJustifyH("LEFT")
  chat:SetFont(pfUI.font_default, C.global.font_size + 1, "OUTLINE")
  chat:SetScript("OnEvent", function()
    if not this:IsVisible() then return end
    local info = _G.ChatTypeInfo[string.gsub(event,"CHAT_MSG_","")]
    if not info then return end
    local class = GetUnitData(arg2 or "")
    local author, msg
    if class and class ~= UNKNOWN then
      local class_color = rgbhex(RAID_CLASS_COLORS[class])
      author = string.format("%s%s|r",class_color,arg2)
    else
      author = arg2
    end
    msg = string.format("%s|cffffffff:|r %s",author,arg1)
    this:AddMessage(msg, info.r, info.g, info.b, 1.0)
  end)
  for _,ctype in ipairs(social_chats) do
    chat:RegisterEvent(ctype)
  end
  chat:SetScript("OnMouseWheel",function()
    if arg1 > 0 then
      this:ScrollUp()
    else
      this:ScrollDown()
    end
  end)
  overlay.chat = chat

  overlay._parent = afkcam
  afkcam.overlay = overlay

  local clock = CreateFrame("Frame", "pfAFKClock", overlay)
  clock:SetAllPoints(overlay)
  clock.time = clock:CreateFontString("Status", "OVERLAY")
  clock.time:SetFont(pfUI.media["font:Hooge.ttf"], 32, "THICKOUTLINE")
  clock.time:SetJustifyH("CENTER")
  clock.time:SetPoint("TOP", 0, -10)
  clock:SetScript("OnUpdate", function()
    local h, m = GetGameTime()
    local noon = "AM"
    local time = ""
    if C.global.twentyfour == "0" then
      if C.global.servertime == "1" then
        if h == 0 then
          h = 12
        elseif h == 12 then
          noon = "PM"
        elseif h > 12 then
          h = h - 12
          noon = "PM"
        end
        time = string.format("%.2d|cff33ffcc:|r%.2d %s", h, m, noon)
      else
        time = date("%I|cff33ffcc:|r%M %p")
      end
      clock.time:SetText(time)
    else
      if C.global.servertime == "1" then
        time = string.format("%.2d|cff33ffcc:|r%.2d", h, m)
      else
        time = date("%H|cff33ffcc:|r%M")
      end
    end
    clock.time:SetText(time)
  end)

  function afkcam:start()
    if afkcam._spinning then return end
    afkcam._speed = GetCVar("cameraYawMoveSpeed")
    afkcam._ownname = GetCVar("UnitNameOwn")
    afkcam._ui_visible = UIParent:IsVisible()
    SaveView(4)
    if afkcam._ui_visible then
      CloseAllWindows()
      UIParent:Hide()
    end
    if afkcam._ownname == "0" then
      SetCVar("UnitNameOwn", "1")
    end
    SetCVar("cameraYawMoveSpeed","8")
    MoveViewRightStart()
    afkcam.overlay:Show()
    afkcam.overlay.chat:Clear()
    afkcam._spinning = true
  end

  function afkcam:stop()
    MoveViewRightStop()
    SetCVar("cameraYawMoveSpeed",afkcam._speed)
    SetCVar("UnitNameOwn", afkcam._ownname)
    SetView(4)

    SetCVar("cameraCustomViewSmoothing", "1")

    if not UIParent:IsVisible() and afkcam._ui_visible then
      UIParent:Show()
    end
    if pfUI.uf.player then pfUI.uf:RefreshUnit(pfUI.uf.player, "all") end
    afkcam.overlay:Hide()
    afkcam._spinning = false
  end

  local delay = CreateFrame("Frame")
  delay:Hide()

  delay:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
  delay:SetScript("OnEvent", function()
    this.delay = GetTime() + 10
  end)

  delay:SetScript("OnUpdate", function()
    if ( this.tick or 0) > GetTime() then return else this.tick = GetTime() + 1 end

    local name = UnitName("player")
    local cast = UnitCastingInfo(name)
    if not cast then cast = UnitChannelInfo(name) end
    if not this.delay then this.delay = 0 end

    if cast then
      this.delay = GetTime() + 10
    end

    if this.delay < GetTime() then
      afkcam:start()
      this:Hide()
    end
  end)

  afkcam:SetScript("OnEvent", function()
    if event == "CHAT_MSG_SYSTEM" then
      if (arg1 == _G.MARKED_AFK) or strfind(arg1, MARKED_AFK_CAPTURE) then
        delay:Show()
      elseif (arg1 == _G.CLEARED_AFK) then
        delay:Hide()
        this:stop()
      end
    else
      if this._spinning then
        delay:Hide()
        this:stop()
      end
    end
  end)

  afkcam:RegisterEvent("CHAT_MSG_SYSTEM")
  afkcam:RegisterEvent("PLAYER_REGEN_DISABLED")
  afkcam:RegisterEvent("PLAYER_LEAVING_WORLD") -- reseting cvars on PLAYER_LOGOUT crashes the client ¯\_(ツ)_/¯
end)
