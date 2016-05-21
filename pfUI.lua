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

pfUI = CreateFrame("Frame",nil,UIParent)
pfUI:RegisterEvent("ADDON_LOADED")
pfUI:SetScript("OnEvent", function()
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

function pfUI:RegisterModule(n, f)
  pfUI.module[n] = f
  table.insert(pfUI.modules, n)
end

function pfUI:Debug(msg)
  if pfUI_config.debug == 1 then
    DEFAULT_CHAT_FRAME:AddMessage(msg)
  end
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

pfUI_playerDB = {}
pfUI_config = {
  debug = 1,
  ["unitframes"] = {
    animation_speed = 1,
    portrait = 1,
    buff_size = "22",
    debuff_size = "22",
    layout = "default",
    ["player"] = {
      width = 200,
      height = 50,
      pheight = 10,
    },
    ["target"] = {
      width = 200,
      height = 50,
      pheight = 10,
    },
  },
  ["bars"] = {
    icon_size = "22",
    border = 2,
  },
  ["panel"] = {
    ["left"] = {
      left = "exp",
      center = "friends",
      right = "guild",
    },
    ["right"] = {
      left = "durability",
      center = "gold",
      right = "gold",
    },
    ["other"] = {
      minimap = "zone",
    },
  }
}

pfUI.cache = CreateFrame("Frame",nil,UIParent)
pfUI.cache:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.cache:SetScript("OnEvent", function()
    _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    pfUI.cache.class_r, pfUI.cache.class_g, pfUI.cache.class_b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5

  end)

message = function (msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55"..msg)
end

ScriptErrors:SetScript("OnShow", function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcc3333ERROR: |cffff5555"..ScriptErrors_Message:GetText())
    ScriptErrors:Hide()
  end)

pfUI.uf = CreateFrame("Frame",nil,UIParent)
