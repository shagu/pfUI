pfUI:RegisterModule("thirdparty", function ()
  pfUI.thirdparty = {}
  pfUI.thirdparty.meters = {}
  pfUI.thirdparty.meters.damage = false
  pfUI.thirdparty.meters.threat = false
  pfUI.thirdparty.meters.state = false

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


  -- KLHTM Integration
  local function pfSkinKTM()
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
  end

  local function pfDockKTM()
    if C.thirdparty.ktm.dock == "1" then
      pfUI.thirdparty.meters.threat = true

      KLHTM_Frame:Hide()

      if pfUI.panel then
        pfUI.panel.right.hide:SetScript("OnClick", function()
          pfUI.thirdparty.meters:Toggle()
        end)
      end
    end
  end

  if KLHTM_Gui then
    pfSkinKTM()
    pfDockKTM()
  else
    local pfHookKTM = CreateFrame("Frame", nil)
    pfHookKTM:RegisterEvent("VARIABLES_LOADED")
    pfHookKTM:SetScript("OnEvent",function()
      if KLHTM_Gui then
        pfHookKTM:UnregisterEvent("VARIABLES_LOADED")
        pfSkinKTM()
        pfDockKTM()
      end
    end)
  end

  -- DPSMate Integration
  local function pfSkinDPSMate()
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
  end

  local function pfDockDPSMate()
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
  end

  if DPSMate then
    pfSkinDPSMate()
    pfDockDPSMate()
  else
    local pfHookDPSMate = CreateFrame("Frame", nil)
    pfHookDPSMate:RegisterEvent("VARIABLES_LOADED")
    pfHookDPSMate:SetScript("OnEvent",function()
      if DPSMate then
        pfHookKTM:UnregisterEvent("VARIABLES_LOADED")
        pfSkinDPSMate()
        pfDockDPSMate()
      end
    end)
  end


  -- SWStats Integration
  local function pfSkinSWStats()
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
  end

  local function pfDockSWStats()
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
  end

  if SW_BarFrame1 then
    pfSkinSWStats()
    pfDockSWStats()
  else
    local pfHookSWStats = CreateFrame("Frame", nil)
    pfHookSWStats:RegisterEvent("VARIABLES_LOADED")
    pfHookSWStats:SetScript("OnEvent",function()
      if SW_BarFrame1 then
        pfHookSWStats:UnregisterEvent("VARIABLES_LOADED")
        pfSkinSWStats()
        pfDockSWStats()
      end
    end)
  end

  -- WIM Integration
  -- Change the appearance of WIM windows to match pfUI
  if C.thirdparty.wim.enable == "1" then

    local pfUIhookWIM = CreateFrame("Frame", nil)
    pfUIhookWIM:RegisterEvent("ADDON_LOADED")
    pfUIhookWIM:SetScript("OnEvent", function()
      if not pfWIM_WindowOnShow and WIM_WindowOnShow then
        _G.WIM_isLinkURL = function() return false end

        pfWIM_WindowOnShow = _G.WIM_WindowOnShow
        _G.WIM_WindowOnShow = function()
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
          pfWIM_WindowOnShow()
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
    if pfUI.healComm.createIncHeal or C.thirdparty.healcomm.enable == "0" then return end

    if AceLibrary and AceLibrary:HasInstance("HealComm-1.0") then
      local HealComm = AceLibrary("HealComm-1.0")
      local AceEvent = AceLibrary("AceEvent-2.0")

      function pfUI.healComm.createIncHeal(unit)
        if pfUI.uf.player and unit == "player" then
          if not pfUI.uf.player.hp then return end

          if pfUI.uf.player and not pfUI.uf.player.incHeal then
            pfUI.uf.player.incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.player)
            pfUI.uf.player.incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            pfUI.uf.player.incHeal:SetFrameStrata("MEDIUM")
            pfUI.uf.player.incHeal:SetMinMaxValues(0, 1)
            pfUI.uf.player.incHeal:SetValue(1)
            pfUI.uf.player.incHeal:SetStatusBarColor(0, 1, 0, 0.5)
            pfUI.uf.player.incHeal:SetHeight(pfUI.uf.player.hp:GetHeight())
            pfUI.uf.player.incHeal:Hide()
          end
          return pfUI.uf.player
        end

        if pfUI.uf.target and unit == "target" then
          if not pfUI.uf.target.hp then return end

          if not pfUI.uf.target.incHeal then
            pfUI.uf.target.incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.target)
            pfUI.uf.target.incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            pfUI.uf.target.incHeal:SetFrameStrata("MEDIUM")
            pfUI.uf.target.incHeal:SetMinMaxValues(0, 1)
            pfUI.uf.target.incHeal:SetValue(1)
            pfUI.uf.target.incHeal:SetStatusBarColor(0, 1, 0, 0.5)
            pfUI.uf.target.incHeal:SetHeight(pfUI.uf.target.hp:GetHeight())
            pfUI.uf.target.incHeal:Hide()
          end
          return pfUI.uf.target
        end

        if pfUI.uf.group and strsub(unit,0,5) == "party" then
          local id = tonumber(strsub(unit,6))
          if pfUI.uf.group[id] then
            if not pfUI.uf.group[id].hp then return end

            if not pfUI.uf.group[id].incHeal then
              pfUI.uf.group[id].incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.group[id])
              pfUI.uf.group[id].incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
              pfUI.uf.group[id].incHeal:SetFrameStrata("MEDIUM")
              pfUI.uf.group[id].incHeal:SetMinMaxValues(0, 1)
              pfUI.uf.group[id].incHeal:SetValue(1)
              pfUI.uf.group[id].incHeal:SetStatusBarColor(0, 1, 0, 0.5)
              pfUI.uf.group[id].incHeal:SetHeight(pfUI.uf.group[id].hp:GetHeight())
              pfUI.uf.group[id].incHeal:Hide()
            end
            return pfUI.uf.group[id]
          end
        end

        if pfUI.uf.raid and strsub(unit,0,4) == "raid" then
          local rid = tonumber(strsub(unit,5))
          local id = nil

          for i=1,40 do
            if not pfUI.uf.raid then break end
            if pfUI.uf.raid[i] and pfUI.uf.raid[i].id == rid then id = i end
          end

          if id == nil then return end
          if pfUI.uf.raid[id] then
            if not pfUI.uf.raid[id].hp then return end

            if not pfUI.uf.raid[id].incHeal then
              pfUI.uf.raid[id].incHeal = CreateFrame("StatusBar", "PlayerFrameIncHealBar", pfUI.uf.raid[id])
              pfUI.uf.raid[id].incHeal:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
              pfUI.uf.raid[id].incHeal:SetFrameStrata("MEDIUM")
              pfUI.uf.raid[id].incHeal:SetMinMaxValues(0, 1)
              pfUI.uf.raid[id].incHeal:SetValue(1)
              pfUI.uf.raid[id].incHeal:SetStatusBarColor(0, 1, 0, 0.5)
              pfUI.uf.raid[id].incHeal:SetHeight(pfUI.uf.raid[id].hp:GetHeight())
              pfUI.uf.raid[id].incHeal:Hide()
            end
            return pfUI.uf.raid[id]
          end
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
        OVERHEALPERCENT = OVERHEALPERCENT or 20

        local frame = pfUI.healComm.createIncHeal(unit)
        if not frame then return end

        local healed = HealComm:getHeal(UnitName(unit))

        local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
        if strsub(unit,0,4) == "raid" and C.unitframes.raid.invert_healthbar == "1" then
          health = maxHealth - health
        end

        if( healed > 0 and (health < maxHealth or OVERHEALPERCENT > 0 )) and frame:IsVisible() then
          frame.incHeal:Show()
          local width = frame.hp.bar:GetWidth() / frame.hp.bar:GetEffectiveScale()
          local healthWidth = width * (health / maxHealth)
          local incWidth = width * healed / maxHealth
          if healthWidth + incWidth > width * (1+(OVERHEALPERCENT/100)) then
            incWidth = width * (1+OVERHEALPERCENT/100) - healthWidth
          end
          frame.incHeal:SetWidth(incWidth)
          frame.incHeal:ClearAllPoints()

          if strsub(unit,0,4) == "raid" and C.unitframes.raid.invert_healthbar == "1" then
            frame.incHeal:SetPoint("TOPLEFT", frame.hp.bar, "TOPLEFT", 0, 0)
            frame.incHeal:SetFrameStrata("HIGH")
          else
            frame.incHeal:SetPoint("TOPLEFT", frame.hp.bar, "TOPLEFT", healthWidth, 0)
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
  local function pfSetupClean_Up()
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
          Clean_Up("bags")
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
          Clean_Up("bank")
        end)
      end
    end)
  end

  if C.thirdparty.cleanup.enable == "1" then
    if Clean_Up then
      pfSetupClean_Up()
    else
      local pfHookClean_Up = CreateFrame("Frame", nil)
      pfHookClean_Up:RegisterEvent("VARIABLES_LOADED")
      pfHookClean_Up:SetScript("OnEvent",function()
          if Clean_Up then
            pfHookClean_Up:UnregisterEvent("VARIABLES_LOADED")
            pfSetupClean_Up()
          end
        end)
    end
  end
end)
