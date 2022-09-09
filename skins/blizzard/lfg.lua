pfUI:RegisterSkin("Looking for group", "tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(LFGParentFrame)
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

  LFGFrameClearAllButton:ClearAllPoints()
  LFGFrameClearAllButton:SetPoint("RIGHT", LFGFrameDoneButton, "LEFT", -2*bpad, 0)

  StripTextures(AutoJoinBackground)
  SkinCheckbox(AutoJoinCheckButton)

  StripTextures(AddMemberBackground)
  SkinCheckbox(AutoAddMembersCheckButton)

  CreateBackdrop(LFGComment)

  -- skin buttons
  local buttons = {
    "LFGWizardFrameLFGButton",
    "LFGWizardFrameLFMButton",
    "LFGFrameDoneButton",
    "LFGFrameClearAllButton",
    "LFMFrameGroupInviteButton",
    "LFMFrameSendMessageButton",
    "LFMFrameSearchButton",
    "LFMFrameColumnHeader1",
    "LFMFrameColumnHeader2",
    "LFMFrameColumnHeader3",
    "LFMFrameColumnHeader4",
  }

  for _, name in pairs(buttons) do
    SkinButton(_G[name])
  end

  -- skin dropdowns
  local dropdowns = {
    "LFGFrameTypeDropDown1",
    "LFGFrameNameDropDown1",
    "LFGFrameTypeDropDown2",
    "LFGFrameNameDropDown2",
    "LFGFrameTypeDropDown3",
    "LFGFrameNameDropDown3",
  }

  for _, name in pairs(dropdowns) do
    SkinDropDown(_G[name])
  end

  SkinDropDown(LFMFrameTypeDropDown, nil, nil, nil, true)
  SkinDropDown(LFMFrameNameDropDown, nil, nil, nil, true)
end)
