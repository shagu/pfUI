pfUI:RegisterSkin("Trainer", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  HookAddonOrVariable("Blizzard_TrainerUI", function()
    StripTextures(ClassTrainerFrame)
    CreateBackdrop(ClassTrainerFrame, nil, nil, .75)
    CreateBackdropShadow(ClassTrainerFrame)

    ClassTrainerFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    ClassTrainerFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    ClassTrainerFrame:SetHitRectInsets(10,32,10,72)
    EnableMovable(ClassTrainerFrame)

    SkinCloseButton(ClassTrainerFrameCloseButton, ClassTrainerFrame.backdrop, -6, -6)

    ClassTrainerFrame:DisableDrawLayer("BACKGROUND")

    ClassTrainerNameText:ClearAllPoints()
    ClassTrainerNameText:SetPoint("TOP", ClassTrainerFrame.backdrop, "TOP", 0, -10)
    ClassTrainerGreetingText:ClearAllPoints()
    ClassTrainerGreetingText:SetPoint("TOP", ClassTrainerNameText, "BOTTOM", 0, -4)

    SkinButton(ClassTrainerCancelButton)
    SkinButton(ClassTrainerTrainButton)
    ClassTrainerTrainButton:ClearAllPoints()
    ClassTrainerTrainButton:SetPoint("RIGHT", ClassTrainerCancelButton, "LEFT", -2*bpad, 0)

    SkinDropDown(ClassTrainerFrameFilterDropDown)

    StripTextures(ClassTrainerListScrollFrame)
    SkinScrollbar(ClassTrainerListScrollFrameScrollBar)

    StripTextures(ClassTrainerDetailScrollFrame)
    SkinScrollbar(ClassTrainerDetailScrollFrameScrollBar)

    StripTextures(ClassTrainerSkillIcon)
    SkinButton(ClassTrainerSkillIcon, nil, nil, nil, nil, true)
    hooksecurefunc("ClassTrainer_SetSelection", function()
      HandleIcon(ClassTrainerSkillIcon, ClassTrainerSkillIcon:GetNormalTexture())
    end, 1)

    StripTextures(ClassTrainerExpandButtonFrame)
    StripTextures(ClassTrainerCollapseAllButton)
    SkinCollapseButton(ClassTrainerCollapseAllButton, true)

    for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
      SkinCollapseButton(_G["ClassTrainerSkill"..i])
    end
  end)
end)
