-- this must be set during the initial execution
if GetLocale() == "zhCN" then
  STANDARD_TEXT_FONT = "Fonts\\FZXHLJW.TTF"
else
  STANDARD_TEXT_FONT = "Interface\\AddOns\\pfUI\\fonts\\arial.ttf"
end

function pfUI.environment:UpdateFonts()
  if pfUI_config and pfUI_config.global and pfUI_config.global.font_default then
    pfUI.font_default = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf"
    pfUI.font_combat =  "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_combat .. ".ttf"
    pfUI.font_square = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf"
  else
    pfUI.font_default = "Interface\\AddOns\\pfUI\\fonts\\arial.ttf"
    pfUI.font_square = "Interface\\AddOns\\pfUI\\fonts\\homespun.ttf"
    pfUI.font_combat = "Interface\\AddOns\\pfUI\\fonts\\diediedie.ttf"
  end

  -- force locale based fonts
  if pfUI_config and pfUI_config.global and pfUI_config.global.force_region == "1" then
    if GetLocale() == "zhCN" then
      pfUI.font_default = "Fonts\\FZXHLJW.TTF"
      pfUI.font_combat = "Fonts\\FZXHLJW.TTF"
      pfUI.font_square = "Fonts\\FZXHLJW.TTF"
    end
  end

  STANDARD_TEXT_FONT = pfUI.font_default;
  UNIT_NAME_FONT = pfUI.font_default;
  DAMAGE_TEXT_FONT = pfUI.font_combat;
  NAMEPLATE_FONT = pfUI.font_default;

  SystemFont:SetFont(pfUI.font_default, 15)
  GameFontNormal:SetFont(pfUI.font_default, 12)
  GameFontBlack:SetFont(pfUI.font_default, 12)
  GameFontNormalSmall:SetFont(pfUI.font_default, 12)
  GameFontNormalLarge:SetFont(pfUI.font_default, 16)
  GameFontNormalHuge:SetFont(pfUI.font_default, 20)
  NumberFontNormal:SetFont(pfUI.font_default, 14, "OUTLINE")
  NumberFontNormalSmall:SetFont(pfUI.font_default, 14, "OUTLINE")
  NumberFontNormalLarge:SetFont(pfUI.font_default, 16, "OUTLINE")
  NumberFontNormalHuge:SetFont(pfUI.font_default, 30, "OUTLINE")
  QuestTitleFont:SetFont(pfUI.font_default, 18)
  QuestFont:SetFont(pfUI.font_default, 13)
  QuestFontHighlight:SetFont(pfUI.font_default, 14)
  ItemTextFontNormal:SetFont(pfUI.font_default, 15)
  MailTextFontNormal:SetFont(pfUI.font_default, 15)
  SubSpellFont:SetFont(pfUI.font_default, 12)
  DialogButtonNormalText:SetFont(pfUI.font_default, 16)
  ZoneTextFont:SetFont(pfUI.font_default, 48, "OUTLINE")
  SubZoneTextFont:SetFont(pfUI.font_default, 24, "OUTLINE")
  TextStatusBarTextSmall:SetFont(pfUI.font_default, 12, "NORMAL")
  GameTooltipText:SetFont(pfUI.font_default, 12)
  GameTooltipTextSmall:SetFont(pfUI.font_default, 12)
  GameTooltipHeaderText:SetFont(pfUI.font_default, 14)
  WorldMapTextFont:SetFont(pfUI.font_default, 102, "THICK")
  InvoiceTextFontNormal:SetFont(pfUI.font_default, 12)
  InvoiceTextFontSmall:SetFont(pfUI.font_default, 12)
  CombatTextFont:SetFont(pfUI.font_default, 25)
  ChatFontNormal:SetFont(pfUI.font_default, 12, "NORMAL")
end

-- run environment update
pfUI.environment:UpdateFonts()
