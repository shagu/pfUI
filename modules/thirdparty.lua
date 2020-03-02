pfUI:RegisterModule("thirdparty", "vanilla:tbc", function()
  -- This module includes the core logic of thirdparty modules.
  -- Right now, in particular the functions to register addons to the
  -- dockframe of the chat panel aswell as the thirdparty root-table.
  -- This module is supposed to be loaded on all expansions, so only
  -- addons that can share the same glue code across expansions will go here.
  -- For expansion related code, see: thirdparty-vanilla and thirdparty-tbc.

  pfUI.thirdparty = {}
  pfUI.thirdparty.bagsort = nil

  do -- addon dockframe
    pfUI.thirdparty.meters = CreateFrame("Frame")
    pfUI.thirdparty.meters:SetScript("OnEvent", function()
      pfUI.thirdparty.meters.state = nil
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

        -- toggle meter by default if configured
        if C.thirdparty.showmeter == "1" then
          self:RegisterEvent("PLAYER_ENTERING_WORLD")
        end
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
end)
