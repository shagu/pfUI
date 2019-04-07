pfUI:RegisterModule("skin", function ()
  -- align UIParent panels
  pfUI.panelalign = CreateFrame("Frame", "pfUIParentPanelAlign", UIParent)
  pfUI.panelalign:SetScript("OnUpdate", function()
    local left = UIParent.left
    local center = UIParent.center

    -- detect outer frame backdrops
    if left and not left.rightObj then
      left.rightObj = left.backdrop or left
      for _, frame in pairs({left:GetChildren()}) do
        if frame.backdrop and frame.backdrop.GetRight and frame.backdrop:GetRight() > left.rightObj:GetRight() then
          left.rightObj = frame.backdrop
        end
      end
    end

    -- reset anchors
    if not left or not left:IsShown() or not center or not center:IsShown() then
      UIParent.pfLeftAligned = nil
      return
    elseif center and center:IsShown() and left and left:IsShown() then
      local width = left.rightObj:GetRight()
      if width ~= UIParent.pfLeftAligned then
        center:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", width + 10, -104)
        UIParent.pfLeftAligned = width
      end
    end
  end)

  -- durability frame
  pfUI.durability = CreateFrame("Frame", "pfDurability", UIParent)
  if pfUI.minimap then
    pfUI.durability:SetPoint("TOPLEFT", pfUI.minimap, "BOTTOMLEFT", 0, -35)
  else
    pfUI.durability:SetPoint("LEFT", UIParent, "RIGHT", -120, 120)
  end
  UpdateMovable(pfUI.durability)
  pfUI.durability:SetWidth(80)
  pfUI.durability:SetHeight(70)
  pfUI.durability:SetFrameStrata("BACKGROUND")
  DurabilityFrame:SetParent(pfUI.durability)
  DurabilityFrame:SetAllPoints(pfUI.durability)
  DurabilityFrame:SetFrameLevel(1)
  DurabilityFrame.SetPoint = function() return end

  if C.appearance.cd.blizzard == "1" then
    hooksecurefunc("PaperDollItemSlotButton_Update", function()
        local cooldown = _G[this:GetName().."Cooldown"]
        if cooldown then cooldown.pfCooldownType = "ALL" end
    end)

    hooksecurefunc("SpellButton_UpdateButton", function()
      local cooldown = _G[this:GetName().."Cooldown"]
      if cooldown then cooldown.pfCooldownType = "ALL" end
    end)
  end

  local boxes = {
    "DropDownList1MenuBackdrop",
    "DropDownList2MenuBackdrop",
    "DropDownList1Backdrop",
    "DropDownList2Backdrop",
  }

  for _, box in pairs(boxes) do
    local b = _G[box]
    CreateBackdrop(b, nil, true, .8)
  end

  if C.global.errors_limit == "1" then
    UIErrorsFrame:SetHeight(25)
  end

  if C.global.errors_hide == "1" then
    UIErrorsFrame:Hide()
  end
end)
