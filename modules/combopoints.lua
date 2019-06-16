pfUI:RegisterModule("combopoints", "vanilla", function ()
  -- Hide Blizzard combo point frame and unregister all events to prevent it from popping up again
  ComboFrame:Hide()
  ComboFrame:UnregisterAllEvents()

  local _, class = UnitClass("player")
  local combo_size = C["unitframes"]["combosize"]
  pfUI.combopoints = {}

  for point = 1, 5 do
    pfUI.combopoints[point] = CreateFrame("Frame", "pfCombo" .. point, UIParent)
    pfUI.combopoints[point]:SetFrameStrata("HIGH")
    pfUI.combopoints[point]:SetWidth(combo_size)
    pfUI.combopoints[point]:SetHeight(combo_size)
    pfUI.combopoints[point]:Hide()

    if pfUI.uf.target then
      pfUI.combopoints[point]:SetPoint("TOPLEFT", pfUI.uf.target, "TOPRIGHT", C.appearance.border.default*3, -(point - 1) * (combo_size + C.appearance.border.default*3))
    else
      pfUI.combopoints[point]:SetPoint("CENTER", UIParent, "CENTER", (point - 3) * (combo_size + C.appearance.border.default*3), 10 )
    end

    pfUI.combopoints[point].tex = pfUI.combopoints[point]:CreateTexture("OVERLAY")
    pfUI.combopoints[point].tex:SetAllPoints(pfUI.combopoints[point])

    if point < 3 then
      pfUI.combopoints[point].tex:SetTexture(1, .3, .3, .75)
    elseif point < 4 then
      pfUI.combopoints[point].tex:SetTexture(1, 1, .3, .75)
    else
      pfUI.combopoints[point].tex:SetTexture(.3, 1, .3, .75)
    end

    UpdateMovable(pfUI.combopoints[point])
    CreateBackdrop(pfUI.combopoints[point])
    CreateBackdropShadow(pfUI.combopoints[point])
  end

  function pfUI.combopoints:DisplayNum(num)
    for point=1, num do
      pfUI.combopoints[point]:Show()
    end

    for point=num+1, 5 do
      pfUI.combopoints[point]:Hide()
    end
  end

  -- combo
  if class == "DRUID" or class == "ROGUE" then
    local combo = CreateFrame("Frame")
    combo:RegisterEvent("UNIT_COMBO_POINTS")
    combo:RegisterEvent("PLAYER_COMBO_POINTS")
    combo:RegisterEvent("PLAYER_TARGET_CHANGED")
    combo:RegisterEvent("PLAYER_ENTERING_WORLD")
    combo:SetScript("OnEvent", function()
      pfUI.combopoints:DisplayNum(GetComboPoints("target"))
    end)
  end
end)
