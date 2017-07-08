pfUI:RegisterModule("autovendor", function ()
  local scanlist = {}

  local function RepairItems()
    local cost, possible = GetRepairAllCost()
    if cost > 0 and possible then
      DEFAULT_CHAT_FRAME:AddMessage("Your items have been repaired for " .. CreateGoldString(cost))
      RepairAllItems()
    end
  end

  local function ScanGreyItems()
    scanlist = {}
    for bag = 0, 4, 1 do
      for slot = 1, GetContainerNumSlots(bag), 1 do
        local name = GetContainerItemLink(bag,slot)
        if name and string.find(name,"ff9d9d9d") then
          table.insert(scanlist, { bag, slot })
        end
      end
    end
  end

  local function GetNextGreyItem()
    if scanlist[1] then
      local bag, slot = scanlist[1][1], scanlist[1][2]
      table.remove(scanlist, 1)

      return bag, slot
    else
      return nil, nil
    end
  end

  local autovendor = CreateFrame("Frame", "pfMoneyUpdate", nil)
  autovendor:Hide()

  autovendor:SetScript("OnShow", function()
    ScanGreyItems()
    this.count = 0
    this.price = 0
  end)

  autovendor:SetScript("OnUpdate", function()
    -- throttle to to one item per .1 second
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

    local bag, slot = GetNextGreyItem()

    if not bag or not slot then
      this:Hide()
      return
    end

    local name = GetContainerItemLink(bag,slot)

    -- double check to only sell grey
    if name and string.find(name,"ff9d9d9d") then
      -- get value
      local _, icount = GetContainerItemInfo(bag, slot)
      local _, _, id = string.find(GetContainerItemLink(bag, slot), "item:(%d+):%d+:%d+:%d+")
      if pfSellData[tonumber(id)] then
        local _, _, sell, buy = strfind(pfSellData[tonumber(id)], "(.*),(.*)")
        this.price = this.price + ( sell * ( icount or 1 ) )
        this.count = this.count + 1
      end
      UseContainerItem(bag, slot)
    end
  end)

  autovendor:SetScript("OnHide", function()
    if this.count > 0 then
      DEFAULT_CHAT_FRAME:AddMessage("Your vendor trash has been sold and you earned " .. CreateGoldString(this.price))
    end
  end)

  autovendor:RegisterEvent("MERCHANT_SHOW")
  autovendor:RegisterEvent("MERCHANT_UPDATE")
  autovendor:SetScript("OnEvent", function()
    autovendor.button:Update()

    if event == "MERCHANT_SHOW" then
      if C["global"]["autorepair"] == "1" then
        RepairItems()
      end

      if C["global"]["autosell"] == "1" then
        autovendor:Show()
      end

      MerchantRepairText:SetText("")
      if MerchantRepairItemButton:IsShown() then
        autovendor.button:ClearAllPoints()
        autovendor.button:SetPoint("RIGHT", MerchantRepairItemButton, "LEFT", -2, 0)
      else
        autovendor.button:ClearAllPoints()
        autovendor.button:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 172, 91)
      end
    end
  end)

  -- Setup Autosell button
  autovendor.button = CreateFrame("Button", "pfMerchantautovendor.buttonButton", MerchantFrame)
  autovendor.button:SetWidth(36)
  autovendor.button:SetHeight(36)
  autovendor.button.icon = autovendor.button:CreateTexture("BORDER")
  autovendor.button.icon:SetAllPoints(autovendor.button)
  autovendor.button.icon:SetTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")
  autovendor.button.icon:SetVertexColor(1,.8,.4)
  autovendor.button:SetNormalTexture("")
  autovendor.button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
  autovendor.button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
  autovendor.button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
    GameTooltip:SetText("Sell Grey Items");
    GameTooltip:Show();
  end)

  autovendor.button:SetScript("OnLeave", function()
    GameTooltip:Hide();
  end)

  autovendor.button:SetScript("OnClick", function()
    autovendor:Show()
  end)

  autovendor.button.Update = function()
    if not autovendor:IsVisible() then

      ScanGreyItems()

      if scanlist[1] then
        autovendor.button:Enable()
        autovendor.button.icon:SetVertexColor(1,.8,.4)
      else
        autovendor.button:Disable()
        autovendor.button.icon:SetVertexColor(.5,.5,.5)
      end

    else
      autovendor.button:Disable()
      autovendor.button.icon:SetVertexColor(.5,.5,.5)
    end
  end

  -- Hook MerchantFrame_Update
  if not pfMerchantFrame_Update then
    local pfMerchantFrame_Update = MerchantFrame_Update
    function _G.MerchantFrame_Update()
      if MerchantFrame.selectedTab == 1 then
        autovendor.button:Show()
      else
        autovendor.button:Hide()
      end
      pfMerchantFrame_Update()
    end
  end
end)
