pfUI:RegisterModule("sellvalue", "vanilla:tbc", function ()
  local function AddVendorPrices(frame, id, count)
    if pfSellData[id] then
      local _, _, sell, buy = strfind(pfSellData[id], "(.*),(.*)")
      sell = tonumber(sell)
      buy = tonumber(buy)

      if not MerchantFrame:IsShown() then
        if sell > 0 then SetTooltipMoney(frame, sell * count) end
      end

      if IsShiftKeyDown() or C.tooltip.vendor.showalways == "1" then
        frame:AddLine(" ")

        if count > 1 then
          frame:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell) .. "|cff555555  //  " .. CreateGoldString(sell*count), 1, 1, 1)
        else
          frame:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell * count), 1, 1, 1)
        end

        if count > 1 then
          frame:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy) .. "|cff555555  //  " .. CreateGoldString(buy*count), 1, 1, 1)
        else
          frame:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy), 1, 1, 1)
        end
      end
      frame:Show()
    end
  end

  pfUI.sellvalue = CreateFrame( "Frame" , "pfGameTooltip", GameTooltip )
  pfUI.sellvalue:SetScript("OnShow", function()
    if libtooltip:GetItemLink() then
      local id = libtooltip:GetItemID()
      local count = tonumber(libtooltip:GetItemCount()) or 1
      AddVendorPrices(GameTooltip, id, math.max(count, 1))
    end
  end)

  local HookSetItemRef = SetItemRef
  _G.SetItemRef = function(link, text, button)
    local item, _, id = string.find(link, "item:(%d+):.*")
    HookSetItemRef(link, text, button)
    if not IsAltKeyDown() and not IsShiftKeyDown() and not IsControlKeyDown() and item then
      AddVendorPrices(ItemRefTooltip, tonumber(id), 1)
    end
  end
end)
