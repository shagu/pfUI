pfUI:RegisterModule("hunterbar", "vanilla", function ()
  local _,class = UnitClass("player")
  if class ~= "HUNTER" or C.bars.hunterbar == "0" then return end

  pfUI.hunterbar = CreateFrame("Frame", "pfHunterBar", UIParent)
  local scanner = libtipscan:GetScanner("hunterbar")

  pfUI.hunterbar.melee = nil
  pfUI.hunterbar.ranged = nil
  pfUI.hunterbar.current = 1

  pfUI.hunterbar:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
  pfUI.hunterbar:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.hunterbar:SetScript("OnEvent", function()
    pfUI.hunterbar.melee = nil
    pfUI.hunterbar.ranged = nil

    for i=1,120 do
      if pfUI.hunterbar.melee and pfUI.hunterbar.ranged then return end

      scanner:SetAction(i)

      local left = scanner:Line(1)
      if left then
        if left == L["hunterpaging"]["MELEE"] then
          pfUI.hunterbar.melee = i
        elseif left == L["hunterpaging"]["RANGED"] then
          pfUI.hunterbar.ranged = i
        end
      end
    end
  end)

  pfUI.hunterbar:SetScript("OnUpdate", function()
    if not pfUI.hunterbar.melee or not pfUI.hunterbar.ranged then return end

    if IsActionInRange(pfUI.hunterbar.melee) == 1 and IsActionInRange(pfUI.hunterbar.ranged) == 0 then
      if _G.CURRENT_ACTIONBAR_PAGE == 1 then
        _G.CURRENT_ACTIONBAR_PAGE = 9
        ChangeActionBarPage()
      end
    else
      if _G.CURRENT_ACTIONBAR_PAGE == 9 then
        _G.CURRENT_ACTIONBAR_PAGE = 1
        ChangeActionBarPage()
      end
    end
  end)
end)
