SLASH_RELOAD1 = '/rl'; -- 3.
function SlashCmdList.RELOAD(msg, editbox) -- 4.
  ReloadUI()
end

pfUI = CreateFrame("Frame",nil,UIParent)
pfUI.backdrop = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\bg", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border", edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

pfUI.backdrop_gitter = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\gitter", tile = true, tileSize = 8,
}

pfUI.backdrop_col = {
  bgFile = "Interface\\AddOns\\pfUI\\img\\bg", tile = true, tileSize = 8,
  edgeFile = "Interface\\AddOns\\pfUI\\img\\border_col", edgeSize = 8,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

pfUI.playerDB = {}

pfUI.config = {
  ["unitframes"] = {
    animation_speed = 1,
    buff_size = "22",
    debuff_size = "22",
    layout = "default",
    width = 200,
    height = 50,
    pheight = 10,
  },
  ["bars"] = {
    icon_size = "22",
    border = 2,
  }
}

function moveit()
  -- don't call it "grid" to avoid confusion with grid (addon) module
  pfUI.gitter = CreateFrame("Frame", nil, UIParent)
  pfUI.gitter:SetFrameStrata("BACKGROUND")
  pfUI.gitter:SetPoint("TOPLEFT", 0, 0, "TOPLEFT")
  pfUI.gitter:SetPoint("BOTTOMRIGHT", 0, 0, "BOTTOMRIGHT")
  pfUI.gitter:SetBackdrop(pfUI.backdrop_gitter)
  pfUI.gitter:SetBackdropColor(0,0,0,1)

  local movable = { pfUI.minimap, pfUI.chat.left, pfUI.chat.right,
    pfUI.uf.player, pfUI.uf.target, pfUI.uf.targettarget, pfUI.uf.pet,
    pfUI.bars.shapeshift, pfUI.bars.bottomleft, pfUI.bars.bottomright,
    pfUI.bars.vertical, pfUI.bars.pet, pfUI.bars.bottom }

  for _,frame in pairs(movable) do
    local frame = frame
    frame:Show()
    frame:SetMovable(true)

    frame.drag = CreateFrame("Frame", nil, frame)
    frame.drag:SetAllPoints(frame)
    frame.drag:SetFrameStrata("DIALOG")
    frame.drag.bg = frame.drag:CreateTexture()
    frame.drag.bg:SetAllPoints(frame.drag)
    frame.drag.bg:SetTexture(.2,1,.8,1)
    frame.drag:SetAlpha(.25)
    frame.drag:EnableMouse(true)

    frame.drag:SetScript("OnMouseDown",function()
        frame:StartMoving()
      end)

    frame.drag:SetScript("OnMouseUp",function()
        frame:StopMovingOrSizing()
      end)
  end
end

pfUI.cache = CreateFrame("Frame",nil,UIParent)
pfUI.cache:RegisterEvent("PLAYER_ENTERING_WORLD")
pfUI.cache:SetScript("OnEvent", function()
    _, class = UnitClass("player")
    local color = RAID_CLASS_COLORS[class]
    pfUI.cache.class_r, pfUI.cache.class_g, pfUI.cache.class_b = (color.r + .5) * .5, (color.g + .5) * .5, (color.b + .5) * .5

  end)

message = function (msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55"..msg)
end

ScriptErrors:SetScript("OnShow", function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcc3333ERROR: |cffff5555"..ScriptErrors_Message:GetText())
    ScriptErrors:Hide()
  end)

pfUI.uf = CreateFrame("Frame",nil,UIParent)
