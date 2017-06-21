if( GetLocale() == "enUS" ) then
--skin.lua
pf_settings = "\"pfUI\" Settings"

--gui.lua
pf_St = "Settings"
pf_General = "General"
pf_ERC = "Enable Region Compatible Font"
pf_STF = "Standard Text Font"
pf_STFS = "Standard Text Font Size"
pf_UFTF = "Unit Frame Text Font"
pf_UFTS = "Unit Frame Text Size"
pf_SCTF = "Scrolling Combat Text Font"
pf_EPP = "Enable Pixel Perfect (Native Resolution)"
pf_EOFP = "Enable Offscreen Frame Positions"
pf_ESLU = "Enable Single Line UIErrors"
pf_DAU = "Disable All UIErrors"
pf_DR = "Delete / Reset"
pf_EVERYTHING = "|cffff5555EVERYTHING|r"
pf_EVERYTHINGMSG = "Do you really want to reset |cffffaaaaEVERYTHING|r?\n\nThis will reset:\n - Current Configuration\n - Current Frame Positions\n - Firstrun Wizard\n - Addon Cache\n - Saved Profiles"
pf_CACHE = "Cache"
pf_CACHEMSG = "Do you really want to reset the Cache?"
pf_Firstrun = "Firstrun"
pf_FirstrunMSG = "Do you really want to reset the Firstrun Wizard Settings?"
pf_Configuration = "Configuration"
pf_ConfigurationMSG = "Do you really want to reset your configuration?\nThis also includes frame positions"
pf_Profile = "Profile"
pf_SProfile = "Select profile"
pf_LProfile = "Load profile"
pf_DProfile = "Delete profile"
pf_SSProfile = "Save profile"
pf_CProfile = "Create Profile"
--
pf_Appearance = "Appearance"
pf_Background_Color = "Background Color"
pf_Border_Color = "Border Color"
pf_Global_Border_Size = "Global Border Size"
pf_Action_Bar_Border_Size = "Action Bar Border Size"
pf_Unit_Frame_Border_Size = "Unit Frame Border Size"
pf_Panel_Border_Size = "Panel Border Size"
pf_Chat_Border_Size = "Chat Border Size"
pf_Bags_Border_Size = "Bags Border Size"
--
pf_CD = "Cooldown"
pf_CDCL = "Cooldown Color (Less than 3 Sec)"
pf_CDCS = "Cooldown Color (Seconds)"
pf_CDCM = "Cooldown Color (Minutes)"
pf_CDCH = "Cooldown Color (Hours)"
pf_CDCD = "Cooldown Color (Days)"
pf_CDTT = "Cooldown Text Threshold"
pf_CDTF = "Cooldown Text Font Size"
--
pf_Unit_Frames = "Unit Frames"
pf_DPUF = "Disable pfUI Unit Frames"
pf_EPC = "Enable Pastel Colors"
pf_ECCHB = "Enable Custom Color Health Bars"
pf_CHBC = "Custom Health Bar Color"
pf_ECCHBB = "Enable Custom Color Health Bar Background"
pf_CHBBC = "Custom Health Bar Background Color"
pf_HAS = "Healthbar Animation Speed"
pf_P_A = "Portrait Alpha"
pf_P_TD = "Always Use 2D Portraits"
pf_E2PAF = "Enable 2D Portraits As Fallback"
pf_UF_L = "Unit Frame Layout"
pf_A4RC = "Aggressive 40y-Range Check (Will break stuff)"
pf_4CI = "40y-Range Check Interval"
pf_C_Z = "Combopoint Size"
pf_A_N = "Abbreviate Numbers (4200 -> 4.2k)"
pf_S_PVP = "Show PvP Icon"
pf_EET = "Enable Energy Ticks"
--
pf_PLAYER = "Player"
pf_Dis_PF = "Display Player Frame"
pf_P_P = "Portrait Position"
pf_HP_WIDTH = "Health Bar Width"
pf_HP_HEIGHT = "Health Bar Height"
pf_MP_HEIGHT = "Power Bar Height"
pf_Spacing = "Spacing"
pf_BUFF_P = "Buff Position"
pf_BUFF_S = "Buff Size"
pf_BUFF_L = "Buff Limit"
pf_BUFF_P_R = "Buffs Per Row"
pf_DEBUFF_P = "Debuff Position"
pf_DEBUFF_S = "Debuff Size"
pf_DEBUFF_L = "Debuff Limit"
pf_DEBUFF_P_R = "Debuffs Per Row"
pf_I_H_B = "Invert Health Bar"
pf_E_BUFF_I = "Enable Buff Indicators"
pf_E_DEBUFF_I = "Enable Debuff Indicators"
pf_E_CC = "Enable Clickcast"
pf_ERF = "Enable Range Fading"
pf_L_T = "Left Text"
pf_C_T = "Center Text"
pf_R_T = "Right Text"
pf_E_HCIT = "Enable Health Color in Text"
pf_E_PCIT = "Enable Power Color in Text"
pf_E_LCIT = "Enable Level Color in Text"
pf_E_CCIT = "Enable Class Color in Text"
--target
pf_TARGET = "Target"
pf_DIS_TF = "Display Target Frame"
pf_E_TSA = "Enable Target Switch Animation"
--TARGET-TARGET
pf_TARGET_TARGET = "Target-Target"
pf_DIS_TOTF = "Display Target of Target Frame"
--pet
pf_PET = "Pet"
pf_DIS_PF = "Display Pet Frame"
--focus
pf_FOCUS = "Focus"
pf_DIS_FF = "Display Focus Frame"
--group frame
pf_GROUP_FRAME = "Group Frames"
pf_SHABI = "Show Hots as Buff Indicators"
pf_SHOAC = "Show Hots of all Classes"
pf_SPABI = "Show Procs as Buff Indicators"
pf_SPOAC = "Show Procs of all Classes"
pf_OSIFDD = "Only Show Indicators for Dispellable Debuffs"
pf_CC_S = "Clickcast Spells"
pf_CLICK_ACTION = "Click Action"
pf_SHIFT_CA = "Shift-Click Action"
pf_ALT_CA = "Alt-Click Action"
pf_CTRL_CA = "Ctrl-Click Action"
--raid
pf_RAID = "Raid"
pf_DIS_RF = "Display Raid Frames"
--group
pf_GROUP = "Group"
pf_DIS_GF = "Display Group Frames"
pf_HIDE_IN_RAID = "Hide Group Frames When In A Raid"
--group-target
pf_GROUP_TARGET = "Group-Target"
pf_DIS_GTF = "Display Group Target Frames"
--group-pet
pf_GROUP_PET = "Group-Pet"
pf_DIS_GPT = "Display Group Pet Frames"
--Combat
pf_COMBAT = "Combat"
pf_COMBAT_FULL = "Enable Combat Glow Effects On Screen Edges"
pf_COMBAT_UF = "Enable Combat Glow Effects On Unit Frames"
pf_COMBAT_GROUP = "Enable Combat Glow Effects On Group Frames"
--bag&bank
pf_BAG_BANK = "Bags & Bank"
pf_DIS_IQC = "Disable Item Quality Color For \"Common\" Items"
pf_ENABLE_IQC = "Enable Item Quality Color For Equipment Only"
pf_AUTO_SELL = "Auto Sell Grey Items"
pf_AUTO_REPAIR = "Auto Repair Items"
--loot
pf_LOOT = "Loot"
pf_ENABLE_ALF = "Enable Auto-Resize Loot Frame"
pf_DIS_LOOT = "Disable Loot Confirmation Dialog (Without Group)"
--minimap
pf_MINIMAP = "Minimap"
pf_ENABLE_ZONE = "Enable Zone Text On Minimap Mouseover"
pf_DIS_MINI_BUFF = "Disable Minimap Buffs"
pf_DIS_MINI_W_BUFF = "Disable Minimap Weapon Buffs"
pf_SHOW_PVP = "Show PvP Icon"
--actionbar
pf_ACTIONBAR = "Actionbar"
pf_ICON_S = "Icon Size"
pf_ENABLE_ABB = "Enable Action Bar Backgrounds"
pf_ENABLE_RDOH = "Enable Range Display On Hotkeys"
pf_RDC = "Range Display Color"
pf_SHOW_MACRO_T = "Show Macro Text"
pf_SHOW_HOTKEY_T = "Show Hotkey Text"
pf_ENABLE_RBAP = "Enable Range Based Auto Paging (Hunter)"
--autohide
pf_AUTOHIDE = "Autohide"
pf_AUTOHIDE_TIME = "Seconds Until Action Bars Autohide"
pf_AUTOHIDE_MAIN = "Enable Autohide For BarActionMain"
pf_AUTOHIDE_B_LEFT = "Enable Autohide For BarBottomLeft"
pf_AUTOHIDE_B_RIGHT = "Enable Autohide For BarBottomRight"
pf_AUTOHIDE_RIGHT = "Enable Autohide For BarRight"
pf_AUTOHIDE_RIGHT2 = "Enable Autohide For BarTwoRight"
pf_AUTOHIDE_SHAPESHIFT = "Enable Autohide For BarShapeShift"
pf_AUTOHIDE_PET = "Enable Autohide For BarPet"
--layout
pf_LAYOUT = "Layout"
pf_M_AB = "Main Actionbar (ActionMain)"
pf_BL_AB = "Second Actionbar (BottomLeft)"
pf_BR_AB = "Left Actionbar (BottomRight)"
pf_R_AB = "Right Actionbar (Right)"
pf_R2_AB = "Vertical Actionbar (TwoRight)"
pf_SS_AB = "Shapeshift Bar (BarShapeShift)"
pf_PET_AB = "Pet Bar (BarPet)"
--panel
pf_PANEL = "Panel"
pf_U_N_F = "Use Unit Fonts"
pf_LP_L = "Left Panel: Left"
pf_LP_C = "Left Panel: Center"
pf_LP_R = "Left Panel: Right"
pf_RP_L = "Right Panel: Left"
pf_RP_C = "Right Panel: Center"
pf_RP_R = "Right Panel: Right"
pf_OP_MAP = "Other Panel: Minimap"
pf_ALWAYS_SHOW = "Always Show Experience And Reputation Bar"
pf_ENABLE_MICRO = "Enable Micro Bar"
pf_TIME24 = "Enable 24h Clock"
--tooltip
pf_TOOTIP = "Tooltip"
pf_TOOTIP_P = "Tooltip Position"
pf_ENABLE_GUILD = "Enable Extended Guild Information"
pf_CUSTOM_T = "Custom Transparency"
pf_ALWAYS_SHOW_ITEM = "Always Show Item Comparison"
pf_SHOW_SELL_VALUES = "Always Show Extended Vendor Values"
--castbar
pf_CASTBAR = "Castbar"
pf_CASTING_COLOR = "Casting Color"
pf_BACK_COLOR = "Channeling Color"
pf_DIS_BZ_C = "Disable Blizzard Castbar"
pf_DIS_P_C = "Disable pfUI Player Castbar"
pf_DIS_T_C = "Disable pfUI Target Castbar"
--chat
pf_CHAT = "Chat"
pf_ENABLE_L_C = "Enable \"Loot & Spam\" Chat Window"
pf_INPUT_W = "Inputbox Width"
pf_INPUT_H = "Inputbox Height"
pf_ENABLE_TIME = "Enable Timestamps"
pf_TIME_FORMAT = "Timestamp Format"
pf_TIME_BRACKETS = "Timestamp Brackets"
pf_TIME_COLOR = "Timestamp Color"
pf_HIDE_CHANNEL = "Hide Channel Names"
pf_URL = "Enable URL Detection"
pf_CLASS_COLOR = "Enable Class Colors"
pf_CHAT_L_W = "Left Chat Width"
pf_CHAT_L_H = "Left Chat Height"
pf_CHAT_R_W = "Right Chat Width"
pf_CHAT_R_H = "Right Chat Height"
pf_ENABLE_R_CHAT = "Enable Right Chat Window"
pf_CHAT_DOCK = "Enable Chat Dock"
pf_ENABLE_CUSTOM_COLOR = "Enable Custom Colors"
pf_CHAT_BACKGROUND = "Chat Background Color"
pf_CHAT_BORDER_COLOR = "Chat Border Color"
pf_ENABLE_WHISPERS = "Enable Custom Incoming Whispers Layout"
pf_I_WHISPERS_COLOR = "Incoming Whispers Color"
pf_ENABLE_S_CHAT = "Enable Sticky Chat"
pf_ENABLE_CHAT_FADE = "Enable Chat Fade"
pf_CHAT_FADE_TIME = "Seconds Before Chat Fade"
--nameplates
pf_NAMEPLATES = "Nameplates"
pf_ENABLE_CASTBARS = "Enable Castbars"
pf_SPELLNAME = "Enable Spellname"
pf_N_DEBUFFS = "Enable Debuffs"
pf_ENABLE_CLICK = "Enable Clickthrough"
pf_MOUSELOOK = "Enable Mouselook With Right Click"
pf_RIGHT_AUTO_AT = "Right Click Auto Attack Threshold"
pf_CLASS_COL_O_E = "Enable Class Colors On Enemies"
pf_CLASS_COL_O_F = "Enable Class Colors On Friends"
pf_RAID_I_S = "Raid Icon Size"
pf_SHOW_PLAYERS_O = "Show Players Only"
pf_SHOW_HP = "Show Health Points"
pf_VERICAL_POS = "Vertical Position"
pf_NAMEPLATE_W = "Nameplate Width"
pf_HP_H = "Healthbar Height"
pf_CASTBAR_H = "Castbar Height"
--Thirdparty
pf_THIRDPARTY = "Thirdparty"
--Modules
pf_MODULES = "Modules"
pf_DISABLE = "Disable Module: "
--close
pf_CLOSE = "Close"
--unlock
pf_UNLOCK = "Unlock"
--Hoverbind
pf_HOVERBIND = "Hoverbind"
--chat.lua
pf_LOOT_SPAM = "Loot & Spam"
--panel.lua
--hoverbind.lua
pf_KEYBINDMODE = "|cff33ffccKeybind Mode|r\n"
pf_KEYBINDMODE_TMA = "This mode allows you to bind keyboard shortcuts to your actionbars.\n"
pf_KEYBINDMODE_BHB = "By hovering a button with your cursor and pressing a key, the key will be assigned to that button.\n"
pf_KEYBINDMODE_HEB = "Hit Escape on a button to remove bindings.\n\n"
pf_KEYBINDMODE_PEM = "Press Escape or click on an empty area to leave the keybind mode.\n"
end