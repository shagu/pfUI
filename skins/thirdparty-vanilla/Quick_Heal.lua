pfUI:RegisterSkin("Quick Heal", "vanilla", function ()
  HookAddonOrVariable("QuickHealHealingBar", function()
  -- To get more Glassic style comment CreateBackdrop

    StripTextures(QuickHealHealingBar)
    CreateBackdrop(QuickHealHealingBar)
    CreateBackdropShadow(QuickHealHealingBar)

    QuickHealHealingBarStatusBar:SetStatusBarTexture(pfUI.media["img:bar"])
    QuickHealHealingBarStatusBar:SetStatusBarColor(0.0, 1.0, 0.0)
    QuickHealHealingBarStatusBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

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
    QuickHealOverhealStatus:SetPoint("CENTER", QuickHealHealingBar, "CENTER", 0, 5)

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

  pfUI.api.HookAddonOrVariable("QuickHeal", function()
    local frames = {
      QuickHealConfig,
      QuickHeal_DownrankSlider
      -- QuickHealConfig_GeneralOptionsFrame,
      -- QuickHealConfig_MessagesAndNotificationFrame,
      -- QuickHealConfig_HealingTargetFilterFrame,
      -- MTListFrame,
      -- MeleeDPSListFrame,
    }
    for _, frame in pairs(frames) do
      StripTextures(frame)
      CreateBackdrop(frame)
      CreateBackdropShadow(frame)
    end

    local buttons = {
      QuickHealConfig_CloseButton,
      QuickHealConfig_DefaultButton,
    }
    for _, button in pairs(buttons) do
      SkinButton(button)
    end

    local checkboxes = {
      QuickHealConfig_CheckButtonNotificationWhisper,
      QuickHealConfig_CheckButtonNotificationChannel,
      QuickHealConfig_CheckButtonNotificationParty,
      QuickHealConfig_CheckButtonNotificationRaid,
      QuickHealConfig_CheckButtonDisplayHealingBar,
      QuickHealConfig_CheckButtonMessageScreenCenter,
      QuickHealConfig_CheckButtonMessageChatWindow,
      QuickHealConfig_CheckButtonOverhealMessageScreenCenter,
      QuickHealConfig_CheckButtonOverhealMessageCastingBar,
      QuickHealConfig_CheckButtonOverhealMessagePlaySound,
      QuickHealConfig_CheckButtonTargetPriority,
      QuickHealConfig_CheckButtonQuickClick,
      QuickHealConfig_FilterRaidGroup1CheckBox,
      QuickHealConfig_FilterRaidGroup2CheckBox,
      QuickHealConfig_FilterRaidGroup3CheckBox,
      QuickHealConfig_FilterRaidGroup4CheckBox,
      QuickHealConfig_FilterRaidGroup5CheckBox,
      QuickHealConfig_FilterRaidGroup6CheckBox,
      QuickHealConfig_FilterRaidGroup7CheckBox,
      QuickHealConfig_FilterRaidGroup8CheckBox,
    }
    for _, checkbox in pairs(checkboxes) do
      SkinCheckbox(checkbox)
    end

    local sliders = {
      QuickHealConfig_RatioFullSlider,
      QuickHealConfig_RatioHealthySlider,
      QuickHealConfig_RatioForceselfSlider,
      QuickHealConfig_PetPrioritySlider,
      QuickHealDownrank_Slider_NH,
      QuickHealDownrank_Slider_FH,
    }
    for _, slider in pairs(sliders) do
      SkinSlider(slider)
    end

    --SkinEditBox ???
    local editboxes = {
      QuickHealConfig_NotificationChannelNameEditBox,
    }
    for _, editbox in pairs(editboxes) do
      StripTextures(editbox)
      CreateBackdrop(editbox)
      CreateBackdropShadow(editbox)
    end

      QuickHealConfig_NotificationChannelNameEditBox:ClearAllPoints()
      QuickHealConfig_NotificationChannelNameEditBox:SetWidth(133)
      QuickHealConfig_NotificationChannelNameEditBox:SetHeight(22)
      QuickHealConfig_NotificationChannelNameEditBox:SetPoint("TOPLEFT", QuickHealConfig, "TOPLEFT", 139, -110)

    local dropdowns = {
      QuickHealConfig_ComboBoxNotificationStyle,
      QuickHealConfig_ComboBoxMessageConfigure,
      QuickHealConfig_ComboBoxNotificationChannel,
    }
    for _, dropdown in pairs(dropdowns) do
      SkinDropDown(dropdown)
    end

    for i = 1, 3 do
        local tab = _G["QuickHealConfigTab" .. i]
        if tab then
            SkinTab(tab)
            -- Adjust the position of each tab based on its index
            if i > 1 then
                local previousTab = _G["QuickHealConfigTab" .. (i - 1)]
                tab:SetPoint("TOPLEFT", previousTab, "TOPRIGHT", 3, 0)
            end
          end
       end
    end)
end)
