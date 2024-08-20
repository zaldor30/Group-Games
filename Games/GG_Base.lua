local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.base = {}
local lBase, base = {}, ns.base

--local function UpdateSecondFrameDuringDrag() logs:PositionLogScreen() end
local function OnDragStart(self)
    if base.isMoveLocked then return end
    self:StartMoving()
    if ns.logs.tblLogs.frame then
        ns.logs.tblLogs.frame:SetScript("OnUpdate", UpdateSecondFrameDuringDrag)
    end
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    lBase.screenPos.point,_,_, lBase.screenPos.x, lBase.screenPos.y = self:GetPoint()
    ns.pSettings.screenPos = lBase.screenPos
    if ns.logs.tblLogs.frame then
        ns.logs.tblLogs.frame:SetScript("OnUpdate", nil)  -- Stop updating the second frame's position
        ns.logs:PositionLogScreen()
    end
end
local function GroupRosterUpdate_Event()
    if not base.tblFrame.frame.isShown or ns.core.isInGroup then return end
    lBase:SetShown(false)
    ns.code:fOut('Your group has disbanded. Group Games has been hidden.')
end

function lBase:Init()
    self.tblFrame = {}
    self.tblMenu = {}

    self.screenPos = {
        point = 'CENTER',
        x = 0,
        y = 0
    }
    self.isMoveLocked = true

    self.menuEntries = { --* Expand for menu items
        {
            text = L['DICE_GAMES'],
            isTitle = true,
            hasArrow = true,
            notCheckable = true,
            menuList = {
                {
                    text = L['DICE_RACE'],
                    notCheckable = true,
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
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['HIGH_ROLLER'])
                        CloseDropDownMenus()

                        ns.observer:Notify('CLOSE_SCREENS')
                        ns.diceGames.highRoller:SetShown(true)
                    end,
                },
                {
                    text = L['SURVIVOR'],
                    notCheckable = true,
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['SURVIVOR'])
                        CloseDropDownMenus()

                        ns.observer:Notify('CLOSE_SCREENS')
                        ns.code:fOut(L['SURVIVOR']..' is not implemented.')
                    end,
                },
                {
                    text = L['TARGET_PRACTICE'],
                    notCheckable = true,
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
end
function lBase:SetShown(val)
    if not val then
        ns.observer:Notify('CLOSE_SCREENS')
        base.bFrame.frame:SetShown(false)
        return
    end

    ns.observer:Register('GROUP_ROSTER_UPDATE', GroupRosterUpdate_Event)
    self.screenPos = ns.pSettings.screenPos or {point = 'CENTER', x = 0, y = 0}

    if not base.bFrame.frame then self:CreateBaseFrame()
    else ns.ggMenu:ClearMenu(self.tblMenu.frame) end

    self.tblMenu.frame = ns.ggMenu:CreateMenu(self.tblFrame.titleBar, self.menuEntries, (ns.core.activeGame and ns.core.activeGame or 'Select a Game'), 150)
    base.bFrame.frame:SetShown(true)
end
function lBase:CreateBaseFrame()
    local f = base.bFrame.frame or CreateFrame('Frame', 'GG_BaseFrame', UIParent, 'BackdropTemplate')
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
    f:SetShown(true)
    base.bFrame.frame = f

    -- Set ESC to close window
    _G['GroupGames'] = f
    tinsert(UISpecialFrames, 'GroupGames')

    --* Create Title Bar
    local titleBar = CreateFrame('Frame', 'GG_BaseFrame_TitleBar', f, 'BackdropTemplate')
    titleBar:SetSize(f:GetWidth() - 4, 35)
    titleBar:SetBackdrop(BackdropTemplate())
    titleBar:SetBackdropBorderColor(0, 0, 0, 0)
    titleBar:SetBackdropColor(0, 0, 0, 1)
    titleBar:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -2)
    titleBar:SetShown(true)
    self.tblFrame.titleBar = titleBar

    local title = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
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

    --* Lock Drag Icon
    local lockIcon = CreateFrame('Button', 'GG_BaseLockIcon', titleBar, 'BackdropTemplate')
    lockIcon:SetSize(20, 20)
    lockIcon:SetPoint('TOPRIGHT', closeButton, 'TOPLEFT', -3, 0)
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
    local settingsIcon = CreateFrame('Button', 'GG_BaseSettingsIcon', titleBar, 'BackdropTemplate')
    settingsIcon:SetSize(20, 20)
    settingsIcon:SetPoint('TOPRIGHT', lockIcon, 'TOPLEFT', -3, 0)
    settingsIcon:SetNormalTexture(SETTINGS_ICON)
    settingsIcon:SetHighlightTexture(BLUE_HIGHLIGHT)
    settingsIcon:SetScript('OnClick', function() Settings.OpenToCategory('Group Games') end)
    settingsIcon:SetScript('OnEnter', function() ns.code:createTooltip(L['TITLE'], L['TOOLTIP_BODY'], true) end)
    settingsIcon:SetScript('OnLeave', function() GameTooltip:Hide() end)
    settingsIcon:SetShown(true)

    --* Build Status Bar
    local statusBar = CreateFrame('Frame', 'GG_BaseFrame_TitleBar', f, 'BackdropTemplate')
    statusBar:SetSize(f:GetWidth() - 4, 25)
    statusBar:SetBackdrop(BackdropTemplate())
    statusBar:SetBackdropBorderColor(0, 0, 0, 0)
    statusBar:SetBackdropColor(0, 0, 0, 1)
    statusBar:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 2, -2)
    statusBar:SetShown(true)

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
        ns.logs:PositionLogScreen()
    end)
    logsButton:SetScript('OnEnter', function()
        local c = ns.logs.logsActive and cActiveHighlight or cDefaultHighlight
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])
    end)
    logsButton:SetScript('OnLeave', function()
        local c = ns.logs.logsActive and cActive or cDefault
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])
    end)
    base.bFrame.logsButton = logsButton

    --* App Area Frame for Games
    local middleFrame = CreateFrame('Frame', 'GG_BaseOutputFrame', f, 'BackdropTemplate')
    -- Anchor the top of the middle frame to the bottom of the title bar
    middleFrame:SetPoint('TOPLEFT', titleBar, 'BOTTOMLEFT', 0, 0)
    middleFrame:SetPoint('TOPRIGHT', titleBar, 'BOTTOMRIGHT', 0, 0)

    -- Anchor the bottom of the middle frame to the top of the status bar
    middleFrame:SetPoint('BOTTOMLEFT', statusBar, 'TOPLEFT', 0, 0)
    middleFrame:SetPoint('BOTTOMRIGHT', statusBar, 'TOPRIGHT', 0, 0)
    middleFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    middleFrame:SetBackdropColor(1, 1, 1, 0)
    middleFrame:SetBackdropBorderColor(1, 1, 1, 0)
    middleFrame:SetShown(true)
    base.bFrame.gameFrame = middleFrame
    ns.gameFrame = middleFrame
end
lBase:Init()

function base:Init()
    self.bFrame = {} -- Interactive Frame Storage
end
function base:IsShown() return self.bFrame.frame and self.bFrame.frame:IsShown() or false end
function base:SetShown(val) lBase:SetShown(val) end
base:Init()