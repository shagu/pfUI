pfUI:RegisterModule("panel", function ()
  pfUI.panel = CreateFrame("Frame",nil,UIParent)
  pfUI.panel:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.panel:RegisterEvent("UNIT_AURA")
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
      pfUI.panel:UpdateRepair();
      pfUI.panel:UpdateExp()
      pfUI.panel:UpdateFriend()
      pfUI.panel:UpdateGuild();
      pfUI.panel:UpdateRepair();
      pfUI.panel:UpdateZone();
    elseif event == "PLAYER_MONEY" then
      pfUI.panel:UpdateGold()
      pfUI.panel:UpdateRepair();
    elseif event == "PLAYER_XP_UPDATE" then
      pfUI.panel:UpdateExp()
    elseif event == "FRIENDLIST_UPDATE" then
      pfUI.panel:UpdateFriend()
    elseif event == "GUILD_ROSTER_UPDATE" or event == "PLAYER_GUILD_UPDATE" then
      pfUI.panel:UpdateGuild();
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_DEAD" then
      pfUI.panel:UpdateRepair();
    elseif event == "MINIMAP_ZONE_CHANGED" then
      pfUI.panel:UpdateZone()
    end
  end)

  pfUI.panel.clock = CreateFrame("Frame",nil,UIParent)
  pfUI.panel.clock:SetScript("OnUpdate",function(s,e)
    if not pfUI.panel.clock.tick then pfUI.panel.clock.tick = GetTime() - 1 end
    if GetTime() >= pfUI.panel.clock.tick + 1 then
      pfUI.panel.clock.tick = GetTime()
      pfUI.panel:OutputPanel("time", date("%H:%M:%S"))
      local _, _, lag = GetNetStats();
      local fps = floor(GetFramerate());
      pfUI.panel:OutputPanel("fps", floor(GetFramerate()) .. " fps & " .. lag .. " ms")
    end
  end);

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
    local gold = floor(GetMoney()/ 100 / 100);
    local silver = floor(mod((GetMoney()/100),100));
    local copper = floor(mod(GetMoney(),100));
    pfUI.panel:OutputPanel("gold", gold .. "|cffffd700g|r " .. silver .. "|cffc7c7cfs|r " .. copper .. "|cffeda55fc|r")
  end

  -- Update "friends"
  function pfUI.panel:UpdateFriend ()
    local online = 0;
    local all = GetNumFriends();
    for friendIndex=1, all do
      friend_name, friend_level, friend_class, friend_area, friend_connected = GetFriendInfo(friendIndex);
      if ( friend_connected ) then
        online = online + 1;
      end
    end
    pfUI.panel:OutputPanel("friends", "Friends: " .. online)
  end

  -- Update "guild"
  function pfUI.panel:UpdateGuild ()
    GuildRoster()
    local online = GetNumGuildMembers();
    local all = GetNumGuildMembers(true);
    pfUI.panel:OutputPanel("guild", "Guild: "..online)
  end

  -- Update "durability"
  local repairToolTip = CreateFrame('GameTooltip', "repairToolTip", this, "GameTooltipTemplate")
  function pfUI.panel:UpdateRepair ()
    local slotnames = { "Head", "Shoulder", "Chest", "Wrist",
      "Hands", "Waist", "Legs", "Feet", "MainHand", "SecondaryHand", "Ranged", };
    local id, hasItem, repairCost;
    local itemName, durability, tmpText, midpt, lval, rval;

    duraLowestslotName = nil;
    repPercent = 100;
    lowestPercent = 100;

    for i,slotName in pairs(slotnames) do
      id, _ = GetInventorySlotInfo(slotName.. "Slot");
      repairToolTip:Hide()
      repairToolTip:SetOwner(this, "ANCHOR_LEFT");
      hasItem, _, repCost = repairToolTip:SetInventoryItem("player", id);
      if (not hasItem) then repairToolTip:ClearLines()
      else
        for i=1, 30, 1 do
          tmpText = getglobal("repairToolTipTextLeft"..i);
          if (tmpText ~= nil) and (tmpText:GetText()) then
            local searchstr = string.gsub(DURABILITY_TEMPLATE, "%%[^%s]+", "(.+)")
            _, _, lval, rval = string.find(tmpText:GetText(), searchstr);
            if (lval and rval) then
              repPercent = math.floor(lval / rval * 100)
              break;
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
    pfUI.panel:OutputPanel("zone", GetMinimapZoneText())
  end

  function pfUI.panel:OutputPanel(entry, value)
    if pfUI_config.panel.left.left == entry then
      pfUI.panel.left.left.text:SetText(value)
    end
    if pfUI_config.panel.left.center == entry then
      pfUI.panel.left.center.text:SetText(value)
    end
    if pfUI_config.panel.left.right == entry then
      pfUI.panel.left.right.text:SetText(value)
    end
    if pfUI_config.panel.right.left == entry then
      pfUI.panel.right.left.text:SetText(value)
    end
    if pfUI_config.panel.right.center == entry then
      pfUI.panel.right.center.text:SetText(value)
    end
    if pfUI_config.panel.right.right == entry then
      pfUI.panel.right.right.text:SetText(value)
    end
    if pfUI_config.panel.other.minimap == entry then
      pfUI.panel.minimap.text:SetText(value)
    end
  end

  pfUI.panel.left = CreateFrame("Frame", "pfPanelLeft", pfUI.panel)
  pfUI.panel.left:SetScale(pfUI.chat.left:GetScale())
  pfUI.panel.left:SetFrameStrata("HIGH")
  pfUI.panel.left:ClearAllPoints()
  pfUI.panel.left:SetHeight(pfUI_config.global.font_size*2)
  pfUI.panel.left:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMLEFT", 2, 2)
  pfUI.panel.left:SetPoint("BOTTOMRIGHT", pfUI.chat.left, "BOTTOMRIGHT", -2, 2)
  pfUI.panel.left:SetBackdrop(pfUI.backdrop)
  pfUI.panel.left:SetBackdropColor(0,0,0,.75)

  pfUI.panel.left.hide = CreateFrame("Button", nil, pfUI.panel.left)
  pfUI.panel.left.hide:ClearAllPoints()
  pfUI.panel.left.hide:SetWidth(16)
  pfUI.panel.left.hide:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.hide:SetPoint("LEFT", 0, 0)
  pfUI.panel.left.hide:SetBackdrop(pfUI.backdrop)
  pfUI.panel.left.hide.texture = pfUI.panel.left.hide:CreateTexture("pfPanelLeftHide")
  pfUI.panel.left.hide.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\left")
  pfUI.panel.left.hide.texture:ClearAllPoints()
  pfUI.panel.left.hide.texture:SetPoint("TOPLEFT", pfUI.panel.left.hide, "TOPLEFT", 4, -6)
  pfUI.panel.left.hide.texture:SetPoint("BOTTOMRIGHT", pfUI.panel.left.hide, "BOTTOMRIGHT", -4, 6)
  pfUI.panel.left.hide.texture:SetVertexColor(.25,.25,.25,1)
  pfUI.panel.left.hide:SetScript("OnClick", function()
      if pfUI.chat.left:IsShown() then pfUI.chat.left:Hide() else pfUI.chat.left:Show() end
    end)

  pfUI.panel.left.left = CreateFrame("Frame", nil, pfUI.panel.left)
  pfUI.panel.left.left:ClearAllPoints()
  pfUI.panel.left.left:SetWidth(115)
  pfUI.panel.left.left:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.left:SetPoint("LEFT", 0, 0)
  pfUI.panel.left.left.text = pfUI.panel.left.left:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.left.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.left.left.text:ClearAllPoints()
  pfUI.panel.left.left.text:SetAllPoints(pfUI.panel.left.left)
  pfUI.panel.left.left.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.left.text:SetFontObject(GameFontWhite)
  pfUI.panel.left.left.text:SetText("[DUMMY]")

  pfUI.panel.left.center = CreateFrame("Frame", nil, pfUI.panel.left)
  pfUI.panel.left.center:ClearAllPoints()
  pfUI.panel.left.center:SetWidth(115)
  pfUI.panel.left.center:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.center:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.center.text = pfUI.panel.left.center:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.center.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.left.center.text:ClearAllPoints()
  pfUI.panel.left.center.text:SetAllPoints(pfUI.panel.left.center)
  pfUI.panel.left.center.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.center.text:SetFontObject(GameFontWhite)
  pfUI.panel.left.center.text:SetText("[DUMMY]")

  pfUI.panel.left.right = CreateFrame("Frame", nil, pfUI.panel.left)
  pfUI.panel.left.right:ClearAllPoints()
  pfUI.panel.left.right:SetWidth(115)
  pfUI.panel.left.right:SetHeight(pfUI.panel.left:GetHeight())
  pfUI.panel.left.right:SetPoint("RIGHT", 0, 0)
  pfUI.panel.left.right.text = pfUI.panel.left.right:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.left.right.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.left.right.text:ClearAllPoints()
  pfUI.panel.left.right.text:SetAllPoints(pfUI.panel.left.right)
  pfUI.panel.left.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.left.right.text:SetFontObject(GameFontWhite)
  pfUI.panel.left.right.text:SetText("[DUMMY]")

  pfUI.panel.right = CreateFrame("Frame", "pfPanelRight", pfUI.panel)
  pfUI.panel.right:SetScale(pfUI.chat.right:GetScale())
  pfUI.panel.right:SetFrameStrata("HIGH")
  pfUI.panel.right:ClearAllPoints()
  pfUI.panel.right:SetHeight(pfUI_config.global.font_size*2)
  pfUI.panel.right:SetPoint("BOTTOMLEFT", pfUI.chat.right, "BOTTOMLEFT", 2, 2)
  pfUI.panel.right:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -2, 2)
  pfUI.panel.right:SetBackdrop(pfUI.backdrop)
  pfUI.panel.right:SetBackdropColor(0,0,0,.75)

  pfUI.panel.right.hide = CreateFrame("Button", nil, pfUI.panel.right)
  pfUI.panel.right.hide:ClearAllPoints()
  pfUI.panel.right.hide:SetWidth(16)
  pfUI.panel.right.hide:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.hide:SetPoint("RIGHT", 0, 0)
  pfUI.panel.right.hide:SetBackdrop(pfUI.backdrop)
  pfUI.panel.right.hide.texture = pfUI.panel.right.hide:CreateTexture("pfPanelRightHide")
  pfUI.panel.right.hide.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\right")
  pfUI.panel.right.hide.texture:ClearAllPoints()
  pfUI.panel.right.hide.texture:SetPoint("TOPLEFT", pfUI.panel.right.hide, "TOPLEFT", 4, -6)
  pfUI.panel.right.hide.texture:SetPoint("BOTTOMRIGHT", pfUI.panel.right.hide, "BOTTOMRIGHT", -4, 6)
  pfUI.panel.right.hide.texture:SetVertexColor(.25,.25,.25,1)
  pfUI.panel.right.hide:SetScript("OnClick", function()
      if pfUI.chat.right:IsShown() then pfUI.chat.right:Hide() else pfUI.chat.right:Show() end
    end)

  pfUI.panel.right.left = CreateFrame("Frame", nil, pfUI.panel.right)
  pfUI.panel.right.left:ClearAllPoints()
  pfUI.panel.right.left:SetWidth(115)
  pfUI.panel.right.left:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.left:SetPoint("LEFT", 0, 0)
  pfUI.panel.right.left.text = pfUI.panel.right.left:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.left.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.right.left.text:ClearAllPoints()
  pfUI.panel.right.left.text:SetAllPoints(pfUI.panel.right.left)
  pfUI.panel.right.left.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.left.text:SetFontObject(GameFontWhite)
  pfUI.panel.right.left.text:SetText("[DUMMY]")

  pfUI.panel.right.center = CreateFrame("Frame", nil, pfUI.panel.right)
  pfUI.panel.right.center:ClearAllPoints()
  pfUI.panel.right.center:SetWidth(115)
  pfUI.panel.right.center:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.center:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.center.text = pfUI.panel.right.center:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.center.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.right.center.text:ClearAllPoints()
  pfUI.panel.right.center.text:SetAllPoints(pfUI.panel.right.center)
  pfUI.panel.right.center.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.center.text:SetFontObject(GameFontWhite)
  pfUI.panel.right.center.text:SetText("[DUMMY]")

  pfUI.panel.right.right = CreateFrame("Frame", nil, pfUI.panel.right)
  pfUI.panel.right.right:ClearAllPoints()
  pfUI.panel.right.right:SetWidth(115)
  pfUI.panel.right.right:SetHeight(pfUI.panel.right:GetHeight())
  pfUI.panel.right.right:SetPoint("RIGHT", 0, 0)
  pfUI.panel.right.right.text = pfUI.panel.right.right:CreateFontString("Status", "LOW", "GameFontNormal")
  pfUI.panel.right.right.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.right.right.text:ClearAllPoints()
  pfUI.panel.right.right.text:SetAllPoints(pfUI.panel.right.right)
  pfUI.panel.right.right.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.right.right.text:SetFontObject(GameFontWhite)
  pfUI.panel.right.right.text:SetText("[DUMMY]")

  pfUI.panel.minimap = CreateFrame("Frame", "pfPanelMinimap", UIParent)
  pfUI.panel.minimap:SetBackdrop(pfUI.backdrop)
  pfUI.panel.minimap:SetPoint("TOPRIGHT",UIParent, -5, -7 - Minimap:GetHeight() - 5)
  pfUI.utils:loadPosition(pfUI.panel.minimap)
  pfUI.panel.minimap:SetHeight(pfUI_config.global.font_size * 2)
  pfUI.panel.minimap:SetWidth(Minimap:GetWidth() + 5)
  pfUI.panel.minimap:SetFrameStrata("BACKGROUND")
  pfUI.panel.minimap.text = pfUI.panel.minimap:CreateFontString("MinimapZoneText", "LOW", "GameFontNormal")
  pfUI.panel.minimap.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
  pfUI.panel.minimap.text:SetPoint("CENTER", 0, 0)
  pfUI.panel.minimap.text:SetFontObject(GameFontWhite)
  pfUI.panel.minimap.text:SetText("[DUMMY]")

  -- MicroButtons
  if pfUI_config.panel.micro.enable == "1" then
    pfUI.panel.microbutton = CreateFrame("Frame", "pfPanelMicroButton", UIParent)
    pfUI.panel.microbutton:SetPoint("TOP", 0, 0)
    pfUI.utils:loadPosition(pfUI.panel.microbutton)
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
      button.frame:SetBackdrop(pfUI.backdrop)
      button.frame:SetBackdropColor(0,0,0,0)
      button:Show()
    end
  end
end)
