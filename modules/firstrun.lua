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

  local txt = T["|cff33ffccBlizzard: \"Interface Options\"|r\n\nDo you want me to setup the recommended blizzard UI settings?\nThis will enable settings that can be found in the Interface section of your client.\nOptions like Buff Durations, Instant Quest Text, Auto Selfcast and others will be set."]
  pfUI.firstrun:AddStep("cvars", function() pfUI.SetupCVars() end, nil, txt)

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

      local txt = T["Welcome to |cff33ffccpf|cffffffffUI|r!\n\nI'm the first run wizzard that will guide you through some basic configuration.\nIf you're lazy, feel free to hit the \"Use Defaults\" button. If you whish to run this\ndialog again, go to the settings and hit the \"Reset Firstrun\" button.\n\nVisit |cff33ffcchttp://shagu.org|r to check for the latest version."]

      CreateQuestionDialog(txt, { "Customize", yes } , { "Use Defaults", no })
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
