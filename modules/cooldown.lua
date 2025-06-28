pfUI:RegisterModule("cooldown", "vanilla:tbc", function ()
  -- cache values
  local lowcolor    = {strsplit(",", C.appearance.cd.lowcolor)}
  local normalcolor = {strsplit(",", C.appearance.cd.normalcolor)}
  local minutecolor = {strsplit(",", C.appearance.cd.minutecolor)}
  local hourcolor   = {strsplit(",", C.appearance.cd.hourcolor)}
  local daycolor    = {strsplit(",", C.appearance.cd.daycolor)}

  local parent, parent_name
  local function pfCooldownOnUpdate()
    parent = this:GetParent()
    if not parent then this:Hide() end
    parent_name = parent:GetName()

    -- avoid to set cooldowns on invalid frames
    if parent_name and _G[parent_name .. "Cooldown"] then
      if not _G[parent_name .. "Cooldown"]:IsShown() then
        this:Hide()
      end
    end

    -- only run every 0.1 seconds from here on
    if ( this.tick or .1) > GetTime() then return else this.tick = GetTime() + .1 end

    -- fix own alpha value (should be inherited, but somehow isn't always)
    if this:GetAlpha() ~= parent:GetAlpha() then
      this:SetAlpha(parent:GetAlpha())
    end

    if this.start < GetTime() then
      -- calculating remaining time as it should be
      local remaining = this.duration - (GetTime() - this.start)
      if remaining >= 0 then
        this.text:SetText(GetColoredTimeString(remaining))
      else
        this:Hide()
      end
    else
      -- I have absolutely no idea, but it works:
      -- https://github.com/Stanzilla/WoWUIBugs/issues/47
      local time = time()
      local startupTime = time - GetTime()
      -- just a simplification of: ((2^32) - (start * 1000)) / 1000
      local cdTime = (2 ^ 32) / 1000 - this.start
      local cdStartTime = startupTime - cdTime
      local cdEndTime = cdStartTime + this.duration
      local remaining = cdEndTime - time

      if remaining >= 0 then
        this.text:SetText(GetColoredTimeString(remaining))
      else
        this:Hide()
      end
    end
  end

  local height, size
  local function pfCreateCoolDown(cooldown, start, duration)
    cooldown.pfCooldownText = CreateFrame("Frame", "pfCooldownFrame", cooldown:GetParent())
    cooldown.pfCooldownText:SetAllPoints(cooldown)
    cooldown.pfCooldownText:SetFrameLevel(cooldown:GetParent():GetFrameLevel() + 2)
    cooldown.pfCooldownText.text = cooldown.pfCooldownText:CreateFontString("pfCooldownFrameText", "OVERLAY")

    if not cooldown.pfCooldownType then
      size = tonumber(C.appearance.cd.font_size_foreign)
    elseif cooldown.pfCooldownType == "BLIZZARD" then
      size = tonumber(C.appearance.cd.font_size_blizz)
    elseif cooldown.pfCooldownSize then
      size = tonumber(cooldown.pfCooldownSize)
    else
      size = tonumber(C.appearance.cd.font_size)
    end

    -- enforce dynamic font size
    if C.appearance.cd.dynamicsize == "1" and cooldown.GetParent then
      height = cooldown:GetParent() and cooldown:GetParent():GetHeight() or cooldown:GetHeight() or 0
      size = math.max((height > 0 and height * .64 or 16), size)
    end

    cooldown.pfCooldownText.text:SetFont(pfUI.media[C.appearance.cd.font], size, "OUTLINE")
    cooldown.pfCooldownText.text:SetPoint("CENTER", cooldown.pfCooldownText, "CENTER", 0, 0)
    cooldown.pfCooldownText:SetScript("OnUpdate", pfCooldownOnUpdate)
  end

  -- hook
  local function SetCooldown(this, start, duration, enable)
    -- abort on unknown frames
    if C.appearance.cd.foreign == "0" and not this.pfCooldownType then
      return
    end

    -- add support for omnicc's disable flag
    if this.noCooldownCount then
      return
    end

    -- realign cooldown frames
    local parent = this.GetParent and this:GetParent()
    if parent and parent:GetWidth() / 36 > 0 then
      this:SetScale(parent:GetWidth() / 36)
      this:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
      this:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
    end

    -- don't draw global cooldowns
    if this.pfCooldownType == "NOGCD" and duration < tonumber(C.appearance.cd.threshold) then
      start, duration = 0, 0
    end

    -- disable GCDs on non pfUI frames
    if not this.pfCooldownType and duration < tonumber(C.appearance.cd.threshold) then
      start, duration = 0, 0
    end

    -- hide animation
    if this.pfCooldownStyleAnimation == 0 then
      this:SetAlpha(0)
    elseif not this.pfCooldownStyleAnimation and C.appearance.cd.hideanim == "1" then
      this:SetAlpha(0)
    end

    -- print time as text on cooldown frames
    if ( not this.pfCooldownStyleText or this.pfCooldownStyleText == 1)
    and start > 0 and duration > 0 and (not enable or enable > 0) then
      if( not this.pfCooldownText ) then
        pfCreateCoolDown(this, start, duration)
      end

      this.pfCooldownText.start = start
      this.pfCooldownText.duration = duration
      this.pfCooldownText:Show()
    elseif(this.pfCooldownText) then
      this.pfCooldownText:Hide()
    end
  end

  if pfUI.expansion == "vanilla" then
    -- vanilla does not have a cooldown frame type, so we hook the
    -- regular SetTimer function that each one is calling.
    hooksecurefunc("CooldownFrame_SetTimer", SetCooldown)
  else
    -- tbc and later expansion have a cooldown frametype, so we can
    -- hook directly into the frame creation and add our function there.
    local methods = getmetatable(CreateFrame('Cooldown', nil, nil, 'CooldownFrameTemplate')).__index
    hooksecurefunc(methods, 'SetCooldown', SetCooldown)
  end
end)
