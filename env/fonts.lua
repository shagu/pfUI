-- this must be set during the initial execution
STANDARD_TEXT_FONT = "Interface\\AddOns\\pfUI\\fonts\\arial.ttf"

function pfUI.environment:UpdateFonts()
  -- load config if available
  local default = "Interface\\AddOns\\pfUI\\fonts\\arial.ttf"
  local square = "Interface\\AddOns\\pfUI\\fonts\\homespun.ttf"
  local combat = "Interface\\AddOns\\pfUI\\fonts\\diediedie.ttf"

  if pfUI_config and pfUI_config.global.font_default then
    default = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf"
    combat =  "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_combat .. ".ttf"
    square = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_square .. ".ttf"
  end

  STANDARD_TEXT_FONT = default;
  UNIT_NAME_FONT = default;
  DAMAGE_TEXT_FONT = combat;
  NAMEPLATE_FONT = default;

  SystemFont:SetFont(default, 15)
  GameFontNormal:SetFont(default, 12)
  GameFontBlack:SetFont(default, 12)
  GameFontNormalSmall:SetFont(default, 10)
  GameFontNormalLarge:SetFont(default, 16)
  GameFontNormalHuge:SetFont(default, 20)
  NumberFontNormal:SetFont(default, 14, "OUTLINE")
  NumberFontNormalSmall:SetFont(default, 14, "OUTLINE")
  NumberFontNormalLarge:SetFont(default, 16, "OUTLINE")
  NumberFontNormalHuge:SetFont(default, 30, "OUTLINE")
  QuestTitleFont:SetFont(default, 18)
  QuestFont:SetFont(default, 13)
  QuestFontHighlight:SetFont(default, 14)
  ItemTextFontNormal:SetFont(default, 15)
  MailTextFontNormal:SetFont(default, 15)
  SubSpellFont:SetFont(default, 10)
  DialogButtonNormalText:SetFont(default, 16)
  ZoneTextFont:SetFont(default, 48, "OUTLINE")
  SubZoneTextFont:SetFont(default, 24, "OUTLINE")
  TextStatusBarTextSmall:SetFont(default, 12, "NORMAL")
  GameTooltipText:SetFont(default, 12)
  GameTooltipTextSmall:SetFont(default, 10)
  GameTooltipHeaderText:SetFont(default, 14)
  WorldMapTextFont:SetFont(default, 102, "THICK")
  InvoiceTextFontNormal:SetFont(default, 12)
  InvoiceTextFontSmall:SetFont(default, 10)
  CombatTextFont:SetFont(default, 25)
  ChatFontNormal:SetFont(default, 12, "NORMAL")
end

-- run environment update
pfUI.environment:UpdateFonts()
