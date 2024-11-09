pfUI:RegisterSkin("Quick Heal", "vanilla", function ()
  HookAddonOrVariable("QuickHealHealingBar", function()
  -- To get more Glassic style:
  -- comment CreateBackdrop / CreateBackdropShadow
  -- uncomment QuickHealHealingBarBackground:Hide()

    StripTextures(QuickHealHealingBar)
    CreateBackdrop(QuickHealHealingBar)
    CreateBackdropShadow(QuickHealHealingBar)

    QuickHealHealingBarStatusBar:SetStatusBarTexture(pfUI.media["img:bar"])
    QuickHealHealingBarStatusBar:SetStatusBarColor(0.0, 1.0, 0.0)
    QuickHealHealingBarStatusBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    CreateBackdropShadow(QuickHealHealingBarStatusBar)

    QuickHealHealingBarStatusBarPost:SetStatusBarTexture(pfUI.media["img:bar"])
    QuickHealHealingBarStatusBarPost:SetStatusBarColor(0.0, 1.0, 0.0, 0.5)
    QuickHealHealingBarStatusBarPost:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    --QuickHealHealingBarBackground:Hide()
    QuickHealHealingBarBackground:SetTexture(pfUI.media["img:bar"])
    QuickHealHealingBarBackground:SetVertexColor(0.1, 0.1, 0.1, 0.8)
    QuickHealHealingBarSpark:SetTexture(pfUI.media["img:spark"])
    QuickHealHealingBarSpark:SetVertexColor(1.0, 1.0, 1.0, 1.0)

    QuickHealHealingBarText:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
    QuickHealOverhealStatus_Text:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    QuickHealHealingBar:ClearAllPoints()
    QuickHealHealingBar:SetWidth(186)
    QuickHealHealingBar:SetHeight(13)
    QuickHealHealingBar:SetPoint("CENTER", CastingBarFrame, "CENTER", 0, 30)

    QuickHealOverhealStatus:SetWidth(300)
    QuickHealOverhealStatus:SetHeight(13)
    QuickHealOverhealStatus:SetPoint("CENTER", QuickHealHealingBar, "CENTER", 0, 10)

    QuickHealHealingBarStatusBar:SetWidth(186)
    QuickHealHealingBarStatusBar:SetHeight(13)
    QuickHealHealingBarStatusBar:SetPoint("TOPLEFT", QuickHealHealingBar, "TOPLEFT", 0, 0)

    QuickHealHealingBarStatusBarPost:SetWidth(372)
    QuickHealHealingBarStatusBarPost:SetHeight(13)
    QuickHealHealingBarStatusBarPost:SetPoint("TOPLEFT", QuickHealHealingBar, "TOPLEFT", 0, 0)

    QuickHealHealingBarBackground:SetWidth(186)
    QuickHealHealingBarBackground:SetHeight(13)
    QuickHealHealingBarBackground:SetPoint("TOPLEFT", QuickHealHealingBarStatusBarPost, "TOPLEFT", 0, 0)

    QuickHealHealingBarText:SetWidth(196)
    QuickHealHealingBarText:SetHeight(16)
    QuickHealHealingBarText:SetPoint("CENTER", QuickHealHealingBar, "CENTER", 0, 0)

    QuickHealOverhealStatus_Text:SetPoint("BOTTOM", QuickHealOverhealStatus, "TOP", 0, 0)
  end)
end)
