pfUI:RegisterSkin("Battlefield Minimap", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()

  HookAddonOrVariable("Blizzard_BattlefieldMinimap", function()
    StripTextures(BattlefieldMinimap)
    CreateBackdrop(BattlefieldMinimap, nil, nil, 0)
    CreateBackdropShadow(BattlefieldMinimap)

    BattlefieldMinimap:SetWidth(220)
    BattlefieldMinimap:SetHeight(146)

    SkinCloseButton(BattlefieldMinimapCloseButton, BattlefieldMinimap, 0, 0)

    SkinTab(BattlefieldMinimapTab)
    BattlefieldMinimapTabText:ClearAllPoints()
    BattlefieldMinimapTabText:SetPoint("CENTER", 0, 0)

    HookScript(BattlefieldMinimap, "OnShow", function()
      BattlefieldMinimapTab:Hide()
    end)

    hooksecurefunc("BattlefieldMinimap_ShowOpacity", function()
      OpacityFrame:ClearAllPoints()
      OpacityFrame:SetPoint("TOPRIGHT", "BattlefieldMinimap", "TOPLEFT", -2*border, 0)
    end, 1)
  end)
end)
