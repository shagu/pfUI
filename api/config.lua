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

  pfUI:UpdateConfig("global",     nil,           "font_default",     "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf")
  pfUI:UpdateConfig("global",     nil,           "font_size",        "12")
  pfUI:UpdateConfig("global",     nil,           "font_unit",        "Interface\\AddOns\\pfUI\\fonts\\BigNoodleTitling.ttf")
  pfUI:UpdateConfig("global",     nil,           "font_unit_size",   "12")
  pfUI:UpdateConfig("global",     nil,           "font_combat",      "Interface\\AddOns\\pfUI\\fonts\\Continuum.ttf")

  pfUI:UpdateConfig("global",     nil,           "force_region",     "1")
  pfUI:UpdateConfig("global",     nil,           "errors_limit",     "1")
  pfUI:UpdateConfig("global",     nil,           "errors_hide",      "0")
  pfUI:UpdateConfig("global",     nil,           "hidebuff",         "0")
  pfUI:UpdateConfig("global",     nil,           "hidewbuff",        "0")
  pfUI:UpdateConfig("global",     nil,           "twentyfour",       "1")
  pfUI:UpdateConfig("global",     nil,           "autosell",         "0")
  pfUI:UpdateConfig("global",     nil,           "autorepair",       "0")

  pfUI:UpdateConfig("appearance", "border",      "background",       "0,0,0,1")
  pfUI:UpdateConfig("appearance", "border",      "color",            "0.3,0.3,0.3,1")
  pfUI:UpdateConfig("appearance", "border",      "default",          "3")
  pfUI:UpdateConfig("appearance", "border",      "actionbars",       "-1")
  pfUI:UpdateConfig("appearance", "border",      "unitframes",       "-1")
  pfUI:UpdateConfig("appearance", "border",      "panels",           "-1")
  pfUI:UpdateConfig("appearance", "border",      "chat",             "-1")
  pfUI:UpdateConfig("appearance", "border",      "bags",             "-1")
  pfUI:UpdateConfig("appearance", "cd",          "lowcolor",         "1,.2,.2,1")
  pfUI:UpdateConfig("appearance", "cd",          "normalcolor",      "1,1,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "minutecolor",      ".2,1,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "hourcolor",        ".2,.5,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "daycolor",         ".2,.2,1,1")
  pfUI:UpdateConfig("appearance", "cd",          "threshold",        "2")
  pfUI:UpdateConfig("appearance", "cd",          "font_size",        "12")
  pfUI:UpdateConfig("appearance", "castbar",     "castbarcolor",     ".7,.7,.9,.8")
  pfUI:UpdateConfig("appearance", "castbar",     "channelcolor",     ".9,.9,.7,.8")
  pfUI:UpdateConfig("appearance", "infight",     "screen",           "0")
  pfUI:UpdateConfig("appearance", "infight",     "common",           "1")
  pfUI:UpdateConfig("appearance", "infight",     "group",            "0")
  pfUI:UpdateConfig("appearance", "bags",        "borderlimit",      "1")
  pfUI:UpdateConfig("appearance", "bags",        "borderonlygear",   "0")
  pfUI:UpdateConfig("appearance", "minimap",     "mouseoverzone",    "0")

  pfUI:UpdateConfig("loot",       nil,           "autoresize",       "1")
  pfUI:UpdateConfig("loot",       nil,           "autopickup",       "1")
  pfUI:UpdateConfig("loot",       nil,           "mousecursor",      "1")

  pfUI:UpdateConfig("unitframes", nil,           "disable",          "0")
  pfUI:UpdateConfig("unitframes", nil,           "pastel",           "1")
  pfUI:UpdateConfig("unitframes", nil,           "custom",           "0")
  pfUI:UpdateConfig("unitframes", nil,           "customcolor",      ".2,.2,.2,1")
  pfUI:UpdateConfig("unitframes", nil,           "custombg",         "0")
  pfUI:UpdateConfig("unitframes", nil,           "custombgcolor",    ".5,.2,.2,1")
  pfUI:UpdateConfig("unitframes", nil,           "animation_speed",  "5")
  pfUI:UpdateConfig("unitframes", nil,           "portraitalpha",    "0.1")
  pfUI:UpdateConfig("unitframes", nil,           "always2dportrait", "0")
  pfUI:UpdateConfig("unitframes", nil,           "portraittexture",  "1")
  pfUI:UpdateConfig("unitframes", nil,           "layout",           "default")
  pfUI:UpdateConfig("unitframes", nil,           "rangecheck",       "0")
  pfUI:UpdateConfig("unitframes", nil,           "rangechecki",      ".5")
  pfUI:UpdateConfig("unitframes", nil,           "combosize",        "6")
  pfUI:UpdateConfig("unitframes", nil,           "abbrevnum",        "1")

  pfUI:UpdateConfig("unitframes", nil,           "show_hots",        "0")
  pfUI:UpdateConfig("unitframes", nil,           "all_hots",         "0")
  pfUI:UpdateConfig("unitframes", nil,           "show_procs",       "0")
  pfUI:UpdateConfig("unitframes", nil,           "all_procs",        "0")
  pfUI:UpdateConfig("unitframes", nil,           "debuffs_class",    "0")

  pfUI:UpdateConfig("unitframes", nil,           "clickcast",        "")
  pfUI:UpdateConfig("unitframes", nil,           "clickcast_shift",  "")
  pfUI:UpdateConfig("unitframes", nil,           "clickcast_alt",    "")
  pfUI:UpdateConfig("unitframes", nil,           "clickcast_ctrl",   "")

  pfUI:UpdateConfig("unitframes", "player",      "visible",           "1")
  pfUI:UpdateConfig("unitframes", "player",      "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "player",      "width",            "200")
  pfUI:UpdateConfig("unitframes", "player",      "height",           "50")
  pfUI:UpdateConfig("unitframes", "player",      "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "player",      "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "player",      "buffs",            "top")
  pfUI:UpdateConfig("unitframes", "player",      "buffsize",         "20")
  pfUI:UpdateConfig("unitframes", "player",      "bufflimit",        "32")
  pfUI:UpdateConfig("unitframes", "player",      "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "player",      "debuffs",          "top")
  pfUI:UpdateConfig("unitframes", "player",      "debuffsize",       "20")
  pfUI:UpdateConfig("unitframes", "player",      "debufflimit",      "32")
  pfUI:UpdateConfig("unitframes", "player",      "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "player",      "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "player",      "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "player",      "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "player",      "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "player",      "faderange",        "0")
  pfUI:UpdateConfig("unitframes", "player",      "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "player",      "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "player",      "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "player",      "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "player",      "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "player",      "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "player",      "txthpright",       "healthdyn")
  pfUI:UpdateConfig("unitframes", "player",      "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "player",      "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "player",      "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "player",      "showPVPMinimap",   "0")
  pfUI:UpdateConfig("unitframes", "player",      "showPVP",          "0")
  pfUI:UpdateConfig("unitframes", "player",      "energy",           "1")

  pfUI:UpdateConfig("unitframes", "target",      "visible",           "1")
  pfUI:UpdateConfig("unitframes", "target",      "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "target",      "width",            "200")
  pfUI:UpdateConfig("unitframes", "target",      "height",           "50")
  pfUI:UpdateConfig("unitframes", "target",      "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "target",      "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "target",      "buffs",            "top")
  pfUI:UpdateConfig("unitframes", "target",      "buffsize",         "20")
  pfUI:UpdateConfig("unitframes", "target",      "bufflimit",        "32")
  pfUI:UpdateConfig("unitframes", "target",      "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "target",      "debuffs",          "top")
  pfUI:UpdateConfig("unitframes", "target",      "debuffsize",       "20")
  pfUI:UpdateConfig("unitframes", "target",      "debufflimit",      "32")
  pfUI:UpdateConfig("unitframes", "target",      "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "target",      "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "target",      "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "target",      "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "target",      "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "target",      "faderange",        "0")
  pfUI:UpdateConfig("unitframes", "target",      "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "target",      "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "target",      "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "target",      "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "target",      "animation",        "0")
  pfUI:UpdateConfig("unitframes", "target",      "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "target",      "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "target",      "txthpright",       "healthdyn")
  pfUI:UpdateConfig("unitframes", "target",      "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "target",      "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "target",      "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "focus",       "visible",           "1")
  pfUI:UpdateConfig("unitframes", "focus",       "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "focus",       "width",            "120")
  pfUI:UpdateConfig("unitframes", "focus",       "height",           "34")
  pfUI:UpdateConfig("unitframes", "focus",       "pheight",          "4")
  pfUI:UpdateConfig("unitframes", "focus",       "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "focus",       "buffs",            "top")
  pfUI:UpdateConfig("unitframes", "focus",       "buffsize",         "12")
  pfUI:UpdateConfig("unitframes", "focus",       "bufflimit",        "32")
  pfUI:UpdateConfig("unitframes", "focus",       "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "focus",       "debuffs",          "top")
  pfUI:UpdateConfig("unitframes", "focus",       "debuffsize",       "12")
  pfUI:UpdateConfig("unitframes", "focus",       "debufflimit",      "32")
  pfUI:UpdateConfig("unitframes", "focus",       "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "focus",       "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "focus",       "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "focus",       "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "focus",       "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "focus",       "faderange",        "0")
  pfUI:UpdateConfig("unitframes", "focus",       "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "focus",       "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "focus",       "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "focus",       "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "focus",       "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "focus",       "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "focus",       "txthpright",       "healthdyn")
  pfUI:UpdateConfig("unitframes", "focus",       "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "focus",       "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "focus",       "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "group",       "visible",           "1")
  pfUI:UpdateConfig("unitframes", "group",       "portrait",         "off")
  pfUI:UpdateConfig("unitframes", "group",       "width",            "164")
  pfUI:UpdateConfig("unitframes", "group",       "height",           "32")
  pfUI:UpdateConfig("unitframes", "group",       "pheight",          "4")
  pfUI:UpdateConfig("unitframes", "group",       "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "group",       "buffs",            "bottom")
  pfUI:UpdateConfig("unitframes", "group",       "buffsize",         "8")
  pfUI:UpdateConfig("unitframes", "group",       "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "group",       "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "group",       "debuffs",          "bottom")
  pfUI:UpdateConfig("unitframes", "group",       "debuffsize",       "8")
  pfUI:UpdateConfig("unitframes", "group",       "debufflimit",      "8")
  pfUI:UpdateConfig("unitframes", "group",       "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "group",       "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "group",       "buff_indicator",   "1")
  pfUI:UpdateConfig("unitframes", "group",       "debuff_indicator", "1")
  pfUI:UpdateConfig("unitframes", "group",       "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "group",       "faderange",        "1")
  pfUI:UpdateConfig("unitframes", "group",       "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "group",       "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "group",       "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "group",       "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "group",       "hide_in_raid",     "0")
  pfUI:UpdateConfig("unitframes", "group",       "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "group",       "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "group",       "txthpright",       "healthmiss")
  pfUI:UpdateConfig("unitframes", "group",       "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "group",       "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "group",       "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "grouptarget", "visible",           "1")
  pfUI:UpdateConfig("unitframes", "grouptarget", "portrait",         "off")
  pfUI:UpdateConfig("unitframes", "grouptarget", "width",            "120")
  pfUI:UpdateConfig("unitframes", "grouptarget", "height",           "16")
  pfUI:UpdateConfig("unitframes", "grouptarget", "pheight",          "0")
  pfUI:UpdateConfig("unitframes", "grouptarget", "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "grouptarget", "buffs",            "off")
  pfUI:UpdateConfig("unitframes", "grouptarget", "buffsize",         "16")
  pfUI:UpdateConfig("unitframes", "grouptarget", "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "grouptarget", "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "grouptarget", "debuffs",          "off")
  pfUI:UpdateConfig("unitframes", "grouptarget", "debuffsize",       "16")
  pfUI:UpdateConfig("unitframes", "grouptarget", "debufflimit",      "16")
  pfUI:UpdateConfig("unitframes", "grouptarget", "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "grouptarget", "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "grouptarget", "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "grouptarget", "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "grouptarget", "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "grouptarget", "faderange",        "1")
  pfUI:UpdateConfig("unitframes", "grouptarget", "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "grouptarget", "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "grouptarget", "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "grouptarget", "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "grouptarget", "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "grouptarget", "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "grouptarget", "txthpright",       "healthperc")
  pfUI:UpdateConfig("unitframes", "grouptarget", "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "grouptarget", "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "grouptarget", "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "grouppet",    "visible",           "1")
  pfUI:UpdateConfig("unitframes", "grouppet",    "portrait",         "off")
  pfUI:UpdateConfig("unitframes", "grouppet",    "width",            "100")
  pfUI:UpdateConfig("unitframes", "grouppet",    "height",           "14")
  pfUI:UpdateConfig("unitframes", "grouppet",    "pheight",          "0")
  pfUI:UpdateConfig("unitframes", "grouppet",    "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "grouppet",    "buffs",            "off")
  pfUI:UpdateConfig("unitframes", "grouppet",    "buffsize",         "16")
  pfUI:UpdateConfig("unitframes", "grouppet",    "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "grouppet",    "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "grouppet",    "debuffs",          "off")
  pfUI:UpdateConfig("unitframes", "grouppet",    "debuffsize",       "16")
  pfUI:UpdateConfig("unitframes", "grouppet",    "debufflimit",      "16")
  pfUI:UpdateConfig("unitframes", "grouppet",    "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "grouppet",    "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "grouppet",    "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "grouppet",    "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "grouppet",    "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "grouppet",    "faderange",        "1")
  pfUI:UpdateConfig("unitframes", "grouppet",    "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "grouppet",    "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "grouppet",    "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "grouppet",    "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "grouppet",    "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "grouppet",    "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "grouppet",    "txthpright",       "healthperc")
  pfUI:UpdateConfig("unitframes", "grouppet",    "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "grouppet",    "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "grouppet",    "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "raid",        "visible",           "1")
  pfUI:UpdateConfig("unitframes", "raid",        "portrait",         "off")
  pfUI:UpdateConfig("unitframes", "raid",        "width",            "50")
  pfUI:UpdateConfig("unitframes", "raid",        "height",           "26")
  pfUI:UpdateConfig("unitframes", "raid",        "pheight",          "4")
  pfUI:UpdateConfig("unitframes", "raid",        "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "raid",        "buffs",            "off")
  pfUI:UpdateConfig("unitframes", "raid",        "buffsize",         "16")
  pfUI:UpdateConfig("unitframes", "raid",        "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "raid",        "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "raid",        "debuffs",          "off")
  pfUI:UpdateConfig("unitframes", "raid",        "debuffsize",       "16")
  pfUI:UpdateConfig("unitframes", "raid",        "debufflimit",      "16")
  pfUI:UpdateConfig("unitframes", "raid",        "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "raid",        "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "raid",        "buff_indicator",   "1")
  pfUI:UpdateConfig("unitframes", "raid",        "debuff_indicator", "1")
  pfUI:UpdateConfig("unitframes", "raid",        "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "raid",        "faderange",        "1")
  pfUI:UpdateConfig("unitframes", "raid",        "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "raid",        "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "raid",        "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "raid",        "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "raid",        "txthpleft",        "name")
  pfUI:UpdateConfig("unitframes", "raid",        "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "raid",        "txthpright",       "healthmiss")
  pfUI:UpdateConfig("unitframes", "raid",        "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "raid",        "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "raid",        "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "ttarget",     "visible",           "1")
  pfUI:UpdateConfig("unitframes", "ttarget",     "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "ttarget",     "width",            "100")
  pfUI:UpdateConfig("unitframes", "ttarget",     "height",           "20")
  pfUI:UpdateConfig("unitframes", "ttarget",     "pheight",          "3")
  pfUI:UpdateConfig("unitframes", "ttarget",     "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "ttarget",     "buffs",            "off")
  pfUI:UpdateConfig("unitframes", "ttarget",     "buffsize",         "16")
  pfUI:UpdateConfig("unitframes", "ttarget",     "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "ttarget",     "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "ttarget",     "debuffs",          "off")
  pfUI:UpdateConfig("unitframes", "ttarget",     "debuffsize",       "16")
  pfUI:UpdateConfig("unitframes", "ttarget",     "debufflimit",      "16")
  pfUI:UpdateConfig("unitframes", "ttarget",     "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "ttarget",     "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "ttarget",     "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "ttarget",     "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "ttarget",     "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "ttarget",     "faderange",        "0")
  pfUI:UpdateConfig("unitframes", "ttarget",     "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "ttarget",     "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "ttarget",     "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "ttarget",     "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "ttarget",     "txthpleft",        "none")
  pfUI:UpdateConfig("unitframes", "ttarget",     "txthpcenter",      "name")
  pfUI:UpdateConfig("unitframes", "ttarget",     "txthpright",       "none")
  pfUI:UpdateConfig("unitframes", "ttarget",     "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "ttarget",     "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "ttarget",     "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "pet",         "visible",           "1")
  pfUI:UpdateConfig("unitframes", "pet",         "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "pet",         "width",            "100")
  pfUI:UpdateConfig("unitframes", "pet",         "height",           "16")
  pfUI:UpdateConfig("unitframes", "pet",         "pheight",          "4")
  pfUI:UpdateConfig("unitframes", "pet",         "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "pet",         "buffs",            "off")
  pfUI:UpdateConfig("unitframes", "pet",         "buffsize",         "12")
  pfUI:UpdateConfig("unitframes", "pet",         "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "pet",         "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "pet",         "debuffs",          "off")
  pfUI:UpdateConfig("unitframes", "pet",         "debuffsize",       "12")
  pfUI:UpdateConfig("unitframes", "pet",         "debufflimit",      "16")
  pfUI:UpdateConfig("unitframes", "pet",         "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "pet",         "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "pet",         "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "pet",         "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "pet",         "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "pet",         "faderange",        "0")
  pfUI:UpdateConfig("unitframes", "pet",         "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "pet",         "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "pet",         "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "pet",         "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "pet",         "txthpleft",        "none")
  pfUI:UpdateConfig("unitframes", "pet",         "txthpcenter",      "name")
  pfUI:UpdateConfig("unitframes", "pet",         "txthpright",       "none")
  pfUI:UpdateConfig("unitframes", "pet",         "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "pet",         "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "pet",         "txtpowerright",    "none")

  pfUI:UpdateConfig("unitframes", "fallback",    "visible",           "1")
  pfUI:UpdateConfig("unitframes", "fallback",    "portrait",         "bar")
  pfUI:UpdateConfig("unitframes", "fallback",    "width",            "200")
  pfUI:UpdateConfig("unitframes", "fallback",    "height",           "50")
  pfUI:UpdateConfig("unitframes", "fallback",    "pheight",          "10")
  pfUI:UpdateConfig("unitframes", "fallback",    "pspace",           "-3")
  pfUI:UpdateConfig("unitframes", "fallback",    "buffs",            "top")
  pfUI:UpdateConfig("unitframes", "fallback",    "buffsize",         "20")
  pfUI:UpdateConfig("unitframes", "fallback",    "bufflimit",        "16")
  pfUI:UpdateConfig("unitframes", "fallback",    "buffperrow",       "8")
  pfUI:UpdateConfig("unitframes", "fallback",    "debuffs",          "top")
  pfUI:UpdateConfig("unitframes", "fallback",    "debuffsize",       "20")
  pfUI:UpdateConfig("unitframes", "fallback",    "debufflimit",      "16")
  pfUI:UpdateConfig("unitframes", "fallback",    "debuffperrow",     "8")
  pfUI:UpdateConfig("unitframes", "fallback",    "invert_healthbar", "0")
  pfUI:UpdateConfig("unitframes", "fallback",    "buff_indicator",   "0")
  pfUI:UpdateConfig("unitframes", "fallback",    "debuff_indicator", "0")
  pfUI:UpdateConfig("unitframes", "fallback",    "clickcast",        "0")
  pfUI:UpdateConfig("unitframes", "fallback",    "faderange",        "0")
  pfUI:UpdateConfig("unitframes", "fallback",    "healthcolor",      "1")
  pfUI:UpdateConfig("unitframes", "fallback",    "powercolor",       "1")
  pfUI:UpdateConfig("unitframes", "fallback",    "levelcolor",       "1")
  pfUI:UpdateConfig("unitframes", "fallback",    "classcolor",       "1")
  pfUI:UpdateConfig("unitframes", "fallback",    "txthpleft",        "unit")
  pfUI:UpdateConfig("unitframes", "fallback",    "txthpcenter",      "none")
  pfUI:UpdateConfig("unitframes", "fallback",    "txthpright",       "healthdyn")
  pfUI:UpdateConfig("unitframes", "fallback",    "txtpowerleft",     "none")
  pfUI:UpdateConfig("unitframes", "fallback",    "txtpowercenter",   "none")
  pfUI:UpdateConfig("unitframes", "fallback",    "txtpowerright",    "none")

  pfUI:UpdateConfig("bars",       nil,           "icon_size",        "20")
  pfUI:UpdateConfig("bars",       nil,           "background",       "1")
  pfUI:UpdateConfig("bars",       nil,           "glowrange",        "1")
  pfUI:UpdateConfig("bars",       nil,           "rangecolor",       "1,0.1,0.1,1")
  pfUI:UpdateConfig("bars",       nil,           "showmacro",        "1")
  pfUI:UpdateConfig("bars",       nil,           "showkeybind",      "1")
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

  pfUI:UpdateConfig("panel",      nil,           "use_unitfonts",    "0")
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
  pfUI:UpdateConfig("castbar",    nil,           "use_unitfonts",    "0")

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
  pfUI:UpdateConfig("chat",       "text",        "channelnumonly",   "1")
  pfUI:UpdateConfig("chat",       "text",        "detecturl",        "1")
  pfUI:UpdateConfig("chat",       "text",        "classcolor",       "1")
  pfUI:UpdateConfig("chat",       "left",        "width",            "380")
  pfUI:UpdateConfig("chat",       "left",        "height",           "180")
  pfUI:UpdateConfig("chat",       "right",       "enable",           "0")
  pfUI:UpdateConfig("chat",       "right",       "alwaysshow",       "0")
  pfUI:UpdateConfig("chat",       "right",       "width",            "380")
  pfUI:UpdateConfig("chat",       "right",       "height",           "180")
  pfUI:UpdateConfig("chat",       "global",      "tabdock",          "1")
  pfUI:UpdateConfig("chat",       "global",      "tabmouse",         "0")
  pfUI:UpdateConfig("chat",       "global",      "custombg",         "0")
  pfUI:UpdateConfig("chat",       "global",      "background",       ".2,.2,.2,.5")
  pfUI:UpdateConfig("chat",       "global",      "border",           ".4,.4,.4,.5")
  pfUI:UpdateConfig("chat",       "global",      "whispermod",       "1")
  pfUI:UpdateConfig("chat",       "global",      "whisper",          "1,.7,1,1")
  pfUI:UpdateConfig("chat",       "global",      "sticky",           "1")
  pfUI:UpdateConfig("chat",       "global",      "fadeout",          "0")
  pfUI:UpdateConfig("chat",       "global",      "fadetime",         "300")

  pfUI:UpdateConfig("nameplates", nil,           "use_unitfonts",    "0")
  pfUI:UpdateConfig("nameplates", nil,           "overlap",          "0")
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
  pfUI:UpdateConfig("nameplates", nil,           "critters",         "0")
  pfUI:UpdateConfig("nameplates", nil,           "showhp",           "0")
  pfUI:UpdateConfig("nameplates", nil,           "vpos",             "-10")
  pfUI:UpdateConfig("nameplates", nil,           "width",            "120")
  pfUI:UpdateConfig("nameplates", nil,           "heighthealth",     "8")
  pfUI:UpdateConfig("nameplates", nil,           "heightcast",       "8")
  pfUI:UpdateConfig("thirdparty", "dpsmate",     "skin",             "0")
  pfUI:UpdateConfig("thirdparty", "dpsmate",     "dock",             "0")
  pfUI:UpdateConfig("thirdparty", "swstats",     "skin",             "0")
  pfUI:UpdateConfig("thirdparty", "swstats",     "dock",             "0")
  pfUI:UpdateConfig("thirdparty", "ktm",         "skin",             "0")
  pfUI:UpdateConfig("thirdparty", "ktm",         "dock",             "0")
  pfUI:UpdateConfig("thirdparty", "wim",         "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "healcomm",    "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "cleanup",     "enable",           "1")
  pfUI:UpdateConfig("position",   nil,           nil,                nil)
  pfUI:UpdateConfig("disabled",   nil,           nil,                nil)
end

function pfUI:MigrateConfig()
  -- config version
  local major, minor, fix = pfUI.api.strsplit(".", tostring(pfUI_config.version))
  local major = tonumber(major) or 0
  local minor = tonumber(minor) or 0
  local fix   = tonumber(fix)   or 0

  local function checkversion(chkmajor, chkminor, chkfix)
    local chkversion = chkmajor + chkminor/100 + chkfix/10000
    local curversion = major + minor/100 + fix/10000
    return curversion <= chkversion and true or nil
  end

  -- migrating to new fonts (1.5 -> 1.6)
  if checkversion(1, 6, 0) then
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

  -- migrating to new loot config section (> 2.0.5)
  if checkversion(2, 0, 5) then
    if pfUI_config.appearance.loot and pfUI_config.appearance.loot.autoresize then
      pfUI_config.loot.autoresize = pfUI_config.appearance.loot.autoresize
      pfUI_config.appearance.loot.autoresize = nil
      pfUI_config.appearance.loot = nil
    end
  end

  -- migrating to new unitframes (> 2.5)
  if checkversion(2, 5, 0) then
    -- migrate clickcast settings
    if pfUI_config.unitframes.raid.clickcast_ctrl then
      pfUI_config.unitframes.clickcast = pfUI_config.unitframes.raid.clickcast
      pfUI_config.unitframes.clickcast_shift = pfUI_config.unitframes.raid.clickcast_shift
      pfUI_config.unitframes.clickcast_alt = pfUI_config.unitframes.raid.clickcast_alt
      pfUI_config.unitframes.clickcast_ctrl = pfUI_config.unitframes.raid.clickcast_ctrl

      pfUI_config.unitframes.raid.clickcast = "0"
      pfUI_config.unitframes.raid.clickcast_shift = nil
      pfUI_config.unitframes.raid.clickcast_alt = nil
      pfUI_config.unitframes.raid.clickcast_ctrl = nil
    end

    -- migrate buffsizes
    if pfUI_config.unitframes.buff_size then
      pfUI_config.unitframes.player.buffsize = pfUI_config.unitframes.buff_size
      pfUI_config.unitframes.target.buffsize = pfUI_config.unitframes.buff_size
      pfUI_config.unitframes.buff_size = nil
    end

    -- migrate debuffsizes
    if pfUI_config.unitframes.debuff_size then
      pfUI_config.unitframes.player.debuffsize = pfUI_config.unitframes.debuff_size
      pfUI_config.unitframes.target.debuffsize = pfUI_config.unitframes.debuff_size
      pfUI_config.unitframes.debuff_size = nil
    end
  end

  -- migrating to new fontnames (> 2.6)
  if checkversion(2, 6, 0) then
    -- migrate font_combat
    if pfUI_config.global.font_square then
      pfUI_config.global.font_unit = pfUI_config.global.font_square
      pfUI_config.global.font_square = nil
    end
  end


  -- migrating old to new font layout (> 3.0.0)
  if checkversion(3, 0, 0) then
    -- migrate font_default
    if not strfind(pfUI_config.global.font_default, "\\") then
      pfUI_config.global.font_default = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_default .. ".ttf"
    end

    -- migrate font_unit
    if not strfind(pfUI_config.global.font_unit, "\\") then
      pfUI_config.global.font_unit = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_unit .. ".ttf"
    end

    -- migrate font_combat
    if not strfind(pfUI_config.global.font_combat, "\\") then
      pfUI_config.global.font_combat = "Interface\\AddOns\\pfUI\\fonts\\" .. pfUI_config.global.font_combat .. ".ttf"
    end
  end

  -- migrating old to new unitframe texts (> 3.0.0)
  if checkversion(3, 0, 0) then
    local unitframes = { "player", "target", "focus", "group", "grouptarget", "grouppet", "raid", "ttarget", "pet", "fallback" }

    for _, unitframe in pairs(unitframes) do
      if pfUI_config.unitframes[unitframe].txtleft then
        pfUI_config.unitframes[unitframe].txthpleft = pfUI_config.unitframes[unitframe].txtleft
        pfUI_config.unitframes[unitframe].txtleft = nil
      end
      if pfUI_config.unitframes[unitframe].txtcenter then
        pfUI_config.unitframes[unitframe].txthpcenter = pfUI_config.unitframes[unitframe].txtcenter
        pfUI_config.unitframes[unitframe].txtcenter = nil
      end
      if pfUI_config.unitframes[unitframe].txtright then
        pfUI_config.unitframes[unitframe].txthpright = pfUI_config.unitframes[unitframe].txtright
        pfUI_config.unitframes[unitframe].txtright = nil
      end
    end
  end

  pfUI_config.version = pfUI.version.string
end
