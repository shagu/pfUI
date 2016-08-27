pfUI:RegisterModule("thirdparty", function ()
  -- DPSMate Integration
  -- Move DPSMate to right chat and let the chat-hide button toggle it
  if DPSMate and pfUI_config.thirdparty.dpsmate.enable == "1" then

    -- set DPSMate appearance to match pfUI
    DPSMateSettings["windows"][1]["titlebarheight"] = 18
    DPSMateSettings["windows"][1]["titlebarfontsize"] = 12
    DPSMateSettings["windows"][1]["titlebarfont"] = "Accidental Presidency"
    DPSMateSettings["windows"][1]["titlebarbgcolor"][1] = 0
    DPSMateSettings["windows"][1]["titlebarbgcolor"][2] = 0
    DPSMateSettings["windows"][1]["titlebarbgcolor"][3] = 0

    DPSMateSettings["windows"][1]["barheight"] = 15
    DPSMateSettings["windows"][1]["barfontsize"] = 12
    DPSMateSettings["windows"][1]["bartexture"] = "BantoBar"
    DPSMateSettings["windows"][1]["barfont"] = "Accidental Presidency"

    DPSMateSettings["windows"][1]["contentbgcolor"][1] = 0
    DPSMateSettings["windows"][1]["contentbgcolor"][2] = 0
    DPSMateSettings["windows"][1]["contentbgcolor"][3] = 0
    DPSMateSettings["windows"][1]["contentbgcolor"][3] = 0

    DPSMate_DPSMate:Hide()

    pfUIhookDPSMate_Show = DPSMate_DPSMate.Show
    function DPSMate_DPSMate.Show ()
      pfUIhookDPSMate_Show(DPSMate_DPSMate)
      DPSMate_DPSMate:ClearAllPoints()
      DPSMate_DPSMate:SetAllPoints(pfUI.chat.right)
      DPSMate_DPSMate:SetWidth(pfUI.chat.right:GetWidth()-6)
      DPSMate_DPSMate:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 3, -3)
      DPSMate_DPSMate:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -3, 3)

      if DPSMate_DPSMate_ScrollFrame then
        DPSMate_DPSMate_ScrollFrame:ClearAllPoints()
        DPSMate_DPSMate_ScrollFrame:SetAllPoints(pfUI.chat.right)
        DPSMate_DPSMate_ScrollFrame:SetWidth(pfUI.chat.right:GetWidth()-6)

        DPSMate_DPSMate_ScrollFrame:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 3, -23)
        DPSMate_DPSMate_ScrollFrame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", -3, 23)
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
