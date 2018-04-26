SLASH_RELOAD1 = '/rl'
function SlashCmdList.RELOAD(msg, editbox)
  ReloadUI()
end

SLASH_PFUI1 = '/pfui'
function SlashCmdList.PFUI(msg, editbox)
  if pfUI.gui:IsShown() then
    pfUI.gui:Hide()
  else
    pfUI.gui:Show()
  end
end

SLASH_GM1, SLASH_GM2 = '/gm', '/support'
function SlashCmdList.GM(msg, editbox)
  ToggleHelpFrame(1)
end

pfUI = CreateFrame("Frame", nil, UIParent)
pfUI:RegisterEvent("ADDON_LOADED")

-- initialize saved variables
pfUI_playerDB = {}
pfUI_config = {}
pfUI_init = {}
pfUI_profiles = {}
pfUI_gold = {}

-- localization
pfUI_locale = {}
pfUI_translation = {}

-- initialize default variables
pfUI.cache = {}
pfUI.module = {}
pfUI.modules = {}
pfUI.skin = {}
pfUI.skins = {}
pfUI.environment = {}
pfUI.movables = {}
pfUI.version = {}
pfUI.hooks = {}
pfUI.env = {}

-- setup pfUI namespace
setmetatable(pfUI.env, {__index = getfenv(0)})

function pfUI:UpdateColors()
  ManaBarColor = {}
  ManaBarColor[0] = { r = 0.00, g = 0.00, b = 1.00, prefix = TEXT(MANA) };
  ManaBarColor[1] = { r = 1.00, g = 0.00, b = 0.00, prefix = TEXT(RAGE_POINTS) };
  ManaBarColor[2] = { r = 1.00, g = 0.50, b = 0.25, prefix = TEXT(FOCUS_POINTS) };
  ManaBarColor[3] = { r = 1.00, g = 1.00, b = 0.00, prefix = TEXT(ENERGY_POINTS) };
  ManaBarColor[4] = { r = 0.00, g = 1.00, b = 1.00, prefix = TEXT(HAPPINESS_POINTS) };

  RAID_CLASS_COLORS = {
    ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
    ["MAGE"]    = { r = 0.41, g = 0.8,  b = 0.94, colorStr = "ff69ccf0" },
    ["ROGUE"]   = { r = 1,    g = 0.96, b = 0.41, colorStr = "fffff569" },
    ["DRUID"]   = { r = 1,    g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
    ["HUNTER"]  = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
    ["SHAMAN"]  = { r = 0.14, g = 0.35, b = 1.0,  colorStr = "ff0070de" },
    ["PRIEST"]  = { r = 1,    g = 1,    b = 1,    colorStr = "ffffffff" },
    ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, colorStr = "ff9482c9" },
    ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" },
  }

  RAID_CLASS_COLORS = setmetatable(RAID_CLASS_COLORS, { __index = function(tab,key)
    return { r = 0.6,  g = 0.6,  b = 0.6,  colorStr = "ff999999" }
  end})
end

function pfUI:UpdateFonts()
  -- abort when config is not ready yet
  if not pfUI_config or not pfUI_config.global then return end

  -- load font configuration
  local default, unit, combat
  if pfUI_config.global.force_region == "1" and GetLocale() == "zhCN" then
    -- force locale compatible fonts
    default = "Fonts\\FZXHLJW.TTF"
    combat = "Fonts\\FZXHLJW.TTF"
    unit = "Fonts\\FZXHLJW.TTF"
  elseif pfUI_config.global.force_region == "1" and GetLocale() == "koKR" then
    -- force locale compatible fonts
    default = "Fonts\\2002.TTF"
    combat = "Fonts\\2002.TTF"
    unit = "Fonts\\2002.TTF"
  else
    -- use default entries
    default = pfUI_config.global.font_default
    combat = pfUI_config.global.font_combat
    unit = pfUI_config.global.font_unit
  end

  -- write setting shortcuts
  pfUI.font_default = default
  pfUI.font_combat = combat
  pfUI.font_unit = unit

  pfUI.font_default_size = default_size
  pfUI.font_combat_size = combat_size
  pfUI.font_unit_size = unit_size

  -- set game constants
  STANDARD_TEXT_FONT = default
  DAMAGE_TEXT_FONT   = combat
  NAMEPLATE_FONT     = default
  UNIT_NAME_FONT     = default

  -- change default game font objects
  SystemFont:SetFont(default, 15)
  GameFontNormal:SetFont(default, 12)
  GameFontBlack:SetFont(default, 12)
  GameFontNormalSmall:SetFont(default, 11)
  GameFontNormalLarge:SetFont(default, 16)
  GameFontNormalHuge:SetFont(default, 20)
  NumberFontNormal:SetFont(default, 14, "OUTLINE")
  NumberFontNormalSmall:SetFont(default, 14, "OUTLINE")
  NumberFontNormalLarge:SetFont(default, 16, "OUTLINE")
  NumberFontNormalHuge:SetFont(default, 30, "OUTLINE")
  QuestTitleFont:SetFont(default, 18)
  QuestFont:SetFont(default, 13)
  QuestFontHighlight:SetFont(default, 14)
  ItemTextFontNormal:SetFont(default, 15)
  MailTextFontNormal:SetFont(default, 15)
  SubSpellFont:SetFont(default, 12)
  DialogButtonNormalText:SetFont(default, 16)
  ZoneTextFont:SetFont(default, 34, "OUTLINE")
  SubZoneTextFont:SetFont(default, 24, "OUTLINE")
  TextStatusBarTextSmall:SetFont(default, 12, "NORMAL")
  GameTooltipText:SetFont(default, 12)
  GameTooltipTextSmall:SetFont(default, 12)
  GameTooltipHeaderText:SetFont(default, 13)
  WorldMapTextFont:SetFont(default, 102, "THICK")
  InvoiceTextFontNormal:SetFont(default, 12)
  InvoiceTextFontSmall:SetFont(default, 12)
  CombatTextFont:SetFont(combat, 25)
  ChatFontNormal:SetFont(default, 13, pfUI_config.chat.text.outline == "1" and "OUTLINE")
