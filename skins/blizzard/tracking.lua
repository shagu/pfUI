pfUI:RegisterSkin("tracking", "tbc", function ()
  MINIMAP_TRACKING_FRAME:DisableDrawLayer("ARTWORK") -- hide border
  SkinButton(MINIMAP_TRACKING_FRAME, nil, nil, nil, MiniMapTrackingIcon, true)
  MINIMAP_TRACKING_FRAME:SetHeight(tonumber(C.appearance.minimap.tracking_size) + 10)
  MINIMAP_TRACKING_FRAME:SetWidth(tonumber(C.appearance.minimap.tracking_size) + 10)
  MINIMAP_TRACKING_FRAME:SetPoint("TOPLEFT", pfUI.minimap, -10, -10)
  UpdateMovable(MINIMAP_TRACKING_FRAME)
end)
