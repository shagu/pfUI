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
          frame:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell) .. "|cff555555  //  " .. CreateGoldString(sell*count), 1, 1, 1);
        else
          frame:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell * count), 1, 1, 1);
        end

        if count > 1 then
          frame:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy) .. "|cff555555  //  " .. CreateGoldString(buy*count), 1, 1, 1);
        else
          frame:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy), 1, 1, 1);
        end
      end
      frame:Show()
    end
  end

  pfUI.sellvalue = CreateFrame( "Frame" , "pfGameTooltip", GameTooltip )
  pfUI.sellvalue:SetScript("OnShow", function()
    if libtooltip:GetItemLink() then
      local id = libtooltip:GetItemID()
      local count = libtooltip:GetItemCount() or 1
      AddVendorPrices(GameTooltip, id, count)
    end
  end)

  local hook = SetItemRef
  _G.SetItemRef = function(link, text, button)
    local item, _, id = string.find(link, "item:(%d+):.*")
    ItemRefTooltip.item = item and id or nil
    ItemRefTooltip.link = link
    hook(link, text, button)
  end

  local function OnUpdate()
    if this.item then
      this:ClearLines()
      this:SetHyperlink(this.link)
      AddVendorPrices(ItemRefTooltip, tonumber(ItemRefTooltip.item), 1)
    end
  end

  if ItemRefTooltip:GetScript("OnUpdate") then
    HookScript("OnUpdate", ItemRefTooltip, OnUpdate)
  else
    ItemRefTooltip:SetScript("OnUpdate", OnUpdate)
  end
end)
