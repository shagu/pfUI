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

    DPSMateSettings["windows"][1]["bgopacity"] = 1
    DPSMateSettings["windows"][1]["opacity"] = 1
    DPSMateSettings["windows"][1]["contentbgtexture"] = "Solid Background"
    DPSMateSettings["windows"][1]["contentbgcolor"][1] = 0
    DPSMateSettings["windows"][1]["contentbgcolor"][2] = 0
    DPSMateSettings["windows"][1]["contentbgcolor"][3] = 0
    DPSMateSettings["windows"][1]["contentbgcolor"][3] = 0

    DPSMate_DPSMate:Hide()

    if not pfUIhookDPSMate_Show then
      pfUIhookDPSMate_Show = DPSMate_DPSMate.Show
    end
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

  -- WIM Integration
  -- Change the appearance of WIM windows to match pfUI
  if pfUI_config.thirdparty.wim.enable == "1" then

    local pfUIhookWIM = CreateFrame("Frame", nil)
    pfUIhookWIM:RegisterEvent("ADDON_LOADED")
    pfUIhookWIM:SetScript("OnEvent", function()
      if not pfUIhookWIM_PostMessage and WIM_PostMessage then
        pfUIhookWIM_PostMessage = WIM_PostMessage
        WIM_PostMessage = function(user, msg, ttype, from, raw_msg)
          pfUIhookWIM_PostMessage(user, msg, ttype, from, raw_msg)
          getglobal("WIM_msgFrame" .. user):SetBackdrop(pfUI.backdrop)
          getglobal("WIM_msgFrame" .. user .. "From"):ClearAllPoints()
          getglobal("WIM_msgFrame" .. user .. "From"):SetPoint("TOP", 0, -10)

          getglobal("WIM_msgFrame" .. user).avatar = CreateFrame("Frame", nil, getglobal("WIM_msgFrame" .. user))
          getglobal("WIM_msgFrame" .. user).avatar:SetAllPoints(getglobal("WIM_msgFrame" .. user))
          getglobal("WIM_msgFrame" .. user .. "ClassIcon"):SetTexCoord(.3, .7, .3, .7)
          getglobal("WIM_msgFrame" .. user .. "ClassIcon"):SetParent(getglobal("WIM_msgFrame" .. user).avatar)
          getglobal("WIM_msgFrame" .. user .. "ClassIcon"):ClearAllPoints()
          getglobal("WIM_msgFrame" .. user .. "ClassIcon"):SetPoint("TOPLEFT", 10 , -10)
          getglobal("WIM_msgFrame" .. user .. "ClassIcon"):SetWidth(26)
          getglobal("WIM_msgFrame" .. user .. "ClassIcon"):SetHeight(26)


          getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"):SetPoint("TOPLEFT", getglobal("WIM_msgFrame" .. user), "TOPLEFT", 10, -45)
          getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"):SetPoint("BOTTOMRIGHT", getglobal("WIM_msgFrame" .. user), "BOTTOMRIGHT", -32, 32)
          getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"):SetFont(STANDARD_TEXT_FONT, 12)

          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetBackdrop(pfUI.backdrop)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):ClearAllPoints()
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetPoint("TOPLEFT", getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"), "BOTTOMLEFT", 0, -2)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetPoint("TOPRIGHT", getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"), "BOTTOMRIGHT", 0, -2)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetTextInsets(5, 5, 5, 5)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetHeight(24)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "MsgBox"):GetRegions()}) do
            if i==6  then v:SetTexture(.1,.1,.1,.5) end
          end

          getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton1"):SetBackdrop(pfUI.backdrop)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton1"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton2"):SetBackdrop(pfUI.backdrop)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton2"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton3"):SetBackdrop(pfUI.backdrop)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton3"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton4"):SetBackdrop(pfUI.backdrop)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton4"):GetRegions()}) do
            if i >= 2 and i < 7then v:SetTexture(.1,.1,.1,0) end
          end

          getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton5"):SetBackdrop(pfUI.backdrop)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton5"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end
        end
      end
    end)
  end
end)
