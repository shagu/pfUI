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

pfLocaleClass = {}
pfLocaleBagtypes = {}
pfLocaleShift = {}
pfLocaleSpells = {}
pfLocaleSpellEvents = {}
pfLocaleSpellInterrupts = {}

pfUI:SetScript("OnEvent", function()
  if not pfUI_init then
    pfUI_init = {}
  end

  pfUI:LoadConfig()

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

  if arg1 == "pfUI" then
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

pfUI.utils = CreateFrame("Frame",nil,UIParent)

function pfUI.utils:UpdateMovable(frame)
  local name = frame:GetName()

  if not pfUI.movables[name] then
    pfUI.movables[name] = true
    table.insert(pfUI.movables, name)
  end

  if pfUI_config["position"][frame:GetName()] then
    if pfUI_config["position"][frame:GetName()]["scale"] then
      frame:SetScale(pfUI_config["position"][frame:GetName()].scale)
    end

    if pfUI_config["position"][frame:GetName()]["xpos"] then
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", pfUI_config["position"][frame:GetName()].xpos, pfUI_config["position"][frame:GetName()].ypos)
    end
  end
end

function pfUI.utils:CreateBackdrop(f, inset, legacy, transp)
  -- use default inset if nothing is given
  local border = inset
  if not border then
    border = tonumber(pfUI_config.appearance.border.default)
  end

  -- bg and edge colors
  if not pfUI.cache.br then
    local br, bg, bb, ba = strsplit(",", pfUI_config.appearance.border.background)
    local er, eg, eb, ea = strsplit(",", pfUI_config.appearance.border.color)
    pfUI.cache.br, pfUI.cache.bg, pfUI.cache.bb, pfUI.cache.ba = br, bg, bb, ba
    pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea = er, eg, eb, ea
  end

  local br, bg, bb, ba =  pfUI.cache.br, pfUI.cache.bg, pfUI.cache.bb, pfUI.cache.ba
  local er, eg, eb, ea = pfUI.cache.er, pfUI.cache.eg, pfUI.cache.eb, pfUI.cache.ea
  if transp then ba = .8 end

  -- use legacy backdrop handling
  if legacy then
    f:SetBackdrop(pfUI.backdrop)
    f:SetBackdropColor(br, bg, bb, ba)
    f:SetBackdropBorderColor(er, eg, eb , ea)
    return
  end

  -- use new backdrop behaviour
  if not f.backdrop then
    f:SetBackdrop(nil)

    local border = tonumber(border) - 1
    local backdrop = pfUI.backdrop
    if border < 1 then backdrop = pfUI.backdrop_small end
  	local b = CreateFrame("Frame", nil, f)
  	b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
  	b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)

    local level = f:GetFrameLevel()
    if level < 1 then
  	  --f:SetFrameLevel(level + 1)
      b:SetFrameLevel(level)
    else
      b:SetFrameLevel(level - 1)
    end

    f.backdrop = b
    b:SetBackdrop(backdrop)
  end

  local b = f.backdrop
  b:SetBackdropColor(br, bg, bb, ba)
  b:SetBackdropBorderColor(er, eg, eb , ea)
end


message = function (msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55"..msg)
end

ScriptErrors:SetScript("OnShow", function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcc3333ERROR: |cffff5555"..ScriptErrors_Message:GetText())
    ScriptErrors:Hide()
  end)

pfUI.uf = CreateFrame("Frame",nil,UIParent)

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
  pfUI.info.text:SetFont("Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf", 14, "OUTLINE")

  pfUI.info:SetWidth(pfUI.info.text:GetStringWidth() + 50)
  pfUI.info:SetHeight(height)
  pfUI.utils:CreateBackdrop(pfUI.info)
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
