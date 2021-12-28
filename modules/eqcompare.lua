pfUI:RegisterModule("eqcompare", "vanilla", function ()
  local loc = pfUI.cache["locale"]
  for key, value in pairs(L["itemtypes"]) do setglobal(key, value) end
  INVTYPE_WEAPON_OTHER = INVTYPE_WEAPON.."_other"
  INVTYPE_FINGER_OTHER = INVTYPE_FINGER.."_other"
  INVTYPE_TRINKET_OTHER = INVTYPE_TRINKET.."_other"

  local slotTable = {
    [INVTYPE_2HWEAPON] = "MainHandSlot",
    [INVTYPE_BODY] = "ShirtSlot",
    [INVTYPE_CHEST] = "ChestSlot",
    [INVTYPE_CLOAK] = "BackSlot",
    [INVTYPE_FEET] = "FeetSlot",
    [INVTYPE_FINGER] = "Finger0Slot",
    [INVTYPE_FINGER_OTHER] = "Finger1Slot",
    [INVTYPE_HAND] = "HandsSlot",
    [INVTYPE_HEAD] = "HeadSlot",
    [INVTYPE_HOLDABLE] = "SecondaryHandSlot",
    [INVTYPE_LEGS] = "LegsSlot",
    [INVTYPE_NECK] = "NeckSlot",
    [INVTYPE_RANGED] = "RangedSlot",
    [INVTYPE_RELIC] = "RangedSlot",
    [INVTYPE_ROBE] = "ChestSlot",
    [INVTYPE_SHIELD] = "SecondaryHandSlot",
    [INVTYPE_SHOULDER] = "ShoulderSlot",
    [INVTYPE_TABARD] = "TabardSlot",
    [INVTYPE_TRINKET] = "Trinket0Slot",
    [INVTYPE_TRINKET_OTHER] = "Trinket1Slot",
    [INVTYPE_WAIST] = "WaistSlot",
    [INVTYPE_WEAPON] = "MainHandSlot",
    [INVTYPE_WEAPON_OTHER] = "SecondaryHandSlot",
    [INVTYPE_WEAPONMAINHAND] = "MainHandSlot",
    [INVTYPE_WEAPONOFFHAND] = "SecondaryHandSlot",
    [INVTYPE_WRIST] = "WristSlot",

    [INVTYPE_WAND] = "RangedSlot",
    [INVTYPE_GUN] = "RangedSlot",
    [INVTYPE_PROJECTILE] = "AmmoSlot",
    [INVTYPE_CROSSBOW] = "RangedSlot",
    [INVTYPE_THROWN] = "RangedSlot",
  }

  local function startsWith(str, start)
    return string.sub(str, 1, string.len(start)) == start
  end

  local function ExtractAttributes(tooltip)
    local name = tooltip:GetName()

    -- get the name/header of the last set comparison tooltip
    local comparetooltip = pfUI.eqcompare.tooltip:GetName()
    local iname = _G[comparetooltip .. "TextLeft1"] and _G[comparetooltip .. "TextLeft1"]:GetText()

    -- only run once per item
    if tooltip.pfCompLastName == iname then return end

    tooltip.pfCompData = {}
    tooltip.pfCompLastName = iname

    for i=1,30 do
      local widget = _G[name.."TextLeft"..i]
      if widget and widget:GetObjectType() == "FontString" then
        local text = widget:GetText()
        if text and not string.find(text, "-", 1, true) then
          local start = 1
          if startsWith(text, "\+") or startsWith(text, "\(") then start = 2 end

          local space = string.find(text, " ", 1, true)
          if space then
            local value = tonumber(string.sub(text, start, space-1))
            if value and text then
              -- we've found an attr
              local attr = string.sub(text, space, string.len(text))
              tooltip.pfCompData[attr] = { value = tonumber(value), widget = widget }
            end
          end
        end
      end
    end
  end



  local function CompareAttributes(data, targetData)
    if not data then return end

local baseArmor , effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");

if UnitLevel("player") < 60 then
DR = (effectiveArmor)/((effectiveArmor)+400+UnitLevel("player")*85);

elseif UnitLevel("player") == 60 then
DR = effectiveArmor/(effectiveArmor+400+(UnitLevel("player")*4.5*(UnitLevel("player")-59)));
end
local _, class = UnitClass("player")
    for attr,v in pairs(data) do
      if targetData then
        local target = targetData[attr]
        if target then
          if v.value ~= target.value and v.widget:GetText() then
            if v.value > target.value then
			if string.find(attr, "Armor") then -- I don't know how to add the 2 armor per agility here
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. " [+" .. 
				(round(((UnitArmor("player")+(v.value - target.value))/((UnitArmor("player")+(v.value - target.value))+400+UnitLevel("player")*85)-DR)*10000, 1)/100) .. "%])")
			end
			elseif string.find(attr, "Strength") then
				if class == "PALADIN" or class == "WARRIOR" or class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)*2) .. "AP, +" .. ((v.value - target.value)/20) .. "Block])")	
					end
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)*2) .. "AP]")	
					end
				elseif class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "ROGUE" or class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						round(v.value - target.value,1) .. "AP]")	
					end 
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
				-- Don't know but I suspect this will help GMs not get weird errors while classless, 
				-- and it will keep basic support to custom classes on whatever weird server
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
					v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ")")	
					end 				
				end
			elseif string.find(attr, "Agility") then
				if class == "PALADIN" or class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)*2) .. "Armor, +" .. ((v.value - target.value)/20) .. "% Dodge, +"
						.. ((v.value - target.value)/20) .. "% Crit.])")	
					end				
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						round(v.value - target.value,1) .. "Cat AP, +" .. (round(v.value - target.value,1)*2) .. "Armor, +" 
						.. ((v.value - target.value)/20) .. "% Dodge, +" .. ((v.value - target.value)/20) .. "% Crit.])")	
					end			
				elseif class == "WARRIOR" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						round(v.value - target.value,1) .. "RAP, +" .. (round(v.value - target.value,1)*2) .. "Armor, +" 
						.. ((v.value - target.value)/20) .. "% Dodge, +" .. ((v.value - target.value)/20) .. "% Crit.])")	
					end		
				elseif class == "HUNTER" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)*2) .. "RAP, +" .. round(v.value - target.value,1) .. "AP, +" .. 
						(round(v.value - target.value,1)*2) .. "Armor, +" 
						.. ((v.value - target.value)/26) .. "% Dodge, +".. ((v.value - target.value)/53) .. "% Crit.])")	
					end	
				elseif class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						round(v.value - target.value,1) .. "RAP, +" .. round(v.value - target.value,1) .. "AP, +" .. 
						(round(v.value - target.value,1)*2) .. "Armor, +" 
						.. ((v.value - target.value)/14.5) .. "% Dodge, +".. ((v.value - target.value)/29) .. "% Crit.])")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "ROGUE" then -- Wowhead didn't have stats for the casters, not significant anyways
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ")")	
					end
				end
			elseif string.find(attr, "Stamina") then -- Stamina could probs be expanded to account for tauren or bear or whatever but not right now
			  if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ", [+" .. 
				(round(v.value - target.value, 1)*10) .. "HP.])")	
				end
			elseif string.find(attr, "Intellect") then
				if class == "PALADIN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/54) .. "% Spell Crit, +" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "DRUID" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/60) .. "% Spell Crit, +" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/59.5) .. "% Spell Crit, +" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "MAGE" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/59.5) .. "% Spell Crit, +" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "PRIEST" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/59.2) .. "% Spell Crit, +" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "WARLOCK" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/60.6) .. "% Spell Crit, +" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ")")	
					end
				end
			elseif string.find(attr, "Spirit") then				
				if class == "HUNTER" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, +" .. (round(v.value - target.value, 1)*0.25) .." HP Regen]")	
					end
				elseif class == "PALADIN" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, +" .. (round(v.value - target.value, 1)*0.25) .." HP Regen]")	
					end
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/4.5) .. "MP Regen, +" .. (round(v.value - target.value, 1)*0.09) .." HP Regen, +" ..
						(round(v.value - target.value,1)/5) .. "MP Regen (cat/bear)]")	
					end
				elseif class == "PRIEST" or class == "MAGE" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/4) .. "MP Regen, +" .. (round(v.value - target.value, 1)*0.1) .." HP Regen]")	
					end
				elseif class == "SHAMAN" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, +" .. (round(v.value - target.value, 1)*0.11) .." HP Regen]")	
					end
				elseif class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, +" .. (round(v.value - target.value, 1)*0.07) .." HP Regen]")	
					end
				elseif class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value, 1)*0.5) .." HP Regen]")	
					end
				elseif class == "WARRIOR" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. "[+" .. 
						(round(v.value - target.value, 1)*0.8) .." HP Regen]")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
					v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ")")	
					end 
				end					
			elseif not string.find(attr, "Armor") and not string.find(attr, "Strength") and not string.find(attr, "Agility")
				and not string.find(attr, "Stamina") and not string.find(attr, "Intellect") and not string.find(attr, "Spirit")			
			then -- for the stats I'm not going to do or haven't done yet
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. round(v.value - target.value, 1) .. ")")					
				end
			  end
			  

            elseif not v.widget.compSet then
			if string.find(attr, "Armor") then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(target.value - v.value, 1) .. " [" .. 
				(round(((UnitArmor("player")-(target.value - v.value))/((UnitArmor("player")-(target.value - v.value))+400+UnitLevel("player")*85)-DR)*10000, 1)/100) .. "%])")
			end
			elseif string.find(attr, "Strength") then
				if class == "PALADIN" or class == "WARRIOR" or class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)*2) .. "AP, -" .. ((v.value - target.value)/20) .. "Block])")	
					end
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)*2) .. "AP]")	
					end
				elseif class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "ROGUE" or class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						round(v.value - target.value,1) .. "AP]")	
					end 
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
					v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(target.value - v.value, 1) .. ")")
					end
				end
			elseif string.find(attr, "Agility") then
				if class == "PALADIN" or class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)*2) .. "Armor, -" .. ((v.value - target.value)/20) .. "% Dodge, -"
						.. ((v.value - target.value)/20) .. "% Crit.])")	
					end				
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						round(v.value - target.value,1) .. "Cat AP, -" .. (round(v.value - target.value,1)*2) .. "Armor, -" 
						.. ((v.value - target.value)/20) .. "% Dodge, -" .. ((v.value - target.value)/20) .. "% Crit.])")	
					end			
				elseif class == "WARRIOR" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						round(v.value - target.value,1) .. "RAP, -" .. (round(v.value - target.value,1)*2) .. "Armor, -" 
						.. ((v.value - target.value)/20) .. "% Dodge, -" .. ((v.value - target.value)/20) .. "% Crit.])")	
					end		
				elseif class == "HUNTER" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)*2) .. "RAP, -" .. round(v.value - target.value,1) .. "AP, -" .. 
						(round(v.value - target.value,1)*2) .. "Armor, -" 
						.. ((v.value - target.value)/26) .. "% Dodge, -".. ((v.value - target.value)/53) .. "% Crit.])")	
					end	
				elseif class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						round(v.value - target.value,1) .. "RAP, -" .. round(v.value - target.value,1) .. "AP, -" .. 
						(round(v.value - target.value,1)*2) .. "Armor, -" 
						.. ((v.value - target.value)/14.5) .. "% Dodge, -".. ((v.value - target.value)/29) .. "% Crit.])")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. ")")	
					end
				end
			elseif string.find(attr, "Stamina") then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(target.value - v.value, 1) .. ", [-" .. 
				(round(v.value - target.value, 1)*10) .. "HP.])")
				end
			elseif string.find(attr, "Intellect") then
				if class == "PALADIN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/54) .. "% Spell Crit, -" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "DRUID" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/60) .. "% Spell Crit, -" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/59.5) .. "% Spell Crit, -" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "MAGE" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/59.5) .. "% Spell Crit, -" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "PRIEST" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/59.2) .. "% Spell Crit, -" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif class == "WARLOCK" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/60.6) .. "% Spell Crit, -" .. ((v.value - target.value)*15) .. "MP.])")	
					end	
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. ")")	
					end
				end
			elseif string.find(attr, "Spirit") then -- Again, could figure in troll 10% and other crap somehow, not gonna right now
				if class == "HUNTER" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.25) .." HP Regen]")	
					end
				elseif class == "PALADIN" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.25) .." HP Regen]")	
					end
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/4.5) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.09) .." HP Regen, -" ..
						(round(v.value - target.value,1)/5) .. "MP Regen (cat/bear)]")	
					end
				elseif class == "PRIEST" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/4) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.1) .." HP Regen]")	
					end
				elseif class == "MAGE" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/4) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.1) .." HP Regen]")	
					end
				elseif class == "SHAMAN" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.11) .." HP Regen]")	
					end
				elseif class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value,1)/5) .. "MP Regen, -" .. (round(v.value - target.value, 1)*0.07) .." HP Regen]")	
					end
				elseif class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value, 1)*0.5) .." HP Regen]")	
					end
				elseif class == "WARRIOR" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. "[-" .. 
						(round(v.value - target.value, 1)*0.8) .." HP Regen]")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
					v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(v.value - target.value, 1) .. ")")	
					end 				
				end
			elseif not string.find(attr, "Armor") and not string.find(attr, "Strength") and not string.find(attr, "Agility")
				and not string.find(attr, "Stamina") and not string.find(attr, "Intellect") and not string.find(attr, "Spirit")	 
			then --return end ??
            elseif not v.widget.compSet then
              if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
                v.widget:SetText(v.widget:GetText() .. "|cffff8888 (-" .. round(target.value - v.value, 1) .. ")")
			  end
            end

            target.processed = true
          else
            target.processed = true
			end
          end
        else
          -- this attribute doesnt exist in target
          if v.widget and v.widget:GetText() then
		    if string.find(attr, "Armor") then
				if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
					v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. v.value .. " [+" .. 
					(round(((UnitArmor("player")+(v.value))/((UnitArmor("player")+(v.value))+400+UnitLevel("player")*85)-DR)*10000, 1)/100) .. "%])")
				end
		    elseif string.find(attr, "Strength") then
				if class == "PALADIN" or class == "WARRIOR" or class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)*2) .. "AP, +" .. ((v.value)/20) .. "Block])")	
					end
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)*2) .. "AP]")	
					end
				elseif class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "ROGUE" or class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(v.value) .. "AP]")	
					end 
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
					v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. ")")	
					end 				
				end
		    elseif string.find(attr, "Agility") then
				if class == "PALADIN" or class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)*2) .. "Armor, +" .. ((v.value)/20) .. "% Dodge, +"
						.. ((v.value)/20) .. "% Crit.])")	
					end				
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(v.value) .. "Cat AP, +" .. ((v.value)*2) .. "Armor, +" 
						.. ((v.value)/20) .. "% Dodge, +" .. ((v.value)/20) .. "% Crit.])")	
					end			
				elseif class == "WARRIOR" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(v.value) .. "RAP, +" .. ((v.value)*2) .. "Armor, +" 
						.. ((v.value)/20) .. "% Dodge, +" .. ((v.value)/20) .. "% Crit.])")	
					end		
				elseif class == "HUNTER" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)*2) .. "RAP, +" .. (v.value) .. "AP, +" .. 
						((v.value)*2) .. "Armor, +" 
						.. ((v.value)/26) .. "% Dodge, +".. ((v.value)/53) .. "% Crit.])")	
					end	
				elseif class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(v.value) .. "RAP, +" .. (v.value) .. "AP, +" .. 
						((v.value)*2) .. "Armor, +" 
						.. ((v.value)/14.5) .. "% Dodge, +".. ((v.value)/29) .. "% Crit.])")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "ROGUE" then -- Wowhead didn't have stats for the casters, not significant anyways
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. ")")	
					end
				end
		    elseif string.find(attr, "Stamina") then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. v.value .. ", [+" .. 
						((v.value)*10) .. "HP.])")
					end
		    elseif string.find(attr, "Intellect") then
				if class == "PALADIN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(round(((v.value/54)*100), 1)/100) .. "% Spell Crit, +" .. ((v.value)*15) .. "MP.])")	
					end	
				elseif class == "DRUID" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(round(((v.value/60)*100), 1)/100) .. "% Spell Crit, +" .. ((v.value)*15) .. "MP.])")	
					end	
				elseif class == "SHAMAN" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(round(((v.value/59.5)*100), 1)/100) .. "% Spell Crit, +" .. ((v.value)*15) .. "MP.])")	
					end	
				elseif class == "MAGE" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(round(((v.value/59.5)*100), 1)/100) .. "% Spell Crit, +" .. ((v.value)*15) .. "MP.])")	
					end	
				elseif class == "PRIEST" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(round(((v.value/59.2)*100), 1)/100) .. "% Spell Crit, +" .. ((v.value)*15) .. "MP.])")	
					end	
				elseif class == "WARLOCK" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						(round(((v.value/60.6)*100), 1)/100) .. "% Spell Crit, +" .. ((v.value)*15) .. "MP.])")	
					end	
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. ")")	
					end
				end
		    elseif string.find(attr, "Spirit") then
				if class == "HUNTER" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)/5) .. "MP Regen, +" .. ((v.value)*0.25) .." HP Regen]")	
					end
				elseif class == "PALADIN" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)/5) .. "MP Regen, +" .. ((v.value)*0.25) .." HP Regen]")	
					end
				elseif class == "DRUID" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)/4.5) .. "MP Regen, +" .. ((v.value)*0.09) .. " HP Regen, +" ..
						((v.value)/5) .. "MP Regen (cat/bear)]")	
					end
				elseif class == "PRIEST" or class == "MAGE" then 
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)/4) .. "MP Regen, +" .. ((v.value)*0.1) .." HP Regen]")	
					end
				elseif class == "SHAMAN" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)/5) .. "MP Regen, +" .. ((v.value)*0.11) .. " HP Regen]")	
					end
				elseif class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)/5) .. "MP Regen, +" .. ((v.value)*0.07) .." HP Regen]")	
					end
				elseif class == "ROGUE" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)*0.5) .." HP Regen]")	
					end
				elseif class == "WARRIOR" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. "[+" .. 
						((v.value)*0.8) .." HP Regen]")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. ")")	
					end 				
				end
				elseif not string.find(attr, "Armor") and not string.find(attr, "Strength") and not string.find(attr, "Agility")
				and not string.find(attr, "Stamina") and not string.find(attr, "Intellect") and not string.find(attr, "Spirit")	 
				then
					if not strfind(v.widget:GetText(), "|cff88ff88") and not strfind(v.widget:GetText(), "|cffff8888") then
						v.widget:SetText(v.widget:GetText() .. "|cff88ff88 (+" .. (v.value) .. ")")	
					end 
				end
		end
      end
    end

    for _,target in pairs(targetData) do
      if target and not target.processed then
        -- we are an extra value
		if string.find(_, "Armor") then
				if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
					target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. target.value .. ")")
				end
		elseif string.find(_, "Strength") then
				if class == "PALADIN" or class == "WARRIOR" or class == "SHAMAN" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)*2) .. "AP, +" .. ((target.value)/20) .. "Block])")	
					end
				elseif class == "DRUID" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)*2) .. "AP]")	
					end
				elseif class == "HUNTER" or class == "MAGE" or class == "PRIEST" or class == "ROGUE" or class == "WARLOCK" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(target.value) .. "AP]")	
					end 
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
					target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. ")")	
					end
				end
		elseif string.find(_, "Agility") then
				if class == "PALADIN" or class == "SHAMAN" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)*2) .. "Armor, +" .. ((target.value)/20) .. "% Dodge, +"
						.. ((target.value)/20) .. "% Crit.])")	
					end				
				elseif class == "DRUID" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(target.value) .. "Cat AP, +" .. ((target.value)*2) .. "Armor, +" 
						.. ((target.value - target.value)/20) .. "% Dodge, +" .. ((target.value)/20) .. "% Crit.])")	
					end			
				elseif class == "WARRIOR" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(target.value) .. "RAP, +" .. ((target.value)*2) .. "Armor, +" 
						.. ((target.value)/20) .. "% Dodge, +" .. ((target.value)/20) .. "% Crit.])")	
					end		
				elseif class == "HUNTER" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)*2) .. "RAP, +" .. (target.value) .. "AP, +" .. 
						((target.value)*2) .. "Armor, +" 
						.. ((target.value)/26) .. "% Dodge, +".. ((target.value)/53) .. "% Crit.])")	
					end	
				elseif class == "ROGUE" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(target.value) .. "RAP, +" .. (target.value) .. "AP, +" .. 
						((target.value)*2) .. "Armor, +" 
						.. ((target.value)/14.5) .. "% Dodge, +".. ((target.value)/29) .. "% Crit.])")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "ROGUE" then -- Wowhead didn't have stats for the casters, not significant anyways
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. ")")	
					end
				end
		elseif string.find(_, "Stamina") then
				if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
					target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. target.value .. ", [+" .. 
				((target.value)*10) .. "HP.])")
				end
		elseif string.find(_, "Intellect") then
				if class == "PALADIN" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(round(((v.value/54)*100), 1)/100) .. "% Spell Crit, +" .. ((target.value)*15) .. "MP.])")	
					end	
				elseif class == "DRUID" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(round(((v.value/60)*100), 1)/100) .. "% Spell Crit, +" .. ((target.value)*15) .. "MP.])")	
					end	
				elseif class == "SHAMAN" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(round(((v.value/59.5)*100), 1)/100) .. "% Spell Crit, +" .. ((target.value)*15) .. "MP.])")		
					end	
				elseif class == "MAGE" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(round(((v.value/59.5)*100), 1)/100) .. "% Spell Crit, +" .. ((target.value)*15) .. "MP.])")		
					end	
				elseif class == "PRIEST" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(round(((v.value/59.2)*100), 1)/100) .. "% Spell Crit, +" .. ((target.value)*15) .. "MP.])")		
					end	
				elseif class == "WARLOCK" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						(round(((v.value/60.6)*100), 1)/100) .. "% Spell Crit, +" .. ((target.value)*15) .. "MP.])")		
					end	
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. ")")	
					end
				end
		elseif string.find(_, "Spirit") then
				if class == "HUNTER" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)/5) .. "MP Regen, +" .. ((target.value)*0.25) .." HP Regen]")	
					end
				elseif class == "PALADIN" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)/5) .. "MP Regen, +" .. ((target.value)*0.25) .." HP Regen]")	
					end
				elseif class == "DRUID" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)/4.5) .. "MP Regen, +" .. ((target.value)*0.09) .. " HP Regen, +" ..
						((target.value)/5) .. "MP Regen (cat/bear)]")	
					end
				elseif class == "PRIEST" or class == "MAGE" then 
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)/4) .. "MP Regen, +" .. ((target.value)*0.1) .." HP Regen]")	
					end
				elseif class == "SHAMAN" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)/5) .. "MP Regen, +" .. ((target.value)*0.11) .." HP Regen]")	
					end
				elseif class == "WARLOCK" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)/5) .. "MP Regen, +" .. ((target.value)*0.07) .." HP Regen]")	
					end
				elseif class == "ROGUE" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)*0.5) .." HP Regen]")	
					end
				elseif class == "WARRIOR" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
						target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. "[+" .. 
						((target.value)*0.8) .." HP Regen]")	
					end
				elseif not class == "PALADIN" and not class == "WARRIOR" and not class == "SHAMAN" and not class == "DRUID"
				and not class == "HUNTER" and not class == "MAGE" and not class == "PRIEST" and not class == "ROGUE" and not class == "WARLOCK" then
					if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
					target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. (target.value) .. ")")	
					end 				
				end
		elseif not string.find(_, "Armor") and not string.find(_, "Strength") and not string.find(_, "Agility")
				and not string.find(_, "Stamina") and not string.find(_, "Intellect") and not string.find(_, "Spirit")	 
			then --return end ??
            elseif not target.widget.compSet then
              if not strfind(target.widget:GetText(), "|cff88ff88") and not strfind(target.widget:GetText(), "|cffff8888") then
                target.widget:SetText(target.widget:GetText() .. "|cff88ff88 (+" .. round(target.value) .. ")")
			  end
            end
		end
      end
    end
  end

  pfUI.eqcompare = {}
  pfUI.eqcompare.GameTooltipShow = function()
    -- use this tooltip for the next comparison
    pfUI.eqcompare.tooltip = this

    if not IsShiftKeyDown() and C.tooltip.compare.showalways ~= "1" then return end
    local rawborder, border = GetBorderSize()

    for i=1,this:NumLines() do
      local tmpText = _G[this:GetName() .. "TextLeft"..i]
      for slotType, slotName in pairs(slotTable) do
        if tmpText:GetText() == slotType then
          local slotID = GetInventorySlotInfo(slotTable[slotType])

          -- determine screen part
          local ltrigger = GetScreenWidth() / 2
          local x = GetCursorPosition()
          x = x / UIParent:GetEffectiveScale()
          if x > ltrigger then ltrigger = nil end

          -- first tooltip
          ShoppingTooltip1:SetOwner(this, "ANCHOR_NONE")
          ShoppingTooltip1:ClearAllPoints()

          if ltrigger then
            ShoppingTooltip1:SetPoint("BOTTOMLEFT", this, "BOTTOMRIGHT", 0, 0)
          else
            ShoppingTooltip1:SetPoint("BOTTOMRIGHT", this, "BOTTOMLEFT", -border*2-1, 0)
          end

          ShoppingTooltip1:SetInventoryItem("player", slotID)
          ShoppingTooltip1:Show()

          -- second tooltip
          if slotTable[slotType .. "_other"] then
            local slotID_other = GetInventorySlotInfo(slotTable[slotType .. "_other"])

            ShoppingTooltip2:SetOwner(this, "ANCHOR_NONE")
            ShoppingTooltip2:ClearAllPoints()

            if ltrigger then
              ShoppingTooltip2:SetPoint("BOTTOMLEFT", ShoppingTooltip1, "BOTTOMRIGHT", 0, 0)
            else
              ShoppingTooltip2:SetPoint("BOTTOMRIGHT", ShoppingTooltip1, "BOTTOMLEFT", -border*2-1, 0)
            end

            ShoppingTooltip2:SetInventoryItem("player", slotID_other)
            ShoppingTooltip2:Show()
          end
          return true
        end
      end
    end
  end

  -- add HookScript method if not already existing
  GameTooltip.HookScript = GameTooltip.HookScript or HookScript
  ShoppingTooltip1.HookScript = ShoppingTooltip1.HookScript or HookScript
  ShoppingTooltip2.HookScript = ShoppingTooltip2.HookScript or HookScript

  pfUI.eqcompare.ShoppingTooltipShow = function()
    -- abort if no comparison tooltip has been set
    if not pfUI.eqcompare.tooltip then return end

    ExtractAttributes(this)
    ExtractAttributes(pfUI.eqcompare.tooltip)
    CompareAttributes(pfUI.eqcompare.tooltip.pfCompData, this.pfCompData)
  end

  -- Add Gametooltip Hooks
  GameTooltip:HookScript("OnShow", pfUI.eqcompare.GameTooltipShow)
  if C.tooltip.compare.basestats == "1" then
    ShoppingTooltip1:HookScript("OnShow", pfUI.eqcompare.ShoppingTooltipShow)
    ShoppingTooltip2:HookScript("OnShow", pfUI.eqcompare.ShoppingTooltipShow)
  end
end)
