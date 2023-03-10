pfUI:RegisterSkin("Character Turtle", "vanilla", function()
  if TWTitles then
    CharacterLevelText:SetPoint("TOP", CharacterNameText, "BOTTOM", 0, -2)
    SkinDropDown(TWTitles)
    TWTitles:SetPoint("TOP", CharacterGuildText, "BOTTOM", 0, -2)
    TWTitlesText:SetPoint("LEFT", TWTitles.backdrop, "LEFT", 6, 2)
    CharacterResistanceFrame:SetPoint("TOP", TWTitles, "BOTTOM", 0, 0)
  end
end)
