pfUI:RegisterModule("afkcam", function ()
  
  local _, class = UnitClass("player")
  local color = RAID_CLASS_COLORS[class]
  local MARKED_AFK_CAPTURE = string.gsub(_G.MARKED_AFK_MESSAGE, "%%s", "(.+)")
  local social_chats = {
    "CHAT_MSG_WHISPER", 
    "CHAT_MSG_PARTY", 
    "CHAT_MSG_RAID", 
    "CHAT_MSG_RAID_LEADER", 
    "CHAT_MSG_RAID_WARNING", 
    "CHAT_MSG_BATTLEGROUND", 
    "CHAT_MSG_BATTLEGROUND_LEADER", 
    "CHAT_MSG_GUILD", 
    "CHAT_MSG_OFFICER"}
  
  local afkcam = CreateFrame("Frame", "pfAFKCam", WorldFrame)
  local overlay = CreateFrame("Button", "pfAFKCamOverlay", afkcam)
  overlay:SetFrameStrata("DIALOG")
  overlay:SetAllPoints(WorldFrame)
  overlay.tex = overlay:CreateTexture("pfAFKCamOverlayShade", "OVERLAY")
  overlay.tex:SetAllPoints(overlay)
  overlay.tex:SetTexture(color.r,color.g,color.b,.05)
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
  chat:SetPoint("TOPLEFT",overlay,"TOPLEFT")
  chat:SetPoint("TOPRIGHT",overlay,"TOPRIGHT")
  chat:SetTimeVisible(1800.0)
  chat:SetMaxLines(500)
  chat:SetFading(false)
  chat:SetJustifyH("LEFT")
  --chat:SetInsertMode("TOP") -- not supported for scrollingmessageframe till 2.3
  chat:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")
  chat:SetScript("OnEvent", function()
    if not this:IsVisible() then return end
    local info = _G.ChatTypeInfo[string.gsub(event,"CHAT_MSG_","")]
    if not info then return end
    local class = GetUnitData(arg2 or "")
    local author, msg
    if class and class ~= UNKNOWN then
      local class_color = string.format("%02x%02x%02x", RAID_CLASS_COLORS[class].r * 255, RAID_CLASS_COLORS[class].g * 255, RAID_CLASS_COLORS[class].b * 255)
      author = string.format("|cff%s%s|r",class_color,arg2)
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
  
  function afkcam:start()
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
    SetCVar("cameraYawMoveSpeed","15")
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
    if not UIParent:IsVisible() and afkcam._ui_visible then
      UIParent:Show()
    end
    if pfUI.uf.player then pfUI.uf:RefreshUnit(pfUI.uf.player, "all") end
    afkcam.overlay:Hide()
    afkcam._spinning = false
  end
  
  afkcam:SetScript("OnEvent", function()
    if event == "CHAT_MSG_SYSTEM" then
      if (arg1 == _G.MARKED_AFK) or strfind(arg1, MARKED_AFK_CAPTURE) then
        this:start()
      elseif (arg1 == _G.CLEARED_AFK) then
        this:stop()
      end
    else
      if this._spinning then
        this:stop()
      end
    end
  end)
  afkcam:RegisterEvent("CHAT_MSG_SYSTEM")
  afkcam:RegisterEvent("PLAYER_REGEN_DISABLED")
  afkcam:RegisterEvent("PLAYER_LEAVING_WORLD") -- reseting cvars on PLAYER_LOGOUT crashes the client ¯\_(ツ)_/¯
end)
