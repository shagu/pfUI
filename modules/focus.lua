pfUI:RegisterModule("focus", function ()
  -- do not go further on disabled UFs
  if C.unitframes.disable == "1" then return end

  pfUI.uf.focus = pfUI.uf:CreateUnitFrame("Focus", nil, C.unitframes.focus, .2)
  pfUI.uf.focus:UpdateFrameSize()
  pfUI.uf.focus:SetPoint("CENTER", UIParent, "CENTER", 0,0)
  UpdateMovable(pfUI.uf.focus)
  pfUI.uf.focus:Hide()
end)
