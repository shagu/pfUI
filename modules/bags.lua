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

  -- avoid vertexcolor updates on item buttons
  function SetItemButtonNormalTextureVertexColor() return end

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

  pfUI.bag.updater = CreateFrame("Frame", "pfBagUpdater", UIParent)
  pfUI.bag.updater.lastUpdate = 0
  pfUI.bag.updater.updateInterval = .5

  function pfUI.bag.updater:ResetDelay()
    pfUI.bag.updater.lastUpdate = 0
    pfUI.bag.updater.updateInterval = .5
    pfUI.bag.updater:Show()
  end

  pfUI.bag.updater:SetScript("OnUpdate", function()
    if pfUI.bag.updater.lastUpdate + pfUI.bag.updater.updateInterval < GetTime() then
      pfUI.buff:UpdateSkin()
      pfUI.bag.updater.lastUpdate  = GetTime()
      pfUI.bag.updater.updateInterval  =   pfUI.bag.updater.updateInterval +  pfUI.bag.updater.updateInterval

      pfUI.bag:CreateBags()
      pfUI.bag:CreateBags("bank")
    end

    if pfUI.bag.updater.updateInterval  > 3 then
      pfUI.bag.updater:Hide()
    end
  end)

  pfUI.bag:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_FACTION" then
      pfUI.bag:CreateBags()
      pfUI.bag.right:Hide()

      pfUI.bag:CreateBags("bank")
      pfUI.bag.left:Hide()

      pfUI.bag:CreateBagSlots(pfUI.bag.right)
      pfUI.bag:CreateBagSlots(pfUI.bag.left)
    end

    if event == "BAG_UPDATE" and arg1 then
      if pfUI.bag.nextUpdateIsFull then
        pfUI.bag:CreateBags()
        pfUI.bag:CreateBags("bank")
        pfUI.bag.nextUpdateIsFull = nil
      else
        pfUI.bag:UpdateBag(arg1)
      end
    end

    if event == "BAG_UPDATE_COOLDOWN" then
      pfUI.bag:CreateBags()
      pfUI.bag:CreateBags("bank")
    end

    if event == "BAG_CLOSED" and arg1 then
      pfUI.bag.updater:ResetDelay()
    end

    if event == "PLAYERBANKSLOTS_CHANGED" then
      pfUI.bag:UpdateBag(-1)
    end

    if event == "PLAYERBANKBAGSLOTS_CHANGED" then
      pfUI.bag:CreateBagSlots(pfUI.bag.left)
      pfUI.bag.left.bagslots:Show()
    end

    if event == "BANKFRAME_OPENED" then
      pfUI.bag:CreateBags("bank")
      pfUI.bag.left:Show()
      OpenBackpack()
    end

    if event == "BANKFRAME_CLOSED" then
      pfUI.bag:CreateBags("bank")
      pfUI.bag.left:Hide()
    end

    if event == "ITEM_LOCK_CHANGED" then
      for bag=-2, 11 do
        for slot=1, GetContainerNumSlots(bag) do
          if pfUI.bags[bag].slots[slot].frame:IsShown() then
            local _, _, locked, _ = GetContainerItemInfo(bag, slot)
            if locked then
              pfUI.bags[bag].slots[slot].frame:SetAlpha(.5)
            else
              pfUI.bags[bag].slots[slot].frame:SetAlpha(1)
            end
          end
        end
      end
    end
  end)

  tinsert(UISpecialFrames,"pfBag")

  pfUI.BACKPACK = { 0, 1, 2, 3, 4 }
  pfUI.BANK = { -1, 5, 6, 7, 8, 9, 10, 11 }
  pfUI.KEYRING = { -2 }

  pfUI.bags = {}
  pfUI.slots = {}

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

      -- clean other buttons
      for slot=GetContainerNumSlots(bag), 30 do
        if pfUI.bags[bag].slots[slot] then
          pfUI.bags[bag].slots[slot].frame:Hide()
          pfUI.bags[bag].slots[slot] = nil
        end
      end

      for slot=1, GetContainerNumSlots(bag) do
        if not pfUI.bags[bag].slots[slot] then
	        local tpl = "ContainerFrameItemButtonTemplate"
          if bag == -1 then tpl = "BankItemButtonGenericTemplate" end
          pfUI.bags[bag].slots[slot] = {}
          pfUI.bags[bag].slots[slot].frame = CreateFrame("Button", "pfBag" .. bag .. "item" .. slot,  pfUI.bags[bag], tpl)
          pfUI.bags[bag].slots[slot].bag = bag
          pfUI.bags[bag].slots[slot].slot = slot
          pfUI.bags[bag].slots[slot].frame:SetID(slot)
        end

        pfUI.bags[bag].slots[slot].frame:ClearAllPoints()
        pfUI.bags[bag].slots[slot].frame:SetPoint("TOPLEFT", x*(pfUI.bag.button_size+pfUI_config.bars.border) + (pfUI_config.bars.border * 2), - (y*(pfUI.bag.button_size+pfUI_config.bars.border) + (pfUI_config.bars.border * 2)+ topspace))
        pfUI.bags[bag].slots[slot].frame:SetHeight(pfUI.bag.button_size)
        pfUI.bags[bag].slots[slot].frame:SetWidth(pfUI.bag.button_size)

        pfUI.bag:UpdateSlot(bag, slot)
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
    for slot=1, GetContainerNumSlots(bag) do
      pfUI.bag:UpdateSlot(bag, slot)
    end
  end

  function pfUI.bag:UpdateSlot(bag, slot)
    if not pfUI.bags[bag] or not pfUI.bags[bag].slots[slot] then
      pfUI.bag:CreateBags()
      pfUI.bag:CreateBags("bank")
      return
    end

    pfUI.bags[bag].slots[slot].frame:SetPushedTexture("")
    pfUI.bags[bag].slots[slot].frame:SetNormalTexture("")
    pfUI.bags[bag].slots[slot].frame:Show()

    function SetItemButtonNormalTextureVertexColor() return end

	  local texture, count, locked, quality = GetContainerItemInfo(bag, slot)
    pfUI.bags[bag].slots[slot].frame:SetBackdrop({
      bgFile = texture, tile = true, tileSize = pfUI.bag.button_size,
      edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
      insets = {left = 0, right = 0, top = 0, bottom = 0},
    })

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
      else
        pfUI.bags[bag].slots[slot].frame:SetBackdropBorderColor(.3,.3,.3,1)
      end
    end

    if not pfUI.bags[bag].slots[slot].stacks then
      pfUI.bags[bag].slots[slot].stacks = pfUI.bags[bag].slots[slot].frame:CreateFontString("Status", "DIALOG", "GameFontWhite")
      pfUI.bags[bag].slots[slot].stacks:SetFont("Interface\\AddOns\\pfUI\\fonts\\homespun.ttf", pfUI_config.global.font_size, "OUTLINE")
      pfUI.bags[bag].slots[slot].stacks:SetParent(pfUI.bags[bag].slots[slot].frame)
      pfUI.bags[bag].slots[slot].stacks:SetAllPoints(pfUI.bags[bag].slots[slot].frame)
      pfUI.bags[bag].slots[slot].stacks:SetJustifyV("BOTTOM")
      pfUI.bags[bag].slots[slot].stacks:SetJustifyH("RIGHT")
    end

    if count and count > 1 then
      pfUI.bags[bag].slots[slot].frame.count = count
      pfUI.bags[bag].slots[slot].stacks:SetText(count)
      pfUI.bags[bag].slots[slot].stacks:Show()
    else
      pfUI.bags[bag].slots[slot].frame.count = 0
      pfUI.bags[bag].slots[slot].stacks:SetText("")
      pfUI.bags[bag].slots[slot].stacks:Hide()
    end

    -- hide duplicate itemcount in bankframe
    if bag == -1 then
      local count = getglobal("pfBag" .. bag .. "item" .. slot .. "Count")
      function count.Show() return end
      count:Hide()
    end

    -- bankframe does not have a cooldown
    if bag ~= -1 then
      ContainerFrame_UpdateCooldown(bag, pfUI.bags[bag].slots[slot].frame)
    end
  end

  function pfUI.bag:CreateBagSlots(frame)
    if not frame.bagslots then
      frame.bagslots = CreateFrame("Frame", "pfBagSlots", frame)
      frame.bagslots.slots = {}
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

      local id, texture, checkRelic = GetInventorySlotInfo("Bag" .. slot .. append)
      frame.bagslots.slots[slot].frame:SetBackdrop({
        bgFile = texture, tile = true, tileSize = pfUI.bag.button_size/5*4,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
      })
      frame.bagslots.slots[slot].frame:SetBackdropBorderColor(.3,.3,.3,1)
      frame.bagslots.slots[slot].frame.SetBackdrop = function () return end

      frame.bagslots.slots[slot].frame:SetNormalTexture(nil)
      frame.bagslots.slots[slot].frame:SetPushedTexture(nil)

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
    frame.bagslots:Hide()
  end

  function pfUI.bag:CreateAdditions(frame)
    -- bag money display
    if not frame.money then
      frame.money = CreateFrame("Frame", "pfUIBagsMoney", frame, "SmallMoneyFrameTemplate")
      frame.money:ClearAllPoints()
      frame.money:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -23, -6)

      pfUIBagsMoneyGoldButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      for i,v in ipairs({pfUIBagsMoneyGoldButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
      pfUIBagsMoneySilverButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      for i,v in ipairs({pfUIBagsMoneySilverButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
      pfUIBagsMoneyCopperButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", pfUI_config.global.font_size, "OUTLINE")
      for i,v in ipairs({pfUIBagsMoneyCopperButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
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
        for bag=-1, 11 do
          for slot=1, GetContainerNumSlots(bag) do
            local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag, slot)
            if itemCount then
              pfUI.bags[bag].slots[slot].frame:SetAlpha(1)
            end
          end
        end
      end)

      frame.search.edit:SetScript("OnTextChanged", function()
        if this:GetText() == "Search" then return end
        for bag=-1, 11 do
          for slot=1, GetContainerNumSlots(bag) do
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
