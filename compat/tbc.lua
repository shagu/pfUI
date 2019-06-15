-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())
if pfUI.expansion ~= "tbc" then return end

-- [[ Constants ]]--
CASTBAR_EVENT_CAST_DELAY = "UNIT_SPELLCAST_DELAYED"
CASTBAR_EVENT_CHANNEL_DELAY = "UNIT_SPELLCAST_CHANNEL_UPDATE"
EVENTS_MINIMAP_ZONE_UPDATE = {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED"}

MICRO_BUTTONS = {
  'CharacterMicroButton', 'SpellbookMicroButton', 'TalentMicroButton',
  'QuestLogMicroButton', 'SocialsMicroButton', 'LFGMicroButton',
  'MainMenuMicroButton', 'HelpMicroButton',
}

NAMEPLATE_OBJECTORDER = { "border", "_", "_", "glow", "name", "level", "levelicon", "raidicon" }

NAMEPLATE_FRAMETYPE = "Frame"

MINIMAP_TRACKING_FRAME = _G.MiniMapTracking
UI_OPTIONS_FRAME = _G.InterfaceOptionsFrame

FRIENDS_NAME_LOCATION = "ButtonTextLocation"

COOLDOWN_FRAME_TYPE = "Cooldown"
LOOT_BUTTON_FRAME_TYPE = "Button"

PLAYER_BUFF_START_ID = 0

ACTIONBAR_SECURE_TEMPLATE_BAR = "SecureStateHeaderTemplate"
ACTIONBAR_SECURE_TEMPLATE_BUTTON = "SecureActionButtonTemplate"
UNITFRAME_SECURE_TEMPLATE = "SecureUnitButtonTemplate"

--[[ TBC API Extensions ]]--
function UnitBuff(unitstr, i)
  -- fake return values to be vanilla alike
  local name, rank, icon, count = _G.UnitBuff(unitstr, i)
  return icon, count
end

function UnitDebuff(unitstr, i)
  -- fake return values to be vanilla alike
  local name, rank, texture, stacks, dtype, duration, timeLeft = _G.UnitDebuff(unitstr, i)
  return texture, stacks, dtype
end

-- the function GetContainerNumSlots returns numbers for keyrings in tbc
function GetContainerNumSlots(bag)
  if bag == -2 and pfUI.bag and not pfUI.bag.showKeyring then
    return 0
  else
    return _G.GetContainerNumSlots(bag)
  end
end

-- map libdebuff to the regular function
libdebuff = {
  ["UnitDebuff"] = function(self, a1, a2, a3)
    return _G.UnitDebuff(a1,a2,a3)
  end
}

--[[ DEBUG ]]--
function TargetByName()
  message("|cffff5555You shouldn't be here!|r TargetByName is blacklisted")
  message(debugstack())
  return
end
