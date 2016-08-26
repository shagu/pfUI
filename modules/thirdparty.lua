pfUI:RegisterModule("thirdparty", function ()
  -- DPSMate Integration
  -- Move DPSMate to right chat and let the chat-hide button toggle it
  if DPSMate and pfUI_config.thirdparty.dpsmate.enable == "1" then
    DPSMate_DPSMate:Hide()

    pfUIhookDPSMate_Show = DPSMate_DPSMate.Show
    function DPSMate_DPSMate.Show ()
      pfUIhookDPSMate_Show(DPSMate_DPSMate)
      DPSMate_DPSMate:SetAllPoints(pfUI.chat.right)
      DPSMate_DPSMate:ClearAllPoints()
      DPSMate_DPSMate:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 3, -3)
      DPSMate_DPSMate:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -3, 3)

      if DPSMate_DPSMate_ScrollFrame then
        DPSMate_DPSMate_ScrollFrame:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 3, -23)
        DPSMate_DPSMate_ScrollFrame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -3, 3)
      end
    end

    pfUI.panel.right.hide:SetScript("OnClick", function()
      if DPSMate_DPSMate:IsShown() then
        DPSMate_DPSMate:Hide()
      else
        DPSMate_DPSMate:Show()
      end
    end)

  end
end)
