pfUI:RegisterSkin("Trade", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  StripTextures(TradeFrame)
  CreateBackdrop(TradeFrame, nil, nil, .75)
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
    StripTextures(PlayerButton)
    CreateBackdrop(PlayerButton, nil, nil, .75)
    local PlayerItemButton = _G["TradePlayerItem"..i.."ItemButton"]
    StripTextures(PlayerItemButton)
    SkinButton(PlayerItemButton, nil, nil, nil, _G[PlayerItemButton:GetName()..'IconTexture'])

    local RecipientButton = _G["TradeRecipientItem"..i]
    StripTextures(RecipientButton)
    CreateBackdrop(RecipientButton, nil, nil, .75)
    local RecipientItemButton = _G["TradeRecipientItem"..i.."ItemButton"]
    StripTextures(RecipientItemButton)
    SkinButton(RecipientItemButton)
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
end)
