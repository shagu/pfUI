-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

if pfUI.client > 11200 then return end

-- [[ Constants ]]--
CASTBAR_DELAY_EVENT = "SPELLCAST_DELAYED" -- SPELLCAST_CHANNEL_UPDATE ?

NAMEPLATE_OBJECTORDER = { "border", "glow", "name", "level", "levelicon",
  "raidicon" }

NAMEPLATE_FRAMETYPE = "Button"

MINIMAP_TRACKING_FRAME = _G.MiniMapTrackingFrame
UI_OPTIONS_FRAME = _G.UIOptionsFrame

FRIENDS_NAME_LOCATION = "ButtonTextNameLocation"

COOLDOWN_FRAME_TYPE = "Model"
LOOT_BUTTON_FRAME_TYPE = "LootButton"
LOOT_BUTTON_SLOT_FUNCTION = "SetSlot"

PLAYER_BUFF_START_ID = -1

--[[ Vanilla API Extensions ]]--
function hooksecurefunc(name, func, append)
  if not _G[name] then return end

  pfUI.hooks[tostring(func)] = {}
  pfUI.hooks[tostring(func)]["old"] = _G[name]
  pfUI.hooks[tostring(func)]["new"] = func

  if append then
    pfUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  else
    pfUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      pfUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  end

  _G[name] = pfUI.hooks[tostring(func)]["function"]
end

function HookScript(f, script, func)
  local prev = f:GetScript(script)
  f:SetScript(script, function()
    if prev then prev() end
    func()
  end)
end
