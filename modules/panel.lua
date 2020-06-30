pfUI:RegisterModule("panel", "vanilla:tbc", function()
  -- initialize gold cache if not yet happened
  pfUI_cache["gold"] = pfUI_cache["gold"] or {}

  local font = C.panel.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.panel.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
  local rawborder, default_border = GetBorderSize("panels")

  do -- Widgets
    do -- Clock & Timer
      local widget = CreateFrame("Frame", "pfPanelWidgetClock",UIParent)
      widget.Tooltip = function()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        local h, m = GetGameTime()
        local noon = " AM"
        local servertime
        local time
        if C.global.twentyfour == "0" then
          if h > 12 then
            h = h - 12
            noon = " PM"
          end
          time = date("%I:%M %p")
          servertime = string.format("%.2d:%.2d %s", h, m, noon)
        else
          time = date("%H:%M")
          servertime = string.format("%.2d:%.2d", h, m)
        end
        GameTooltip:AddLine("|cff555555" .. T["Time"])
        GameTooltip:AddDoubleLine(T["Localtime"],  "|cffffffff" .. time)
        GameTooltip:AddDoubleLine(T["Servertime"], "|cffffffff".. servertime)
        GameTooltip:AddLine(" ")
        if TimeManagerFrame then
          GameTooltip:AddDoubleLine(T["Left Click"], "|cffffffff" .. T["Show/Hide TimeManager"])
        else
          GameTooltip:AddDoubleLine(T["Left Click"], "|cffffffff" .. T["Show/Hide Timer"])
          GameTooltip:AddDoubleLine(T["Right Click"], "|cffffffff" .. T["Reset Timer"])
        end
        GameTooltip:Show()
      end
      widget.Click = function()
        this:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        if TimeManagerFrame then
          if TimeManagerClockButton.alarmFiring then
            TimeManager_TurnOffAlarm()
          end
          ToggleTimeManager()
          return
        end
        if arg1 == "LeftButton" then
          if widget.timerFrame:IsShown() then
            widget.timerFrame:Hide()
          else
            widget.timerFrame:Show()
          end
        elseif arg1 == "RightButton" then
          widget.timerFrame.Snapshot = GetTime()
        end
      end
      widget:SetScript("OnUpdate",function()
        if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

        local h, m = GetGameTime()
        local noon = "AM"
        local time = ""
        if C.global.twentyfour == "0" then
          if C.global.servertime == "1" then
            if h > 12 then
              h = h - 12
              noon = "PM"
            end
            time = string.format("%.2d:%.2d %s", h, m, noon)
          else
            time = date("%I:%M:%S %p")
          end
        else
          if C.global.servertime == "1" then
            time = string.format("%.2d:%.2d", h, m)
          else
            time = date("%H:%M:%S")
          end
        end
        pfUI.panel:OutputPanel("time", time, widget.Tooltip, widget.Click)
      end)

      widget.timerFrame = CreateFrame("Frame", "pfUITimer", UIParent)
      widget.timerFrame:Hide()
      widget.timerFrame:SetWidth(120)
      widget.timerFrame:SetHeight(35)
      widget.timerFrame:SetPoint("TOP", 0, -100)
      UpdateMovable(widget.timerFrame)

      widget.timerFrame.text = widget.timerFrame:CreateFontString("Status", "LOW", "GameFontNormal")
      widget.timerFrame.text:SetFontObject(GameFontWhite)
      widget.timerFrame.text:SetFont(font, font_size, "OUTLINE")
      widget.timerFrame.text:SetAllPoints(widget.timerFrame)
      widget.timerFrame:SetScript("OnUpdate", function()
          if not widget.timerFrame.Snapshot then widget.timerFrame.Snapshot = GetTime() end
          widget.timerFrame.curTime = SecondsToTime(floor(GetTime() - widget.timerFrame.Snapshot))
          if widget.timerFrame.curTime ~= "" then
            widget.timerFrame.text:SetText("|c33cccccc" .. widget.timerFrame.curTime)
          else
            widget.timerFrame.text:SetText("|cffff3333 --- " .. T["NEW TIMER"] .. " ---")
          end
        end)

      -- Combat Timer
      widget.combat = CreateFrame("Frame", "pfUICombatTimer", UIParent)
      widget.combat:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget.combat:RegisterEvent("PLAYER_REGEN_ENABLED")
      widget.combat:RegisterEvent("PLAYER_REGEN_DISABLED")
      widget.combat:SetScript("OnEvent", function()
        if event == "PLAYER_REGEN_DISABLED" then
          if UnitAffectingCombat("player") and not this.combat then
            this.combat = GetTime()
          end

        elseif event == "PLAYER_REGEN_ENABLED" then
          if this.combat then
            this.lastcombat = GetTime() - this.combat
            this.combat = nil
            pfUI.panel:OutputPanel("combat", "|cffffffff" .. SecondsToTime(ceil(this.lastcombat)))
          end

        elseif event == "PLAYER_ENTERING_WORLD" then
          pfUI.panel:OutputPanel("combat", T["Combat"] .. ": " .. NOT_APPLICABLE)
        end
      end)
      widget.combat:SetScript("OnUpdate", function()
        if not this.tick then this.tick = GetTime() end
        if GetTime() <= this.tick + 1 then return else this.tick = GetTime() end
        if this.combat then
          pfUI.panel:OutputPanel("combat", "|cffffaaaa" .. SecondsToTime(ceil(GetTime() - this.combat)))
        end
      end)
    end

    do -- FPS & Lag
      local widget = CreateFrame("Frame", "pfPanelWidgetLag", UIParent)
      local lag, fps, laghex, fpshex, _
      widget.Tooltip = function()
        local active = 0
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:AddLine("|cff555555" .. T["Systeminfo"])
        for i=1, GetNumAddOns() do
          if IsAddOnLoaded(i) then
            active = active + 1
          end
        end

        local memkb, gckb = gcinfo()
        local memmb = memkb and memkb > 0 and round((memkb or 0)/1000, 2) .. " MB" or UNAVAILABLE
        local gcmb = gckb and gckb > 0 and round((gckb or 0)/1000, 2) .. " MB" or UNAVAILABLE

        local nin, nout, nping = GetNetStats()

        GameTooltip:AddDoubleLine(T["Active Addons"], "|cffffffff" .. active .. "|cff555555 / |cffffffff" .. GetNumAddOns())
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(T["Memory Usage"], "|cffffffff" .. memmb)
        GameTooltip:AddDoubleLine(T["Next Memory Cleanup"], "|cffffffff" .. gcmb)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(T["Network Down"], "|cffffffff" .. round(nin,1) .. "KB/s")
        GameTooltip:AddDoubleLine(T["Network Up"], "|cffffffff" .. round(nout,1) .. "KB/s")
        GameTooltip:AddDoubleLine(T["Network Latency"], "|cffffffff" .. nping .. "ms")
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(T["Graphic Renderer"], "|cffffffff" .. GetCVar("gxApi"))
        GameTooltip:AddDoubleLine(T["Screen Resolution"], "|cffffffff" .. GetCVar("gxResolution"))
        GameTooltip:AddDoubleLine(T["UI-Scale"], "|cffffffff" .. round(UIParent:GetEffectiveScale(),2))
        GameTooltip:Show()
      end
      widget.Click = function()
        if pfUI.addons and pfUI.addons:IsShown() then
          pfUI.addons:Hide()
        elseif pfUI.addons then
          pfUI.addons:Show()
        end
      end
      widget:SetScript("OnUpdate",function()
        if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + 1 end

        fps = floor(GetFramerate())
        _, _, lag = GetNetStats()

        if C.panel.fpscolors == "1" then
          _, _, _, fpshex = GetColorGradient(fps/60)
          _, _, _, laghex = GetColorGradient(60/lag)
          fps = fpshex .. fps .. "|r"
          lag = laghex .. lag .. "|r"
        end

        pfUI.panel:OutputPanel("fps", fps .. " " .. T["fps"] .. " & " .. lag .. " " .. T["ms"], widget.Tooltip, widget.Click)
      end)
    end

    do -- XP & Kills To Level
      local widget = CreateFrame("Frame", "pfPanelWidgetXP", UIParent)
      local curexp, difexp, maxexp, remexp, oldexp, remstring
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("PLAYER_XP_UPDATE")
      widget:SetScript("OnEvent", function()
        if UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
          curexp = UnitXP("player")
          if oldexp ~= nil then
            difexp = curexp - oldexp
            maxexp = UnitXPMax("player")
            if difexp > 0 then
              remexp = floor((maxexp - curexp)/difexp)
              remstring = "|cff555555 [" .. remexp .. "]|r"
            else
              remstring = nil
            end
          end
          oldexp = curexp

          local a=UnitXP("player")
          local b=UnitXPMax("player")
          local xprested = tonumber(GetXPExhaustion())
          if remstring == nil then remstring = "" end
          if xprested ~= nil then
            pfUI.panel:OutputPanel("exp", T["Exp"] .. ": |cffaaaaff"..floor((a/b)*100).."%"..remstring)
          else
            pfUI.panel:OutputPanel("exp", T["Exp"] .. ": " .. floor((a/b)*100) .. "%" .. remstring)
          end
        else
          pfUI.panel:OutputPanel("exp", T["Exp"] .. ": " .. NOT_APPLICABLE)
        end
      end)
    end

    do -- Bagspace
      local widget = CreateFrame("Frame", "pfPanelWidgetBag", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("BAG_UPDATE")
      widget:SetScript("OnEvent", function()
        local maxslots = 0
        local usedslots = 0

        for bag = 0,4 do
          if C.panel.bag.ignorespecial ~= "1" or GetBagFamily(bag) == "BAG" then
            local bagsize = GetContainerNumSlots(bag)
            maxslots = maxslots + bagsize
            for j = 1,bagsize do
              local link = GetContainerItemLink(bag,j)
              if link then
                usedslots = usedslots + 1
              end
            end
          end
        end
        local freeslots = maxslots - usedslots
        pfUI.panel:OutputPanel("bagspace", freeslots .. " (" .. usedslots .. "/" .. maxslots .. ")", nil, OpenAllBags)
      end)
    end

    do -- Gold
      local widget = CreateFrame("Frame", "pfPanelWidgetGold", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("PLAYER_MONEY")
      widget.Tooltip = function()
        local gold = floor(GetMoney()/ 10000)
        local silver = floor(mod((GetMoney()/100),100))
        local copper = floor(mod(GetMoney(),100))

        local dmod = ""
        if pfUI.panel.diffMoney < 0 then
          dmod = "|cffff8888-"
        elseif pfUI.panel.diffMoney > 0 then
          dmod = "|cff88ff88+"
        end

        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:ClearLines()

        GameTooltip:AddLine("|cff555555" .. T["Money"])
        GameTooltip:AddDoubleLine(T["Login"] .. ":", CreateGoldString(pfUI.panel.initMoney))
        GameTooltip:AddDoubleLine(T["Now"] .. ":", CreateGoldString(GetMoney()))
        GameTooltip:AddDoubleLine("|cffffffff","")
        for name, gold in pairs(pfUI_cache["gold"][GetRealmName()]) do
          if name ~= UnitName("player") then
            GameTooltip:AddDoubleLine(name .. ":", CreateGoldString(gold))
          end
        end
        GameTooltip:AddDoubleLine("|cffffffff","")
        GameTooltip:AddDoubleLine(T["This Session"] .. ":", dmod .. CreateGoldString(math.abs(pfUI.panel.diffMoney)))
        GameTooltip:Show()
      end
      widget:SetScript("OnEvent", function()
        local realm = GetRealmName()
        local unit  = UnitName("player")
        local money = GetMoney()
        local goldstr = CreateGoldString(GetMoney())

        pfUI.panel.initMoney = pfUI.panel.initMoney or money
        pfUI.panel.diffMoney = money - pfUI.panel.initMoney

        pfUI_cache["gold"][realm] = pfUI_cache["gold"][realm] or {}
        pfUI_cache["gold"][realm][unit] = money

        pfUI.panel:OutputPanel("gold", goldstr, widget.Tooltip, OpenAllBags)
      end)
    end

    do -- Friends
      local widget = CreateFrame("Frame", "pfPanelWidgetFriends", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("FRIENDLIST_UPDATE")
      widget.Click = function() ToggleFriendsFrame(1) end
      widget:SetScript("OnEvent", function()
        local online = 0
        local all = GetNumFriends()
        for friendIndex=1, all do
          local friend_name, friend_level, friend_class, friend_area, friend_connected = GetFriendInfo(friendIndex)
          if ( friend_connected ) then
            online = online + 1
          end
        end

        pfUI.panel:OutputPanel("friends", FRIENDS .. ": " .. online, nil, widget.Click)
      end)
    end

    do -- Guild
      local widget = CreateFrame("Frame", "pfPanelWidgetGuild", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("GUILD_ROSTER_UPDATE")
      widget:RegisterEvent("PLAYER_GUILD_UPDATE")
      widget.Click = function() ToggleFriendsFrame(3) end
      widget:SetScript("OnEvent", function()
        if GetGuildInfo("player") then
          local count = 0
          for i = 1, GetNumGuildMembers() do
            local _, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
            if online then count = count + 1 end
          end

          pfUI.panel:OutputPanel("guild", GUILD .. ": " .. count, nil, widget.Click)
        else
          pfUI.panel:OutputPanel("guild", GUILD .. ": " .. NOT_APPLICABLE, nil, widget.Click)
        end
      end)

      widget:SetScript("OnUpdate",function()
        if ( this.tick or 10) > GetTime() then return else this.tick = GetTime() + 10 end
        if GetGuildInfo("player") then GuildRoster() end
      end)
    end

    do -- Durability / Repair
      local widget = CreateFrame("Frame", "pfPanelWidgetRepair", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("PLAYER_MONEY")
      widget:RegisterEvent("PLAYER_REGEN_ENABLED")
      widget:RegisterEvent("PLAYER_DEAD")
      widget:RegisterEvent("PLAYER_UNGHOST")
      widget:RegisterEvent("UNIT_INVENTORY_CHANGED")
      widget:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

      widget.itemLines = {}
      widget.durability_slots = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }
      widget.totalRep = 0
      widget.scantip = libtipscan:GetScanner("panel")
      widget.duracapture = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
      widget.Click = function() ToggleCharacter("PaperDollFrame") end
      widget.Tooltip = function()
        if widget.totalRep > 0 then
          GameTooltip:ClearLines()
          GameTooltip_SetDefaultAnchor(GameTooltip, this)
          GameTooltip:SetText("|cff555555"..(string.gsub(REPAIR_COST,":","")).."|r")
          SetTooltipMoney(GameTooltip, widget.totalRep)
          for _,line in ipairs(widget.itemLines) do
            GameTooltip:AddDoubleLine(line[1],line[2])
          end
          GameTooltip:Show()
        end
      end
      widget:SetScript("OnEvent", function()
        if event == "UNIT_INVENTORY_CHANGED" and arg1 ~= "player" then return end

        local repPercent = 100
        local lowestPercent = 100
        widget.totalRep = 0
        wipe(widget.itemLines)
        for _, id in pairs(widget.durability_slots) do
          local hasItem, _, repCost = widget.scantip:SetInventoryItem("player", id)
          if (hasItem) then
            widget.totalRep = widget.totalRep + repCost
            local line, lval, rval = widget.scantip:Find(widget.duracapture)
            if (lval and rval) then
              repPercent = math.floor(lval / rval * 100)
              if repPercent < 100 then
                local link = GetInventoryItemLink("player",id)
                local r,g,b,hex = GetColorGradient(repPercent/100)
                local cPercent = string.format("%s%s%%|r",hex,repPercent)
                widget.itemLines[table.getn(widget.itemLines)+1]={link, cPercent}
              end
            end
          end
          if repPercent < lowestPercent then
            lowestPercent = repPercent
          end
        end

        pfUI.panel:OutputPanel("durability", lowestPercent .. "% " .. ARMOR, widget.Tooltip, widget.Click)
      end)
    end

    do -- Zone
      local widget = CreateFrame("Frame", "pfPanelWidgetZone", UIParent)
      for _,event in pairs(EVENTS_MINIMAP_ZONE_UPDATE) do
        widget:RegisterEvent(event)
      end
      widget.Tooltip = function()
        local real = GetRealZoneText()
        local sub = GetSubZoneText()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:AddLine("|cffffffff" .. real)
        GameTooltip:AddLine(sub)

        local posX, posY = GetPlayerMapPosition("player")
        if posX ~= 0 and posY ~= 0 then
          GameTooltip:AddLine("|cffaaaaaa" .. round(posX * 100, 1) .. ", " .. round(posY * 100, 1))
        end

        GameTooltip:Show()
      end
      widget.Click = function()
        if WorldMapFrame:IsShown() then
          WorldMapFrame:Hide()
        else
          WorldMapFrame:Show()
        end
      end
      widget:SetScript("OnEvent", function()
        pfUI.panel:OutputPanel("zone", GetMinimapZoneText(), widget.Tooltip, widget.Click)
      end)
    end

    do -- Ammo
      local widget = CreateFrame("Frame", "pfPanelWidgetAmmo", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("UNIT_INVENTORY_CHANGED")
      widget.Tooltip = function()
        if GetInventoryItemQuality("player", 0) then
          local ammo = GetInventoryItemCount("player", 0)
          GameTooltip:ClearLines()
          GameTooltip_SetDefaultAnchor(GameTooltip, this)
          GameTooltip:SetInventoryItem("player", 0)
          GameTooltip:AddLine(T["Count"] .. ": " .. ammo, .3,1,.8)
          GameTooltip:Show()
        end
      end
      widget:SetScript("OnEvent", function()
        if not GetInventoryItemQuality("player", 0) then
          pfUI.panel:OutputPanel("ammo", AMMOSLOT .. ": -")
        else
          pfUI.panel:OutputPanel("ammo", AMMOSLOT .. ": " .. GetInventoryItemCount("player", 0), tooltip)
        end
      end)
    end

    do -- Soulshards
      local widget = CreateFrame("Frame", "pfPanelWidgetSoulshard", UIParent)
      widget:RegisterEvent("PLAYER_ENTERING_WORLD")
      widget:RegisterEvent("BAG_UPDATE")
      widget:SetScript("OnEvent", function()
        local count = 0
        local _, class = UnitClass("player")

        if class == "WARLOCK" then
          for bag=0,4 do
            for slot=1,GetContainerNumSlots(bag) do
              local link = GetContainerItemLink(bag,slot)
              if link then
                local _, _, id = string.find(link, "item:(%d+):%d+:%d+:%d+")
                if id == "6265" then
                  count = count + 1
                end
              end
            end
          end
        end

        pfUI.panel:OutputPanel("soulshard", T["Soulshards"] .. ": " .. count)
      end)
    end
  end

  pfUI.panel = {}
  pfUI.panel.modules = {}

  -- list of available panel fields
  pfUI.panel.options = { "time", "fps", "exp", "gold", "friends",
    "guild", "durability", "zone", "ammo", "bagspace" }

  local panels = {}
  function pfUI.panel:OutputPanel(entry, value, tooltip, func)
    -- return if not yet fully initialized
    if not pfUI.panel.minimap then return end

    -- initialize then panels if not yet done
    if not panels[1] then
      panels = {
        { pfUI.panel.left.left,    C.panel.left.left },
        { pfUI.panel.left.center,  C.panel.left.center },
        { pfUI.panel.left.right,   C.panel.left.right },
        { pfUI.panel.right.left,   C.panel.right.left },
        { pfUI.panel.right.center, C.panel.right.center },
        { pfUI.panel.right.right,  C.panel.right.right },
        { pfUI.panel.minimap,      C.panel.other.minimap },
      }
    end

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


  pfUI.panel.left = CreateFrame("Frame", "pfPanelLeft", UIParent)
  pfUI.panel.left:SetFrameStrata("FULLSCREEN")
  pfUI.panel.left:ClearAllPoints()

  if pfUI.chat then
    pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
    pfUI.panel.left:SetWidth(tonumber(C.chat.left.width) - 4)
    pfUI.panel.left:SetPoint("BOTTOM", pfUI.chat.left, "BOTTOM", 0, 2)
  else
    pfUI.panel.left:SetWidth(C.chat.left.width)
    pfUI.panel.left:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
  end

  pfUI.panel.left:SetFrameStrata("DIALOG")
  pfUI.panel.left:SetHeight(C.global.font_size*1.5)

  CreateBackdrop(pfUI.panel.left, default_border, nil)
  CreateBackdropShadow(pfUI.panel.left)
  UpdateMovable(pfUI.panel.left)

  pfUI.panel.left.hide = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.hide:SetFrameLevel(0)
  pfUI.panel.left.hide:ClearAllPoints()
  pfUI.panel.left.hide:SetWidth(12)
  pfUI.panel.left.hide:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.hide:SetPoint("LEFT", 0, 0)
  CreateBackdrop(pfUI.panel.left.hide, default_border)
  pfUI.panel.left.hide.texture = pfUI.panel.left.hide:CreateTexture("pfPanelLeftHide")
  pfUI.panel.left.hide.texture:SetTexture(pfUI.media["img:left"])
  pfUI.panel.left.hide.texture:ClearAllPoints()
  pfUI.panel.left.hide.texture:SetPoint("TOPLEFT", pfUI.panel.left.hide, "TOPLEFT", 2, -4)
  pfUI.panel.left.hide.texture:SetPoint("BOTTOMRIGHT", pfUI.panel.left.hide, "BOTTOMRIGHT", -2, 4)
  pfUI.panel.left.hide.texture:SetVertexColor(.25,.25,.25,1)
  pfUI.panel.left.hide:SetScript("OnClick", function()
      if pfUI.chat.left:IsShown() then pfUI.chat.left:Hide() else pfUI.chat.left:Show() end
    end)

  pfUI.panel.left.left = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.left:SetFrameLevel(0)
  pfUI.panel.left.left:ClearAllPoints()
  pfUI.panel.left.left:SetWidth(115)
  pfUI.panel.left.left:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.left:SetPoint("LEFT", 0, 0)
  pfUI.panel.left.left.text = pfUI.panel.left.left:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.left.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.left.left.text:ClearAllPoints()
  pfUI.panel.left.left.text:SetAllPoints(pfUI.panel.left.left)
  pfUI.panel.left.left.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.left.text:SetFontObject(GameFontWhite)

  pfUI.panel.left.center = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.center:SetFrameLevel(0)
  pfUI.panel.left.center:ClearAllPoints()
  pfUI.panel.left.center:SetWidth(115)
  pfUI.panel.left.center:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.center:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.center.text = pfUI.panel.left.center:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.center.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.left.center.text:ClearAllPoints()
  pfUI.panel.left.center.text:SetAllPoints(pfUI.panel.left.center)
  pfUI.panel.left.center.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.center.text:SetFontObject(GameFontWhite)

  pfUI.panel.left.right = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.right:SetFrameLevel(0)
  pfUI.panel.left.right:ClearAllPoints()
  pfUI.panel.left.right:SetWidth(115)
  pfUI.panel.left.right:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.right:SetPoint("RIGHT", 0, 0)
  pfUI.panel.left.right.text = pfUI.panel.left.right:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.right.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.left.right.text:ClearAllPoints()
  pfUI.panel.left.right.text:SetAllPoints(pfUI.panel.left.right)
  pfUI.panel.left.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.right.text:SetFontObject(GameFontWhite)

  if C.panel.left.left == "none"
  and C.panel.left.center == "none"
  and C.panel.left.right == "none" then
    pfUI.panel.left:Hide()
  end

  pfUI.panel.right = CreateFrame("Frame", "pfPanelRight", UIParent)
  pfUI.panel.right:SetFrameStrata("FULLSCREEN")
  pfUI.panel.right:ClearAllPoints()
  if pfUI.chat then
    pfUI.panel.right:SetScale(pfUI.chat.right:GetScale())
    pfUI.panel.right:SetWidth(tonumber(C.chat.right.width) - 4)
    pfUI.panel.right:SetPoint("BOTTOM", pfUI.chat.right, "BOTTOM", 0, 2)
  else
    pfUI.panel.right:SetWidth(C.chat.right.width)
    pfUI.panel.right:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
  end

  pfUI.panel.right:SetFrameStrata("DIALOG")
  pfUI.panel.right:SetHeight(C.global.font_size*1.5)

  CreateBackdrop(pfUI.panel.right, default_border, nil)
  CreateBackdropShadow(pfUI.panel.right)
  UpdateMovable(pfUI.panel.right)

  pfUI.panel.right.hide = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.hide:SetFrameLevel(0)
  pfUI.panel.right.hide:ClearAllPoints()
  pfUI.panel.right.hide:SetWidth(12)
  pfUI.panel.right.hide:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.hide:SetPoint("RIGHT", 0, 0)
  CreateBackdrop(pfUI.panel.right.hide, default_border)
  pfUI.panel.right.hide.texture = pfUI.panel.right.hide:CreateTexture("pfPanelRightHide")
  pfUI.panel.right.hide.texture:SetTexture(pfUI.media["img:right"])
  pfUI.panel.right.hide.texture:ClearAllPoints()
  pfUI.panel.right.hide.texture:SetPoint("TOPLEFT", pfUI.panel.right.hide, "TOPLEFT", 2, -4)
  pfUI.panel.right.hide.texture:SetPoint("BOTTOMRIGHT", pfUI.panel.right.hide, "BOTTOMRIGHT", -2, 4)
  pfUI.panel.right.hide.texture:SetVertexColor(.25,.25,.25,1)
  pfUI.panel.right.hide:SetScript("OnClick", function()
      if pfUI.chat.right:IsShown() then pfUI.chat.right:Hide() else pfUI.chat.right:Show() end
    end)

  pfUI.panel.right.left = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.left:SetFrameLevel(0)
  pfUI.panel.right.left:ClearAllPoints()
  pfUI.panel.right.left:SetWidth(115)
  pfUI.panel.right.left:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.left:SetPoint("LEFT", 0, 0)
  pfUI.panel.right.left.text = pfUI.panel.right.left:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.left.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.right.left.text:ClearAllPoints()
  pfUI.panel.right.left.text:SetAllPoints(pfUI.panel.right.left)
  pfUI.panel.right.left.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.left.text:SetFontObject(GameFontWhite)

  pfUI.panel.right.center = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.center:SetFrameLevel(0)
  pfUI.panel.right.center:ClearAllPoints()
  pfUI.panel.right.center:SetWidth(115)
  pfUI.panel.right.center:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.center:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.center.text = pfUI.panel.right.center:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.center.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.right.center.text:ClearAllPoints()
  pfUI.panel.right.center.text:SetAllPoints(pfUI.panel.right.center)
  pfUI.panel.right.center.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.center.text:SetFontObject(GameFontWhite)

  pfUI.panel.right.right = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.right:SetFrameLevel(0)
  pfUI.panel.right.right:ClearAllPoints()
  pfUI.panel.right.right:SetWidth(115)
  pfUI.panel.right.right:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.right:SetPoint("RIGHT", 0, 0)
  pfUI.panel.right.right.text = pfUI.panel.right.right:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.right.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.right.right.text:ClearAllPoints()
  pfUI.panel.right.right.text:SetAllPoints(pfUI.panel.right.right)
  pfUI.panel.right.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.right.text:SetFontObject(GameFontWhite)

  if C.panel.right.left == "none"
  and C.panel.right.center == "none"
  and C.panel.right.right == "none" then
    pfUI.panel.right:Hide()
  end

  pfUI.panel.minimap = CreateFrame("Button", "pfPanelMinimap", UIParent)
  if pfUI.minimap then
    pfUI.panel.minimap:SetPoint("TOP", pfUI.minimap, "BOTTOM", 0 , -default_border*3)
    pfUI.panel.minimap:SetWidth(pfUI.minimap:GetWidth())
  else
    pfUI.panel.minimap:SetWidth(200)
    pfUI.panel.minimap:SetPoint("TOP", UIParent, "TOP", 0, -5)
  end

  pfUI.panel.minimap:SetHeight(C.global.font_size*1.5)
  pfUI.panel.minimap:SetFrameStrata("MEDIUM")

  CreateBackdrop(pfUI.panel.minimap, default_border)
  CreateBackdropShadow(pfUI.panel.minimap)
  UpdateMovable(pfUI.panel.minimap)

  pfUI.panel.minimap.text = pfUI.panel.minimap:CreateFontString("MinimapZoneText", "LOW", "GameFontNormal")
  pfUI.panel.minimap.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.minimap.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.minimap.text:SetFontObject(GameFontWhite)

  if C.panel.other.minimap == "none" then pfUI.panel.minimap:Hide() end

  -- MicroButtons
  if C.panel.micro.enable == "1" then
    pfUI.panel.microbutton = CreateFrame("Frame", "pfPanelMicroButton", UIParent)
    pfUI.panel.microbutton:SetPoint("TOP", pfUI.panel.minimap, "BOTTOM", 0,  -2*default_border)
    UpdateMovable(pfUI.panel.microbutton)
    pfUI.panel.microbutton:SetHeight(23)
    pfUI.panel.microbutton:SetWidth(145)
    pfUI.panel.microbutton:SetFrameStrata("MEDIUM")

    for i=1,table.getn(MICRO_BUTTONS) do
      local anchor = _G[MICRO_BUTTONS[i-1]] or pfUI.panel.microbutton
      local button = _G[MICRO_BUTTONS[i]]
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
      CreateBackdrop(button.frame, default_border)
      button:Show()
    end
  end


  pfUI.panel.autohide = CreateFrame("Frame", nil, UIParent)
  pfUI.panel.autohide:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.panel.autohide:SetScript("OnEvent", function()
    if C.panel.hide_leftchat == "1" then
      EnableAutohide(pfUI.panel.left, 2)
    end
    if C.panel.hide_rightchat == "1" then
      EnableAutohide(pfUI.panel.right, 2)
    end
    if C.panel.hide_minimap == "1" then
      EnableAutohide(pfUI.panel.minimap, 2)
    end
    if C.panel.hide_microbar == "1" then
      EnableAutohide(pfUI.panel.microbutton, 2)
    end
  end)
end)
