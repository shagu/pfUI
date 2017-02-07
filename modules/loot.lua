pfUI:RegisterModule("loot", function ()
  pfUI.loot = CreateFrame("Frame", "pfLootFrame", UIParent)
  pfUI.loot:Hide()
  pfUI.loot:SetFrameStrata("DIALOG")
  pfUI.loot:RegisterEvent("LOOT_OPENED")
  pfUI.loot:RegisterEvent("LOOT_CLOSED")
  pfUI.loot:RegisterEvent("LOOT_SLOT_CLEARED")
  pfUI.loot:RegisterEvent("OPEN_MASTER_LOOT_LIST")
  pfUI.loot:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

  pfUI.loot:SetWidth(160+pfUI_config.appearance.border.default*2)
  pfUI.loot.slots = {}
  function pfUI.loot:UpdateLootFrame()
    local maxrarity, maxwidth = 0, 0

    local items = GetNumLootItems()
    if(items > 0) then
      local real = 0
      for i=1, items do
        local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
        if texture then real = real + 1 end
      end

      local slotid = 1
      for id=0 ,GetNumLootItems() do
        if GetLootSlotInfo(id) then
          local slot = pfUI.loot.slots[slotid] or pfUI.loot:CreateSlot(slotid)
          local texture, item, quantity, quality, locked = GetLootSlotInfo(id)
          local color = ITEM_QUALITY_COLORS[quality]

          if(LootSlotIsCoin(id)) then
            item = string.gsub(item,"\n", ", ")
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
          slot:SetSlot(id)

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
        pfUI.api:CreateBackdrop(pfUI.loot)
      else
        pfUI.api:CreateBackdrop(pfUI.loot)
        pfUI.loot.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, 1)
      end
      pfUI.loot:SetHeight(math.max((real*22)+4*pfUI_config.appearance.border.default), 20)
      pfUI.loot:SetWidth(maxwidth + 22 + 8*pfUI_config.appearance.border.default )
    end
  end

  function pfUI.loot:CreateSlot(id)
    local frame = CreateFrame("LootButton", 'pfLootButton'..id, pfUI.loot)
    frame:SetPoint("LEFT", pfUI_config.appearance.border.default*2, 0)
    frame:SetPoint("RIGHT", -pfUI_config.appearance.border.default*2, 0)
    frame:SetHeight(22)
    frame:SetPoint("TOP", pfUI.loot, "TOP", 4, (-pfUI_config.appearance.border.default*2+22)-(id*22))

    frame:SetScript("OnClick", function()
      if ( IsControlKeyDown() ) then
        DressUpItemLink(GetLootSlotLink(this:GetID()))
      elseif ( IsShiftKeyDown() ) then
        if ( ChatFrameEditBox:IsVisible() ) then
          ChatFrameEditBox:Insert(GetLootSlotLink(this:GetID()))
        end
      end

      StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")

      pfUI.loot.selectedLootButton = this:GetName()
      pfUI.loot.selectedSlot = this:GetID()
      pfUI.loot.selectedQuality = this.quality
      pfUI.loot.selectedItemName = this.name:GetText()
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

    if pfUI_config.appearance.loot.autoresize == "1" then
      frame:SetScript("OnUpdate", function()
        pfUI.loot:UpdateLootFrame()
      end)
    end

    frame.ficon = CreateFrame("Frame", "pfLootButtonIcon", frame)
    frame.ficon:SetHeight(frame:GetHeight() - 2*pfUI_config.appearance.border.default)
    frame.ficon:SetWidth(frame:GetHeight() - 2*pfUI_config.appearance.border.default)
    frame.ficon:ClearAllPoints()
    frame.ficon:SetPoint("RIGHT", frame)
    pfUI.api:CreateBackdrop(frame.ficon)

    frame.icon = frame.ficon:CreateTexture(nil, "ARTWORK")
    frame.icon:SetTexCoord(.07, .93, .07, .93)
    frame.icon:SetAllPoints(frame.ficon)

    frame.count = frame.ficon:CreateFontString(nil, "OVERLAY")
    frame.count:ClearAllPoints()
    frame.count:SetJustifyH"RIGHT"
    frame.count:SetPoint("BOTTOMRIGHT", frame.ficon, 2, 2)
    frame.count:SetFont(pfUI.font_default, pfUI_config.global.font_size, STANDARD_TEXT_FONT_FLAGS)
    frame.count:SetText(1)

    frame.name = frame:CreateFontString(nil, "OVERLAY")
    frame.name:SetJustifyH("LEFT")
    frame.name:ClearAllPoints()
    frame.name:SetAllPoints(frame)
    frame.name:SetNonSpaceWrap(true)
    frame.name:SetFont(pfUI.font_default, pfUI_config.global.font_size, STANDARD_TEXT_FONT_FLAGS)

    frame.rarity = frame:CreateTexture(nil, "ARTWORK")
    frame.rarity:SetTexture"Interface\\AddOns\\pfUI\\img\\bar"
    frame.rarity:SetPoint("LEFT", frame.ficon, "RIGHT", 0, 0)
    frame.rarity:SetPoint("RIGHT", frame)
    frame.rarity:SetAlpha(.15)
    frame.rarity:SetAllPoints(frame)

    frame.hover = frame:CreateTexture(nil, "ARTWORK")
    frame.hover:SetTexture"Interface\\AddOns\\pfUI\\img\\bar"
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

      local x, y = GetCursorPosition()
      x = x / this:GetEffectiveScale()
      y = y / this:GetEffectiveScale()

      this:ClearAllPoints()
      this:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)

      pfUI.loot:UpdateLootFrame()
    end

    if event == "LOOT_SLOT_CLEARED" then
      if(not this:IsShown()) then return end
      pfUI.loot.slots[arg1]:Hide()
    end

    if event == "LOOT_CLOSED" then
      StaticPopup_Hide("LOOT_BIND")
      HideUIPanel(this)
      for _, v in pairs(this.slots) do
        v:Hide()
      end
    end
  end)

  LootFrame:UnregisterAllEvents()
  table.insert(UISpecialFrames, "pfLootFrame")

  function GroupLootDropDown_GiveLoot()
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
