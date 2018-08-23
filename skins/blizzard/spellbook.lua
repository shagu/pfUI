pfUI:RegisterSkin("Spellbook", function ()
  local border = tonumber(pfUI_config.appearance.border.default)
  local bpad = border > 1 and border - 1 or 1

  StripTextures(SpellBookFrame)
  CreateBackdrop(SpellBookFrame, nil, nil, .75)
  SpellBookFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
  SpellBookFrame.backdrop:SetPoint("BOTTOMRIGHT", -31, 75)

  SpellBookFrameTabButton1:SetPoint("TOPLEFT", SpellBookFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  for i=1,3 do
    local tab = _G["SpellBookFrameTabButton"..i]
    local lastTab = _G["SpellBookFrameTabButton"..(i-1)]
    tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)

    tab:GetNormalTexture():SetTexture("")
    tab:GetDisabledTexture():SetTexture("")
    SkinTab(tab)
  end

  for i=1,SPELLS_PER_PAGE do
    local button = _G["SpellButton"..i]
    local texture = _G["SpellButton"..i.."IconTexture"]

    StripTextures(button)
    CreateBackdrop(button)

    _G["SpellButton"..i.."AutoCastable"]:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")

    texture:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
    texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
    texture:SetTexCoord(.1,.9,.1,.9)

    button.backdrop:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    button.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
  end

  hooksecurefunc("SpellButton_UpdateButton", function()
    local name = this:GetName()
    _G[name.."SubSpellName"]:SetTextColor(1, 1, 1)
    _G[name.."Highlight"]:SetTexture(1, 1, 1, 0.3)
  end)

  SpellBookSkillLineTab1:ClearAllPoints()
  SpellBookSkillLineTab1:SetPoint("TOPLEFT", SpellBookFrame.backdrop, "TOPRIGHT", border + (border == 1 and 1 or 2), -30)
  for i = 1, MAX_SKILLLINE_TABS do
    local button = _G["SpellBookSkillLineTab"..i]
    local lastbutton = _G["SpellBookSkillLineTab"..(i-1)]
    local texture = _G["SpellBookSkillLineTab"..i]:GetNormalTexture()

    StripTextures(button)
    CreateBackdrop(button)

    texture:SetTexCoord(.07,.93,.07,.93)

    if lastbutton then
      button:ClearAllPoints()
      button:SetPoint("TOP", lastbutton, "BOTTOM", 0, - (border + (border == 1 and 1 or 2) + bpad))
    end

    function button.SetChecked(self, checked)
      if checked then
        self.backdrop:SetBackdropBorderColor(1,1,1)
      else
        CreateBackdrop(self)
      end
    end
  end

  SkinArrowButton(SpellBookPrevPageButton, "left")
  SpellBookPrevPageButton:SetWidth(18)
  SpellBookPrevPageButton:SetHeight(18)

  SkinArrowButton(SpellBookNextPageButton, "right")
  SpellBookNextPageButton:SetWidth(18)
  SpellBookNextPageButton:SetHeight(18)

  SkinCloseButton(SpellBookCloseButton)
  SpellBookPageText:SetTextColor(1, 1, 1)
end)
