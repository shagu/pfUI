pfUI:RegisterModule("sellvalue", function ()
  pfUI.sellvalue = CreateFrame( "Frame" , "pfGameTooltip", GameTooltip )

  pfUI.sellvalue:SetScript("OnHide", function()
    GameTooltip.itemLink = nil
    GameTooltip.itemCount = nil
  end)

  pfUI.sellvalue:SetScript("OnShow", function()
    if GameTooltip.itemLink then
      local _, _, itemID = string.find(GameTooltip.itemLink, "item:(%d+):%d+:%d+:%d+")
      local itemID = tonumber(itemID)
      local count = GameTooltip.itemCount or 1

      if pfSellData[itemID] then
        local _, _, sell, buy = strfind(pfSellData[itemID], "(.*),(.*)")
        sell = tonumber(sell)
        buy = tonumber(buy)

        if not MerchantFrame:IsShown() then
          if sell > 0 then SetTooltipMoney(GameTooltip, sell * count) end
        end

        if IsShiftKeyDown() or C.tooltip.vendor.showalways == "1" then
          GameTooltip:AddLine(" ")

          if count > 1 then
            GameTooltip:AddDoubleLine("Sell:", CreateGoldString(sell) .. "|cff555555  //  " .. CreateGoldString(sell*count), 1, 1, 1);
          else
            GameTooltip:AddDoubleLine("Sell:", CreateGoldString(sell * count), 1, 1, 1);
          end

          if count > 1 then
            GameTooltip:AddDoubleLine("Buy:", CreateGoldString(buy) .. "|cff555555  //  " .. CreateGoldString(buy*count), 1, 1, 1);
          else
            GameTooltip:AddDoubleLine("Buy:", CreateGoldString(buy), 1, 1, 1);
          end
        end
        GameTooltip:Show()
      end
    end
  end)

  local pfHookSetBagItem = GameTooltip.SetBagItem
  function GameTooltip.SetBagItem(self, container, slot)
    GameTooltip.itemLink = GetContainerItemLink(container, slot)
    _, GameTooltip.itemCount = GetContainerItemInfo(container, slot)
    return pfHookSetBagItem(self, container, slot)
  end

  local pfHookSetQuestLogItem = GameTooltip.SetQuestLogItem
  function GameTooltip.SetQuestLogItem(self, itemType, index)
    GameTooltip.itemLink = GetQuestLogItemLink(itemType, index)
    if not GameTooltip.itemLink then return end
    return pfHookSetQuestLogItem(self, itemType, index)
  end

  local pfHookSetQuestItem = GameTooltip.SetQuestItem
  function GameTooltip.SetQuestItem(self, itemType, index)
    GameTooltip.itemLink = GetQuestItemLink(itemType, index)
    return pfHookSetQuestItem(self, itemType, index)
  end

  local pfHookSetLootItem = GameTooltip.SetLootItem
  function GameTooltip.SetLootItem(self, slot)
    GameTooltip.itemLink = GetLootSlotLink(slot)
    pfHookSetLootItem(self, slot)
  end

  local pfHookSetInboxItem = GameTooltip.SetInboxItem
  function GameTooltip.SetInboxItem(self, mailID, attachmentIndex)
    local itemName, itemTexture, inboxItemCount, inboxItemQuality = GetInboxItem(mailID)
    GameTooltip.itemLink = GetItemLinkByName(itemName)
    return pfHookSetInboxItem(self, mailID, attachmentIndex)
  end

  local pfHookSetInventoryItem = GameTooltip.SetInventoryItem
  function GameTooltip.SetInventoryItem(self, unit, slot)
    GameTooltip.itemLink = GetInventoryItemLink(unit, slot)
    return pfHookSetInventoryItem(self, unit, slot)
  end

  local pfHookSetLootRollItem = GameTooltip.SetLootRollItem
  function GameTooltip.SetLootRollItem(self, id)
    GameTooltip.itemLink = GetLootRollItemLink(id)
    return pfHookSetLootRollItem(self, id)
  end

  local pfHookSetLootRollItem = GameTooltip.SetLootRollItem
  function GameTooltip.SetLootRollItem(self, id)
    GameTooltip.itemLink = GetLootRollItemLink(id)
    return pfHookSetLootRollItem(self, id)
  end

  local pfHookSetMerchantItem = GameTooltip.SetMerchantItem
  function GameTooltip.SetMerchantItem(self, merchantIndex)
    GameTooltip.itemLink = GetMerchantItemLink(merchantIndex)
    return pfHookSetMerchantItem(self, merchantIndex)
  end

  local pfHookSetCraftItem = GameTooltip.SetCraftItem
  function GameTooltip.SetCraftItem(self, skill, slot)
    GameTooltip.itemLink = GetCraftReagentItemLink(skill, slot)
    return pfHookSetCraftItem(self, skill, slot)
  end

  local pfHookSetCraftSpell = GameTooltip.SetCraftSpell
  function GameTooltip.SetCraftSpell(self, slot)
    GameTooltip.itemLink = GetCraftItemLink(slot)
    return pfHookSetCraftSpell(self, slot)
  end

  local pfHookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
  function GameTooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
    if reagentIndex then
      GameTooltip.itemLink = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
    else
      GameTooltip.itemLink = GetTradeSkillItemLink(skillIndex)
    end
    return pfHookSetTradeSkillItem(self, skillIndex, reagentIndex)
  end

  local pfHookSetAuctionSellItem = GameTooltip.SetAuctionSellItem
  function GameTooltip.SetAuctionSellItem(self)
    local itemName, _, itemCount = GetAuctionSellItemInfo()
    GameTooltip.itemCount = itemCount
    GameTooltip.itemLink = GetItemLinkByName(itemName)
    return pfHookSetAuctionSellItem(self)
  end

  local pfHookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
  function GameTooltip.SetTradePlayerItem(self, index)
    GameTooltip.itemLink = GetTradePlayerItemLink(index)
    return pfHookSetTradePlayerItem(self, index)
  end

  local pfHookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
  function GameTooltip.SetTradeTargetItem(self, index)
    GameTooltip.itemLink = GetTradeTargetItemLink(index)
    return pfHookSetTradeTargetItem(self, index)
  end
end)
