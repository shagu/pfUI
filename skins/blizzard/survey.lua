pfUI:RegisterSkin("GM Survey", "vanilla", function ()
  HookAddonOrVariable("Blizzard_GMSurveyUI", function()
    StripTextures(GMSurveyFrame)
    CreateBackdrop(GMSurveyFrame, nil, nil, .75)
    CreateBackdropShadow(GMSurveyFrame)

    GMSurveyFrame.backdrop:SetPoint("TOPLEFT", 10, 0)
    GMSurveyFrame.backdrop:SetPoint("BOTTOMRIGHT", -72, 40)
    GMSurveyFrame:SetHitRectInsets(10,72,0,40)
    EnableMovable(GMSurveyFrame)

    SkinCloseButton(GMSurveyCloseButton, GMSurveyFrame.backdrop, -6, -6)

    StripTextures(GMSurveyHeader)
    GMSurveyHeaderText:ClearAllPoints()
    GMSurveyHeaderText:SetPoint("TOP", GMSurveyFrame.backdrop, "TOP", 0, -10)
    local answer_header = GetNoNameObject(GMSurveyFrame, "FontString", "BACKGROUND", GMSURVEY_REQUEST_TEXT)
    answer_header:ClearAllPoints()
    answer_header:SetPoint("TOP", GMSurveyFrame.backdrop, "TOP", 0, -35)

    for i = 1, 5 do
      StripTextures(_G["GMSurveyQuestion"..i])
    end

    SkinButton(GMSurveySubmitButton)
    GMSurveySubmitButton:ClearAllPoints()
    GMSurveySubmitButton:SetPoint("BOTTOMRIGHT", GMSurveyFrame.backdrop, "BOTTOMRIGHT", -10, 10)
    SkinButton(GMSurveyCancelButton)
    GMSurveyCancelButton:ClearAllPoints()
    GMSurveyCancelButton:SetPoint("BOTTOMLEFT", GMSurveyFrame.backdrop, "BOTTOMLEFT", 10, 10)

    CreateBackdrop(GMSurveyCommentFrame, nil, true, .75)
    SkinScrollbar(GMSurveyCommentScrollFrameScrollBar)
    GMSurveyFrameComment:SetMaxLetters(2000)
    hooksecurefunc("GMSurveyFrame_Update", function()
      GMSurveyFrameComment:SetWidth(505)
    end, 1)
  end)
end)
