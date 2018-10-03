-- load pfUI environment
setfenv(1, pfUI:GetEnvironment())

if pfUI.client < 20000 or pfUI.client > 20400 then return end
DEFAULT_CHAT_FRAME:AddMessage("Compatibility Mode for |cff33ffccTBC |cffffff002.4.3|r has been loaded. Good Luck!")

-- blacklist unrequired modules
pfUI.module.autoshift = true
pfUI.module.itemclick = true

-- [[ Constants ]]--
CASTBAR_EVENTS = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP",
  "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
  "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START",
  "UNIT_SPELLCAST_CHANNEL_STOP", "UNIT_SPELLCAST_CHANNEL_UPDATE",
  "PLAYER_TARGET_CHANGED" }

NAMEPLATE_OBJECTORDER = { "border", "glow", "_", "_", "name", "level",
  "levelicon", "raidicon" }

NAMEPLATE_FRAMETYPE = "Frame"

MINIMAP_TRACKING_FRAME = _G.MiniMapTracking
UI_OPTIONS_FRAME = _G.InterfaceOptionsFrame

FRIENDS_NAME_LOCATION = "ButtonTextLocation"

COOLDOWN_FRAME_TYPE = "Cooldown"
LOOT_BUTTON_FRAME_TYPE = "Button"

PLAYER_BUFF_START_ID = 0

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

--[[ DEBUG ]]--
function TargetByName()
  message("|cffff5555You shouldn't be here!|r TargetByName is blacklisted")
  message(debugstack())
  return
end
