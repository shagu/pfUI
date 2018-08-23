pfUI:RegisterSkin("Talents", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  HookAddonOrVariable("Blizzard_TalentUI", function()
    StripTextures(TalentFrame)
    CreateBackdrop(TalentFrame, nil, nil, .75)
    TalentFrame.backdrop:SetPoint("TOPLEFT", 13, -12)
    TalentFrame.backdrop:SetPoint("BOTTOMRIGHT", -31, 76)

    TalentFramePortrait:Hide()
    TalentFrameCancelButton:Hide()

    SkinCloseButton(TalentFrameCloseButton)

    StripTextures(TalentFrameScrollFrame)
    CreateBackdrop(TalentFrameScrollFrame)

    TalentFrameScrollFrame.backdrop:SetPoint("TOPLEFT", -1, 5)
    TalentFrameScrollFrame.backdrop:SetPoint("BOTTOMRIGHT", 6, -4)

    TalentFrameBackgroundTopLeft:SetPoint("TOPLEFT", TalentFrameScrollFrame.backdrop, "TOPLEFT", 1, -1)
    TalentFrameBackgroundBottomLeft:SetPoint("BOTTOMLEFT", TalentFrameScrollFrame.backdrop, "BOTTOMLEFT", 1, -55)
    TalentFrameBackgroundBottomRight:SetPoint("BOTTOMRIGHT", TalentFrameScrollFrame.backdrop, "BOTTOMRIGHT", 18, -55)

    SkinScrollbar(TalentFrameScrollFrameScrollBar, TalentFrameScrollFrame)
    TalentFrameScrollFrameScrollBar:SetPoint("TOPLEFT", TalentFrameScrollFrame, "TOPRIGHT", 10, -16)

    TalentFrameSpentPoints:SetPoint("TOP", 0, -48)
    TalentFrameTalentPointsText:SetPoint("BOTTOMRIGHT", TalentFrame, "BOTTOMRIGHT", -65, 83)

    for i = 1, MAX_NUM_TALENTS do
      local talent = _G["TalentFrameTalent"..i]
      if talent then
        StripTextures(talent)
        SkinButton(talent)

        local icon = _G["TalentFrameTalent"..i.."IconTexture"]
        SetAllPointsOffset(icon, talent, 2, 2)
        icon:SetTexCoord(.1,.9,.1,.9)
        icon:SetDrawLayer("ARTWORK")

        _G["TalentFrameTalent"..i.."Rank"]:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
      end
    end

    -- tabs
    TalentFrameTab1:ClearAllPoints()
    TalentFrameTab1:SetPoint("TOPLEFT", TalentFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
    for i = 1, 5 do
      local tab = _G["TalentFrameTab"..i]
      local lastTab = _G["TalentFrameTab"..(i-1)]
      if lastTab then
        tab:ClearAllPoints()
        tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
      end
      SkinTab(tab)
    end
  end)
end)
