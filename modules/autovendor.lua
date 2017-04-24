pfUI:RegisterModule("autovendor", function ()
  pfUI.autovendor = CreateFrame("Frame", "pfMoneyUpdate", nil)
  pfUI.autovendor.RepairAllItems = function()
    local cost, possible = GetRepairAllCost()
    if cost > 0 and possible then
      DEFAULT_CHAT_FRAME:AddMessage("Your items have been repaired for " .. CreateGoldString(cost))
      RepairAllItems()
    end
  end

  pfUI.autovendor.SellAllGrey = function()
    local price = 0
    local count = 0

    for bag = 0, 4, 1 do
      for slot = 1, GetContainerNumSlots(bag), 1 do
        local name = GetContainerItemLink(bag,slot)
        if name and string.find(name,"ff9d9d9d") then

          -- get value
          local _, icount = GetContainerItemInfo(bag, slot)
          local _, _, id = string.find(GetContainerItemLink(bag, slot), "item:(%d+):%d+:%d+:%d+")
          if pfSellData[tonumber(id)] then
            local _, _, sell, buy = strfind(pfSellData[tonumber(id)], "(.*),(.*)")
            price = price + ( sell * ( icount or 1 ) )
            count = count + 1
          end
          UseContainerItem(bag,slot)
        end
      end
    end

    if count > 0 then
      DEFAULT_CHAT_FRAME:AddMessage("Your vendor trash has been sold and you earned " .. CreateGoldString(price))
    end
  end

  pfUI.autovendor:RegisterEvent("MERCHANT_SHOW")
  pfUI.autovendor:SetScript("OnEvent", function()
    if event == "MERCHANT_SHOW" then
      if C["global"]["autorepair"] == "1" then
        pfUI.autovendor:RepairAllItems()
      end

      if C["global"]["autosell"] == "1" then
        pfUI.autovendor:SellAllGrey()
      end

      MerchantRepairText:SetText("")
      if MerchantRepairItemButton:IsShown() then
        pfUI.autovendor.button:ClearAllPoints()
        pfUI.autovendor.button:SetPoint("RIGHT", MerchantRepairItemButton, "LEFT", -2, 0)
      else
        pfUI.autovendor.button:ClearAllPoints()
        pfUI.autovendor.button:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 172, 91)
      end
    end
  end)

  -- show button
  pfUI.autovendor.button = CreateFrame("Button", "pfMerchantpfUI.autovendor.buttonButton", MerchantFrame)
  pfUI.autovendor.button:SetWidth(36)
  pfUI.autovendor.button:SetHeight(36)
  pfUI.autovendor.button.icon = pfUI.autovendor.button:CreateTexture("BORDER")
  pfUI.autovendor.button.icon:SetAllPoints(pfUI.autovendor.button)
  pfUI.autovendor.button.icon:SetTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")
  pfUI.autovendor.button.icon:SetVertexColor(1,.8,.4)
  pfUI.autovendor.button:SetNormalTexture("")
  pfUI.autovendor.button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
  pfUI.autovendor.button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
  pfUI.autovendor.button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:SetText("Sell Grey Items");
    GameTooltip:Show();
  end)

  pfUI.autovendor.button:SetScript("OnLeave", function()
    GameTooltip:Hide();
  end)

  pfUI.autovendor.button:SetScript("OnClick", function()
    pfUI.autovendor:SellAllGrey()
  end)

  if not pfMerchantFrame_Update then
    local pfMerchantFrame_Update = MerchantFrame_Update
    function _G.MerchantFrame_Update()
      if MerchantFrame.selectedTab == 1 then
        pfUI.autovendor.button:Show()
      else
        pfUI.autovendor.button:Hide()
      end
      pfMerchantFrame_Update()
    end
  end
end)
