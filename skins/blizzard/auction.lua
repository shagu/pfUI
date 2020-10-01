pfUI:RegisterSkin("Auctionhouse", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()
  HookAddonOrVariable("Blizzard_AuctionUI", function()
    -- Compatibility
    if BrowseResetButton then -- tbc
      SkinButton(BrowseResetButton)
    else -- vanilla
      SkinArrowButton(BidPrevPageButton, "left", 18)
      SkinArrowButton(BidNextPageButton, "right", 18)
      SkinArrowButton(AuctionsPrevPageButton, "left", 18)
      SkinArrowButton(AuctionsNextPageButton, "right", 18)
    end

    hooksecurefunc("AuctionFrame_OnShow", function()
      AuctionFrame:ClearAllPoints()
      AuctionFrame:SetPoint("TOPLEFT", 10, -104)
    end, 1)

    StripTextures(AuctionFrame, true)
    CreateBackdrop(AuctionFrame, nil, nil, .75)
    CreateBackdropShadow(AuctionFrame)
    EnableMovable(AuctionFrame)

    SkinCloseButton(AuctionFrameCloseButton, AuctionFrame.backdrop, -6, -6)

    AuctionFrame:DisableDrawLayer("BACKGROUND")

    SkinTab(AuctionFrameTab1)
    AuctionFrameTab1:ClearAllPoints()
    AuctionFrameTab1:SetPoint("TOPLEFT", AuctionFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
    SkinTab(AuctionFrameTab2)
    AuctionFrameTab2:ClearAllPoints()
    AuctionFrameTab2:SetPoint("LEFT", AuctionFrameTab1, "RIGHT", border*2 + 1, 0)
    SkinTab(AuctionFrameTab3)
    AuctionFrameTab3:ClearAllPoints()
    AuctionFrameTab3:SetPoint("LEFT", AuctionFrameTab2, "RIGHT", border*2 + 1, 0)

    do -- Browse Tab
      BrowseTitle:ClearAllPoints()
      BrowseTitle:SetPoint("TOP", AuctionFrame.backdrop, "TOP", 0, -10)

      StripTextures(BrowseFilterScrollFrame)
      SkinScrollbar(BrowseFilterScrollFrameScrollBar)
      for i = 1, NUM_FILTERS_TO_DISPLAY do
        SkinButton(_G["AuctionFilterButton"..i])
      end

      StripTextures(BrowseScrollFrame)
      SkinScrollbar(BrowseScrollFrameScrollBar)

      local sort_buttons = {BrowseQualitySort,BrowseLevelSort,BrowseDurationSort,BrowseHighBidderSort,BrowseCurrentBidSort}
      for _,v in pairs(sort_buttons) do
        StripTextures(v, nil, "BACKGROUND")
        CreateBackdrop(v, nil, true)
        v:SetHighlightTexture("")
      end

      for i = 1, NUM_BROWSE_TO_DISPLAY do
        local button = _G["BrowseButton"..i]
        if button then
          StripTextures(button, nil, "BACKGROUND")
          CreateBackdrop(button, nil, true)

          local highlight = button:GetHighlightTexture()
          if highlight then
            highlight:SetHeight(40)
          end
        end

        local item = _G["BrowseButton"..i.."Item"]
        if item then
          StripTextures(item)
          SkinButton(item, nil, nil, nil, nil, true)
          item:ClearAllPoints()
          item:SetPoint("LEFT", 2, 0)
        end
      end
      hooksecurefunc("AuctionFrameBrowse_Update", function()
        for i = 1, NUM_BROWSE_TO_DISPLAY do
          HandleIcon(_G["BrowseButton"..i.."Item"], _G["BrowseButton"..i.."ItemIconTexture"])
        end
      end, 1)

      SkinArrowButton(BrowsePrevPageButton, "left", 18)
      SkinArrowButton(BrowseNextPageButton, "right", 18)

      SkinCheckbox(IsUsableCheckButton, 22)
      SkinCheckbox(ShowOnPlayerCheckButton)

      local editboxes = {BrowseName, BrowseMinLevel, BrowseMaxLevel}
      for _,v in pairs(editboxes) do
        StripTextures(v, nil, "BACKGROUND")
        CreateBackdrop(v, nil, true)
      end
      BrowseName:ClearAllPoints()
      BrowseName:SetPoint("TOPLEFT", AuctionFrame.backdrop, "TOPLEFT", 30, -54)
      BrowseNameText:ClearAllPoints()
      BrowseNameText:SetPoint("BOTTOMLEFT", BrowseName, "TOPLEFT", 4, 4)
      BrowseMinLevel:ClearAllPoints()
      BrowseMinLevel:SetPoint("LEFT", BrowseName, "RIGHT", 10, 0)
      BrowseLevelText:ClearAllPoints()
      BrowseLevelText:SetPoint("BOTTOMLEFT", BrowseMinLevel, "TOPLEFT", 4, 4)
      BrowseLevelHyphen:ClearAllPoints()
      BrowseLevelHyphen:SetPoint("LEFT", BrowseMinLevel, "RIGHT", 4, 0)

      SkinDropDown(BrowseDropDown)
      BrowseDropDown:ClearAllPoints()
      BrowseDropDown:SetPoint("LEFT", BrowseMaxLevel, "RIGHT", 20, 0)

      SkinMoneyInputFrame(BrowseBidPrice)

      SkinButton(BrowseSearchButton)
      SkinButton(BrowseCloseButton)
      SkinButton(BrowseBuyoutButton)
      BrowseBuyoutButton:ClearAllPoints()
      BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -2*bpad, 0)
      SkinButton(BrowseBidButton)
      BrowseBidButton:ClearAllPoints()
      BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -2*bpad, 0)
    end

    do -- Bid Tab
      BidTitle:ClearAllPoints()
      BidTitle:SetPoint("TOP", AuctionFrame.backdrop, "TOP", 0, -10)

      local sort_buttons = {BidQualitySort,BidLevelSort,BidDurationSort,BidBuyoutSort,BidStatusSort, BidBidSort}
      for _,v in pairs(sort_buttons) do
        StripTextures(v, nil, "BACKGROUND")
        CreateBackdrop(v, nil, true)
        v:SetHighlightTexture("")
      end

      StripTextures(BidScrollFrame)
      SkinScrollbar(BidScrollFrameScrollBar)
      for i = 1, NUM_BIDS_TO_DISPLAY do
        local button = _G["BidButton"..i]
        StripTextures(button, nil, "BACKGROUND")
        CreateBackdrop(button, nil, true)
        button:GetHighlightTexture():SetHeight(40)

        local item = _G["BidButton"..i.."Item"]
        StripTextures(item)
        SkinButton(item, nil, nil, nil, nil, true)
        item:ClearAllPoints()
        item:SetPoint("LEFT", 2, 0)
      end
      hooksecurefunc("AuctionFrameBid_Update", function()
        for i = 1, NUM_BIDS_TO_DISPLAY do
          HandleIcon(_G["BidButton"..i.."Item"], _G["BidButton"..i.."ItemIconTexture"])
        end
      end, 1)

      SkinMoneyInputFrame(BidBidPrice)
      BidBidPrice:ClearAllPoints()
      BidBidPrice:SetPoint("BOTTOM", 25, 18)
      BidBidText:ClearAllPoints()
      BidBidText:SetPoint("BOTTOMRIGHT", AuctionFrameBid, "BOTTOM", -74, 21)

      SkinButton(BidCloseButton)
      SkinButton(BidBuyoutButton)
      BidBuyoutButton:ClearAllPoints()
      BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -2*bpad, 0)
      SkinButton(BidBidButton)
      BidBidButton:ClearAllPoints()
      BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -2*bpad, 0)
    end

    do -- Auctions Tab
      AuctionsTitle:ClearAllPoints()
      AuctionsTitle:SetPoint("TOP", AuctionFrame.backdrop, "TOP", 0, -10)

      local sort_buttons = {AuctionsQualitySort,AuctionsDurationSort,AuctionsHighBidderSort,AuctionsBidSort}
      for _,v in pairs(sort_buttons) do
        StripTextures(v, nil, "BACKGROUND")
        CreateBackdrop(v, nil, true)
        v:SetHighlightTexture("")
      end

      StripTextures(AuctionsScrollFrame)
      SkinScrollbar(AuctionsScrollFrameScrollBar)
      for i = 1, NUM_AUCTIONS_TO_DISPLAY do
        local button = _G["AuctionsButton"..i]
        StripTextures(button, nil, "BACKGROUND")
        CreateBackdrop(button, nil, true)
        button:GetHighlightTexture():SetHeight(40)

        local item = _G["AuctionsButton"..i.."Item"]
        StripTextures(item)
        SkinButton(item, nil, nil, nil, nil, true)
        item:ClearAllPoints()
        item:SetPoint("LEFT", 2, 0)
      end
      hooksecurefunc("AuctionFrameAuctions_Update", function()
        for i = 1, NUM_AUCTIONS_TO_DISPLAY do
          HandleIcon(_G["AuctionsButton"..i.."Item"], _G["AuctionsButton"..i.."ItemIconTexture"])
        end
      end, 1)

      SkinButton(AuctionsItemButton)
      hooksecurefunc("AuctionSellItemButton_OnEvent", function()
        if event ~= "NEW_AUCTION_UPDATE" then return end
        HandleIcon(AuctionsItemButton, AuctionsItemButton:GetNormalTexture())
      end, 1)

      SkinMoneyInputFrame(StartPrice)
      SkinMoneyInputFrame(BuyoutPrice)

      SkinButton(AuctionsCreateAuctionButton)
      SkinButton(AuctionsCloseButton)
      SkinButton(AuctionsCancelAuctionButton)
      AuctionsCancelAuctionButton:ClearAllPoints()
      AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -2*bpad, 0)
    end

    do -- AuctionDressUpFrame
      StripTextures(AuctionDressUpFrame, nil, "BACKGROUND")
      CreateBackdrop(AuctionDressUpFrame, nil, true, .75)
      CreateBackdropShadow(AuctionDressUpFrame)

      AuctionDressUpFrame:ClearAllPoints()
      AuctionDressUpFrame:SetPoint("LEFT", AuctionFrame.backdrop, "RIGHT", 4, 0)

      StripTextures(AuctionDressUpFrameCloseButton)
      SkinCloseButton(AuctionDressUpFrameCloseButton, AuctionDressUpFrame, -6, -6)

      EnableClickRotate(AuctionDressUpModel)
      AuctionDressUpModelRotateLeftButton:Hide()
      AuctionDressUpModelRotateRightButton:Hide()

      SkinButton(AuctionDressUpFrameResetButton)
    end
  end)
end)
