-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())
if pfUI.expansion ~= "vanilla" then return end

-- [[ Constants ]]--
CASTBAR_EVENT_CAST_DELAY = "SPELLCAST_DELAYED"
CASTBAR_EVENT_CHANNEL_DELAY = "SPELLCAST_CHANNEL_UPDATE"
CASTBAR_EVENT_CAST_START = "SPELLCAST_START"
CASTBAR_EVENT_CHANNEL_START = "SPELLCAST_CHANNEL_START"

EVENTS_MINIMAP_ZONE_UPDATE = {"PLAYER_ENTERING_WORLD", "MINIMAP_ZONE_CHANGED"}

MICRO_BUTTONS = {
  'CharacterMicroButton', 'SpellbookMicroButton', 'TalentMicroButton',
  'QuestLogMicroButton', 'SocialsMicroButton', 'WorldMapMicroButton',
  'MainMenuMicroButton', 'HelpMicroButton',
}

NAMEPLATE_OBJECTORDER = { "border", "glow", "name", "level", "levelicon", "raidicon" }

NAMEPLATE_FRAMETYPE = "Button"

MINIMAP_TRACKING_FRAME = _G.MiniMapTrackingFrame

FRIENDS_NAME_LOCATION = "ButtonTextNameLocation"

COOLDOWN_FRAME_TYPE = "Model"
LOOT_BUTTON_FRAME_TYPE = "LootButton"

PLAYER_BUFF_START_ID = -1

ACTIONBAR_SECURE_TEMPLATE_BAR = nil
ACTIONBAR_SECURE_TEMPLATE_BUTTON = nil
UNITFRAME_SECURE_TEMPLATE = nil

--[[ Vanilla API Extensions ]]--
function hooksecurefunc(tbl, name, func, prepend)
  if type(tbl) == "string" then
    prepend, func, name, tbl = func, name, tbl, _G
  end

  if not tbl or not tbl[name] then return end

  pfUI.hooks[tostring(func)] = {}
  pfUI.hooks[tostring(func)]["old"] = tbl[name]
  pfUI.hooks[tostring(func)]["new"] = func

  if prepend then
    pfUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
      pfUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
      return pfUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
    end
  else
    pfUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
      local r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16 = pfUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
      pfUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
      return r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16
    end
  end

  tbl[name] = pfUI.hooks[tostring(func)]["function"]
end

do -- GetItemInfo
  local name, link, rarity, minlevel, itype, isubtype, stack
  function GetItemInfo(item)
    if not item then return end
    name, link, rarity, minlevel, itype, isubtype, stack = _G.GetItemInfo(item)
    return name, link, rarity, nil, minlevel, itype, isubtype, stack
  end
end

do -- RunMacroText
  local obj = { ["GetText"] = function(self) return self.text end }
  obj = setmetatable(obj, {__index = function(tab,key)
    local value = function() return end
    rawset(tab,key,value)
    return value
  end})

  function RunMacroText(text)
    obj.text = text
    ChatEdit_ParseText(obj, 1)
  end
end
