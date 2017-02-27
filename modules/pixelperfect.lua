pfUI:RegisterModule("pixelperfect", function ()
  if C.global.pixelperfect == "1" then
    local resolution = GetCVar("gxResolution")
    for screenwidth, screenheight in string.gfind(resolution, "(.+)x(.+)") do
      local scale = (min(2, max(.64, 768/screenheight)))
      SetCVar("UseUIScale", 1)
      SetCVar("UIScale", scale)

      -- scale UIParent to native screensize
      UIParent:SetWidth(screenwidth)
      UIParent:SetHeight(screenheight)
      UIParent:SetPoint("CENTER",0,0)
    end
  end
end)
