pfUI:RegisterSkin("Arena", "tbc", function ()
  StripTextures(ArenaFrame)
  CreateBackdrop(ArenaFrame, nil, nil, .75)
  CreateBackdropShadow(ArenaFrame)

  ArenaFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
  ArenaFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 72)
  ArenaFrame:SetHitRectInsets(10,32,10,72)
  EnableMovable(ArenaFrame)

  SkinCloseButton(ArenaFrameCloseButton, ArenaFrame.backdrop, -6, -6)

  ArenaFrame:DisableDrawLayer("BACKGROUND")

  ArenaFrameFrameLabel:ClearAllPoints()
  ArenaFrameFrameLabel:SetPoint("TOP", TabardFrame.backdrop, "TOP", 0, -10)

  ArenaFrame.zones_bg = CreateFrame("Frame", "ArenaFrameZonesBackground", ArenaFrame)
  CreateBackdrop(ArenaFrame.zones_bg, nil, nil, .7)
  ArenaFrame.zones_bg:SetWidth(324)
  ArenaFrame.zones_bg:SetHeight(204)
  ArenaFrame.zones_bg:SetPoint("TOPLEFT", ArenaFrame.backdrop, "TOPLEFT", 9, -62)

  ArenaFrame.tex1 = ArenaFrame.backdrop:CreateTexture("ArenaFrameWorldMap1", "ARTWORK")
  ArenaFrame.tex1:SetTexture("Interface\\BattlefieldFrame\\UI-Battlefield-WorldMap1")
  ArenaFrame.tex1:SetPoint("TOPLEFT", 11, -64)
  ArenaFrame.tex1:SetHeight(240)
  ArenaFrame.tex2 = ArenaFrame.backdrop:CreateTexture("ArenaFrameWorldMap2", "ARTWORK")
  ArenaFrame.tex2:SetTexture("Interface\\BattlefieldFrame\\UI-Battlefield-WorldMap2")
  ArenaFrame.tex2:SetPoint("LEFT", ArenaFrame.tex1, "RIGHT", 0, 0)
  ArenaFrame.tex2:SetHeight(240)

  ArenaFrameNameHeader:ClearAllPoints()
  ArenaFrameNameHeader:SetPoint("BOTTOMLEFT", ArenaFrameDivider, "TOPLEFT", 14, 70)
  local shift = 28
  ArenaZone1:ClearAllPoints()
  ArenaZone1:SetPoint("TOPLEFT", ArenaFrame, "TOPLEFT", 23, -79 - shift)
  ArenaZone4:ClearAllPoints()
  ArenaZone4:SetPoint("TOPLEFT", ArenaZone3, "TOPLEFT", 0, -85 + shift)

  ArenaFrame.textbox = CreateFrame("Frame", "ArenaFrameTextBox", ArenaFrame)
  ArenaFrame.textbox:SetWidth(324)
  ArenaFrame.textbox:SetHeight(110)
  CreateBackdrop(ArenaFrame.textbox)
  ArenaFrame.textbox:SetPoint("BOTTOM", ArenaFrame.backdrop, "BOTTOM", 0, 36)

  ArenaFrameZoneDescription:SetFontObject(GameFontWhite)
  ArenaFrameZoneDescription:ClearAllPoints()
  ArenaFrameZoneDescription:SetPoint("TOPLEFT", ArenaFrame.textbox, "TOPLEFT", 4, -4)
  ArenaFrameZoneDescription:SetPoint("BOTTOMRIGHT", ArenaFrame.textbox, "BOTTOMRIGHT", -4, 4)

  SkinButton(ArenaFrameCancelButton)
  SkinButton(ArenaFrameJoinButton)
  SkinButton(ArenaFrameGroupJoinButton)
end)
