pfUI:RegisterModule("thirdparty-tbc", "tbc", function ()
  -- abort when thirdparty core module is not loaded
  if not pfUI.thirdparty then return end
  local rawborder, default_border = GetBorderSize()

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
end)
