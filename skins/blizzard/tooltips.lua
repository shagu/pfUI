pfUI:RegisterSkin("Tooltips", function ()
  local border = tonumber(C.appearance.border.default)
  local alpha = tonumber(C.tooltip.alpha)

  for _, tooltip in pairs({GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2}) do
    CreateBackdrop(tooltip, nil, nil, alpha)
  end

  HookScript(WorldMapTooltip, "OnShow", function()
    CreateBackdrop(WorldMapTooltip, nil, nil, alpha)
  end)

  SkinCloseButton(ItemRefCloseButton, ItemRefTooltip.backdrop, -6, -6)

  for _, tooltip in pairs({ShoppingTooltip1, ShoppingTooltip2}) do
    tooltip:SetClampedToScreen(true)
    tooltip:SetScript("OnShow", function()
      local a, b, c, x, y = this:GetPoint()
      if not x or x == 0 then x = (border*2) + ( x or 0 ) + 1 end
      if a then this:SetPoint(a, b, c, x, y) end
    end)
  end
end)
