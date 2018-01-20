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
end)
