-- DPSMate overrides fontstyle and size of every dropdown menu
pfUIhookShowMenu = UnitPopup_ShowMenu
function UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData)
  pfUIhookShowMenu(dropdownMenu, which, unit, name, userData)
  for i=1, 20 do
    getglobal("DropDownList1Button"..i.."NormalText"):SetFont(STANDARD_TEXT_FONT, 10)
  end
end

pfUIhookUIDropDownMenu_Initialize = UIDropDownMenu_Initialize
function UIDropDownMenu_Initialize(frame, initFunction, displayMode, level)
  pfUIhookUIDropDownMenu_Initialize(frame, initFunction, displayMode, level)
	for i=1, 20 do
    getglobal("DropDownList1Button"..i.."NormalText"):SetFont(STANDARD_TEXT_FONT, 10)
  end
end
