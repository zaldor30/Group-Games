local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.base = {}
local lBase, base = {}, ns.base

local function OnDragStart(self)
    if base.isMoveLocked then return end
    self:StartMoving()
    if ns.logs.tblFrame.frame then
        ns.logs.tblFrame.frame:SetScript("OnUpdate", UpdateSecondFrameDuringDrag)
    end
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    lBase.screenPos.point,_,_, lBase.screenPos.x, lBase.screenPos.y = self:GetPoint()
    ns.pSettings.screenPos = lBase.screenPos
    if ns.logs.tblFrame.frame then
        ns.logs.tblFrame.frame:SetScript("OnUpdate", nil)  -- Stop updating the second frame's position
        ns.logs:PositionLogScreen()
    end
end
local function obsGROUP_TYPE_UPDATE()
end
local function obsGAME_OVER() lBase:SetShown(true) end
local function obsGAME_RUNNING() lBase:SetShown(true) end

function lBase:Init()
    self.tblMenu = {}

    self.screenPos = {
        point = 'CENTER',
        x = 0,
        y = 0
    }
    self.isMoveLocked = true

    self.tblButtons = {}
    self.menuEntries = {}
end
function lBase:SetShown(val)
    if not val then
        base.tblFrame.frame:SetShown(false)
        return
    end

    ns.observer:Register('GAME_OVER', obsGAME_OVER)
    ns.observer:Register('GAME_RUNNING', obsGAME_RUNNING)
    ns.observer:Register('GROUP_TYPE_UPDATE', obsGROUP_TYPE_UPDATE)

    self.screenPos = ns.pSettings.screenPos or {point = 'CENTER', x = 0, y = 0}

    self:CreateBaseFrame()
    self:CreateTitleFrame()
    self:CreateIconFrame()
    self:CreateStatusBar()
    self:CreateAppFrame()

    --* Menu Entries
    self.menuEntries = {
        {
            text = L['DICE_GAMES'],
            isTitle = true,
            hasArrow = true,
            notCheckable = true,
            menuList = {
                {
                    text = L['DICE_RACE'],
                    notCheckable = true,
                    hide = ns.gSettings.diceRace.hide or false,
                    fav = ns.gSettings.diceRace.favorite or false,
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['DICE_RACE'])
                        CloseDropDownMenus()

                        ns.observer:Notify('CLOSE_SCREENS')
                        ns.code:fOut(L['DICE_RACE']..' is not implemented.')
                        ns.diceGames.diceRace:SetShown(true)
                    end,
                },
                {
                    text = L['HIGH_ROLLER'],
                    notCheckable = true,
                    hide = ns.gSettings.highRoller.hide or false,
                    fav = ns.gSettings.highRoller.favorite or false,
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['HIGH_ROLLER'])
                        CloseDropDownMenus()

                        ns.observer:Notify('CLOSE_SCREENS')
                        ns.diceGames.highRoller:SetShown(true)
                    end,
                },
                {
                    hide = ns.gSettings.survivor.hide or false,
                    text = L['SURVIVOR'],
                    notCheckable = true,
                    fav = ns.gSettings.survivor.favorite or false,
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['SURVIVOR'])
                        CloseDropDownMenus()

                    ns.observer:Notify('CLOSE_SCREENS')
                    ns.code:fOut(L['SURVIVOR']..' is not implemented.')
                end,
                },
                {
                    text = L['TARGET_PRACTICE'],
                    hide = true,
                    notCheckable = true,
                    fav = ns.gSettings.targetPractice.favorite or false,
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['TARGET_PRACTICE'])
                        CloseDropDownMenus()

                        ns.observer:Notify('CLOSE_SCREENS')
                        ns.code:fOut(L['TARGET_PRACTICE']..' is not implemented.')
                    end,
                },
            },
        },
    }

    if ns.core.canRunGames then
        --! Open Template
    else
        --! Close Iconframe and Template
        lBase:GameRunning()
        return
    end

    self.tblMenu.frame = ns.ggMenu:CreateMenu(base.tblFrame.titleBar, self.menuEntries, (ns.core.activeGame and ns.core.activeGame or 'Select a Game'), 150)
    ns.logs:SetShown(false, true)
    base.tblFrame.frame:SetShown(true)
