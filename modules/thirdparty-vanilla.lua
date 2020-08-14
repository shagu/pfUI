pfUI:RegisterModule("thirdparty-vanilla", "vanilla", function()
  -- abort when thirdparty core module is not loaded
  if not pfUI.thirdparty then return end
  local rawborder, default_border = GetBorderSize()

  HookAddonOrVariable("KLHThreatMeter", function()
    local ktm_scale = 1
    local function GetKtmWidthDiff(view, match_size)
      local default_width = 0
      for column, header in view.head do
        if (header.vis()) then
          default_width = default_width + header.width
        else
          default_width = default_width + 0.1
        end
      end
      return match_size / (default_width + 12)
    end

    local function SetKtmWidth(view, diff_width)
      for column, header in view.head do
        header.width = round(round(header.width * diff_width) / ktm_scale)
      end
    end

    local function RefreshKtmWidth(width)
      local width = width or pfUI.chat.right:GetWidth()
      if (pfUI.thirdparty.meters.damage and pfUI.thirdparty.meters.threat) then
        width = width / 2
      end
      SetKtmWidth(KLHTM_Gui.raid, GetKtmWidthDiff(KLHTM_Gui.raid, width))
      SetKtmWidth(KLHTM_Gui.self, GetKtmWidthDiff(KLHTM_Gui.self, width))
      KLHTM_Redraw(true)
      KLHTM_UpdateRaidFrame()
      KLHTM_UpdateSelfFrame()
      KLHTM_UpdateFrame()
    end

    local docktable = { "ktm", "TODO", "KLHTM_Frame",
      function() -- single
        RefreshKtmWidth()
        KLHTM_Frame:ClearAllPoints()
        KLHTM_Frame:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 0, 0)
        KLHTM_Frame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, pfUI.panel.right:GetHeight())
        KLHTM_Frame.backdrop:SetPoint("BOTTOMRIGHT", KLHTM_Frame, "BOTTOMRIGHT", 0, -(KLHTM_Frame:GetBottom() - pfUI.chat.right:GetBottom())-default_border)
      end,
      function() -- dual
        RefreshKtmWidth()
        KLHTM_Frame:ClearAllPoints()
        KLHTM_Frame:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 0, 0)
        KLHTM_Frame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOM", -default_border, pfUI.panel.right:GetHeight())
        KLHTM_Frame.backdrop:SetPoint("BOTTOMRIGHT", KLHTM_Frame, "BOTTOMRIGHT", 0, -(KLHTM_Frame:GetBottom() - pfUI.chat.right:GetBottom())-default_border)
      end,
      function() -- show
        KLHTM_SetVisible(true)
        KLHTM_Frame:Show()
      end,
      function() -- hide
        KLHTM_SetVisible(false)
        KLHTM_Frame:Hide()
      end,
      function() -- once
        if KLHTM_Gui.frame then
          KLHTM_SetGuiScale(ktm_scale)
        end
      end
    }

    pfUI.thirdparty.meters:RegisterMeter("threat", docktable)

    if C.thirdparty.ktm.skin == "1" then
      -- remove titlebar
      if KLHTM_Gui then
        if KLHTM_Gui.title then
          KLHTM_Gui.title.back:Hide()
        end
        if KLHTM_Gui.raid then
          -- skin rows (raid)
          for i in pairs(KLHTM_Gui.raid.rows) do
            KLHTM_Gui.raid.rows[i].bar:SetTexture(pfUI.media["img:bar"])
            KLHTM_Gui.raid.rows[i].bar:SetAlpha(.75)

            if _G["KLHTM_RaidFrameRow" .. i .. "NameText"] then
              _G["KLHTM_RaidFrameRow" .. i .. "NameText"]:SetFont(pfUI.font_default, 13, "OUTLINE")
              _G["KLHTM_RaidFrameRow" .. i .. "ThreatText"]:SetFont(pfUI.font_default, 13, "OUTLINE")
              _G["KLHTM_RaidFrameRow" .. i .. "PercentThreatText"]:SetFont(pfUI.font_default, 13, "OUTLINE")
            end
          end
        end
        if KLHTM_Gui.self then
          -- skin rows (self)
          for i in pairs(KLHTM_Gui.self.rows) do
            KLHTM_Gui.self.rows[i].bar:SetTexture(pfUI.media["img:bar"])
            KLHTM_Gui.self.rows[i].bar:SetAlpha(.75)
          end
        end
      end

      CreateBackdrop(KLHTM_Frame, nil, nil, (C.thirdparty.chatbg == "1" and .8))
      CreateBackdropShadow(KLHTM_Frame)

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

      KLHTM_RaidFrameHeaderNameText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameHeaderThreatText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameHeaderPercentThreatText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameBottomThreatDefecitText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameBottomMasterTargetText:SetFont(pfUI.font_default, 12, "OUTLINE")
      KLHTM_RaidFrameHeaderName:SetHeight(12)

      -- remove seperators
      if KLHTM_RaidFrameLine then KLHTM_RaidFrameLine:Hide() end
      if KLHTM_RaidFrameBottomLine then KLHTM_RaidFrameBottomLine:Hide() end
      if KLHTM_SelfFrameLine then KLHTM_SelfFrameLine:Hide() end
      if KLHTM_SelfFrameBottomLine then KLHTM_SelfFrameBottomLine:Hide() end
    end
  end)

  HookAddonOrVariable("SW_Stats", function()
    local docktable = { "swstats", "TODO", "SW_BarFrame1",
      function() -- single
        SW_BarFrame1:SetWidth(pfUI.chat.right:GetWidth())
        SW_BarFrame1:ClearAllPoints()
        SW_BarFrame1:SetAllPoints(pfUI.chat.right)
        SW_BarFrame1_Resizer:Hide()
        SW_BarsLayout("SW_BarFrame1", true)
      end,
      function() -- dual
        SW_BarFrame1:SetWidth(pfUI.chat.right:GetWidth() / 2)
        SW_BarFrame1:ClearAllPoints()
        SW_BarFrame1:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", 0, 0)
        SW_BarFrame1:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0 ,0)
        SW_BarFrame1_Resizer:Hide()
        SW_BarsLayout("SW_BarFrame1", true)
      end,
      function() -- show
        SW_BarFrame1:Show()
        SW_OptKey(1)
      end,
      function() -- hide
        SW_BarFrame1:Hide()
      end,
      function() -- once
        SW_Settings["SHOWMAIN"] = nil
        SW_BarFrame1:Hide()

        SW_OptChk_Running:ClearAllPoints()
        SW_OptChk_Running:SetParent(SW_BarFrame1_Title)
        SW_OptChk_Running:SetPoint("RIGHT", SW_BarFrame1_Title_TimeLine, "LEFT", -2, 0)
        -- hide bottom panels
        SW_BarFrame1_Selector:Hide()

        -- let user select mode by clicking the title
        HookScript(SW_BarFrame1_Title, "OnMouseUp", function()
          local page = SW_Settings and SW_Settings.BarFrames and SW_Settings.BarFrames.SW_BarFrame1 and SW_Settings.BarFrames.SW_BarFrame1.Selected
          if page then
            local target = (arg1 == "LeftButton") and (page + 1) or (arg1 == "RightButton") and (page - 1)
            SW_OptKey((target > SW_OPT_COUNT) and 1 or (target < 1) and SW_OPT_COUNT or target)
          end
        end)
      end
    }

    pfUI.thirdparty.meters:RegisterMeter("damage", docktable)

    if C.thirdparty.swstats.skin == "1" then
      SW_Settings["OPT_ShowMainWinDPS"] = 1
      SW_Settings["Colors"] = SW_Settings["Colors"] or {}
      SW_Settings["Colors"]["TitleBarsFont"] = { [1] = 1, [2] = 1, [3] = 1, [4] = 1, }
      SW_Settings["Colors"]["TitleBars"] = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, }
      SW_Settings["Colors"]["Backdrops"] = { [1] = .3, [2] = 1, [3] = .8, [4] = 1, }

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

      local SkinSW_RoundButton = function(n, s)
        local s = s or 14
        local btn, normal, highlight = _G[n], _G[string.format("%s_Normal",n)], _G[string.format("%s_Highlight",n)]
        StripTextures(normal)
        StripTextures(highlight)
        CreateBackdrop(btn)
        btn:SetHeight(s)
        btn:SetWidth(s)
        SetHighlight(btn)
      end

      SW_BarFrame1_Title:SetPoint("TOPLEFT", 3, 0)
      SW_BarFrame1_Title_Sync:SetScale(.84)
      SW_BarFrame1_Title_Report:SetScale(.84)
      SW_BarFrame1_Title_Settings:SetScale(.84)
      SW_BarFrame1_Title_Close:SetScale(.84)
      SW_BarFrame1_Title_Console:SetScale(.84)
      SW_BarFrame1_Title_TimeLine:SetScale(.84)

      -- bar padding
      SW_BarFrame1.swoBarY = -22
      _G.SW_BARSEPY = 1

      CreateBackdrop(SW_BarFrame1, nil, nil, (C.thirdparty.chatbg == "1" and .8))
      CreateBackdropShadow(SW_BarFrame1)

      if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
        local r, g, b, a = strsplit(",", C.chat.global.background)
        SW_BarFrame1.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

        local r, g, b, a = strsplit(",", C.chat.global.border)
        SW_BarFrame1.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
      end

      SkinCheckbox(SW_OptChk_Running, 20)
      for i=1, SW_OPT_COUNT do
        SkinSW_RoundButton(string.format("SW_BarFrame1_Selector_Opt%d",i))
        if i == 1 then
          _G[string.format("SW_BarFrame1_Selector_Opt%d",i)]:SetPoint("TOPLEFT", SW_OptChk_Running, "TOPRIGHT", 3, -3)
        end
      end
      SW_BarFrame1_Selector:SetPoint("TOPLEFT", SW_BarFrame1.backdrop, "BOTTOMLEFT", 10, 0)

      -- mode settings
      CreateBackdrop(SW_BarSettingsFrameV2, nil, nil, .8)
      CreateBackdrop(SW_BarSettingsFrameV2_Title, 0)
      CreateBackdrop(SW_BarSettingsFrameV2_Tab1, 0)
      SW_BarSettingsFrameV2_Tab1:SetHeight(24)
      SW_BarSettingsFrameV2_Tab1_Text:SetParent(SW_BarSettingsFrameV2_Tab1.backdrop)
      CreateBackdrop(SW_BarSettingsFrameV2_Tab2, 0)
      SW_BarSettingsFrameV2_Tab2:SetHeight(24)
      SW_BarSettingsFrameV2_Tab2_Text:SetParent(SW_BarSettingsFrameV2_Tab2.backdrop)
      CreateBackdrop(SW_BarSettingsFrameV2_Tab3, 0)
      SW_BarSettingsFrameV2_Tab3:SetHeight(24)
      SW_BarSettingsFrameV2_Tab3_Text:SetParent(SW_BarSettingsFrameV2_Tab3.backdrop)
      SkinCheckbox(SW_OptChk_Rank, 18)
      SkinCheckbox(SW_OptChk_Num, 18)
      SkinCheckbox(SW_OptChk_Percent, 18)
      SkinCheckbox(SW_Filter_None, 18)
      SkinCheckbox(SW_Filter_PC, 18)
      SkinCheckbox(SW_Filter_NPC, 18)
      SkinCheckbox(SW_Filter_Group, 18)
      SkinCheckbox(SW_Filter_EverGroup, 18)
      SkinCheckbox(SW_HealOpt_Eff, 18)
      SkinCheckbox(SW_HealOpt_OH, 18)
      SkinCheckbox(SW_HealOpt_IF, 18)
      SkinDropDown(SW_InfoTypeDropDown)
      SkinDropDown(SW_ClassFilterDropDown)
      SkinDropDown(SW_SchoolDropDown)
      if SW_SchoolDropDown:GetWidth() < 100 then
        UIDropDownMenu_SetWidth(100, SW_SchoolDropDown) -- SW_Stats is missing this in init
      end
      SkinButton(SW_SetInfoVarTxtFrame_Button)
      SkinButton(SW_SetInfoVarFromTarget)
      CreateBackdrop(SW_CS_BarC_Button)
      SetAllPointsOffset(SW_CS_BarC_Button.backdrop,SW_CS_BarC_Button,2)
      SetHighlight(SW_CS_BarC_Button)
      CreateBackdrop(SW_CS_FontC_Button)
      SetAllPointsOffset(SW_CS_FontC_Button.backdrop,SW_CS_FontC_Button,2)
      SetHighlight(SW_CS_FontC_Button)
      CreateBackdrop(SW_CS_OptC_Button)
      SetAllPointsOffset(SW_CS_OptC_Button.backdrop,SW_CS_OptC_Button,2)
      SetHighlight(SW_CS_OptC_Button)
      SkinSlider(SW_BarHeightSlider)
      SW_BarHeightSliderLow:ClearAllPoints()
      SW_BarHeightSliderLow:SetPoint("TOPRIGHT", SW_BarHeightSlider, "TOPLEFT", -2, -2)
      SW_BarHeightSliderHigh:ClearAllPoints()
      SW_BarHeightSliderHigh:SetPoint("BOTTOMRIGHT", SW_BarHeightSlider, "BOTTOMLEFT", -2, 2)
      SkinSlider(SW_ColCountSlider)
      SkinSlider(SW_TextureSlider)
      SkinSlider(SW_FontSizeSlider)
      SkinButton(SW_SetFrameTxtFrame_Button)
      SkinButton(SW_SetOptTxtFrame_Button)
      SkinCheckbox(SW_ColorsOptUseClass)
      SW_BarSettings_Visuals:SetPoint("TOPLEFT", 5, -50)
      SW_BarSettings_Visuals:SetPoint("BOTTOMRIGHT", 2, 10)
      SkinCheckbox(SW_PF_Inactive,18)
      SkinCheckbox(SW_PF_Active,18)
      SkinCheckbox(SW_PF_Current,18)
      SkinCheckbox(SW_PF_VPP,18)
      SkinCheckbox(SW_PF_VPR,18)
      SkinCheckbox(SW_PF_MM,18)
      SkinCheckbox(SW_PF_MR,18)
      SkinCheckbox(SW_PF_MB,18)
      SkinCheckbox(SW_PF_Ignore,18)

      -- general settings
      CreateBackdrop(SW_GeneralSettings, nil, nil, .8)
      CreateBackdrop(SW_GeneralSettings_Title, 0)
      SkinCheckbox(SW_Chk_ShowTLB,18)
      SkinCheckbox(SW_Chk_ShowSyncB,18)
      SkinCheckbox(SW_Chk_ShowConsoleB,18)
      SkinCheckbox(SW_Chk_ShowDPS,18)
      CreateBackdrop(SW_CS_Damage_Button)
      SetAllPointsOffset(SW_CS_Damage_Button.backdrop, SW_CS_Damage_Button, 2)
      SetHighlight(SW_CS_Damage_Button)
      CreateBackdrop(SW_CS_Heal_Button)
      SetAllPointsOffset(SW_CS_Heal_Button.backdrop, SW_CS_Heal_Button, 2)
      SetHighlight(SW_CS_Heal_Button)
      CreateBackdrop(SW_CS_TitleBar_Button)
      SetAllPointsOffset(SW_CS_TitleBar_Button.backdrop, SW_CS_TitleBar_Button, 2)
      SetHighlight(SW_CS_TitleBar_Button)
      CreateBackdrop(SW_CS_TitleFont_Button)
      SetAllPointsOffset(SW_CS_TitleFont_Button.backdrop, SW_CS_TitleFont_Button, 2)
      SetHighlight(SW_CS_TitleFont_Button)
      CreateBackdrop(SW_CS_Backdrops_Button)
      SetAllPointsOffset(SW_CS_Backdrops_Button.backdrop, SW_CS_Backdrops_Button, 2)
      SetHighlight(SW_CS_Backdrops_Button)
      CreateBackdrop(SW_CS_MainWinBack_Button)
      SetAllPointsOffset(SW_CS_MainWinBack_Button.backdrop, SW_CS_MainWinBack_Button, 2)
      SetHighlight(SW_CS_MainWinBack_Button)
      CreateBackdrop(SW_CS_ClassCAlpha_Button)
      SetAllPointsOffset(SW_CS_ClassCAlpha_Button.backdrop, SW_CS_ClassCAlpha_Button, 2)
      SetHighlight(SW_CS_ClassCAlpha_Button)
      SkinSlider(SW_OptCountSlider)
      SkinSlider(SW_GeneralSettingsIconSlider)
      SkinSlider(SW_GeneralSettingsIconRadiusSlider)

      -- announce
      CreateBackdrop(SW_BarReportFrame, nil, nil, .8)
      CreateBackdrop(SW_BarReportFrame_Title, 0)
      SkinCheckbox(SW_RepTo_Say,18)
      SkinCheckbox(SW_RepTo_Group,18)
      SkinCheckbox(SW_RepTo_Raid,18)
      SkinCheckbox(SW_RepTo_Guild,18)
      SkinCheckbox(SW_RepTo_Channel,18)
      SkinCheckbox(SW_RepTo_Whisper,18)
      SkinCheckbox(SW_RepTo_Officer,18)
      SkinCheckbox(SW_RepTo_Clipboard,18)
      SkinCheckbox(SW_Chk_RepMulti,18)
      SkinSlider(SW_BarReportFrameRepAmountSlider)
      SkinButton(SW_BarReportFrame_SendReport)
      SkinButton(SW_BarReportFrame_VarText_SetTextFromTarget)
      StripTextures(SW_BarReportFrame_VarText_EditBox, "BACKGROUND")
      CreateBackdrop(SW_BarReportFrame_VarText_EditBox)

      -- copy
      CreateBackdrop(SW_TextWindow, nil, nil, .75)
      CreateBackdrop(SW_TextWindow_Title, 0)
      SkinSlider(SW_TextWindowExportSlider)
      StripTextures(SW_TextWindow_EditBox, "BACKGROUND")
      CreateBackdrop(SW_TextWindow_EditBox)

      -- sync
      CreateBackdrop(SW_BarSyncFrame, nil, nil, .8)
      CreateBackdrop(SW_BarSyncFrame_Title, 0)
      SkinCheckbox(SW_AutoVoteYes,18)
      SkinCheckbox(SW_AutoVoteNo,18)
      SkinScrollbar(SW_SyncListScrollBar)

      -- timeline
      CreateBackdrop(SW_TimeLine, nil, nil, .8)
      CreateBackdrop(SW_TimeLine_Title, 0)
      SkinCheckbox(SW_Chk_TL_SafeMode,18)
      SkinCheckbox(SW_Chk_TL_SingleSelect,18)
      SkinCheckbox(SW_Chk_TL_AutoZone,18)
      SkinCheckbox(SW_Chk_TL_AutoDelete,18)
      SkinButton(SW_TL_Nuke)
      SkinButton(SW_TL_ReloadUI)
      SkinButton(SW_TL_Select)
      SkinButton(SW_TL_Merge)
      for i=1,10 do
        SkinSW_RoundButton(string.format("SW_TimeLine_Item%d_Delete",i),12)
        SkinSW_RoundButton(string.format("SW_TimeLine_Item%d_Rename",i),12)
      end
      SkinScrollbar(SW_TL_SelectorScrollBar)

      -- console
      CreateBackdrop(SW_FrameConsole, nil, nil, .75)
      CreateBackdrop(SW_FrameConsole_Title, 0)
      SW_FrameConsole_Title:SetHeight(24)
      SkinArrowButton(SW_FrameConsole_Text1_MsgUp, "up", 13)
      SkinArrowButton(SW_FrameConsole_Text1_MsgDown, "down", 13)
      SkinArrowButton(SW_FrameConsole_Text1_MsgBottom, "down", 13)
      SW_FrameConsole_Text1_MsgUp:SetPoint("BOTTOMRIGHT", -5, 45)
      SW_FrameConsole_Text1_MsgDown:SetPoint("BOTTOMRIGHT", -5, 30)
      SW_FrameConsole_Text1_MsgBottom:SetPoint("BOTTOMRIGHT", -5, 12)
      CreateBackdrop(SW_FrameConsole_Tab1, 0)
      SW_FrameConsole_Tab1:SetHeight(24)
      SW_FrameConsole_Tab1_Text:SetParent(SW_FrameConsole_Tab1.backdrop)
      CreateBackdrop(SW_FrameConsole_Tab2, 0)
      SW_FrameConsole_Tab2:SetHeight(24)
      SW_FrameConsole_Tab2_Text:SetParent(SW_FrameConsole_Tab2.backdrop)
      SkinCheckbox(SW_Chk_ShowEvent,18)
      SkinCheckbox(SW_Chk_ShowOrigStr,18)
      SkinCheckbox(SW_Chk_ShowRegEx,18)
      SkinCheckbox(SW_Chk_ShowMatch,18)
      SkinCheckbox(SW_Chk_ShowSyncInfo,18)
      SkinArrowButton(SW_FrameConsole_Text2_MsgUp,"up",13)
      SkinArrowButton(SW_FrameConsole_Text2_MsgDown,"down",13)
      SkinArrowButton(SW_FrameConsole_Text2_MsgBottom,"down",13)
      SW_FrameConsole_Text2_MsgUp:SetPoint("BOTTOMRIGHT", -5, 45)
      SW_FrameConsole_Text2_MsgDown:SetPoint("BOTTOMRIGHT", -5, 30)
      SW_FrameConsole_Text2_MsgBottom:SetPoint("BOTTOMRIGHT", -5, 12)
    end
  end)

  HookAddonOrVariable("WIM", function()
    if C.thirdparty.wim.enable == "0" then return end

    _G.WIM_isLinkURL = function() return false end
    _G.WIM_ConvertURLtoLinks = function(text) -- use pfUI link handler (it is more correct)
      return pfUI.chat:HandleLink(text)
    end

    -- replace wim class colors with pfUI ones
    hooksecurefunc("WIM_InitClassProps", function()
      for class in pairs(RAID_CLASS_COLORS) do
        local wimclass = _G[format("WIM_LOCALIZED_%s",class)]
        local colorstr = rgbhex(RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, RAID_CLASS_COLORS[class].a)
        _G.WIM_ClassColors[wimclass] = gsub(colorstr, "^|cff", "")
      end
    end, true)

    -- convo menu
    CreateBackdrop(WIM_Icon_ToolTip, 0, nil, tonumber(C.tooltip.alpha))
    CreateBackdrop(WIM_ConversationMenu, 0, nil, .75)
    for i=1, _G.WIM_MaxMenuCount do
      local btn, btnClose = _G["WIM_ConversationMenuTellButton"..i], _G["WIM_ConversationMenuTellButton"..i.."Close"]
      SkinCloseButton(btnClose, btn, -4, -1)
      btnClose:SetWidth(13)
      btnClose:SetHeight(13)
    end
    hooksecurefunc("WIM_Icon_DropDown_Update", function()
      for i=1,_G.WIM_MaxMenuCount do
        local btn = _G["WIM_ConversationMenuTellButton"..i]
        if i==1 and btn:IsEnabled() == 0 then return end
        if not btn:IsShown() then return end
        local btn_txt = btn:GetText()
        local user = btn.theUser
        local userclr = _G.WIM_PlayerCache and _G.WIM_PlayerCache[user] and _G.WIM_PlayerCache[user].class and _G.WIM_UserWithClassColor(user)
        if userclr and user ~= userclr then
          btn_txt = gsub(btn_txt, user, format("|r%s",userclr))
          btn:SetText(btn_txt)
        end
      end
    end, true)

    if WIM_HistoryFrame then -- history frame
      CreateBackdrop(WIM_HistoryFrame, nil, nil, .8)
      CreateBackdropShadow(WIM_HistoryFrame)
      WIM_HistoryFrame.backdrop:SetPoint("TOPLEFT", 10, -10)
      WIM_HistoryFrame.backdrop:SetPoint("BOTTOMRIGHT", -10, 10)
      WIM_HistoryFrame:SetHitRectInsets(10,10,10,10)
      StripTextures(WIM_HistoryFrameTitle)

      SkinCloseButton(WIM_HistoryFrameTitleExitButton, WIM_HistoryFrame.backdrop, -6, -6)

      SkinArrowButton(WIM_HistoryFrameMessageListScrollUp, 'up', 18)
      WIM_HistoryFrameMessageListScrollUp:SetPoint("TOPLEFT", WIM_HistoryFrameMessageListScrollingMessageFrame, "TOPRIGHT", 10, -6)
      SkinArrowButton(WIM_HistoryFrameMessageListScrollDown, 'down', 18)
      WIM_HistoryFrameMessageListScrollDown:SetPoint("BOTTOMLEFT", WIM_HistoryFrameMessageListScrollingMessageFrame, "BOTTOMRIGHT", 10, 0)
    end

    if WIM_Options then -- options frame
      CreateBackdrop(WIM_Options, nil, nil, .8)
      CreateBackdropShadow(WIM_Options)
      WIM_Options.backdrop:SetPoint("TOPLEFT", 12, -10)
      WIM_Options.backdrop:SetPoint("BOTTOMRIGHT", -12, 0)
      WIM_Options:SetHitRectInsets(12,12,10,0)

      WIM_OptionsTitleBorder:SetTexture(nil)
      WIM_OptionsTitleString:SetPoint("TOP", WIM_Options.backdrop, "TOP", 0, -4)

      SkinCloseButton(WIM_OptionsExitButton, WIM_Options.backdrop, -6, -6)
      WIM_OptionsHelpButton:ClearAllPoints()
      WIM_OptionsHelpButton:SetPoint("RIGHT", WIM_OptionsExitButton, "LEFT", -10, 0)
      WIM_OptionsHelpButton:SetHighlightTexture(nil)

      SkinCheckbox(WIM_OptionsEnableWIM)

      do -- display
        StripTextures(WIM_OptionsDisplayCaption)
        SkinCheckbox(WIM_OptionsDisplayShowShortcutBar)
        SkinCheckbox(WIM_OptionsDisplayShowTimeStamps)
        SkinCheckbox(WIM_OptionsDisplayShowCharacterInfo)
        SkinCheckbox(WIM_OptionsDisplayShowCharacterInfoClassIcon)
        SkinCheckbox(WIM_OptionsDisplayShowCharacterInfoClassColor)
        SkinCheckbox(WIM_OptionsDisplayShowCharacterInfoDetails)
        if WIM_OptionsDisplayShowCharacterInfoZone then SkinCheckbox(WIM_OptionsDisplayShowCharacterInfoZone) end

        SkinSlider(WIM_OptionsDisplayFontSize)
        SkinSlider(WIM_OptionsDisplayWindowSize)
        SkinSlider(WIM_OptionsDisplayWindowAlpha)
      end
      do -- minimap
        StripTextures(WIM_OptionsMiniMapCaption)
        SkinCheckbox(WIM_OptionsMiniMapEnabled)
        SkinCheckbox(WIM_OptionsMiniMapFreeMoving)

        SkinSlider(WIM_OptionsMiniMapIconPosition)
      end
      -- alignment for WIM_OptionsTabbedFrame:
      WIM_OptionsOptionTab1:SetPoint("TOPLEFT", WIM_OptionsMiniMap, "BOTTOMLEFT", 10, -4) -- move the upper bound WIM_OptionsTabbedFrame
      WIM_OptionsDisplay:SetHeight(540) -- move the lower bound WIM_OptionsTabbedFrame
      WIM_Options_GeneralScroll:SetPoint("BOTTOMRIGHT", WIM_OptionsTabbedFrame, "BOTTOMRIGHT", -30, 10)
      -------------------------------------------------

      -- wrap SkinCheckbox to fix issues with scrollframe breaking layers
      local SkinScrollchildCheckbox = function(f, s)
        if not f then return end
        SkinCheckbox(f, s)
        if f:GetParent() ~= f.backdrop and f:GetParent() ~= f then
          f.backdrop:SetParent(f:GetParent())
          f:SetParent(f.backdrop)
        end
      end
      do -- general tab
        SkinTab(WIM_OptionsOptionTab1)
        SkinScrollbar(WIM_Options_GeneralScrollScrollBar)

        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralAutoFocus)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralKeepFocus)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralKeepFocusRested)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralShowToolTips)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralPopOnSend)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralPopNew)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralPopUpdate)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralPopCombat)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralSupress)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralPlaySoundWisp)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralSortOrderAlpha)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralShowAFK)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralUseEscape)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralInterceptSlashWisp)
        SkinScrollchildCheckbox(WIM_OptionsTabbedFrameGeneralBlockLowLevel)
      end
      do -- windows tab
        SkinTab(WIM_OptionsOptionTab2)

        SkinCheckbox(WIM_OptionsTabbedFrameWindowWindowCascade)
        SkinButton(WIM_OptionsTabbedFrameWindowWindowAnchor)
        SkinDropDown(WIM_OptionsTabbedFrameWindowCascadeDirection)
        SkinSlider(WIM_OptionsTabbedFrameWindowWindowWidth)
        SkinSlider(WIM_OptionsTabbedFrameWindowWindowHeight)
        WIM_OptionsTabbedFrameWindowWindowHeight:SetPoint("TOPLEFT", WIM_OptionsTabbedFrameWindowWindowWidth, "BOTTOMLEFT", 0, -40)
        WIM_OptionsTabbedFrameWindowWindowHeight:SetMinMaxValues(240, 600) -- fix min value. WIM.lua:643.
      end
      do -- filters tab
        SkinTab(WIM_OptionsOptionTab3)

        SkinCheckbox(WIM_OptionsTabbedFrameFilterAliasShowAsComment)
        for _,v in pairs({"Alias", "Filtering"}) do
          SkinCheckbox(_G["WIM_OptionsTabbedFrameFilter"..v.."Enabled"])
          SkinButton(_G["WIM_OptionsTabbedFrameFilter"..v.."ColumnHeader1"])
          SkinButton(_G["WIM_OptionsTabbedFrameFilter"..v.."ColumnHeader2"])
          SkinScrollbar(_G["WIM_OptionsTabbedFrameFilter"..v.."PanelScrollBarScrollBar"])
          SkinButton(_G["WIM_OptionsTabbedFrameFilter"..v.."PanelAdd"])
          SkinButton(_G["WIM_OptionsTabbedFrameFilter"..v.."PanelRemove"])
          SkinButton(_G["WIM_OptionsTabbedFrameFilter"..v.."PanelEdit"])
        end

        CreateBackdrop(WIM_Options_AliasWindow, nil, nil, .8)
        WIM_Options_AliasWindowTitleBorder:SetTexture(nil)
        CreateBackdrop(WIM_Options_AliasWindowPanel1, nil, nil)
        WIM_Options_AliasWindowPanel1.backdrop:SetPoint("TOPLEFT", 0, -4)
        WIM_Options_AliasWindowPanel1.backdrop:SetPoint("BOTTOMRIGHT", 0, 8)
        CreateBackdrop(WIM_Options_AliasWindowPanel2, nil, nil)
        WIM_Options_AliasWindowPanel2.backdrop:SetPoint("TOPLEFT", 0, -4)
        WIM_Options_AliasWindowPanel2.backdrop:SetPoint("BOTTOMRIGHT", 0, 8)
        SkinButton(WIM_Options_AliasWindowOK)
        SkinButton(WIM_Options_AliasWindowCancel)

        CreateBackdrop(WIM_Options_FilterWindow, nil, nil, .8)
        WIM_Options_FilterWindowTitleBorder:SetTexture(nil)
        CreateBackdrop(WIM_Options_FilterWindowPanel1, nil, nil)
        WIM_Options_FilterWindowPanel1.backdrop:SetPoint("TOPLEFT", 0, -4)
        WIM_Options_FilterWindowPanel1.backdrop:SetPoint("BOTTOMRIGHT", 0, 8)
        SkinCheckbox(WIM_Options_FilterWindow_ActionIgnore)
        SkinCheckbox(WIM_Options_FilterWindow_ActionBlock)
        SkinButton(WIM_Options_FilterWindowOK)
        SkinButton(WIM_Options_FilterWindowCancel)
      end
      do -- history tab
        SkinTab(WIM_OptionsOptionTab4)

        SkinCheckbox(WIM_OptionsTabbedFrameHistoryEnabled)
        SkinCheckbox(WIM_OptionsTabbedFrameHistoryRecordEveryone)
        SkinCheckbox(WIM_OptionsTabbedFrameHistoryRecordFriends)
        SkinCheckbox(WIM_OptionsTabbedFrameHistoryRecordGuild)
        SkinCheckbox(WIM_OptionsTabbedFrameHistoryShowInMessage)
        SkinCheckbox(WIM_OptionsTabbedFrameHistorySetMaxToStore)
        SkinCheckbox(WIM_OptionsTabbedFrameHistorySetAutoDelete)
        SkinDropDown(WIM_OptionsTabbedFrameHistoryMessageCount)
        SkinDropDown(WIM_OptionsTabbedFrameHistoryMaxCount)
        SkinDropDown(WIM_OptionsTabbedFrameHistoryAutoDeleteTime)
        SkinButton(WIM_OptionsTabbedFrameHistoryColumnHeader1)
        SkinButton(WIM_OptionsTabbedFrameHistoryColumnHeader2)
        SkinScrollbar(WIM_OptionsTabbedFrameHistoryPanelScrollBarScrollBar)
        SkinButton(WIM_OptionsTabbedFrameHistoryPanelDeleteUser)
        SkinButton(WIM_OptionsTabbedFrameHistoryPanelViewHistory)
      end
    end

    if WIM_Help then -- help frame
      CreateBackdrop(WIM_Help, nil, nil, .8)
      WIM_HelpTitleBorder:SetTexture(nil)
      SkinCloseButton(WIM_HelpExitButton, WIM_Help.backdrop, -6, -6)
      SkinTab(WIM_HelpTab1)
      SkinTab(WIM_HelpTab2)
      SkinTab(WIM_HelpTab3)
      SkinTab(WIM_HelpTabCredits)
      SkinScrollbar(WIM_HelpScrollFrameScrollBar)
    end

    hooksecurefunc("WIM_WindowOnShow", function()
      if this.backdrop then return end -- already skinned

      local windowname = this:GetName()
      CreateBackdrop(this, nil, nil, .8)
      CreateBackdropShadow(this)
      local from = _G[windowname.."From"]
      from:ClearAllPoints()
      from:SetPoint("TOP", 0, -10)
      local exit = _G[windowname.."ExitButton"]
      SkinCloseButton(exit, this.backdrop, -6, -6)
      local history = _G[windowname.."HistoryButton"]
      history:ClearAllPoints()
      history:SetPoint("TOPRIGHT", exit, "TOPLEFT", -2, 2)

      this.avatar = CreateFrame("Frame", nil, this)
      this.avatar:SetAllPoints(this)

      local classicon = _G[windowname .. "ClassIcon"]
      classicon:SetTexCoord(.3, .7, .3, .7)
      classicon:SetParent(this.avatar)
      classicon:ClearAllPoints()
      classicon:SetPoint("TOPLEFT", 10 , -10)
      classicon:SetWidth(26)
      classicon:SetHeight(26)

      local msgframe = _G[windowname .. "ScrollingMessageFrame"]
      msgframe:SetPoint("TOPLEFT", this, "TOPLEFT", 10, -45)
      msgframe:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", -32, 32)
      msgframe:SetFont(pfUI.font_default, C.global.font_size)

      local msgbox = _G[windowname .. "MsgBox"]
      CreateBackdrop(msgbox)
      msgbox:ClearAllPoints()
      msgbox:SetPoint("TOPLEFT", msgframe, "BOTTOMLEFT", 0, -5)
      msgbox:SetPoint("TOPRIGHT", msgframe, "BOTTOMRIGHT", 0, -5)
      msgbox:SetTextInsets(5, 5, 5, 5)
      msgbox:SetHeight(20)

      for i = 1, 5 do
        local btn = _G[windowname .. "ShortcutFrameButton"..i]
        local icon = _G[windowname .. "ShortcutFrameButton"..i.."Icon"]
        local prev_btn = _G[windowname .. "ShortcutFrameButton"..(i-1)]
        StripTextures(btn, nil, "ARTWORK")
        icon:SetDrawLayer("ARTWORK")
        SkinButton(btn, nil, nil, nil, icon)
        btn:ClearAllPoints()
        if not prev_btn then
          btn:SetPoint("TOP", exit, "BOTTOM", 0, -20)
        else
          btn:SetPoint("TOP", prev_btn, "BOTTOM", 0, -4)
        end
      end
      local scrollup, scrolldown = _G[windowname .. "ScrollUp"], _G[windowname .. "ScrollDown"]
      SkinArrowButton(scrollup, "up", 18)
      SkinArrowButton(scrolldown, "down", 18)
      scrolldown:ClearAllPoints()
      scrolldown:SetPoint("BOTTOMRIGHT", -4, 30)
      scrollup:ClearAllPoints()
      scrollup:SetPoint("BOTTOMLEFT", scrolldown, "TOPLEFT", 0, 2)

      StripTextures(_G[windowname .. "IgnoreConfirm"])
      SkinButton(_G[windowname .. "IgnoreConfirmYes"])
      SkinButton(_G[windowname .. "IgnoreConfirmNo"])
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

      local rawborder, default_border = GetBorderSize("bags")

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
        pfUI.bag.right.sort.texture:SetTexture(pfUI.media["img:sort"])
        pfUI.bag.right.sort.texture:ClearAllPoints()
        pfUI.bag.right.sort.texture:SetPoint("TOPLEFT", pfUI.bag.right.sort, "TOPLEFT", 2, -2)
        pfUI.bag.right.sort.texture:SetPoint("BOTTOMRIGHT", pfUI.bag.right.sort, "BOTTOMRIGHT", -2, 2)
        pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)

        pfUI.bag.right.sort:SetScript("OnEnter", function ()
          pfUI.bag.right.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
          pfUI.bag.right.sort.texture:SetVertexColor(1,1,.25,1)
          GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
          GameTooltip:SetText(GetAddOnMetadata("SortBags","Title"))
          GameTooltip:AddLine(GetAddOnMetadata("SortBags","Notes"),1,1,1)
          GameTooltip:Show()
        end)

        pfUI.bag.right.sort:SetScript("OnLeave", function ()
          CreateBackdrop(pfUI.bag.right.sort)
          pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)
          if GameTooltip:IsOwned(this) then
            GameTooltip:Hide()
          end
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
        pfUI.bag.left.sort.texture:SetTexture(pfUI.media["img:sort"])
        pfUI.bag.left.sort.texture:ClearAllPoints()
        pfUI.bag.left.sort.texture:SetPoint("TOPLEFT", pfUI.bag.left.sort, "TOPLEFT", 2, -2)
        pfUI.bag.left.sort.texture:SetPoint("BOTTOMRIGHT", pfUI.bag.left.sort, "BOTTOMRIGHT", -2, 2)
        pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)

        pfUI.bag.left.sort:SetScript("OnEnter", function ()
          pfUI.bag.left.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
          pfUI.bag.left.sort.texture:SetVertexColor(1,1,.25,1)
          GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
          GameTooltip:SetText(GetAddOnMetadata("SortBags","Title"))
          GameTooltip:AddLine(GetAddOnMetadata("SortBags","Notes"),1,1,1)
          GameTooltip:Show()
        end)

        pfUI.bag.left.sort:SetScript("OnLeave", function ()
          CreateBackdrop(pfUI.bag.left.sort)
          pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)
          if GameTooltip:IsOwned(this) then
            GameTooltip:Hide()
          end
        end)

        pfUI.bag.left.sort:SetScript("OnClick", function()
          SortBankBags()
        end)
      end
    end)
  end)

  HookAddonOrVariable("FlightMap", function()
    if C.thirdparty.flightmap.enable == "0" then return end

    FlightMapTimesBorder:Hide()
    FlightMapTimesFlash:Hide()

    FlightMapTimesFrame:SetStatusBarTexture(pfUI.media["img:bar"])
    FlightMapTimesFrame:SetHeight(18)
    CreateBackdrop(FlightMapTimesFrame)
    CreateBackdropShadow(FlightMapTimesFrame)

    FlightMapTimesText:ClearAllPoints()
    FlightMapTimesText:SetPoint("CENTER", FlightMapTimesFrame, "CENTER", 0, 0)
    FlightMapTimesText:SetFont(pfUI.font_default, 12, "OUTLINE")
  end)

  HookAddonOrVariable("TheoryCraft_SetUpButton", function()
    if C.thirdparty.theorycraft.enable == "0" then return end

    -- set pfUI bar font
    if TheoryCraft_Settings then
      TheoryCraft_Settings["FontPath"] = pfUI.media[C.bars.font]
    end

    if not pfUI.bars then return end

    -- make theorycraft aware of pfUI bars
    for i=1,10 do
      for j=1,10 do
        TheoryCraft_SetUpButton(pfUI.bars[i][j]:GetName(), "Normal")
      end
    end
  end)

  HookAddonOrVariable("SM_GetActionSpell", function()
    if C.thirdparty.supermacro.enable == "0" then return end
    if not pfUI.bars then return end

    -- hook events to include SuperMacro refreshs
    local ButtonFullUpdate = pfUI.bars.ButtonFullUpdate
    pfUI.bars.ButtonFullUpdate = function(button)
      -- run the old function
      ButtonFullUpdate(button)

      -- update with SuperMacro textures
      if not button then return end
      if button.bar and button.bar > 10 then return end
      local text = GetActionText(button:GetID())

      if text then
        if _G.SM_ACTION_SPELL and _G.SM_ACTION_SPELL["regular"] and _G.SM_ACTION_SPELL["regular"][text] then
          button.icon:SetTexture(_G.SM_ACTION_SPELL["regular"][text].texture)
        end
      end
    end

    -- hook events to include SuperMacro refreshs
    local ButtonEnter = pfUI.bars[1][1]:GetScript("OnEnter")
    local function NewButtonEnter()
      ButtonEnter()
      SM_ActionButton_SetTooltip()
    end

    -- reassign the new event handler
    for i=1,10 do
      for j=1,12 do
        pfUI.bars[i][j]:SetScript("OnEvent", NewButtonEvent)
        pfUI.bars[i][j]:SetScript("OnEnter", NewButtonEnter)
      end
    end

    -- trigger the event whenever SuperMacro got an update
    hooksecurefunc("SM_UpdateActionSpell", function()
      for slot=1,120 do pfUI.bars.update[slot] = true end
    end)
  end)

  HookAddonOrVariable("AtlasLoot", function()
    if C.thirdparty.atlasloot.enable == "0" then return end

    CreateBackdrop(AtlasLootTooltip)
    CreateBackdropShadow(AtlasLootTooltip)

    if pfUI.eqcompare then
      HookScript(AtlasLootTooltip, "OnShow", pfUI.eqcompare.GameTooltipShow)
      HookScript(AtlasLootTooltip, "OnHide", function()
        ShoppingTooltip1:Hide()
        ShoppingTooltip2:Hide()
      end)
    end
  end)

  HookAddonOrVariable("MyRolePlay", function()
    if C.thirdparty.myroleplay.enable == "0" then return end

    if pfUI.uf.target then
      -- set mrp icon to target frame
      mrpButtonIconFrame:SetParent(pfUI.uf.target)
      mrpButtonIconFrame:SetFrameStrata("DIALOG")
      mrpButtonIconFrame:SetWidth(20)
      mrpButtonIconFrame:SetHeight(20)
      mrpButtonIconFrame:SetPoint("TOPRIGHT", pfUI.uf.target, "TOPRIGHT", 10, 10)
      function _G.mrpMoveIcon()
        mrpButtonIconFrame:SetPoint("TOPRIGHT", pfUI.uf.target, "TOPRIGHT", 10, 10)
      end
    end

    if pfUI.uf.player then
      -- set tooltip function for player frame
      local oldfunc = pfUI.uf.player:GetScript("OnEnter")
      pfUI.uf.player:SetScript("OnEnter", function()
        oldfunc()
        mrpDisplayTooltip("player", "PLAYER")
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
    DruidManaBar:SetStatusBarTexture(pfUI.media["img:bar"])

    local f = pfUI.uf.player
    DruidManaBar:SetWidth((f.config.pwidth ~= "-1" and f.config.pwidth or f.config.width))
    DruidManaBar:SetHeight(f.config.pheight)
    DruidManaBar.text:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
    DruidManaBar.text:SetFontObject(GameFontWhite)

    CreateBackdrop(DruidManaBar)
    CreateBackdropShadow(DruidManaBar)

    DruidManaBar:SetScript("OnMouseUp", function(button)
      f:Click(button)
    end)

    DruidManaBar:ClearAllPoints()
    DruidManaBar:SetPoint("CENTER", 0, 0)
    UpdateMovable(DruidManaBar)
  end)

  HookAddonOrVariable("NoteIt", function()
    if C.thirdparty.noteit.enable == "0" then return end

    -- Main window
    pfUI.api.StripTextures(NoteInputFrame, true)
    CreateBackdrop(NoteInputFrame, nil, nil, .75)
    CreateBackdropShadow(NoteInputFrame)

    NoteInputFrame.backdrop:SetPoint("TOPLEFT", 10, -12)
    NoteInputFrame.backdrop:SetPoint("BOTTOMRIGHT", -32, 30)

    -- close button
    pfUI.api.SkinCloseButton(NoteInputFrameCloseButton, NoteInputFrame, -37, -17)

    -- Options button
    pfUI.api.SkinButton(NoteInputOptionsButton)
    NoteInputOptionsButton:ClearAllPoints()
    NoteInputOptionsButton:SetPoint("TOPLEFT", NoteInputTextBackground, "BOTTOMLEFT", 0, -15)
    NoteInputOptionsButton:SetWidth(145)

    -- Delete button
    pfUI.api.SkinButton(NoteInputDeleteButton)
    NoteInputDeleteButton:ClearAllPoints()
    NoteInputDeleteButton:SetPoint("TOPLEFT", NoteInputOptionsButton, "BOTTOMLEFT", 0, -4)
    NoteInputDeleteButton:SetWidth(145)

    -- Save button
    pfUI.api.SkinButton(NoteInputFrameSaveButton)
    NoteInputFrameSaveButton:ClearAllPoints()
    NoteInputFrameSaveButton:SetPoint("TOPRIGHT", NoteInputTextBackground, "BOTTOMRIGHT", 0, -15)
    NoteInputFrameSaveButton:SetWidth(145)

    --  Cancel button
    pfUI.api.SkinButton(NoteInputFrameExitButton)
    NoteInputFrameExitButton:ClearAllPoints()
    NoteInputFrameExitButton:SetPoint("TOPLEFT", NoteInputFrameSaveButton, "BOTTOMLEFT", 0, -4)
    NoteInputFrameExitButton:SetWidth(145)

    -- Window title
    NoteInputTitleText:SetTextColor(1,1,.25,1)

    -- Scrollbars
    pfUI.api.SkinScrollbar(NoteInputNameChooseFrameScrollBar)
    pfUI.api.SkinScrollbar(NoteInputNoteFrameScrollBar)

    -- Search/Input label frame
    NoteInputNameLabel:ClearAllPoints()
    NoteInputNameLabel:SetPoint("TOPLEFT", NoteInputTitleText, "BOTTOMLEFT", -10, 0)

    -- Search/Input input frame
    pfUI.api.StripTextures(NoteInputNameEditBox)
    CreateBackdrop(NoteInputNameEditBox)
    NoteInputNameEditBox:SetTextInsets(5,5,5,5)
    NoteInputNameEditBox:ClearAllPoints()
    NoteInputNameEditBox:SetPoint("TOPLEFT", NoteInputNameLabel, "BOTTOMLEFT", 0, 0)
    NoteInputNameEditBox:SetPoint("TOPRIGHT", NoteInputNameLabel, "BOTTOMRIGHT", 0, 0)
    NoteInputNameEditBox:SetHeight(20)

    -- Frame holding the list (i think)
    pfUI.api.StripTextures(NoteInputNameChooseFrame)
    CreateBackdrop(NoteInputNameChooseFrame)
    NoteInputNameChooseFrame:ClearAllPoints()
    NoteInputNameChooseFrame:SetPoint("TOPLEFT", NoteInputNameEditBox, "BOTTOMLEFT", 0, -10)
    NoteInputNameChooseFrame:SetPoint("TOPRIGHT", NoteInputNameEditBox, "BOTTOMRIGHT", -20, 0)
    NoteInputNameChooseFrame:SetHeight(100)

    -- Note label frame
    NoteInputNoteLabel:ClearAllPoints()
    NoteInputNoteLabel:SetPoint("TOPLEFT", NoteInputNameChooseFrame, "BOTTOMLEFT", 0, 0)
    NoteInputNoteLabel:SetPoint("TOPRIGHT", NoteInputNameChooseFrame, "BOTTOMRIGHT", 0, 0)

    -- Note input frame
    pfUI.api.StripTextures(NoteInputNoteFrame)
    CreateBackdrop(NoteInputNoteFrame)
    NoteInputNoteEditBox:SetTextInsets(5,5,5,5)
    NoteInputNoteFrame:ClearAllPoints()
    NoteInputNoteFrame:SetPoint("TOPLEFT", NoteInputNoteLabel, "BOTTOMLEFT", 0, 0)
    NoteInputNoteFrame:SetPoint("TOPRIGHT", NoteInputNoteLabel, "BOTTOMRIGHT", 0, 0)
    NoteInputNoteFrame:SetHeight(140)

    -- Weird frames
    NoteInputNameChooseBackground:Hide()
    NoteInputTextBackground:Hide()

    NoteInputTextBackground:ClearAllPoints()
    NoteInputTextBackground:SetPoint("TOPLEFT", NoteInputNameChooseFrame, "BOTTOMLEFT", -2, -38)
    NoteInputTextBackground:SetPoint("TOPRIGHT", NoteInputNameChooseFrame, "BOTTOMRIGHT", 22, -38)
  end)

  local EnableHealComm = function()
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
  end
  HookAddonOrVariable("HealComm", EnableHealComm)
  HookAddonOrVariable("LunaUnitFrames", EnableHealComm)
  HookAddonOrVariable("NotGrid", EnableHealComm)

  HookAddonOrVariable("MoveAnything", function()
    SkinButton(GameMenuButtonMoveAnything)
  end)
  HookAddonOrVariable("MCP", function()
    SkinButton(GameMenuButtonAddOns)
  end)
end)
