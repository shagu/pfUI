pfUI:RegisterModule("infight", function ()
  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  -- build the frame
  pfUI.infight = CreateFrame("Frame", "pfUICombat", UIParent)

  pfUI.infight.backdrop = {
    edgeFile = "Interface\\AddOns\\pfUI\\img\\glow", edgeSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  }

  pfUI.infight.backdrop_outline = {
    edgeFile = "Interface\\AddOns\\pfUI\\img\\glow2", edgeSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
  }

  pfUI.infight.elements = {}

  function pfUI.infight:CreateGlow(unit, frame)
    local anchor = pfUI.uf[unit]
    if not pfUI.uf[unit] then anchor = frame end
    pfUI.infight[unit] = CreateFrame("Frame", "pfUICombat" .. unit,  anchor)
    pfUI.infight[unit]:SetFrameStrata("BACKGROUND")
    pfUI.infight[unit]:SetBackdrop(pfUI.infight.backdrop_outline)
    pfUI.infight[unit]:SetPoint("TOPLEFT", anchor, "TOPLEFT", -7 - default_border,7 + default_border)
    pfUI.infight[unit]:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 7 + default_border,-7 - default_border)
    pfUI.infight[unit]:Hide()
    table.insert(pfUI.infight.elements, unit)
  end

  pfUI.infight:SetScript("OnUpdate",function(s,e)
    if not pfUI.infight.clock then pfUI.infight.clock = GetTime() -0.1 end
    if GetTime() >= pfUI.infight.clock + 0.1 then
      pfUI.infight.clock = GetTime()

      if not pfUI.infight.fadeValue then  pfUI.infight.fadeValue = 1 end
      if pfUI.infight.fadeValue >= 0.3 then
        pfUI.infight.fadeModifier = -0.1
      end
      if pfUI.infight.fadeValue <= 0 then
        pfUI.infight.fadeModifier = 0.1
      end
      pfUI.infight.fadeValue = pfUI.infight.fadeValue + pfUI.infight.fadeModifier

      for _,unit in pairs (pfUI.infight.elements) do
        if UnitAffectingCombat(unit) then
          pfUI.infight[unit]:Show()
          pfUI.infight[unit]:SetBackdropBorderColor(1,0.2+pfUI.infight.fadeValue, pfUI.infight.fadeValue, 1-pfUI.infight.fadeValue);
        else
          pfUI.infight[unit]:Hide()
        end
      end

      if C.appearance.infight.screen == "1" and pfUI.infight.screen then
        if UnitAffectingCombat("player") then
          pfUI.infight.screen:Show()
          pfUI.infight.screen:SetBackdropBorderColor(1,0.2+pfUI.infight.fadeValue, pfUI.infight.fadeValue, 1-pfUI.infight.fadeValue);
        else
          pfUI.infight.screen:Hide()
        end
      end
    end
  end)

  if C.appearance.infight.screen == "1" then
    pfUI.infight.screen = CreateFrame("Frame", "pfUICombatScreen", UIParent)
    pfUI.infight.screen:SetFrameStrata("BACKGROUND")
    pfUI.infight.screen:SetBackdrop(pfUI.infight.backdrop)
    pfUI.infight.screen:SetAllPoints(WorldFrame)
    pfUI.infight.screen:Hide()
  end

  if C.appearance.infight.common == "1" then
    pfUI.infight:CreateGlow("player")
    pfUI.infight:CreateGlow("target")
    pfUI.infight:CreateGlow("targettarget")
    pfUI.infight:CreateGlow("pet")
  end

  if C.appearance.infight.group == "1" then
    for i=1,4 do
      pfUI.infight:CreateGlow("party" .. i, _G["pfGroup" .. i])
    end
  end
end)
