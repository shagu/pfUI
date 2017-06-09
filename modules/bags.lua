pfUI:RegisterModule("bags", function ()
  local default_border = C.appearance.border.default
  if C.appearance.border.bags ~= "-1" then
    default_border = C.appearance.border.bags
  end

  -- overwrite some bag functions
  function _G.OpenAllBags()
    if pfUI.bag.right:IsShown() then
      pfUI.bag.right:Hide()
    else
      pfUI.bag.right:Show()
    end
  end

  function _G.CloseAllBags()
    pfUI.bag.right:Hide()
  end

  function _G.ToggleBackpack()
    if pfUI.bag.right:IsShown() then
      pfUI.bag.right:Hide()
    else
      pfUI.bag.right:Show()
    end
  end

  function _G.OpenBackpack()
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

  function _G.ToggleBag()
    return
  end

  -- hide blizzard's bankframe
  BankFrame:SetScale(0.001)
  BankFrame:SetPoint("TOPLEFT", 0,0)
  BankFrame:SetAlpha(0)

  pfUI.bag = CreateFrame("Frame", "pfUIBag")
  pfUI.bag:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.bag:RegisterEvent("BAG_UPDATE")
  pfUI.bag:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
  pfUI.bag:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
  pfUI.bag:RegisterEvent("BAG_UPDATE_COOLDOWN")
  pfUI.bag:RegisterEvent("BAG_CLOSED")
  pfUI.bag:RegisterEvent("BANKFRAME_CLOSED")
  pfUI.bag:RegisterEvent("BANKFRAME_OPENED")
  pfUI.bag:RegisterEvent("ITEM_LOCK_CHANGED")

  pfUI.bag:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
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
          if pfUI.bags[bag].slots[slot].frame.hasItem then
            if _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "Cooldown"] then
              ContainerFrame_UpdateCooldown(bag, pfUI.bags[bag].slots[slot].frame)
            end
          end
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

    if event == "PLAYERBANKSLOTS_CHANGED" then
      pfUI.bag:UpdateBag(-1)
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

  function pfUI.bag:CreateBags(object)
    local x = 0
    local y = 0
    local frame = {}
    local iterate = {}

    if object == "bank" then
      if not pfUI.bag.left then pfUI.bag.left = CreateFrame("Frame", "pfBank", UIParent) end
      if pfUI.chat then
        pfUI.bag.left:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMLEFT", 0, 0)
        pfUI.bag.left:SetPoint("BOTTOMRIGHT", pfUI.chat.left, "BOTTOMRIGHT", 0, 0)
        pfUI.bag.left:SetWidth(C.chat.left.width * pfUI.chat.left:GetScale())
      else
        pfUI.bag.left:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
        pfUI.bag.left:SetWidth(C.chat.left.width)
      end
      pfUI.bag.left:EnableMouse(1)
      iterate = pfUI.BANK
      frame = pfUI.bag.left
    else
      if not pfUI.bag.right then pfUI.bag.right = CreateFrame("Frame", "pfBag", UIParent) end
      if pfUI.chat then
        pfUI.bag.right:SetPoint("BOTTOMLEFT", pfUI.chat.right, "BOTTOMLEFT", 0, 0)
        pfUI.bag.right:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 0)
        pfUI.bag.right:SetWidth(C.chat.right.width * pfUI.chat.right:GetScale())
      else
        pfUI.bag.right:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 5)
        pfUI.bag.right:SetWidth(C.chat.right.width)
      end
      pfUI.bag.right:EnableMouse(1)
      iterate = pfUI.BACKPACK
      frame = pfUI.bag.right
    end

    pfUI.bag:CreateAdditions(frame)

    frame:SetFrameStrata("HIGH")
    CreateBackdrop(frame, default_border)

    pfUI.bag.button_size = (frame:GetWidth() - 2*default_border - 9*default_border*3)/ 10
    local topspace = pfUI.bag.right.close:GetHeight() + default_border * 2

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
        pfUI.bags[bag].slots[slot].frame:SetPoint("TOPLEFT",
          default_border + x*(pfUI.bag.button_size+default_border*3),
          -default_border*2 - y*(pfUI.bag.button_size+default_border*3) - topspace)
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
    if pfUI.panel then topspace = topspace + pfUI.panel.right:GetHeight() end
    frame:SetHeight( default_border*2 + y*(pfUI.bag.button_size+default_border*3) + topspace)

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
      CreateBackdrop(pfUI.bags[bag].slots[slot].frame, default_border)
      pfUI.bags[bag].slots[slot].frame:SetNormalTexture("")

      pfUI.bags[bag].slots[slot].bag = bag
      pfUI.bags[bag].slots[slot].slot = slot
      pfUI.bags[bag].slots[slot].frame:SetID(slot)
    end

    local texture, count, locked, quality = GetContainerItemInfo(bag, slot)

    -- running advanced item color scan
    if C.appearance.bags.borderonlygear == "0" and texture and quality and quality < 1 then
      local link = GetContainerItemLink(bag, slot)
      if link then
        local _, _, linkstr = string.find(link, "(item:%d+:%d+:%d+:%d+)")
        local n, _, q = GetItemInfo(linkstr)
        if quality then quality = q end
      end
    end

    SetItemButtonTexture(pfUI.bags[bag].slots[slot].frame, texture)
    SetItemButtonCount(pfUI.bags[bag].slots[slot].frame, count)
    SetItemButtonDesaturated(pfUI.bags[bag].slots[slot].frame, locked, 0.5, 0.5, 0.5)

    if texture then
      pfUI.bags[bag].slots[slot].frame.hasItem = 1
    else
      pfUI.bags[bag].slots[slot].frame.hasItem = nil
    end

    -- bankframe does not support cooldowns
    if bag ~= -1 then
      ContainerFrame_UpdateCooldown(bag, pfUI.bags[bag].slots[slot].frame)
    end

    local count = _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "Count"]
    count:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
    count:SetAllPoints()
    count:SetJustifyH("RIGHT")
    count:SetJustifyV("BOTTOM")

    local icon = _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "IconTexture"]
    icon:SetTexCoord(.08, .92, .08, .92)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)

    local border = _G[pfUI.bags[bag].slots[slot].frame:GetName() .. "NormalTexture"]
    border:SetTexture("")

    -- detect backdrop border color
    if quality and quality > tonumber(C.appearance.bags.borderlimit) then
      pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
    else
      local bagtype
      if bag > 0 then
        local _, _, id = strfind(GetInventoryItemLink("player", ContainerIDToInventoryID(bag)) or "", "item:(%d+)")
        if id then
          local _, _, _, _, itemType, subType = GetItemInfo(id)
          bagtype = L["bagtypes"][itemType]
          bagsubtype = L["bagtypes"][subType]

          if bagsubtype == "SOULBAG" then
            bagtype = "SOULBAG"
          elseif not (bagsubtype and bagsubtype == "DEFAULT") and bagtype ~= "QUIVER" and bagtype ~= "SOULBAG" then
            bagtype = "SPECIAL"
          end
        end
      end

      if bagtype == "QUIVER" then
        pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.8,.8,.2,1)
      elseif bagtype == "SOULBAG" then
        pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.5,.2,.2,1)
      elseif bagtype == "SPECIAL" then
        pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.2,.2,.8,1)
      elseif bag == -2 then
        pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.2,.8,.8,1)
      else
        pfUI.bags[bag].slots[slot].frame.backdrop:SetBackdropBorderColor(.3,.3,.3,1)
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

    frame.bagslots:SetPoint("BOTTOM"..position, frame, "TOP"..position, 0, default_border*3)
    CreateBackdrop(frame.bagslots, default_border)

    local extra = 0
    if frame == pfUI.bag.left and GetNumBankSlots() < 6 then extra = 1 end
    local width = (pfUI.bag.button_size/5*4 + default_border*2) * (max-min+1+extra)
    local height = default_border + (pfUI.bag.button_size/5*4 + default_border)

    frame.bagslots:SetWidth(width)
    frame.bagslots:SetHeight(height)

    for slot=min, max do
      if not frame.bagslots.slots[slot] then
        frame.bagslots.slots[slot] = {}
        frame.bagslots.slots[slot].frame = CreateFrame("CheckButton", name .. slot .. append, frame.bagslots, tpl)

        local icon = _G[frame.bagslots.slots[slot].frame:GetName() .. "IconTexture"]
        local border = _G[frame.bagslots.slots[slot].frame:GetName() .. "NormalTexture"]
        icon:SetTexCoord(.08, .92, .08, .92)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
        border:SetTexture("")

        if frame == pfUI.bag.left then
          frame.bagslots.slots[slot].frame:SetID(slot + 4)
          frame.bagslots.slots[slot].frame.slot = slot + 3
        else
          frame.bagslots.slots[slot].frame.slot = slot
          frame.bagslots.slots[slot].slot = slot
        end

        local SlotEnter = frame.bagslots.slots[slot].frame:GetScript("OnEnter")
        frame.bagslots.slots[slot].frame:SetScript("OnEnter", function()
          for slot, f in ipairs(pfUI.bags[this.slot + 1].slots) do
            CreateBackdrop(f.frame, default_border)
            f.frame.backdrop:SetBackdropBorderColor(.2,1,.8,1)
          end
          SlotEnter()
        end)

        local SlotLeave = frame.bagslots.slots[slot].frame:GetScript("OnLeave")
        frame.bagslots.slots[slot].frame:SetScript("OnLeave", function()
          pfUI.bag:UpdateBag(this.slot + 1)
          SlotLeave()
        end)
      end

      local left = (slot-min)*(pfUI.bag.button_size/5*4+default_border*2) + default_border
      local top = -default_border

      frame.bagslots.slots[slot].frame:ClearAllPoints()
      frame.bagslots.slots[slot].frame:SetPoint("TOPLEFT", frame.bagslots, "TOPLEFT", left, top)
      frame.bagslots.slots[slot].frame:SetHeight(pfUI.bag.button_size/5*4)
      frame.bagslots.slots[slot].frame:SetWidth(pfUI.bag.button_size/5*4)

      local id, texture = GetInventorySlotInfo("Bag" .. slot .. append)
      CreateBackdrop(frame.bagslots.slots[slot].frame, default_border)
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
        frame.bagslots.buy:SetPoint("RIGHT", frame.bagslots, "RIGHT", -default_border, 0)
        CreateBackdrop(frame.bagslots.buy, default_border)
        frame.bagslots.buy:SetHeight(pfUI.bag.button_size/5*4)
        frame.bagslots.buy:SetWidth(pfUI.bag.button_size/5*4)
        frame.bagslots.buy:SetText("+")
        frame.bagslots.buy:SetTextColor(.5,.5,1,1)
        frame.bagslots.buy:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
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
    -- bag additions
    if frame == pfUI.bag.right then
      -- bag close button
      if not frame.close then
        frame.close = CreateFrame("Button", "pfBagClose", frame)
        frame.close:SetPoint("TOPRIGHT", -default_border*1,-default_border )
        CreateBackdrop(frame.close, default_border)
        frame.close:SetHeight(12)
        frame.close:SetWidth(12)
        frame.close.texture = frame.close:CreateTexture("pfBagClose")
        frame.close.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
        frame.close.texture:ClearAllPoints()
        frame.close.texture:SetPoint("TOPLEFT", frame.close, "TOPLEFT", 2, -2)
        frame.close.texture:SetPoint("BOTTOMRIGHT", frame.close, "BOTTOMRIGHT", -2, 2)
        frame.close.texture:SetVertexColor(1,.25,.25,1)
        frame.close:SetScript("OnEnter", function ()
          frame.close.backdrop:SetBackdropBorderColor(1,.25,.25,1)
        end)

        frame.close:SetScript("OnLeave", function ()
          CreateBackdrop(frame.close, default_border)
        end)

       frame.close:SetScript("OnClick", function()
         CloseAllBags()
        end)
      end

      -- bags button
      if not frame.bags then
        frame.bags = CreateFrame("Button", "pfBagSlotShow", frame)
        frame.bags:SetPoint("TOPRIGHT", frame.close, "TOPLEFT", -default_border*3, 0)
        CreateBackdrop(frame.bags, default_border)
        frame.bags:SetHeight(12)
        frame.bags:SetWidth(12)
        frame.bags:SetTextColor(1,1,.25,1)
        frame.bags:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
        frame.bags.texture = frame.bags:CreateTexture("pfBagArrowUp")
        frame.bags.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\up")
        frame.bags.texture:ClearAllPoints()
        frame.bags.texture:SetPoint("TOPLEFT", frame.bags, "TOPLEFT", 3, -1)
        frame.bags.texture:SetPoint("BOTTOMRIGHT", frame.bags, "BOTTOMRIGHT", -3, 1)
        frame.bags.texture:SetVertexColor(.25,.25,.25,1)

        frame.bags:SetScript("OnEnter", function ()
          frame.bags.backdrop:SetBackdropBorderColor(1,1,.25,1)
          frame.bags.texture:SetVertexColor(1,1,.25,1)
        end)

        frame.bags:SetScript("OnLeave", function ()
          CreateBackdrop(frame.bags, default_border)
          frame.bags.texture:SetVertexColor(.25,.25,.25,1)
        end)

        frame.bags:SetScript("OnClick", function()
          if pfUI.bag.right.bagslots:IsShown() then
            pfUI.bag.right.bagslots:Hide()
          else
            pfUI.bag.right.bagslots:Show()
          end
        end)
      end

      -- key button
      if not frame.keys then
        frame.keys = CreateFrame("Button", "pfBagSlotShow", frame)
        frame.keys:SetPoint("TOPRIGHT", frame.bags, "TOPLEFT", -default_border*3, 0)
        CreateBackdrop(frame.keys, default_border)
        frame.keys:SetHeight(12)
        frame.keys:SetWidth(12)
        frame.keys:SetTextColor(1,1,.25,1)
        frame.keys:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
        frame.keys.texture = frame.keys:CreateTexture("pfBagArrowUp")
        frame.keys.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\key")
        frame.keys.texture:ClearAllPoints()
        frame.keys.texture:SetPoint("TOPLEFT", frame.keys, "TOPLEFT", 3, -1)
        frame.keys.texture:SetPoint("BOTTOMRIGHT", frame.keys, "BOTTOMRIGHT", -3, 1)
        frame.keys.texture:SetVertexColor(.25,.25,.25,1)

        frame.keys:SetScript("OnEnter", function ()
          frame.keys.backdrop:SetBackdropBorderColor(1,1,.25,1)
          frame.keys.texture:SetVertexColor(1,1,.25,1)
        end)

        frame.keys:SetScript("OnLeave", function ()
          CreateBackdrop(frame.keys, default_border)
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
        frame.search = CreateFrame("Frame", "pfBagSearch", frame)
        frame.search:SetHeight(12)
        frame.search:SetPoint("TOPLEFT", frame, "TOPLEFT", default_border, -default_border)
        frame.search:SetPoint("TOPRIGHT", frame.keys, "TOPLEFT", -default_border*3, -default_border)
        CreateBackdrop(frame.search, default_border)

        frame.search.edit = CreateFrame("EditBox", "pfUIBagSearch", frame.search, "InputBoxTemplate")
        pfUIBagSearchLeft:SetTexture(nil)
        pfUIBagSearchMiddle:SetTexture(nil)
        pfUIBagSearchRight:SetTexture(nil)
        frame.search.edit:ClearAllPoints()
        frame.search.edit:SetPoint("TOPLEFT", frame.search, "TOPLEFT", default_border*2, 0)
        frame.search.edit:SetPoint("BOTTOMRIGHT", frame.search, "BOTTOMRIGHT", -default_border*2, 0)

        frame.search.edit:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
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
    else
      -- bankframe

      -- bag close button
      if not frame.close then
        frame.close = CreateFrame("Button", "pfBagClose", frame)
        frame.close:SetPoint("TOPRIGHT", -default_border*1,-default_border )
        CreateBackdrop(frame.close, default_border)
        frame.close:SetHeight(12)
        frame.close:SetWidth(12)
        frame.close.texture = frame.close:CreateTexture("pfBagClose")
        frame.close.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\close")
        frame.close.texture:ClearAllPoints()
        frame.close.texture:SetPoint("TOPLEFT", frame.close, "TOPLEFT", 2, -2)
        frame.close.texture:SetPoint("BOTTOMRIGHT", frame.close, "BOTTOMRIGHT", -2, 2)
        frame.close.texture:SetVertexColor(1,.25,.25,1)
        frame.close:SetScript("OnEnter", function ()
          frame.close.backdrop:SetBackdropBorderColor(1,.25,.25,1)
        end)

        frame.close:SetScript("OnLeave", function ()
          CreateBackdrop(frame.close, default_border)
        end)

       frame.close:SetScript("OnClick", function()
         CloseBankFrame()
        end)
      end

      -- bags button
      if not frame.bags then
        frame.bags = CreateFrame("Button", "pfBagSlotShow", frame)
        frame.bags:SetPoint("TOPRIGHT", frame.close, "TOPLEFT", -default_border*3, 0)
        CreateBackdrop(frame.bags, default_border)
        frame.bags:SetHeight(12)
        frame.bags:SetWidth(12)
        frame.bags:SetTextColor(1,1,.25,1)
        frame.bags:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
        frame.bags.texture = frame.bags:CreateTexture("pfBagArrowUp")
        frame.bags.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\up")
        frame.bags.texture:ClearAllPoints()
        frame.bags.texture:SetPoint("TOPLEFT", frame.bags, "TOPLEFT", 3, -1)
        frame.bags.texture:SetPoint("BOTTOMRIGHT", frame.bags, "BOTTOMRIGHT", -3, 1)
        frame.bags.texture:SetVertexColor(.25,.25,.25,1)

        frame.bags:SetScript("OnEnter", function ()
          frame.bags.backdrop:SetBackdropBorderColor(1,1,.25,1)
          frame.bags.texture:SetVertexColor(1,1,.25,1)
        end)

        frame.bags:SetScript("OnLeave", function ()
          CreateBackdrop(frame.bags, default_border)
          frame.bags.texture:SetVertexColor(.25,.25,.25,1)
        end)

        frame.bags:SetScript("OnClick", function()
          if pfUI.bag.left.bagslots:IsShown() then
            pfUI.bag.left.bagslots:Hide()
          else
            pfUI.bag.left.bagslots:Show()
          end
        end)
      end

    end
  end
end)
