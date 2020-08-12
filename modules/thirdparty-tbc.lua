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

  HookAddonOrVariable("DruidBarFrame", function()
    if C.thirdparty.druidbar.enable == "0" then return end
    local p = ManaBarColor[0]
    local pr, pg, pb = 0, 0, 0
    if p then pr, pg, pb = p.r + .5, p.g +.5, p.b +.5 end
    DruidBarKey.color = { pr, pg, pb, 1 }
    DruidBarKey.bordercolor = {1,1,1,0}
    DruidBarKey.bgcolor = {0,0,0,0}
    DruidBarKey.manatexture = pfUI.media["img:bar"]
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
