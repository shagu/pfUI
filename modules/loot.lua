pfUI:RegisterModule("loot", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()

  pfUI.loot = CreateFrame("Frame", "pfLootFrame", UIParent)
  pfUI.loot:Hide()
  pfUI.loot:SetFrameStrata("DIALOG")
  pfUI.loot:RegisterEvent("LOOT_OPENED")
  pfUI.loot:RegisterEvent("LOOT_CLOSED")
  pfUI.loot:RegisterEvent("LOOT_SLOT_CLEARED")
  pfUI.loot:RegisterEvent("OPEN_MASTER_LOOT_LIST")
  pfUI.loot:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
  pfUI.loot:RegisterEvent("LOOT_BIND_CONFIRM")

  pfUI.loot:SetWidth(160+border*2)

  if C.loot.mousecursor == "0" then
    pfUI.loot:SetHeight(160+border*2)
    pfUI.loot:SetPoint("TOP", UIParent, "CENTER", 0, 0)
    UpdateMovable(pfUI.loot)
  end

  pfUI.loot.unitbuttons = {
    ["PF_BANKLOOTER"] = {T["Set Banker"],"bankLooter"},
    ["PF_DISENCHANTLOOTER"] = {T["Set Disenchanter"],"disenchantLooter"},
  }
  pfUI.loot.me = (UnitName("player"))
  pfUI.loot.index_to_name = {}
  pfUI.loot.name_to_index = {}
  pfUI.loot.classes_in_raid = {}
  pfUI.loot.players_in_class = {}
  pfUI.loot.randoms = {}
  pfUI.loot.rollers = {}
  pfUI.loot.rollers_sorted = {}
  pfUI.loot.info = {}
  local info = pfUI.loot.info

  function pfUI.loot.RaidRoll(candidates)
    if type(candidates) ~= "table" then return end
    local slot = pfUI.loot.selectedSlot or 0
    local to = table.getn(candidates)
    if to >= 1 then
      local _,_,_,quality = GetLootSlotInfo(slot)
      if quality >= tonumber(C.loot.rollannouncequal) then
        SendChatMessageWide(T["Random Rolling"].." "..GetLootSlotLink(slot))
        if C.loot.rollannounce == "1" then
          local k,names = 1, ""
          for i=1,to do
            names = (k==1) and (i..":"..pfUI.loot.index_to_name[candidates[i]]) or (names..", "..i..":"..pfUI.loot.index_to_name[candidates[i]])
            -- fit the maximum names in a single 255 char message (15)
            if i == to or k == 15 then
              QueueFunction(SendChatMessageWide,names)
              names = ""
            end
            k = k<15 and k+1 or 1
          end
        end
      end
      pfUI.loot:RegisterEvent("CHAT_MSG_SYSTEM")
      pfUI.loot.randomRolling = true
      QueueFunction(RandomRoll,"1",tostring(to))
    end
  end

  function pfUI.loot.RequestRolls()
    local slot = pfUI.loot.selectedSlot or 0
    local rollers = wipe(pfUI.loot.rollers)
    local rollers_sorted = wipe(pfUI.loot.rollers_sorted)
    SendChatMessageWide(T["Roll for"].. " " .. GetLootSlotLink(slot))
    pfUI.loot:RegisterEvent("CHAT_MSG_SYSTEM")
    pfUI.loot.monitorRolling = true
    UIDropDownMenu_Refresh(GroupLootDropDown)
  end

  function pfUI.loot:BuildSpecialRecipientsMenu(level)
    local slot = pfUI.loot.selectedSlot or 0
    if level == 1 then
      if pfUI.loot.my_index or pfUI.loot.disenchanter_index or pfUI.loot.banker_index then
        info = wipe(info)
        info.text = T["Special Recipient"]
        info.textR = NORMAL_FONT_COLOR.r
        info.textG = NORMAL_FONT_COLOR.g
        info.textB = NORMAL_FONT_COLOR.b
        info.textHeight = 12
        info.hasArrow = 1
        info.notCheckable = 1
        info.value = "PFRECIPIENTS"
        info.func = nil
        UIDropDownMenu_AddButton(info)
      end
    elseif level == 2 then
      if UIDROPDOWNMENU_MENU_VALUE == "PFRECIPIENTS" then
        if (pfUI.loot.my_index) then
          info = wipe(info)
          info.text = T["Self"]
          info.textHeight = 12
          info.value = pfUI.loot.my_index
          info.func = GroupLootDropDown_GiveLoot
          UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
        end
        if (pfUI.loot.disenchanter_index) then
          info = wipe(info)
          info.text = T["Disenchanter"]
          info.textHeight = 12
          info.value = pfUI.loot.disenchanter_index
          info.func = GroupLootDropDown_GiveLoot
          UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
        end
        if (pfUI.loot.banker_index) then
          info = wipe(info)
          info.text = T["Banker"]
          info.textHeight = 12
          info.value = pfUI.loot.banker_index
          info.func = GroupLootDropDown_GiveLoot
          UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
        end
      end
    end
  end

  function pfUI.loot.ClearRolls()
    wipe(pfUI.loot.rollers)
    wipe(pfUI.loot.rollers_sorted)
    pfUI.loot.monitorRolling = nil
    UIDropDownMenu_Refresh(GroupLootDropDown)
  end

  function pfUI.loot.CallTieRoll(rollers)
    if type(rollers) ~= "table" then return end
    local highroll
    local ties = {}
    local num_rollers = table.getn(rollers)
    for i=1,num_rollers do
      if rollers[i].value ~= "disabled" then
        if highroll == nil then
          highroll = rollers[i].roll
          table.insert(ties,rollers[i])
        elseif rollers[i].roll == highroll then
          table.insert(ties,rollers[i])
        end
      end
    end
    local num_ties = table.getn(ties)
    if num_ties > 1 then
      local names = ""
      for i=1, num_ties do
        names = i==1 and (names..ties[i].who) or (names..", "..ties[i].who)
      end
      pfUI.loot:ClearRolls()
      SendChatMessageWide(names.." "..T["Reroll"])
      pfUI.loot:RegisterEvent("CHAT_MSG_SYSTEM")
      pfUI.loot.monitorRolling = true
    end
    UIDropDownMenu_Refresh(GroupLootDropDown)
  end

  function pfUI.loot:BuildSpecialRollsMenu(level)
    local slot = pfUI.loot.selectedSlot or 0
    if level == 1 then
      info = wipe(info)
      info.text = T["Random"]
      info.textR = NORMAL_FONT_COLOR.r
      info.textG = NORMAL_FONT_COLOR.g
      info.textB = NORMAL_FONT_COLOR.b
      info.value = "PFRANDOM"
      info.textHeight = 12
      info.notCheckable = 1
      info.arg1 = pfUI.loot.randoms
      info.func = pfUI.loot.RaidRoll
      UIDropDownMenu_AddButton(info)

      info = wipe(info)
      info.text = T["Request Rolls"]
      info.textR = NORMAL_FONT_COLOR.r
      info.textG = NORMAL_FONT_COLOR.g
      info.textB = NORMAL_FONT_COLOR.b
      info.value = "PFROLLS"
      info.textHeight = 12
      info.hasArrow = 1
      info.notCheckable = 1
      info.func = pfUI.loot.RequestRolls
      UIDropDownMenu_AddButton(info)
    elseif level == 2 then
      if UIDROPDOWNMENU_MENU_VALUE == "PFROLLS" then
        info = wipe(info)
        info.text = T["Clear Rolls"]
        info.textR = NORMAL_FONT_COLOR.r
        info.textG = NORMAL_FONT_COLOR.g
        info.textB = NORMAL_FONT_COLOR.b
        info.value = "PFCLEARROLLS"
        info.notCheckable = 1
        info.func = pfUI.loot.ClearRolls
        UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)

        info = wipe(info)
        info.text = T["Reroll Ties"]
        info.textR = NORMAL_FONT_COLOR.r
        info.textG = NORMAL_FONT_COLOR.g
        info.textB = NORMAL_FONT_COLOR.b
        info.value = "PFTIEROLL"
        info.notCheckable = 1
        info.arg1 = pfUI.loot.rollers_sorted
        info.func = pfUI.loot.CallTieRoll
        UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
        for _,roller in ipairs(pfUI.loot.rollers_sorted) do
          info = wipe(info)
          info.text = string.format("%02d - %s",roller.roll,roller.who)
          info.textHeight = 12
          if roller.value == "disabled" then
            info.disabled = 1
            info.value = "disabled"
          else
            info.value = roller.value
            info.func = GroupLootDropDown_GiveLoot
          end
          info.notCheckable = 1
          UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
        end
      end
    end
  end

  function pfUI.loot:BuildRaidMenu(level)
    local slot = pfUI.loot.selectedSlot or 0
    local index_to_name = wipe(pfUI.loot.index_to_name)
    local name_to_index = wipe(pfUI.loot.name_to_index)
    local classes_in_raid = wipe(pfUI.loot.classes_in_raid) -- [global class]=localized class for display
    local players_in_class = wipe(pfUI.loot.players_in_class)
    local randoms = wipe(pfUI.loot.randoms)
    pfUI.loot.my_index = false
    pfUI.loot.disenchanter_index = false
    pfUI.loot.banker_index = false
    local disenchantLooter = pfUI.loot.disenchantLooter or ""
    local bankLooter = pfUI.loot.bankLooter or ""
    for i = 1, MAX_RAID_MEMBERS do -- masterlootcandidate index does not correspond with unit id index
      local candidate = GetMasterLootCandidate(i)
      if (candidate) then
        index_to_name[i] = candidate
        name_to_index[candidate] = i
        randoms[table.getn(randoms)+1]=i
        if candidate == pfUI.loot.me then
          pfUI.loot.my_index = i
        end
        if candidate == disenchantLooter then
          pfUI.loot.disenchanter_index = i
        end
        if candidate == bankLooter then
          pfUI.loot.banker_index = i
        end
        local unit = GroupInfoByName(candidate,"raid")
        classes_in_raid[unit.class] = unit.lclass
        if players_in_class[unit.class] == nil then players_in_class[unit.class] = {} end
        table.insert(players_in_class[unit.class],candidate)
      end
    end
    if level == 1 then -- classes
      info = wipe(info)
      info.text = GIVE_LOOT
      info.textHeight = 12
      info.notCheckable = 1
      info.isTitle = 1
      UIDropDownMenu_AddButton(info)
      pfUI.loot:BuildSpecialRollsMenu(UIDROPDOWNMENU_MENU_LEVEL)
      pfUI.loot:BuildSpecialRecipientsMenu(UIDROPDOWNMENU_MENU_LEVEL)
      for order, class in ipairs(CLASS_SORT_ORDER) do
        local lclass = classes_in_raid[class]
        if (lclass) then
          info = wipe(info)
          info.text = lclass
          info.textR, info.textG, info.textB = .7,.7,.7
          if class and RAID_CLASS_COLORS[class] then
            info.textR = RAID_CLASS_COLORS[class].r
            info.textG = RAID_CLASS_COLORS[class].g
            info.textB = RAID_CLASS_COLORS[class].b
          end
          info.textHeight = 12
          info.hasArrow = 1
          info.notCheckable = 1
          info.value = class
          info.func = nil
          UIDropDownMenu_AddButton(info)
        end
      end
    elseif level == 2 then -- players
      pfUI.loot:BuildSpecialRollsMenu(UIDROPDOWNMENU_MENU_LEVEL)
      pfUI.loot:BuildSpecialRecipientsMenu(UIDROPDOWNMENU_MENU_LEVEL)
      local players = players_in_class[UIDROPDOWNMENU_MENU_VALUE]
      if (players) and next(players) then
        table.sort(players)
        for _, candidate in ipairs(players) do
          info = wipe(info)
          info.text = candidate
          info.textR, info.textG, info.textB = .7,.7,.7
          if UIDROPDOWNMENU_MENU_VALUE and RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE] then
            info.textR = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].r
            info.textG = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].g
            info.textB = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].b
          end
          info.textHeight = 12
          info.value = name_to_index[candidate]
          info.func = GroupLootDropDown_GiveLoot
          UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
        end
      end
    end
  end

  function pfUI.loot:BuildPartyMenu(level)
    local slot = pfUI.loot.selectedSlot or 0
    if level == 1 then
      for i=1, MAX_PARTY_MEMBERS+1, 1 do
        local candidate = GetMasterLootCandidate(i)
        if (candidate) then
          info = wipe(info)
          local unit = GroupInfoByName(candidate,"party")
          info.text = candidate
          info.textR, info.textG, info.textB = .7,.7,.7
          if unit.class and RAID_CLASS_COLORS[unit.class] then
            info.textR = RAID_CLASS_COLORS[unit.class].r
            info.textG = RAID_CLASS_COLORS[unit.class].g
            info.textB = RAID_CLASS_COLORS[unit.class].b
          end
          info.textHeight = 12
          info.value = i
          info.func = GroupLootDropDown_GiveLoot
          UIDropDownMenu_AddButton(info)
        end
      end
    end
  end

  function pfUI.loot:InitGroupDropDown()
    local inRaid = UnitInRaid("player")
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
      if ( inRaid ) then
        pfUI.loot:BuildRaidMenu(UIDROPDOWNMENU_MENU_LEVEL)
      else
        pfUI.loot:BuildPartyMenu(UIDROPDOWNMENU_MENU_LEVEL)
      end
    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 and (inRaid) then
      pfUI.loot:BuildRaidMenu(UIDROPDOWNMENU_MENU_LEVEL)
    end
  end

  function pfUI.loot:AddMasterLootMenus()
    for index,value in ipairs(UnitPopupMenus["SELF"]) do
      if value == "LOOT_PROMOTE" then
        table.insert(UnitPopupMenus["SELF"],index+1,"PF_BANKLOOTER")
        table.insert(UnitPopupMenus["SELF"],index+1,"PF_DISENCHANTLOOTER")
      end
    end
    for index,value in ipairs(UnitPopupMenus["PARTY"]) do
      if value == "LOOT_PROMOTE" then
        table.insert(UnitPopupMenus["PARTY"],index+1,"PF_BANKLOOTER")
        table.insert(UnitPopupMenus["PARTY"],index+1,"PF_DISENCHANTLOOTER")
      end
    end
    for index,value in ipairs(UnitPopupMenus["PLAYER"]) do
      if value == "RAID_TARGET_ICON" then
        table.insert(UnitPopupMenus["PLAYER"],index+1,"PF_BANKLOOTER")
        table.insert(UnitPopupMenus["PLAYER"],index+1,"PF_DISENCHANTLOOTER")
      end
    end
    for index,value in ipairs(UnitPopupMenus["RAID"]) do
      if value == "RAID_REMOVE" then
        table.insert(UnitPopupMenus["RAID"],index+1,"PF_BANKLOOTER")
        table.insert(UnitPopupMenus["RAID"],index+1,"PF_DISENCHANTLOOTER")
      end
    end
  end

  function pfUI.loot:RemoveMasterlootMenus()
    for index = table.getn(UnitPopupMenus["SELF"]),1,-1 do
      if UnitPopupMenus["SELF"][index] == "PF_BANKLOOTER" or UnitPopupMenus["SELF"][index] == "PF_DISENCHANTLOOTER" then
        table.remove(UnitPopupMenus["SELF"],index,value)
      end
    end
    for index = table.getn(UnitPopupMenus["PARTY"]),1,-1 do
      if UnitPopupMenus["PARTY"][index] == "PF_BANKLOOTER" or UnitPopupMenus["PARTY"][index] == "PF_DISENCHANTLOOTER" then
        table.remove(UnitPopupMenus["PARTY"],index,value)
      end
    end
    for index = table.getn(UnitPopupMenus["PLAYER"]),1,-1 do
      if UnitPopupMenus["PLAYER"][index] == "PF_BANKLOOTER" or UnitPopupMenus["PLAYER"][index] == "PF_DISENCHANTLOOTER" then
        table.remove(UnitPopupMenus["PLAYER"],index,value)
      end
    end
    for index = table.getn(UnitPopupMenus["RAID"]),1,-1 do
      if UnitPopupMenus["RAID"][index] == "PF_BANKLOOTER" or UnitPopupMenus["RAID"][index] == "PF_DISENCHANTLOOTER" then
        table.remove(UnitPopupMenus["RAID"],index,value)
      end
    end
  end

  if C.loot.advancedloot == "1" then
    UIDropDownMenu_Initialize(GroupLootDropDown, pfUI.loot.InitGroupDropDown, "MENU")
    for button, data in pairs(pfUI.loot.unitbuttons) do
      UnitPopupButtons[button] = { text = data[1], dist = 0}
    end
    pfUI.loot:RemoveMasterlootMenus() -- remove then add to ensure no duplicate menus
    pfUI.loot:AddMasterLootMenus()
    hooksecurefunc("UnitPopup_OnClick",function()
      local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU]
      if not dropdownFrame then return end
      local button = this.value
      local unit = dropdownFrame.unit
      local name = dropdownFrame.name
      if button and pfUI.loot.unitbuttons[button] then
        if name then
          -- resolves to pfUI.loot.bankLooter|disenchantLooter = name
          pfUI.loot[pfUI.loot.unitbuttons[button][2]] = name
        end
      end
    end)
    hooksecurefunc("UnitPopup_HideButtons",function()
      local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU]
      local unit = dropdownFrame.unit
      local name = dropdownFrame.name
      for index,value in pairs(UnitPopupMenus[dropdownFrame.which]) do
        if pfUI.loot.unitbuttons[value] then
          local method, lootmasterID = GetLootMethod()
          if not ((method == "master" and lootmasterID == 0) or IsRaidLeader()) then
            UnitPopupShown[index] = 0
          end
          if (unit) and UnitIsPlayer(unit) and not (UnitInRaid(unit) or (UnitInParty(unit) and UnitExists("party1"))) then
            UnitPopupShown[index] = 0
          end
        end
      end
    end,true)
  else
    pfUI.loot:RemoveMasterlootMenus()
    UIDropDownMenu_Initialize(GroupLootDropDown, GroupLootDropDown_Initialize, "MENU")
  end

  pfUI.loot.slots = {}
  function pfUI.loot:UpdateLootFrame()
    if C.loot.mousecursor == "1" then
      pfUI.loot:SetClampedToScreen(true)
    else
      pfUI.loot:SetClampedToScreen(false)
    end
    local maxrarity, maxwidth = 0, 0

    local items = GetNumLootItems()
    LootFrame.numLootItems = items

    if items > 0 then
      local real = 0
      for i=1, items do
        local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
        if texture then real = real + 1 end
      end

      local slotid = 1
      for id=0, items do
        if GetLootSlotInfo(id) then
          local slot = pfUI.loot.slots[slotid] or pfUI.loot:CreateSlot(slotid)
          local texture, item, quantity, quality, locked = GetLootSlotInfo(id)
          local color = ITEM_QUALITY_COLORS[quality]

          if(LootSlotIsCoin(id)) then
            item = string.gsub(string.gsub(item,"\n", ", "), ", $", "")
          end

          if(quantity > 1) then
            slot.count:SetText(quantity)
            slot.count:Show()
          else
            slot.count:Hide()
          end

          if(quality > 1) then
            slot.rarity:SetVertexColor(color.r, color.g, color.b)
            slot.ficon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
            slot.rarity:Show()
          else
            slot.ficon.backdrop:SetBackdropBorderColor(.3,.3,.3)
            slot.rarity:Hide()
          end

          slot.quality = quality
          slot.name:SetText(item)
          slot.name:SetTextColor(color.r, color.g, color.b)
          slot.icon:SetTexture(texture)

          maxrarity = math.max(maxrarity, quality)
          maxwidth = math.max(maxwidth, slot.name:GetStringWidth())

          slot:SetID(id)
          if slot.SetSlot then
            slot:SetSlot(id)
          end

          slot:Enable()
          slot:Show()
          slotid = slotid + 1
        end

        for i=real+1, GetNumLootItems() do
          if pfUI.loot.slots[i] then
            pfUI.loot.slots[i]:Hide()
          end
        end
      end

      local color = ITEM_QUALITY_COLORS[maxrarity]
      if maxrarity <= 1 then
        CreateBackdrop(pfUI.loot)
        CreateBackdropShadow(pfUI.loot)
      else
        CreateBackdrop(pfUI.loot)
        CreateBackdropShadow(pfUI.loot)
        pfUI.loot.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
      end
      pfUI.loot:SetHeight(math.max((real*22)+4*border), 20)
      pfUI.loot:SetWidth(maxwidth + 22 + 8*border)
    end
  end

  local function AutoBind(arg1)
  end

  local function CloseOnClick()
    local lootbind = StaticPopup_FindVisible("LOOT_BIND")
    local masterloot = UIDROPDOWNMENU_INIT_MENU and (UIDROPDOWNMENU_INIT_MENU == "GroupLootDropDown")
    if lootbind or masterloot then else CloseLoot() end
  end

  function pfUI.loot:CreateSlot(id)
    local frame = CreateFrame(LOOT_BUTTON_FRAME_TYPE, 'pfLootButton'..id, pfUI.loot)
    frame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
    frame:SetPoint("LEFT", border*2, 0)
    frame:SetPoint("RIGHT", -border*2, 0)
    frame:SetHeight(22)
    frame:SetPoint("TOP", pfUI.loot, "TOP", 4, (-border*2+22)-(id*22))

    frame:SetScript("OnClick", function()
      if IsControlKeyDown() then
        DressUpItemLink(GetLootSlotLink(this:GetID()))
      elseif IsShiftKeyDown() then
        if ChatEdit_InsertLink then
          ChatEdit_InsertLink(GetLootSlotLink(this:GetID()))
        elseif ChatFrameEditBox:IsVisible() then
          ChatFrameEditBox:Insert(GetLootSlotLink(this:GetID()))
        end
      end

      StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
      local numItems = GetNumLootItems()
      pfUI.loot.selectedLootButton = this:GetName()
      pfUI.loot.selectedSlot = this:GetID()
      pfUI.loot.selectedQuality = this.quality
      pfUI.loot.selectedItemName = this.name:GetText()
      LootFrame.selectedSlot = pfUI.loot.selectedSlot
      LootFrame.selectedQuality = pfUI.loot.selectedQuality
      LootFrame.selectedItemName = pfUI.loot.selectedItemName

      LootSlot(this:GetID())
      -- workaround for bugged disenchant / container loot on some servers
      if numItems == 1 then
        QueueFunction(CloseOnClick)
      end
    end)

    frame:SetScript("OnEnter", function()
      if ( LootSlotIsItem(this:GetID()) ) then
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:SetLootItem(this:GetID())
        CursorUpdate()
      end
      if this.hover then
        this.hover:Show()
      end
    end)

    frame:SetScript("OnLeave", function()
      GameTooltip:Hide()
      ResetCursor()
      if this.hover then
        this.hover:Hide()
      end
    end)

    if C.loot.autoresize == "1" then
      frame:SetScript("OnUpdate", function()
        pfUI.loot:UpdateLootFrame()
      end)
    end

    frame.ficon = CreateFrame("Frame", "pfLootButtonIcon", frame)
    frame.ficon:SetHeight(frame:GetHeight() - 2*border)
    frame.ficon:SetWidth(frame:GetHeight() - 2*border)
    frame.ficon:ClearAllPoints()
    frame.ficon:SetPoint("RIGHT", frame)
    CreateBackdrop(frame.ficon)

    frame.icon = frame.ficon:CreateTexture(nil, "ARTWORK")
    frame.icon:SetTexCoord(.07, .93, .07, .93)
    frame.icon:SetAllPoints(frame.ficon)

    frame.count = frame.ficon:CreateFontString(nil, "OVERLAY")
    frame.count:ClearAllPoints()
    frame.count:SetJustifyH"RIGHT"
    frame.count:SetPoint("BOTTOMRIGHT", frame.ficon, 2, 2)
    frame.count:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
    frame.count:SetText(1)

    frame.name = frame:CreateFontString(nil, "OVERLAY")
    frame.name:SetJustifyH("LEFT")
    frame.name:ClearAllPoints()
    frame.name:SetAllPoints(frame)
    frame.name:SetNonSpaceWrap(true)
    frame.name:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    frame.rarity = frame:CreateTexture(nil, "ARTWORK")
    frame.rarity:SetTexture(pfUI.media["img:bar"])
    frame.rarity:SetPoint("LEFT", frame.ficon, "RIGHT", 0, 0)
    frame.rarity:SetPoint("RIGHT", frame)
    frame.rarity:SetAlpha(.15)
    frame.rarity:SetAllPoints(frame)

    frame.hover = frame:CreateTexture(nil, "ARTWORK")
    frame.hover:SetTexture(pfUI.media["img:bar"])
    frame.hover:SetPoint("LEFT", frame.ficon, "RIGHT", 0, 0)
    frame.hover:SetPoint("RIGHT", frame)
    frame.hover:SetAlpha(.15)
    frame.hover:SetAllPoints(frame)
    frame.hover:Hide()

    pfUI.loot.slots[id] = frame
    return frame
  end

  pfUI.loot:SetScript("OnHide", function()
    StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
    CloseLoot()
  end)

  pfUI.loot:SetScript("OnEvent", function()
    if event == "OPEN_MASTER_LOOT_LIST" then
      ToggleDropDownMenu(1, nil, GroupLootDropDown, pfUI.loot.slots[pfUI.loot.selectedSlot], 0, 0)
    end

    if event == "UPDATE_MASTER_LOOT_LIST" then
      UIDropDownMenu_Refresh(GroupLootDropDown)
    end

    if event == "LOOT_OPENED" then
      ShowUIPanel(this)

      if(not this:IsShown()) then
        CloseLoot(not autoLoot)
      end

      if C.loot.mousecursor == "1" then
        local x, y = GetCursorPosition()
        x = x / this:GetEffectiveScale()
        y = y / this:GetEffectiveScale()

        this:ClearAllPoints()
        this:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)
      end

      pfUI.loot:UpdateLootFrame()
    end

    if event == "LOOT_SLOT_CLEARED" and arg1 then
      if not this:IsShown() then return end
      if not pfUI.loot.slots[arg1] then return end
      pfUI.loot.slots[arg1]:Hide()
    end

    if event == "LOOT_CLOSED" then
      StaticPopup_Hide("LOOT_BIND")
      HideUIPanel(this)
      if DropDownList1:IsShown() then CloseDropDownMenus() end
      for _, v in pairs(this.slots) do
        v:Hide()
      end
    end

    if event == "CHAT_MSG_SYSTEM" then
      -- random rolling, check for our own roll
      if pfUI.loot.randomRolling ~= nil then
        local who, roll, from, to = cmatch(arg1, RANDOM_ROLL_RESULT)
        if (who) and  who == pfUI.loot.me then
          local winner = tonumber(roll)
          GiveMasterLoot(pfUI.loot.selectedSlot, pfUI.loot.randoms[winner])
        end
        pfUI.loot.randomRolling = nil
      end
      -- collecting rolls from raid, discard duplicates and 'cheating'
      if pfUI.loot.monitorRolling ~= nil then
        local who, roll, from, to = cmatch(arg1, RANDOM_ROLL_RESULT)
        if (who) and not pfUI.loot.rollers[who] then
          if tonumber(from)==1 and tonumber(to)==100 then
            if pfUI.loot.name_to_index[who] ~= nil then
              pfUI.loot.rollers[who] = {roll=tonumber(roll),value=pfUI.loot.name_to_index[who]}
            else -- not an eligible candidate for that item
              pfUI.loot.rollers[who] = {roll=tonumber(roll),value="disabled"}
            end
            pfUI.loot.rollers_sorted[table.getn(pfUI.loot.rollers_sorted)+1]={who=who,roll=tonumber(roll),value=pfUI.loot.rollers[who].value}
          end
        end
        table.sort(pfUI.loot.rollers_sorted,function(a,b)
          return a.roll > b.roll
        end)
        QueueFunction(UIDropDownMenu_Refresh,GroupLootDropDown)
      end
    end

    -- auto accept BoP loot in solo mode
    if C.loot.autopickup == "1" and GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
      if event == "LOOT_BIND_CONFIRM" then
        local slot = arg1
        QueueFunction(function()
          if pfUI.client <= 12000 then
            LootSlot(slot)
          elseif pfUI.client <= 20400 then
            ConfirmLootSlot(slot)
          end
          StaticPopup_Hide("LOOT_BIND")
        end)
      elseif event == "LOOT_OPENED" and pfUI.client <= 11200 then
        for i=1,GetNumLootItems() do
          LootSlot(i)
        end
      end
    end
  end)

  LootFrame:UnregisterAllEvents()
  table.insert(UISpecialFrames, "pfLootFrame")

  function _G.GroupLootDropDown_GiveLoot()
    if ( pfUI.loot.selectedQuality >= MASTER_LOOT_THREHOLD ) then
      local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[pfUI.loot.selectedQuality].hex..pfUI.loot.selectedItemName..FONT_COLOR_CODE_CLOSE, this:GetText())
      if ( dialog ) then
        dialog.data = this.value
      end
    else
      GiveMasterLoot(pfUI.loot.selectedSlot, this.value)
    end
    CloseDropDownMenus()
  end

  StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(data)
    GiveMasterLoot(pfUI.loot.selectedSlot, data)
  end
end)
