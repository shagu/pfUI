pfUI_playerDB = {}
pfUI_config = {}

function pfUI:LoadConfig()
  --                MODULE        SUBGROUP   ENTRY               VALUE
  pfUI:UpdateConfig("global",     nil,       "font_size",        "10")
  pfUI:UpdateConfig("unitframes", nil,       "animation_speed",  "5")
  pfUI:UpdateConfig("unitframes", nil,       "portrait",         "1")
  pfUI:UpdateConfig("unitframes", nil,       "buff_size",        "22")
  pfUI:UpdateConfig("unitframes", nil,       "debuff_size",      "22")
  pfUI:UpdateConfig("unitframes", nil,       "layout",           "default")
  pfUI:UpdateConfig("unitframes", "player",  "width",            "200")
  pfUI:UpdateConfig("unitframes", "player",  "height",           "50")
  pfUI:UpdateConfig("unitframes", "player",  "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "target",  "width",            "200")
  pfUI:UpdateConfig("unitframes", "target",  "height",           "50")
  pfUI:UpdateConfig("unitframes", "target",  "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast",        "")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast_shift",  "")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast_alt",    "")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast_ctrl",   "")
  pfUI:UpdateConfig("bars",       nil,       "icon_size",        "22")
  pfUI:UpdateConfig("bars",       nil,       "border",           "2")
  pfUI:UpdateConfig("panel",      "left",    "left",             "guild")
  pfUI:UpdateConfig("panel",      "left",    "center",           "durability")
  pfUI:UpdateConfig("panel",      "left",    "right",            "friends")
  pfUI:UpdateConfig("panel",      "right",   "left",             "fps")
  pfUI:UpdateConfig("panel",      "right",   "center",           "time")
  pfUI:UpdateConfig("panel",      "right",   "right",            "gold")
  pfUI:UpdateConfig("panel",      "other",   "minimap",          "zone")
  pfUI:UpdateConfig("panel",      "xp",      "showalways",       "0")
  pfUI:UpdateConfig("castbar",    "player",  "hide_blizz",       "1")
  pfUI:UpdateConfig("tooltip",    nil,       "position",         "bottom")
  pfUI:UpdateConfig("chat",       "text",    "time",             "0")
  pfUI:UpdateConfig("chat",       "text",    "timeformat",       "%H:%M:%S")
  pfUI:UpdateConfig("chat",       "text",    "timebracket",      "[]")
  pfUI:UpdateConfig("chat",       "text",    "timecolor",        "dddddd")
  pfUI:UpdateConfig("nameplates", nil,       "showcastbar",      "1")
  pfUI:UpdateConfig("nameplates", nil,       "showdebuffs",      "0")
  pfUI:UpdateConfig("nameplates", nil,       "clickthrough",     "0")
  pfUI:UpdateConfig("thirdparty", "dpsmate", "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "wim",     "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "healcomm","enable",           "1")
  pfUI:UpdateConfig("position",   nil,       nil,                nil)
end

function pfUI:UpdateConfig(group, subgroup, entry, value)
  -- check for missing config groups
  if not pfUI_config[group] then
    pfUI_config[group] = {}
  end

  -- update config
  if not subgroup and entry and value and not pfUI_config[group][entry] then
    pfUI_config[group][entry] = value
  end

  -- check for missing config subgroups
  if subgroup and not pfUI_config[group][subgroup] then
    pfUI_config[group][subgroup] = {}
  end

  -- update config in subgroup
  if subgroup and entry and value and not pfUI_config[group][subgroup][entry] then
    pfUI_config[group][subgroup][entry] = value
  end
end