end

function pfUI:GetEnvironment()
  -- load api into environment
  for m, func in pairs(pfUI.api or {}) do
    pfUI.env[m] = func
  end

  local lang = pfUI_config.global and pfUI_translation[pfUI_config.global.language] and pfUI_config.global.language or GetLocale()
  local T = setmetatable(pfUI_translation[lang] or {}, { __index = function(tab,key)
    local value = tostring(key)
    rawset(tab,key,value)
    return value
  end})

  pfUI.env._G = getfenv(0)
  pfUI.env.T = T
  pfUI.env.C = pfUI_config
  pfUI.env.L = (pfUI_locale[GetLocale()] or pfUI_locale["enUS"])

  return pfUI.env
end

pfUI:SetScript("OnEvent", function()
  -- some addons overwrite color and font settings
  -- need to enforce pfUI's selection every time
  pfUI:UpdateFonts()
  pfUI:UpdateColors()

  if arg1 == "pfUI" then
    -- read pfUI version from .toc file
    local major, minor, fix = pfUI.api.strsplit(".", tostring(GetAddOnMetadata("pfUI", "Version")))
    pfUI.version.major = tonumber(major) or 1
    pfUI.version.minor = tonumber(minor) or 2
    pfUI.version.fix   = tonumber(fix)   or 0
    pfUI.version.string = pfUI.version.major .. "." .. pfUI.version.minor .. "." .. pfUI.version.fix

    pfUI:LoadConfig()
    pfUI:MigrateConfig()
    pfUI:UpdateFonts()

    -- load modules
    for i,m in pairs(this.modules) do
      if not ( pfUI_config["disabled"] and pfUI_config["disabled"][m]  == "1" ) then
        setfenv(pfUI.module[m], pfUI:GetEnvironment())
        pfUI.module[m]()
      end
    end

    -- load skins
    for i,s in pairs(this.skins) do
      if not ( pfUI_config["disabled"] and pfUI_config["disabled"]["skin_" .. s]  == "1" ) then
        setfenv(pfUI.skin[s], pfUI:GetEnvironment())
        pfUI.skin[s]()
      end
    end
  end
end)

function pfUI:RegisterModule(n, f)
  pfUI.module[n] = f
  table.insert(pfUI.modules, n)
end

function pfUI:RegisterSkin(n, f)
  pfUI.skin[n] = f
  table.insert(pfUI.skins, n)
end

pfUI.backdrop = {
  bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0,
  edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}
pfUI.backdrop_no_top = pfUI.backdrop

pfUI.backdrop_hover = {
  edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 24,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

message = function (msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55" .. ( msg or "nil" ))
end

print = message

ScriptErrors:SetScript("OnShow", function(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcc3333ERROR: |cffff5555"..ScriptErrors_Message:GetText())
  ScriptErrors:Hide()
end)

function pfUI.SetupCVars()
  ClearTutorials()
  TutorialFrame_HideAllAlerts()

  ConsoleExec("CameraDistanceMaxFactor 5")

  SetCVar("autoSelfCast", "1")
  SetCVar("profanityFilter", "0")

  MultiActionBar_ShowAllGrids()
  ALWAYS_SHOW_MULTIBARS = "1"

  SHOW_BUFF_DURATIONS = "1"
  QUEST_FADING_DISABLE = "1"
  NAMEPLATES_ON = "1"

  SHOW_COMBAT_TEXT = "1"
  COMBAT_TEXT_SHOW_LOW_HEALTH_MANA = "1"
  COMBAT_TEXT_SHOW_AURAS = "1"
  COMBAT_TEXT_SHOW_AURA_FADE = "1"
  COMBAT_TEXT_SHOW_COMBAT_STATE = "1"
  COMBAT_TEXT_SHOW_DODGE_PARRY_MISS = "1"
  COMBAT_TEXT_SHOW_RESISTANCES = "1"
  COMBAT_TEXT_SHOW_REPUTATION = "1"
  COMBAT_TEXT_SHOW_REACTIVES = "1"
  COMBAT_TEXT_SHOW_FRIENDLY_NAMES = "1"
  COMBAT_TEXT_SHOW_COMBO_POINTS = "1"
  COMBAT_TEXT_SHOW_MANA = "1"
  COMBAT_TEXT_FLOAT_MODE = "1"
  COMBAT_TEXT_SHOW_HONOR_GAINED = "1"
  UIParentLoadAddOn("Blizzard_CombatText")
end
