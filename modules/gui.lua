pfUI.gui = CreateFrame("Frame",nil,UIParent)

pfUI.gui:RegisterEvent("PLAYER_ENTERING_WORLD");

pfUI.gui:SetFrameStrata("DIALOG")
pfUI.gui:SetWidth(480)
pfUI.gui:SetHeight(320)
pfUI.gui:Hide()

pfUI.gui:SetBackdrop(pfUI.backdrop)
pfUI.gui:SetBackdropColor(0,0,0,.75);
pfUI.gui:SetPoint("CENTER",0,0)
pfUI.gui:SetMovable(true)
pfUI.gui:EnableMouse(true)
pfUI.gui:SetScript("OnMouseDown",function()
    pfUI.gui:StartMoving()
  end)
pfUI.gui:SetScript("OnMouseUp",function()
    pfUI.gui:StopMovingOrSizing()
  end)

function pfUI.gui.switchTab(frame)
  local elements = { pfUI.gui.global, pfUI.gui.uf }
  for _, hide in pairs(elements) do
    hide:Hide()
  end
  frame:Show()
end

-- Global Settings
pfUI.gui.global = CreateFrame("Frame", nil, pfUI.gui)
pfUI.gui.global:SetWidth(400)
pfUI.gui.global:SetHeight(320)

pfUI.gui.global:SetBackdrop(pfUI.backdrop)
pfUI.gui.global:SetBackdropColor(0,0,0,.50);
pfUI.gui.global:SetPoint("RIGHT",0,0)

pfUI.gui.global.switch = CreateFrame("Button", nil, pfUI.gui)
pfUI.gui.global.switch:ClearAllPoints()
pfUI.gui.global.switch:SetWidth(80)
pfUI.gui.global.switch:SetHeight(20)
pfUI.gui.global.switch:SetPoint("TOPLEFT", 0, 0)
pfUI.gui.global.switch:SetBackdrop(pfUI.backdrop)
pfUI.gui.global.switch.text = pfUI.gui.global.switch:CreateFontString("Status", "LOW", "GameFontNormal")
pfUI.gui.global.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")
pfUI.gui.global.switch.text:ClearAllPoints()
pfUI.gui.global.switch.text:SetAllPoints(pfUI.gui.global.switch)
pfUI.gui.global.switch.text:SetPoint("CENTER", 0, 0)
pfUI.gui.global.switch.text:SetFontObject(GameFontWhite)
pfUI.gui.global.switch.text:SetText("Global")
pfUI.gui.global.switch:SetScript("OnClick", function()
    pfUI.gui.switchTab(pfUI.gui.global)
  end)

pfUI.gui.global.title = pfUI.gui.global:CreateFontString("Status", "LOW", "GameFontNormal")
pfUI.gui.global.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 12, "OUTLINE")
pfUI.gui.global.title:SetPoint("TOP", 0, -10)
pfUI.gui.global.title:SetFontObject(GameFontWhite)
pfUI.gui.global.title:SetText("Global Settings")

-- UnitFrame settings
pfUI.gui.uf = CreateFrame("Frame", nil, pfUI.gui)
pfUI.gui.uf:SetWidth(400)
pfUI.gui.uf:SetHeight(320)

pfUI.gui.uf:SetBackdrop(pfUI.backdrop)
pfUI.gui.uf:SetBackdropColor(0,0,0,.50);
pfUI.gui.uf:SetPoint("RIGHT",0,0)

pfUI.gui.uf.switch = CreateFrame("Button", nil, pfUI.gui)
pfUI.gui.uf.switch:ClearAllPoints()
pfUI.gui.uf.switch:SetWidth(80)
pfUI.gui.uf.switch:SetHeight(20)
pfUI.gui.uf.switch:SetPoint("TOPLEFT", 0, -20)
pfUI.gui.uf.switch:SetBackdrop(pfUI.backdrop)
pfUI.gui.uf.switch.text = pfUI.gui.uf.switch:CreateFontString("Status", "LOW", "GameFontNormal")
pfUI.gui.uf.switch.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 9, "OUTLINE")
pfUI.gui.uf.switch.text:ClearAllPoints()
pfUI.gui.uf.switch.text:SetAllPoints(pfUI.gui.uf.switch)
pfUI.gui.uf.switch.text:SetPoint("CENTER", 0, 0)
pfUI.gui.uf.switch.text:SetFontObject(GameFontWhite)
pfUI.gui.uf.switch.text:SetText("UnitFrames")
pfUI.gui.uf.switch:SetScript("OnClick", function()
    pfUI.gui.switchTab(pfUI.gui.uf)
  end)

pfUI.gui.uf.title = pfUI.gui.uf:CreateFontString("Status", "LOW", "GameFontNormal")
pfUI.gui.uf.title:SetFont("Interface\\AddOns\\pfUI\\fonts\\arial.ttf", 12, "OUTLINE")
pfUI.gui.uf.title:SetPoint("TOP", 0, -10)
pfUI.gui.uf.title:SetFontObject(GameFontWhite)
pfUI.gui.uf.title:SetText("UnitFrame Settings")

pfUI.gui.switchTab(pfUI.gui.global)