pfUI:RegisterModule("sellvalue", function ()
  pfUI.sellvalue = CreateFrame( "Frame" , "pfUIsellvalue", GameTooltip )

  pfUI.sellvalue:SetScript("OnShow", function()
    if GetMouseFocus() and GetMouseFocus():GetParent() then
      local bag = GetMouseFocus():GetParent():GetID()
      local slot = GetMouseFocus():GetID()
      local _, count = GetContainerItemInfo(bag, slot)
      local itemLink = GetContainerItemLink(bag, slot);
      if not itemLink then return end

      local _, _, iid = string.find(itemLink, "item:(%d+):%d+:%d+:%d+")
      local _, _, itemLink = string.find(itemLink, "(item:%d+:%d+:%d+:%d+)");
      local itemName = GetItemInfo(itemLink)

      if pfSellData[tonumber(iid)] and itemName == getglobal("GameTooltipTextLeft1"):GetText() then
        local _, _, sell, buy = strfind(pfSellData[tonumber(iid)], "(.*),(.*)")
        sell = tonumber(sell)
        buy = tonumber(buy)

        if not MerchantFrame:IsShown() then
          if sell > 0 then SetTooltipMoney(GameTooltip, sell * count) end
        end

        if IsShiftKeyDown() then
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
end)
