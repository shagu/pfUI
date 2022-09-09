pfUI:RegisterModule("player", "vanilla:tbc", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  PlayerFrame:Hide()
  PlayerFrame:UnregisterAllEvents()

  pfUI.uf.player = pfUI.uf:CreateUnitFrame("Player", nil, C.unitframes.player)

  pfUI.uf.player:UpdateFrameSize()
  pfUI.uf.player:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", -75, 125)
  UpdateMovable(pfUI.uf.player)

  -- Replace default's RESET_INSTANCES button with an always working one
  UnitPopupButtons["RESET_INSTANCES_FIX"] = { text = RESET_INSTANCES, dist = 0 }
  for id, text in pairs(UnitPopupMenus["SELF"]) do
    if text == "RESET_INSTANCES" then
      UnitPopupMenus["SELF"][id] = "RESET_INSTANCES_FIX"
    end
  end

  hooksecurefunc("UnitPopup_OnClick", function()
    local button = this.value
    if button == "RESET_INSTANCES_FIX" then
      StaticPopup_Show("CONFIRM_RESET_INSTANCES")
    end
  end)
end)
