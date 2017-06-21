pfUI:RegisterModule("firstrun", function ()
  pfUI.firstrun = CreateFrame("Frame", "pfFirstRunWizard", UIParent)
  pfUI.firstrun.steps = {}
  pfUI.firstrun.next = nil

  pfUI.firstrun:RegisterEvent("PLAYER_ENTERING_WORLD")
  pfUI.firstrun:SetScript("OnEvent", function() pfUI.firstrun:NextStep() end)

  function pfUI.firstrun:AddStep(name, yfunc, nfunc, descr, cmpnt)
    if not name then return end

    local step = {}
    step.name = name
    step.yfunc = yfunc or nil
    step.nfunc = nfunc or nil
    step.descr = descr or nil
    step.cmpnt = cmpnt or nil

    table.insert(pfUI.firstrun.steps, step)
  end

  pfUI.firstrun:AddStep("cvars", function() pfUI.SetupCVars() end, nil, "|cff33ffccBlizzard: \"Interface Options\"|r\n\n"..
  "Do you want me to setup the recommended blizzard UI settings?\n"..
  "This will enable settings that can be found in the Interface section of your client.\n"..
  "Options like Buff Durations, Instant Quest Text, Auto Selfcast and others will be set.\n")

  local all_yes = false
  function pfUI.firstrun:NextStep()
    if pfUI_init and next(pfUI_init) == nil then
      local yes = function()
        this:GetParent():Hide()
        pfUI_init["welcome"] = true
        pfUI.firstrun:NextStep()
      end

      local no = function()
        this:GetParent():Hide()
        pfUI_init["welcome"] = true
        all_yes = true
        pfUI.firstrun:NextStep()
      end

      CreateQuestionDialog("Welcome to |cff33ffccpf|cffffffffUI|r!\n\n"..
      "I'm the first run wizzard that will guide you through some basic configuration.\n"..
      "If you're lazy, feel free to hit the \"Use Defaults\" button. If you whish to run this\n"..
      "dialog again, go to the settings and hit the \"Reset Firstrun\" button.\n\n"..
      "Visit |cff33ffcchttp://shagu.org|r to check for the latest version.", { "Customize", yes } , { "Use Defaults", no })
      return
    end

    for _, step in pairs(pfUI.firstrun.steps) do
      local name = step.name

      if not pfUI_init[name] then
        local function yes()
          pfUI_init[name] = true
          if step.yfunc then step.yfunc() end
          this:GetParent():Hide()
          pfUI.firstrun:NextStep()
        end

        local function no()
          pfUI_init[name] = true
          if step.nfunc then step.nfunc() end
          this:GetParent():Hide()
          pfUI.firstrun:NextStep()
        end

        if all_yes == true then
          yes()
          return
        end

        if step.cmpnt and step.cmpnt == "edit" then
          CreateQuestionDialog(step.descr, yes, no, true)
        else
          CreateQuestionDialog(step.descr, yes, no, false)
        end

        return
      end
    end
  end
end)
