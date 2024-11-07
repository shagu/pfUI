pfUI:RegisterModule("farmmode", "vanilla:tbc", function ()
  local function ToggleFarmMode()
    if pfUI.farmmap:IsShown() then
      pfUI.farmmap:Hide()
    else
      pfUI.farmmap:Show()
    end
  end

  local function MoveNodes(layer)
    -- pfMap entries (pfQuest / pfDB)
    if pfMap and pfMap.drawlayer then
      pfMap.drawlayer = layer
      for id, pin in pairs(pfMap.mpins) do
        pin:SetParent(layer)
      end
      pfMap:UpdateMinimap()
    end
  end

  local function UpdateMinimap()
    -- haven't found anything better to
    -- force update the map textures
    Minimap_ZoomIn()
    Minimap_ZoomOut()
  end

  _G.SLASH_PFFARMMAP1, _G.SLASH_PFFARMMAP2 = "/farm", "/farmmode"
  _G.SlashCmdList.PFFARMMAP = ToggleFarmMode

  pfUI.farmmap = CreateFrame("Minimap", "pfFarmMap", UIParent)
  pfUI.farmmap:Hide()
  pfUI.farmmap:SetFrameStrata("LOW")
  pfUI.farmmap:SetWidth(300)
  pfUI.farmmap:SetHeight(300)
  pfUI.farmmap:SetClampedToScreen(1)
  pfUI.farmmap:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -200)
  pfUI.farmmap:SetAlpha(.8)
  pfUI.farmmap:SetMovable(1)
  pfUI.farmmap:EnableMouse(1)
  pfUI.farmmap:EnableMouseWheel(1)
  pfUI.farmmap:RegisterForDrag("LeftButton")
  pfUI.farmmap:SetScript("OnMouseWheel", function()
    if IsControlKeyDown() then
      this:SetWidth(this:GetWidth() + (arg1 > 0 and 10 or -10))
      this:SetHeight(this:GetHeight() + (arg1 > 0 and 10 or -10))
      Minimap_ZoomIn()
      Minimap_ZoomOut()
    elseif IsShiftKeyDown() then
      this:SetAlpha(this:GetAlpha() + (arg1 > 0 and 0.1 or (this:GetAlpha() > 0.1 and -0.1 or 0)))
      SaveMovable(this)
    else
      if(arg1 > 0) then Minimap_ZoomIn() else Minimap_ZoomOut() end
    end
  end)

  pfUI.farmmap:SetScript("OnDragStart", function()
    this:StartMoving()
  end)

  pfUI.farmmap:SetScript("OnDragStop",  function()
    this:StopMovingOrSizing()
    SaveMovable(this)
  end)

  pfUI.farmmap:SetScript("OnUpdate", function()
    if not Minimap:IsShown() then return end

    Minimap:Hide()

    -- move existing nodes to new minimap
    MoveNodes(pfUI.farmmap)

    -- move tracking frame
    if pfUI.tracking then
      pfUI.tracking:ClearAllPoints()
      pfUI.tracking:SetPoint("TOPLEFT", pfUI.farmmap, -10, -10)
    end

    -- move pvp icon
    if pfUI.minimap and pfUI.minimap.pvpicon then
      pfUI.minimap.pvpicon:ClearAllPoints()
      pfUI.minimap.pvpicon:SetPoint("BOTTOMRIGHT", pfUI.farmmap, "BOTTOMRIGHT", -5, 5)
    end

    -- save old minimap height
    if pfUI.minimap then
      this.mmoldsize = pfUI.minimap:GetHeight()
      pfUI.minimap:SetHeight(16)
      pfUI.minimap:SetAlpha(1)
      pfUI.farmmap.button:Show()
    end

    -- refresh minimap content
    UpdateMinimap()
  end)

  pfUI.farmmap:SetScript("OnHide", function()
    ShowUIPanel(Minimap)

    -- move existing nodes to new minimap
    MoveNodes(Minimap)

    -- move tracking frame
    if pfUI.tracking then
      pfUI.tracking:ClearAllPoints()
      pfUI.tracking:SetPoint("TOPLEFT", pfUI.minimap or Minimap, -10, -10)
      UpdateMovable(pfUI.tracking)
    end

    -- move pvp icon
    if pfUI.minimap and pfUI.minimap.pvpicon then
      pfUI.minimap.pvpicon:ClearAllPoints()
      pfUI.minimap.pvpicon:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", -5, 5)
    end

    -- save old minimap height
    if pfUI.minimap then
      pfUI.minimap:SetHeight(this.mmoldsize)
      pfUI.minimap:SetAlpha(1)
      pfUI.farmmap.button:Hide()
    end

    -- refresh minimap content
    UpdateMinimap()
  end)

  if pfUI.minimap then
    pfUI.farmmap.button = CreateFrame("Button", "pfFarmMapButton", pfUI.minimap)
    pfUI.farmmap.button:Hide()
    pfUI.farmmap.button:SetPoint("TOPLEFT", pfUI.minimap, "TOPLEFT", 0, 0)
    pfUI.farmmap.button:SetPoint("BOTTOMRIGHT", pfUI.minimap, "BOTTOMRIGHT", 0, 0)
    pfUI.farmmap.button:SetFrameStrata("MEDIUM")
    pfUI.farmmap.button:SetScript("OnClick", ToggleFarmMode)

    pfUI.farmmap.button.txt = pfUI.farmmap.button:CreateFontString("pfFarmMapText", "LOW", "GameFontWhite")
    pfUI.farmmap.button.txt:SetFont(pfUI.font_default, C.global.font_size, "OUTLINE")
    pfUI.farmmap.button.txt:SetPoint("CENTER", 0, 0)
    pfUI.farmmap.button.txt:SetText("|cff33ffcc FARM MODE")
  end

  CreateBackdrop(pfUI.farmmap)
  LoadMovable(pfUI.farmmap)
end)
