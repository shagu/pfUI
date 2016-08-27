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
  pfUI:UpdateConfig("bars",       nil,       "icon_size",        "22")
  pfUI:UpdateConfig("bars",       nil,       "border",           "2")
  pfUI:UpdateConfig("panel",      "left",    "left",             "guild")
  pfUI:UpdateConfig("panel",      "left",    "center",           "durability")
  pfUI:UpdateConfig("panel",      "left",    "right",            "friends")
  pfUI:UpdateConfig("panel",      "right",   "left",             "fps")
  pfUI:UpdateConfig("panel",      "right",   "center",           "time")
  pfUI:UpdateConfig("panel",      "right",   "right",            "gold")
  pfUI:UpdateConfig("panel",      "other",   "minimap",          "zone")
  pfUI:UpdateConfig("castbar",    "player",  "hide_blizz",       "1")
  pfUI:UpdateConfig("tooltip",    nil,       "position",         "bottom")
  pfUI:UpdateConfig("thirdparty", "dpsmate", "enable",           "1")
  pfUI:UpdateConfig("thirdparty", "wim",     "enable",           "1")
  pfUI:UpdateConfig("position",   nil,       nil,                nil)
end

function pfUI:UpdateConfig(group, subgroup, entry, value)
  -- check for missing config groups
  if not pfUI_config[group] then
    pfUI_config[group] = {}
  end

  -- update config
  if not subgroup and entry and value and not pfUI_config[group][entry] then
    pfUI:Debug("Creating Config: " .. entry .. " with value " .. value)
    pfUI_config[group][entry] = value
  end

  -- check for missing config subgroups
  if subgroup and not pfUI_config[group][subgroup] then
    pfUI:Debug("Creating Subgroup: " .. subgroup)
    pfUI_config[group][subgroup] = {}
  end

  -- update config in subgroup
  if subgroup and entry and value and not pfUI_config[group][subgroup][entry] then
    pfUI:Debug("Creating Config in Subgroup (" .. subgroup .. "): " .. entry .. " with value " .. value)
    pfUI_config[group][subgroup][entry] = value
  end
end
