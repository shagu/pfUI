function pfUI.environment:UpdateFonts()
  -- abort when config is not ready yet
  if not pfUI_config or not pfUI_config.global then return end

  -- load font configuration
  local default, unit, combat
  if pfUI_config.global.force_region == "1" and GetLocale() == "zhCN" then
    -- force locale compatible fonts
    default = "Fonts\\FZXHLJW.TTF"
    combat = "Fonts\\FZXHLJW.TTF"
    unit = "Fonts\\FZXHLJW.TTF"
  elseif pfUI_config.global.force_region == "1" and GetLocale() == "koKR" then
    -- force locale compatible fonts
    default = "Fonts\\2002.TTF"
    combat = "Fonts\\2002.TTF"
    unit = "Fonts\\2002.TTF"
  else
    -- use default entries
    default = pfUI_config.global.font_default
    combat = pfUI_config.global.font_combat
    unit = pfUI_config.global.font_unit
  end

  -- write setting shortcuts
  pfUI.font_default = default
  pfUI.font_combat = combat
  pfUI.font_unit = unit

  pfUI.font_default_size = default_size
  pfUI.font_combat_size = combat_size
  pfUI.font_unit_size = unit_size

  -- set game constants
  STANDARD_TEXT_FONT = default
  DAMAGE_TEXT_FONT   = combat
  NAMEPLATE_FONT     = default
  UNIT_NAME_FONT     = default

  -- change default game font objects
  SystemFont:SetFont(default, 15)
  GameFontNormal:SetFont(default, 12)
  GameFontBlack:SetFont(default, 12)
  GameFontNormalSmall:SetFont(default, 11)
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
  SubSpellFont:SetFont(default, 12)
  DialogButtonNormalText:SetFont(default, 16)
  ZoneTextFont:SetFont(default, 34, "OUTLINE")
  SubZoneTextFont:SetFont(default, 24, "OUTLINE")
  TextStatusBarTextSmall:SetFont(default, 12, "NORMAL")
  GameTooltipText:SetFont(default, 12)
  GameTooltipTextSmall:SetFont(default, 12)
  GameTooltipHeaderText:SetFont(default, 13)
  WorldMapTextFont:SetFont(default, 102, "THICK")
  InvoiceTextFontNormal:SetFont(default, 12)
  InvoiceTextFontSmall:SetFont(default, 12)
  CombatTextFont:SetFont(combat, 25)
  ChatFontNormal:SetFont(default, 13, pfUI_config.chat.text.outline == "1" and "OUTLINE")
end
