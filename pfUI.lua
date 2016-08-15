SLASH_RELOAD1 = '/rl';
function SlashCmdList.RELOAD(msg, editbox)
  ReloadUI()
end

SLASH_PFUI1 = '/pfui';
function SlashCmdList.PFUI(msg, editbox)
  if pfUI.gui:IsShown() then
    pfUI.gui:Hide()
  else
    pfUI.gui:Show()
  end
end

SLASH_GM1, SLASH_GM2 = '/gm', '/support';
function SlashCmdList.GM(msg, editbox)
  ToggleHelpFrame(1)
end

pfUI = CreateFrame("Frame",nil,UIParent)
pfUI:RegisterEvent("ADDON_LOADED")
pfUI:SetScript("OnEvent", function()
  pfUI:LoadConfig()
  if arg1 == "pfUI" then
    pfUI:Debug("pfUI module loader:")
    for i,m in pairs(this.modules) do
      if not pfUI[m] then
        pfUI.module[m]()
        pfUI:Debug("=> " ..  m)
      end
    end
  end
end)

pfUI.module = {}
pfUI.modules = {}
pfLocaleClass = {}
pfLocaleSpells = {}
pfLocaleSpellEvents = {}
pfLocaleSpellInterrupts = {}

function pfUI:RegisterModule(n, f)
  pfUI.module[n] = f
  table.insert(pfUI.modules, n)
end

function pfUI:Debug(msg)
  -- DEFAULT_CHAT_FRAME:AddMessage(msg)
end

pfUI.backdrop = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\bg", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

pfUI.backdrop_gitter = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\gitter", tile = true, tileSize = 8,
}

pfUI.backdrop_col = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\bg", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

pfUI.backdrop_underline = {
  edgeFile = "Interface\\AddOns\\pfUI\\img\\underline", edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

pfUI.utils = CreateFrame("Frame",nil,UIParent)

function pfUI.utils:loadPosition(frame)
  if pfUI_config["position"][frame:GetName()] then
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", pfUI_config["position"][frame:GetName()].xpos, pfUI_config["position"][frame:GetName()].ypos)
  end
end

message = function (msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55"..msg)
end

ScriptErrors:SetScript("OnShow", function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcc3333ERROR: |cffff5555"..ScriptErrors_Message:GetText())
    ScriptErrors:Hide()
  end)

pfUI.uf = CreateFrame("Frame",nil,UIParent)
