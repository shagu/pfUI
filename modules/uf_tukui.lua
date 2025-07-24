pfUI:RegisterModule("uf_tukui", "vanilla:tbc", function ()
  if C.unitframes.disable == "1" or C.unitframes.layout ~= "tukui" then return end

  -- update player layout
  local hookUpdateConfigPlayer = pfUI.uf.player.UpdateConfig
  function pfUI.uf.player.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigPlayer(pfUI.uf.player)

    -- load configs
    local rawborder, default_border = GetBorderSize("unitframes")
    local pspacing = C.unitframes.player.pspace * GetPerfectPixel()
    local tspacing = C.unitframes.target.pspace * GetPerfectPixel()

    -- adjust layout
    pfUI.uf.player:UpdateFrameSize()
    pfUI.uf.player:SetFrameStrata("LOW")
    pfUI.uf.player:SetHeight(pfUI.uf.player:GetHeight() + 2*default_border + (C.global.font_size * 1.25) + pspacing)

    if pfUI.uf.player.config.portrait == "left" then
      pfUI.uf.player.portrait:ClearAllPoints()
      pfUI.uf.player.portrait:SetPoint("TOPLEFT", pfUI.uf.player, "TOPLEFT", 0, 0)
    elseif pfUI.uf.player.config.portrait == "right" then
      pfUI.uf.player.portrait:ClearAllPoints()
      pfUI.uf.player.portrait:SetPoint("TOPRIGHT", pfUI.uf.player, "TOPRIGHT", 0, 0)
    end

    pfUI.uf.player.caption = pfUI.uf.player.caption or CreateFrame("Frame", "pfPlayerCaption", pfUI.uf.player)
    pfUI.uf.player.caption:SetHeight(C.global.font_size * 1.25)
    pfUI.uf.player.caption:SetPoint("BOTTOMRIGHT",pfUI.uf.player, "BOTTOMRIGHT",0, 0)
    pfUI.uf.player.caption:SetPoint("BOTTOMLEFT",pfUI.uf.player, "BOTTOMLEFT",0, 0)

    pfUI.uf.player.hpLeftText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpLeftText:ClearAllPoints()
    pfUI.uf.player.hpLeftText:SetPoint("LEFT",pfUI.uf.player.caption, "LEFT", default_border, 0)

    pfUI.uf.player.hpCenterText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpCenterText:ClearAllPoints()
    pfUI.uf.player.hpCenterText:SetPoint("CENTER",pfUI.uf.player.caption, "CENTER", 0, 0)

    pfUI.uf.player.hpRightText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpRightText:ClearAllPoints()
    pfUI.uf.player.hpRightText:SetPoint("RIGHT",pfUI.uf.player.caption, "RIGHT", -default_border, 0)

    pfUI.castbar.player:SetAllPoints(pfUI.uf.player.caption)
    UpdateMovable(pfUI.castbar.player, true)

    local _, anchor = pfUI.castbar.player:GetPoint()
    if anchor and anchor == pfUI.uf.player.caption then
      pfUI.castbar.player:SetHeight(pfUI.uf.player.caption:GetHeight())
    end

    CreateBackdrop(pfUI.uf.player.caption, default_border)
    if pfUI.castbar.player.bar.backdrop_shadow then
      pfUI.castbar.player.bar.backdrop_shadow:Hide()
    end
  end

  -- update target layout
  local hookUpdateConfigTarget = pfUI.uf.target.UpdateConfig
  function pfUI.uf.target.UpdateConfig()
    -- run default unitframe update function
    hookUpdateConfigTarget(pfUI.uf.target)

    -- load configs
    local rawborder, default_border = GetBorderSize("unitframes")
    local pspacing = C.unitframes.player.pspace
    local tspacing = C.unitframes.target.pspace

    -- adjust layout
    pfUI.uf.target:UpdateFrameSize()
    pfUI.uf.target:SetFrameStrata("LOW")
    pfUI.uf.target:SetHeight(pfUI.uf.target:GetHeight() + 2*default_border + (C.global.font_size * 1.25) + tspacing)

    if pfUI.uf.target.config.portrait == "left" then
      pfUI.uf.target.portrait:ClearAllPoints()
      pfUI.uf.target.portrait:SetPoint("TOPLEFT", pfUI.uf.target, "TOPLEFT", 0, 0)
    elseif pfUI.uf.target.config.portrait == "right" then
      pfUI.uf.target.portrait:ClearAllPoints()
      pfUI.uf.target.portrait:SetPoint("TOPRIGHT", pfUI.uf.target, "TOPRIGHT", 0, 0)
    end

    pfUI.uf.target.caption = pfUI.uf.target.caption or CreateFrame("Frame", "pfTargetCaption", pfUI.uf.target)
    pfUI.uf.target.caption:SetHeight(C.global.font_size * 1.25)
    pfUI.uf.target.caption:SetPoint("BOTTOMRIGHT",pfUI.uf.target,"BOTTOMRIGHT", 0, 0)
    pfUI.uf.target.caption:SetPoint("BOTTOMLEFT",pfUI.uf.target,"BOTTOMLEFT", 0, 0)

    pfUI.uf.target.hpLeftText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpLeftText:ClearAllPoints()
    pfUI.uf.target.hpLeftText:SetPoint("LEFT",pfUI.uf.target.caption, "LEFT", default_border, 0)

    pfUI.uf.target.hpCenterText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpCenterText:ClearAllPoints()
    pfUI.uf.target.hpCenterText:SetPoint("CENTER",pfUI.uf.target.caption, "CENTER", 0, 0)

    pfUI.uf.target.hpRightText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpRightText:ClearAllPoints()
    pfUI.uf.target.hpRightText:SetPoint("RIGHT",pfUI.uf.target.caption, "RIGHT", -default_border, 0)

    pfUI.castbar.target:SetAllPoints(pfUI.uf.target.caption)
    UpdateMovable(pfUI.castbar.target, true)

    local _, anchor = pfUI.castbar.target:GetPoint()
    if anchor and anchor == pfUI.uf.target.caption then
      pfUI.castbar.target:SetHeight(pfUI.uf.target.caption:GetHeight())
    end

    CreateBackdrop(pfUI.uf.target.caption, default_border)
    if pfUI.castbar.target.bar.backdrop_shadow then
      pfUI.castbar.target.bar.backdrop_shadow:Hide()
    end
  end

  -- trigger updates
  pfUI.uf.player.UpdateConfig()
  pfUI.uf.target.UpdateConfig()
end)
