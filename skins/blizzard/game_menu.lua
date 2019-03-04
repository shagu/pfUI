pfUI:RegisterSkin("GameMenuFrame", function ()
  StripTextures(GameMenuFrame)
  CreateBackdrop(GameMenuFrame, nil, true, .75)
  GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 2)
  GameMenuFrame:SetWidth(GameMenuFrame:GetWidth() - 30)

  local title = GetNoNameObject(GameMenuFrame, "FontString", "ARTWORK", MAIN_MENU)
  title:SetTextColor(1,1,1,1)
  title:ClearAllPoints()
  title:SetPoint("TOP", GameMenuFrame, "TOP", 0, 16)
  title:SetFont(pfUI.font_default, C.global.font_size + 2, "OUTLINE")

  local buttons = {
    GameMenuButtonOptions,
    GameMenuButtonSoundOptions,
    GameMenuButtonUIOptions,
    GameMenuButtonKeybindings,
    GameMenuButtonMacros,
    GameMenuButtonLogout,
    GameMenuButtonQuit,
    GameMenuButtonContinue
  }

  for _, button in pairs(buttons) do
    SkinButton(button)
  end
end)
