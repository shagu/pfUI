pfUI:RegisterModule("bags", function ()
  -- overwrite some bag functions
  function OpenAllBags()
    if pfUI.bag.right:IsShown() then
      pfUI.bag.right:Hide()
    else
      pfUI.bag.right:Show()
    end
  end

  function CloseAllBags()
    pfUI.bag.right:Hide()
  end

  function ToggleBackpack()
    if pfUI.bag.right:IsShown() then
      pfUI.bag.right:Hide()
    else
      pfUI.bag.right:Show()
    end
  end

  function OpenBackpack()
    if ( pfUI.bag.right:IsShown() ) then
      ContainerFrame1.backpackWasOpen = 1
      return
    else
      ContainerFrame1.backpackWasOpen = nil
    end

    if ( not ContainerFrame1.backpackWasOpen ) then
      ToggleBackpack()
    end
  end

  function ToggleBag()
    return
  end

  -- hide blizzard's bankframe
  BankFrame:SetScale(0.001)
  BankFrame:SetPoint("TOPLEFT", 0,0)
  BankFrame:SetAlpha(0)

  pfUI.bag = CreateFrame("Frame", "pfUIBag")
  pfUI.bag:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.bag:RegisterEvent("UPDATE_FACTION")
  pfUI.bag:RegisterEvent("BAG_UPDATE")
  pfUI.bag:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
  pfUI.bag:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
  pfUI.bag:RegisterEvent("BAG_UPDATE_COOLDOWN")
  pfUI.bag:RegisterEvent("BAG_CLOSED")
  pfUI.bag:RegisterEvent("BANKFRAME_CLOSED")
  pfUI.bag:RegisterEvent("BANKFRAME_OPENED")
  pfUI.bag:RegisterEvent("ITEM_LOCK_CHANGED")

  pfUI.bag:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_FACTION" then
      pfUI.bag:CreateBags()
      pfUI.bag.right:Hide()

      pfUI.bag:CreateBags("bank")
      pfUI.bag.left:Hide()

      pfUI.bag:CreateBagSlots(pfUI.bag.right)
      pfUI.bag:CreateBagSlots(pfUI.bag.left)
    end

    if event == "BAG_CLOSED" or event == "PLAYERBANKSLOTS_CHANGED" or
       event == "PLAYERBANKBAGSLOTS_CHANGED" or event == "BAG_UPDATE" or
       event == "BANKFRAME_OPENED" or event == "BANKFRAME_CLOSED" then
      pfUI.bag:CheckFullUpdate()
    end

    if event == "BAG_UPDATE_COOLDOWN" then
      for bag=-2, 11 do
        local bagsize = GetContainerNumSlots(bag)
        if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end
        for slot=1, bagsize do
          ContainerFrame_UpdateCooldown(bag, pfUI.bags[bag].slots[slot].frame)
        end
      end
    end

    if event == "ITEM_LOCK_CHANGED" then
      for bag=-2, 11 do
        local bagsize = GetContainerNumSlots(bag)
        if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end
        for slot=1, bagsize do
          if pfUI.bags[bag].slots[slot].frame:IsShown() then
            local _, _, locked, _ = GetContainerItemInfo(bag, slot)
            SetItemButtonDesaturated(pfUI.bags[bag].slots[slot].frame, locked, 0.5, 0.5, 0.5)
          end
        end
      end
    end

    if event == "BAG_UPDATE" then
      pfUI.bag:UpdateBag(arg1)
    end

    if event == "PLAYERBANKBAGSLOTS_CHANGED" then
      pfUI.bag:CreateBagSlots(pfUI.bag.left)
    end

    if event == "BANKFRAME_OPENED" then
      pfUI.bag.left:Show()
      OpenBackpack()
    end

    if event == "BANKFRAME_CLOSED" then
      pfUI.bag.left:Hide()
    end
  end)

  tinsert(UISpecialFrames,"pfBag")

  pfUI.BACKPACK = { -2, 0, 1, 2, 3, 4 }
  pfUI.BANK = { -1, 5, 6, 7, 8, 9, 10, 11 }

  pfUI.bags = {}
  pfUI.slots = {}

  function pfUI.bag:CheckFullUpdate()
    local maxslots = 0

    for bag = -2,11 do
      local bagsize = GetContainerNumSlots(bag)
      if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end

      maxslots = maxslots + bagsize
    end

    if maxslots ~= pfUI.bag.maxslots then
      for bag = -2,11 do
        for slot, f in ipairs(pfUI.bags[bag].slots) do
          local bagsize = GetContainerNumSlots(bag)
          if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end

          if slot > bagsize then
            pfUI.bags[bag].slots[slot].frame:Hide()
          end
        end
      end

      pfUI.bag:CreateBags()
      pfUI.bag:CreateBags("bank")
      pfUI.bag.maxslots = maxslots
    end
  end

  function pfUI.bag:BrushButton(parent)
    local button = CreateFrame('Button', nil, parent)
    button:SetWidth(28)
    button:SetHeight(26)
    button:SetNormalTexture[[Interface\AddOns\pfUI\img\Bags]]
    button:GetNormalTexture():SetTexCoord(.12109375, .23046875, .7265625, .9296875)
    button:SetPushedTexture[[Interface\AddOns\pfUI\img\Bags]]
    button:GetPushedTexture():SetTexCoord(.00390625, .11328125, .7265625, .9296875)
    button:SetHighlightTexture[[Interface\Buttons\ButtonHilight-Square]]
    button:GetHighlightTexture():ClearAllPoints()
    button:GetHighlightTexture():SetPoint('CENTER', 0, 0)
    button:GetHighlightTexture():SetWidth(24)
    button:GetHighlightTexture():SetHeight(23)
    return button
  end

  function pfUI.bag:CreateBags(object)
    local x = 0
    local y = 0
    local frame = {}
    local iterate = {}

    if object == "bank" then
      if not pfUI.bag.left then pfUI.bag.left = CreateFrame("Frame", "pfBank", nil) end
      pfUI.bag.left:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMLEFT", 0, 0)
      pfUI.bag.left:SetPoint("BOTTOMRIGHT", pfUI.chat.left, "BOTTOMRIGHT", 0, 0)
      pfUI.bag.left:EnableMouse(1)
      iterate = pfUI.BANK
      frame = pfUI.bag.left
    else
      if not pfUI.bag.right then pfUI.bag.right = CreateFrame("Frame", "pfBag", nil) end
      pfUI.bag.right:SetPoint("BOTTOMLEFT", pfUI.chat.right, "BOTTOMLEFT", 0, 0)
      pfUI.bag.right:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 0)
      pfUI.bag.right:EnableMouse(1)
      iterate = pfUI.BACKPACK
      frame = pfUI.bag.right
      pfUI.bag:CreateAdditions(frame)
    end

    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop(pfUI.backdrop)

    pfUI.bag.button_size = (frame:GetWidth() - pfUI_config.bars.border*3) / 10 - pfUI_config.bars.border

    local topspace = 18
    if object == "bank" then topspace = 0 end

    for id, bag in pairs(iterate) do
      if not pfUI.bags[bag] then
        pfUI.bags[bag] = CreateFrame("Frame", "pfBag" .. bag,  frame)
        pfUI.bags[bag]:SetAllPoints(frame)
        pfUI.bags[bag].slots = {}
      end
      pfUI.bags[bag]:SetID(bag)
      local bagsize = GetContainerNumSlots(bag)
      if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end
      for slot=1, bagsize do
        pfUI.bag:UpdateSlot(bag, slot)

        pfUI.bags[bag].slots[slot].frame:ClearAllPoints()
        pfUI.bags[bag].slots[slot].frame:SetPoint("TOPLEFT", x*(pfUI.bag.button_size+pfUI_config.bars.border) + (pfUI_config.bars.border * 2), - (y*(pfUI.bag.button_size+pfUI_config.bars.border) + (pfUI_config.bars.border * 2)+ topspace))
        pfUI.bags[bag].slots[slot].frame:SetHeight(pfUI.bag.button_size)
        pfUI.bags[bag].slots[slot].frame:SetWidth(pfUI.bag.button_size)

        if x >= 9 then
          y = y + 1
          x = 0
        else
          x = x + 1
        end
      end
    end

    if x > 0 then y = y + 1 end
    frame:SetHeight( y * pfUI.bag.button_size + y * pfUI_config.bars.border + pfUI_config.bars.border*3 + 17 + topspace )

    frame:SetScript("OnShow", function() pfUI.bag:CreateBags(object) end)
    frame:SetScript("OnHide", function() pfUI.bag:CreateBags(object) end)
  end

  function pfUI.bag:UpdateBag(bag)
    local bagsize = GetContainerNumSlots(bag)
    if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end
    for slot=1, bagsize do
      pfUI.bag:UpdateSlot(bag, slot)
    end
  end

  function pfUI.bag:UpdateSlot(bag, slot)
    if not pfUI.bags[bag] then return end

    if not pfUI.bags[bag].slots[slot] then
      local tpl = "ContainerFrameItemButtonTemplate"
      if bag == -1 then tpl = "BankItemButtonGenericTemplate" end
      pfUI.bags[bag].slots[slot] = {}
      pfUI.bags[bag].slots[slot].frame = CreateFrame("Button", "pfBag" .. bag .. "item" .. slot,  pfUI.bags[bag], tpl)
      pfUI.bags[bag].slots[slot].frame:SetBackdrop(pfUI.backdrop_col)
      pfUI.bags[bag].slots[slot].frame:SetNormalTexture("")

      pfUI.bags[bag].slots[slot].bag = bag
      pfUI.bags[bag].slots[slot].slot = slot
      pfUI.bags[bag].slots[slot].frame:SetID(slot)
    end

    local texture, count, locked, quality = GetContainerItemInfo(bag, slot)
    SetItemButtonTexture(pfUI.bags[bag].slots[slot].frame, texture)
    SetItemButtonCount(pfUI.bags[bag].slots[slot].frame, count)
    SetItemButtonDesaturated(pfUI.bags[bag].slots[slot].frame, locked, 0.5, 0.5, 0.5)

    -- bankframe does not support cooldowns
    if bag ~= -1 then
      ContainerFrame_UpdateCooldown(bag, pfUI.bags[bag].slots[slot].frame)
    end

    local count = getglobal(pfUI.bags[bag].slots[slot].frame:GetName() .. "Count")
    count:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", pfUI_config.global.font_size, "OUTLINE")
    count:SetAllPoints()
    count:SetJustifyH("RIGHT")
    count:SetJustifyV("BOTTOM")

    local icon = getglobal(pfUI.bags[bag].slots[slot].frame:GetName() .. "IconTexture")
    icon:SetTexCoord(.08, .92, .08, .92)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", 3, -3)
    icon:SetPoint("BOTTOMRIGHT", -3, 3)

    local border = getglobal(pfUI.bags[bag].slots[slot].frame:GetName() .. "NormalTexture")
    border:SetTexture("")

    -- detect backdrop border color
    if quality and quality > 1 then
      pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(GetItemQualityColor(quality))
    else
      local bagtype
      if bag > 0 then
        local _, _, id = strfind(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)) or "", "item:(%d+)");
        if id then
          local _, _, _, _, itemType, subType = GetItemInfo(id);
          bagtype = pfLocaleBagtypes[pfUI.cache["locale"]][itemType]
          bagsubtype = pfLocaleBagtypes[pfUI.cache["locale"]][subType]

          if bagsubtype == "SOULBAG" then
            bagtype = "SOULBAG"
          elseif not (bagsubtype and bagsubtype == "DEFAULT") and bagtype ~= "QUIVER" and bagtype ~= "SOULBAG" then
            bagtype = "SPECIAL"
          end
        end
      end

      if bagtype == "QUIVER" then
        pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(.8,.8,.2,1)
      elseif bagtype == "SOULBAG" then
        pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(.5,.2,.2,1)
      elseif bagtype == "SPECIAL" then
        pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(.2,.2,.8,1)
      elseif bag == -2 then
        pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(.2,.8,.8,1)
      else
        pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(.3,.3,.3,1)
      end
    end

    pfUI.bags[bag].slots[slot].frame:Show()
  end

  function pfUI.bag:CreateBagSlots(frame)
    if not frame.bagslots then
      frame.bagslots = CreateFrame("Frame", "pfBagSlots", frame)
      frame.bagslots.slots = {}
      frame.bagslots:Hide()
    end

    local min, max = 0, 3
    local tpl = "BagSlotButtonTemplate"
    local name, append = "pfUIBagsBBag", "Slot"
    local position = "RIGHT"

    if frame == pfUI.bag.left then
      min, max = 1, GetNumBankSlots()
      tpl = "BankItemButtonBagTemplate"
      name, append = "pfUIBankBBag", ""
      position = "LEFT"
    end

    frame.bagslots:SetPoint("BOTTOM"..position, frame, "TOP"..position, 0, pfUI_config.bars.border)
    frame.bagslots:SetBackdrop(pfUI.backdrop)

    local extra = 0
    if frame == pfUI.bag.left and GetNumBankSlots() < 6 then extra = 1 end
    local width = 3 * pfUI_config.bars.border + (pfUI.bag.button_size/5*4 + pfUI_config.bars.border) * (max-min+1+extra)
    local height = 3 * pfUI_config.bars.border + (pfUI.bag.button_size/5*4 + pfUI_config.bars.border)

    frame.bagslots:SetWidth(width)
    frame.bagslots:SetHeight(height)

    for slot=min, max do
      if not frame.bagslots.slots[slot] then
        frame.bagslots.slots[slot] = {}
        frame.bagslots.slots[slot].frame = CreateFrame("CheckButton", name .. slot .. append, frame.bagslots, tpl)

        local icon = getglobal(frame.bagslots.slots[slot].frame:GetName() .. "IconTexture")
        local border = getglobal(frame.bagslots.slots[slot].frame:GetName() .. "NormalTexture")
        icon:SetTexCoord(.08, .92, .08, .92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 3, -3)
        icon:SetPoint("BOTTOMRIGHT", -3, 3)
        border:SetTexture("")

        if frame == pfUI.bag.left then
          frame.bagslots.slots[slot].frame:SetID(slot + 4)
        else
          frame.bagslots.slots[slot].slot = slot
        end
      end

      local left = (slot-min)*(pfUI.bag.button_size/5*4+pfUI_config.bars.border) + pfUI_config.bars.border*2
      local top = -2 * pfUI_config.bars.border

      frame.bagslots.slots[slot].frame:ClearAllPoints()
      frame.bagslots.slots[slot].frame:SetPoint("TOPLEFT", frame.bagslots, "TOPLEFT", left, top)
      frame.bagslots.slots[slot].frame:SetHeight(pfUI.bag.button_size/5*4)
      frame.bagslots.slots[slot].frame:SetWidth(pfUI.bag.button_size/5*4)

      local id, texture = GetInventorySlotInfo("Bag" .. slot .. append)
      frame.bagslots.slots[slot].frame:SetBackdrop(pfUI.backdrop)
      frame.bagslots.slots[slot].frame:Show()

      local numSlots, full = GetNumBankSlots()
      if ( slot <= numSlots ) then
        frame.bagslots.slots[slot].frame.tooltipText = BANK_BAG
      else
        frame.bagslots.slots[slot].frame.tooltipText = BANK_BAG_PURCHASE
      end
    end

    if frame == pfUI.bag.left then
      if GetNumBankSlots() < 6 then
        if not frame.bagslots.buy then
          frame.bagslots.buy = CreateFrame("Button", "pfBagSlotBuy", frame.bagslots)
        end
        frame.bagslots.buy:SetPoint("RIGHT", frame.bagslots, "RIGHT", -2 * pfUI_config.bars.border, 0)
        frame.bagslots.buy:SetBackdrop(pfUI.backdrop)
        frame.bagslots.buy:SetHeight(pfUI.bag.button_size/5*4)
        frame.bagslots.buy:SetWidth(pfUI.bag.button_size/5*4)
        frame.bagslots.buy:SetText("+")
        frame.bagslots.buy:SetTextColor(.5,.5,1,1)
        frame.bagslots.buy:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
        frame.bagslots.buy:SetScript("OnEnter", function ()
          frame.bagslots.buy:SetTextColor(1,1,1,1)
        end)
        frame.bagslots.buy:SetScript("OnLeave", function ()
          frame.bagslots.buy:SetTextColor(.5,.5,1,1)
        end)
        frame.bagslots.buy:SetScript("OnClick", function()
         StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
        end)
      else
        if frame.bagslots.buy then frame.bagslots.buy:Hide() end
      end
    end
  end

  function pfUI.bag:CreateAdditions(frame)
    -- bag money display
    if not frame.money then
      frame.money = CreateFrame("Frame", "pfUIBagsMoney", frame, "SmallMoneyFrameTemplate")
      frame.money:ClearAllPoints()
      frame.money:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -62, -6)

      pfUIBagsMoneyGoldButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      for i,v in ipairs({pfUIBagsMoneyGoldButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
      pfUIBagsMoneySilverButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      for i,v in ipairs({pfUIBagsMoneySilverButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
      pfUIBagsMoneyCopperButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      for i,v in ipairs({pfUIBagsMoneyCopperButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
    end

    if not frame.sort then
      frame.sort = pfUI.bag:BrushButton(frame)
      frame.sort:SetScale(.7)
      frame.sort:SetPoint('TOPRIGHT', -73, -5)
      frame.sort:SetScript('OnClick', function()
        PlaySoundFile[[Interface\AddOns\pfUI\UI_BagSorting_01.ogg]]
        Clean_Up'bags'
      end)
      frame.sort:SetScript('OnEnter', function()
        GameTooltip:SetOwner(this)
        GameTooltip:AddLine('Clean Up Bags')
        GameTooltip:Show()
      end)
      frame.sort:SetScript('OnLeave', function()
        GameTooltip:Hide()
      end)
    end

    -- bag close button
    if not frame.close then
      frame.close = CreateFrame("Button", "pfBagClose", UIParent)
      frame.close:SetParent(frame)
      frame.close:SetPoint("TOPRIGHT", -pfUI_config.bars.border*2,-pfUI_config.bars.border*2 )
      frame.close:SetBackdrop(pfUI.backdrop)
      frame.close:SetHeight(15)
      frame.close:SetWidth(15)
      frame.close.texture = frame.close:CreateTexture("pfBagClose")
      frame.close.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
      frame.close.texture:ClearAllPoints()
      frame.close.texture:SetPoint("TOPLEFT", frame.close, "TOPLEFT", 4, -4)
      frame.close.texture:SetPoint("BOTTOMRIGHT", frame.close, "BOTTOMRIGHT", -4, 4)
      frame.close.texture:SetVertexColor(1,.25,.25,1)
      frame.close:SetScript("OnEnter", function ()
          frame.close:SetBackdrop(pfUI.backdrop_col)
          frame.close:SetBackdropBorderColor(1,.25,.25,1)
        end)

      frame.close:SetScript("OnLeave", function ()
          frame.close:SetBackdrop(pfUI.backdrop)
          frame.close:SetBackdropBorderColor(1,1,1,1)
        end)

     frame.close:SetScript("OnClick", function()
       CloseAllBags()
      end)
    end

    -- bags button
    if not frame.bags then
      frame.bags = CreateFrame("Button", "pfBagSlotShow", UIParent)
      frame.bags:SetParent(frame)
      frame.bags:SetPoint("TOPRIGHT", -pfUI_config.bars.border*2 - 15 , -pfUI_config.bars.border*2 )
      frame.bags:SetBackdrop(pfUI.backdrop)
      frame.bags:SetHeight(15)
      frame.bags:SetWidth(15)
      frame.bags:SetTextColor(1,1,.25,1)
      frame.bags:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      frame.bags.texture = frame.bags:CreateTexture("pfBagArrowUp")
      frame.bags.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\up")
      frame.bags.texture:ClearAllPoints()
      frame.bags.texture:SetPoint("TOPLEFT", frame.bags, "TOPLEFT", 5, -3)
      frame.bags.texture:SetPoint("BOTTOMRIGHT", frame.bags, "BOTTOMRIGHT", -5, 3)
      frame.bags.texture:SetVertexColor(.25,.25,.25,1)

      frame.bags:SetScript("OnEnter", function ()
          frame.bags:SetBackdrop(pfUI.backdrop_col)
          frame.bags:SetBackdropBorderColor(1,1,.25,1)
          frame.bags.texture:SetVertexColor(1,1,.25,1)
        end)

      frame.bags:SetScript("OnLeave", function ()
          frame.bags:SetBackdrop(pfUI.backdrop)
          frame.bags:SetBackdropBorderColor(1,1,1,1)
          frame.bags.texture:SetVertexColor(.25,.25,.25,1)
        end)

      frame.bags:SetScript("OnClick", function()
        if pfUI.bag.right.bagslots:IsShown() then
          pfUI.bag.right.bagslots:Hide()
          pfUI.bag.left.bagslots:Hide()
        else
          pfUI.bag.left.bagslots:Show()
          pfUI.bag.right.bagslots:Show()
        end
      end)
    end

    -- key button
    if not frame.keys then
      frame.keys = CreateFrame("Button", "pfBagSlotShow", UIParent)
      frame.keys:SetParent(frame)
      frame.keys:SetPoint("TOPRIGHT", -pfUI_config.bars.border*2 - 30 , -pfUI_config.bars.border*2 )
      frame.keys:SetBackdrop(pfUI.backdrop)
      frame.keys:SetHeight(15)
      frame.keys:SetWidth(15)
      frame.keys:SetTextColor(1,1,.25,1)
      frame.keys:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      frame.keys.texture = frame.keys:CreateTexture("pfBagArrowUp")
      frame.keys.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\key")
      frame.keys.texture:ClearAllPoints()
      frame.keys.texture:SetPoint("TOPLEFT", frame.keys, "TOPLEFT", 5, -3)
      frame.keys.texture:SetPoint("BOTTOMRIGHT", frame.keys, "BOTTOMRIGHT", -5, 3)
      frame.keys.texture:SetVertexColor(.25,.25,.25,1)

      frame.keys:SetScript("OnEnter", function ()
          frame.keys:SetBackdrop(pfUI.backdrop_col)
          frame.keys:SetBackdropBorderColor(1,1,.25,1)
          frame.keys.texture:SetVertexColor(1,1,.25,1)
        end)

      frame.keys:SetScript("OnLeave", function ()
          frame.keys:SetBackdrop(pfUI.backdrop)
          frame.keys:SetBackdropBorderColor(1,1,1,1)
          frame.keys.texture:SetVertexColor(.25,.25,.25,1)
        end)

      frame.keys:SetScript("OnClick", function()
        if not pfUI.bag.showKeyring then
          pfUI.bag.showKeyring = true
        else
          pfUI.bag.showKeyring = nil
        end
        pfUI.bag:CheckFullUpdate()
      end)
    end

    -- bag search
    if not frame.search then
      frame.search = CreateFrame("Frame", "pfBagSearch", UIParent)
      frame.search:SetParent(frame)
      frame.search:SetHeight(15)
      frame.search:SetWidth(100)
      frame.search:SetPoint("TOPLEFT", frame, "TOPLEFT", pfUI_config.bars.border*2, -pfUI_config.bars.border*2)
      frame.search:SetBackdrop(pfUI.backdrop)
      frame.search:SetBackdropBorderColor(0,0,0,1)

      frame.search.edit = CreateFrame("EditBox", "pfUIBagSearch", frame.search, "InputBoxTemplate")
      pfUIBagSearchLeft:SetTexture(nil)
      pfUIBagSearchMiddle:SetTexture(nil)
      pfUIBagSearchRight:SetTexture(nil)
      frame.search.edit:ClearAllPoints()
      frame.search.edit:SetPoint("TOPLEFT", frame.search, "TOPLEFT", pfUI_config.bars.border*2, 0)
      frame.search.edit:SetPoint("BOTTOMRIGHT", frame.search, "BOTTOMRIGHT", -pfUI_config.bars.border*2, 0)

      frame.search.edit:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      frame.search.edit:SetAutoFocus(false)
      frame.search.edit:SetText("Search")
      frame.search.edit:SetTextColor(.5,.5,.5,1)

      frame.search.edit:SetScript("OnEditFocusGained", function()
        this:SetText("")
      end)

      frame.search.edit:SetScript("OnEditFocusLost", function()
        this:SetText("Search")
        for bag=-2, 11 do
          local bagsize = GetContainerNumSlots(bag)
          if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end
          for slot=1, bagsize do
            local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
            if itemCount then
              pfUI.bags[bag].slots[slot].frame:SetAlpha(1)
            end
          end
        end
      end)

      frame.search.edit:SetScript("OnTextChanged", function()
        if this:GetText() == "Search" then return end
        for bag=-2, 11 do
          local bagsize = GetContainerNumSlots(bag)
          if bag == -2 and pfUI.bag.showKeyring == true then bagsize = GetKeyRingSize() end
          for slot=1, bagsize do
            local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
            if itemCount then
              local itemLink = GetContainerItemLink(bag, slot)
              local itemstring = string.sub(itemLink, string.find(itemLink, "%[")+1, string.find(itemLink, "%]")-1)
              if strfind(strlower(itemstring), strlower(this:GetText())) then
                pfUI.bags[bag].slots[slot].frame:SetAlpha(1)
              else
                pfUI.bags[bag].slots[slot].frame:SetAlpha(.25)
              end
            end
          end
        end
      end)
    end
  end
end)
