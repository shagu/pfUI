local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
  -- pfUI
  pfUI_profiles["pfUI"] = {
    ["chat"] = {
      ["right"] = {
        ["enable"] = "1",
      },
    },
  }

  -- pfUI Dark
  pfUI_profiles["pfUI Dark"] = {
    ["appearance"] = {
      ["border"] = {
        ["color"] = "0.0,0.0,0.0,1",
        ["background"] = "0.02,0.02,0.02,0.75",
      },
    },
    ["chat"] = {
      ["right"] = {
        ["enable"] = "1",
      },
    },
  }

  -- Slim
  pfUI_profiles["Slim"] = {
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
        ["enable"] = "1",
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
        ["debuffs"] = "off",
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
        ["buffs"] = "off",
        ["debuffs"] = "off",
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

  -- Adapta
  pfUI_profiles["Adapta"] = {
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
        ["enable"] = "1",
        ["height"] = "161",
        ["width"] = "400",
      },
    },
  }
end)
