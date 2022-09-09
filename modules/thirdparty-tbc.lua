pfUI:RegisterModule("thirdparty-tbc", "tbc", function ()
  -- abort when thirdparty core module is not loaded
  if not pfUI.thirdparty then return end
  local rawborder, default_border = GetBorderSize()

  HookAddonOrVariable("Omen", function()
    local docktable = { "omen", "Omen", "OmenBarList",
      function() -- single
        Omen.BarList:ClearAllPoints()
        Omen.BarList:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", -5, 5)
        Omen.BarList:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 5, pfUI.panel.right:GetHeight()-5)
        Omen.BarList:SetWidth(pfUI.chat.right:GetWidth() + 7)

        -- backdrop adjustments
        if Omen.BarList.backdrop then
          Omen.BarList.backdrop:SetPoint("TOPLEFT", -default_border+5, default_border-5)
          Omen.BarList.backdrop:SetPoint("BOTTOMRIGHT", default_border-5, -18-default_border+5)
        end
      end,
      function() -- dual
        Omen.BarList:ClearAllPoints()
        Omen.BarList:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", -5, 5)
        Omen.BarList:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOM", -default_border+5, pfUI.panel.right:GetHeight()-5)
        Omen.BarList:SetWidth(pfUI.chat.right:GetWidth() / 2 + 7)

        -- backdrop adjustments
        if Omen.BarList.backdrop then
          Omen.BarList.backdrop:SetPoint("TOPLEFT", -default_border+5, default_border-5)
          Omen.BarList.backdrop:SetPoint("BOTTOMRIGHT", default_border-5, -18-default_border+5)
        end
      end,
      function() -- show
        Omen:UpdateDisplay()
        Omen:EnableLastModule()
        Omen:LayoutModuleIcons()

        Omen.ModuleList:SetPoint("BOTTOMLEFT", Omen.BarList, "TOPLEFT", 5, default_border*3-5)
        Omen.ModuleList:SetPoint("BOTTOMRIGHT", Omen.BarList, "TOPRIGHT", -5, default_border*3)

        -- fake sizes to retain proper button sizes
        Omen.ModuleList._GetHeight = Omen.ModuleList._GetHeight or Omen.ModuleList.GetHeight
        Omen.ModuleList.GetHeight = function() return 30 end
        Omen:LayoutModuleIcons()
        Omen.ModuleList.GetHeight = Omen.ModuleList._GetHeight
        Omen.ModuleList:SetHeight(20)

        OmenResizeGrip:Hide()
        Omen:Toggle(true)
      end,
      function() -- hide
        Omen:Toggle(nil)
      end,
      function() -- once
        Omen.Title:Hide()
        Omen.Title.Show = function() return end
        EnableAutohide(Omen.ModuleList, 1)

        local hookUpdateDisplay = Omen.UpdateDisplay
        Omen.UpdateDisplay = function(self)
          hookUpdateDisplay(self)
          pfUI.thirdparty.meters:Resize()
        end

        Omen.UpdateVisible = function()
          if pfUI.thirdparty.meters.state then
            Omen.Anchor:Show()
          else
            Omen.Anchor:Hide()
          end
        end
      end,
    }

    pfUI.thirdparty.meters:RegisterMeter("threat", docktable)

    if C.thirdparty.omen.skin == "1" then
      if Omen.Anchor then

        local hookUpdateDisplay = Omen.UpdateDisplay
        Omen.UpdateDisplay = function(self)
          hookUpdateDisplay(self)

          StripTextures(Omen.Title)
          StripTextures(Omen.ModuleList)
          StripTextures(Omen.BarList)

          if not Omen.Title.backdrop or not Omen.ModuleList.backdrop or not Omen.BarList.backdrop then
            CreateBackdrop(Omen.Title, nil, nil, (C.thirdparty.chatbg == "1" and .8))
            CreateBackdropShadow(Omen.Title)

            CreateBackdrop(Omen.ModuleList, nil, nil, (C.thirdparty.chatbg == "1" and .8))
            CreateBackdropShadow(Omen.ModuleList)

            CreateBackdrop(Omen.BarList, nil, nil, (C.thirdparty.chatbg == "1" and .8))
            CreateBackdropShadow(Omen.BarList)
          end

          if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
            local r, g, b, a = strsplit(",", C.chat.global.background)
            Omen.BarList.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
            Omen.ModuleList.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

            local r, g, b, a = strsplit(",", C.chat.global.border)
            Omen.BarList.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
            Omen.ModuleList.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
          end
        end

        HookScript(Omen.Anchor, "OnShow", function()
          for i, child in pairs({ OmenModuleButtons:GetChildren() }) do
            if child and child:IsObjectType("Button") then
              child:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
              CreateBackdrop(child, nil, true)
            end
          end
        end)

        Omen:UpdateDisplay()
      end
    end
  end)

  HookAddonOrVariable("Recount", function()
    local docktable = { "recount", "Recount", "Recount_MainWindow",
      function() -- single
        Recount.MainWindow:ClearAllPoints()
        Recount.MainWindow:SetPoint("TOPLEFT", pfUI.chat.right, "TOPLEFT", 0, 10)
        Recount.MainWindow:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 18)
        Recount.MainWindow:SetWidth(pfUI.chat.right:GetWidth())
      end,
      function() -- dual
        Recount.MainWindow:ClearAllPoints()
        Recount.MainWindow:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", default_border, 10)
        Recount.MainWindow:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 18)
        Recount.MainWindow:SetWidth(pfUI.chat.right:GetWidth() / 2)
      end,
      function() -- show
        Recount.MainWindow:Show()
        Recount:ResizeMainWindow()
        Recount:RefreshMainWindow()
      end,
      function() -- hide
        Recount.MainWindow:Hide()
      end,
      function() -- once
        local hookResize = Recount.ResizeMainWindow
        Recount.ResizeMainWindow = function()
          hookResize()

          local a, b, c = Recount.MainWindow:GetPoint()
          if b == pfUI.chat.right and Recount.MainWindow.backdrop then
            Recount.MainWindow.backdrop:SetPoint("BOTTOMRIGHT", default_border, -18-default_border)
          else
            Recount.MainWindow.backdrop:SetPoint("BOTTOMRIGHT", default_border, default_border)
          end
        end
      end,
    }

    pfUI.thirdparty.meters:RegisterMeter("damage", docktable)

    if C.thirdparty.recount.skin == "1" then
      if Recount_MainWindow then
        StripTextures(Recount.MainWindow)
        CreateBackdrop(Recount.MainWindow, nil, nil, (C.thirdparty.chatbg == "1" and .8))
        CreateBackdropShadow(Recount.MainWindow)
        SkinScrollbar(Recount_MainWindow_ScrollBarScrollBar)
        Recount_MainWindow_ScrollBarScrollBarScrollUpButton.Overlay:SetTexture(nil)
        Recount_MainWindow_ScrollBarScrollBarScrollDownButton.Overlay:SetTexture(nil)
        Recount.MainWindow.DragBottomLeft:SetNormalTexture(nil)
        Recount.MainWindow.DragBottomRight:SetNormalTexture(nil)

        -- backdrop adjustments
        Recount.MainWindow.backdrop:SetPoint("TOPLEFT", -default_border, -5-default_border-GetPerfectPixel())
        if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
          local r, g, b, a = strsplit(",", C.chat.global.background)
          Recount.MainWindow.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

          local r, g, b, a = strsplit(",", C.chat.global.border)
          Recount.MainWindow.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
        end
      end
    end
  end)

  HookAddonOrVariable("BCEPGP_LootFrame_Update", function()
    if C.thirdparty.bcepgp.enable == "0" then return end

    local hook = _G.BCEPGP_LootFrame_Update
    _G.BCEPGP_LootFrame_Update = function(a,b,c,d,e,f)
      LootFrame.numLootItems = GetNumLootItems()
      hook(a,b,c,d,e,f)
    end
  end)

  -- Sheep Watch Continued
  -- https://www.curseforge.com/wow/addons/sheep-watch-continued/files/225593
  HookAddonOrVariable("SheepWatch", function()
    if C.thirdparty.sheepwatch.enable == "0" then return end

    StripTextures(SheepWatch)

    if SheepWatchFrameStatusBar then
      SheepWatchFrameStatusBar:SetStatusBarTexture(pfUI.media["img:bar"])
      SheepWatchFrameStatusBar:SetHeight(14)
      CreateBackdrop(SheepWatchFrameStatusBar)
      CreateBackdropShadow(SheepWatchFrameStatusBar)
    end

    if SheepWatchText then
      SheepWatchText:ClearAllPoints()
      SheepWatchText:SetPoint("CENTER", 0, 4)
    end

    if SheepWatchCounterText then
      SheepWatchCounterText:ClearAllPoints()
      SheepWatchCounterText:SetPoint("RIGHT", 0, 4)
    end
  end)

  HookAddonOrVariable("Bag_Sort", function()
    if C.thirdparty.bag_sort.enable == "0" then return end

    local sort = CreateFrame("Frame", nil)
    sort:RegisterEvent("PLAYER_ENTERING_WORLD")
    sort:SetScript("OnEvent", function()
      this:UnregisterAllEvents()

      pfUI.thirdparty.RegisterBagSort("Bag_Sort",
        function()
          BS_slashBagSortHandler()
        end,
        function()
          GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
          GameTooltip:SetText(GetAddOnMetadata("Bag_Sort","Title"))
          GameTooltip:AddLine(GetAddOnMetadata("Bag_Sort","Notes"),1,1,1)
          GameTooltip:Show()
        end,
        function()
          BS_slashBankSortHandler()
        end,
        function()
          GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
          GameTooltip:SetText(GetAddOnMetadata("Bag_Sort","Title"))
          GameTooltip:AddLine(GetAddOnMetadata("Bag_Sort","Notes"),1,1,1)
          GameTooltip:Show()
        end)
    end)
  end)

  HookAddonOrVariable("AckisRecipeList", function()
    if C.thirdparty.ackis.enable == "0" then return end
    if AckisRecipeList.ShowScanButton then
      local AckisRecipeListShowScanButton = AckisRecipeList.ShowScanButton
      AckisRecipeList.ShowScanButton = function(a1,a2,a3,a4)
        -- run the original function
        AckisRecipeListShowScanButton(a1,a2,a3,a4)

        -- apply skin and reposition the button
        SkinButton(AckisRecipeList.ScanButton)
        local a,b,c,d,e = AckisRecipeList.ScanButton:GetPoint()
        AckisRecipeList.ScanButton:SetPoint(a,b,c,d-14,e-2)
      end
    end
  end)

  HookAddonOrVariable("TotemTimers", function()
    if C.thirdparty.totemtimers.enable == "0" then return end

    local function skin(button, weapon)
      if button and not button.pfskinned then
        button.pfskinned = true

        local icon = button.icon or _G[button:GetName().."Icon"]
        icon:SetDrawLayer("BORDER")

        SkinButton(button, nil, nil, nil, icon)
        SetAllPointsOffset(icon, button, 2)

        if _G[button:GetName().."Flash"] then
          SetAllPointsOffset(_G[button:GetName().."Flash"], button, 3)
          _G[button:GetName().."Flash"]:SetTexCoord(.08, .92, .08, .92)
        end

        if button.spellIcon then
          button.spellIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
          button.spellIcon:SetTexCoord(.08, .92, .08, .92)
        end

        if weapon then
          -- weapon button skin workaround taken from ElvUI-TBC:
          -- https://github.com/ElvUI-TBC/ElvUI_AddOnSkins/blob/master/ElvUI_AddOnSkins/Skins/Addons/totemTimers.lua#L92-L135
          local icon2frame = _G[button:GetName().."Icon2Frame"]
          icon2frame:SetFrameStrata("MEDIUM")
          icon2frame:SetWidth(icon2frame:GetWidth() + 1)
          button.icon2 = _G[button:GetName().."Icon2"]
          SetAllPointsOffset(button.icon2, icon2frame, 2)

          button.icon1Frame = CreateFrame("Frame", "TotemTimers_MainHandIcon1Frame", button)
          button.icon1Frame:SetWidth(16)
          button.icon1Frame:SetHeight(30)
          button.icon1Frame:SetPoint("LEFT", 0, 0)

          button.icon1 = button.icon1Frame:CreateTexture(nil, "MEDIUM")
          SetAllPointsOffset(button.icon1, button.icon1Frame, 3)
          button.icon1:SetTexture(icon:GetTexture())
          button.icon1:SetAlpha(icon:GetAlpha())

          _G[button:GetName().."Cooldown"]:SetFrameLevel(button.icon1Frame:GetFrameLevel() + 1)

          icon:Hide()
          hooksecurefunc(icon, "SetTexture", function(_, texture)
            button.icon1:SetTexture(texture)
          end)
          hooksecurefunc(icon, "SetAlpha", function(_, alpha)
            button.icon1:SetAlpha(alpha)
          end)

          if icon:GetTexCoordModifiesRect() then
            button.icon1:SetTexCoord(.08, .5, .08, .92)
          else
            button.icon1:SetTexCoord(.08, .92, .08, .92)
          end
          button.icon2:SetTexCoord(.5, .92, .08, .92)

          hooksecurefunc(icon, "SetTexCoord", function(self, arg1, arg2)
            if arg2 == 0.5 and arg1 == 0 then
              button.icon1:SetTexCoord(.08, .5, .08, .92)
            elseif arg2 == 1 then
              button.icon1:SetTexCoord(.08, .92, .08, .92)
            end
          end)
          hooksecurefunc(button.icon2, "SetTexCoord", function(self, arg1, arg2)
            if arg2 == 1 then self:SetTexCoord(.5, .92, .08, .92) end
          end)
        end
      end
    end

    hooksecurefunc("TotemTimers_SetupGlobals", function()
      for i=1,4 do -- skin main buttons
        for j=1,10 do skin(_G[i.."SlaveButton"..j]) end
        skin(_G["TotemTimers"..i])
      end

      for _, timer in pairs({ "EarthElemental", "FireElemental", "ManaTide", "ManaTrinket" }) do
        skin(_G["TotemTimers_"..timer])
      end

      for i, tracker in pairs({ "Ankh", "Shield", "MainHand", "EarthShield" }) do
        skin(_G["TotemTimers_"..tracker], i==3)
      end
    end)
  end)

  HookAddonOrVariable("DruidBarFrame", function()
    if C.thirdparty.druidbar.enable == "0" then return end
    local p = ManaBarColor[0]
    local pr, pg, pb = 0, 0, 0
    if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
    DruidBarKey.color = { pr, pg, pb, 1 }
    DruidBarKey.bordercolor = {1,1,1,0}
    DruidBarKey.bgcolor = {0,0,0,0}
    DruidBarKey.manatexture = pfUI.media[pfUI.uf.player.config.pbartexture]
    DruidBarKey.bordertexture = ""

    hooksecurefunc("DruidBar_MainGraphics", function()
      local f = pfUI.uf.player
      DruidBarFrame:SetWidth((f.config.pwidth ~= "-1" and f.config.pwidth or f.config.width))
      DruidBarFrame:SetHeight(f.config.pheight)
      DruidBarMana:SetAllPoints(DruidBarFrame)

      DruidBarText:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")
      DruidBarText1:SetFont(pfUI.font_unit, C.global.font_unit_size, "OUTLINE")

      StripTextures(DruidBarFrame)
      CreateBackdrop(DruidBarFrame)
      CreateBackdropShadow(DruidBarFrame)
    end)
  end)
end)
