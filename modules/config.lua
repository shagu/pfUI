pfUI_playerDB = {}
pfUI_config = {}

function pfUI:LoadConfig()
  --                MODULE        SUBGROUP   ENTRY               VALUE
  pfUI:UpdateConfig("global",     nil,       "font_size",        "10")
  pfUI:UpdateConfig("global",     nil,       "font_default",     "arial")
  pfUI:UpdateConfig("global",     nil,       "font_square",      "homespun")
  pfUI:UpdateConfig("global",     nil,       "font_combat",      "diediedie")
  pfUI:UpdateConfig("appearance", "border",  "background",       "0, 0, 0, 1")
  pfUI:UpdateConfig("appearance", "border",  "color",            "0.3, 0.3, 0.3, 1")
  pfUI:UpdateConfig("appearance", "border",  "default",          "3")
  pfUI:UpdateConfig("appearance", "border",  "actionbars",       "-1")
  pfUI:UpdateConfig("appearance", "border",  "unitframes",       "-1")
  pfUI:UpdateConfig("appearance", "border",  "groupframes",      "-1")
  pfUI:UpdateConfig("appearance", "border",  "raidframes",       "-1")
  pfUI:UpdateConfig("appearance", "border",  "panels",           "-1")
  pfUI:UpdateConfig("appearance", "border",  "chat",             "-1")
  pfUI:UpdateConfig("appearance", "border",  "bags",             "-1")
  pfUI:UpdateConfig("appearance", "cd",      "mincolor",         "55ffff")
  pfUI:UpdateConfig("appearance", "cd",      "hourcolor",        "55aaff")
  pfUI:UpdateConfig("appearance", "cd",      "daycolor",         "5555ff")
  pfUI:UpdateConfig("appearance", "cd",      "threshold",        "2")
  pfUI:UpdateConfig("unitframes", nil,       "disable",          "0")
  pfUI:UpdateConfig("unitframes", nil,       "animation_speed",  "5")
  pfUI:UpdateConfig("unitframes", nil,       "portrait",         "1")
  pfUI:UpdateConfig("unitframes", nil,       "buff_size",        "20")
  pfUI:UpdateConfig("unitframes", nil,       "debuff_size",      "20")
  pfUI:UpdateConfig("unitframes", nil,       "layout",           "default")
  pfUI:UpdateConfig("unitframes", "player",  "width",            "200")
  pfUI:UpdateConfig("unitframes", "player",  "height",           "50")
  pfUI:UpdateConfig("unitframes", "player",  "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "player",  "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "player",  "showPVPMinimap",   "0")
  pfUI:UpdateConfig("unitframes", "player",  "showPVP",          "0")
  pfUI:UpdateConfig("unitframes", "target",  "width",            "200")
  pfUI:UpdateConfig("unitframes", "target",  "height",           "50")
  pfUI:UpdateConfig("unitframes", "target",  "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "target",  "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "ttarget", "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "pet",     "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "group",   "hide_in_raid",     "0")
  pfUI:UpdateConfig("unitframes", "group",   "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "raid",    "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "raid",    "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "raid",    "show_missing",     "0")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast",        "")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast_shift",  "")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast_alt",    "")
  pfUI:UpdateConfig("unitframes", "raid",    "clickcast_ctrl",   "")
  pfUI:UpdateConfig("unitframes", "raid",    "buffs_buffs",      "0")
  pfUI:UpdateConfig("unitframes", "raid",    "buffs_hots",       "0")
  pfUI:UpdateConfig("unitframes", "raid",    "buffs_procs",      "0")
  pfUI:UpdateConfig("unitframes", "raid",    "buffs_classonly",  "0")
  pfUI:UpdateConfig("unitframes", "raid",    "debuffs_enable",   "0")
  pfUI:UpdateConfig("unitframes", "raid",    "debuffs_class",    "0")
  pfUI:UpdateConfig("bars",       nil,       "icon_size",        "18")
  pfUI:UpdateConfig("bars",       nil,       "background",       "1")
  pfUI:UpdateConfig("bars",       nil,       "hide_time",        "1")
  pfUI:UpdateConfig("bars",       nil,       "hide_bottom",      "0")
  pfUI:UpdateConfig("bars",       nil,       "hide_bottomleft",  "0")
  pfUI:UpdateConfig("bars",       nil,       "hide_bottomright", "0")
  pfUI:UpdateConfig("bars",       nil,       "hide_vertical",    "0")
  pfUI:UpdateConfig("bars",       nil,       "hide_shapeshift",  "0")
  pfUI:UpdateConfig("bars",       nil,       "hide_pet",         "0")
  pfUI:UpdateConfig("panel",      "left",    "left",             "guild")
  pfUI:UpdateConfig("panel",      "left",    "center",           "durability")
  pfUI:UpdateConfig("panel",      "left",    "right",            "friends")
  pfUI:UpdateConfig("panel",      "right",   "left",             "fps")
  pfUI:UpdateConfig("panel",      "right",   "center",           "time")
  pfUI:UpdateConfig("panel",      "right",   "right",            "gold")
  pfUI:UpdateConfig("panel",      "other",   "minimap",          "zone")
  pfUI:UpdateConfig("panel",      "micro",   "enable",           "0")
  pfUI:UpdateConfig("panel",      "xp",      "showalways",       "0")
  pfUI:UpdateConfig("castbar",    "player",  "hide_blizz",       "1")
  pfUI:UpdateConfig("castbar",    "player",  "hide_pfui",        "0")
  pfUI:UpdateConfig("castbar",    "target",  "hide_pfui",        "0")
  pfUI:UpdateConfig("tooltip",    nil,       "position",         "bottom")
  pfUI:UpdateConfig("chat",       "text",    "input_width",      "0")
  pfUI:UpdateConfig("chat",       "text",    "input_height",     "0")
  pfUI:UpdateConfig("chat",       "text",    "time",             "0")
  pfUI:UpdateConfig("chat",       "text",    "timeformat",       "%H:%M:%S")
  pfUI:UpdateConfig("chat",       "text",    "timebracket",      "[]")
  pfUI:UpdateConfig("chat",       "text",    "timecolor",        "dddddd")
  pfUI:UpdateConfig("chat",       "left",    "height",           "150")
  pfUI:UpdateConfig("chat",       "right",   "height",           "150")
  pfUI:UpdateConfig("chat",       "global",  "custombg",         "0")
  pfUI:UpdateConfig("chat",       "global",  "bgcolor",          ".2,.2,.2")
  pfUI:UpdateConfig("chat",       "global",  "bgtransp",         ".5")
  pfUI:UpdateConfig("nameplates", nil,       "showcastbar",      "1")
  pfUI:UpdateConfig("nameplates", nil,       "showdebuffs",      "0")
  pfUI:UpdateConfig("nameplates", nil,       "clickthrough",     "0")
  pfUI:UpdateConfig("nameplates", nil,       "raidiconsize",     "16")
  pfUI:UpdateConfig("thirdparty", "dpsmate", "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "wim",     "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "healcomm","enable",           "1")
  pfUI:UpdateConfig("thirdparty", "cleanup", "enable",           "1")
  pfUI:UpdateConfig("position",   nil,       nil,                nil)
  pfUI:UpdateConfig("disabled",   nil,       nil,                nil)
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
