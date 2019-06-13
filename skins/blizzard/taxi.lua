pfUI:RegisterSkin("Flightmaster", "vanilla:tbc", function ()
  StripTextures(TaxiFrame)
  CreateBackdrop(TaxiFrame, nil, nil, .75)
  CreateBackdropShadow(TaxiFrame)

  TaxiFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  TaxiFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
  TaxiFrame:SetHitRectInsets(10,32,10,72)
  EnableMovable(TaxiFrame)

  SkinCloseButton(TaxiCloseButton, TaxiFrame.backdrop, -6, -6)

  TaxiFrame:DisableDrawLayer("BACKGROUND")

  TaxiMerchant:ClearAllPoints()
  TaxiMerchant:SetPoint("TOP", TaxiFrame.backdrop, "TOP", 0, -10)
end)
