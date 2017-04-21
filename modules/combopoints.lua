pfUI:RegisterModule("combopoints", function ()
  -- Hide Blizzard combo point frame and unregister all events to prevent it from popping up again
  ComboFrame:Hide()
  ComboFrame:UnregisterAllEvents()

  pfUI.combopoints = CreateFrame("Frame")

  pfUI.combopoints:RegisterEvent("UNIT_COMBO_POINTS")
  pfUI.combopoints:RegisterEvent("PLAYER_COMBO_POINTS")
  pfUI.combopoints:RegisterEvent("UNIT_DISPLAYPOWER")
  pfUI.combopoints:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.combopoints:RegisterEvent('UNIT_ENERGY')
  pfUI.combopoints:RegisterEvent("PLAYER_ENTERING_WORLD")

  pfUI.combopoints:SetScript("OnEvent", function()
      if event == "PLAYER_ENTERING_WORLD" then
        local combo_size = C["unitframes"]["combosize"]

        for point=1, 5 do
          if not pfUI.combopoints["combopoint" .. point] then
            pfUI.combopoints["combopoint" .. point] = CreateFrame("Frame", "pfCombo" .. point, UIParent)
            pfUI.combopoints["combopoint" .. point]:SetFrameStrata("HIGH")
            pfUI.combopoints["combopoint" .. point]:SetWidth(combo_size)
            pfUI.combopoints["combopoint" .. point]:SetHeight(combo_size)
            CreateBackdrop(pfUI.combopoints["combopoint" .. point])

            if pfUI.uf.target then
              pfUI.combopoints["combopoint" .. point]:SetPoint("TOPLEFT", pfUI.uf.target, "TOPRIGHT", C.appearance.border.default*3, -(point - 1) * (combo_size + C.appearance.border.default*3))
            else
              pfUI.combopoints["combopoint" .. point]:SetPoint("CENTER", UIParent, "CENTER", (point - 3) * (combo_size + C.appearance.border.default*3), 10 )
            end
            UpdateMovable(pfUI.combopoints["combopoint" .. point])
          end

          if point < 3 then
            local tex = pfUI.combopoints["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(pfUI.combopoints["combopoint" .. point])
            tex:SetTexture(1, .3, .3, .75)
          elseif point < 4 then
            local tex = pfUI.combopoints["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(pfUI.combopoints["combopoint" .. point])
            tex:SetTexture(1, 1, .3, .75)
          else
            local tex = pfUI.combopoints["combopoint" .. point]:CreateTexture("OVERLAY")
            tex:SetAllPoints(pfUI.combopoints["combopoint" .. point])
            tex:SetTexture(.3, 1, .3, .75)
          end
          pfUI.combopoints["combopoint" .. point]:Hide()
        end
      else
        local combopoints = GetComboPoints("target")
        for point=1, 5 do
          pfUI.combopoints["combopoint" .. point]:Hide()
        end
        for point=1, combopoints do
          pfUI.combopoints["combopoint" .. point]:Show()
        end
      end
    end)
end)
