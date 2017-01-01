-- override and set some default colors
function pfUI.environment:UpdateColors()
  ManaBarColor = {}
  ManaBarColor[0] = { r = 0.00, g = 0.00, b = 1.00, prefix = TEXT(MANA) };
  ManaBarColor[1] = { r = 1.00, g = 0.00, b = 0.00, prefix = TEXT(RAGE_POINTS) };
  ManaBarColor[2] = { r = 1.00, g = 0.50, b = 0.25, prefix = TEXT(FOCUS_POINTS) };
  ManaBarColor[3] = { r = 1.00, g = 1.00, b = 0.00, prefix = TEXT(ENERGY_POINTS) };
  ManaBarColor[4] = { r = 0.00, g = 1.00, b = 1.00, prefix = TEXT(HAPPINESS_POINTS) };

  RAID_CLASS_COLORS = {
    ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, colorStr = "ffc79c6e" },
    ["MAGE"] = { r = 0.41, g = 0.8, b = 0.94, colorStr = "ff69ccf0" },
    ["ROGUE"] = { r = 1, g = 0.96, b = 0.41, colorStr = "fffff569" },
    ["DRUID"] = { r = 1, g = 0.49, b = 0.04, colorStr = "ffff7d0a" },
    ["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, colorStr = "ffabd473" },
    ["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.0, colorStr = "ff0070de" },
    ["PRIEST"] = { r = 1, g = 1, b = 1, colorStr = "ffffffff" },
    ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, colorStr = "ff9482c9" },
    ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, colorStr = "fff58cba" }
  }
end

-- run environment update
pfUI.environment:UpdateColors()
