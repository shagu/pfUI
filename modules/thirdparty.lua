pfUI:RegisterModule("thirdparty", function ()
  pfUI.thirdparty = {}
  pfUI.thirdparty.meters = {}
  pfUI.thirdparty.meters.damage = false
  pfUI.thirdparty.meters.threat = false
  pfUI.thirdparty.meters.state = false
  pfUI.thirdparty.bagsort = nil

  local showmeter = CreateFrame("Frame")
  showmeter:SetScript("OnEvent", function()
    pfUI.thirdparty.meters.state = false
    pfUI.thirdparty.meters:Toggle()
    this:UnregisterAllEvents()
  end)

  function pfUI.thirdparty.meters:Resize()
    if pfUI.chat and pfUI.panel then

      if DPSMate_DPSMate and C.thirdparty.dpsmate.dock == "1" then
        -- DPSMate Single View
        if pfUI.thirdparty.meters.damage and not pfUI.thirdparty.meters.threat then
          DPSMate_DPSMate:ClearAllPoints()
          DPSMate_DPSMate:SetAllPoints(pfUI.chat.right)
          DPSMate_DPSMate:SetWidth(pfUI.chat.right:GetWidth())
          DPSMate_DPSMate_ScrollFrame:ClearAllPoints()
          DPSMate_DPSMate_ScrollFrame:SetWidth(pfUI.chat.right:GetWidth())
          DPSMate_DPSMate_ScrollFrame:SetPoint("TOPLEFT", DPSMate_DPSMate_Head, "BOTTOMLEFT", 0, 0)
          DPSMate_DPSMate_ScrollFrame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, pfUI.panel.right:GetHeight())
          DPSMate_DPSMate_ScrollFrame_Child:SetWidth(pfUI.chat.right:GetWidth())
          DPSMate_DPSMate_Resize:Hide()
        end

        -- DPSMate Dual View
        if pfUI.thirdparty.meters.damage and pfUI.thirdparty.meters.threat then
          DPSMate_DPSMate:ClearAllPoints()
          DPSMate_DPSMate:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", 0, 0)
          DPSMate_DPSMate:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 0)
          DPSMate_DPSMate:SetWidth(pfUI.chat.right:GetWidth() / 2)
          DPSMate_DPSMate_ScrollFrame:ClearAllPoints()
          DPSMate_DPSMate_ScrollFrame:SetWidth(pfUI.chat.right:GetWidth() / 2)
          DPSMate_DPSMate_ScrollFrame:SetPoint("TOPLEFT", DPSMate_DPSMate_Head, "BOTTOMLEFT", 0, 0)
          DPSMate_DPSMate_ScrollFrame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, pfUI.panel.right:GetHeight())
          DPSMate_DPSMate_ScrollFrame_Child:SetWidth(pfUI.chat.right:GetWidth() / 2)
          DPSMate_DPSMate_Resize:Hide()
        end
      end

      if SW_BarFrame1 and C.thirdparty.swstats.dock == "1" then
        -- SWStats Single View
        if pfUI.thirdparty.meters.damage and not pfUI.thirdparty.meters.threat then
          SW_BarFrame1:SetWidth(pfUI.chat.right:GetWidth())
          SW_BarFrame1:ClearAllPoints()
          SW_BarFrame1:SetAllPoints(pfUI.chat.right)
          SW_BarFrame1_Resizer:Hide()
          SW_BarsLayout("SW_BarFrame1", true)
        end

        -- SWStats Dual View
        if pfUI.thirdparty.meters.damage and pfUI.thirdparty.meters.threat then
          SW_BarFrame1:SetWidth(pfUI.chat.right:GetWidth() / 2)
          SW_BarFrame1:ClearAllPoints()
          SW_BarFrame1:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", 0, 0)
          SW_BarFrame1:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0 ,0)
          SW_BarFrame1_Resizer:Hide()
          SW_BarsLayout("SW_BarFrame1", true)
        end
      end

      if KLHTM_Frame and C.thirdparty.ktm.dock == "1" then
        -- KLHTM Single View
        if not pfUI.thirdparty.meters.damage and pfUI.thirdparty.meters.threat then
          KLHTM_Frame:SetWidth(pfUI.chat.right:GetWidth())
          KLHTM_Frame:ClearAllPoints()
          KLHTM_Frame:SetAllPoints(pfUI.chat.right)
        end

        -- KLHTM Dual View
        if pfUI.thirdparty.meters.damage and pfUI.thirdparty.meters.threat then
          KLHTM_Frame:SetWidth(pfUI.chat.right:GetWidth() / 2)
          KLHTM_Frame:ClearAllPoints()
          KLHTM_Frame:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 0, 0)
          KLHTM_Frame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOM", -C.appearance.border.default, 0)
        end
      end
    end
  end

  function pfUI.thirdparty.meters:Toggle()
    pfUI.thirdparty.meters:Resize()

    -- show meters
    if pfUI.thirdparty.meters.state == false then
      pfUI.thirdparty.meters.state = true

      -- chat
      if pfUI.chat and C.chat.right.enable == "1" then
        pfUI.chat.right:SetAlpha(0)
      end

      -- ktm
      if C.thirdparty.ktm.dock == "1" and KLHTM_Frame then
        KLHTM_SetVisible(true)
        KLHTM_Frame:Show()
      end

      -- dpsmate
      if C.thirdparty.dpsmate.dock == "1" and DPSMate_DPSMate then
        DPSMate_DPSMate:Show()
      end

      -- swstats
      if C.thirdparty.swstats.dock == "1" and SW_BarFrame1 then
        SW_BarFrame1:Show()
        SW_OptKey(1)
      end

    -- hide meters
    else
      pfUI.thirdparty.meters.state = false

      -- chat
      if pfUI.chat and C.chat.right.enable == "1" then
        pfUI.chat.right:SetAlpha(1)
      end

      -- ktm
      if C.thirdparty.ktm.dock == "1" and KLHTM_Frame then
        KLHTM_SetVisible(false)
        KLHTM_Frame:Hide()
      end

      -- dpsmate
      if C.thirdparty.dpsmate.dock == "1" and DPSMate_DPSMate then
        DPSMate_DPSMate:Hide()
      end

      -- swstats
      if C.thirdparty.swstats.dock == "1" and SW_BarFrame1 then
        SW_BarFrame1:Hide()
      end
    end
  end

  HookAddonOrVariable("KLHThreatMeter", function()
    if C.thirdparty.ktm.skin == "1" then
      -- remove titlebar
      KLHTM_Gui.title.back:Hide()
      KLHTM_SetGuiScale(.9)

      CreateBackdrop(KLHTM_Frame, nil, nil, (C.thirdparty.chatbg == "1" and .8))

      if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
        local r, g, b, a = strsplit(",", C.chat.global.background)
        KLHTM_Frame.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

        local r, g, b, a = strsplit(",", C.chat.global.border)
        KLHTM_Frame.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
      end

      -- theme buttons
      local buttons = { "KLHTM_TitleFrameClose", "KLHTM_TitleFrameMinimise",
        "KLHTM_TitleFrameMaximise", "KLHTM_TitleFrameOptions", "KLHTM_TitleFramePin",
        "KLHTM_TitleFrameUnpin", "KLHTM_TitleFrameSelfView", "KLHTM_TitleFrameRaidView",
        "KLHTM_TitleFrameMasterTarget", "KLHTM_SelfFrameBottomReset" }

      for i, button in pairs(buttons) do
        local b = _G[button]
        if not b then return end
        SkinButton(b)
        b:SetScale(.8)

        -- remove red background on some buttons
        for i,v in ipairs({b:GetRegions()}) do
          if v.SetTexture and i == 1 then
            v:SetTexture(0,0,0,0)
          end
        end

        local p,rt,rp,xo,yo = b:GetPoint()
        if not b.pfSet and i > 1 then
          b:SetPoint(p,rt,rp,xo - 3,yo)
          b.pfSet = true
        end
      end

      -- name buttons
      KLHTM_TitleFrameClose:SetText("x")
      KLHTM_TitleFrameMinimise:SetText("_")
      KLHTM_TitleFrameMaximise:SetText("_")
      KLHTM_TitleFrameOptions:SetText("O")
      KLHTM_TitleFramePin:SetText("P")
      KLHTM_TitleFrameUnpin:SetText("U")
      KLHTM_TitleFrameSelfView:SetText("S")
      KLHTM_TitleFrameRaidView:SetText("R")
      KLHTM_TitleFrameMasterTarget:SetText("T")

      -- skin rows (raid)
      for i in pairs(KLHTM_Gui.raid.rows) do
        KLHTM_Gui.raid.rows[i].bar:SetTexture("Interface\\AddOns\\pfUI\\img\\bar")
        KLHTM_Gui.raid.rows[i].bar:SetAlpha(.75)

        if _G["KLHTM_RaidFrameRow" .. i .. "NameText"] then
          _G["KLHTM_RaidFrameRow" .. i .. "NameText"]:SetFont(pfUI.font_default, 13, "OUTLINE")
          _G["KLHTM_RaidFrameRow" .. i .. "ThreatText"]:SetFont(pfUI.font_default, 13, "OUTLINE")
          _G["KLHTM_RaidFrameRow" .. i .. "PercentThreatText"]:SetFont(pfUI.font_default, 13, "OUTLINE")
        end
      end

      KLHTM_RaidFrameHeaderNameText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameHeaderThreatText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameHeaderPercentThreatText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameBottomThreatDefecitText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameBottomMasterTargetText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameHeaderName:SetHeight(12)

      -- skin rows (self)
      for i in pairs(KLHTM_Gui.self.rows) do
        KLHTM_Gui.self.rows[i].bar:SetTexture("Interface\\AddOns\\pfUI\\img\\bar")
        KLHTM_Gui.self.rows[i].bar:SetAlpha(.75)
      end

      -- remove seperators
      if KLHTM_RaidFrameLine then KLHTM_RaidFrameLine:Hide() end
      if KLHTM_RaidFrameBottomLine then KLHTM_RaidFrameBottomLine:Hide() end
      if KLHTM_SelfFrameLine then KLHTM_SelfFrameLine:Hide() end
      if KLHTM_SelfFrameBottomLine then KLHTM_SelfFrameBottomLine:Hide() end
    end

    if C.thirdparty.ktm.dock == "1" then
      pfUI.thirdparty.meters.threat = true

      KLHTM_Frame:Hide()

      if pfUI.panel then
        pfUI.panel.right.hide:SetScript("OnClick", function()
          pfUI.thirdparty.meters:Toggle()
        end)
      end

      -- toggle meter by default if configured
      if C.thirdparty.showmeter == "1" then
        showmeter:RegisterEvent("PLAYER_ENTERING_WORLD")
      end
    end
  end)

  HookAddonOrVariable("DPSMate", function()
    if C.thirdparty.dpsmate.skin == "1" then
      if DPSMateSettings then
        -- set DPSMate appearance to match pfUI
        for w in pairs(DPSMateSettings["windows"]) do
          DPSMateSettings["windows"][w]["titlebarheight"] = 20
          DPSMateSettings["windows"][w]["titlebarfontsize"] = 12
          DPSMateSettings["windows"][w]["titlebarfont"] = "Accidental Presidency"
          DPSMateSettings["windows"][w]["titlebaropacity"] = 0

          DPSMateSettings["windows"][w]["titlebarfontcolor"][1] = 1
          DPSMateSettings["windows"][w]["titlebarfontcolor"][2] = 1
          DPSMateSettings["windows"][w]["titlebarfontcolor"][3] = 1

          DPSMateSettings["windows"][w]["barheight"] = 11
          DPSMateSettings["windows"][w]["barfontsize"] = 13
          DPSMateSettings["windows"][w]["bartexture"] = "normTex"
          DPSMateSettings["windows"][w]["barfont"] = "Accidental Presidency"

          DPSMateSettings["windows"][w]["opacity"] = 1
          DPSMateSettings["windows"][w]["contentbgtexture"] = "Solid Background"
          DPSMateSettings["windows"][w]["bgopacity"] = 0
          DPSMateSettings["windows"][w]["borderopacity"] = 0
        end

        DPSMate:InitializeFrames()

        for k, val in pairs(DPSMateSettings["windows"]) do
          local frame = _G["DPSMate_"..val["name"]]
          CreateBackdrop(frame, nil, nil, (C.thirdparty.chatbg == "1" and .8))

          if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
            local r, g, b, a = strsplit(",", C.chat.global.background)
            frame.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

            local r, g, b, a = strsplit(",", C.chat.global.border)
            frame.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
          end
        end
      end
    end

    if C.thirdparty.dpsmate.dock == "1" then
      pfUI.thirdparty.meters.damage = true

      if DPSMate_DPSMate then
        DPSMate_DPSMate:Hide()
      end

      if pfUI.panel then
        pfUI.panel.right.hide:SetScript("OnClick", function()
          pfUI.thirdparty.meters:Toggle()
        end)
      end

      -- toggle meter by default if configured
      if C.thirdparty.showmeter == "1" then
        showmeter:RegisterEvent("PLAYER_ENTERING_WORLD")
      end
    end
  end)

  HookAddonOrVariable("SW_Stats", function()
    if C.thirdparty.swstats.skin == "1" then
      SW_Settings["OPT_ShowMainWinDPS"] = 1
      SW_Settings["Colors"] = SW_Settings["Colors"] or {}
      SW_Settings["Colors"]["TitleBarsFont"] = { [1] = 1, [2] = 1, [3] = 1,	[4] = 1, }
      SW_Settings["Colors"]["TitleBars"] = { [1] = 0, [2] = 0, [3] = 0,	[4] = 0, }
      SW_Settings["Colors"]["Backdrops"] = { [1] = .3, [2] = 1, [3] = .8,	[4] = 1, }

      SW_Settings["InfoSettings"] = SW_Settings["InfoSettings"] or {}
      SW_Settings["InfoSettings"][1] = SW_Settings["InfoSettings"][1] or {}
      SW_Settings["InfoSettings"][1]["SF"] = "SW_Filter_EverGroup"
      SW_Settings["InfoSettings"][1]["ShowPercent"] = 1
      SW_Settings["InfoSettings"][1]["ShowRank"] = 1
      SW_Settings["InfoSettings"][1]["ShowNumber"] = 1
      SW_Settings["InfoSettings"][1]["BT"] = 13
      SW_Settings["InfoSettings"][1]["BH"] = 10
      SW_Settings["InfoSettings"][1]["BFS"] = 11
      SW_Settings["InfoSettings"][1]["BC"]  = { [1] = .5, [2] = .5, [3] = .5, [4] = .5, }
      SW_Settings["InfoSettings"][1]["BFC"] = { [1] = 1,  [2] = 1,  [3] = 1,  [4] = 1, }
      SW_Settings["InfoSettings"][1]["OC"]  = { [1] = 1,  [2] = 1,  [3] = 1,  [4] = 1, }
      SW_Settings["InfoSettings"][1]["OTF"] = ( SW_Settings["InfoSettings"][1]["OTF"] == "1" and "SWStats" ) or SW_Settings["InfoSettings"][1]["OTF"]
      SW_Settings["InfoSettings"][1]["UCC"] = 1

      SW_BarFrame1_Title:SetPoint("TOPLEFT", 3, 0)
      SW_BarFrame1_Title_Sync:SetScale(.84)
      SW_BarFrame1_Title_Report:SetScale(.84)
      SW_BarFrame1_Title_Settings:SetScale(.84)
      SW_BarFrame1_Title_Close:SetScale(.84)
      SW_BarFrame1_Title_Console:SetScale(.84)
      SW_BarFrame1_Title_TimeLine:SetScale(.84)
      SW_BarFrame1_Title_TimeLine:SetScale(.84)

      -- bar padding
      SW_BarFrame1.swoBarY = -22
      _G.SW_BARSEPY = 1

      CreateBackdrop(SW_BarFrame1, nil, nil, (C.thirdparty.chatbg == "1" and .8))

      if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
        local r, g, b, a = strsplit(",", C.chat.global.background)
        SW_BarFrame1.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

        local r, g, b, a = strsplit(",", C.chat.global.border)
        SW_BarFrame1.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
      end

      CreateBackdrop(SW_BarSettingsFrameV2)
      CreateBackdrop(SW_BarSettingsFrameV2_Title, 0)
      CreateBackdrop(SW_BarSettingsFrameV2_Tab1, 0)
      SW_BarSettingsFrameV2_Tab1:SetHeight(24)
      CreateBackdrop(SW_BarSettingsFrameV2_Tab2, 0)
      SW_BarSettingsFrameV2_Tab2:SetHeight(24)
      CreateBackdrop(SW_BarSettingsFrameV2_Tab3, 0)
      SW_BarSettingsFrameV2_Tab3:SetHeight(24)

      CreateBackdrop(SW_BarReportFrame)
      CreateBackdrop(SW_BarReportFrame_Title, 0)
    end

    if C.thirdparty.swstats.dock == "1" then
      pfUI.thirdparty.meters.damage = true

      SW_Settings["SHOWMAIN"] = nil
      SW_BarFrame1:Hide()

      -- hide bottom panels
      SW_OptChk_Running:Hide()
      SW_BarFrame1_Selector:Hide()

      if pfUI.panel then
        pfUI.panel.right.hide:SetScript("OnClick", function()
          pfUI.thirdparty.meters:Toggle()
        end)
      end

      -- toggle meter by default if configured
      if C.thirdparty.showmeter == "1" then
        showmeter:RegisterEvent("PLAYER_ENTERING_WORLD")
      end
    end
  end)

  HookAddonOrVariable("WIM", function()
    if C.thirdparty.wim.enable == "0" then return end

    _G.WIM_isLinkURL = function() return false end

    hooksecurefunc("WIM_WindowOnShow", function()
      -- blue shaman
      _G.WIM_ClassColors[WIM_LOCALIZED_SHAMAN]	= "0070de"

      local windowname = this:GetName()

      CreateBackdrop(_G[windowname], nil, nil, .8)
      _G[windowname .. "From"]:ClearAllPoints()
      _G[windowname .. "From"]:SetPoint("TOP", 0, -10)

      _G[windowname].avatar = CreateFrame("Frame", nil, _G[windowname])
      _G[windowname].avatar:SetAllPoints(_G[windowname])
      _G[windowname .. "ClassIcon"]:SetTexCoord(.3, .7, .3, .7)
      _G[windowname .. "ClassIcon"]:SetParent(_G[windowname].avatar)
      _G[windowname .. "ClassIcon"]:ClearAllPoints()
      _G[windowname .. "ClassIcon"]:SetPoint("TOPLEFT", 10 , -10)
      _G[windowname .. "ClassIcon"]:SetWidth(26)
      _G[windowname .. "ClassIcon"]:SetHeight(26)

      _G[windowname .. "ScrollingMessageFrame"]:SetPoint("TOPLEFT", _G[windowname], "TOPLEFT", 10, -45)
      _G[windowname .. "ScrollingMessageFrame"]:SetPoint("BOTTOMRIGHT", _G[windowname], "BOTTOMRIGHT", -32, 32)
      _G[windowname .. "ScrollingMessageFrame"]:SetFont(pfUI.font_default, 12)

      CreateBackdrop(_G[windowname .. "MsgBox"])
      _G[windowname .. "MsgBox"]:ClearAllPoints()
      _G[windowname .. "MsgBox"]:SetPoint("TOPLEFT", _G[windowname .. "ScrollingMessageFrame"], "BOTTOMLEFT", 0, -5)
      _G[windowname .. "MsgBox"]:SetPoint("TOPRIGHT", _G[windowname .. "ScrollingMessageFrame"], "BOTTOMRIGHT", 0, -5)
      _G[windowname .. "MsgBox"]:SetTextInsets(5, 5, 5, 5)
      _G[windowname .. "MsgBox"]:SetHeight(20)
      for i,v in ipairs({_G[windowname .. "MsgBox"]:GetRegions()}) do
        if i==6  then v:SetTexture(.1,.1,.1,.5) end
      end

      CreateBackdrop(_G[windowname .. "ShortcutFrameButton1"])
      for i,v in ipairs({_G[windowname .. "ShortcutFrameButton1"]:GetRegions()}) do
        if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
      end

      CreateBackdrop(_G[windowname .. "ShortcutFrameButton2"])
      for i,v in ipairs({_G[windowname .. "ShortcutFrameButton2"]:GetRegions()}) do
        if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
      end

      CreateBackdrop(_G[windowname .. "ShortcutFrameButton3"])
      for i,v in ipairs({_G[windowname .. "ShortcutFrameButton3"]:GetRegions()}) do
        if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
      end

      CreateBackdrop(_G[windowname .. "ShortcutFrameButton4"])
      for i,v in ipairs({_G[windowname .. "ShortcutFrameButton4"]:GetRegions()}) do
        if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
      end

      CreateBackdrop(_G[windowname .. "ShortcutFrameButton5"])
      for i,v in ipairs({_G[windowname .. "ShortcutFrameButton5"]:GetRegions()}) do
        if i >= 2 and i < 7 then v:SetTexture(.1,.1,.1,0) end
      end
    end)
  end)

  HookAddonOrVariable("SortBags", function()
    if C.thirdparty.sortbags.enable == "0" then return end

    if not pfUI.thirdparty.bagsort then pfUI.thirdparty.bagsort = "sortbags" end
    pfUI.thirdparty.sortbags = CreateFrame("Frame", nil)
    pfUI.thirdparty.sortbags:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.thirdparty.sortbags:SetScript("OnEvent", function()
      pfUI.thirdparty.sortbags:UnregisterAllEvents()

      -- don't do anything if another bagsorter was found
      if pfUI.thirdparty.bagsort ~= "sortbags" then return end

      -- make sure the bag module is enabled
      if not pfUI.bag or not pfUI.bag.right then return end

      local default_border = C.appearance.border.default
      if C.appearance.border.bags ~= "-1" then
        default_border = C.appearance.border.bags
      end

      -- draw the button
      if not pfUI.bag.right.sort then
        pfUI.bag.right.sort = CreateFrame("Button", "pfBagSlotSort", UIParent)
        pfUI.bag.right.sort:SetParent(pfUI.bag.right)
        pfUI.bag.right.sort:SetPoint("TOPRIGHT", pfUI.bag.right.keys, "TOPLEFT", -default_border*3, 0)

        CreateBackdrop(pfUI.bag.right.sort, default_border)
        pfUI.bag.right.sort:SetHeight(12)
        pfUI.bag.right.sort:SetWidth(12)
        pfUI.bag.right.sort:SetTextColor(1,1,.25,1)
        pfUI.bag.right.sort:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
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
          CreateBackdrop(pfUI.bag.right.sort)
          pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)
        end)

        pfUI.bag.right.sort:SetScript("OnClick", function()
          SortBags()
        end)

        pfUI.bag.right.search:ClearAllPoints()
        pfUI.bag.right.search:SetPoint("TOPLEFT", pfUI.bag.right, "TOPLEFT", default_border, -default_border)
        pfUI.bag.right.search:SetPoint("TOPRIGHT", pfUI.bag.right.sort, "TOPLEFT", -default_border*3, -default_border)
      end

      -- draw the button
      if not pfUI.bag.left.sort then
        pfUI.bag.left.sort = CreateFrame("Button", "pfBankSlotSort", UIParent)
        pfUI.bag.left.sort:SetParent(pfUI.bag.left)
        pfUI.bag.left.sort:SetPoint("TOPRIGHT", pfUI.bag.left.bags, "TOPLEFT", -default_border*3, 0)

        CreateBackdrop(pfUI.bag.left.sort, default_border)
        pfUI.bag.left.sort:SetHeight(12)
        pfUI.bag.left.sort:SetWidth(12)
        pfUI.bag.left.sort:SetTextColor(1,1,.25,1)
        pfUI.bag.left.sort:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
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
          CreateBackdrop(pfUI.bag.left.sort)
          pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)
        end)

        pfUI.bag.left.sort:SetScript("OnClick", function()
          SortBankBags()
        end)
      end
    end)
  end)

  HookAddonOrVariable("MrPlow", function()
    if C.thirdparty.mrplow.enable == "0" then return end

    pfUI.thirdparty.bagsort = "mrplow" -- dont't check for sortbags, use mrplow as default
    local MrPlowL = AceLibrary and AceLibrary("AceLocale-2.2"):new("MrPlow")
    if not (MrPlowL and MrPlowL["Bank"]) then return end

    pfUI.thirdparty.mrplow = CreateFrame("Frame", nil)
    pfUI.thirdparty.mrplow:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.thirdparty.mrplow:SetScript("OnEvent", function()
      pfUI.thirdparty.mrplow:UnregisterAllEvents()

      -- don't do anything if another bagsorter was found
      if pfUI.thirdparty.bagsort ~= "mrplow" then return end

      -- make sure the bag module is enabled
      if not pfUI.bag or not pfUI.bag.right then return end

      local default_border = C.appearance.border.default
      if C.appearance.border.bags ~= "-1" then
        default_border = C.appearance.border.bags
      end

      -- draw the button
      if not pfUI.bag.right.sort then
        pfUI.bag.right.sort = CreateFrame("Button", "pfBagSlotSort", UIParent)
        pfUI.bag.right.sort:SetParent(pfUI.bag.right)
        pfUI.bag.right.sort:SetPoint("TOPRIGHT", pfUI.bag.right.keys, "TOPLEFT", -default_border*3, 0)

        CreateBackdrop(pfUI.bag.right.sort, default_border)
        pfUI.bag.right.sort:SetHeight(12)
        pfUI.bag.right.sort:SetWidth(12)
        pfUI.bag.right.sort:SetTextColor(1,1,.25,1)
        pfUI.bag.right.sort:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
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
          CreateBackdrop(pfUI.bag.right.sort)
          pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)
        end)

        pfUI.bag.right.sort:SetScript("OnClick", function()
          MrPlow:Works()
        end)

        pfUI.bag.right.search:ClearAllPoints()
        pfUI.bag.right.search:SetPoint("TOPLEFT", pfUI.bag.right, "TOPLEFT", default_border, -default_border)
        pfUI.bag.right.search:SetPoint("TOPRIGHT", pfUI.bag.right.sort, "TOPLEFT", -default_border*3, -default_border)
      end

      -- draw the button
      if not pfUI.bag.left.sort then
        pfUI.bag.left.sort = CreateFrame("Button", "pfBankSlotSort", UIParent)
        pfUI.bag.left.sort:SetParent(pfUI.bag.left)
        pfUI.bag.left.sort:SetPoint("TOPRIGHT", pfUI.bag.left.bags, "TOPLEFT", -default_border*3, 0)

        CreateBackdrop(pfUI.bag.left.sort, default_border)
        pfUI.bag.left.sort:SetHeight(12)
        pfUI.bag.left.sort:SetWidth(12)
        pfUI.bag.left.sort:SetTextColor(1,1,.25,1)
        pfUI.bag.left.sort:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
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
          CreateBackdrop(pfUI.bag.left.sort)
          pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)
        end)

        pfUI.bag.left.sort:SetScript("OnClick", function()
          MrPlow:Works(MrPlowL["Bank"])
        end)
      end
    end)
  end)

  HookAddonOrVariable("FlightMap", function()
    if C.thirdparty.flightmap.enable == "0" then return end

    FlightMapTimesBorder:Hide()
    FlightMapTimesFlash:Hide()

    FlightMapTimesFrame:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
    FlightMapTimesFrame:SetHeight(18)
    CreateBackdrop(FlightMapTimesFrame)

    FlightMapTimesText:ClearAllPoints()
    FlightMapTimesText:SetPoint("CENTER", FlightMapTimesFrame, "CENTER", 0, 0)
    FlightMapTimesText:SetFont(pfUI.font_default, 12, "OUTLINE")
  end)

  HookAddonOrVariable("AtlasLoot", function()
    if C.thirdparty.atlasloot.enable == "0" then return end

    CreateBackdrop(AtlasLootTooltip)
    if pfUI.eqcompare then
      HookScript(AtlasLootTooltip, "OnShow", pfUI.eqcompare.GameTooltipShow)
      HookScript(AtlasLootTooltip, "OnHide", function()
        ShoppingTooltip1:Hide()
        ShoppingTooltip2:Hide()
      end)
    end
  end)

  HookAddonOrVariable("DruidManaBarBackground", function()
    if C.thirdparty.druidmana.enable == "0" then return end
    DruidManaBar:SetParent(UIParent)
    DruidManaBar.bd:Hide()

    local p = ManaBarColor[0]
    local pr, pg, pb = 0, 0, 0
    if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
    DruidManaBar:SetStatusBarColor(pr, pg, pb)
    DruidManaBar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")

    CreateBackdrop(DruidManaBar)

    DruidManaBar:SetScript("OnMouseUp", function(button)
      pfUI.uf.player:Click(button)
    end)

    DruidManaBar:ClearAllPoints()
    DruidManaBar:SetPoint("CENTER", 0, 0)
    UpdateMovable(DruidManaBar)
  end)

  HookAddonOrVariable("HealComm", function()
    -- hook healcomm's addon message to parse single-player events
    if AceLibrary and AceLibrary:HasInstance("HealComm-1.0") and pfUI.prediction then
      local HealComm = AceLibrary("HealComm-1.0")

      -- use pfUI frames to draw healComm predictions
      local pfHookHealCommSendAddonMessage = HealComm.SendAddonMessage
      function HealComm.SendAddonMessage(this, msg)
        if not UnitInRaid("player") and GetNumPartyMembers() < 1 then
          pfUI.prediction:ParseChatMessage(UnitName("player"), msg)
        end
        pfHookHealCommSendAddonMessage(this, msg)
      end

      -- disable pfUI predictions
      pfUI.prediction.sender:UnregisterAllEvents()
      pfUI.prediction.sender.enabled = nil
    end
  end)
end)
