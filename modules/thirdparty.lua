pfUI:RegisterModule("thirdparty", "vanilla:tbc", function()
  -- This module includes the core logic of thirdparty modules.
  -- Right now, in particular the functions to register addons to the
  -- dockframe of the chat panel aswell as the thirdparty root-table.
  -- This module is supposed to be loaded on all expansions, so only
  -- addons that can share the same glue code across expansions will go here.
  -- For expansion related code, see: thirdparty-vanilla and thirdparty-tbc.

  pfUI.thirdparty = {}

  do -- addon dockframe
    pfUI.thirdparty.meters = CreateFrame("Frame")
    pfUI.thirdparty.meters:SetScript("OnEvent", function()
      if C.thirdparty.showmeter == "1" then
        pfUI.thirdparty.meters.state = nil
      else
        pfUI.thirdparty.meters.state = true
      end

      pfUI.thirdparty.meters:Toggle()
      this:UnregisterAllEvents()
    end)

    pfUI.thirdparty.meters.damage = nil
    pfUI.thirdparty.meters.threat = nil
    pfUI.thirdparty.meters.state = nil

    function pfUI.thirdparty.meters:RegisterMeter(side, data)
      -- abort when one addon is already register on the side
      if pfUI.thirdparty.meters[side] then return end

      -- load addon table
      local config, addon, frame, single, dual, show, hide, once = unpack(data)

      -- put addon into dockmode when enabled
      if C.thirdparty[config] and C.thirdparty[config].dock == "1" then
        pfUI.thirdparty.meters[side] = data

        -- initialize and hide the frame in the beginning
        if once then once() end
        if hide then hide() end

        -- enable toggle event on the panel button
        if pfUI.panel then
          pfUI.panel.right.hide:SetScript("OnClick", function()
            pfUI.thirdparty.meters:Toggle()
          end)
        end

        -- show/hide meter on login by default
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
      end
    end

    function pfUI.thirdparty.meters:Resize()
      if not pfUI.chat or not pfUI.panel then return end

      if self.damage then -- resize damage meter
        local config, addon, frame, single, dual, show, hide = unpack(self.damage)
        if frame and C.thirdparty[config].dock == "1" then
          if not self.threat then single() else dual() end
        end
      end

      if self.threat then -- resize threat meter
        local config, addon, frame, single, dual, show, hide = unpack(self.threat)
        if frame and C.thirdparty[config].dock == "1" then
          if not self.damage then single() else dual() end
        end
      end
    end

    function pfUI.thirdparty.meters:Toggle()
      self:Resize()

      -- show/hide right chatframe
      if pfUI.chat and C.chat.right.enable == "1" then
        -- make sure the panel header stays hidden
        if self.state then
          pfUI.chat.right.panelTop:Show()
        else
          pfUI.chat.right.panelTop:Hide()
        end

        -- set chat visibility
        pfUI.chat.right:SetAlpha(self.state and 1 or 0)
      end

      -- show/hide damage meters
      if self.damage then
        local config, addon, frame, single, dual, show, hide = unpack(self.damage)
        if not self.state then show() else hide() end
      end

      -- show/hide threat meters
      if self.threat then
        local config, addon, frame, single, dual, show, hide = unpack(self.threat)
        if not self.state then show() else hide() end
      end

      -- show meters
      if not self.state then
        self.state = true
      else
        self.state = nil
      end
    end
  end


  do -- bag sort addon
    pfUI.thirdparty.bagsort = nil
    function pfUI.thirdparty.RegisterBagSort(name, bag, bagtooltip, bank, banktooltip)
      -- skip on certain conditions
      if pfUI.thirdparty.bagsort then return end
      if not pfUI.bag or not pfUI.bag.right then return end

      pfUI.thirdparty.bagsort = name

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

        pfUI.bag.right.sort:SetScript("OnClick", bag)

        pfUI.bag.right.sort:SetScript("OnEnter", function ()
          pfUI.bag.right.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
          pfUI.bag.right.sort.texture:SetVertexColor(1,1,.25,1)
          if bagtooltip then bagtooltip() end
        end)

        pfUI.bag.right.sort:SetScript("OnLeave", function ()
          CreateBackdrop(pfUI.bag.right.sort)
          pfUI.bag.right.sort.texture:SetVertexColor(.25,.25,.25,1)
          if GameTooltip:IsOwned(this) then
            GameTooltip:Hide()
          end
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

        pfUI.bag.left.sort:SetScript("OnClick", bank)

        pfUI.bag.left.sort:SetScript("OnEnter", function ()
          pfUI.bag.left.sort.backdrop:SetBackdropBorderColor(1,1,.25,1)
          pfUI.bag.left.sort.texture:SetVertexColor(1,1,.25,1)
          if banktooltip then banktooltip() end
        end)

        pfUI.bag.left.sort:SetScript("OnLeave", function ()
          CreateBackdrop(pfUI.bag.left.sort)
          pfUI.bag.left.sort.texture:SetVertexColor(.25,.25,.25,1)
          if GameTooltip:IsOwned(this) then
            GameTooltip:Hide()
          end
        end)
      end
    end
  end

  -- MrPlow Bag Sorting Addon.
  -- Vanilla: https://www.wowace.com/projects/mr-plow/files/288059
  -- TBC: https://www.wowace.com/projects/mr-plow/files/136162
  HookAddonOrVariable("MrPlow", function()
    if C.thirdparty.mrplow.enable == "0" then return end

    local sort = CreateFrame("Frame", nil)
    sort:RegisterEvent("PLAYER_ENTERING_WORLD")
    sort:SetScript("OnEvent", function()
      this:UnregisterAllEvents()

      local MrPlowL = AceLibrary and AceLibrary("AceLocale-2.2"):new("MrPlow")
      if not (MrPlowL and MrPlowL["Bank"]) then return end

      pfUI.thirdparty.RegisterBagSort("MrPlow",
        function()
          MrPlow:Works()
        end,
        function()
          GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
          GameTooltip:SetText(MrPlowL["Mr Plow"])
          GameTooltip:AddLine(MrPlowL["The Works"],1,1,1)
          GameTooltip:Show()
        end,
        function()
          MrPlow:Works(MrPlowL["Bank"])
        end,
        function()
          GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
          GameTooltip:SetText(MrPlowL["Mr Plow"])
          GameTooltip:AddLine(MrPlowL["Bank"],1,1,1)
          GameTooltip:Show()
        end)
    end)
  end)

  -- ShaguDPS Damage Meter
  -- Vanilla: https://github.com/shagu/ShaguDPS
  -- TBC: https://github.com/shagu/ShaguDPS
  HookAddonOrVariable("ShaguDPS", function()
    local docktable = { "shagudps", "ShaguDPS", "ShaguDPSWindow",
      function() -- single
        ShaguDPSWindow:ClearAllPoints()
        ShaguDPSWindow:SetAllPoints(pfUI.chat.right)
        ShaguDPSWindow:SetWidth(pfUI.chat.right:GetWidth())
        if ShaguDPSWindow.Resize then ShaguDPSWindow:Resize() end
      end,
      function() -- dual
        ShaguDPSWindow:ClearAllPoints()
        ShaguDPSWindow:SetPoint("TOPLEFT", pfUI.chat.right, "TOP", 0, 0)
        ShaguDPSWindow:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, 0)
        ShaguDPSWindow:SetWidth(pfUI.chat.right:GetWidth() / 2)
        if ShaguDPSWindow.Resize then ShaguDPSWindow:Resize() end
      end,
      function() -- show
        ShaguDPS.config.visible = 1
        ShaguDPS.window.Refresh(true)
      end,
      function() -- hide
        ShaguDPS.config.visible = 0
        ShaguDPS.window.Refresh(true)
      end
    }

    pfUI.thirdparty.meters:RegisterMeter("damage", docktable)

    if C.thirdparty.shagudps.skin == "1" then
      local hookRefresh = ShaguDPS.window.Refresh
      ShaguDPS.window.Refresh = function (arg1, arg2)
        hookRefresh(arg1, arg2)

        for wid=1,10 do
          local window = ShaguDPS.window[wid]

          -- legacy single-window support
          if wid == 1 and not window then
            window = ShaguDPS.window
          end

          if window then
            local _, chat_border = GetBorderSize("chat")

            window.title:Hide()
            window.title:SetPoint("TOPLEFT", 1, -1)
            window.title:SetPoint("TOPRIGHT", -1, -1)

            CreateBackdrop(window, chat_border, nil, (C.thirdparty.chatbg == "1" and .8))
            CreateBackdropShadow(window)

            local hook = window.Refresh
            if not window.pfRefreshHook then
              window.pfRefreshHook = window.Refresh
              window.Refresh = function(self, arg1, arg2)
                window.pfRefreshHook(self, arg1, arg2)

                -- keep backdrop hidden
                if C.thirdparty.shagudps.skin == "1" then
                  window:SetBackdrop(nil)
                  window.border:SetBackdrop(nil)
                end
              end
            end

            if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
              local r, g, b, a = strsplit(",", C.chat.global.background)
              window.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

              local r, g, b, a = strsplit(",", C.chat.global.border)
              window.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
            end

            -- skin buttons
            local buttons = {
              window.btnAnnounce, window.btnReset, window.btnSegment, window.btnMode,
              window.btnDamage, window.btnDPS, window.btnHeal, window.btnHPS,
              window.btnCurrent, window.btnOverall, window.btnWindow, window.btnSettings,
            }

            for _, button in pairs(buttons) do
              if button then
                button:SetHeight(14)
                CreateBackdrop(button, -1, true, .75)
                button:SetBackdropBorderColor(.4,.4,.4,1)

                if button:GetWidth() == 16 then
                  button:SetWidth(14)
                end
              end
            end

            window.border:Hide()
          end
        end
      end
    end
  end)

  -- DPSMate Damage Meter
  -- Vanilla: https://github.com/Geigerkind/DPSMate
  -- TBC: https://github.com/Geigerkind/DPSMateTBC
  HookAddonOrVariable("DPSMate_DPSMate", function()
    local docktable = { "dpsmate", "DPSMate", "DPSMate_DPSMate",
      function() -- single
        DPSMate_DPSMate:ClearAllPoints()
        DPSMate_DPSMate:SetAllPoints(pfUI.chat.right)
        DPSMate_DPSMate:SetWidth(pfUI.chat.right:GetWidth())
        DPSMate_DPSMate_ScrollFrame:ClearAllPoints()
        DPSMate_DPSMate_ScrollFrame:SetWidth(pfUI.chat.right:GetWidth())
        DPSMate_DPSMate_ScrollFrame:SetPoint("TOPLEFT", DPSMate_DPSMate_Head, "BOTTOMLEFT", 0, 0)
        DPSMate_DPSMate_ScrollFrame:SetPoint("BOTTOMRIGHT", pfUI.chat.right, "BOTTOMRIGHT", 0, pfUI.panel.right:GetHeight())
        DPSMate_DPSMate_ScrollFrame_Child:SetWidth(pfUI.chat.right:GetWidth())
        DPSMate_DPSMate_Resize:Hide()
      end,
      function() -- dual
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
      end,
      function() -- show
        DPSMate_DPSMate:Show()
      end,
      function() -- hide
        DPSMate_DPSMate:Hide()
      end
    }

    pfUI.thirdparty.meters:RegisterMeter("damage", docktable)

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

        if DPSMate.UpdatePointer then
          DPSMate:UpdatePointer()
        end
        DPSMate:InitializeFrames()

        for k, val in pairs(DPSMateSettings["windows"]) do
          local frame = _G["DPSMate_"..val["name"]]
          CreateBackdrop(frame, nil, nil, (C.thirdparty.chatbg == "1" and .8))
          CreateBackdropShadow(frame)

          if C.thirdparty.chatbg == "1" and C.chat.global.custombg == "1" then
            local r, g, b, a = strsplit(",", C.chat.global.background)
            frame.backdrop:SetBackdropColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))

            local r, g, b, a = strsplit(",", C.chat.global.border)
            frame.backdrop:SetBackdropBorderColor(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
          end
        end
      end
    end
  end)
end)
