pfUI:RegisterModule("uf_tukui", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  local default_border = C.appearance.border.default
  if C.appearance.border.unitframes ~= "-1" then
    default_border = C.appearance.border.unitframes
  end

  local pspacing = C.unitframes.player.pspace
  local tspacing = C.unitframes.target.pspace

  if C.unitframes.layout == "tukui" then
    -- Player
    pfUI.uf.player:UpdateFrameSize()
    pfUI.uf.player:SetHeight(pfUI.uf.player:GetHeight() + 2*default_border + C.global.font_size + 2*default_border + pspacing)

    pfUI.uf.player.caption = CreateFrame("Frame", "pfPlayerCaption", pfUI.uf.player)
    pfUI.uf.player.caption:SetHeight(C.global.font_size + 2*default_border)
    pfUI.uf.player.caption:SetPoint("BOTTOMRIGHT",pfUI.uf.player, "BOTTOMRIGHT",0, 0)
    pfUI.uf.player.caption:SetPoint("BOTTOMLEFT",pfUI.uf.player, "BOTTOMLEFT",0, 0)

    pfUI.uf.player.leftText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.leftText:ClearAllPoints()
    pfUI.uf.player.leftText:SetPoint("TOPLEFT",pfUI.uf.player.caption, "TOPLEFT", default_border, 1)
    pfUI.uf.player.leftText:SetPoint("BOTTOMRIGHT",pfUI.uf.player.caption, "BOTTOMRIGHT", -default_border, 0)

    pfUI.uf.player.centerText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.centerText:ClearAllPoints()
    pfUI.uf.player.centerText:SetPoint("TOPLEFT",pfUI.uf.player.caption, "TOPLEFT", default_border, 1)
    pfUI.uf.player.centerText:SetPoint("BOTTOMRIGHT",pfUI.uf.player.caption, "BOTTOMRIGHT", -default_border, 0)

    pfUI.uf.player.rightText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.rightText:ClearAllPoints()
    pfUI.uf.player.rightText:SetPoint("TOPLEFT",pfUI.uf.player.caption, "TOPLEFT", default_border, 1)
    pfUI.uf.player.rightText:SetPoint("BOTTOMRIGHT",pfUI.uf.player.caption, "BOTTOMRIGHT", -default_border, 0)

    pfUI.castbar.player:SetAllPoints(pfUI.uf.player.caption)
    UpdateMovable(pfUI.castbar.player)
    CreateBackdrop(pfUI.uf.player.caption)

    -- Target
    pfUI.uf.target:UpdateFrameSize()
    pfUI.uf.target:SetHeight(pfUI.uf.target:GetHeight() + 2*default_border + C.global.font_size + 2*default_border + tspacing)

    pfUI.uf.target.caption = CreateFrame("Frame", "pfTargetCaption", pfUI.uf.target)
    pfUI.uf.target.caption:SetHeight(C.global.font_size + 2*default_border)
    pfUI.uf.target.caption:SetPoint("BOTTOMRIGHT",pfUI.uf.target,"BOTTOMRIGHT", 0, 0)
    pfUI.uf.target.caption:SetPoint("BOTTOMLEFT",pfUI.uf.target,"BOTTOMLEFT", 0, 0)

    pfUI.uf.target.leftText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.leftText:ClearAllPoints()
    pfUI.uf.target.leftText:SetPoint("TOPLEFT",pfUI.uf.target.caption, "TOPLEFT", default_border, 1)
    pfUI.uf.target.leftText:SetPoint("BOTTOMRIGHT",pfUI.uf.target.caption, "BOTTOMRIGHT", -default_border, 0)

    pfUI.uf.target.centerText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.centerText:ClearAllPoints()
    pfUI.uf.target.centerText:SetPoint("TOPLEFT",pfUI.uf.target.caption, "TOPLEFT", default_border, 1)
    pfUI.uf.target.centerText:SetPoint("BOTTOMRIGHT",pfUI.uf.target.caption, "BOTTOMRIGHT", -default_border, 0)

    pfUI.uf.target.rightText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.rightText:ClearAllPoints()
    pfUI.uf.target.rightText:SetPoint("TOPLEFT",pfUI.uf.target.caption, "TOPLEFT", default_border, 1)
    pfUI.uf.target.rightText:SetPoint("BOTTOMRIGHT",pfUI.uf.target.caption, "BOTTOMRIGHT", -default_border, 0)

    pfUI.castbar.target:SetAllPoints(pfUI.uf.target.caption)
    UpdateMovable(pfUI.castbar.target)
    CreateBackdrop(pfUI.uf.target.caption)
  end
end)
