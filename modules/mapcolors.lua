-- adds class colored circles on world and battlefield map
pfUI:RegisterModule("mapcolors", function ()
  local function Initialize(unit_button_name)
    local texture_size = tonumber(C.appearance.worldmap.groupcircles)
    for i=1, MAX_PARTY_MEMBERS do
      local frame = _G[unit_button_name.."Party"..i]
      frame.icon = _G[unit_button_name.."Party"..i.."Icon"]
      frame.icon:SetTexture(pfUI.media["img:circleparty"])
      frame.icon:SetVertexColor(.5, 1, .5)
      SetAllPointsOffset(frame.icon, frame, texture_size, -texture_size)
    end
    for i=1, MAX_RAID_MEMBERS do
      local frame = _G[unit_button_name.."Raid"..i]
      frame.icon = _G[unit_button_name.."Raid"..i.."Icon"]
      frame.icon:SetTexture(pfUI.media["img:circleraid"])
      frame.icon:SetVertexColor(.5, 1, .5)
      SetAllPointsOffset(frame.icon, frame, texture_size, -texture_size)
    end
  end
  local function UpdateTexture(frame)
    if UnitInParty(frame.unit) then
      frame.icon:SetTexture(pfUI.media["img:circleparty"])
    else
      frame.icon:SetTexture(pfUI.media["img:circleraid"])
    end
  end
  local function UpdateTextureColor(frame)
    if UnitExists(frame.unit) then
      local _, class = UnitClass(frame.unit)
      local color = RAID_CLASS_COLORS[class]
      frame.icon:SetVertexColor(color.r, color.g, color.b)
    else
      frame.icon:SetVertexColor(.5, 1, .5)
    end
  end
  local function UpdateUnitFrames(unit_button_name)
    if GetNumRaidMembers() > 0 then
      for i=1, MAX_RAID_MEMBERS do
        local frame = _G[unit_button_name.."Raid"..i]
        UpdateTexture(frame)
        UpdateTextureColor(frame)
      end
    elseif GetNumPartyMembers() > 0 then
      for i=1, MAX_PARTY_MEMBERS do
        local frame = _G[unit_button_name.."Party"..i]
        UpdateTextureColor(frame)
      end
    end
  end
  local function ColorizeName(frame)
    local _, class = UnitClass(frame.unit)
    local color = RAID_CLASS_COLORS[class]
    frame.name = frame.name or UnitName(frame.unit)
    frame.name = '|c'..color.colorStr..frame.name..'|r'
  end
  local function UpdateUnitColors(unit_button_name, tooltip)
    local tooltipText = ""
    if unit_button_name == 'WorldMap' then
      -- Check player
      if MouseIsOver(WorldMapPlayer) then
        ColorizeName(WorldMapPlayer)
        tooltipText = WorldMapPlayer.name
      end
    end
    -- Check party
    for i=1, MAX_PARTY_MEMBERS do
      local frame = _G[unit_button_name.."Party"..i]
      if frame:IsVisible() and MouseIsOver(frame) then
        ColorizeName(frame)
        tooltipText = tooltipText.."\n"..frame.name
      end
    end
    --Check Raid
    for i=1, MAX_RAID_MEMBERS do
      local frame = _G[unit_button_name.."Raid"..i]
      if frame:IsVisible() and MouseIsOver(frame) then
        ColorizeName(frame)
        tooltipText = tooltipText.."\n"..frame.name
      end
    end
    tooltip:SetText(tooltipText)
    tooltip:Show()
  end

  -- WorldMap
  Initialize('WorldMap')
  hooksecurefunc('WorldMapButton_OnUpdate', function()
    UpdateUnitFrames('WorldMap')
  end)
  if C.appearance.worldmap.colornames == "1" then
    hooksecurefunc('WorldMapUnit_OnEnter', function()
      UpdateUnitColors('WorldMap', WorldMapTooltip)
    end)
  end
  -- BattlefieldMinimap
  HookAddonOrVariable("Blizzard_BattlefieldMinimap", function()
    Initialize('BattlefieldMinimap')
    hooksecurefunc('BattlefieldMinimap_OnUpdate', function()
      UpdateUnitFrames('BattlefieldMinimap')
    end)
    if C.appearance.worldmap.colornames == "1" then
      hooksecurefunc('BattlefieldMinimapUnit_OnEnter', function()
        UpdateUnitColors('BattlefieldMinimap', GameTooltip)
      end)
    end
  end)
end)
