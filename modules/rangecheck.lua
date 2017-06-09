pfUI:RegisterModule("rangecheck", function ()
  local _,class = UnitClass("player")

  if C.unitframes.rangecheck == "0" then return end

  pfUI.rangecheck = CreateFrame("Frame", "pfRangecheck", UIParent)
  pfUI.rangecheck.scanner = CreateFrame("GameTooltip", "pfRangecheckScanner", UIParent, "GameTooltipTemplate")
  pfUI.rangecheck.scanner:SetOwner(pfUI.rangecheck, "ANCHOR_NONE")

  pfUI.rangecheck.slot = nil
  pfUI.rangecheck.interval = C.unitframes.rangechecki

  pfUI.rangecheck:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
  pfUI.rangecheck:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.rangecheck:SetScript("OnEvent", function()
    pfUI.rangecheck.slot = nil

    for i=1,120 do
      if pfUI.rangecheck.slot then return end

      pfUI.rangecheck.scanner:ClearLines()
      pfUI.rangecheck.scanner:SetAction(i)

      if pfRangecheckScannerTextLeft1 and pfRangecheckScannerTextLeft1:GetText() then
        if pfRangecheckScannerTextLeft1:GetText() == L["rangecheck"][class] then
          pfUI.rangecheck.slot = i
        end
      end
    end
  end)
end)
