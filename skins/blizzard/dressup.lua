pfUI:RegisterSkin("Dress Up Frame", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(DressUpFrame, nil, "ARTWORK")
  CreateBackdrop(DressUpFrame, nil, nil, .75)
  CreateBackdropShadow(DressUpFrame)

  DressUpFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  DressUpFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
  DressUpFrame:SetHitRectInsets(10,32,10,72)
  EnableMovable(DressUpFrame)

  SkinCloseButton(DressUpFrameCloseButton, DressUpFrame.backdrop, -6, -6)

  DressUpFrame:DisableDrawLayer("BACKGROUND")

  DressUpFrameTitleText:ClearAllPoints()
  DressUpFrameTitleText:SetPoint("TOP", DressUpFrame.backdrop, "TOP", 0, -10)

  DressUpFrameDescriptionText:ClearAllPoints()
  DressUpFrameDescriptionText:SetPoint("TOP", DressUpFrame.backdrop, "TOP", 0, -30)

  EnableClickRotate(DressUpModel)
  DressUpModelRotateLeftButton:Hide()
  DressUpModelRotateRightButton:Hide()

  SkinButton(DressUpFrameCancelButton)
  SkinButton(DressUpFrameResetButton)
  DressUpFrameResetButton:ClearAllPoints()
  DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -2*bpad, 0)
end)
