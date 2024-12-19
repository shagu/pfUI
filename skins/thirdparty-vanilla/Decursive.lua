pfUI:RegisterSkin("Decursive", "vanilla", function()
    HookAddonOrVariable("Decursive", function()
        local tooltips = {
            "DcrDisplay_Tooltip",
            "Dcr_ScanningTooltip",
            "Dcr_Tooltip"
        }
        for _, tooltipName in ipairs(tooltips) do
            local tooltip = _G[tooltipName]
            if tooltip then
                CreateBackdrop(tooltip)
            end
        end

        local checkboxes = {
            "DcrOptionsFramePrintDefault",
            "DcrOptionsFramePrintCustomFrame",
            "DcrOptionsFrameCheckForAbolish",
            "DcrOptionsFrameDoNotBLPrio",
            "DcrOptionsFrameAlwaysUseBestSpell",
            "DcrOptionsFrameRandomOrder",
            "DcrOptionsFrameCurePets",
            "DcrOptionsFrameSkipStealth",
            "DcrOptionsFramePlaySound",
            "DcrOptionsFramePrintError",
            "DcrOptionsFrameShowToolTip",
            "DcrOptionsFrameReverseLiveDisplay",
            "DcrOptionsFrameHideLL",
            "DcrOptionsFrameTieLL",
            "DcrOptionsFrameCureMutatingInjection",
            "DcrOptionsFrameCureWyvernSting",
            "DcrOptionsFrameRangeCheck",
            -- "DecursiveCurseTypeCheckBox", -- if need
            "DcrOptionsFrame2CureMagic",
            "DcrOptionsFrame2CurePoison",
            "DcrOptionsFrame2CureDisease",
            "DcrOptionsFrame2CureCurse",
        }
        for _, checkboxName in ipairs(checkboxes) do
            local checkbox = _G[checkboxName]
            if checkbox then
                SkinCheckbox(checkbox)
            end
        end

        local sliders = {
            "DcrOptionsFrameAmountOfAfflictedSlider",
            "DcrOptionsFrameCureBlacklistSlider",
            "DcrOptionsFrameScanTimeSlider"
        }
        for _, sliderName in ipairs(sliders) do
            local slider = _G[sliderName]
            if slider then
                SkinSlider(slider)
            end
        end

        local frames = {
            "DecursiveMainBar",
            "DecursivePriorityListFrame",
            "DecursiveSkipListFrame",
            "DecursivePopulateListFrame",
            "DcrOptionsFrame",
            "DcrOptionsFrame2",
            "DecursiveAnchor",
            -- "DecursiveTextFrame", -- if need
        }
        for _, frameName in ipairs(frames) do
            local frame = _G[frameName]
            if frame then
                StripTextures(frame)
                CreateBackdrop(frame)
                CreateBackdropShadow(frame)
            end
        end

        for i = 1, 15 do
            local listItem = _G["DecursiveAfflictedListFrame" .. "ListItem" .. i]
            if listItem then
                StripTextures(listItem)
                CreateBackdrop(listItem)
                CreateBackdropShadow(listItem)
                listItem:ClearAllPoints()
                listItem:SetPoint("TOPLEFT", "DecursiveMainBar", "BOTTOMLEFT", 0, -3)
            end
        end

        local buttons = {
            "DecursiveMainBarPriority",
            "DecursiveMainBarSkip",
            "DecursiveMainBarOptions",
            "DecursiveMainBarHide",

            "DcrOptionsFrame2Save",
            "DcrOptionsFrameAnchor",
            "DecursiveAnchorDirection",

            -- "DecursiveAfflictedListFrameClear", -- if need
            -- "DecursiveAfflictedListFrameClose", -- if need

            "DecursivePriorityListFrameClear",
            "DecursivePriorityListFrameClose",
            "DecursivePriorityListFramePopulate",
            "DecursivePriorityListFrameAdd",
            "DecursivePriorityListFrameUp",
            "DecursivePriorityListFrameDown",

            "DecursiveSkipListFrameClear",
            "DecursiveSkipListFrameClose",
            "DecursiveSkipListFramePopulate",
            "DecursiveSkipListFrameAdd",
            "DecursiveSkipListFrameUp",
            "DecursiveSkipListFrameDown",

            "DecursivePopulateListFrameGroup1",
            "DecursivePopulateListFrameGroup2",
            "DecursivePopulateListFrameGroup3",
            "DecursivePopulateListFrameGroup4",
            "DecursivePopulateListFrameGroup5",
            "DecursivePopulateListFrameGroup6",
            "DecursivePopulateListFrameGroup7",
            "DecursivePopulateListFrameGroup8",
            "DecursivePopulateListFrameWarrior",
            "DecursivePopulateListFramePriest",
            "DecursivePopulateListFrameMage",
            "DecursivePopulateListFrameWarlock",
            "DecursivePopulateListFrameHunter",
            "DecursivePopulateListFrameRogue",
            "DecursivePopulateListFrameDruid",
            "DecursivePopulateListFrameShaman",
            "DecursivePopulateListFramePaladin",
            "DecursivePopulateListFrameClose",
        }
        for _, buttonName in ipairs(buttons) do
            local button = _G[buttonName]
            if button then
                SkinButton(button)
            end
        end

        -- Interactive color states to buttons
        -- set SetVertexColor for buttons:texture
        local redButtons = {
            "DecursiveMainBarHide",
            "DcrOptionsFrameAnchor",
            "DecursiveAnchorDirection",
            "DcrOptionsFrame2Save",
            "DecursivePriorityListFrameClose",
            "DecursiveSkipListFrameClose",
            "DecursivePopulateListFrameClose"
        }

        local Colors = {
            base = {0.1, 0.1, 0.1, 1},
            border = {
                normal = {0, 0, 0, 1},
                hover = {1, 0.5, 0.5, 1},
                click = {0.7, 0, 0, 1}
            },
            text = {
                normal = {1, 0, 0, 1},
                hover = {1, 0.5, 0.5, 1},
                click = {0.7, 0, 0, 1}
            }
        }

        local function safeSetColor(button, colorType, color)
            if not button or not color then return end
            
            local colorSetters = {
                text = {
                    function() button:SetTextColor(unpack(color)) end,
                    function() button.Text:SetTextColor(unpack(color)) end,
                    function() button:GetFontString():SetTextColor(unpack(color)) end
                },
                border = {
                    function() button:SetBackdropBorderColor(unpack(color)) end
                },
                background = {
                    function() button:SetBackdropColor(unpack(color)) end
                }
            }
            
            for _, setter in ipairs(colorSetters[colorType] or {}) do
                pcall(setter)
            end
        end

        local function setupButtonColor(button)
            if not button then return end

            local state = {
                isHovered = false,
                isClicked = false
            }

            local function updateButtonColors()
                local colorSet = state.isClicked and Colors.border.click or 
                                 state.isHovered and Colors.border.hover or 
                                 Colors.border.normal

                local textColorSet = state.isClicked and Colors.text.click or 
                                      state.isHovered and Colors.text.hover or 
                                      Colors.text.normal

                safeSetColor(button, "border", colorSet)
                safeSetColor(button, "text", textColorSet)
                safeSetColor(button, "background", Colors.base)
            end

            button:SetScript("OnEnter", function() 
                state.isHovered = true
                updateButtonColors()
            end)
            
            button:SetScript("OnLeave", function() 
                state.isHovered = false
                updateButtonColors()
            end)
            
            button:SetScript("OnMouseDown", function() 
                state.isClicked = true
                updateButtonColors()
            end)
            
            button:SetScript("OnMouseUp", function() 
                state.isClicked = false
                updateButtonColors()
            end)

            updateButtonColors()
        end

        for _, buttonName in ipairs(redButtons or {}) do
            local button = _G[buttonName]
            pcall(setupButtonColor, button)
        end

        -- Align Buttons
        local mainBar = _G["DecursiveMainBar"]
        local decursiveButtons = {
            "DecursiveMainBarPriority",
            "DecursiveMainBarSkip", 
            "DecursiveMainBarOptions",
            "DecursiveMainBarHide"
        }
        local prevButton
        for i, buttonName in ipairs(decursiveButtons) do
            local button = _G[buttonName]
            button:ClearAllPoints()
            button:SetPoint(i == 1 and "RIGHT" or "LEFT", 
                            i == 1 and mainBar or prevButton, 
                            i == 1 and "RIGHT" or "RIGHT", 
                            i == 1 and 22 or 1, 0)
            prevButton = button
        end

        -- Colorize buttons
        local function GetClassColor(class)
            return RAID_CLASS_COLORS[class].r, 
                   RAID_CLASS_COLORS[class].g, 
                   RAID_CLASS_COLORS[class].b, 1
        end
        local classButtons = {
            ["DecursivePopulateListFrameWarrior"]   = "WARRIOR",
            ["DecursivePopulateListFramePaladin"]   = "PALADIN", 
            ["DecursivePopulateListFrameHunter"]    = "HUNTER",
            ["DecursivePopulateListFrameRogue"]     = "ROGUE",
            ["DecursivePopulateListFramePriest"]    = "PRIEST", 
            ["DecursivePopulateListFrameShaman"]    = "SHAMAN",
            ["DecursivePopulateListFrameMage"]      = "MAGE", 
            ["DecursivePopulateListFrameWarlock"]   = "WARLOCK", 
            ["DecursivePopulateListFrameDruid"]     = "DRUID"
        }
        for buttonName, class in pairs(classButtons) do
            local button = _G[buttonName]
            if button then
                local r, g, b = GetClassColor(class)
                if r and g and b then
                    button:SetBackdropColor(r * 0.5, g * 0.5, b * 0.5, 0.8)
                    button:SetBackdropBorderColor(r, g, b, 1)
                    
                    local text = button:GetFontString()
                    if text then
                        text:SetTextColor(r, g, b, 1)
                    end
                end
            end
        end

    end)
end)
