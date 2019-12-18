pfUI:RegisterSkin("Tooltips", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local alpha = tonumber(C.tooltip.alpha)

  for _, tooltip in pairs({GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2}) do
    CreateBackdrop(tooltip, nil, nil, alpha)
    CreateBackdropShadow(tooltip)
  end

  HookScript(WorldMapTooltip, "OnShow", function()
    CreateBackdrop(WorldMapTooltip, nil, nil, alpha)
    CreateBackdropShadow(WorldMapTooltip)
  end)

  SkinCloseButton(ItemRefCloseButton, ItemRefTooltip.backdrop, -6, -6)

  for _, tooltip in pairs({ShoppingTooltip1, ShoppingTooltip2}) do
    tooltip:SetClampedToScreen(true)
    HookScript(tooltip, "OnShow", function()
      local a, b, c, x, y = this:GetPoint()
      if not x or x == 0 then x = (border*2) + ( x or 0 ) + 1 end
      if a then this:SetPoint(a, b, c, x, y) end
    end)
  end
end)
