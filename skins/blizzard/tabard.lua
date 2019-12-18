pfUI:RegisterSkin("Guild Tabard", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(TabardFrame)
  CreateBackdrop(TabardFrame, nil, nil, .75)
  CreateBackdropShadow(TabardFrame)

  TabardFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  TabardFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
  TabardFrame:SetHitRectInsets(10,32,10,72)
  EnableMovable(TabardFrame)

  SkinCloseButton(TabardFrameCloseButton, TabardFrame.backdrop, -6, -6)

  TabardFrame:DisableDrawLayer("BACKGROUND")

  TabardFrameNameText:ClearAllPoints()
  TabardFrameNameText:SetPoint("TOP", TabardFrame.backdrop, "TOP", 0, -10)

  TabardFrameGreetingText:ClearAllPoints()
  TabardFrameGreetingText:SetPoint("TOP", TabardFrame.backdrop, "TOP", 0, -39)

  StripTextures(TabardFrameCostFrame)

  EnableClickRotate(TabardModel)
  TabardCharacterModelRotateLeftButton:Hide()
  TabardCharacterModelRotateRightButton:Hide()

  StripTextures(TabardFrameCustomizationFrame)
  for i = 1, 5 do
    local button = _G["TabardFrameCustomization"..i]
    StripTextures(button)
    CreateBackdrop(button, nil, true)

    local left = _G["TabardFrameCustomization"..i.."LeftButton"]
    StripTextures(left)
    SkinArrowButton(left, "left", 20)
    left:ClearAllPoints()
    left:SetPoint("LEFT", 0, 0)

    local right = _G["TabardFrameCustomization"..i.."RightButton"]
    StripTextures(right)
    SkinArrowButton(right, "right", 20)
    right:ClearAllPoints()
    right:SetPoint("RIGHT", 0, 0)

    local text = _G["TabardFrameCustomization"..i.."Text"]
    text:ClearAllPoints()
    text:SetPoint("CENTER", 0, 0)
  end

  SkinButton(TabardFrameCancelButton)
  SkinButton(TabardFrameAcceptButton)
  TabardFrameAcceptButton:ClearAllPoints()
  TabardFrameAcceptButton:SetPoint("RIGHT", TabardFrameCancelButton, "LEFT", -2*bpad, 0)
end)
