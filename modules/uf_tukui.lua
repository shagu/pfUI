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
    pfUI.uf.player.caption = CreateFrame("Frame", "pfPlayerCaption", pfUI.uf.player)
    pfUI.uf.player.caption:SetHeight(C.global.font_size + default_border)
    pfUI.uf.player.caption:SetPoint("TOPRIGHT",pfUI.uf.player,"BOTTOMRIGHT",0, -default_border*2 - pspacing)
    pfUI.uf.player.caption:SetPoint("TOPLEFT",pfUI.uf.player,"BOTTOMLEFT",0, -default_border*2 - pspacing)

    pfUI.uf.player.hpText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpText:SetAllPoints(pfUI.uf.player.caption)
    pfUI.uf.player.hpText:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    pfUI.castbar.player:SetAllPoints(pfUI.uf.player.caption)

    pfUI.uf.player.powerText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.powerText:SetAllPoints(pfUI.uf.player.caption)
    pfUI.uf.player.powerText:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
    CreateBackdrop(pfUI.uf.player.caption)

    -- Target
    pfUI.uf.target.caption = CreateFrame("Frame", "pfTargetCaption", pfUI.uf.target)
    pfUI.uf.target.caption:SetHeight(C.global.font_size + default_border)
    pfUI.uf.target.caption:SetPoint("TOPRIGHT",pfUI.uf.target,"BOTTOMRIGHT", 0, -default_border*2 - pspacing)
    pfUI.uf.target.caption:SetPoint("TOPLEFT",pfUI.uf.target,"BOTTOMLEFT", 0, -default_border*2 - pspacing)

    pfUI.uf.target.hpText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpText:SetAllPoints(pfUI.uf.target.caption)
    pfUI.uf.target.hpText:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")

    pfUI.castbar.target:SetAllPoints(pfUI.uf.target.caption)

    pfUI.uf.target.powerText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.powerText:SetAllPoints(pfUI.uf.target.caption)
    pfUI.uf.target.powerText:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
    CreateBackdrop(pfUI.uf.target.caption)
  end
end)
