pfUI:RegisterModule("mapreveal", "vanilla:tbc", function ()
  -- do not load if other map addon is loaded
  if Cartographer then return end
  if METAMAP_TITLE then return end

  pfUI.mapreveal = {}
  function pfUI.mapreveal:UpdateConfig()
    WorldMapFrame_Update()
  end

  pfUI.mapreveal.onmap = CreateFrame("CheckButton", "pfUI_mapreveal_onmap", WorldMapFrame, "UICheckButtonTemplate")
  pfUI.mapreveal.onmap:SetNormalTexture("")
  pfUI.mapreveal.onmap:SetPushedTexture("")
  pfUI.mapreveal.onmap:SetHighlightTexture("")
  pfUI.mapreveal.onmap.text = _G["pfUI_mapreveal_onmapText"]
  CreateBackdrop(pfUI.mapreveal.onmap, nil, true)
  pfUI.mapreveal.onmap:SetWidth(14)
  pfUI.mapreveal.onmap:SetHeight(14)
  pfUI.mapreveal.onmap:SetPoint("LEFT", WorldMapZoomOutButton, "RIGHT", 20, 0)
  pfUI.mapreveal.onmap.text:SetPoint("LEFT", pfUI.mapreveal.onmap, "RIGHT", 2, 0)
  pfUI.mapreveal.onmap.text:SetText(T["Reveal Unexplored Areas"])
  pfUI.mapreveal.onmap:SetScript("OnShow", function()
    this:SetChecked(C.appearance.worldmap.mapreveal == "1")
  end)
  pfUI.mapreveal.onmap:SetScript("OnClick", function ()
    if this:GetChecked() then
      C.appearance.worldmap.mapreveal = "1"
    else
      C.appearance.worldmap.mapreveal = "0"
    end
    pfUI.mapreveal:UpdateConfig()
  end)

  local overlayData = setmetatable(pfMapOverlayData, {__index = function(t,k)
    local v = {}
    rawset(t,k,v)
    return v
  end})

  local errata = {
    ["Interface\\WorldMap\\Tirisfal\\BRIGHTWATERLAKE"] = {offsetX={587,584}},
    ["Interface\\WorldMap\\Silverpine\\BERENSPERIL"] = {offsetY={417,415}},
  }

  local function create_hash(prefix, textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY)
    local hash = string.format(":%s:%s:%s:%s",textureWidth,textureHeight,offsetX,offsetY)
    if (mapPointX ~= 0 or mapPointY ~= 0) then
      hash = string.format("%s:%s:%s",hash,tostring(mapPointX),tostring(mapPointY))
    end
    if string.sub(textureName, 0, string.len(prefix)) == prefix then
      return string.format("%s%s",string.sub(textureName, string.len(prefix) + 1),hash)
    end
    return string.format("|%s",hash)
  end

  local function unpack_hash(prefix, hash)
    local _, stored_prefix, textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY
    _, _, stored_prefix, textureName, textureWidth, textureHeight, offsetX, offsetY = string.find(hash, "^([|]?)([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)")
    if (not textureName or not offsetY) then
      return
    end
    if (offsetY) then
      _, _, mapPointX, mapPointY = string.find(hash,"^[|]?[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:([^:]+):([^:]+)")
    end
    if (not mapPointY) then
      mapPointX = 0 mapPointY = 0
    end
    if (stored_prefix ~= "|") then
      textureName = string.format("%s%s",prefix,textureName)
    end
    -- coerce to number by addition; cheaper than tonumber()
    return textureName, textureWidth + 0, textureHeight + 0, offsetX + 0, offsetY + 0, mapPointX + 0, mapPointY + 0
  end

  local function pfWorldMapFrame_Update()
    local r,g,b,a = GetStringColor(C.appearance.worldmap.mapreveal_color)
    local mapFileName, textureHeight, textureWidth = GetMapInfo()

    if (not mapFileName) then mapFileName = "World" end

    local prefix = string.format("Interface\\WorldMap\\%s\\",mapFileName)
    local numOverlays = GetNumMapOverlays()

    local alreadyknown = {}
    for i=1, numOverlays do
      local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i)
      local overlayHash = create_hash(textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY)
      alreadyknown[textureName] = overlayHash
    end

    local zoneData = overlayData[mapFileName]
    local textureCount = 0
    local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
    for i, hash in ipairs(zoneData) do
      local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = unpack_hash(prefix, hash)
      if C.appearance.worldmap.mapreveal == "1" or alreadyknown[textureName] then
        if errata[textureName] and errata[textureName].offsetX and errata[textureName].offsetX[1] == offsetX then
          offsetX = errata[textureName].offsetX[2]
        end
        if errata[textureName] and errata[textureName].offsetY and errata[textureName].offsetY[1] == offsetY then
          offsetY = errata[textureName].offsetY[2]
        end
        local numTexturesHorz = math.ceil(textureWidth / 256)
        local numTexturesVert = math.ceil(textureHeight / 256)
        local neededTextures = textureCount + (numTexturesHorz * numTexturesVert)
        local texture, texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
        if (neededTextures > NUM_WORLDMAP_OVERLAYS) then
          for j = NUM_WORLDMAP_OVERLAYS + 1, neededTextures do
            _G.WorldMapDetailFrame:CreateTexture(string.format("%s%s","WorldMapOverlay",j), "ARTWORK")
          end
          NUM_WORLDMAP_OVERLAYS = neededTextures
        end
        for j = 1, numTexturesVert do
          if (j < numTexturesVert) then
            texturePixelHeight,textureFileHeight = 256,256
          else
            texturePixelHeight = mod(textureHeight, 256)
            if (texturePixelHeight == 0) then texturePixelHeight = 256 end
            textureFileHeight = 16
            while (textureFileHeight < texturePixelHeight) do
              textureFileHeight = textureFileHeight * 2
            end
          end
          for k = 1, numTexturesHorz do
            if (textureCount > NUM_WORLDMAP_OVERLAYS) then
              return
            end
            texture = _G[string.format("%s%s","WorldMapOverlay",(textureCount + 1))]
            if (k < numTexturesHorz) then
              texturePixelWidth, textureFileWidth = 256,256
            else
              texturePixelWidth = mod(textureWidth, 256)
              if (texturePixelWidth == 0) then texturePixelWidth = 256 end
              textureFileWidth = 16
              while (textureFileWidth < texturePixelWidth) do
                textureFileWidth = textureFileWidth * 2
              end
            end
            texture:SetWidth(texturePixelWidth)
            texture:SetHeight(texturePixelHeight)
            texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
            texture:ClearAllPoints()
            texture:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", offsetX + (256 *(k - 1)), -(offsetY +(256 *(j - 1))))
            texture:SetTexture(string.format("%s%s",textureName,(((j - 1) * numTexturesHorz) + k)))

            if not alreadyknown[textureName] then
              texture:SetVertexColor(r,g,b,a)
            else
              texture:SetVertexColor(1,1,1,1)
            end
            texture:Show()
            textureCount = textureCount + 1
          end
        end
      end
    end
    for i = textureCount + 1, NUM_WORLDMAP_OVERLAYS do
      _G[string.format("%s%s","WorldMapOverlay",i)]:Hide()
    end
  end

  hooksecurefunc("WorldMapFrame_Update", pfWorldMapFrame_Update, true)
end)
