pfUI:RegisterModule("sellvalue", "vanilla:tbc", function ()
  pfUI.sellvalue = CreateFrame( "Frame" , "pfGameTooltip", GameTooltip )
  pfUI.sellvalue:SetScript("OnShow", function()
    if libtooltip:GetItemLink() then
      local itemID = libtooltip:GetItemID()
      local count = libtooltip:GetItemCount() or 1

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
            GameTooltip:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell) .. "|cff555555  //  " .. CreateGoldString(sell*count), 1, 1, 1);
          else
            GameTooltip:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell * count), 1, 1, 1);
          end

          if count > 1 then
            GameTooltip:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy) .. "|cff555555  //  " .. CreateGoldString(buy*count), 1, 1, 1);
          else
            GameTooltip:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy), 1, 1, 1);
          end
        end
        GameTooltip:Show()
      end
    end
  end)
end)
