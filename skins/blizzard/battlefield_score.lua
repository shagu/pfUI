pfUI:RegisterSkin("Battlefield Score", "vanilla", function ()
  local rawborder, border = GetBorderSize()
  local bpad = rawborder > 1 and border - GetPerfectPixel() or GetPerfectPixel()

  StripTextures(WorldStateScoreFrame)
  CreateBackdrop(WorldStateScoreFrame, nil, nil, .75)
  CreateBackdropShadow(WorldStateScoreFrame)

  WorldStateScoreFrame.backdrop:SetPoint("TOPLEFT", 10, -14)
  WorldStateScoreFrame.backdrop:SetPoint("BOTTOMRIGHT", -112, 68)
  WorldStateScoreFrame:SetHitRectInsets(10,112,14,68)

  SkinCloseButton(WorldStateScoreFrameCloseButton, WorldStateScoreFrame.backdrop, -6, -6)

  WorldStateScoreFrameLabel:ClearAllPoints()
  WorldStateScoreFrameLabel:SetPoint("TOP", WorldStateScoreFrame.backdrop, "TOP", 0, -10)

  StripTextures(WorldStateScoreScrollFrame)
  SkinScrollbar(WorldStateScoreScrollFrameScrollBar)

  WorldStateScoreFrameTab1:ClearAllPoints()
  WorldStateScoreFrameTab1:SetPoint("TOPLEFT", WorldStateScoreFrame.backdrop, "BOTTOMLEFT", bpad, -(border + (border == 1 and 1 or 2)))
  for i = 1, 3 do
    local tab = _G["WorldStateScoreFrameTab"..i]
    local lastTab = _G["WorldStateScoreFrameTab"..(i-1)]
    if lastTab then
      tab:ClearAllPoints()
      tab:SetPoint("LEFT", lastTab, "RIGHT", border*2 + 1, 0)
    end
    SkinTab(tab)
  end

  SkinButton(WorldStateScoreFrameLeaveButton)
end)
