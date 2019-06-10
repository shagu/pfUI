pfUI:RegisterModule("itemclick", "vanilla", function ()
  -- small module that tries to decide if an item should be used or dropped into
  -- the auctionhouse search or trade window

  local pfHookUseContainerItem = _G.UseContainerItem
  function _G.UseContainerItem(bag,slot)
    if TradeFrame:IsShown() then
      PickupContainerItem(bag,slot)
      local slot = TradeFrame_GetAvailableSlot()
      if slot then ClickTradeButton(slot) end
      if CursorHasItem() then
        ClearCursor()
      end
    elseif AuctionFrame and AuctionFrame:IsShown() and
        AuctionFrameBrowse and AuctionFrameBrowse:IsShown() then
      local link = GetContainerItemLink(bag,slot)
      local name = link and string.sub(link, string.find(link, "%[")+1, string.find(link, "%]")-1) or ""
      BrowseName:SetText(name)
      AuctionFrameBrowse_Search()
    elseif AuctionFrame and AuctionFrame:IsShown() and
        AuctionFrameAuctions and AuctionFrameAuctions:IsShown() then
      PickupContainerItem(bag,slot)
      AuctionsItemButton:Click()
      if CursorHasItem() then
        ClearCursor()
      end
    else
      pfHookUseContainerItem(bag,slot)
    end
  end
end)