end
function lBase:CreateBaseFrame()
    local f = base.tblFrame.frame or CreateFrame('Frame', 'GG_BaseFrame', UIParent, 'BackdropTemplate')
    f:SetSize(450, 250)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetPoint(self.screenPos.point, self.screenPos.x, self.screenPos.y)
    f:SetMovable(self.isMoveLocked)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript('OnDragStart', OnDragStart)
    f:SetScript('OnDragStop', OnDragStop)
    f:SetScript('OnHide', function() end)--ns.logs:SetShown(false) end)
    f:SetShown(true)
    base.tblFrame.frame = f

    -- Set ESC to close window
    _G['GroupGames'] = f
    tinsert(UISpecialFrames, 'GroupGames')
end
function lBase:CreateTitleFrame()
    local f = base.tblFrame.frame

    --* Create Title Bar
    local titleBar = CreateFrame('Frame', 'GG_BaseFrame_TitleBar', f, 'BackdropTemplate')
    titleBar:SetSize(f:GetWidth() - 4, 35)
    titleBar:SetBackdrop(BackdropTemplate())
    titleBar:SetBackdropBorderColor(0, 0, 0, 0)
    titleBar:SetBackdropColor(0, 0, 0, 1)
    titleBar:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -2)
    titleBar:SetShown(true)
    base.tblFrame.titleBar = titleBar

    local title = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightMedium')
    title:SetText(L['TITLE'])
    title:SetPoint('LEFT', titleBar, 'LEFT', 8, 0)
    title:SetShown(true)

    local closeButton = CreateFrame('Button', 'GG_BaseCloseButton', titleBar, 'UIPanelCloseButton')
    closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -5, 0)
    closeButton:SetSize(20, 20)
    closeButton:SetScript('OnClick', function()
        ns.observer:Notify('CLOSE_SCREENS')
        ns.logs:SetShown(false)
        f:SetShown(false)
    end)
    closeButton:SetShown(true)
    base.tblFrame.closeButton = closeButton
end
function lBase:CreateIconFrame()
    local f = base.tblFrame.titleBar

    --* Lock Drag Icon
    local lockIcon = CreateFrame('Button', 'GG_BaseLockIcon', f, 'BackdropTemplate')
    lockIcon:SetSize(20, 20)
    lockIcon:SetPoint('TOPRIGHT', base.tblFrame.closeButton, 'TOPLEFT', -3, 0)
    lockIcon:SetNormalTexture(FRAME_LOCKED_ICON)
    lockIcon:SetHighlightTexture(BLUE_HIGHLIGHT)
    lockIcon:SetScript('OnClick', function()
        self.isMoveLocked = not self.isMoveLocked
        f:SetMovable(not self.isMoveLocked)
        lockIcon:SetNormalTexture(self.isMoveLocked and FRAME_LOCKED_ICON or FRAME_UNLOCKED_ICON)
    end)
    lockIcon:SetScript('OnEnter', function() ns.code:createTooltip(L['DRAG_FRAME'], L['DRAG_FRAME_TOOLTIP'], true) end)
    lockIcon:SetScript('OnLeave', function() GameTooltip:Hide() end)
    lockIcon:SetShown(true)

    --* Settings Icon
    local settingsIcon = CreateFrame('Button', 'GG_BaseSettingsIcon', f, 'BackdropTemplate')
    settingsIcon:SetSize(20, 20)
    settingsIcon:SetPoint('RIGHT', lockIcon, 'LEFT', 0, 0)
    settingsIcon:SetNormalTexture(SETTINGS_ICON)
    settingsIcon:SetHighlightTexture(BLUE_HIGHLIGHT)
    settingsIcon:SetScript('OnClick', function() Settings.OpenToCategory('Group Games') end)
    settingsIcon:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE'], L['TOOLTIP_BODY'], true) end)
    settingsIcon:SetScript('OnLeave', function() GameTooltip:Hide() end)
    settingsIcon:SetShown(true)

    --* Home Icon
    local homeIcon = CreateFrame('Button', 'GG_BaseSettingsIcon', f, 'BackdropTemplate')
    homeIcon:SetSize(20, 20)
    homeIcon:SetPoint('RIGHT', settingsIcon, 'LEFT', -3, 0)
    homeIcon:SetNormalTexture(HOME_ICON)
    homeIcon:SetHighlightTexture(BLUE_HIGHLIGHT)
    homeIcon:SetScript('OnClick', function()
        ns.observer:Notify('NEW_GAME_OPENING')
        self:SetShown(true)
    end)
    homeIcon:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE'], L['TOOLTIP_BODY'], true) end)
    homeIcon:SetScript('OnLeave', function() GameTooltip:Hide() end)
    homeIcon:SetShown(false)
