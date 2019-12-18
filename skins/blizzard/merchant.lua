pfUI:RegisterSkin("Merchant", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  -- Compatibility
  if MerchantGuildBankRepairButton then -- tbc
    SkinButton(MerchantGuildBankRepairButton, nil, nil, nil, MerchantGuildBankRepairButtonIcon)
    MerchantGuildBankRepairButtonIcon:SetTexCoord(.59, .82, .06, .54)
    hooksecurefunc("MerchantFrame_UpdateRepairButtons", function()
      MerchantGuildBankRepairButton:ClearAllPoints()
      MerchantGuildBankRepairButton:SetPoint("RIGHT", MerchantBuyBackItemItemButton, "LEFT", -14, 0)
      MerchantRepairAllButton:ClearAllPoints()
      MerchantRepairAllButton:SetPoint("RIGHT", MerchantGuildBankRepairButton, "LEFT", -6, 0)
    end)
  else -- vanilla
    MerchantRepairAllButton:ClearAllPoints()
    MerchantRepairAllButton:SetPoint("RIGHT", MerchantBuyBackItemItemButton, "LEFT", -6, 0)
  end

  StripTextures(MerchantFrame)
  CreateBackdrop(MerchantFrame, nil, nil, .75)
  CreateBackdropShadow(MerchantFrame)

  MerchantFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  MerchantFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 58)
  MerchantFrame:SetHitRectInsets(10,32,10,58)
  EnableMovable(MerchantFrame)

  SkinCloseButton(MerchantFrameCloseButton, MerchantFrame.backdrop, -6, -6)

  MerchantFrame:DisableDrawLayer("BACKGROUND")

  SkinTab(MerchantFrameTab1)
  MerchantFrameTab1:ClearAllPoints()
  MerchantFrameTab1:SetPoint("TOPLEFT", MerchantFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))

  SkinTab(MerchantFrameTab2)
  MerchantFrameTab2:ClearAllPoints()
  MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", border*2 + 1, 0)

  for i = 1, BUYBACK_ITEMS_PER_PAGE, 1 do
    local merchantButton = _G["MerchantItem"..i]
    StripTextures(merchantButton)
    merchantButton:SetHeight(37)

    local bg = merchantButton:CreateTexture(nil, "LOW")
    bg:SetTexture(1,1,1,.05)
    bg:SetAllPoints()

    local itemButton = _G["MerchantItem"..i.."ItemButton"]
    StripTextures(itemButton)
    SkinButton(itemButton, nil, nil, nil, _G[itemButton:GetName()..'IconTexture'])

    local moneyFrame = _G["MerchantItem"..i.."MoneyFrame"]
    moneyFrame:ClearAllPoints()
    moneyFrame:SetPoint("BOTTOMLEFT", itemButton, "BOTTOMRIGHT", 5, 1)
  end

  hooksecurefunc("MerchantFrame_UpdateMerchantInfo", function()
    if MerchantFrame.selectedTab == 1 then
      for i = 3, 11, 2 do
      _G["MerchantItem"..i]:ClearAllPoints()
      _G["MerchantItem"..i]:SetPoint("TOPLEFT", _G["MerchantItem"..i-2], "BOTTOMLEFT", 0, -15)
      end
    end
  end, 1)

  StripTextures(MerchantPrevPageButton)
  SkinArrowButton(MerchantPrevPageButton, "left", 18)
  StripTextures(MerchantNextPageButton)
  SkinArrowButton(MerchantNextPageButton, "right", 18)

  StripTextures(MerchantBuyBackItem)
  local bg = MerchantBuyBackItem:CreateTexture(nil, "LOW")
  bg:SetTexture(1,1,1,.05)
  bg:SetAllPoints()

  StripTextures(MerchantBuyBackItemItemButton)
  SkinButton(MerchantBuyBackItemItemButton, nil, nil, nil, _G[MerchantBuyBackItemItemButton:GetName()..'IconTexture'])

  SkinButton(MerchantRepairAllButton, nil, nil, nil, MerchantRepairAllIcon)
  MerchantRepairAllIcon:SetTexCoord(.31, .53, .06, .52)

  StripTextures(MerchantRepairItemButton)
  SkinButton(MerchantRepairItemButton, nil, nil, nil, MerchantRepairItemButton:GetNormalTexture())
  MerchantRepairItemButton:SetNormalTexture("Interface\\MerchantFrame\\UI-Merchant-RepairIcons")
  MerchantRepairItemButton:ClearAllPoints()
  MerchantRepairItemButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -4*bpad, 0)
  MerchantRepairItemButton:GetNormalTexture():SetTexCoord(.03, .25, .07, .50)
end)
