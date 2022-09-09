-- adds class colored circles on world and battlefield map
pfUI:RegisterModule("mapcolors", function ()
  pfUI.mapcolors = CreateFrame("Frame", nil, UIParent)
  pfUI.mapcolors:SetScript("OnUpdate", function()
    -- throttle to to one item per .1 second
    if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .1 end

    local frame, icon

    -- initialize all button names
    if not this.buttons then
      this.buttons = {}

      for i = 1, 4 do
        icon = string.format("WorldMapParty%d", i)
        this.buttons[icon] = string.format("party%d", i)
      end

      for i = 1, 4 do
        icon = string.format("BattlefieldMinimapParty%d", i)
        this.buttons[icon] = string.format("party%d", i)
      end

      for i = 1, 40 do
        icon = string.format("BattlefieldMinimapRaid%d", i)
        this.buttons[icon] = string.format("raid%d", i)
      end

      for i = 1, 40 do
        icon = string.format("WorldMapRaid%d", i)
        this.buttons[icon] = string.format("raid%d", i)
      end
    end

    -- update all available buttons
    local ingroup
    for name, unitstr in pairs(this.buttons) do
      frame = _G[name]

      if frame and UnitExists(unitstr) then
        icon = _G[name.."Icon"]
        icon:SetTexture()

        -- create icon if not yet existing
        if not frame.pfIcon then
          frame.pfIcon = frame:CreateTexture(nil, "OVERLAY")
          SetAllPointsOffset(frame.pfIcon, frame, this.size, -this.size)
        end

        -- check if unit is in same group
        ingroup = nil
        for i=1,5 do -- check if unit is in group
          if UnitName(string.format("party%d", i)) == UnitName(unitstr) then
            ingroup = true
          end
        end

        -- update texture according to raid/group state
        if ingroup and frame.pfIcon.ingroup ~= "PARTY" then
          frame.pfIcon:SetTexture(pfUI.media["img:circleparty"])
          frame.pfIcon.ingroup = "PARTY"
        elseif not ingroup and frame.pfIcon.ingroup ~= "RAID" then
          frame.pfIcon:SetTexture(pfUI.media["img:circleraid"])
          frame.pfIcon.ingroup = "RAID"
        end

        -- detect unit class and set color
        local _, class = UnitClass(unitstr)
        local color = RAID_CLASS_COLORS[class]
        if color then
          frame.pfIcon:SetVertexColor(color.r, color.g, color.b)
        else
          frame.pfIcon:SetVertexColor(.5,1,.5)
        end
      end
    end
  end)

  pfUI.mapcolors.UpdateConfig = function()
    pfUI.mapcolors.size = tonumber(C.appearance.worldmap.groupcircles)

    if not pfUI.mapcolors.buttons then return end
    for name, unitstr in pairs(pfUI.mapcolors.buttons) do
      frame = _G[name]

      if frame and frame.pfIcon then
        SetAllPointsOffset(frame.pfIcon, frame, pfUI.mapcolors.size, -pfUI.mapcolors.size)
      end
    end
  end

  pfUI.mapcolors:UpdateConfig()
end)
