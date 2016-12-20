pfUI:RegisterModule("panel", function ()
  local default_border = pfUI_config.appearance.border.default
  if pfUI_config.appearance.border.panels ~= "-1" then
    default_border = pfUI_config.appearance.border.panels
  end

  pfUI.panel = CreateFrame("Frame",nil,UIParent)
  pfUI.panel:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.panel:RegisterEvent("PLAYER_MONEY")
  pfUI.panel:RegisterEvent("PLAYER_XP_UPDATE")
  pfUI.panel:RegisterEvent("FRIENDLIST_UPDATE")
  pfUI.panel:RegisterEvent("GUILD_ROSTER_UPDATE")
  pfUI.panel:RegisterEvent("PLAYER_GUILD_UPDATE")
  pfUI.panel:RegisterEvent("PLAYER_REGEN_ENABLED")
  pfUI.panel:RegisterEvent("PLAYER_DEAD")
  pfUI.panel:RegisterEvent("MINIMAP_ZONE_CHANGED")

  -- list of available panel fields
  pfUI.panel.options = { "time", "fps", "exp", "gold", "friends",
                         "guild", "durability", "zone" }

  pfUI.panel:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
      pfUI.panel:UpdateGold()
      pfUI.panel:UpdateRepair()
      pfUI.panel:UpdateExp()
      pfUI.panel:UpdateFriend()
      pfUI.panel:UpdateGuild()
      pfUI.panel:UpdateRepair()
      pfUI.panel:UpdateZone()
    elseif event == "PLAYER_MONEY" then
      pfUI.panel:UpdateGold()
      pfUI.panel:UpdateRepair()
    elseif event == "PLAYER_XP_UPDATE" then
      pfUI.panel:UpdateExp()
    elseif event == "FRIENDLIST_UPDATE" then
      pfUI.panel:UpdateFriend()
    elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" then
      pfUI.panel:UpdateGuild()
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_DEAD" then
      pfUI.panel:UpdateRepair()
    elseif event == "MINIMAP_ZONE_CHANGED" then
      pfUI.panel:UpdateZone()
    end
  end)

  pfUI.panel.clock = CreateFrame("Frame",nil,UIParent)

  pfUI.panel.clock.timerFrame = CreateFrame("Frame", "pfUITimer", UIParent)
  pfUI.panel.clock.timerFrame:Hide()
  pfUI.panel.clock.timerFrame:SetWidth(120)
  pfUI.panel.clock.timerFrame:SetHeight(35)
  pfUI.panel.clock.timerFrame:SetPoint("TOP", 0, -100)
  pfUI.utils:UpdateMovable(pfUI.panel.clock.timerFrame)

  pfUI.panel.clock.timerFrame.text = pfUI.panel.clock.timerFrame:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.clock.timerFrame.text:SetFontObject(GameFontWhite)
  pfUI.panel.clock.timerFrame.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.clock.timerFrame.text:SetAllPoints(pfUI.panel.clock.timerFrame)

  pfUI.panel.clock.timerFrame:SetScript("OnUpdate", function()
      if not pfUI.panel.clock.timerFrame.Snapshot then pfUI.panel.clock.timerFrame.Snapshot = GetTime() end
      pfUI.panel.clock.timerFrame.curTime = SecondsToTime(floor(GetTime() - pfUI.panel.clock.timerFrame.Snapshot))
      if pfUI.panel.clock.timerFrame.curTime ~= "" then
        pfUI.panel.clock.timerFrame.text:SetText("|c33cccccc" .. pfUI.panel.clock.timerFrame.curTime)
      else
        pfUI.panel.clock.timerFrame.text:SetText("|cffff3333 --- NEW TIMER ---")
      end
    end)

  pfUI.panel.clock:SetScript("OnUpdate",function(s,e)
    if not pfUI.panel.clock.tick then pfUI.panel.clock.tick = GetTime() - 1 end
    if GetTime() >= pfUI.panel.clock.tick + 1 then
      -- time date
      local tooltip = function ()
        local posX, posY = GetPlayerMapPosition("player")
        local real = GetRealZoneText()
        local sub = GetSubZoneText()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:AddLine("|cff555555Timer")
        GameTooltip:AddDoubleLine("Left Click", "|cffffffffShow/Hide Timer")
        GameTooltip:AddDoubleLine("Right Click", "|cffffffffReset Timer")
        GameTooltip:Show()
      end

      local click = function ()
        this:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        if arg1 == "LeftButton" then
          if pfUI.panel.clock.timerFrame:IsShown() then
            pfUI.panel.clock.timerFrame:Hide()
          else
            pfUI.panel.clock.timerFrame:Show()
          end
        elseif arg1 == "RightButton" then
          pfUI.panel.clock.timerFrame.Snapshot = GetTime()
        end

      end

      pfUI.panel.clock.tick = GetTime()
      pfUI.panel:OutputPanel("time", date("%H:%M:%S"), tooltip, click)

      -- lag fps
      local tooltip = function ()
        local active = 0
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:AddLine("|cff555555Systeminfo")
        for i=1, GetNumAddOns() do
          if IsAddOnLoaded(i) then
            active = active + 1
          end
        end
        GameTooltip:AddDoubleLine("Active Addons", "|cffffffff" .. active .. "|cff555555 / |cffffffff" .. GetNumAddOns())
        GameTooltip:AddLine(" ")
        local nin, nout, nping = GetNetStats()
        GameTooltip:AddDoubleLine("Network Down", "|cffffffff" .. round(nin,1) .. "KB/s")
        GameTooltip:AddDoubleLine("Network Up", "|cffffffff" .. round(nout,1) .. "KB/s")
        GameTooltip:AddDoubleLine("Network Latency", "|cffffffff" .. nping .. "ms")
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Graphic Renderer", "|cffffffff" .. GetCVar("gxApi"))
        GameTooltip:AddDoubleLine("Screen Resolution", "|cffffffff" .. GetCVar("gxResolution"))
        GameTooltip:AddDoubleLine("UI-Scale", "|cffffffff" .. round(UIParent:GetEffectiveScale(),2))
        GameTooltip:Show()
      end

      local click = function ()
        if pfUI.addons:IsShown() then
          pfUI.addons:Hide()
        else
          pfUI.addons:Show()
        end
      end

      local _, _, lag = GetNetStats()
      local fps = floor(GetFramerate())
      pfUI.panel:OutputPanel("fps", floor(GetFramerate()) .. " fps & " .. lag .. " ms", tooltip, click)
    end
  end)

  -- Update "exp"
  function pfUI.panel:UpdateExp ()
    if UnitLevel("player") ~= 60 then
      curexp = UnitXP("player")
      if oldexp ~= nil then
        difexp = curexp - oldexp
        maxexp = UnitXPMax("player")
        remexp = floor((maxexp - curexp)/difexp)
        remstring = "|cff555555 [" .. remexp .. "]|r"
      end
      oldexp = curexp

      local a=UnitXP("player")
      local b=UnitXPMax("player")
      local xprested = tonumber(GetXPExhaustion())
      if remstring == nil then remstring = "" end
      if xprested ~= nil then
        pfUI.panel:OutputPanel("exp", "Exp:|cffaaaaff "..floor((a/b)*100).."%"..remstring)
      else
        pfUI.panel:OutputPanel("exp", "Exp: " .. floor((a/b)*100) .. "%" .. remstring)
      end
    else
      pfUI.panel:OutputPanel("exp", "Exp: N/A")
    end
  end

  -- Update "gold"
  function pfUI.panel:UpdateGold ()
    local gold = floor(GetMoney()/ 100 / 100)
    local silver = floor(mod((GetMoney()/100),100))
    local copper = floor(mod(GetMoney(),100))

    local tooltip = function ()
      if not pfUI.panel.initMoney then pfUI.panel.initMoney = GetMoney() end
      local dmoney = GetMoney() - pfUI.panel.initMoney

      -- initial gold
      local igold = floor(pfUI.panel.initMoney/ 100 / 100)
      local isilver = floor(mod((pfUI.panel.initMoney/100),100))
      local icopper = floor(mod(pfUI.panel.initMoney,100))

      -- current gold
      local gold = floor(GetMoney()/ 100 / 100)
      local silver = floor(mod((GetMoney()/100),100))
      local copper = floor(mod(GetMoney(),100))

      -- diff gold
      local dgold = floor(abs(dmoney/100/100))
      local dsilver = floor(abs(mod((dmoney/100),100)))
      local dcopper = floor(abs(mod(dmoney,100)))

      local dmod, dchar = "", ""
      if dmoney < 0 then
        dmod = "|cffffaaaa"
        dchar = "|cffff8888-"
      elseif dmoney > 0 then
        dmod = "|cffaaffaa"
        dchar = "|cff88ff88+"
      end

      GameTooltip_SetDefaultAnchor(GameTooltip, this)
      GameTooltip:ClearLines()

      GameTooltip:AddLine("|cff555555Money")

      GameTooltip:AddDoubleLine("Login:",
        "|cffffffff " .. igold .. "|cffffd700g" ..
        "|cffffffff " .. isilver .. "|cffc7c7cfs" ..
        "|cffffffff " .. icopper .. "|cffeda55fc")

      GameTooltip:AddDoubleLine("Now:",
        "|cffffffff " .. gold .. "|cffffd700g" ..
        "|cffffffff " .. silver .. "|cffc7c7cfs" ..
        "|cffffffff " .. copper .. "|cffeda55fc")

      GameTooltip:AddDoubleLine("|cffffffff","")

      GameTooltip:AddDoubleLine("This Session:",
        dchar ..
        "|cffffffff " .. dmod .. dgold .. "|cffffd700g" ..
        "|cffffffff " .. dmod .. dsilver .. "|cffc7c7cfs" ..
        "|cffffffff " .. dmod .. dcopper .. "|cffeda55fc")

      GameTooltip:Show()
    end

    local click = function ()
      OpenAllBags()
    end

    pfUI.panel:OutputPanel("gold", gold .. "|cffffd700g|r " .. silver .. "|cffc7c7cfs|r " .. copper .. "|cffeda55fc|r", tooltip, click)
  end

  -- Update "friends"
  function pfUI.panel:UpdateFriend ()
    local online = 0
    local all = GetNumFriends()
    for friendIndex=1, all do
      friend_name, friend_level, friend_class, friend_area, friend_connected = GetFriendInfo(friendIndex)
      if ( friend_connected ) then
        online = online + 1
      end
    end
    pfUI.panel:OutputPanel("friends", "Friends: " .. online)
  end

  -- Update "guild"
  function pfUI.panel:UpdateGuild ()
    GuildRoster()
    local online = GetNumGuildMembers()
    local all = GetNumGuildMembers(true)
    pfUI.panel:OutputPanel("guild", "Guild: "..online)
  end

  -- Update "durability"
  local repairToolTip = CreateFrame('GameTooltip', "repairToolTip", this, "GameTooltipTemplate")
  function pfUI.panel:UpdateRepair ()
    local slotnames = { "Head", "Shoulder", "Chest", "Wrist",
      "Hands", "Waist", "Legs", "Feet", "MainHand", "SecondaryHand", "Ranged", }
    local id, hasItem, repairCost
    local itemName, durability, tmpText, midpt, lval, rval

    duraLowestslotName = nil
    repPercent = 100
    lowestPercent = 100

    for i,slotName in pairs(slotnames) do
      id, _ = GetInventorySlotInfo(slotName.. "Slot")
      repairToolTip:Hide()
      repairToolTip:SetOwner(this, "ANCHOR_LEFT")
      hasItem, _, repCost = repairToolTip:SetInventoryItem("player", id)
      if (not hasItem) then repairToolTip:ClearLines()
      else
        for i=1, 30, 1 do
          tmpText = getglobal("repairToolTipTextLeft"..i)
          if (tmpText ~= nil) and (tmpText:GetText()) then
            local searchstr = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
            _, _, lval, rval = string.find(tmpText:GetText(), searchstr)
            if (lval and rval) then
              repPercent = math.floor(lval / rval * 100)
              break
            end
          end
        end
      end
      if repPercent < lowestPercent then
        lowestPercent = repPercent
      end
    end
    repairToolTip:Hide()
    pfUI.panel:OutputPanel("durability", lowestPercent .. "% Armor")
  end

  function pfUI.panel:UpdateZone ()
    local tooltip = function ()
      local posX, posY = GetPlayerMapPosition("player")
      local real = GetRealZoneText()
      local sub = GetSubZoneText()
      GameTooltip:ClearLines()
      GameTooltip_SetDefaultAnchor(GameTooltip, this)
      GameTooltip:AddLine("|cffffffff" .. real)
      GameTooltip:AddLine(sub)
      GameTooltip:AddLine("|cffaaaaaa" .. round(posX*100,1) .. " / " .. round(posY*100,1))
      GameTooltip:Show()
    end

    local click = function ()
      if WorldMapFrame:IsShown() then
        WorldMapFrame:Hide()
      else
        WorldMapFrame:Show()
      end
    end

    pfUI.panel:OutputPanel("zone", GetMinimapZoneText(), tooltip, click)
  end

  function pfUI.panel:OutputPanel(entry, value, tooltip, func)
    -- return if not yet fully initialized
    if not pfUI.panel.minimap then return end

    local panels = {
      { pfUI.panel.left.left,    pfUI_config.panel.left.left },
      { pfUI.panel.left.center,  pfUI_config.panel.left.center },
      { pfUI.panel.left.right,   pfUI_config.panel.left.right },
      { pfUI.panel.right.left,   pfUI_config.panel.right.left },
      { pfUI.panel.right.center, pfUI_config.panel.right.center },
      { pfUI.panel.right.right,  pfUI_config.panel.right.right },
      { pfUI.panel.minimap,      pfUI_config.panel.other.minimap },
    }

    for i,p in pairs(panels) do
      local frame, config = p[1], p[2]
      if config == entry then
        frame.text:SetText(value)
        if not frame.initialized or frame.initialized ~= entry then
          if tooltip then
            frame:SetScript("OnEnter", tooltip)
            frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
          end

          if func then
            frame:SetScript("OnClick", func)
          end
          frame.initialized = entry
        end
      end
    end
  end


  pfUI.panel.left = CreateFrame("Frame", "pfPanelLeft", pfUI.panel)


  pfUI.panel.left:SetFrameStrata("HIGH")
  pfUI.panel.left:ClearAllPoints()

  if pfUI.chat then
    pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
    pfUI.panel.left:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMLEFT", 2, 2)
    pfUI.panel.left:SetPoint("BOTTOMRIGHT", pfUI.chat.left, "BOTTOMRIGHT", -2, 2)
  else
    pfUI.panel.left:SetWidth(pfUI_config.chat.left.width)
    pfUI.panel.left:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
  end

  pfUI.panel.left:SetHeight(pfUI_config.global.font_size+default_border*2)
  pfUI.utils:CreateBackdrop(pfUI.panel.left, default_border, nil, true)

  pfUI.panel.left.hide = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.hide:ClearAllPoints()
  pfUI.panel.left.hide:SetWidth(12)
  pfUI.panel.left.hide:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.hide:SetPoint("LEFT", 0, 0)
  pfUI.utils:CreateBackdrop(pfUI.panel.left.hide, default_border)
  pfUI.panel.left.hide.texture = pfUI.panel.left.hide:CreateTexture("pfPanelLeftHide")
  pfUI.panel.left.hide.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\left")
  pfUI.panel.left.hide.texture:ClearAllPoints()
  pfUI.panel.left.hide.texture:SetPoint("TOPLEFT", pfUI.panel.left.hide, "TOPLEFT", 2, -4)
  pfUI.panel.left.hide.texture:SetPoint("BOTTOMRIGHT", pfUI.panel.left.hide, "BOTTOMRIGHT", -2, 4)
  pfUI.panel.left.hide.texture:SetVertexColor(.25,.25,.25,1)
  pfUI.panel.left.hide:SetScript("OnClick", function()
      if pfUI.chat.left:IsShown() then pfUI.chat.left:Hide() else pfUI.chat.left:Show() end
    end)

  pfUI.panel.left.left = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.left:ClearAllPoints()
  pfUI.panel.left.left:SetWidth(115)
  pfUI.panel.left.left:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.left:SetPoint("LEFT", 0, 0)
  pfUI.panel.left.left.text = pfUI.panel.left.left:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.left.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.left.left.text:ClearAllPoints()
  pfUI.panel.left.left.text:SetAllPoints(pfUI.panel.left.left)
  pfUI.panel.left.left.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.left.text:SetFontObject(GameFontWhite)

  pfUI.panel.left.center = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.center:ClearAllPoints()
  pfUI.panel.left.center:SetWidth(115)
  pfUI.panel.left.center:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.center:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.center.text = pfUI.panel.left.center:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.center.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.left.center.text:ClearAllPoints()
  pfUI.panel.left.center.text:SetAllPoints(pfUI.panel.left.center)
  pfUI.panel.left.center.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.center.text:SetFontObject(GameFontWhite)

  pfUI.panel.left.right = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.right:ClearAllPoints()
  pfUI.panel.left.right:SetWidth(115)
  pfUI.panel.left.right:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.right:SetPoint("RIGHT", 0, 0)
  pfUI.panel.left.right.text = pfUI.panel.left.right:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.right.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.left.right.text:ClearAllPoints()
  pfUI.panel.left.right.text:SetAllPoints(pfUI.panel.left.right)
  pfUI.panel.left.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.right.text:SetFontObject(GameFontWhite)

  pfUI.panel.right = CreateFrame("Frame", "pfPanelRight", pfUI.panel)
  pfUI.panel.right:SetFrameStrata("HIGH")
  pfUI.panel.right:ClearAllPoints()
  if pfUI.chat then
    pfUI.panel.right:SetScale(pfUI.chat.left:GetScale())
    pfUI.panel.right:SetPoint("BOTTOMLEFT", pfUI.chat.right, "BOTTOMLEFT", 2, 2)
    pfUI.panel.right:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -2, 2)
  else
    pfUI.panel.right:SetWidth(pfUI_config.chat.right.width)
    pfUI.panel.right:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
  end
  pfUI.panel.right:SetHeight(pfUI_config.global.font_size+default_border*2)
  pfUI.utils:CreateBackdrop(pfUI.panel.right, default_border, nil, true)

  pfUI.panel.right.hide = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.hide:ClearAllPoints()
  pfUI.panel.right.hide:SetWidth(12)
  pfUI.panel.right.hide:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.hide:SetPoint("RIGHT", 0, 0)
  pfUI.utils:CreateBackdrop(pfUI.panel.right.hide, default_border)
  pfUI.panel.right.hide.texture = pfUI.panel.right.hide:CreateTexture("pfPanelRightHide")
  pfUI.panel.right.hide.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\right")
  pfUI.panel.right.hide.texture:ClearAllPoints()
  pfUI.panel.right.hide.texture:SetPoint("TOPLEFT", pfUI.panel.right.hide, "TOPLEFT", 2, -4)
  pfUI.panel.right.hide.texture:SetPoint("BOTTOMRIGHT", pfUI.panel.right.hide, "BOTTOMRIGHT", -2, 4)
  pfUI.panel.right.hide.texture:SetVertexColor(.25,.25,.25,1)
  pfUI.panel.right.hide:SetScript("OnClick", function()
      if pfUI.chat.right:IsShown() then pfUI.chat.right:Hide() else pfUI.chat.right:Show() end
    end)

  pfUI.panel.right.left = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.left:ClearAllPoints()
  pfUI.panel.right.left:SetWidth(115)
  pfUI.panel.right.left:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.left:SetPoint("LEFT", 0, 0)
  pfUI.panel.right.left.text = pfUI.panel.right.left:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.left.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.right.left.text:ClearAllPoints()
  pfUI.panel.right.left.text:SetAllPoints(pfUI.panel.right.left)
  pfUI.panel.right.left.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.left.text:SetFontObject(GameFontWhite)

  pfUI.panel.right.center = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.center:ClearAllPoints()
  pfUI.panel.right.center:SetWidth(115)
  pfUI.panel.right.center:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.center:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.center.text = pfUI.panel.right.center:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.center.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.right.center.text:ClearAllPoints()
  pfUI.panel.right.center.text:SetAllPoints(pfUI.panel.right.center)
  pfUI.panel.right.center.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.center.text:SetFontObject(GameFontWhite)

  pfUI.panel.right.right = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.right:ClearAllPoints()
  pfUI.panel.right.right:SetWidth(115)
  pfUI.panel.right.right:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.right:SetPoint("RIGHT", 0, 0)
  pfUI.panel.right.right.text = pfUI.panel.right.right:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.right.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.right.right.text:ClearAllPoints()
  pfUI.panel.right.right.text:SetAllPoints(pfUI.panel.right.right)
  pfUI.panel.right.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.right.text:SetFontObject(GameFontWhite)

  pfUI.panel.minimap = CreateFrame("Button", "pfPanelMinimap", UIParent)
  pfUI.utils:CreateBackdrop(pfUI.panel.minimap, default_border)
  pfUI.utils:UpdateMovable(pfUI.panel.minimap)
  pfUI.panel.minimap:SetHeight(pfUI_config.global.font_size+default_border*2)
  if pfUI.minimap then
    pfUI.panel.minimap:SetPoint("TOP", pfUI.minimap, "BOTTOM", 0 , -default_border*3)
    pfUI.panel.minimap:SetWidth(pfUI.minimap:GetWidth())
  else
    pfUI.panel.minimap:SetWidth(200)
    pfUI.panel.minimap:SetPoint("TOP", UIParent, "TOP", 0, -5)
  end
  pfUI.panel.minimap:SetFrameStrata("BACKGROUND")
  pfUI.panel.minimap.text = pfUI.panel.minimap:CreateFontString("MinimapZoneText", "LOW", "GameFontNormal")
  pfUI.panel.minimap.text:SetFont(pfUI.font_default, pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.minimap.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.minimap.text:SetFontObject(GameFontWhite)

  -- MicroButtons
  if pfUI_config.panel.micro.enable == "1" then
    pfUI.panel.microbutton = CreateFrame("Frame", "pfPanelMicroButton", UIParent)
    pfUI.panel.microbutton:SetPoint("TOP", 0, 0)
    pfUI.utils:UpdateMovable(pfUI.panel.microbutton)
    pfUI.panel.microbutton:SetHeight(23)
    pfUI.panel.microbutton:SetWidth(145)
    pfUI.panel.microbutton:SetFrameStrata("BACKGROUND")

    local MICRO_BUTTONS = {
      'CharacterMicroButton', 'SpellbookMicroButton', 'TalentMicroButton',
      'QuestLogMicroButton', 'SocialsMicroButton', 'WorldMapMicroButton',
      'MainMenuMicroButton', 'HelpMicroButton',
    }

    for i=1,table.getn(MICRO_BUTTONS) do
      local anchor = getglobal(MICRO_BUTTONS[i-1]) or pfUI.panel.microbutton
      local button = getglobal(MICRO_BUTTONS[i])
      button:ClearAllPoints()
      button:SetParent(pfUI.panel.microbutton)
      if i == 1 then
        button:SetPoint("LEFT", pfUI.panel.microbutton, "LEFT", 1, 10)
      else
        button:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 1, 0)
      end

      button:SetScale(.6)
      button.frame = CreateFrame("Frame", "backdrop", button)
      button.frame:SetScale(1.4)
      button.frame:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -16)
      button.frame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
      pfUI.utils:CreateBackdrop(button.frame, default_border)
      button:Show()
    end
  end
end)
