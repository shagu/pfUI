pfUI:RegisterModule("pixelperfect", "vanilla:tbc", function ()
  -- pre-calculated min values
  local statics = {
    [4] = 1.4222222222222,
    [5] = 1.1377777777778,
    [6] = 0.94814814814815,
    [7] = 0.81269841269841,
    [8] = 0.71111111111111,
  }

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
      local scale = conf and statics[conf] or 1

      SetCVar("uiScale", scale)
      SetCVar("useUiScale", 1)

      UIParent:SetScale(scale)
    end
  end

  -- pixelperfect: native UIScale listener
  if tonumber(C.global.pixelperfect) > 0 then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", pixelperfect)
    pixelperfect()
  end

  pfUI.pixelperfect = {
    UpdateConfig = pixelperfect
  }
end)
