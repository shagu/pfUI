-- Modern
local modern = {
  ["chat"] = {
    ["global"] = {
      ["custombg"] = "1",
      ["border"] = "0.1,0.1,0.1,0.5",
      ["background"] = "0.1,0.1,0.1,0.2",
    },
  },
  ["global"] = {
    ["font_unit"] = "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf",
    ["font_size"] = "11",
    ["font_unit_size"] = "11",
  },
  ["panel"] = {
    ["left"] = {
      ["left"] = "exp",
    },
    ["xp"] = {
      ["dont_overlap"] = "1",
      ["xp_always"] = "1",
      ["xp_mode"] = "HORIZONTAL",
      ["xp_position"] = "TOP",
      ["xp_anchor"] = "pfActionBarLeft",
      ["xp_color"] = "0.6,0.6,0.6,1",
      ["rest_color"] = "0.4,0.4,0.4,0.5",
      ["xp_height"] = "4",
      ["rep_always"] = "1",
      ["rep_mode"] = "HORIZONTAL",
      ["rep_position"] = "TOP",
      ["rep_anchor"] = "pfActionBarRight",
      ["rep_height"] = "4",
      ["rep_display"] = "FLEX",
    },
  },
  ["unitframes"] = {
    ["custom"] = "2",
    ["custompbgcolor"] = "0.3,0.1,0.1,1",
    ["custombgcolor"] = "0.3,0.1,0.1,1",
    ["ragecolor"] = "0.6,0.2,0.2,1",
    ["energycolor"] = "0.6,0.4,0.2,1",
    ["manacolor"] = "0.2,0.2,0.4,1",
    ["focuscolor"] = "0.6,0.4,0.2,1",
    ["customcolor"] = "0.1,0.1,0.1,1",

    ["grouptarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["ptarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["target"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["txthpleft"] = "healthdyn",
      ["pspace"] = "1",
      ["txtpowerleft"] = "powerdyn",
      ["height"] = "22",
      ["buffs"] = "TOPRIGHT",
      ["txthpright"] = "unitrev",
      ["buffsize"] = "16",
      ["portrait"] = "right",
      ["width"] = "160",
    },
    ["ttarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pspace"] = "1",
      ["height"] = "7",
      ["portrait"] = "off",
    },
    ["pet"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pspace"] = "1",
      ["pheight"] = "3",
      ["txtpowercenter"] = "healthdyn",
      ["height"] = "7",
      ["buffs"] = "BOTTOMLEFT",
      ["portrait"] = "off",
      ["debuffs"] = "BOTTOMRIGHT",
    },
    ["player"] = {
      ["txtpowerright"] = "powerdyn",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pspace"] = "1",
      ["debuffs"] = "TOPRIGHT",
      ["portrait"] = "left",
      ["buffsize"] = "16",
      ["width"] = "160",
      ["height"] = "22",
      ["showPVP"] = "1",
    },
    ["customfullhp"] = "1",
    ["focustarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["customfade"] = "1",
    ["group"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["raid"] = {
      ["indicator_pos"] = "TOPRIGHT",
      ["verticalbar"] = "1",
      ["txthpleft"] = "none",
      ["defcolor"] = "0",
      ["customfade"] = "1",
      ["focuscolor"] = "0.6,0.4,0.2,1",
      ["raidpadding"] = "5",
      ["txthpcenter"] = "namehealthbreak",
      ["ragecolor"] = "0.6,0.2,0.2,1",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["glowaggro"] = "0",
      ["height"] = "35",
      ["txthpright"] = "none",
      ["customcolor"] = "0.1,0.1,0.1,1",
      ["width"] = "40.7",
      ["manacolor"] = "0.2,0.2,0.4,1",
      ["energycolor"] = "0.6,0.4,0.2,1",
      ["customfullhp"] = "1",
      ["custom"] = "2",
    },
    ["focus"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["tttarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["grouppet"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
  },
  ["appearance"] = {
    ["castbar"] = {
      ["texture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["minimap"] = {
      ["coordsloc"] = "bottomleft",
    },
    ["border"] = {
      ["color"] = "0.1,0.1,0.1,1",
      ["bags"] = "3",
      ["chat"] = "3",
      ["default"] = "2",
    },
  },
  ["tooltip"] = {
    ["statusbar"] = {
      ["texture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
  },
  ["castbar"] = {
    ["player"] = {
      ["showrank"] = "1",
      ["height"] = "12",
      ["showlag"] = "1",
      ["showicon"] = "1",
    },
    ["target"] = {
      ["height"] = "12",
      ["showicon"] = "1",
    },
  },
  ["abuttons"] = {
    ["enable"] = "1",
    ["hideincombat"] = "0",
  },
  ["nameplates"] = {
    ["heighthealth"] = "10",
    ["healthtexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    ["health"] = {
      ["offset"] = "10",
    },
  },
  ["bars"] = {
    ["bar4"] = {
      ["enable"] = "0",
    },
    ["bar11"] = {
      ["background"] = "0",
      ["spacing"] = "3",
    },
    ["bar5"] = {
      ["formfactor"] = "12 x 1",
      ["buttons"] = "6",
    },
    ["bar3"] = {
      ["formfactor"] = "12 x 1",
      ["buttons"] = "6",
    },
  }
}

-- Nostalgia
local nostalgia = {
  ["chat"] = {
    ["global"] = {
      ["custombg"] = "1",
      ["tabmouse"] = "1",
      ["border"] = "0,0,0,0",
      ["frameshadow"] = "0",
      ["background"] = "0,0,0,0",
    },
    ["right"] = {
      ["width"] = "330",
    },
    ["left"] = {
      ["width"] = "330",
    },
  },
  ["bars"] = {
    ["bar3"] = {
      ["enable"] = "0",
    },
    ["gryphons"] = {
      ["anchor_right"] = "pfActionBarMain",
      ["anchor_left"] = "pfActionBarMain",
      ["offset_h"] = "-60",
      ["size"] = "80",
      ["texture"] = "Gryphon",
    },
    ["bar11"] = {
      ["icon_size"] = "20",
      ["background"] = "0",
    },
    ["font"] = "Fonts\\ARIALN.TTF",
    ["bar6"] = {
      ["icon_size"] = "26",
      ["background"] = "0",
    },
    ["bar4"] = {
      ["formfactor"] = "2 x 6",
      ["autohide"] = "1",
    },
    ["bar1"] = {
      ["icon_size"] = "26",
      ["background"] = "0",
    },
    ["macro_size"] = "8",
    ["bar5"] = {
      ["enable"] = "0",
    },
    ["bar12"] = {
      ["icon_size"] = "20",
      ["background"] = "0",
    },
    ["count_size"] = "8",
  },
  ["panel"] = {
    ["xp"] = {
      ["xp_always"] = "1",
      ["rep_position"] = "BOTTOM",
      ["rep_display"] = "FLEX",
      ["xp_anchor"] = "pfActionBarMain",
      ["texture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["rep_anchor"] = "pfActionBarMain",
      ["xp_mode"] = "HORIZONTAL",
      ["xp_position"] = "BOTTOM",
      ["rep_mode"] = "HORIZONTAL",
    },
  },
  ["appearance"] = {
    ["castbar"] = {
      ["texture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["border"] = {
      ["force_blizz"] = "1",
      ["color"] = "0.7,0.7,0.7,1",
      ["background"] = "0.1,0.1,0.1,0.7",
    },
  },
  ["nameplates"] = {
    ["healthtexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
  },
  ["global"] = {
    ["font_blizzard"] = "1",
    ["font_unit"] = "Fonts\\ARIALN.TTF",
    ["font_combat"] = "Fonts\\FRIZQT__.TTF",
    ["font_unit_name"] = "Fonts\\FRIZQT__.TTF",
    ["font_unit_size"] = "10",
    ["font_default"] = "Fonts\\ARIALN.TTF",
  },
  ["unitframes"] = {
    ["grouptarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["width"] = "100",
    },
    ["ptarget"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portrait"] = "off",
    },
    ["target"] = {
      ["buffs"] = "TOPRIGHT",
      ["buffsize"] = "18",
      ["buffperrow"] = "6",
      ["debuffs"] = "TOPRIGHT",
      ["debuffsize"] = "18",
      ["debuffperrow"] = "6",
      ["portraitwidth"] = "42",
      ["portraitheight"] = "42",
      ["txtpowerright"] = "powerdyn",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["width"] = "130",
      ["portrait"] = "right",
      ["pheight"] = "8",
      ["height"] = "24",
    },
    ["player"] = {
      ["buffsize"] = "18",
      ["buffperrow"] = "6",
      ["debuffsize"] = "18",
      ["debuffperrow"] = "6",
      ["width"] = "130",
      ["txtpowerright"] = "powerdyn",
      ["portraitheight"] = "42",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portraitwidth"] = "42",
      ["portrait"] = "left",
      ["pheight"] = "8",
      ["height"] = "24",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["focus"] = {
      ["portraitwidth"] = "42",
      ["portraitheight"] = "42",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pheight"] = "8",
      ["portrait"] = "left",
      ["height"] = "24",
    },
    ["raid"] = {
      ["verticalbar"] = "1",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["width"] = "40",
    },
    ["pet"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portrait"] = "off",
    },
    ["group"] = {
      ["portraitheight"] = "42",
      ["portraitwidth"] = "42",
      ["pheight"] = "8",
      ["width"] = "130",
      ["height"] = "24",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portrait"] = "left",
    },
    ["tttarget"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portrait"] = "off",
      ["pheight"] = "4",
      ["height"] = "15",
    },
    ["grouppet"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["width"] = "80",
    },
    ["focustarget"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portrait"] = "off",
    },
    ["ttarget"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
      ["portrait"] = "off",
      ["pheight"] = "6",
    },
  },
}

-- Legacy
local legacy = {
}

-- Slim
local slim = {
  ["panel"] = {
    ["use_unitfonts"] = "1",
  },
  ["tooltip"] = {
    ["position"] = "bottom",
  },
  ["appearance"] = {
    ["infight"] = {
      ["screen"] = "0",
      ["common"] = "1",
    },
    ["border"] = {
      ["color"] = "0,0,0,1",
      ["bags"] = "3",
      ["panels"] = "1",
      ["unitframes"] = "1",
      ["default"] = "1",
      ["background"] = "0.1,0.1,0.1,0.8",
      ["chat"] = "2",
      ["actionbars"] = "1",
    },
  },
  ["buffbar"] = {
    ["pdebuff"] = {
      ["enable"] = "1",
      ["height"] = "14",
    },
    ["pbuff"] = {
      ["enable"] = "1",
      ["height"] = "14",
    },
    ["tdebuff"] = {
      ["enable"] = "1",
      ["height"] = "14",
      ["selfdebuff"] = "1",
    },
  },
  ["chat"] = {
    ["global"] = {
      ["tabmouse"] = "1",
      ["tabdock"] = "0",
      ["border"] = "0,0,0,0",
      ["background"] = "0,0,0,0.3",
      ["custombg"] = "1",
    },
    ["text"] = {
      ["outline"] = "0",
    },
    ["left"] = {
      ["height"] = "160",
      ["width"] = "405",
    },
    ["right"] = {
      ["height"] = "160",
      ["width"] = "405",
    },
  },
  ["bars"] = {
    ["background"] = "0",
    ["icon_size"] = "22",
  },
  ["version"] = "3.3.0",
  ["nameplates"] = {
    ["use_unitfonts"] = "1",
  },
  ["unitframes"] = {
    ["target"] = {
      ["buffsize"] = "14",
      ["pheight"] = "6",
      ["height"] = "35",
      ["panchor"] = "TOPLEFT",
      ["pspace"] = "-1",
      ["width"] = "225",
    },
    ["pet"] = {
      ["debuffs"] = "top",
      ["pheight"] = "6",
      ["pspace"] = "-1",
      ["width"] = "125",
    },
    ["player"] = {
      ["buffsize"] = "14",
      ["txthpleft"] = "powerdyn",
      ["height"] = "35",
      ["showPVP"] = "1",
      ["panchor"] = "TOPRIGHT",
      ["pspace"] = "-1",
      ["width"] = "225",
      ["pheight"] = "6",
    },
    ["custombgcolor"] = "0.5,0.2,0.2,1",
    ["focus"] = {
      ["pheight"] = "6",
    },
    ["raid"] = {
      ["height"] = "24",
      ["width"] = "48",
    },
    ["custombg"] = "1",
    ["customcolor"] = "0.15,0.15,0.15,1",
    ["custom"] = "1",
    ["ttarget"] = {
      ["portrait"] = "off",
      ["pheight"] = "6",
      ["height"] = "16",
      ["pspace"] = "-1",
      ["width"] = "125",
    },
    ["tttarget"] = {
      ["portrait"] = "off",
      ["pheight"] = "6",
      ["height"] = "16",
      ["pspace"] = "-1",
      ["width"] = "125",
    },
    ["ptarget"] = {
      ["portrait"] = "off",
      ["pheight"] = "-1",
      ["height"] = "8",
      ["pspace"] = "-1",
      ["width"] = "125",
    },
  },
}

-- Light
local light = {
  ["unitframes"] = {
    ["grouptarget"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["pheight"] = "2",
      ["raidiconalign"] = "TOP",
      ["height"] = "12",
      ["raidiconoffy"] = "6",
      ["width"] = "100",
    },
    ["ptarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["raidiconalign"] = "TOP",
      ["raidiconoffy"] = "6",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["target"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["buffperrow"] = "9",
      ["txthpcenter"] = "powerdyn",
      ["raidiconalign"] = "TOP",
      ["height"] = "16",
      ["buffs"] = "TOPRIGHT",
      ["raidiconoffy"] = "6",
      ["selfdebuff"] = "1",
      ["portrait"] = "right",
      ["width"] = "160",
      ["buffsize"] = "13.55",
      ["pheight"] = "6",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["ttarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["raidiconalign"] = "TOP",
      ["raidiconoffy"] = "6",
      ["height"] = "7",
      ["portrait"] = "off",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["layout"] = "tukui",
    ["player"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["custombg"] = "1",
      ["buffperrow"] = "11",
      ["portrait"] = "left",
      ["txthpcenter"] = "powerdyn",
      ["pheight"] = "6",
      ["buffsize"] = "13.55",
      ["custompbg"] = "1",
      ["height"] = "16",
      ["showPVP"] = "1",
      ["debuffs"] = "TOPRIGHT",
      ["width"] = "160",
    },
    ["focus"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["raidiconalign"] = "TOP",
      ["buffsize"] = "11.45",
      ["height"] = "24",
      ["raidiconoffy"] = "6",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["raid"] = {
      ["indicator_pos"] = "TOPRIGHT",
      ["txthpleft"] = "none",
      ["clickcast"] = "1",
      ["customfullhp"] = "1",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["debuff_indicator"] = "3",
      ["customfade"] = "1",
      ["width"] = "42",
      ["focuscolor"] = "0.6,0.4,0.2,1",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["manacolor"] = "0.2,0.2,0.4,1",
      ["ragecolor"] = "0.6,0.2,0.2,1",
      ["txthpcenter"] = "namehealthbreak",
      ["raidiconalign"] = "TOP",
      ["height"] = "24",
      ["raidiconoffy"] = "6",
      ["txthpright"] = "none",
      ["debuff_ind_pos"] = "BOTTOM",
      ["debuff_ind_size"] = ".50",
      ["customcolor"] = "0.1,0.1,0.1,1",
      ["custom"] = "2",
      ["glowaggro"] = "0",
      ["raidpadding"] = "5",
      ["energycolor"] = "0.6,0.4,0.2,1",
    },
    ["focuscolor"] = "0.7,0.6,0.4,1",
    ["combowidth"] = "12",
    ["ragecolor"] = "0.6,0.2,0.2,1",
    ["pet"] = {
      ["bufflimit"] = "16",
      ["pheight"] = "3",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["raidiconalign"] = "TOP",
      ["buffsize"] = "9",
      ["txtpowercenter"] = "healthdyn",
      ["height"] = "7",
      ["buffs"] = "BOTTOMLEFT",
      ["raidiconoffy"] = "6",
      ["debuffs"] = "BOTTOMRIGHT",
      ["portrait"] = "off",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["custompbgcolor"] = "0.3,0.1,0.1,1",
    ["comboheight"] = "5.10",
    ["group"] = {
      ["buffperrow"] = "14",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "1",
      ["raidiconalign"] = "TOP",
      ["height"] = "24",
      ["raidiconoffy"] = "6",
      ["width"] = "140",
    },
    ["custombgcolor"] = "0.3,0.1,0.1,1",
    ["tttarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["raidiconalign"] = "TOP",
      ["raidiconoffy"] = "6",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["grouppet"] = {
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["pspace"] = "-1",
      ["pheight"] = "-1",
      ["raidiconalign"] = "TOP",
      ["height"] = "8",
      ["raidiconoffy"] = "6",
      ["width"] = "80",
    },
    ["manacolor"] = "0.4,0.5,0.7,1",
    ["energycolor"] = "0.8,0.7,0.4,1",
    ["focustarget"] = {
      ["bartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
      ["raidiconalign"] = "TOP",
      ["raidiconoffy"] = "6",
      ["pbartexture"] = "Interface\\AddOns\\pfUI\\img\\bar_tukui",
    },
    ["customcolor"] = "0.1,0.1,0.1,1",
  },
  ["chat"] = {
    ["global"] = {
      ["custombg"] = "1",
      ["tabmouse"] = "1",
      ["border"] = "0.6,0.6,0.6,0",
      ["frameshadow"] = "0",
      ["background"] = "0.1,0.1,0.1,0",
    },
    ["text"] = {
      ["timecolor"] = "0.4,0.4,0.4,0.4",
      ["timebracket"] = "",
    },
  },
  ["panel"] = {
    ["left"] = {
      ["left"] = "exp",
    },
    ["xp"] = {
      ["xp_always"] = "1",
      ["rep_position"] = "TOP",
      ["rep_display"] = "FLEX",
      ["xp_anchor"] = "pfActionBarLeft",
      ["rep_always"] = "1",
      ["rep_mode"] = "HORIZONTAL",
      ["xp_color"] = "0.6,0.6,0.6,1",
      ["rep_anchor"] = "pfActionBarRight",
      ["xp_mode"] = "HORIZONTAL",
      ["xp_height"] = "4",
      ["xp_position"] = "TOP",
      ["rep_height"] = "4",
      ["dont_overlap"] = "1",
      ["rest_color"] = "0.4,0.4,0.4,0.5",
    },
  },
  ["global"] = {
    ["font_unit"] = "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf",
    ["font_size"] = "11",
    ["font_unit_size"] = "11",
  },
  ["castbar"] = {
    ["player"] = {
      ["showrank"] = "1",
      ["showicon"] = "1",
      ["height"] = "12",
      ["showlag"] = "1",
    },
    ["target"] = {
      ["height"] = "12",
      ["showicon"] = "1",
    },
  },
  ["appearance"] = {
    ["cd"] = {
      ["font"] = "Interface\\AddOns\\pfUI\\fonts\\Myriad-Pro.ttf",
    },
    ["castbar"] = {
      ["texture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
    ["bags"] = {
      ["borderlimit"] = "0",
    },
    ["border"] = {
      ["shadow"] = "1",
      ["color"] = "0.4,0.4,0.4,1",
      ["bags"] = "3",
      ["chat"] = "3",
      ["default"] = "2",
      ["background"] = "0.1,0.1,0.1,1",
    },
  },
  ["tooltip"] = {
    ["statusbar"] = {
      ["texture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    },
  },
  ["buffbar"] = {
    ["pdebuff"] = {
      ["height"] = "12",
    },
    ["pbuff"] = {
      ["height"] = "12",
      ["enable"] = "1",
    },
    ["tdebuff"] = {
      ["selfdebuff"] = "1",
      ["height"] = "12",
      ["enable"] = "1",
    },
  },
  ["thirdparty"] = {
    ["chatbg"] = "0",
    ["dpsmate"] = {
      ["skin"] = "1",
    },
    ["swstats"] = {
      ["skin"] = "1",
    },
    ["shagudps"] = {
      ["skin"] = "1",
    },
  },
  ["nameplates"] = {
    ["combatofftank"] = "0.5,0,0.7,1",
    ["selfdebuff"] = "1",
    ["healthtexture"] = "Interface\\AddOns\\pfUI\\img\\bar_gradient",
    ["heighthealth"] = "10",
    ["health"] = {
      ["offset"] = "10",
    },
  },
  ["bars"] = {
    ["bar3"] = {
      ["formfactor"] = "12 x 1",
      ["buttons"] = "6",
    },
    ["bar5"] = {
      ["formfactor"] = "12 x 1",
      ["buttons"] = "6",
    },
    ["bar11"] = {
      ["spacing"] = "3",
      ["background"] = "0",
    },
    ["bar4"] = {
      ["enable"] = "0",
    },
  },
}

-- Adapta
local adapta = {
  ["appearance"] = {
    ["infight"] = {
      ["screen"] = "1",
      ["common"] = "0",
    },
    ["border"] = {
      ["color"] = "0,0,0,1",
      ["unitframes"] = "1",
      ["background"] = "0.05,0.15,0.15,0.75",
      ["actionbars"] = "4",
    },
  },
  ["unitframes"] = {
    ["target"] = {
      ["portrait"] = "off",
      ["height"] = "35",
      ["panchor"] = "TOPLEFT",
      ["pspace"] = "-1",
      ["width"] = "225",
      ["pheight"] = "6",
    },
    ["pet"] = {
      ["debuffs"] = "top",
      ["portrait"] = "off",
      ["pspace"] = "-1",
      ["width"] = "125",
      ["pheight"] = "6",
    },
    ["player"] = {
      ["portrait"] = "off",
      ["txthpleft"] = "powerdyn",
      ["height"] = "35",
      ["showPVP"] = "1",
      ["panchor"] = "TOPRIGHT",
      ["pspace"] = "-1",
      ["width"] = "225",
      ["pheight"] = "6",
    },
    ["focus"] = {
      ["portrait"] = "off",
      ["pheight"] = "6",
    },
    ["ttarget"] = {
      ["portrait"] = "off",
      ["height"] = "16",
      ["pspace"] = "-1",
      ["width"] = "125",
      ["pheight"] = "6",
    },
    ["tttarget"] = {
      ["portrait"] = "off",
      ["height"] = "16",
      ["pspace"] = "-1",
      ["width"] = "125",
      ["pheight"] = "6",
    },
    ["ptarget"] = {
      ["portrait"] = "off",
      ["height"] = "8",
      ["pspace"] = "-1",
      ["width"] = "125",
      ["pheight"] = "-1",
    },
    ["customcolor"] = "0.1,0.2,0.2,1",
    ["custombg"] = "1",
    ["custom"] = "1",
  },
  ["bars"] = {
    ["icon_size"] = "17",
    ["right"] = {
      ["formfactor"] = "4 x 3",
    },
    ["bottomright"] = {
      ["formfactor"] = "4 x 3",
    },
  },
  ["chat"] = {
    ["global"] = {
      ["tabmouse"] = "1",
      ["tabdock"] = "0",
      ["border"] = "0,0,0,1",
      ["custombg"] = "1",
      ["background"] = "0.15,0.25,0.25,0.3",
    },
    ["text"] = {
      ["outline"] = "0",
    },
    ["left"] = {
      ["height"] = "161",
      ["width"] = "400",
    },
    ["right"] = {
      ["height"] = "161",
      ["width"] = "400",
    },
  },
}

-- assign profiles to userdata
pfUI_profiles["Modern"] = modern
pfUI_profiles["Nostalgia"] = nostalgia
pfUI_profiles["Legacy"] = legacy
pfUI_profiles["Adapta"] = adapta
pfUI_profiles["Slim"] = slim


-- overwrite core profiles in userdata
local profile_loader = CreateFrame("Frame")
profile_loader:RegisterEvent("VARIABLES_LOADED")
profile_loader:SetScript("OnEvent", function()
  pfUI_profiles["Modern"] = modern
  pfUI_profiles["Nostalgia"] = nostalgia
  pfUI_profiles["Legacy"] = legacy
  pfUI_profiles["Adapta"] = adapta
  pfUI_profiles["Light"] = light
  pfUI_profiles["Slim"] = slim
  this:UnregisterAllEvents()
end)