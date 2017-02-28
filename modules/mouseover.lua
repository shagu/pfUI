pfUI:RegisterModule("mouseover", function ()
  pfUI.uf.mouseover = CreateFrame("Frame", "pfMouseOver", UIParent)

  _G.SLASH_PFCAST1, _G.SLASH_LPFCAST2 = "/pfcast", "/pfmouse"
  function SlashCmdList.PFCAST(msg, editbox)
    local oldt = true
    local unit = "mouseover"
    if not UnitExists(unit) then
      local frame = GetMouseFocus()
      if frame.label and frame.id then
        unit = frame.label .. frame.id
      elseif UnitExists("target") then
        unit = "target"
      elseif GetCVar("autoSelfCast") == "1" then
        unit = "player"
      else
        return
      end
    end

    if UnitIsUnit("target", unit) then oldt = nil end

    TargetUnit(unit)
    CastSpellByName(msg)

    if oldt then
      if pfUI.uf.target then
        pfUI.uf.target.noanim = "yes"
      end
      TargetLastTarget()
    end
  end
end)
