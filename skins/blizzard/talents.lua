pfUI:RegisterSkin("Talents", "vanilla", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  HookAddonOrVariable("Blizzard_TalentUI", function()
    StripTextures(TalentFrame)
    CreateBackdrop(TalentFrame, nil, nil, .75)
    CreateBackdropShadow(TalentFrame)

    TalentFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
    TalentFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
    TalentFrame:SetHitRectInsets(10,32,10,72)
    EnableMovable(TalentFrame)

    TalentFrame:DisableDrawLayer("BACKGROUND")
    TalentFrameCancelButton:Hide()

    TalentFrameTitleText:ClearAllPoints()
    TalentFrameTitleText:SetPoint("TOP", TalentFrame.backdrop, "TOP", 0, -10)
    TalentFrameSpentPoints:ClearAllPoints()
    TalentFrameSpentPoints:SetPoint("TOP", TalentFrame.backdrop, "TOP", 0, -48)

    SkinCloseButton(TalentFrameCloseButton, TalentFrame.backdrop, -6, -6)

    StripTextures(TalentFrameScrollFrame)
    SkinScrollbar(TalentFrameScrollFrameScrollBar)

    TalentFrameTalentPointsText:ClearAllPoints()
    TalentFrameTalentPointsText:SetPoint("BOTTOMRIGHT", TalentFrame, "BOTTOMRIGHT", -65, 83)

    for i = 1, MAX_NUM_TALENTS do
      local talent = _G["TalentFrameTalent"..i]
      if talent then
        StripTextures(talent)
        SkinButton(talent, nil, nil, nil, _G["TalentFrameTalent"..i.."IconTexture"])

        _G["TalentFrameTalent"..i.."Rank"]:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
      end
    end

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
