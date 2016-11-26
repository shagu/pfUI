pfUI:RegisterModule("thirdparty", function ()
  pfUI.thirdparty = {}

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

      if DPSMate_DPSMate_ScrollFrame then
        DPSMate_DPSMate_ScrollFrame:ClearAllPoints()
        DPSMate_DPSMate_ScrollFrame:SetAllPoints(pfUI.chat.right)
        DPSMate_DPSMate_ScrollFrame:SetWidth(pfUI.chat.right:GetWidth())

        DPSMate_DPSMate_ScrollFrame:SetPoint("TOPLEFT", DPSMate_DPSMate_Head, "BOTTOMLEFT", 0, 0)
        DPSMate_DPSMate_ScrollFrame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, pfUI.panel.right:GetHeight())
        DPSMate_DPSMate_Resize:Hide()
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
          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user))
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

          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user .. "MsgBox"))
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):ClearAllPoints()
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetPoint("TOPLEFT", getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"), "BOTTOMLEFT", 0, -5)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetPoint("TOPRIGHT", getglobal("WIM_msgFrame" .. user .. "ScrollingMessageFrame"), "BOTTOMRIGHT", 0, -5)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetTextInsets(5, 5, 5, 5)
          getglobal("WIM_msgFrame" .. user .. "MsgBox"):SetHeight(20)
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "MsgBox"):GetRegions()}) do
            if i==6  then v:SetTexture(.1,.1,.1,.5) end
          end

          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton1"))
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton1"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton2"))
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton2"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton3"))
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton3"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton4"))
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton4"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end

          pfUI.utils:CreateBackdrop(getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton5"))
          for i,v in ipairs({getglobal("WIM_msgFrame" .. user .. "ShortcutFrameButton5"):GetRegions()}) do
            if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
          end
        end
      end
    end)
  end

  -- HealComm Integration
  -- Show HealComm bonus healthbars in pfUI frames
  pfUI.healComm = CreateFrame("Frame", nil)
  pfUI.healComm:RegisterEvent("UPDATE_FACTION")

  pfUI.healComm:SetScript("OnEvent", function ()
    -- return if already exists
    if pfUI.healComm.createIncHeal or pfUI_config.thirdparty.healcomm.enable == "0" then return end

    if AceLibrary and AceLibrary:HasInstance("HealComm-1.0") then
      local HealComm = AceLibrary("HealComm-1.0")
      local AceEvent = AceLibrary("AceEvent-2.0")

      function pfUI.healComm.createIncHeal(unit)
        if unit == "player" then
          if pfUI.uf.player and not pfUI.uf.player.incHeal then
            pfUI.uf.player.incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.player)
            pfUI.uf.player.incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            pfUI.uf.player.incHeal:SetMinMaxValues(0, 1)
            pfUI.uf.player.incHeal:SetValue(1)
            pfUI.uf.player.incHeal:SetStatusBarColor(0, 1, 0, 0.5)
            pfUI.uf.player.incHeal:SetHeight(pfUI.uf.player.hp:GetHeight())
            pfUI.uf.player.incHeal:Hide()
          end
          return pfUI.uf.player
        end

        if unit == "target" then
          if pfUI.uf.target and not pfUI.uf.target.incHeal then
            pfUI.uf.target.incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.target)
            pfUI.uf.target.incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            pfUI.uf.target.incHeal:SetMinMaxValues(0, 1)
            pfUI.uf.target.incHeal:SetValue(1)
            pfUI.uf.target.incHeal:SetStatusBarColor(0, 1, 0, 0.5)
            pfUI.uf.target.incHeal:SetHeight(pfUI.uf.target.hp:GetHeight())
            pfUI.uf.target.incHeal:Hide()
          end
          return pfUI.uf.target
        end

        if strsub(unit,0,5) == "party" then
          local id = tonumber(strsub(unit,6))
          if pfUI.uf.group[id] and not pfUI.uf.group[id].incHeal then
            pfUI.uf.group[id].incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.group[id])
            pfUI.uf.group[id].incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            pfUI.uf.group[id].incHeal:SetMinMaxValues(0, 1)
            pfUI.uf.group[id].incHeal:SetValue(1)
            pfUI.uf.group[id].incHeal:SetStatusBarColor(0, 1, 0, 0.5)
            pfUI.uf.group[id].incHeal:SetHeight(pfUI.uf.group[id].hp:GetHeight())
            pfUI.uf.group[id].incHeal:Hide()
          end
          return pfUI.uf.group[id]
        end

        if strsub(unit,0,4) == "raid" then
          local rid = tonumber(strsub(unit,5))
          local id = nil

          for i=1,40 do
            if pfUI.uf.raid[i] and pfUI.uf.raid[i].id == rid then id = i end
          end

          if id == nil then return end

          if pfUI.uf.raid[id] and not pfUI.uf.raid[id].incHeal then
            pfUI.uf.raid[id].incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.raid[id])
            pfUI.uf.raid[id].incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            pfUI.uf.raid[id].incHeal:SetMinMaxValues(0, 1)
            pfUI.uf.raid[id].incHeal:SetValue(1)
            pfUI.uf.raid[id].incHeal:SetStatusBarColor(0, 1, 0, 0.5)
            pfUI.uf.raid[id].incHeal:SetHeight(pfUI.uf.raid[id].hp:GetHeight())
            pfUI.uf.raid[id].incHeal:Hide()
          end
          return pfUI.uf.raid[id]
        end

        return nil
      end

      function pfUI.healComm.onEvent(unitname)
        if UnitName("target") == unitname then
          pfUI.healComm.onHeal("target")
        end

        if UnitName("player") == unitname then
          pfUI.healComm.onHeal("player")
        end

        if UnitInRaid("player") then
          for i=1,40 do
            if UnitName("raid" .. i) == unitname then
              pfUI.healComm.onHeal("raid" .. i)
            end
          end
        end

        for i=1,4 do
          if UnitName("party" .. i) == unitname then
            pfUI.healComm.onHeal("party" .. i)
          end
        end
      end

      function pfUI.healComm.onEventHealthChange(unit)
        pfUI.healComm.onHeal(unit)
      end

      function pfUI.healComm.TargetChanged()
        pfUI.healComm.onHeal("target")
      end

      function pfUI.healComm.onHeal(unit)
        local frame = pfUI.healComm.createIncHeal(unit)
        if not frame then return end

        local healed = HealComm:getHeal(UnitName(unit))

        local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
        if strsub(unit,0,4) == "raid" and pfUI_config.unitframes.raid.invert_healthbar == "1" then
          health = maxHealth - health
        end

        if( healed > 0 and (health < maxHealth or OVERHEALPERCENT > 0 )) and frame:IsVisible() then
          frame.incHeal:Show()
          local healthWidth = frame:GetWidth() * (health / maxHealth)
          local incWidth = (frame:GetWidth()-6) * (healed / maxHealth)
          if (healthWidth + incWidth) > (frame:GetWidth() * (1+(OVERHEALPERCENT/100)) ) then
            incWidth = frame:GetWidth() * (1+(OVERHEALPERCENT/100)) - healthWidth
          end
          frame.incHeal:SetWidth(incWidth)
          frame.incHeal:ClearAllPoints()

          if strsub(unit,0,4) == "raid" and pfUI_config.unitframes.raid.invert_healthbar == "1" then
            frame.incHeal:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            frame.incHeal:SetFrameStrata("HIGH")
          else
            frame.incHeal:SetPoint("TOPLEFT", frame, "TOPLEFT", healthWidth, 0)
          end
        else
          frame.incHeal:Hide()
        end
      end

      AceEvent:RegisterEvent("HealComm_Healupdate", pfUI.healComm.onEvent)
      AceEvent:RegisterEvent("UNIT_HEALTH", pfUI.healComm.onEventHealthChange)
      AceEvent:RegisterEvent("PLAYER_TARGET_CHANGED", pfUI.healComm.TargetChanged)
    end
  end)


  -- CleanUp Integration
  -- Integrate CleanUp bag sorting into pfUI
  if Clean_Up and pfUI_config.thirdparty.cleanup.enable == "1" then
    pfUI.thirdparty.cleanup = CreateFrame("Frame", nil)
    pfUI.thirdparty.cleanup:RegisterEvent("BAG_UPDATE")
    pfUI.thirdparty.cleanup:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.thirdparty.cleanup:SetScript("OnEvent", function()
      -- make sure bagframe was already created
      if not pfUI.bag or not pfUI.bag.right then return end
      pfUI.thirdparty.cleanup:UnregisterAllEvents()

      -- draw the button
      if not pfUI.bag.right.sort then
        pfUI.bag.right.sort = CreateFrame("Button", "pfBagSlotSort", UIParent)
        pfUI.bag.right.sort:SetParent(pfUI.bag.right)
        pfUI.bag.right.sort:SetPoint("TOPRIGHT", -pfUI_config.appearance.border.default*14 - 45, -pfUI_config.appearance.border.default)
        pfUI.bag.right.sort:SetPoint("TOPRIGHT", pfUI.bag.right.keys, "TOPLEFT", -pfUI_config.appearance.border.default*3, 0)

        pfUI.utils:CreateBackdrop(pfUI.bag.right.sort)
        pfUI.bag.right.sort:SetHeight(12)
        pfUI.bag.right.sort:SetWidth(12)
        pfUI.bag.right.sort:SetTextColor(1,1,.25,1)
        pfUI.bag.right.sort:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
        pfUI.bag.right.sort.texture = pfUI.bag.right.sort:CreateTexture("pfBagArrowUp")
        pfUI.bag.right.sort.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\sort")
        pfUI.bag.right.sort.texture:ClearAllPoints()
        pfUI.bag.right.sort.texture:SetPoint("TOPLEFT", pfUI.bag.right.sort, "TOPLEFT", 2, -2)
        pfUI.bag.right.sort.texture:SetPoint("BOTTOMRIGHT", pfUI.bag.right.sort, "BOTTOMRIGHT", -2, 2)
        pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)

        pfUI.bag.right.sort:SetScript("OnEnter", function ()
          pfUI.bag.right.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
          pfUI.bag.right.sort.texture:SetVertexColor(1,1,.25,1)
        end)

        pfUI.bag.right.sort:SetScript("OnLeave", function ()
          pfUI.utils:CreateBackdrop(pfUI.bag.right.sort)
          pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)
        end)

        pfUI.bag.right.sort:SetScript("OnClick", function()
          Clean_Up("bags")
        end)

        pfUI.bag.right.search:ClearAllPoints()
        pfUI.bag.right.search:SetPoint("TOPLEFT", pfUI.bag.right, "TOPLEFT", pfUI_config.appearance.border.default, -pfUI_config.appearance.border.default)
        pfUI.bag.right.search:SetPoint("TOPRIGHT", pfUI.bag.right.sort, "TOPLEFT", -pfUI_config.appearance.border.default*3, -pfUI_config.appearance.border.default)
      end

      -- draw the button
      if not pfUI.bag.left.sort then
        pfUI.bag.left.sort = CreateFrame("Button", "pfBankSlotSort", UIParent)
        pfUI.bag.left.sort:SetParent(pfUI.bag.left)
        pfUI.bag.left.sort:SetPoint("TOPRIGHT", -pfUI_config.appearance.border.default*14 - 45, -pfUI_config.appearance.border.default)
        pfUI.bag.left.sort:SetPoint("TOPRIGHT", pfUI.bag.left.bags, "TOPLEFT", -pfUI_config.appearance.border.default*3, 0)

        pfUI.utils:CreateBackdrop(pfUI.bag.left.sort)
        pfUI.bag.left.sort:SetHeight(12)
        pfUI.bag.left.sort:SetWidth(12)
        pfUI.bag.left.sort:SetTextColor(1,1,.25,1)
        pfUI.bag.left.sort:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", pfUI_config.global.font_size, "OUTLINE")
        pfUI.bag.left.sort.texture = pfUI.bag.left.sort:CreateTexture("pfBagArrowUp")
        pfUI.bag.left.sort.texture:SetTexture("Interface\\AddOns\\pfUI\\img\\sort")
        pfUI.bag.left.sort.texture:ClearAllPoints()
        pfUI.bag.left.sort.texture:SetPoint("TOPLEFT", pfUI.bag.left.sort, "TOPLEFT", 2, -2)
        pfUI.bag.left.sort.texture:SetPoint("BOTTOMRIGHT", pfUI.bag.left.sort, "BOTTOMRIGHT", -2, 2)
        pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)

        pfUI.bag.left.sort:SetScript("OnEnter", function ()
          pfUI.bag.left.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
          pfUI.bag.left.sort.texture:SetVertexColor(1,1,.25,1)
        end)

        pfUI.bag.left.sort:SetScript("OnLeave", function ()
          pfUI.utils:CreateBackdrop(pfUI.bag.left.sort)
          pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)
        end)

        pfUI.bag.left.sort:SetScript("OnClick", function()
          Clean_Up("bank")
        end)
      end
    end)
  end
end)
