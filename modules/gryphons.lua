pfUI:RegisterModule("gryphons", "vanilla:tbc", function ()
  pfUI.gryphons = {
    frames = {
      left = CreateFrame("Frame"),
      right = CreateFrame("Frame"),
    }
  }

  pfUI.gryphons.textures = {
    ["None"] = nil,
    ["Gryphon"] = "Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Dwarf",
    ["Lion"] = "Interface\\MainMenuBar\\UI-MainMenuBar-EndCap-Human",
  }

  pfUI.gryphons.UpdateConfig = function()
    for position, frame in pairs(pfUI.gryphons.frames) do
      local anchor = _G[C.bars.gryphons["anchor_"..position]]
      local texture = pfUI.gryphons.textures[C.bars.gryphons.texture]
      local r, g, b, a = GetStringColor(C.bars.gryphons.color)
      local size = tonumber(C.bars.gryphons.size) or 50
      local offset_h = tonumber(C.bars.gryphons.offset_h) or 0
      local offset_v = tonumber(C.bars.gryphons.offset_v) or 0
      local relative = "BOTTOM"..string.upper(position)

      frame:SetParent(anchor)
      frame:SetWidth(size)
      frame:SetHeight(size)
      frame:SetPoint(relative, anchor, relative, (position == "right" and -1 or 1) * offset_h, offset_v)
      frame:SetFrameLevel(128)

      frame.texture = frame.texture or frame:CreateTexture(nil, "OVERLAY")
      frame.texture:SetTexture(texture)
      frame.texture:SetVertexColor(r, g, b, a)
      frame.texture:SetAllPoints()

      if position == "right" then
        frame.texture:SetTexCoord(1, 0, 0, 1)
      end

      if texture then
        frame:Show()
      else
        frame:Hide()
      end
    end
  end

  pfUI.gryphons.UpdateConfig()
end)
