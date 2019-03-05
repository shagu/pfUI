pfUI:RegisterSkin("Guild Registrar", function ()
  StripTextures(GuildRegistrarFrame)
  StripTextures(GuildRegistrarGreetingFrame)
  CreateBackdrop(GuildRegistrarFrame, nil, nil, .75)
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

  local texture = "StationeryTest"
  if date("%m%d") == "0223" then texture = "Stationery_Val" end
  local tex_Left = GuildRegistrarFrame:CreateTexture("BACKGROUND")
  tex_Left:SetTexture("Interface\\Stationery\\"..texture.."1")
  tex_Left:SetPoint("TOPLEFT", 23, -81)
  tex_Left:SetWidth(tex_Left:GetWidth() + 10)
  tex_Left:SetHeight(330)
  local tex_Right = GuildRegistrarFrame:CreateTexture("BACKGROUND")
  tex_Right:SetTexture("Interface\\Stationery\\"..texture.."2")
  tex_Right:SetPoint("LEFT", tex_Left, "RIGHT", 0, 0)
  tex_Right:SetWidth(tex_Right:GetWidth() + 10)
  tex_Right:SetHeight(330)
end)
