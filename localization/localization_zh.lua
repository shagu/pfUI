if( GetLocale() == "zhCN" ) then
--skin.lua
pf_settings = "UI设置"

--gui.lua
pf_St = "基本设置"
pf_General = "默认"
pf_ERC = "启用兼容字体"
pf_STF = "标准字体"
pf_STFS = "标准字体字号"
pf_UFTF = "头像框架字体"
pf_UFTS = "头像框架字体字号"
pf_SCTF = "战斗信息字体"
pf_EPP = "启用UI缩放"
pf_EOFP = "启用屏幕框架固定"
pf_ESLU = "显示一行错误"
pf_DAU = "禁用所有UI错误"
pf_DR = "还原"
pf_EVERYTHING = "|cffff5555全部|r"
pf_EVERYTHINGMSG = "你是否要还原 |cffffaaaa所有|r配置？\n\n这将还原：\n 当前配置\n 界面位置\n 首次安装向导\n 插件缓存\n 保存的配置"
pf_CACHE = "缓存"
pf_CACHEMSG = "你是否要重置缓存？"
pf_Firstrun = "首次安装"
pf_FirstrunMSG = "你是否要重新安装插件？"
pf_Configuration = "配置"
pf_ConfigurationMSG = "你是否要还原设置？\n这将包括框架位置"
pf_Profile = "配置"
pf_SProfile = "选择配置"
pf_LProfile = "加载配置"
pf_DProfile = "删除配置"
pf_SSProfile = "保存配置"
pf_CProfile = "新建配置"
--
pf_Appearance = "外观"
pf_Background_Color = "背景颜色"
pf_Border_Color = "边框颜色"
pf_Global_Border_Size = "全局边框大小"
pf_Action_Bar_Border_Size = "动作条边框大小"
pf_Unit_Frame_Border_Size = "头像边框大小"
pf_Panel_Border_Size = "面板边框大小"
pf_Chat_Border_Size = "聊天窗口边框大小"
pf_Bags_Border_Size = "背包边框大小"
--
pf_CD = "冷却时间"
pf_CDCL = "技能冷却时间颜色[少于3秒]"
pf_CDCS = "技能冷却时间颜色[秒]"
pf_CDCM = "技能冷却时间颜色[分]"
pf_CDCH = "技能冷却时间颜色[时]"
pf_CDCD = "技能冷却时间颜色[天]"
pf_CDTT = "技能冷却时间文字大小"
--
pf_Unit_Frames = "头像框架"
pf_DPUF = "禁用头像框架"
pf_EPC = "使用彩色头像"
pf_ECCHB = "使用自定义血条颜色"
pf_CHBC = "血条颜色"
pf_ECCHBB = "使用自定义血条背景色"
pf_CHBBC = "血条背景色"
pf_HAS = "掉血动画速度"
pf_P_A = "人偶透明度"
pf_E2PAF = "启动2D头像备用"
pf_UF_L = "头像框架样式"
pf_A4RC = "Aggressive 40y-Range Check (Will break stuff)"
pf_4CI = "40y-Range Check Interval"
pf_C_Z = "连击点大小"
pf_A_N = "缩写数字格式[4200为4.2K]"
pf_S_PVP = "显示PVP图标"
pf_EET = "显示能量刻度"
--player
pf_PLAYER = "玩家"
pf_Dis_PF = "禁用玩家头像模块"
pf_P_P = "人偶头像位置"
pf_HP_WIDTH = "血条宽度"
pf_HP_HEIGHT = "血条高度"
pf_MP_HEIGHT = "能量值高度"
pf_Spacing = "血条能量条间隔"
pf_BUFF_P = "BUFF位置"
pf_BUFF_S = "BUFF大小"
pf_BUFF_L = "BUFF数量"
pf_BUFF_P_R = "BUFF每行数量"
pf_DEBUFF_P = "DEBUFF位置"
pf_DEBUFF_S = "DEBUFF大小"
pf_DEBUFF_L = "DEBUFF数量"
pf_DEBUFF_P_R = "DEBUFF每行数量"
pf_I_H_B = "血量反向显示"
pf_E_BUFF_I = "在头像框架上显示BUFF"
pf_E_DEBUFF_I = "在头像框架上显示DEBUFF"
pf_E_CC = "启用点击施法"
pf_ERF = "Enable Range Fading"
pf_L_T = "左侧文字"
pf_C_T = "中间文字"
pf_R_T = "右侧文字"
pf_E_HCIT = "启用生命值文字颜色样式"
pf_E_PCIT = "启用能量值文字颜色样式"
pf_E_LCIT = "启用等级文字颜色样式"
pf_E_CCIT = "启用职业文字颜色样式"
--target
pf_TARGET = "目标"
pf_DIS_TF = "禁用目标头像模块"
pf_E_TSA = "启用目标切换动画"
--TARGET-TARGET
pf_TARGET_TARGET = "目标的目标"
pf_DIS_TOTF = "禁用目标的目标头像模块"
--pet
pf_PET = "宠物"
pf_DIS_PF = "禁用宠物头像模块"
--focus
pf_FOCUS = "焦点目标"
pf_DIS_FF = "禁用焦点目标模块"
--group frame
pf_GROUP_FRAME = "队伍框架"
pf_SHABI = "在框架的Buff指示器显示Hot"
pf_SHOAC = "显示所有职业的Hot"
pf_SPABI = "在框架的Buff指示器显示触发效果"
pf_SPOAC = "显示所有职业的触发效果"
pf_OSIFDD = "只显示可驱散的DEBUFF"
pf_CC_S = "点击施法"
pf_CLICK_ACTION = "点击操作"
pf_SHIFT_CA = "SHIFT点击操作"
pf_ALT_CA = "ALT点击操作"
pf_CTRL_CA = "CTRL点击操作"
--raid
pf_RAID = "团队"
pf_DIS_RF = "禁用团队模块"
--group
pf_GROUP = "小队"
pf_DIS_GF = "禁用小队模块"
pf_HIDE_IN_RAID = "在团队框架下隐藏小队框架"
--group-target
pf_GROUP_TARGET = "小队目标"
pf_DIS_GTF = "禁用小队目标模块"
--group-pet
pf_GROUP_PET = "小队宠物"
pf_DIS_GPT = "禁用小队宠物模块"
--Combat
pf_COMBAT = "战斗报警"
pf_COMBAT_FULL = "全屏显示战斗报警"
pf_COMBAT_UF = "仅在头像上显示战斗报警"
pf_COMBAT_GROUP = "在小队显示战斗报警"
--bag&bank
pf_BAG_BANK = "背包银行"
pf_DIS_IQC = "仅在普通品质以上物品显示品质颜色"
pf_ENABLE_IQC = "仅在装备上显示品质颜色"
pf_AUTO_SELL = "自动贩卖灰色物品"
pf_AUTO_REPAIR = "自动修理装备"
--loot
pf_LOOT = "拾取"
pf_ENABLE_ALF = "自动调整拾取框大小"
pf_DIS_LOOT = "禁用拾取确认对话框[无组队]"
--minimap
pf_MINIMAP = "小地图"
pf_ENABLE_ZONE = "鼠标悬停时显示区域名称"
pf_DIS_MINI_BUFF = "隐藏系统BUFF图标"
pf_DIS_MINI_W_BUFF = "隐藏系统武器BUFF图标"
pf_SHOW_PVP = "显示PVP图标"
--actionbar
pf_ACTIONBAR = "动作条"
pf_ICON_S = "图标大小"
pf_ENABLE_ABB = "启用动作条背景"
pf_ENABLE_RDOH = "使用颜色指示技能使用距离"
pf_RDC = "技能使用距离超限颜色"
pf_SHOW_MACRO_T = "显示宏的名字"
pf_SHOW_HOTKEY_T = "显示快捷键文本"
pf_ENABLE_RBAP = "启用基于范围的自动分页[猎人]"
--autohide
pf_AUTOHIDE = "自动隐藏"
pf_AUTOHIDE_TIME = "自动隐藏动作条延时"
pf_AUTOHIDE_MAIN = "自动隐藏主动作条"
pf_AUTOHIDE_B_LEFT = "自动隐藏左下动作条"
pf_AUTOHIDE_B_RIGHT = "自动隐藏右下动作条"
pf_AUTOHIDE_RIGHT = "自动隐藏右侧动作条"
pf_AUTOHIDE_RIGHT2 = "自动隐藏右侧动作条2"
pf_AUTOHIDE_SHAPESHIFT = "自动隐藏姿态条"
pf_AUTOHIDE_PET = "自动隐藏宠物动作条"
--layout
pf_LAYOUT = "布局"
pf_M_AB = "主动作条"
pf_BL_AB = "左下方动作条"
pf_BR_AB = "右下方动作条"
pf_R_AB = "右侧动作条"
pf_R2_AB = "右侧动作条2"
pf_SS_AB = "姿态条"
pf_PET_AB = "宠物动作条"
--panel
pf_PANEL = "面板"
pf_U_N_F = "切换插件字体"
pf_LP_L = "左侧面板：左侧"
pf_LP_C = "左侧面板：中部"
pf_LP_R = "左侧面板：右侧"
pf_RP_L = "右侧面板：左侧"
pf_RP_C = "右侧面板：中部"
pf_RP_R = "右侧面板：右侧"
pf_OP_MAP = "小地图面板"
pf_ALWAYS_SHOW = "总是显示经验和声望"
pf_ENABLE_MICRO = "显示菜单栏"
pf_TIME24 = "启用24小时制式"
--tooltip
pf_TOOTIP = "鼠标提示框"
pf_TOOTIP_P = "鼠标提示框位置"
pf_ENABLE_GUILD = "显示公会职位"
pf_CUSTOM_T = "透明度"
pf_ALWAYS_SHOW_ITEM = "始终显示装备比较"
pf_SHOW_SELL_VALUES = "始终显示售卖价格"
--castbar
pf_CASTBAR = "施法条"
pf_CASTING_COLOR = "吟唱施法读条颜色"
pf_BACK_COLOR = "引导施法读条颜色"
pf_DIS_BZ_C = "隐藏暴雪施法条"
pf_DIS_P_C = "隐藏玩家施法条"
pf_DIS_T_C = "隐藏目标施法条"
--chat
pf_CHAT = "聊天框"
pf_ENABLE_L_C = "启用[拾取、综合]聊天窗口"
pf_INPUT_W = "输入框宽度"
pf_INPUT_H = "输入框高度"
pf_ENABLE_TIME = "启用时间戳"
pf_TIME_FORMAT = "时间戳格式"
pf_TIME_BRACKETS = "时间戳括弧"
pf_TIME_COLOR = "时间戳颜色"
pf_HIDE_CHANNEL = "隐藏频道名称"
pf_URL = "启用超链接检测"
pf_CLASS_COLOR = "使用职业颜色"
pf_CHAT_L_W = "左侧聊天窗口宽度"
pf_CHAT_L_H = "左侧聊天窗口高度"
pf_CHAT_R_W = "右侧聊天窗口宽度"
pf_CHAT_R_H = "右侧聊天窗口高度"
pf_ENABLE_R_CHAT = "总是显示右侧聊天窗口"
pf_CHAT_DOCK = "显示聊天窗口停靠栏"
pf_ENABLE_CUSTOM_COLOR = "激活自定义聊天窗口"
pf_CHAT_BACKGROUND = "聊天窗口背景颜色"
pf_CHAT_BORDER_COLOR = "聊天窗口边框颜色"
pf_ENABLE_WHISPERS = "启用私聊样式"
pf_I_WHISPERS_COLOR = "私聊颜色设置"
pf_ENABLE_S_CHAT = "粘滞性聊天[保存上一次的频道]"
pf_ENABLE_CHAT_FADE = "聊天记录淡出"
pf_CHAT_FADE_TIME = "淡出时间设置"
--nameplates
pf_NAMEPLATES = "姓名板"
pf_ENABLE_CASTBARS = "显示敌对施法条"
pf_SPELLNAME = "显示技能名称"
pf_N_DEBUFFS = "显示DEBUFF"
pf_ENABLE_CLICK = "启用点击"
pf_MOUSELOOK = "启动右键移动镜头"
pf_RIGHT_AUTO_AT = "镜头移动速度"
pf_CLASS_COL_O_E = "显示敌军职业颜色"
pf_CLASS_COL_O_F = "显示友军职业颜色"
pf_RAID_I_S = "团队图标大小"
pf_SHOW_PLAYERS_O = "仅显示自己"
pf_SHOW_HP = "显示生命值"
pf_VERICAL_POS = "垂直偏移"
pf_NAMEPLATE_W = "姓名板高度"
pf_HP_H = "生命条高度"
pf_CASTBAR_H = "敌对施法条高度"
--Thirdparty
pf_THIRDPARTY = "第三方插件接口"
--Modules
pf_MODULES = "高级选项"
pf_DISABLE = "禁用 "
--close
pf_CLOSE = "关闭"
--unlock
pf_UNLOCK = "解锁排版"
--Hoverbind
pf_HOVERBIND = "悬停设置"
--chat.lua
pf_LOOT_SPAM = "拾取、综合"
--panel.lua
end