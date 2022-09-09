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
    if event == "PLAYER_ENTERING_WORLD" then
      this.event = GetTime() + 3
    elseif this.event and this.event < GetTime() + .2 then
      this.event = GetTime() + .1
    end
  end)

  pfUI.hunterbar:SetScript("OnUpdate", function()
    -- we got an event 0.1s ago, scanning for new Skills
    if this.event and this.event <= GetTime() then
      this.event = nil
      this.melee = nil
      this.ranged = nil

      for i=1,120 do
        if this.melee and this.ranged then return end

        scanner:SetAction(i)

        local left = scanner:Line(1)
        if left then
          if left == L["hunterpaging"]["MELEE"] then
            this.melee = i
          elseif left == L["hunterpaging"]["RANGED"] then
            this.ranged = i
          end
        end
      end
    end

    -- skip further code when no abilities were found
    if not this.melee or not this.ranged then return end

    -- do the actual rangedetection and barswapping
    if IsActionInRange(this.melee) == 1 and IsActionInRange(this.ranged) == 0 then
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
