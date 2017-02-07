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

pfUI = CreateFrame("Frame",nil,UIParent)
pfUI:RegisterEvent("ADDON_LOADED")

-- initialize default variables
pfUI.cache = {}
pfUI.module = {}
pfUI.modules = {}
pfUI.environment = {}
pfUI.movables = {}
pfUI.version = {}

pfLocaleClass = {}
pfLocaleBagtypes = {}
pfLocaleInvtypes = {}
pfLocaleShift = {}
pfLocaleSpells = {}
pfLocaleSpellInterrupts = {}
pfLocaleHunterbars = {}

pfUI:SetScript("OnEvent", function()

  -- some addons overwrite color and font settings
  -- need to enforce pfUI's selection every time
  pfUI.environment:UpdateFonts()
  pfUI.environment:UpdateColors()

  if arg1 == "pfUI" then
    if not pfUI_init then
      pfUI_init = {}
    end

    if not pfUI_profiles then
      pfUI_profiles = {}
    end

    -- read pfUI version from .toc file
    local major, minor, fix = pfUI.api.strsplit(".", tostring(GetAddOnMetadata("pfUI", "Version")))
    pfUI.version.major = tonumber(major) or 1
    pfUI.version.minor = tonumber(minor) or 2
    pfUI.version.fix   = tonumber(fix)   or 0
    pfUI.version.string = pfUI.version.major .. "." .. pfUI.version.minor .. "." .. pfUI.version.fix

    pfUI:LoadConfig()
    pfUI:MigrateConfig()

    -- reload environment
    pfUI.environment:UpdateFonts()
    pfUI.environment:UpdateColors()

    -- fill the cache
    pfUI.cache["locale"] = GetLocale()
    if pfUI.cache["locale"] ~= "enUS" and
       pfUI.cache["locale"] ~= "frFR" and
       pfUI.cache["locale"] ~= "deDE" and
       pfUI.cache["locale"] ~= "zhCN" and
       pfUI.cache["locale"] ~= "ruRU" then
       pfUI.cache["locale"] = "enUS"
    end

    for i,m in pairs(this.modules) do
      -- do not load disabled modules
      if pfUI_config["disabled"] and pfUI_config["disabled"][m]  == "1" then
        -- message("DEBUG: module " .. m .. " has been disabled")
      else
        pfUI.module[m]()
      end
    end
  end
end)

function pfUI:RegisterModule(n, f)
  pfUI.module[n] = f
  table.insert(pfUI.modules, n)
end

pfUI.backdrop = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\col", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
  insets = {left = -1, right = -1, top = -1, bottom = -1},
}

pfUI.backdrop_small = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\col", tile = true, tileSize = 8,
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

pfUI.firstrun = CreateFrame("Frame", "pfFirstRunWizard", UIParent)
pfUI.firstrun.steps = {}
pfUI.firstrun.next = nil

pfUI.firstrun:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.firstrun:SetScript("OnEvent", function() pfUI.firstrun:NextStep() end)

function pfUI.firstrun:AddStep(name, yfunc, nfunc, descr, cmpnt)
  if not name then return end

  local step = {}
  step.name = name
  step.yfunc = yfunc or nil
  step.nfunc = nfunc or nil
  step.descr = descr or nil
  step.cmpnt = cmpnt or nil

  table.insert(pfUI.firstrun.steps, step)
end

pfUI.firstrun:AddStep("cvars", function() pfUI.SetupCVars() end, nil, "|cff33ffccBlizzard: \"Interface Options\"|r\n\n"..
"Do you want me to setup the recommended blizzard UI settings?\n"..
"This will enable settings that can be found in the Interface section of your client.\n"..
"Options like Buff Durations, Instant Quest Text, Auto Selfcast and others will be set.\n")

function pfUI.firstrun:NextStep()
  if pfUI_init and next(pfUI_init) == nil then
    local yes = function()
      this:GetParent():Hide()
      pfUI_init["welcome"] = true
      pfUI.firstrun:NextStep()
    end

    local no = function()
      this:GetParent():Hide()
    end

    pfUI.api:CreateQuestionDialog("Welcome to |cff33ffccpf|cffffffffUI|r!\n\n"..
    "I'm the first run wizzard that will guide you through some basic configuration.\n"..
    "You'll now be prompted for several questions. To get a default installation,\n"..
    "you might want to click \"Yes\" everywhere. A few settings are client settings\n"..
    "(e.g chat questions) so if you don't want to lose your chat configurations, you\n"..
    "should be careful with your choices.\n\n"..
    "Visit |cff33ffcchttp://shagu.org|r to check for the latest version.", yes, no)
    return
  end

  for _, step in pairs(pfUI.firstrun.steps) do
    local name = step.name

    if not pfUI_init[name] then
      local function yes()
        pfUI_init[name] = true
        if step.yfunc then step.yfunc() end
        this:GetParent():Hide()
        pfUI.firstrun:NextStep()
      end

      local function no()
        pfUI_init[name] = true
        if step.nfunc then step.nfunc() end
        this:GetParent():Hide()
        pfUI.firstrun:NextStep()
      end

      if step.cmpnt and step.cmpnt == "edit" then
        pfUI.api:CreateQuestionDialog(step.descr, yes, no, true)
      else
        pfUI.api:CreateQuestionDialog(step.descr, yes, no, false)
      end

      return
    end
  end
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
  pfUI.api:CreateBackdrop(pfUI.info)
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
