pfUI:RegisterSkin("Looking for group", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  CreateBackdrop(LFGParentFrame, nil, nil, .75)
  CreateBackdropShadow(LFGParentFrame)

  LFGParentFrame.backdrop:SetPoint("TOPLEFT", 14, -10)
  LFGParentFrame.backdrop:SetPoint("BOTTOMRIGHT", -26, 72)
  LFGParentFrame:SetHitRectInsets(14,26,10,72)
  EnableMovable(LFGParentFrame)

  SkinCloseButton(GetNoNameObject(LFGParentFrame, 'Button', nil, "UI-Panel-MinimizeButton-Up"), LFGParentFrame.backdrop, -6, -6)

  LFGParentFrame:DisableDrawLayer("BACKGROUND")

  LFGParentFrameTitle:ClearAllPoints()
  LFGParentFrameTitle:SetPoint("TOP", LFGParentFrame.backdrop, "TOP", 0, -10)

  SkinTab(LFGParentFrameTab1)
  LFGParentFrameTab1:ClearAllPoints()
  LFGParentFrameTab1:SetPoint("TOPLEFT", LFGParentFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  SkinTab(LFGParentFrameTab2)
  LFGParentFrameTab2:ClearAllPoints()
  LFGParentFrameTab2:SetPoint("LEFT", LFGParentFrameTab1, "RIGHT", border*2 + 1, 0)

  LFGParentFrameBackground:Hide()

  do -- LFGWizardFrame
    SkinButton(LFGWizardFrameLFGButton)
    SkinButton(LFGWizardFrameLFMButton)
  end

  do -- LFGFrame
    StripTextures(AutoJoinBackground)

    SkinCheckbox(AutoJoinCheckButton)

    SkinDropDown(LFGFrameTypeDropDown1)
    SkinDropDown(LFGFrameNameDropDown1)
    SkinDropDown(LFGFrameTypeDropDown2)
    SkinDropDown(LFGFrameNameDropDown2)
    SkinDropDown(LFGFrameTypeDropDown3)
    SkinDropDown(LFGFrameNameDropDown3)

    SkinButton(LFGFrameDoneButton)
    SkinButton(LFGFrameClearAllButton)
    LFGFrameClearAllButton:ClearAllPoints()
    LFGFrameClearAllButton:SetPoint("RIGHT", LFGFrameDoneButton, "LEFT", -2*bpad, 0)

    CreateBackdrop(LFGComment)
  end

  do -- LFMFrame
    StripTextures(AddMemberBackground)

    SkinCheckbox(AutoAddMembersCheckButton)

    SkinDropDown(LFMFrameTypeDropDown, nil, nil, nil, true)
    SkinDropDown(LFMFrameNameDropDown, nil, nil, nil, true)

    for i=1, 4 do
      SkinButton(_G["LFMFrameColumnHeader"..i])
    end

    SkinButton(LFMFrameGroupInviteButton)
    SkinButton(LFMFrameSendMessageButton)
    SkinButton(LFMFrameSearchButton)
  end
end)
