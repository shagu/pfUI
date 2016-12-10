pfUI:RegisterModule("nameplates", function ()
  pfUI.nameplates = CreateFrame("Frame", nil, UIParent)

  pfUI.nameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
  pfUI.nameplates:RegisterEvent("UNIT_AURA")

  -- temporary data per session
  pfUI.nameplates.mobs = {}
  pfUI.nameplates.targets = {}

  pfUI.nameplates:SetScript("OnEvent", function()
      -- current debuffs
      pfUI.nameplates.debuffs = {}
      local i = 1
      local debuff = UnitDebuff("target", i)
      while debuff do
        pfUI.nameplates.debuffs[i] = debuff
        i = i + 1
        debuff = UnitDebuff("target", i)
      end

      -- scan player (target)
      if UnitName("target") ~= nil and pfUI_playerDB[UnitName("target")] == nil and pfUI.nameplates.targets[UnitName("target")] == nil then
        if UnitIsPlayer("target") then
          local _, class = UnitClass("target")
          pfUI_playerDB[UnitName("target")] = {}
          pfUI_playerDB[UnitName("target")]["class"] = class
        elseif UnitClassification("target") ~= "normal" then
          local elite = UnitClassification("target")
          pfUI.nameplates.mobs[UnitName("target")] = elite
        end
        pfUI.nameplates.targets[UnitName("target")] = "OK"
      end
  end)

  pfUI.nameplates:SetScript("OnUpdate", function()
    local frames = { WorldFrame:GetChildren() }
    for _, nameplate in ipairs(frames) do
      local regions = nameplate:GetRegions()
      if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
        local healthbar = nameplate:GetChildren()
        local border, glow, name, level, levelicon , raidicon = nameplate:GetRegions()

        if pfUI_config.nameplates.players == "1" then
          if not pfUI_playerDB[name:GetText()] or not pfUI_playerDB[name:GetText()]["class"] then
            nameplate:Hide()
          end
        end

        -- scan player (idle targeting)
        if pfUI.nameplates.targets[name:GetText()] == nil and UnitName("target") == nil then
          TargetByName(name:GetText(), true)
          if UnitIsPlayer("target") then
            local _, class = UnitClass("target")
            pfUI_playerDB[name:GetText()] = {}
            pfUI_playerDB[name:GetText()]["class"] = class
          elseif UnitClassification("target") ~= "normal" then
            local elite = UnitClassification("target")
            pfUI.nameplates.mobs[name:GetText()] = elite
          end
          pfUI.nameplates.targets[name:GetText()] = "OK"
          ClearTarget()
        end

        -- scan player (mouseover)
        if pfUI_playerDB[name:GetText()] == nil and UnitName("mouseover") == name:GetText() and pfUI.nameplates.targets[name:GetText()] == nil then
          if UnitIsPlayer("mouseover") then
            local _, class = UnitClass("mouseover")
            pfUI_playerDB[name:GetText()] = {}
            pfUI_playerDB[name:GetText()]["class"] = class
          elseif UnitClassification("mouseover") ~= "normal" then
            local elite = UnitClassification("mouseover")
            pfUI.nameplates.mobs[name:GetText()] = elite
          end
          pfUI.nameplates.targets[name:GetText()] = "OK"
        end

        -- enable clickthrough
        if pfUI_config.nameplates["clickthrough"] == "0" then
          nameplate:EnableMouse(true)
        else
          nameplate:EnableMouse(false)
        end

        -- healthbar
        healthbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
        healthbar:ClearAllPoints()
        healthbar:SetPoint("TOP", nameplate, "TOP", 0, tonumber(pfUI_config.nameplates.vpos))
        healthbar:SetWidth(110)
        healthbar:SetHeight(7)

        if healthbar.bg == nil then
          healthbar.bg = healthbar:CreateTexture(nil, "BORDER")
          healthbar.bg:SetTexture(0,0,0,0.90)
          healthbar.bg:ClearAllPoints()
          healthbar.bg:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
          healthbar.bg:SetWidth(healthbar:GetWidth() + 3)
          healthbar.bg:SetHeight(healthbar:GetHeight() + 3)
        end

        if pfUI_config.nameplates.showhp == "1" then
          if healthbar.hptext == nil then
            healthbar.hptext = healthbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
            healthbar.hptext:SetPoint("RIGHT", healthbar, "RIGHT")
            healthbar.hptext:SetNonSpaceWrap(false)
            healthbar.hptext:SetFontObject(GameFontWhite)
            healthbar.hptext:SetTextColor(1,1,1,1)
            healthbar.hptext:SetFont(STANDARD_TEXT_FONT, 10)
          end

          local min, max = healthbar:GetMinMaxValues()
          local cur = healthbar:GetValue()
          healthbar.hptext:SetText(cur .. " / " .. max)
        end

        -- raidtarget
        raidicon:ClearAllPoints()
        raidicon:SetWidth(pfUI_config.nameplates.raidiconsize)
        raidicon:SetHeight(pfUI_config.nameplates.raidiconsize)
        raidicon:SetPoint("CENTER", healthbar, "CENTER", 0, -5)

        -- debuffs
        if nameplate.debuffs == nil then nameplate.debuffs = {} end
        for j=1, 16, 1 do
          if nameplate.debuffs[j] == nil then
            nameplate.debuffs[j] = nameplate:CreateTexture(nil, "BORDER")
            nameplate.debuffs[j]:SetTexture(0,0,0,0)
            nameplate.debuffs[j]:ClearAllPoints()
            nameplate.debuffs[j]:SetWidth(12)
            nameplate.debuffs[j]:SetHeight(12)
            if j == 1 then
              nameplate.debuffs[j]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
            elseif j <= 8 then
              nameplate.debuffs[j]:SetPoint("LEFT", nameplate.debuffs[j-1], "RIGHT", 1, 0)
            elseif j > 8 then
              nameplate.debuffs[j]:SetPoint("TOPLEFT", nameplate.debuffs[1], "BOTTOMLEFT", (j-9) * 13, -1)
            end
          end
        end

        if pfUI_config.nameplates["showdebuffs"] == "1" and UnitExists("target") and healthbar:GetAlpha() == 1 then
          local j = 1
          local k = 1
          for j, e in ipairs(pfUI.nameplates.debuffs) do
            nameplate.debuffs[j]:SetTexture(pfUI.nameplates.debuffs[j])
            nameplate.debuffs[j]:SetTexCoord(.078, .92, .079, .937)
            nameplate.debuffs[j]:SetAlpha(0.9)
            k = k + 1
          end
          for j = k, 16, 1 do
            nameplate.debuffs[j]:SetTexture(nil)
          end
        else
          for j = 1, 16, 1 do
            nameplate.debuffs[j]:SetTexture(nil)
          end
        end

        -- hide default plates
        border:Hide()
        glow:Hide()

        -- adjust font
        name:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
        name:SetPoint("BOTTOM", healthbar, "CENTER", 0, 7)
        level:SetFont(STANDARD_TEXT_FONT,12, "OUTLINE")
        level:ClearAllPoints()
        level:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)
        levelicon:ClearAllPoints()
        levelicon:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)

        -- tweak the colors to match the rest
        local red, green, blue, _ = name:GetTextColor()
        if red > 0.99 and green == 0 and blue == 0 then
          name:SetTextColor(1,0.4,0.2,0.85)
        elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
          name:SetTextColor(1,1,1,0.85)
        end

        local red, green, blue, _ = level:GetTextColor()
        if red > 0.99 and green == 0 and blue == 0 then
          level:SetTextColor(1,0.4,0.2,0.85)
        elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
          level:SetTextColor(1,1,1,0.85)
        end

        -- adjust healthbar color
        local red, green, blue, _ = healthbar:GetStatusBarColor()
        if pfUI_playerDB[name:GetText()] and pfUI_playerDB[name:GetText()]["class"] and RAID_CLASS_COLORS[pfUI_playerDB[name:GetText()]["class"]] then
          healthbar:SetStatusBarColor(
            RAID_CLASS_COLORS[pfUI_playerDB[name:GetText()]["class"]].r,
            RAID_CLASS_COLORS[pfUI_playerDB[name:GetText()]["class"]].g,
            RAID_CLASS_COLORS[pfUI_playerDB[name:GetText()]["class"]].b,
            0.9)
        elseif red > 0.9 and green < 0.2 and blue < 0.2 then
          healthbar:SetStatusBarColor(.9,.2,.3,0.8)
        elseif red > 0.9 and green > 0.9 and blue < 0.2 then
          healthbar:SetStatusBarColor(1,1,.3,0.8)
        elseif blue > 0.9 and red == 0 and green == 0 then
          healthbar:SetStatusBarColor(0.2,0.6,1,0.8)
        elseif red == 0 and green > 0.99 and blue == 0 then
          healthbar:SetStatusBarColor(0.6,1,0,0.8)
        end

        -- show indicator for elite/rare mobs
        if level:GetText() ~= nil then
          if pfUI.nameplates.mobs[name:GetText()] and pfUI.nameplates.mobs[name:GetText()] == "elite" and not string.find(level:GetText(), "+") then
            level:SetText(level:GetText() .. "+")
          elseif pfUI.nameplates.mobs[name:GetText()] and pfUI.nameplates.mobs[name:GetText()] == "rareelite" and not string.find(level:GetText(), "R+") then
            level:SetText(level:GetText() .. "R+")
          elseif pfUI.nameplates.mobs[name:GetText()] and pfUI.nameplates.mobs[name:GetText()] == "rare" and not string.find(level:GetText(), "R") then
            level:SetText(level:GetText() .. "R")
          end
        end

        -- show castbar
        if pfUI.castbar and pfUI_config.nameplates["showcastbar"] == "1" and pfUI.castbar.target.casterDB[name:GetText()] ~= nil and pfUI.castbar.target.casterDB[name:GetText()]["cast"] ~= nil then

          -- create frames
          if healthbar.castbar == nil then
            healthbar.castbar = CreateFrame("StatusBar", nil, healthbar)
            healthbar.castbar:SetWidth(110)
            healthbar.castbar:SetHeight(7)
            healthbar.castbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -5)
            healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                    insets = {left = -1, right = -1, top = -1, bottom = -1} })
            healthbar.castbar:SetBackdropColor(0,0,0,1)
            healthbar.castbar:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
            healthbar.castbar:SetStatusBarColor(.9,.8,0,1)

            if healthbar.castbar.bg == nil then
              healthbar.castbar.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
              healthbar.castbar.bg:SetTexture(0,0,0,0.90)
              healthbar.castbar.bg:ClearAllPoints()
              healthbar.castbar.bg:SetPoint("CENTER", healthbar.castbar, "CENTER", 0, 0)
              healthbar.castbar.bg:SetWidth(healthbar.castbar:GetWidth() + 3)
              healthbar.castbar.bg:SetHeight(healthbar.castbar:GetHeight() + 3)
            end

            if healthbar.castbar.text == nil then
              healthbar.castbar.text = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
              healthbar.castbar.text:SetPoint("RIGHT", healthbar.castbar, "LEFT")
              healthbar.castbar.text:SetNonSpaceWrap(false)
              healthbar.castbar.text:SetFontObject(GameFontWhite)
              healthbar.castbar.text:SetTextColor(1,1,1,.5)
              healthbar.castbar.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            end

            if healthbar.castbar.spell == nil then
              healthbar.castbar.spell = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
              healthbar.castbar.spell:SetPoint("CENTER", healthbar.castbar, "CENTER")
              healthbar.castbar.spell:SetNonSpaceWrap(false)
              healthbar.castbar.spell:SetFontObject(GameFontWhite)
              healthbar.castbar.spell:SetTextColor(1,1,1,1)
              healthbar.castbar.spell:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
            end

            if healthbar.castbar.icon == nil then
              healthbar.castbar.icon = healthbar.castbar:CreateTexture(nil, "BORDER")
              healthbar.castbar.icon:ClearAllPoints()
              healthbar.castbar.icon:SetPoint("BOTTOMLEFT", healthbar.castbar, "BOTTOMRIGHT", 5, 0)
              healthbar.castbar.icon:SetWidth(18)
              healthbar.castbar.icon:SetHeight(18)
            end

            if healthbar.castbar.icon.bg == nil then
              healthbar.castbar.icon.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
              healthbar.castbar.icon.bg:SetTexture(0,0,0,0.90)
              healthbar.castbar.icon.bg:ClearAllPoints()
              healthbar.castbar.icon.bg:SetPoint("CENTER", healthbar.castbar.icon, "CENTER", 0, 0)
              healthbar.castbar.icon.bg:SetWidth(healthbar.castbar.icon:GetWidth() + 3)
              healthbar.castbar.icon.bg:SetHeight(healthbar.castbar.icon:GetHeight() + 3)
            end
          end

          if pfUI.castbar.target.casterDB[name:GetText()]["starttime"] + pfUI.castbar.target.casterDB[name:GetText()]["casttime"] <= GetTime() then
            pfUI.castbar.target.casterDB[name:GetText()] = nil
            healthbar.castbar:Hide()
          else
            healthbar.castbar:SetMinMaxValues(0,  pfUI.castbar.target.casterDB[name:GetText()]["casttime"])
            healthbar.castbar:SetValue(GetTime() -  pfUI.castbar.target.casterDB[name:GetText()]["starttime"])
            healthbar.castbar.text:SetText(round( pfUI.castbar.target.casterDB[name:GetText()]["starttime"] +  pfUI.castbar.target.casterDB[name:GetText()]["casttime"] - GetTime(),1))
            if healthbar.castbar.spell then
              if pfUI_config.nameplates.spellname == "1" then
                healthbar.castbar.spell:SetText(pfUI.castbar.target.casterDB[name:GetText()]["cast"])
              else
                healthbar.castbar.spell:SetText("")
              end
            end
            healthbar.castbar:Show()
            nameplate.debuffs[1]:SetPoint("TOPLEFT", healthbar.castbar, "BOTTOMLEFT", 0, -3)

            if pfUI.castbar.target.casterDB[name:GetText()]["icon"] then
              healthbar.castbar.icon:SetTexture("Interface\\Icons\\" ..  pfUI.castbar.target.casterDB[name:GetText()]["icon"])
              healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
            end
          end
        elseif healthbar.castbar then
          healthbar.castbar:Hide()
          nameplate.debuffs[1]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
        end
      end
    end
  end)
end)
