pfUI:RegisterModule("font", function ()
  pfUI.font = CreateFrame("Frame",nil,UIParent)
  pfUI.font:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.font:RegisterEvent("VARIABLES_LOADED")
  pfUI.font:RegisterEvent("ADDON_LOADED")

  pfUI.font:SetScript("OnEvent", function()
      pfUI.font:LoadFonts()
    end)

  function pfUI.font.LoadFonts()
    local font = "Interface\\AddOns\\pfUI\\fonts\\arial.ttf"
    local combat_font = "Interface\\AddOns\\pfUI\\fonts\\combat_font.ttf"

    STANDARD_TEXT_FONT = font;
    UNIT_NAME_FONT = font;
    DAMAGE_TEXT_FONT = combat_font;
    NAMEPLATE_FONT = font;

    SystemFont:SetFont(font, 15)
    GameFontNormal:SetFont(font, 12)
    GameFontBlack:SetFont(font, 12)
    GameFontNormalSmall:SetFont(font, 10)
    GameFontNormalLarge:SetFont(font, 16)
    GameFontNormalHuge:SetFont(font, 20)
    NumberFontNormal:SetFont(font, 14, "OUTLINE")
    NumberFontNormalSmall:SetFont(font, 14, "OUTLINE")
    NumberFontNormalLarge:SetFont(font, 16, "OUTLINE")
    NumberFontNormalHuge:SetFont(font, 30, "OUTLINE")
    QuestTitleFont:SetFont(font, 18)
    QuestFont:SetFont(font, 13)
    QuestFontHighlight:SetFont(font, 14)
    ItemTextFontNormal:SetFont(font, 15)
    MailTextFontNormal:SetFont(font, 15)
    SubSpellFont:SetFont(font, 10)
    DialogButtonNormalText:SetFont(font, 16)
    ZoneTextFont:SetFont(font, 48, "OUTLINE")
    SubZoneTextFont:SetFont(font, 24, "OUTLINE")
    TextStatusBarTextSmall:SetFont(font, 12, "NORMAL")
    GameTooltipText:SetFont(font, 12)
    GameTooltipTextSmall:SetFont(font, 10)
    GameTooltipHeaderText:SetFont(font, 14)
    WorldMapTextFont:SetFont(font, 102, "THICK")
    InvoiceTextFontNormal:SetFont(font, 12)
    InvoiceTextFontSmall:SetFont(font, 10)
    CombatTextFont:SetFont(font, 25)
    ChatFontNormal:SetFont(font, 12, "NORMAL")
  end
end)
