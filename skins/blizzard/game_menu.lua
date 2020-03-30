pfUI:RegisterSkin("Game Menu", "vanilla:tbc", function ()
  StripTextures(GameMenuFrame)
  CreateBackdrop(GameMenuFrame, nil, true, .75)
  CreateBackdropShadow(GameMenuFrame)

  GameMenuFrame:SetWidth(GameMenuFrame:GetWidth() - 30)
  if pfUI.expansion == 'tbc' then
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 10)
  elseif pfUI.expansion == 'vanilla' then
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 6)
  end

  local title = GetNoNameObject(GameMenuFrame, "FontString", "ARTWORK", MAIN_MENU)
  title:SetTextColor(1,1,1,1)
  title:ClearAllPoints()
  title:SetPoint("TOP", GameMenuFrame, "TOP", 0, 16)
  title:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")

  local pfUIButton = CreateFrame("Button", "GameMenuButtonPFUI", GameMenuFrame, "GameMenuButtonTemplate")
  pfUIButton:SetPoint("TOP", 0, -10)
  pfUIButton:SetText(T["|cff33ffccpf|cffffffffUI|cffcccccc Config"])
  pfUIButton:SetScript("OnClick", function()
    pfUI.gui:Show()
    HideUIPanel(GameMenuFrame)
  end)
  SkinButton(pfUIButton)

  local point, relativeTo, relativePoint, xOffset, yOffset = GameMenuButtonOptions:GetPoint()
  GameMenuButtonOptions:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset - 22)

  local buttons = {
    GameMenuButtonOptions,
    GameMenuButtonSoundOptions,
    GameMenuButtonUIOptions,
    GameMenuButtonKeybindings,
    GameMenuButtonMacros,
    GameMenuButtonRatings,
    GameMenuButtonLogout,
    GameMenuButtonQuit,
    GameMenuButtonContinue,
  }

  for _, button in pairs(buttons) do
    if button then SkinButton(button) end
  end
end)
