pfUI:RegisterSkin("Guild Registrar", "vanilla:tbc", function ()
  StripTextures(GuildRegistrarFrame)
  StripTextures(GuildRegistrarGreetingFrame)
  CreateBackdrop(GuildRegistrarFrame, nil, nil, .75)
  CreateBackdropShadow(GuildRegistrarFrame)

  GuildRegistrarFrame.backdrop:SetPoint("TOPLEFT", 12, -16)
  GuildRegistrarFrame.backdrop:SetPoint("BOTTOMRIGHT", -28, 66)
  GuildRegistrarFrame:SetHitRectInsets(12,28,16,66)
  EnableMovable(GuildRegistrarFrame)

  SkinCloseButton(GuildRegistrarFrameCloseButton, GuildRegistrarFrame.backdrop, -6, -6)

  GuildRegistrarFrame:DisableDrawLayer("BACKGROUND")

  GuildRegistrarFrameNpcNameText:ClearAllPoints()
  GuildRegistrarFrameNpcNameText:SetPoint("TOP", GuildRegistrarFrame.backdrop, "TOP", 0, -10)

  SkinButton(GuildRegistrarFrameGoodbyeButton)
  SkinButton(GuildRegistrarFrameCancelButton)
  SkinButton(GuildRegistrarFramePurchaseButton)

  GuildRegistrarCostLabel:SetFontObject("GameFontWhite")
  GuildRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
  CreateBackdrop(GuildRegistrarFrameEditBox, nil, nil, 1)
  GuildRegistrarFrameEditBox:SetHeight(16)

  local bg = GuildRegistrarFrame:CreateTexture(nil, "LOW")
  bg:SetTexCoord(.1,1,0,1)
  bg:SetTexture("Interface\\Stationery\\StationeryTest1")
  bg:SetPoint("TOPLEFT", 23, -81)
  bg:SetPoint("BOTTOMRIGHT", -40, 100)
end)
