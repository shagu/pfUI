if GetBuildInfo() ~= "2.4.3" then return end

message("TBC compat module loaded. Good Luck!")

-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

-- the "MiniMapTrackingFrame" is called "MiniMapTracking"
pfUI.api.MiniMapTrackingFrame = _G.MiniMapTracking

-- blacklist pfUI functions
pfUI.api.hooksecurefunc = nil
pfUI.api.select = nil

-- tbc removed the offset of -1
function pfUI.api.GetPlayerBuff(id, btype)
  return _G.GetPlayerBuff(id+1, btype)
end
