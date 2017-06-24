-- this must be set during the initial execution
if GetLocale() == "zhCN" then
  STANDARD_TEXT_FONT = "Fonts\\FZXHLJW.TTF"
elseif GetLocale() == "koKR" then
  STANDARD_TEXT_FONT = "Fonts\\2002.TTF"
else
  STANDARD_TEXT_FONT = "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf"
end

function pfUI.environment:UpdateFonts()
  -- force locale based fonts
  if pfUI_config and pfUI_config.global and pfUI_config.global.force_region == "1" then
    if GetLocale() == "zhCN" then
      pfUI_config.global.font_default = "Fonts\\FZXHLJW.TTF"
      pfUI_config.global.font_combat = "Fonts\\FZXHLJW.TTF"
      pfUI_config.global.font_unit = "Fonts\\FZXHLJW.TTF"
    elseif GetLocale() == "koKR" then
      pfUI_config.global.font_default = "Fonts\\2002.TTF"
      pfUI_config.global.font_combat = "Fonts\\2002.TTF"
      pfUI_config.global.font_unit = "Fonts\\2002.TTF"
    end
  end

  if pfUI_config and pfUI_config.global and pfUI_config.global.font_default then
    pfUI.font_default = pfUI_config.global.font_default or "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf"
    pfUI.font_unit = pfUI_config.global.font_unit or "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf"
    pfUI.font_combat = pfUI_config.global.font_combat or "Interface\\AddOns\\pfUI\\fonts\\Continuum.ttf"
  else
    pfUI.font_default = "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf"
    pfUI.font_unit = "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf"
    pfUI.font_combat = "Interface\\AddOns\\pfUI\\fonts\\Continuum.ttf"
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
  ChatFontNormal:SetFont(pfUI.font_default, 12, "NORMAL")
  CombatTextFont:SetFont(pfUI.font_combat, 25)
end

-- run environment update
pfUI.environment:UpdateFonts()
