pfUI:RegisterSkin("Petition", "vanilla", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(PetitionFrame)
  CreateBackdrop(PetitionFrame, nil, nil, .75)
  CreateBackdropShadow(PetitionFrame)

  PetitionFrame.backdrop:SetPoint("TOPLEFT", 12, -16)
  PetitionFrame.backdrop:SetPoint("BOTTOMRIGHT", -28, 66)
  PetitionFrame:SetHitRectInsets(12,28,16,66)
  EnableMovable(PetitionFrame)

  SkinCloseButton(PetitionFrameCloseButton, PetitionFrame.backdrop, -6, -6)

  PetitionNpcNameFrame:ClearAllPoints()
  PetitionNpcNameFrame:SetPoint("TOP", PetitionFrame.backdrop, "TOP", 0, -10)

  SkinButton(PetitionFrameSignButton)
  SkinButton(PetitionFrameCancelButton)
  SkinButton(PetitionFrameRenameButton)
  PetitionFrameRenameButton:ClearAllPoints()
  PetitionFrameRenameButton:SetWidth(100)
  PetitionFrameRenameButton:SetPoint("RIGHT", PetitionFrameCancelButton, "LEFT", -2*bpad, 0)
  SkinButton(PetitionFrameRequestButton)
  PetitionFrameRequestButton:ClearAllPoints()
  PetitionFrameRequestButton:SetPoint("RIGHT", PetitionFrameRenameButton, "LEFT", -2*bpad, 0)

  local texture = "StationeryTest"
  if date("%m%d") == "0223" then texture = "Stationery_Val" end
  local tex_Left = PetitionFrame:CreateTexture("BACKGROUND")
  tex_Left:SetTexture("Interface\\Stationery\\"..texture.."1")
  tex_Left:SetPoint("TOPLEFT", 23, -81)
  tex_Left:SetWidth(tex_Left:GetWidth() + 10)
  tex_Left:SetHeight(330)
  local tex_Right = PetitionFrame:CreateTexture("BACKGROUND")
  tex_Right:SetTexture("Interface\\Stationery\\"..texture.."2")
  tex_Right:SetPoint("LEFT", tex_Left, "RIGHT", 0, 0)
  tex_Right:SetWidth(tex_Right:GetWidth() + 10)
  tex_Right:SetHeight(330)
end)
