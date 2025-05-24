pfUI:RegisterModule("itemclick", "vanilla", function ()
  -- small module that tries to decide if an item should be used or dropped into
  -- the auctionhouse search or trade window

  -- helper functions
  local IsTrading = function()
    return TradeFrame:IsShown()
  end

  local IsAuctionBrowsing = function()
    return AuctionFrame and AuctionFrame:IsShown() and AuctionFrameBrowse and AuctionFrameBrowse:IsShown()
  end

  local IsAuctionSelling = function()
    return AuctionFrame and AuctionFrame:IsShown() and AuctionFrameAuctions and AuctionFrameAuctions:IsShown()
  end

  -- overwrite use/trade logic unless shift is pressed
  local pfHookUseContainerItem = _G.UseContainerItem
  function _G.UseContainerItem(bag, slot)
    if IsTrading() and not IsShiftKeyDown() then
      -- move item to trade window
      PickupContainerItem(bag, slot)
      local slot = TradeFrame_GetAvailableSlot()
      if slot then ClickTradeButton(slot) end
      if CursorHasItem() then
        ClearCursor()
      end
    elseif IsAuctionBrowsing() and not IsShiftKeyDown() then
      -- search item in auction house
      local link = GetContainerItemLink(bag, slot)
      local name = link and string.sub(link, string.find(link, "%[")+1, string.find(link, "%]")-1) or ""
      BrowseName:SetText(name)
      AuctionFrameBrowse_Search()
    elseif IsAuctionSelling() and not IsShiftKeyDown() then
      -- sell item to auction house
      PickupContainerItem(bag, slot)
      AuctionsItemButton:Click()
      if CursorHasItem() then
        ClearCursor()
      end
    else
      -- default action
      pfHookUseContainerItem(bag, slot)
    end
  end

  -- detect bag button tooltips
  local showHelperNextTooltip = false
  local pfHookSetBagItem = GameTooltip.SetBagItem
  function GameTooltip.SetBagItem(self, container, slot)
    showHelperNextTooltip = IsTrading() or IsAuctionBrowsing() or IsAuctionSelling()
    return pfHookSetBagItem(self, container, slot)
  end

  -- add helper text to tooltips
  local tooltip = CreateFrame("Frame", "pfItemClickHelpMessage", GameTooltip)
  tooltip:SetScript("OnShow", function()
    if showHelperNextTooltip then
      GameTooltip:AddLine(T["Hold [Shift] to use item."], 0.50, 0.75, 1.00)
      GameTooltip:Show()
      showHelperNextTooltip = false
    end
  end)
end)
