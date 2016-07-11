pfUI:RegisterModule("bags", function ()

  -- remove this function to avoid vertexcolor updates on item buttons
  function SetItemButtonNormalTextureVertexColor () return end

  pfUI.bag = CreateFrame("Frame", "pfBag")
  pfUI.bag:SetFrameStrata("MEDIUM")
  pfUI.bag:SetPoint("BOTTOMLEFT", pfUI.chat.right, "BOTTOMLEFT", 0, 0)
  pfUI.bag:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 0)
  pfUI.bag:SetBackdrop(pfUI.backdrop)
  pfUI.bag:Hide()

  pfUI.bag.bagframe = CreateFrame("Frame", "pfBagBags", pfUI.bag)
  pfUI.bag.bagframe:SetFrameStrata("MEDIUM")
  pfUI.bag.bagframe:SetBackdrop(pfUI.backdrop)
  pfUI.bag.bagframe:Hide()

  pfUI.bank = CreateFrame("Frame", "pfBank")
  pfUI.bank:SetFrameStrata("MEDIUM")
  pfUI.bank:SetPoint("BOTTOMLEFT", pfUI.chat.left, "BOTTOMLEFT", 0, 0)
  pfUI.bank:SetPoint("BOTTOMRIGHT", pfUI.chat.left, "BOTTOMRIGHT", 0, 0)
  pfUI.bank:SetBackdrop(pfUI.backdrop)
  pfUI.bank:Hide()

  pfUI.bank.bagframe = CreateFrame("Frame", "pfBankBags", pfUI.bank)
  pfUI.bank.bagframe:SetFrameStrata("MEDIUM")
  pfUI.bank.bagframe:SetBackdrop(pfUI.backdrop)
  pfUI.bank.bagframe:Hide()

  for i=1, 6 do
    local bag = getglobal("BankFrameBag" .. i)
    bag:SetNormalTexture(nil)
    bag:SetPushedTexture(nil)
    bag:SetBackdrop(
      { bgFile = texture, tile = false, tileSize = pfUI_config.unitframes.buff_size,
        edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
      })
    bag:SetBackdropBorderColor(.3,.3,.3,1)
  end

  tinsert(UISpecialFrames,"pfBag");

  function OpenAllBags()
    if pfUI.bag:IsShown() then
      pfUI.bag:Hide()
    else
      pfUI.bag:Show()
    end
  end

  function CloseAllBags()
    pfUI.bag:Hide()
  end

  function ToggleBackpack()
    if pfUI.bag:IsShown() then
      pfUI.bag:Hide()
    else
      pfUI.bag:Show()
    end
  end

  function ToggleBag() end

  for i=1, 5 do
    pfUI.bag[i] = CreateFrame("Frame")
    pfUI.bag[i]:SetID(i-1)
    pfUI.bag[i]:SetParent(pfUI.bag)
    pfUI.bag[i]:SetAllPoints(pfUI.bag)
  end

  for i=6, 12 do
    pfUI.bank[i] = CreateFrame("Frame")
    pfUI.bank[i]:SetID(i-1)
    pfUI.bank[i]:SetParent(pfUI.bank)
    pfUI.bank[i]:SetAllPoints(pfUI.bank)
  end

  pfUI.bag.close = CreateFrame("Button")
  pfUI.bag.close:SetParent(pfUI.bag)
  pfUI.bag.close:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  pfUI.bag.close:SetPoint("TOPRIGHT", -pfUI_config.bars.border*2,-pfUI_config.bars.border*2 )
  pfUI.bag.close:SetBackdrop(pfUI.backdrop)
  pfUI.bag.close:SetHeight(15)
  pfUI.bag.close:SetWidth(15)
  pfUI.bag.close:SetText("x")
  pfUI.bag.close:SetTextColor(1,.25,.25,1)
  pfUI.bag.close:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 10, "OUTLINE")
  pfUI.bag.close:SetScript("OnEnter", function ()
      pfUI.bag.close:SetBackdrop(pfUI.backdrop_col)
      pfUI.bag.close:SetBackdropBorderColor(1,.25,.25,1)
    end)

  pfUI.bag.close:SetScript("OnLeave", function ()
      pfUI.bag.close:SetBackdrop(pfUI.backdrop)
      pfUI.bag.close:SetBackdropBorderColor(1,1,1,1)
    end)

  pfUI.bag.close:SetScript("OnClick", function()
    if arg1 == "RightButton" then
      if pfUI.bag.bagframe:IsShown() then
        pfUI.bag.bagframe:Hide()
        pfUI.bank.bagframe:Hide()
      else
        pfUI.bag.bagframe:Show()
        pfUI.bank.bagframe:Show()
      end
    else
      CloseAllBags()
    end
  end)

  pfUI.bag.search = CreateFrame("Frame", pfUI.bag)
  pfUI.bag.search:SetParent(pfUI.bag)
  pfUI.bag.search:SetHeight(15)
  pfUI.bag.search:SetWidth(100)
  pfUI.bag.search:SetPoint("TOPLEFT", pfUI.bag, "TOPLEFT", pfUI_config.bars.border*2, -pfUI_config.bars.border*2)
  pfUI.bag.search:SetBackdrop(pfUI.backdrop)
  pfUI.bag.search:SetBackdropBorderColor(0,0,0,1)

  pfUI.bag.search.edit = CreateFrame("EditBox", "pfUIBagSearch", pfUI.bag.search, "InputBoxTemplate")
  pfUIBagSearchLeft:SetTexture(nil);
  pfUIBagSearchMiddle:SetTexture(nil);
  pfUIBagSearchRight:SetTexture(nil);
  pfUI.bag.search.edit:ClearAllPoints()
  pfUI.bag.search.edit:SetScript("OnEditFocusGained", function()
      pfUI.bag.search.edit:SetTextColor(1,1,1,1)
      pfUI.bag.search:SetBackdropBorderColor(1,1,1,1)
      this:SetText("")

      pfUI.bag.search:SetPoint("TOPLEFT", pfUI.bag, "TOPLEFT", pfUI_config.bars.border*2, -pfUI_config.bars.border*2)
      pfUI.bag.search:SetPoint("TOPRIGHT", pfUI.bag, "TOPRIGHT", -pfUI_config.bars.border*2 - 16, -pfUI_config.bars.border*2)

      pfUI.bag.money:Hide()
    end)
  pfUI.bag.search.edit:SetScript("OnEditFocusLost", function()
      pfUI.bag.search.edit:SetTextColor(.5,.5,.5,1)
      pfUI.bag.search:SetBackdropBorderColor(0,0,0,1)
      this:SetText("Search")

      pfUI.bag.search:ClearAllPoints()
      pfUI.bag.search:SetWidth(100)
      pfUI.bag.search:SetPoint("TOPLEFT", pfUI.bag, "TOPLEFT", pfUI_config.bars.border*2, -pfUI_config.bars.border*2)

      for j=1, 12 do
        local frame, container = nil
        if j > 11 then
          frame = "BankFrame"
          container = -1
        else
          frame = "ContainerFrame" .. j
          container = j - 1
        end
        for i=1, GetContainerNumSlots(container) do
          getglobal(frame .. "Item" .. i):SetAlpha(1)
        end
      end

      pfUI.bag.money:Show()
    end)

  pfUI.bag.search.edit:SetPoint("TOPLEFT", pfUI.bag.search, "TOPLEFT", pfUI_config.bars.border*2, 0)
  pfUI.bag.search.edit:SetPoint("BOTTOMRIGHT", pfUI.bag.search, "BOTTOMRIGHT", -pfUI_config.bars.border*2, 0)

  pfUI.bag.search.edit:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 10, "OUTLINE")
  pfUI.bag.search.edit:SetAutoFocus(false)
  pfUI.bag.search.edit:SetText("Search")
  pfUI.bag.search.edit:SetTextColor(.5,.5,.5,1)
  pfUI.bag.search.edit:SetScript("OnTextChanged", function(self)
      if pfUI.bag.search.edit:GetText() == "Search" then return end
      for j=1, 12 do

        local frame, container = nil
        if j > 11 then
          frame = "BankFrame"
          container = -1
        else
          frame = "ContainerFrame" .. j
          container = j - 1
        end

        for i=1, GetContainerNumSlots(container) do
          local texture, itemCount, locked, quality, readable = GetContainerItemInfo(container, i);
          if itemCount then
            local itemLink = GetContainerItemLink(container, i);
            local itemstring = string.sub(itemLink, string.find(itemLink, "%[")+1, string.find(itemLink, "%]")-1);
            if strfind(strlower(itemstring), strlower(pfUI.bag.search.edit:GetText())) then
              getglobal(frame .. "Item" .. i):SetAlpha(1)
            else
              getglobal(frame .. "Item" .. i):SetAlpha(.25)
            end
          end
        end
      end
    end)

  pfUI.bag.money = CreateFrame("Frame", "pfUIBagsMoney", pfUI.bag, "SmallMoneyFrameTemplate")
  pfUI.bag.money:ClearAllPoints()
  pfUI.bag.money:SetPoint("TOPRIGHT", pfUI.bag, "TOPRIGHT", -13, -6)
  pfUIBagsMoneyGoldButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 10, "OUTLINE")
  for i,v in ipairs({pfUIBagsMoneyGoldButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
  pfUIBagsMoneySilverButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 10, "OUTLINE")
  for i,v in ipairs({pfUIBagsMoneySilverButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
  pfUIBagsMoneyCopperButton:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 10, "OUTLINE")
  for i,v in ipairs({pfUIBagsMoneyCopperButton:GetRegions()}) do if i == 1 then v:SetHeight(10); v:SetWidth(10) end end
  pfUI.bag:RegisterEvent("BAG_UPDATE");
  pfUI.bag:RegisterEvent("BAG_CLOSED");
  pfUI.bag:RegisterEvent("BAG_OPEN");
  pfUI.bag:RegisterEvent("BAG_UPDATE_COOLDOWN");
  pfUI.bag:RegisterEvent("ITEM_LOCK_CHANGED");
  pfUI.bag:RegisterEvent("UPDATE_INVENTORY_ALERTS")
  pfUI.bag:SetScript("OnEvent", function()
      local x = -1
      local y = 0
      local x_max = 10

      local button_size = (this:GetWidth() - pfUI_config.bars.border*3) / x_max - pfUI_config.bars.border

      pfUI.bag.bagframe:SetPoint("BOTTOMLEFT", pfUI.bag, "TOPLEFT", 0, pfUI_config.bars.border)
      pfUI.bag.bagframe:SetWidth(3 * pfUI_config.bars.border + 4*(pfUI_config.bars.border+button_size))
      pfUI.bag.bagframe:SetHeight(button_size + 2 * (pfUI_config.bars.border*2))

      for i=0, 3 do
        local bag = getglobal("CharacterBag" .. i .. "Slot")
        bag:ClearAllPoints()
        bag:SetParent(pfUI.bag.bagframe)
        bag:SetWidth(button_size)
        bag:SetHeight(button_size)
        bag:SetNormalTexture(nil)
        bag:SetPushedTexture(nil)
        bag:SetBackdrop(
            { bgFile = texture, tile = false, tileSize = pfUI_config.unitframes.buff_size,
              edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
              insets = { left = 0, right = 0, top = 0, bottom = 0}
            })

        bag:SetBackdropBorderColor(.3,.3,.3,1)
        bag.SetBackdrop = function () return end

        bag:SetPoint("TOPLEFT", pfUI.bag.bagframe, "TOPLEFT", pfUI_config.bars.border*2 + i*button_size + i*pfUI_config.bars.border, -pfUI_config.bars.border*2)
        bag:SetAlpha(1)
        bag:Show()
      end


      for j=1, 5 do
        for i=1, GetContainerNumSlots(j-1) do
          x = x + 1
          if x >= x_max then y = y + 1; x = 0 end

          getglobal("ContainerFrame" .. j).size = GetContainerNumSlots(j-1)
          f = getglobal("ContainerFrame" .. j .. "Item" .. i)
          f:SetParent(pfUI.bag[j])
          f:SetID(i)
          f:SetPoint("TOPLEFT", pfUI.bag, "TOPLEFT", pfUI_config.bars.border*2 + x*button_size + x*pfUI_config.bars.border, -pfUI_config.bars.border*2 - y*button_size - y * pfUI_config.bars.border - 17)
          f:Show()
          f:SetHeight(button_size)
          f:SetWidth(button_size)
          local texture, itemCount, locked, quality, readable = GetContainerItemInfo(j-1, i);
          f:SetNormalTexture(nil)

          f:SetBackdrop(
            { bgFile = texture, tile = false, tileSize = pfUI_config.unitframes.buff_size,
              edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
              insets = { left = 0, right = 0, top = 0, bottom = 0}
            })
          if quality and quality > 1 then
            f:SetBackdropBorderColor(GetItemQualityColor(quality))
          else
            f:SetBackdropBorderColor(.3,.3,.3,1)
          end

          SetItemButtonCount(getglobal("ContainerFrame" .. j .. "Item" .. i), itemCount);
          if ( texture ) then
            local cooldown = getglobal(getglobal("ContainerFrame" .. j .. "Item" .. i):GetName().."Cooldown");
            local start, duration, enable = GetContainerItemCooldown(j-1, getglobal("ContainerFrame" .. j .. "Item" .. i):GetID());
            CooldownFrame_SetTimer(cooldown, start, duration, enable);
            if ( duration > 0 and enable == 0 ) then
              SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
            end
            getglobal("ContainerFrame" .. j .. "Item" .. i .. "Cooldown"):Show();
          else
            getglobal("ContainerFrame" .. j .. "Item" .. i .. "Cooldown"):Hide();
          end

          getglobal("ContainerFrame" .. j .. "Item" .. i .. "Count"):SetPoint("BOTTOMLEFT", 0,0)
          getglobal("ContainerFrame" .. j .. "Item" .. i .. "Count"):SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")

          for i,v in ipairs({f:GetRegions()}) do
            -- 2 is stack count
            if i == 4 then v:SetAlpha(0) end
          end
        end
      end
      y = y + 1
      pfUI.bag:SetHeight( y * button_size + y * pfUI_config.bars.border + pfUI_config.bars.border*3 + 17 + 17)
    end)

  pfUI.bank:RegisterEvent("BAG_UPDATE");
  pfUI.bank:RegisterEvent("BANKFRAME_OPENED");
  pfUI.bank:RegisterEvent("BANKFRAME_CLOSED");
  pfUI.bank:RegisterEvent("BAG_UPDATE_COOLDOWN");
  pfUI.bank:RegisterEvent("ITEM_LOCK_CHANGED");
  pfUI.bank:RegisterEvent("UPDATE_INVENTORY_ALERTS")
  pfUI.bank:RegisterEvent("BANKFRAME_OPENED");
  pfUI.bank:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
  pfUI.bank:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
  pfUI.bank:SetScript("OnEvent", function()
      BankFrame:SetWidth(.1)
      BankFrame:SetHeight(.1)
      BankFrame:SetAlpha(0)

      if event == "BANKFRAME_OPENED" then pfUI.bank:Show(); pfUI.bag:Show() end
      if event == "BANKFRAME_CLOSED" then pfUI.bank:Hide(); HideUIPanel(this) end

      local x = -1
      local y = 0
      local x_max = 10

      local button_size = (this:GetWidth() - pfUI_config.bars.border*3) / x_max - pfUI_config.bars.border

      -- put bagslots into pfUI bagslot frame
      pfUI.bank.bagframe:SetPoint("BOTTOMLEFT", pfUI.bank, "TOPLEFT", 0, pfUI_config.bars.border)
      pfUI.bank.bagframe:SetWidth(3 * pfUI_config.bars.border + 6*(pfUI_config.bars.border+button_size))
      pfUI.bank.bagframe:SetHeight(button_size + 2 * (pfUI_config.bars.border*2))

      BankFramePurchaseButton:SetParent(pfUI.bank.bagframe)
      BankFramePurchaseButton:SetAlpha(1)
      BankFramePurchaseButton:SetWidth(button_size)
      BankFramePurchaseButton:SetHeight(button_size)
      BankFramePurchaseButton:SetPoint("RIGHT", pfUI.bank.bagframe, "RIGHT",  -pfUI_config.bars.border*2, 0)
      BankFramePurchaseButton:SetText("+")
      BankFramePurchaseButton:SetBackdrop(pfUI.backdrop)
      BankFramePurchaseButton:SetNormalTexture(nil)
      BankFramePurchaseButton:SetPushedTexture(nil)
      if BankFramePurchaseInfo:IsShown() then
        pfUI.bank.bagframe:SetWidth(pfUI.bank.bagframe:GetWidth() + button_size + pfUI_config.bars.border)
      end

      for i=1, 6 do
        local bag = getglobal("BankFrameBag" .. i)
        bag:ClearAllPoints()
        bag:SetParent(pfUI.bank.bagframe)
        bag:SetWidth(button_size)
        bag:SetHeight(button_size)
        bag:SetNormalTexture(nil)
        bag:SetPushedTexture(nil)
        bag:SetBackdrop(
            { bgFile = texture, tile = false, tileSize = pfUI_config.unitframes.buff_size,
              edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
              insets = { left = 0, right = 0, top = 0, bottom = 0}
            })
        bag:SetBackdropBorderColor(.3,.3,.3,1)
        bag.SetBackdrop = function () return end

        bag:SetPoint("TOPLEFT", pfUI.bank.bagframe, "TOPLEFT", pfUI_config.bars.border*2 + (i-1)*button_size + (i-1)*pfUI_config.bars.border, -pfUI_config.bars.border*2)
        bag:SetAlpha(1)
      end

      for j=5, 11 do
        local frame, container = nil
        if j == 5 then
          frame = "BankFrame"
          container = -1
        else
          frame = "ContainerFrame" .. j
          container = j - 1
        end

        for i=1, GetContainerNumSlots(container) do
          x = x + 1
          if x >= x_max then y = y + 1; x = 0 end
          getglobal(frame).size = GetContainerNumSlots(j-1)
          f = getglobal(frame .. "Item" .. i)
          if j == 5 then f:SetParent(pfUI.bank[12]) else f:SetParent(pfUI.bank[j]) end
          f:Show()
          f:SetID(i)
          f:SetPoint("TOPLEFT", pfUI.bank, "TOPLEFT", pfUI_config.bars.border*2 + x*button_size + x*pfUI_config.bars.border, -pfUI_config.bars.border*2 - y*button_size - y * pfUI_config.bars.border)
          f:SetAlpha(1)
          f:SetHeight(button_size)
          f:SetWidth(button_size)
          local texture, itemCount, locked, quality, readable = GetContainerItemInfo(container, i);
          f:SetNormalTexture(nil)

          f:SetBackdrop(
            { bgFile = texture, tile = false, tileSize = pfUI_config.unitframes.buff_size,
              edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
              insets = { left = 0, right = 0, top = 0, bottom = 0}
            })
          if quality and quality > 1 then
            f:SetBackdropBorderColor(GetItemQualityColor(quality))
          else
            f:SetBackdropBorderColor(.3,.3,.3,1)
          end

          SetItemButtonCount(getglobal(frame .. "Item" .. i), itemCount);
          if ( texture ) then
            local cooldown = getglobal(getglobal(frame .. "Item" .. i):GetName().."Cooldown");
            if cooldown then
              local start, duration, enable = GetContainerItemCooldown(container, getglobal(frame .. "Item" .. i):GetID());
              CooldownFrame_SetTimer(cooldown, start, duration, enable);
              if ( duration > 0 and enable == 0 ) then
                SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
              end
            end
          end

          getglobal(frame .. "Item" .. i .. "Count"):SetPoint("BOTTOMLEFT", 0,0)
          getglobal(frame .. "Item" .. i .. "Count"):SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")

          for i,v in ipairs({f:GetRegions()}) do
            -- 2 is stack count
            if i == 4 then v:SetAlpha(0) end
            if j == 5 and i == 1 then v:SetAlpha(0) end

          end
        end
      end
      y = y + 1
      pfUI.bank:SetHeight( y * button_size + y * pfUI_config.bars.border + pfUI_config.bars.border*3 + 17)
    end)
end)
