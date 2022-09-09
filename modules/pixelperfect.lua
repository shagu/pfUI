pfUI:RegisterModule("pixelperfect", "vanilla:tbc", function ()
  -- pixel perfect
  local function pixelperfect()
    local conf = tonumber(C.global.pixelperfect)
    if conf < 4 then
      -- restore gamesettings
      local scale = GetCVar("uiScale")
      local use = GetCVar("useUiScale")

      if use == 1 then
        UIParent:SetScale(tonumber(use))
      else
        UIParent:SetScale(.9)
      end
    else
      -- apply pixel dependent scaling
      local resolution = GetCVar("gxResolution")

      for screenwidth, screenheight in gfind(resolution, "(.+)x(.+)") do
        local screenheight = tonumber(screenheight) / 8
        local scale = 768 / ( screenheight * conf )

        SetCVar("uiScale", scale)
        SetCVar("useUiScale", 1)

        UIParent:SetScale(scale)
      end
    end
  end

  -- pixelperfect: native UIScale listener
  if tonumber(C.global.pixelperfect) > 0 then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", pixelperfect)
    pixelperfect()
  end

  pfUI.pixelperfect = {}
  function pfUI.pixelperfect:UpdateConfig()
    pixelperfect()
  end

  pfUI.pixelperfect:UpdateConfig()
end)
