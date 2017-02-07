pfUI_playerDB = {}
pfUI_config = {}

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

function pfUI:LoadConfig()
  --                MODULE        SUBGROUP       ENTRY               VALUE
  pfUI:UpdateConfig("global",     nil,           "profile",          "default")
  pfUI:UpdateConfig("global",     nil,           "pixelperfect",     "0")
  pfUI:UpdateConfig("global",     nil,           "offscreen",        "0")
  pfUI:UpdateConfig("global",     nil,           "font_size",        "12")
  pfUI:UpdateConfig("global",     nil,           "font_default",     "Myriad-Pro")
  pfUI:UpdateConfig("global",     nil,           "font_square",      "Homespun")
  pfUI:UpdateConfig("global",     nil,           "font_combat",      "Continuum")
  pfUI:UpdateConfig("global",     nil,           "force_region",     "1")
  pfUI:UpdateConfig("global",     nil,           "errors_limit",     "1")
  pfUI:UpdateConfig("global",     nil,           "errors_hide",      "0")
  pfUI:UpdateConfig("global",     nil,           "hidebuff",         "0")
  pfUI:UpdateConfig("global",     nil,           "hidewbuff",        "0")
  pfUI:UpdateConfig("global",     nil,           "twentyfour",       "1")

  pfUI:UpdateConfig("appearance", "border",      "background",       "0,0,0,1")
  pfUI:UpdateConfig("appearance", "border",      "color",            "0.3,0.3,0.3,1")
  pfUI:UpdateConfig("appearance", "border",      "default",          "3")
  pfUI:UpdateConfig("appearance", "border",      "actionbars",       "-1")
  pfUI:UpdateConfig("appearance", "border",      "unitframes",       "-1")
  pfUI:UpdateConfig("appearance", "border",      "groupframes",      "-1")
  pfUI:UpdateConfig("appearance", "border",      "raidframes",       "-1")
  pfUI:UpdateConfig("appearance", "border",      "panels",           "-1")
  pfUI:UpdateConfig("appearance", "border",      "chat",             "-1")
  pfUI:UpdateConfig("appearance", "border",      "bags",             "-1")
  pfUI:UpdateConfig("appearance", "cd",          "mincolor",         ".2,1,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "hourcolor",        ".2,.5,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "daycolor",         ".2,.2,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "threshold",        "2")
  pfUI:UpdateConfig("appearance", "castbar",     "castbarcolor",     ".7,.7,.9,.8")
  pfUI:UpdateConfig("appearance", "castbar",     "channelcolor",     ".9,.9,.7,.8")
  pfUI:UpdateConfig("appearance", "loot",        "autoresize",       "1")
  pfUI:UpdateConfig("appearance", "infight",     "screen",           "0")
  pfUI:UpdateConfig("appearance", "infight",     "common",           "1")
  pfUI:UpdateConfig("appearance", "infight",     "group",            "0")
  pfUI:UpdateConfig("appearance", "bags",        "borderlimit",      "1")
  pfUI:UpdateConfig("appearance", "bags",        "borderonlygear",   "0")
  pfUI:UpdateConfig("appearance", "minimap",     "mouseoverzone",    "0")

  pfUI:UpdateConfig("unitframes", nil,           "disable",          "0")
  pfUI:UpdateConfig("unitframes", nil,           "pastel",           "1")
  pfUI:UpdateConfig("unitframes", nil,           "custom",           "0")
  pfUI:UpdateConfig("unitframes", nil,           "customcolor",      ".2,.2,.2,1")
  pfUI:UpdateConfig("unitframes", nil,           "animation_speed",  "5")
  pfUI:UpdateConfig("unitframes", nil,           "portraitalpha",    "0.1")
  pfUI:UpdateConfig("unitframes", nil,           "portraittexture",  "1")

  pfUI:UpdateConfig("unitframes", nil,           "buff_size",        "20")
  pfUI:UpdateConfig("unitframes", nil,           "debuff_size",      "20")
  pfUI:UpdateConfig("unitframes", nil,           "layout",           "default")
  pfUI:UpdateConfig("unitframes", nil,           "globalclick",      "0")

  pfUI:UpdateConfig("unitframes", "player",      "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "player",      "width",            "200")
  pfUI:UpdateConfig("unitframes", "player",      "height",           "50")
  pfUI:UpdateConfig("unitframes", "player",      "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "player",      "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "player",      "showPVPMinimap",   "0")
  pfUI:UpdateConfig("unitframes", "player",      "showPVP",          "0")
  pfUI:UpdateConfig("unitframes", "player",      "buffs",            "top")
  pfUI:UpdateConfig("unitframes", "player",      "energy",           "1")

  pfUI:UpdateConfig("unitframes", "target",      "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "target",      "animation",        "0")
  pfUI:UpdateConfig("unitframes", "target",      "width",            "200")
  pfUI:UpdateConfig("unitframes", "target",      "height",           "50")
  pfUI:UpdateConfig("unitframes", "target",      "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "target",      "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "target",      "buffs",            "top")

  pfUI:UpdateConfig("unitframes", "group",       "portrait",         "off")
  pfUI:UpdateConfig("unitframes", "group",       "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "group",       "hide_in_raid",     "0")
  pfUI:UpdateConfig("unitframes", "group",       "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "group",       "raid_buffs",       "0")
  pfUI:UpdateConfig("unitframes", "group",       "raid_debuffs",     "0")

  pfUI:UpdateConfig("unitframes", "raid",        "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "raid",        "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "raid",        "show_missing",     "0")
  pfUI:UpdateConfig("unitframes", "raid",        "clickcast",        "")
  pfUI:UpdateConfig("unitframes", "raid",        "clickcast_shift",  "")
  pfUI:UpdateConfig("unitframes", "raid",        "clickcast_alt",    "")
  pfUI:UpdateConfig("unitframes", "raid",        "clickcast_ctrl",   "")
  pfUI:UpdateConfig("unitframes", "raid",        "buffs_buffs",      "0")
  pfUI:UpdateConfig("unitframes", "raid",        "buffs_hots",       "0")
  pfUI:UpdateConfig("unitframes", "raid",        "buffs_procs",      "0")
  pfUI:UpdateConfig("unitframes", "raid",        "buffs_classonly",  "0")
  pfUI:UpdateConfig("unitframes", "raid",        "debuffs_enable",   "0")
  pfUI:UpdateConfig("unitframes", "raid",        "debuffs_class",    "0")

  pfUI:UpdateConfig("unitframes", "ttarget",     "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "ttarget",     "pspace",           "-3")

  pfUI:UpdateConfig("unitframes", "pet",         "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "pet",         "pspace",           "-3")

  pfUI:UpdateConfig("bars",       nil,           "icon_size",        "20")
  pfUI:UpdateConfig("bars",       nil,           "background",       "1")
  pfUI:UpdateConfig("bars",       nil,           "glowrange",        "1")
  pfUI:UpdateConfig("bars",       nil,           "rangecolor",       "1,0.1,0.1,1")
  pfUI:UpdateConfig("bars",       nil,           "hunterbar",        "1")
  pfUI:UpdateConfig("bars",       nil,           "hide_time",        "1")
  pfUI:UpdateConfig("bars",       nil,           "hide_actionmain",  "0")
  pfUI:UpdateConfig("bars",       nil,           "hide_bottomleft",  "0")
  pfUI:UpdateConfig("bars",       nil,           "hide_bottomright", "0")
  pfUI:UpdateConfig("bars",       nil,           "hide_right",       "0")
  pfUI:UpdateConfig("bars",       nil,           "hide_tworight",    "0")
  pfUI:UpdateConfig("bars",       nil,           "hide_shapeshift",  "0")
  pfUI:UpdateConfig("bars",       nil,           "hide_pet",         "0")
  pfUI:UpdateConfig("bars",       "actionmain",  "formfactor",       "12 x 1")
  pfUI:UpdateConfig("bars",       "bottomleft",  "formfactor",       "12 x 1")
  pfUI:UpdateConfig("bars",       "bottomright", "formfactor",       "6 x 2")
  pfUI:UpdateConfig("bars",       "right",       "formfactor",       "6 x 2")
  pfUI:UpdateConfig("bars",       "tworight",    "formfactor",       "1 x 12")
  pfUI:UpdateConfig("bars",       "shapeshift",  "formfactor",       "10 x 1")
  pfUI:UpdateConfig("bars",       "pet",         "formfactor",       "10 x 1")

  pfUI:UpdateConfig("panel",      "left",        "left",             "guild")
  pfUI:UpdateConfig("panel",      "left",        "center",           "durability")
  pfUI:UpdateConfig("panel",      "left",        "right",            "friends")
  pfUI:UpdateConfig("panel",      "right",       "left",             "fps")
  pfUI:UpdateConfig("panel",      "right",       "center",           "time")
  pfUI:UpdateConfig("panel",      "right",       "right",            "gold")
  pfUI:UpdateConfig("panel",      "other",       "minimap",          "zone")
  pfUI:UpdateConfig("panel",      "micro",       "enable",           "0")
  pfUI:UpdateConfig("panel",      "xp",          "showalways",       "0")
  pfUI:UpdateConfig("castbar",    "player",      "hide_blizz",       "1")
  pfUI:UpdateConfig("castbar",    "player",      "hide_pfui",        "0")
  pfUI:UpdateConfig("castbar",    "target",      "hide_pfui",        "0")
  pfUI:UpdateConfig("tooltip",    nil,           "position",         "bottom")
  pfUI:UpdateConfig("tooltip",    nil,           "extguild",         "1")
  pfUI:UpdateConfig("tooltip",    nil,           "alpha",            "0.8")
  pfUI:UpdateConfig("tooltip",    "compare",     "showalways",       "0")
  pfUI:UpdateConfig("tooltip",    "vendor",      "showalways",       "0")

  pfUI:UpdateConfig("chat",       "text",        "input_width",      "0")
  pfUI:UpdateConfig("chat",       "text",        "input_height",     "0")
  pfUI:UpdateConfig("chat",       "text",        "time",             "0")
  pfUI:UpdateConfig("chat",       "text",        "timeformat",       "%H:%M:%S")
  pfUI:UpdateConfig("chat",       "text",        "timebracket",      "[]")
  pfUI:UpdateConfig("chat",       "text",        "timecolor",        ".8,.8,.8,1")
  pfUI:UpdateConfig("chat",       "text",        "classcolor",       "1")
  pfUI:UpdateConfig("chat",       "left",        "width",            "380")
  pfUI:UpdateConfig("chat",       "left",        "height",           "180")
  pfUI:UpdateConfig("chat",       "right",       "enable",           "0")
  pfUI:UpdateConfig("chat",       "right",       "alwaysshow",       "0")
  pfUI:UpdateConfig("chat",       "right",       "width",            "380")
  pfUI:UpdateConfig("chat",       "right",       "height",           "180")
  pfUI:UpdateConfig("chat",       "global",       "tabdock",         "1")
  pfUI:UpdateConfig("chat",       "global",      "custombg",         "0")
  pfUI:UpdateConfig("chat",       "global",      "background",       ".2,.2,.2,.5")
  pfUI:UpdateConfig("chat",       "global",      "border",           ".4,.4,.4,.5")
  pfUI:UpdateConfig("chat",       "global",      "whispermod",       "1")
  pfUI:UpdateConfig("chat",       "global",      "whisper",          "1,.6,1,1")
  pfUI:UpdateConfig("chat",       "global",      "sticky",           "1")
  pfUI:UpdateConfig("chat",       "global",      "fadeout",          "0")
  pfUI:UpdateConfig("chat",       "global",      "fadetime",         "300")

  pfUI:UpdateConfig("nameplates", nil,           "showcastbar",      "1")
  pfUI:UpdateConfig("nameplates", nil,           "spellname",        "0")
  pfUI:UpdateConfig("nameplates", nil,           "showdebuffs",      "0")
  pfUI:UpdateConfig("nameplates", nil,           "clickthrough",     "0")
  pfUI:UpdateConfig("nameplates", nil,           "rightclick",       "1")
  pfUI:UpdateConfig("nameplates", nil,           "clickthreshold",   "0.5")
  pfUI:UpdateConfig("nameplates", nil,           "enemyclassc",      "1")
  pfUI:UpdateConfig("nameplates", nil,           "friendclassc",     "1")
  pfUI:UpdateConfig("nameplates", nil,           "raidiconsize",     "16")
  pfUI:UpdateConfig("nameplates", nil,           "players",          "0")
  pfUI:UpdateConfig("nameplates", nil,           "showhp",           "0")
  pfUI:UpdateConfig("nameplates", nil,           "vpos",            "-10")
  pfUI:UpdateConfig("thirdparty", "dpsmate",     "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "wim",         "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "healcomm",    "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "cleanup",     "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "ktm",         "enable",           "1")
  pfUI:UpdateConfig("position",   nil,           nil,                nil)
  pfUI:UpdateConfig("disabled",   nil,           nil,                nil)
end

function pfUI:MigrateConfig()
  -- config version
  local major, minor, fix = pfUI.api.strsplit(".", tostring(pfUI_config.version))
  local major = tonumber(major) or 0
  local minor = tonumber(minor) or 0
  local fix   = tonumber(fix)   or 0

  -- migrating to new fonts (1.5 -> 1.6)
  if major <= 1 and minor <= 5 then
    -- migrate font_default
    if pfUI_config.global.font_default == "arial" then
      pfUI_config.global.font_default = "Myriad-Pro"
    elseif pfUI_config.global.font_default == "homespun" then
      pfUI_config.global.font_default = "Homespun"
    elseif pfUI_config.global.font_default == "diediedie" then
      pfUI_config.global.font_default = "DieDieDie"
    end

    -- migrate font_square
    if pfUI_config.global.font_square == "arial" then
      pfUI_config.global.font_square = "Myriad-Pro"
    elseif pfUI_config.global.font_square == "homespun" then
      pfUI_config.global.font_square = "Homespun"
    elseif pfUI_config.global.font_square == "diediedie" then
      pfUI_config.global.font_square = "DieDieDie"
    end

    -- migrate font_combat
    if pfUI_config.global.font_combat == "arial" then
      pfUI_config.global.font_combat = "Myriad-Pro"
    elseif pfUI_config.global.font_combat == "homespun" then
      pfUI_config.global.font_combat = "Homespun"
    elseif pfUI_config.global.font_combat == "diediedie" then
      pfUI_config.global.font_combat = "DieDieDie"
    end
  end

  pfUI_config.version = pfUI.version.string
end
