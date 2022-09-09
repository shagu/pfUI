pfUI:RegisterSkin("Trade", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(TradeFrame)
  CreateBackdrop(TradeFrame, nil, nil, .75)
  CreateBackdropShadow(TradeFrame)

  TradeFrame.backdrop:SetPoint("TOPLEFT", 8, -20)
  TradeFrame.backdrop:SetPoint("BOTTOMRIGHT", -16, 30)
  TradeFrame:SetHitRectInsets(8,16,20,30)
  EnableMovable(TradeFrame)

  SkinCloseButton(TradeFrameCloseButton, TradeFrame.backdrop, -6, -6)

  TradeFrame:DisableDrawLayer("BACKGROUND")

  TradeFramePlayerNameText:ClearAllPoints()
  TradeFramePlayerNameText:SetPoint("TOPLEFT", TradeFrame.backdrop, "TOPLEFT", 60, -20)
  TradeFrameRecipientNameText:ClearAllPoints()
  TradeFrameRecipientNameText:SetPoint("TOPRIGHT", TradeFrame.backdrop, "TOPRIGHT", -60, -20)

  for i = 1, MAX_TRADE_ITEMS do
    local PlayerButton = _G["TradePlayerItem"..i]
    local PlayerItemButton = _G["TradePlayerItem"..i.."ItemButton"]
    local RecipientButton = _G["TradeRecipientItem"..i]
    local RecipientItemButton = _G["TradeRecipientItem"..i.."ItemButton"]

    StripTextures(PlayerButton)
    StripTextures(PlayerItemButton)
    SkinButton(PlayerItemButton, nil, nil, nil, _G[PlayerItemButton:GetName()..'IconTexture'])
    local PlayerItemButtonBG = PlayerButton:CreateTexture(nil, "LOW")
    PlayerItemButtonBG:SetTexture(1,1,1,.05)
    PlayerItemButtonBG:SetAllPoints()

    StripTextures(RecipientButton)
    StripTextures(RecipientItemButton)
    SkinButton(RecipientItemButton, nil, nil, nil, _G[RecipientItemButton:GetName()..'IconTexture'])
    local RecipientButtonBG = RecipientButton:CreateTexture(nil, "LOW")
    RecipientButtonBG:SetTexture(1,1,1,.05)
    RecipientButtonBG:SetAllPoints()
  end

  hooksecurefunc("TradeFrame_UpdateTargetItem", function(id)
    HandleIcon(_G["TradeRecipientItem"..id.."ItemButton"], _G["TradeRecipientItem"..id..'IconTexture'])
  end, 1)

  SkinMoneyInputFrame(TradePlayerInputMoneyFrame)

  SkinButton(TradeFrameCancelButton)
  TradeFrameCancelButton:ClearAllPoints()
  TradeFrameCancelButton:SetPoint("BOTTOMRIGHT", TradeFrame.backdrop, -10, 10)
  SkinButton(TradeFrameTradeButton)
  TradeFrameTradeButton:ClearAllPoints()
  TradeFrameTradeButton:SetPoint("RIGHT", TradeFrameCancelButton, "LEFT", -2*bpad, 0)

  -- skin highlights
  TradeHighlightPlayerTop:SetTexture(0, 0, 0, 0)
  TradeHighlightPlayerMiddle:SetTexture(0, 0, 0, 0)
  TradeHighlightPlayerBottom:SetTexture(0, 1, 0, 0.2)
  TradeHighlightPlayerBottom:SetPoint("TOPLEFT", 2, 0)

  TradeHighlightPlayerEnchantTop:SetTexture(0, 0, 0, 0)
  TradeHighlightPlayerEnchantMiddle:SetTexture(0, 0, 0, 0)
  TradeHighlightPlayerEnchantBottom:SetTexture(0, 1, 0, 0.2)
  TradeHighlightPlayerEnchantBottom:SetPoint("TOPLEFT", 2, 0)

  TradeHighlightRecipientTop:SetTexture(0, 0, 0, 0)
  TradeHighlightRecipientMiddle:SetTexture(0, 0, 0, 0)
  TradeHighlightRecipientBottom:SetTexture(0, 1, 0, 0.2)
  TradeHighlightRecipientBottom:SetPoint("TOPLEFT", 2, 0)

  TradeHighlightRecipientEnchantTop:SetTexture(0, 0, 0, 0)
  TradeHighlightRecipientEnchantMiddle:SetTexture(0, 0, 0, 0)
  TradeHighlightRecipientEnchantBottom:SetTexture(0, 1, 0, 0.2)
  TradeHighlightRecipientEnchantBottom:SetPoint("TOPLEFT", 2, 0)
end)
