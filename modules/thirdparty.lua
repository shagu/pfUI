pfUI:RegisterModule("thirdparty", function ()
  pfUI.thirdparty = {}
  pfUI.thirdparty.meters = {}
  pfUI.thirdparty.meters.damage = false
  pfUI.thirdparty.meters.threat = false
  pfUI.thirdparty.meters.state = false

  local function AddIntegration(addon, func)
    local lurker = CreateFrame("Frame", nil)
    lurker.func = func
    lurker:RegisterEvent("VARIABLES_LOADED")
    lurker:SetScript("OnEvent",function()
      if IsAddOnLoaded(addon) or _G[addon] then
        this:func()
        this:UnregisterEvent("VARIABLES_LOADED")
      end
    end)
  end

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
          DPSMate_DPSMate:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", 0 ,0)
          DPSMate_DPSMate:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0 ,0)
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
          SW_BarFrame1:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", 0 ,0)
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
          KLHTM_Frame:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 0 ,0)
          KLHTM_Frame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOM", -1 ,0)
        end
      end
    end
  end

  function pfUI.thirdparty.meters:Toggle()
    pfUI.thirdparty.meters:Resize()

    -- show meters
    if pfUI.thirdparty.meters.state == false then
      pfUI.thirdparty.meters.state = true

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

  AddIntegration("KLHThreatMeter", function()
    if C.thirdparty.ktm.skin == "1" then
      -- remove titlebar
      KLHTM_Gui.title.back:Hide()
      KLHTM_SetGuiScale(.9)

      if C.thirdparty.ktm.dock == "1" then
        KLHTM_Frame:SetBackdrop({
          bgFile = "Interface\\AddOns\\pfUI\\img\\col", tile = true, tileSize = 8,
          insets = {left = -1, right = -1, top = -1, bottom = -1},
        })

        KLHTM_Frame:SetBackdropColor(0,0,0)
      else
        CreateBackdrop(KLHTM_Frame)
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
    end
  end)

  AddIntegration("DPSMate", function()
    if C.thirdparty.dpsmate.skin == "1" then
      local pfHookDPSMateInitializeFrames = _G.DPSMate.InitializeFrames
      _G.DPSMate.InitializeFrames = function(self)
        if DPSMateSettings then
          -- set DPSMate appearance to match pfUI
          DPSMateSettings["windows"][1]["titlebarheight"] = 20
          DPSMateSettings["windows"][1]["titlebarfontsize"] = 12
          DPSMateSettings["windows"][1]["titlebarfont"] = "Accidental Presidency"
          DPSMateSettings["windows"][1]["titlebarbgcolor"][1] = 0
          DPSMateSettings["windows"][1]["titlebarbgcolor"][2] = 0
          DPSMateSettings["windows"][1]["titlebarbgcolor"][3] = 0

          DPSMateSettings["windows"][1]["titlebarfontcolor"][1] = 1
          DPSMateSettings["windows"][1]["titlebarfontcolor"][2] = 1
          DPSMateSettings["windows"][1]["titlebarfontcolor"][3] = 1

          DPSMateSettings["windows"][1]["barheight"] = 11
          DPSMateSettings["windows"][1]["barfontsize"] = 13
          DPSMateSettings["windows"][1]["bartexture"] = "normTex"
          DPSMateSettings["windows"][1]["barfont"] = "Accidental Presidency"

          DPSMateSettings["windows"][1]["bgopacity"] = 1
          DPSMateSettings["windows"][1]["borderopacity"] = 0
          DPSMateSettings["windows"][1]["opacity"] = 1
          DPSMateSettings["windows"][1]["contentbgtexture"] = "Solid Background"
          DPSMateSettings["windows"][1]["contentbgcolor"][1] = 0
          DPSMateSettings["windows"][1]["contentbgcolor"][2] = 0
          DPSMateSettings["windows"][1]["contentbgcolor"][3] = 0
          DPSMateSettings["windows"][1]["contentbgcolor"][3] = 0
        end

        pfHookDPSMateInitializeFrames(self)
      end
    end

    if C.thirdparty.dpsmate.dock == "1" then
      pfUI.thirdparty.meters.damage = true

      local pfDPSMateOnLoad = DPSMate.OnLoad
      function _G.DPSMate:OnLoad()
        pfDPSMateOnLoad()
        DPSMate_DPSMate:Hide()
      end

      if DPSMate_DPSMate then
        DPSMate_DPSMate:Hide()
      end

      if pfUI.panel then
        pfUI.panel.right.hide:SetScript("OnClick", function()
          pfUI.thirdparty.meters:Toggle()
        end)
      end
    end
  end)

  AddIntegration("SW_Stats", function()
    if C.thirdparty.swstats.skin == "1" then

      SW_Settings["OPT_ShowMainWinDPS"] = 1

      SW_Settings["Colors"] = SW_Settings["Colors"] or {}
      SW_Settings["Colors"]["MainWinBack"] = { [1] = 0, [2] = 0, [3] = 0,	[4] = 1, }
      SW_Settings["Colors"]["Backdrops"] = { [1] = 0, [2] = 0, [3] = 0,	[4] = 0, }
      SW_Settings["Colors"]["TitleBarsFont"] = { [1] = 1, [2] = 1, [3] = 1,	[4] = 1, }
      SW_Settings["Colors"]["TitleBars"] = { [1] = 0, [2] = 0, [3] = 0,	[4] = 1, }

      SW_Settings["InfoSettings"] = SW_Settings["InfoSettings"] or {}
      SW_Settings["InfoSettings"][1] = SW_Settings["InfoSettings"][1] or {}
      SW_Settings["InfoSettings"][1]["SF"] = "SW_Filter_EverGroup"
      SW_Settings["InfoSettings"][1]["ShowPercent"] = 1
      SW_Settings["InfoSettings"][1]["ShowRank"] = 1
      SW_Settings["InfoSettings"][1]["ShowNumber"] = 1
      SW_Settings["InfoSettings"][1]["BT"] = 13
      SW_Settings["InfoSettings"][1]["BH"] = 10
      SW_Settings["InfoSettings"][1]["BFS"] = 11
      SW_Settings["InfoSettings"][1]["BFC"] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, }
      SW_Settings["InfoSettings"][1]["BC"] = { [1] = 0, [2] = 0, [3] = 0, [4] = 1, }
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

      if C.thirdparty.swstats.dock == "1" then
        SW_BarFrame1:SetBackdrop({
          bgFile = "Interface\\AddOns\\pfUI\\img\\col", tile = true, tileSize = 8,
          insets = {left = -1, right = -1, top = -1, bottom = -1},
        })
        SW_BarFrame1:SetBackdropColor(0,0,0)
      else
        CreateBackdrop(SW_BarFrame1)
      end
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
    end
  end)

  AddIntegration("WIM", function()
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

  AddIntegration("SortBags", function()
    if C.thirdparty.sortbags.enable == "0" then return end

    pfUI.thirdparty.sortbags = CreateFrame("Frame", nil)
    pfUI.thirdparty.sortbags:RegisterEvent("BAG_UPDATE")
    pfUI.thirdparty.sortbags:RegisterEvent("PLAYER_ENTERING_WORLD")
    pfUI.thirdparty.sortbags:SetScript("OnEvent", function()
      -- make sure bagframe was already created
      if not pfUI.bag or not pfUI.bag.right then return end
      pfUI.thirdparty.sortbags:UnregisterAllEvents()

      -- draw the button
      if not pfUI.bag.right.sort then
        pfUI.bag.right.sort = CreateFrame("Button", "pfBagSlotSort", UIParent)
        pfUI.bag.right.sort:SetParent(pfUI.bag.right)
        pfUI.bag.right.sort:SetPoint("TOPRIGHT", -C.appearance.border.default*14 - 45, -C.appearance.border.default)
        pfUI.bag.right.sort:SetPoint("TOPRIGHT", pfUI.bag.right.keys, "TOPLEFT", -C.appearance.border.default*3, 0)

        CreateBackdrop(pfUI.bag.right.sort)
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
        pfUI.bag.right.search:SetPoint("TOPLEFT", pfUI.bag.right, "TOPLEFT", C.appearance.border.default, -C.appearance.border.default)
        pfUI.bag.right.search:SetPoint("TOPRIGHT", pfUI.bag.right.sort, "TOPLEFT", -C.appearance.border.default*3, -C.appearance.border.default)
      end

      -- draw the button
      if not pfUI.bag.left.sort then
        pfUI.bag.left.sort = CreateFrame("Button", "pfBankSlotSort", UIParent)
        pfUI.bag.left.sort:SetParent(pfUI.bag.left)
        pfUI.bag.left.sort:SetPoint("TOPRIGHT", -C.appearance.border.default*14 - 45, -C.appearance.border.default)
        pfUI.bag.left.sort:SetPoint("TOPRIGHT", pfUI.bag.left.bags, "TOPLEFT", -C.appearance.border.default*3, 0)

        CreateBackdrop(pfUI.bag.left.sort)
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

  AddIntegration("DebuffTimers", function()
    if pfUI.debuffs then
      pfUI.debuffs.active = nil
    end
  end)

  AddIntegration("FlightMap", function()
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

  AddIntegration("AtlasLoot", function()
    if C.thirdparty.atlasloot.enable == "0" then return end

    CreateBackdrop(AtlasLootTooltip)
    if pfUI.eqcompare then
      local AtlasCompare = CreateFrame( "Frame" , "pfEQCompareAtlas", AtlasLootTooltip )

      AtlasCompare:SetScript("OnShow", function()
        if this.itemLink then message(this.itemLink) end
        pfUI.eqcompare.ShowCompare(AtlasLootTooltip)
      end)

      AtlasCompare:SetScript("OnHide", function()
        ShoppingTooltip1:Hide()
        ShoppingTooltip2:Hide()
      end)
    end
  end)

  AddIntegration("HealComm", function()
    -- hook healcomm's addon message to parse single-player events
    if AceLibrary and AceLibrary:HasInstance("HealComm-1.0") and pfUI.prediction then
      local HealComm = AceLibrary("HealComm-1.0")
      local pfHookHealCommSendAddonMessage = HealComm.SendAddonMessage
      function HealComm.SendAddonMessage(this, msg)
        if not UnitInRaid("player") and GetNumPartyMembers() < 1 then
          pfUI.prediction:ParseChatMessage(UnitName("player"), msg)
        end
        pfHookHealCommSendAddonMessage(this, msg)
      end
    end
  end)
end)
