pfUI:RegisterSkin("Macro", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  local f = CreateFrame("Frame")
  f:RegisterEvent("ADDON_LOADED")
  f:SetScript("OnEvent", function()
    if arg1 == "Blizzard_MacroUI" then
      StripTextures(MacroFrame)
      CreateBackdrop(MacroFrame, nil, nil, .9)
      EnableMovable(MacroFrame)

      MacroFrame:SetWidth(360)
      MacroFrame:SetHeight(460)

      SkinCloseButton(MacroFrameCloseButton, MacroFrame, -6, -6)
      SkinTab(MacroFrameTab1)
      SkinTab(MacroFrameTab2)
      MacroFrameTab2:SetPoint("LEFT", MacroFrameTab1, "RIGHT", 2*bpad + 4, 0)

      for i=1, 18 do
        local button = _G["MacroButton"..i]
        StripTextures(button)
        CreateBackdrop(button)
        button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
        button:SetCheckedTexture([[Interface\Buttons\CheckButtonHilight]])
        local icon = _G["MacroButton"..i..'Icon']
        icon:SetAllPoints(button)
        icon:SetTexCoord(.08, .92, .08, .92)
      end
      StripTextures(MacroFrameSelectedMacroButton)
      CreateBackdrop(MacroFrameSelectedMacroButton)
      MacroFrameSelectedMacroButtonIcon:SetAllPoints(MacroFrameSelectedMacroButton)
      MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)
      MacroFrameSelectedMacroName:SetPoint("TOPLEFT", MacroFrameSelectedMacroButton, "TOPRIGHT", 6, 3)

      SkinButton(MacroDeleteButton)
      MacroDeleteButton:ClearAllPoints()
      MacroDeleteButton:SetPoint("BOTTOMLEFT", 20, 17)
      SkinButton(MacroExitButton)
      MacroExitButton:ClearAllPoints()
      MacroExitButton:SetPoint("BOTTOMRIGHT", -20, 17)
      SkinButton(MacroNewButton)
      MacroNewButton:ClearAllPoints()
      MacroNewButton:SetPoint("RIGHT", MacroExitButton, "LEFT", -2*bpad, 0)
      SkinButton(MacroEditButton)

      MacroEditButton:ClearAllPoints()
      MacroEditButton:SetHeight(22)
      MacroEditButton:SetWidth(150)
      MacroEditButton:SetPoint("BOTTOMLEFT", MacroFrameSelectedMacroButton, "BOTTOMRIGHT", 6, -2)

      CreateBackdrop(MacroFrameTextBackground, nil, nil, 1)
      SkinScrollbar(MacroFrameScrollFrameScrollBar)
      MacroFrameCharLimitText:SetPoint("BOTTOM", MacroFrameTextBackground, "BOTTOM", 0, -16)

      StripTextures(MacroPopupFrame)
      CreateBackdrop(MacroPopupFrame, nil, nil, .9)
      StripTextures(MacroPopupScrollFrame)
      SkinScrollbar(MacroPopupScrollFrameScrollBar)

      MacroPopupNameLeft:SetTexture(nil)
      MacroPopupNameMiddle:SetTexture(nil)
      MacroPopupNameRight:SetTexture(nil)
      CreateBackdrop(MacroPopupEditBox)
      MacroPopupEditBox:SetScript("OnEscapePressed", function()
        MacroPopupFrame:Hide()
        MacroFrame_Update()
      end)

      for i=1, 20 do
        local button = _G["MacroPopupButton"..i]
        StripTextures(button)
        CreateBackdrop(button)
        button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]])
        button:SetCheckedTexture([[Interface\Buttons\CheckButtonHilight]])
        local icon = _G["MacroPopupButton"..i..'Icon']
        icon:SetAllPoints(button)
        icon:SetTexCoord(.08, .92, .08, .92)
      end
      SkinButton(MacroPopupCancelButton)
      SkinButton(MacroPopupOkayButton)
      MacroPopupOkayButton:ClearAllPoints()
      MacroPopupOkayButton:SetPoint("RIGHT", MacroPopupCancelButton, "LEFT", -2*bpad, 0)
    end
  end)
end)
