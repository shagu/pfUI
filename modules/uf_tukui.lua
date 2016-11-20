pfUI:RegisterModule("uf_tukui", function ()
  -- do not go further on disabled UFs
  if pfUI_config.unitframes.disable == "1" then return end

  if pfUI_config.unitframes.layout == "tukui" then
    pfUI.uf.player.caption = CreateFrame("Frame",nil, pfUI.uf.player)
pfUI.utils:CreateBackdrop(    pfUI.uf.player.caption)
    pfUI.uf.player.caption:SetHeight(pfUI_config.global.font_size * 2)
    pfUI.uf.player.caption:SetPoint("TOPRIGHT",pfUI.uf.player,"BOTTOMRIGHT",0,-1)
    pfUI.uf.player.caption:SetPoint("TOPLEFT",pfUI.uf.player,"BOTTOMLEFT",0,-1)

    pfUI.uf.player.hpText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.hpText:SetPoint("RIGHT",pfUI.uf.player.caption, "RIGHT", -3, 0)

    pfUI.uf.player.powerText:SetParent(pfUI.uf.player.caption)
    pfUI.uf.player.powerText:SetPoint("LEFT",pfUI.uf.player.caption, "LEFT", 5, 0)

    pfUI.uf.target.caption = CreateFrame("Frame",nil, pfUI.uf.target)
pfUI.utils:CreateBackdrop(    pfUI.uf.target.caption)
    pfUI.uf.target.caption:SetHeight(pfUI_config.global.font_size * 2)
    pfUI.uf.target.caption:SetPoint("TOPRIGHT",pfUI.uf.target,"BOTTOMRIGHT",0,-1)
    pfUI.uf.target.caption:SetPoint("TOPLEFT",pfUI.uf.target,"BOTTOMLEFT",0,-1)

    pfUI.uf.target.hpText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.hpText:SetPoint("RIGHT",pfUI.uf.target.caption, "RIGHT", -3, 0)

    pfUI.uf.target.powerText:SetParent(pfUI.uf.target.caption)
    pfUI.uf.target.powerText:SetPoint("LEFT",pfUI.uf.target.caption, "LEFT", 5, 0)
  end
end)
