pfUI:RegisterSkin("Spellbook", "vanilla:tbc", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(SpellBookFrame)
  CreateBackdrop(SpellBookFrame, nil, nil, .75)
  CreateBackdropShadow(SpellBookFrame)

  SpellBookFrame.backdrop:SetPoint("TOPLEFT", 12, -12)
  SpellBookFrame.backdrop:SetPoint("BOTTOMRIGHT", -30, 72)
  SpellBookFrame:SetHitRectInsets(12,30,12,72)
  EnableMovable(SpellBookFrame)

  SpellBookTitleText:ClearAllPoints()
  SpellBookTitleText:SetPoint("TOP", SpellBookFrame.backdrop, "TOP", 0, -10)

  SpellBookFrameTabButton1:ClearAllPoints()
  SpellBookFrameTabButton1:SetPoint("TOPLEFT", SpellBookFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  for i=1, 3 do
    local tab = _G["SpellBookFrameTabButton"..i]
    local lastTab = _G["SpellBookFrameTabButton"..(i-1)]
    if lastTab then
      tab:ClearAllPoints()
      tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
    end
    SkinTab(tab)
  end

  for i=1,SPELLS_PER_PAGE do
    local button = _G["SpellButton"..i]
    local texture = _G["SpellButton"..i.."IconTexture"]

    StripTextures(button)
    SkinButton(button, nil, nil, nil, texture)

    _G["SpellButton"..i.."SubSpellName"]:SetTextColor(1, 1, 1)
    _G["SpellButton"..i.."AutoCastable"]:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay")
    _G["SpellButton"..i.."Highlight"]:SetTexture("")
    _G["SpellButton"..i.."Highlight"].SetTexture = function(self, tex) return end
  end

  SpellBookSkillLineTab1:ClearAllPoints()
  SpellBookSkillLineTab1:SetPoint("TOPLEFT", SpellBookFrame.backdrop, "TOPRIGHT", border + (border == 1 and 1 or 2), -30)
  for i = 1, MAX_SKILLLINE_TABS do
    local button = _G["SpellBookSkillLineTab"..i]
    local lastbutton = _G["SpellBookSkillLineTab"..(i-1)]
    local texture = _G["SpellBookSkillLineTab"..i]:GetNormalTexture()

    StripTextures(button)
    SkinButton(button, nil, nil, nil, texture)

    button:SetScale(1.1)
    texture:SetTexCoord(.07,.93,.07,.93)

    if lastbutton then
      button:ClearAllPoints()
      button:SetPoint("TOP", lastbutton, "BOTTOM", 0, - (border + (border == 1 and 1 or 2) + bpad))
    end
  end

  SkinArrowButton(SpellBookPrevPageButton, "left", 18)
  SkinArrowButton(SpellBookNextPageButton, "right", 18)

  SkinCloseButton(SpellBookCloseButton, SpellBookFrame.backdrop, -6, -6)
  SpellBookPageText:SetTextColor(1, 1, 1)
end)
