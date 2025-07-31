pfUI:RegisterModule("mouseover", "vanilla", function ()
  pfUI.uf.mouseover = CreateFrame("Frame", "pfMouseOver", UIParent)

  _G.SLASH_PFCAST1, _G.SLASH_PFCAST2 = "/pfcast", "/pfmouse"
  function SlashCmdList.PFCAST(msg)
    local func = loadstring(msg or "")
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

    if func then
      func()
    else
      -- write temporary unit name
      pfUI.uf.mouseover.unit = unit

      CastSpellByName(msg, unit)

      -- remove temporary mouseover unit
      pfUI.uf.mouseover.unit = nil
    end
  end
end)
