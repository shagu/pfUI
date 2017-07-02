pfUI:RegisterModule("panel", function ()

  local font = C.panel.use_unitfonts == "1" and pfUI.font_unit or pfUI.font_default
  local font_size = C.panel.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size

  local default_border = C.appearance.border.default
  if C.appearance.border.panels ~= "-1" then
    default_border = C.appearance.border.panels
  end

  pfUI.panel = CreateFrame("Frame", "pfPanel", UIParent)
  pfUI.panel:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.panel:RegisterEvent("BAG_UPDATE")
  pfUI.panel:RegisterEvent("PLAYER_MONEY")
  pfUI.panel:RegisterEvent("UNIT_INVENTORY_CHANGED")
  pfUI.panel:RegisterEvent("PLAYER_XP_UPDATE")
  pfUI.panel:RegisterEvent("FRIENDLIST_UPDATE")
  pfUI.panel:RegisterEvent("GUILD_ROSTER_UPDATE")
  pfUI.panel:RegisterEvent("PLAYER_GUILD_UPDATE")
  pfUI.panel:RegisterEvent("PLAYER_REGEN_ENABLED")
  pfUI.panel:RegisterEvent("PLAYER_DEAD")
  pfUI.panel:RegisterEvent("PLAYER_UNGHOST")
  pfUI.panel:RegisterEvent("UPDATE_INVENTORY_ALERTS")
  pfUI.panel:RegisterEvent("MINIMAP_ZONE_CHANGED")

  -- list of available panel fields
  pfUI.panel.options = { "time", "fps", "exp", "gold", "friends",
                         "guild", "durability", "zone", "ammo", "bagspace" }

  pfUI.panel:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
      pfUI.panel:UpdateGold()
      pfUI.panel:UpdateRepair()
      pfUI.panel:UpdateExp()
      pfUI.panel:UpdateFriend()
      pfUI.panel:UpdateGuild()
      pfUI.panel:UpdateRepair()
      pfUI.panel:UpdateZone()
      pfUI.panel:UpdateAmmo()
      pfUI.panel:UpdateSoulshard()
      pfUI.panel:UpdateBagspace()
    elseif event == "PLAYER_MONEY" then
      pfUI.panel:UpdateGold()
      pfUI.panel:UpdateRepair()
    elseif event == "BAG_UPDATE" then
      pfUI.panel:UpdateSoulshard()
      pfUI.panel:UpdateBagspace()
    elseif event == "UNIT_INVENTORY_CHANGED" then
      pfUI.panel:UpdateAmmo()
    elseif event == "PLAYER_XP_UPDATE" then
      pfUI.panel:UpdateExp()
    elseif event == "FRIENDLIST_UPDATE" then
      pfUI.panel:UpdateFriend()
    elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" then
      pfUI.panel:UpdateGuild()
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_DEAD"
      or event == "PLAYER_UNGHOST" or event == "UPDATE_INVENTORY_ALERTS" then
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
  UpdateMovable(pfUI.panel.clock.timerFrame)

  pfUI.panel.clock.timerFrame.text = pfUI.panel.clock.timerFrame:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.clock.timerFrame.text:SetFontObject(GameFontWhite)
  pfUI.panel.clock.timerFrame.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.clock.timerFrame.text:SetAllPoints(pfUI.panel.clock.timerFrame)

  pfUI.panel.clock.timerFrame:SetScript("OnUpdate", function()
      if not pfUI.panel.clock.timerFrame.Snapshot then pfUI.panel.clock.timerFrame.Snapshot = GetTime() end
      pfUI.panel.clock.timerFrame.curTime = SecondsToTime(floor(GetTime() - pfUI.panel.clock.timerFrame.Snapshot))
      if pfUI.panel.clock.timerFrame.curTime ~= "" then
        pfUI.panel.clock.timerFrame.text:SetText("|c33cccccc" .. pfUI.panel.clock.timerFrame.curTime)
      else
        pfUI.panel.clock.timerFrame.text:SetText("|cffff3333 --- " .. T["NEW TIMER"] .. " ---")
      end
    end)

  pfUI.panel.clock:SetScript("OnUpdate",function(s,e)
    if not pfUI.panel.clock.tick then pfUI.panel.clock.tick = GetTime() - 1 end
    if GetTime() >= pfUI.panel.clock.tick + 1 then
      -- time date
      local tooltip = function ()
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
          servertime = string.format("%.2d:%.2d", h, m) .. noon
        else
          time = date("%H:%M")
          servertime = string.format("%.2d:%.2d", h, m)
        end
        GameTooltip:AddLine("|cff555555" .. T["Time"])
        GameTooltip:AddDoubleLine(T["Localtime"],  "|cffffffff" .. time)
        GameTooltip:AddDoubleLine(T["Servertime"], "|cffffffff".. servertime)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(T["Left Click"], "|cffffffff" .. T["Show/Hide Timer"])
        GameTooltip:AddDoubleLine(T["Right Click"], "|cffffffff" .. T["Reset Timer"])
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
      if C.global.twentyfour == "0" then
        pfUI.panel:OutputPanel("time", date("%I:%M:%S %p"), tooltip, click)
      else
        pfUI.panel:OutputPanel("time", date("%H:%M:%S"), tooltip, click)
      end

      -- lag fps
      local tooltip = function ()
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
        local memmb = round(memkb/1000, 2)
        local gcmb = round(gckb/1000, 2)

        local nin, nout, nping = GetNetStats()

        GameTooltip:AddDoubleLine(T["Active Addons"], "|cffffffff" .. active .. "|cff555555 / |cffffffff" .. GetNumAddOns())
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(T["Memory Usage"], "|cffffffff" .. memmb .. " MB")
        GameTooltip:AddDoubleLine(T["Next Memory Cleanup"], "|cffffffff" .. gcmb .. " MB")
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

      local click = function ()
        if pfUI.addons:IsShown() then
          pfUI.addons:Hide()
        else
          pfUI.addons:Show()
        end
      end

      local _, _, lag = GetNetStats()
      pfUI.panel:OutputPanel("fps", floor(GetFramerate()) .. " " .. T["fps"] .. " & " .. lag .. " " .. T["ms"], tooltip, click)
    end
  end)

  -- Combat Timer
  pfUI.panel.clock.combat = CreateFrame("Frame", "pfUICombatTimer", UIParent)
  pfUI.panel.clock.combat:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.panel.clock.combat:RegisterEvent("PLAYER_REGEN_ENABLED")
  pfUI.panel.clock.combat:RegisterEvent("PLAYER_REGEN_DISABLED")
  pfUI.panel.clock.combat:SetScript("OnEvent", function()
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

  pfUI.panel.clock.combat:SetScript("OnUpdate", function()
    if not this.tick then this.tick = GetTime() end
    if GetTime() <= this.tick + 1 then return else this.tick = GetTime() end
    if this.combat then
      pfUI.panel:OutputPanel("combat", "|cffffaaaa" .. SecondsToTime(ceil(GetTime() - this.combat)))
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
        pfUI.panel:OutputPanel("exp", T["Exp"] .. ": |cffaaaaff"..floor((a/b)*100).."%"..remstring)
      else
        pfUI.panel:OutputPanel("exp", T["Exp"] .. ": " .. floor((a/b)*100) .. "%" .. remstring)
      end
    else
      pfUI.panel:OutputPanel("exp", T["Exp"] .. ": " .. NOT_APPLICABLE)
    end
  end

  -- Update "bagspace"
  function pfUI.panel:UpdateBagspace ()
    local maxslots = 0
    local usedslots = 0

    for bag = 0,4 do
      local bagsize = GetContainerNumSlots(bag)
      maxslots = maxslots + bagsize
      for j = 1,bagsize do
        link = GetContainerItemLink(bag,j)
        if link then
          usedslots = usedslots + 1
        end
      end
    end
    local freeslots = maxslots - usedslots
    pfUI.panel:OutputPanel("bagspace", freeslots .. " (" .. usedslots .. "/" .. maxslots .. ")")
  end

  -- Update "gold"
  function pfUI.panel:UpdateGold ()
    local gold = floor(GetMoney()/ 100 / 100)
    local silver = floor(mod((GetMoney()/100),100))
    local copper = floor(mod(GetMoney(),100))
    if not pfUI.panel.initMoney then pfUI.panel.initMoney = GetMoney() end

    local tooltip = function ()
      pfUI.panel.diffMoney = GetMoney() - pfUI.panel.initMoney

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
      GameTooltip:AddDoubleLine(T["This Session"] .. ":", dmod .. CreateGoldString(math.abs(pfUI.panel.diffMoney)))
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
    local click = function() ToggleFriendsFrame(1) end
    pfUI.panel:OutputPanel("friends", FRIENDS .. ": " .. online, nil, click)
  end

  -- Update "guild"
  function pfUI.panel:UpdateGuild ()
    GuildRoster()
    local online = GetNumGuildMembers()
    local all = GetNumGuildMembers(true)
    local click = function() ToggleFriendsFrame(3) end
    if not GetGuildInfo("player") then
      pfUI.panel:OutputPanel("guild", GUILD .. ": " .. NOT_APPLICABLE, nil, click)
    else
      pfUI.panel:OutputPanel("guild", GUILD .. ": " .. online, nil, click)
    end
  end

  -- Update "durability"
  local repairToolTip = CreateFrame('GameTooltip', "repairToolTip", this, "GameTooltipTemplate")
  function pfUI.panel:UpdateRepair ()
    local slotnames = { "Head", "Shoulder", "Chest", "Wrist",
      "Hands", "Waist", "Legs", "Feet", "MainHand", "SecondaryHand", "Ranged", }
    local repPercent = 100
    local lowestPercent = 100

    for i,slotName in pairs(slotnames) do
      local id, _ = GetInventorySlotInfo(slotName.. "Slot")
      repairToolTip:Hide()
      repairToolTip:SetOwner(this, "ANCHOR_LEFT")
      local hasItem, _, _ = repairToolTip:SetInventoryItem("player", id)
      if (not hasItem) then
        repairToolTip:ClearLines()
      else
        for i=1, 30, 1 do
          local tmpText = _G["repairToolTipTextLeft"..i]
          if (tmpText ~= nil) and (tmpText:GetText()) then
            local searchstr = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
            local _, _, lval, rval = string.find(tmpText:GetText(), searchstr, 1)
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

    local tooltip = function()
      -- recalculate repair costs
      local totalRep = 0
        for i,slotName in pairs(slotnames) do
          local id, _ = GetInventorySlotInfo(slotName.. "Slot")
          repairToolTip:Hide()
          repairToolTip:SetOwner(this, "ANCHOR_LEFT")
          local hasItem, _, repCost = repairToolTip:SetInventoryItem("player", id)
          totalRep = totalRep + repCost
        end
      repairToolTip:Hide()

      -- show tooltip
      if totalRep > 0 then
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, this)
        GameTooltip:SetText("|cff555555"..(string.gsub(REPAIR_COST,":","")).."|r")
        SetTooltipMoney(GameTooltip, totalRep)
        GameTooltip:Show()
      end
    end

    local click = function ()
      ToggleCharacter("PaperDollFrame")
    end

    pfUI.panel:OutputPanel("durability", lowestPercent .. "% " .. ARMOR, tooltip, click)
  end

  function pfUI.panel:UpdateZone ()
    local tooltip = function ()
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

    local click = function ()
      if WorldMapFrame:IsShown() then
        WorldMapFrame:Hide()
      else
        WorldMapFrame:Show()
      end
    end

    pfUI.panel:OutputPanel("zone", GetMinimapZoneText(), tooltip, click)
  end

  function pfUI.panel:UpdateAmmo ()
    if not GetInventoryItemQuality("player", 0) then
      pfUI.panel:OutputPanel("ammo", AMMOSLOT .. ": -")
    else
      local tooltip = function ()
        if GetInventoryItemQuality("player", 0) then
          local ammo = GetInventoryItemCount("player", 0)
          GameTooltip:ClearLines()
          GameTooltip_SetDefaultAnchor(GameTooltip, this)
          GameTooltip:SetInventoryItem("player", 0)
          GameTooltip:AddLine(T["Count"] .. ": " .. ammo, .3,1,.8)
          GameTooltip:Show()
        end
      end

      pfUI.panel:OutputPanel("ammo", AMMOSLOT .. ": " .. GetInventoryItemCount("player", 0), tooltip)
    end
  end

  function pfUI.panel:UpdateSoulshard()
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

    pfUI.panel:OutputPanel("soulshard", T["Soulshards"] .. ": " .. count, tooltip)
  end

  function pfUI.panel:OutputPanel(entry, value, tooltip, func)
    -- return if not yet fully initialized
    if not pfUI.panel.minimap then return end

    local panels = {
      { pfUI.panel.left.left,    C.panel.left.left },
      { pfUI.panel.left.center,  C.panel.left.center },
      { pfUI.panel.left.right,   C.panel.left.right },
      { pfUI.panel.right.left,   C.panel.right.left },
      { pfUI.panel.right.center, C.panel.right.center },
      { pfUI.panel.right.right,  C.panel.right.right },
      { pfUI.panel.minimap,      C.panel.other.minimap },
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


  pfUI.panel.left = CreateFrame("Frame", "pfPanelLeft", UIParent)


  pfUI.panel.left:SetFrameStrata("HIGH")
  pfUI.panel.left:ClearAllPoints()

  if pfUI.chat then
    pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
    pfUI.panel.left:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMLEFT", 2, 2)
    pfUI.panel.left:SetPoint("BOTTOMRIGHT", pfUI.chat.left, "BOTTOMRIGHT", -2, 2)
  else
    pfUI.panel.left:SetWidth(C.chat.left.width)
    pfUI.panel.left:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
  end

  UpdateMovable(pfUI.panel.left)

  pfUI.panel.left:SetHeight(C.global.font_size+default_border*2)
  CreateBackdrop(pfUI.panel.left, default_border, nil)

  pfUI.panel.left.hide = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.hide:ClearAllPoints()
  pfUI.panel.left.hide:SetWidth(12)
  pfUI.panel.left.hide:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.hide:SetPoint("LEFT", 0, 0)
  CreateBackdrop(pfUI.panel.left.hide, default_border)
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
  pfUI.panel.left.left.text:SetFont(font, font_size, "OUTLINE")
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
  pfUI.panel.left.center.text:SetFont(font, font_size, "OUTLINE")
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
  pfUI.panel.left.right.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.left.right.text:ClearAllPoints()
  pfUI.panel.left.right.text:SetAllPoints(pfUI.panel.left.right)
  pfUI.panel.left.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.right.text:SetFontObject(GameFontWhite)

  pfUI.panel.right = CreateFrame("Frame", "pfPanelRight", UIParent)
  pfUI.panel.right:SetFrameStrata("HIGH")
  pfUI.panel.right:ClearAllPoints()
  if pfUI.chat then
    pfUI.panel.right:SetScale(pfUI.chat.left:GetScale())
    pfUI.panel.right:SetPoint("BOTTOMLEFT", pfUI.chat.right, "BOTTOMLEFT", 2, 2)
    pfUI.panel.right:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -2, 2)
  else
    pfUI.panel.right:SetWidth(C.chat.right.width)
    pfUI.panel.right:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
  end

  UpdateMovable(pfUI.panel.right)

  pfUI.panel.right:SetHeight(C.global.font_size+default_border*2)
  CreateBackdrop(pfUI.panel.right, default_border, nil)

  pfUI.panel.right.hide = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.hide:ClearAllPoints()
  pfUI.panel.right.hide:SetWidth(12)
  pfUI.panel.right.hide:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.hide:SetPoint("RIGHT", 0, 0)
  CreateBackdrop(pfUI.panel.right.hide, default_border)
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
  pfUI.panel.right.left.text:SetFont(font, font_size, "OUTLINE")
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
  pfUI.panel.right.center.text:SetFont(font, font_size, "OUTLINE")
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
  pfUI.panel.right.right.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.right.right.text:ClearAllPoints()
  pfUI.panel.right.right.text:SetAllPoints(pfUI.panel.right.right)
  pfUI.panel.right.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.right.text:SetFontObject(GameFontWhite)

  pfUI.panel.minimap = CreateFrame("Button", "pfPanelMinimap", UIParent)
  CreateBackdrop(pfUI.panel.minimap, default_border)
  UpdateMovable(pfUI.panel.minimap)
  pfUI.panel.minimap:SetHeight(C.global.font_size+default_border*2)
  if pfUI.minimap then
    pfUI.panel.minimap:SetPoint("TOP", pfUI.minimap, "BOTTOM", 0 , -default_border*3)
    pfUI.panel.minimap:SetWidth(pfUI.minimap:GetWidth())
  else
    pfUI.panel.minimap:SetWidth(200)
    pfUI.panel.minimap:SetPoint("TOP", UIParent, "TOP", 0, -5)
  end
  pfUI.panel.minimap:SetFrameStrata("BACKGROUND")
  pfUI.panel.minimap.text = pfUI.panel.minimap:CreateFontString("MinimapZoneText", "LOW", "GameFontNormal")
  pfUI.panel.minimap.text:SetFont(font, font_size, "OUTLINE")
  pfUI.panel.minimap.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.minimap.text:SetFontObject(GameFontWhite)

  -- MicroButtons
  if C.panel.micro.enable == "1" then
    pfUI.panel.microbutton = CreateFrame("Frame", "pfPanelMicroButton", UIParent)
    pfUI.panel.microbutton:SetPoint("TOP", pfUI.panel.minimap, "BOTTOM", 0,  -2*default_border)
    UpdateMovable(pfUI.panel.microbutton)
    pfUI.panel.microbutton:SetHeight(23)
    pfUI.panel.microbutton:SetWidth(145)
    pfUI.panel.microbutton:SetFrameStrata("BACKGROUND")

    local MICRO_BUTTONS = {
      'CharacterMicroButton', 'SpellbookMicroButton', 'TalentMicroButton',
      'QuestLogMicroButton', 'SocialsMicroButton', 'WorldMapMicroButton',
      'MainMenuMicroButton', 'HelpMicroButton',
    }

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
end)