end
function lBase:CreateStatusBar()
    local f = base.tblFrame.frame

    --* Build Status Bar
    local statusBar = CreateFrame('Frame', 'GG_BaseFrame_TitleBar', f, 'BackdropTemplate')
    statusBar:SetSize(f:GetWidth() - 4, 25)
    statusBar:SetBackdrop(BackdropTemplate())
    statusBar:SetBackdropBorderColor(0, 0, 0, 0)
    statusBar:SetBackdropColor(0, 0, 0, 1)
    statusBar:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 2, -2)
    statusBar:SetShown(true)
    base.tblFrame.statusBar = statusBar

    local default = 'v'..GG.version..(GG.isPreRelease and ' ('..GG.preReleaseType..')' or '')
    local statusText = f:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed3')
    statusText:SetText(default)
    statusText:SetTextColor(1, 1, 1)
    statusText:SetPoint('LEFT', statusBar, 'LEFT', 5, 2)
    statusText:SetShown(true)

    ns.statusControl = statusText
    ns.statusText = function(text) statusText:SetText((not text or text == '') and default or text) end

    local cDefault, cActive = {1, 1, 1, 1}, {0, 1, 0, 1}
    local cDefaultHighlight, cActiveHighlight = {0.7, 0.7, 0.7, 1}, {0, 0.7, 0, 1}
    local logsButton = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableMed3')
    logsButton:SetText('Logs')
    logsButton:SetTextColor(1, 1, 1)
    logsButton:SetPoint('RIGHT', statusBar, 'RIGHT', -5, 2)
    logsButton:SetShown(true)
    logsButton:SetScript('OnMouseDown', function()
        ns.logs.logsActive = not ns.logs.logsActive
        local c = ns.logs.logsActive and cActive or cDefault
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])

        ns.logs:SetShown(ns.logs.logsActive)
    end)
    logsButton:SetScript('OnEnter', function()
        local c = ns.logs.logsActive and cActiveHighlight or cDefaultHighlight
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])
    end)
    logsButton:SetScript('OnLeave', function()
        local c = ns.logs.logsActive and cActive or cDefault
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])
    end)
    base.tblFrame.logsButton = logsButton
end
function lBase:CreateAppFrame()
    local f = base.tblFrame

    --* App Area Frame for Games
    local middleFrame = CreateFrame('Frame', 'GG_BaseOutputFrame', f.frame, 'BackdropTemplate')
    -- Anchor the top of the middle frame to the bottom of the title bar
    middleFrame:SetPoint('TOPLEFT', f.titleBar, 'BOTTOMLEFT', 0, 0)
    middleFrame:SetPoint('TOPRIGHT', f.titleBar, 'BOTTOMRIGHT', 0, 0)

    -- Anchor the bottom of the middle frame to the top of the status bar
    middleFrame:SetPoint('BOTTOMLEFT', f.statusBar, 'TOPLEFT', 0, 0)
    middleFrame:SetPoint('BOTTOMRIGHT', f.statusBar, 'TOPRIGHT', 0, 0)
    middleFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    middleFrame:SetBackdropColor(1, 1, 1, 0)
    middleFrame:SetBackdropBorderColor(1, 1, 1, 0)
    middleFrame:SetShown(true)
    base.tblFrame.appFrame = middleFrame
    ns.appFrame = middleFrame
end
function lBase:GameRunning()
    if not base.tblFrame.frame then return end

    local gFrame = CreateFrame('Frame', 'GG_GameFrame', base.tblFrame.frame, "BackdropTemplate")
    gFrame:SetSize(200, 200)
end
lBase:Init()

function base:Init()
    self.tblFrame = {}
end
function base:IsShown() return self.tblFrame.frame and self.tblFrame.frame:IsShown() or false end
function base:SetShown(val) lBase:SetShown(val) end
base:Init()