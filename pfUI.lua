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
if not pfUI_gold then
  pfUI_gold = {}
end

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
  pfUI.environment:UpdateFonts()
  pfUI.environment:UpdateColors()

  if arg1 == "pfUI" then
    -- read pfUI version from .toc file
    local major, minor, fix = pfUI.api.strsplit(".", tostring(GetAddOnMetadata("pfUI", "Version")))
    pfUI.version.major = tonumber(major) or 1
    pfUI.version.minor = tonumber(minor) or 2
    pfUI.version.fix   = tonumber(fix)   or 0
    pfUI.version.string = pfUI.version.major .. "." .. pfUI.version.minor .. "." .. pfUI.version.fix

    pfUI:LoadConfig()
    pfUI:MigrateConfig()

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
  bgFile = "Interface\\AddOns\\pfUI\\img\\col", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

pfUI.backdrop_no_top = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\col", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border_no_top", edgeSize = 8,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

pfUI.backdrop_underline = {
  edgeFile = "Interface\\AddOns\\pfUI\\img\\underline", edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

message = function (msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55"..msg)
end

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

pfUI.info = CreateFrame("Button", "pfInfoBox", UIParent)
pfUI.info:Hide()

pfUI.info.text = pfUI.info:CreateFontString("Status", "HIGH", "GameFontNormal")
pfUI.info.text:ClearAllPoints()
pfUI.info.text:SetFontObject(GameFontWhite)

pfUI.info.timeout = CreateFrame("StatusBar", nil, pfUI.info)
pfUI.info.timeout:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
pfUI.info.timeout:SetStatusBarColor(.3,1,.8,1)

function pfUI.info:ShowInfoBox(text, time, parent, height)
  if not text then return end
  if not time then time = 5 end
  if not parent then parent = UIParent end
  if not height then height = 100 end

  pfUI.info:SetParent(parent)
  pfUI.info:ClearAllPoints()
  pfUI.info.text:SetAllPoints(pfUI.info)
  pfUI.info.text:SetText(text)
  pfUI.info.text:SetFont(pfUI.font_default, 14, "OUTLINE")

  pfUI.info:SetWidth(pfUI.info.text:GetStringWidth() + 50)
  pfUI.info:SetHeight(height)
  pfUI.info:SetFrameStrata("DIALOG")
  pfUI.api.CreateBackdrop(pfUI.info)
  pfUI.info:SetPoint("TOP", 0, -25)

  pfUI.info.timeout:ClearAllPoints()
  pfUI.info.timeout:SetPoint("TOPLEFT", pfUI.info, "TOPLEFT", 3, -3)
  pfUI.info.timeout:SetPoint("TOPRIGHT", pfUI.info, "TOPRIGHT", -3, 3)
  pfUI.info.timeout:SetHeight(2)
  pfUI.info.timeout:SetMinMaxValues(0, time)
  pfUI.info.timeout:SetValue(time)

  pfUI.info.duration = time
  pfUI.info.lastshow = GetTime()
  pfUI.info:Show()
end

pfUI.info:SetScript("OnUpdate", function()
  local time = pfUI.info.lastshow + pfUI.info.duration - GetTime()
  pfUI.info.timeout:SetValue(time)

  if GetTime() > pfUI.info.lastshow + pfUI.info.duration then
    pfUI.info:SetAlpha(pfUI.info:GetAlpha()-0.05)
  end

  if pfUI.info:GetAlpha() <= 0.1 then
    pfUI.info:Hide()
    pfUI.info:SetAlpha(1)
  end
end)

pfUI.info:SetScript("OnClick", function() this:Hide() end)
