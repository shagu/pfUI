-- Skip module initialization on every other client than TurtleWoW.
if not TargetHPText or not TargetHPPercText then return end

pfUI:RegisterModule("turtle-wow", "vanilla", function ()
  local delay = CreateFrame("Frame")
  delay:SetScript("OnUpdate", function()
    if pfUI.map then
      -- while pfUI map is loaded, disable turtle wows window-implementation
      _G.WorldMapFrame_Maximize()
      pfUI.map.loader:GetScript("OnEvent")()

      _G.WorldMapFrame_Minimize = function() return end
      _G.WorldMapFrame_Maximize = function() return end

      _G.WorldMapFrameMaximizeButton.Show = function() return end
      _G.WorldMapFrameMaximizeButton:Hide()

      _G.WorldMapFrameMinimizeButton.Show = function() return end
      _G.WorldMapFrameMinimizeButton:Hide()

      WorldMapFrameTitle.Show = function() return end
      WorldMapFrameTitle:Hide()
    end

    this:Hide()
  end)
end)
