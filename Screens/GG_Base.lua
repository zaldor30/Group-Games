local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.win, ns.logs = {}, {}
ns.win.base = {}
local base, logs = ns.win.base, ns.logs

local function UpdateSecondFrameDuringDrag() logs:PositionLogScreen() end
local function OnDragStart(self)
    if base.isMoveLocked then return end
    self:StartMoving()
    if logs.tblLogs.frame then
        logs.tblLogs.frame:SetScript("OnUpdate", UpdateSecondFrameDuringDrag)
    end
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    base.screenPos.point,_,_, base.screenPos.x, base.screenPos.y = self:GetPoint()
    ns.pSettings.screenPos = base.screenPos
    if logs.tblLogs.frame then
        logs.tblLogs.frame:SetScript("OnUpdate", nil)  -- Stop updating the second frame's position
        logs:PositionLogScreen()
    end
end
local function GroupRosterUpdate_Event()
    if not base.tblFrame.frame.isShown or ns.core.isInGroup then return end

    ns.observer:Notify('CLOSE_SCREENS')
    base.tblFrame.frame:SetShown(false)
    ns.code:fOut('Your group has disbanded. Group Games has been hidden.')
end

function base:Init()
    self.logEntries = {}
    self.logsActive = false

    self.screenPos = nil
    self.isMoveLocked = true
    self.tblFrame = {}
    self.tblMenu = {}
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
                    end,
                },
                {
                    text = L['TARGET_PRACTICE'],
                    notCheckable = true,
                    func = function()
                        UIDropDownMenu_SetText(self.tblMenu.frame, L['TARGET_PRACTICE'])
                        CloseDropDownMenus()

                        ns.observer:Notify('CLOSE_SCREENS')
                    end,
                },
            },
        },
    }
end
function base:SetShown(val)
    if self.tblFrame.frame then self.tblFrame.frame:SetShown(val) end
    if not val then return end

    self.screenPos = ns.pSettings.screenPos or {point = 'CENTER', x = 0, y = 0}

    ns.observer:Register('GROUP_ROSTER_UPDATE', GroupRosterUpdate_Event)
    if not self.tblFrame.frame then
        self:CreateBaseFrame()
        self:CreateMenu()
        logs:CreateLogsFrame()
        logs:SetShown(false)
    end
end
function base:CreateBaseFrame()
    local f = self.tblFrame.frame or CreateFrame('Frame', 'GG_BaseFrame', UIParent, 'BackdropTemplate')
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
    self.tblFrame.frame = f

    --* Build Title Bar
    local titleBar = self.tblFrame.titleBar or CreateFrame('Frame', 'GG_BaseFrame_TitleBar', f, 'BackdropTemplate')
    titleBar:SetSize(f:GetWidth() - 4, 35)
    titleBar:SetBackdrop(BackdropTemplate())
    titleBar:SetBackdropBorderColor(0, 0, 0, 0)
    titleBar:SetBackdropColor(0, 0, 0, 1)
    titleBar:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -2)
    titleBar:SetShown(true)
    self.tblFrame.titleBar = titleBar

    local title = self.tblFrame.title or titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    title:SetText(L['TITLE'])
    title:SetPoint('LEFT', titleBar, 'LEFT', 8, 0)
    title:SetShown(true)

    local closeButton = self.tblFrame.closeButton or CreateFrame('Button', 'GG_BaseCloseButton', titleBar, 'UIPanelCloseButton')
    closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -5, 0)
    closeButton:SetScript('OnClick', function()
        ns.observer:Notify('CLOSE_SCREENS')
        logs:SetShown(false)
        f:SetShown(false)
    end)
    closeButton:SetShown(true)

    local lockIcon = self.tblFrame.lockIcon or CreateFrame('Button', 'GG_BaseLockIcon', titleBar, 'BackdropTemplate')
    lockIcon:SetSize(20, 20)
    lockIcon:SetPoint('TOPRIGHT', closeButton, 'TOPLEFT', -5, 0)
    lockIcon:SetNormalTexture(GG.locked)
    lockIcon:SetHighlightTexture(BLUE_HIGHLIGHT)
    lockIcon:SetScript('OnClick', function()
        self.isMoveLocked = not self.isMoveLocked
        f:SetMovable(not self.isMoveLocked)
        lockIcon:SetNormalTexture(self.isMoveLocked and GG.locked or GG.Unlocked)
    end)
    lockIcon:SetShown(true)

    --* Build Status Bar
    local statusBar = self.tblFrame.statusBar or CreateFrame('Frame', 'GG_BaseFrame_TitleBar', f, 'BackdropTemplate')
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

    -- Create a horizontal line across the top of the statusBar
    local cDefault, cActive = {1, 1, 1, 1}, {0, 1, 0, 1}
    local cDefaultHighlight, cActiveHighlight = {0.7, 0.7, 0.7, 1}, {0, 0.7, 0, 1}
    local topLine = statusBar:CreateTexture(nil, "OVERLAY")
    topLine:SetColorTexture(0.5, 0.5, 0.5, 1) -- Set the line color (white in this case)
    topLine:SetHeight(.5) -- Set the line thickness
    topLine:SetPoint("TOPLEFT", statusBar, "TOPLEFT", 5, 0)
    topLine:SetPoint("TOPRIGHT", statusBar, "TOPRIGHT", -5, 0)

    local logsButton = f:CreateFontString(nil, 'OVERLAY', 'GameFontDisableMed3')
    logsButton:SetText('Logs')
    logsButton:SetTextColor(1, 1, 1)
    logsButton:SetPoint('RIGHT', statusBar, 'RIGHT', -5, 2)
    logsButton:SetShown(true)
    logsButton:SetScript('OnMouseDown', function()
        self.logsActive = not self.logsActive
        local c = self.logsActive and cActive or cDefault
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])

        logs:SetShown(self.logsActive)
        logs:PositionLogScreen()
    end)
    logsButton:SetScript('OnEnter', function()
        local c = self.logsActive and cActiveHighlight or cDefaultHighlight
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])
    end)
    logsButton:SetScript('OnLeave', function()
        local c = self.logsActive and cActive or cDefault
        logsButton:SetTextColor(c[1], c[2], c[3], c[4])
    end)
    self.tblFrame.logsButton = logsButton

    --* App Area Frame for Games
    local middleFrame = self.tblFrame.middleFrame or CreateFrame('Frame', 'GG_BaseOutputFrame', f, 'BackdropTemplate')
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
    self.tblFrame.middleFrame = middleFrame
    ns.gameFrame = middleFrame
end

--* Game Menu DropDownS
function base:CreateMenu()
    -- Create a frame for the dropdown menu
    local dropdownFrame = CreateFrame("Frame", "MyDropdownMenu", base.tblFrame.titleBar, "UIDropDownMenuTemplate")
    dropdownFrame:SetPoint('CENTER', base.tblFrame.titleBar, 'CENTER', 0, 0)

    -- Set default text before an item is selected
    UIDropDownMenu_SetText(dropdownFrame, "Select a Game")
    UIDropDownMenu_SetWidth(dropdownFrame, 200)

    -- Center the default text
    local dropdownText = _G[dropdownFrame:GetName().."Text"]
    dropdownText:ClearAllPoints()
    dropdownText:SetPoint("CENTER", dropdownFrame, "CENTER", 0, 2)
    dropdownText:SetJustifyH("CENTER")

    self.tblMenu.frame = dropdownFrame

    -- Initialize the dropdown menu
    UIDropDownMenu_Initialize(dropdownFrame, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        if level == 1 then
            for _, item in ipairs(base.menuEntries) do
                info.text = item.text
                info.notCheckable = item.notCheckable
                info.hasArrow = item.hasArrow
                info.menuList = item.menuList
                info.func = item.func
                UIDropDownMenu_AddButton(info)
            end
        elseif menuList then
            for _, childItem in ipairs(menuList) do
                info.text = childItem.text
                info.notCheckable = childItem.notCheckable
                info.func = childItem.func
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
end
base:Init()

--* Logs Routine
function logs:Init()
    self.logEntries = {}
    self.logsActive = false

    self.tblLogs = {}
end
function logs:SetShown(val)
    if self.tblLogs.frame then self.tblLogs.frame:SetShown(val) end
    if not val then
        base.logsActive = false
        base.tblFrame.logsButton:SetTextColor(1, 1, 1, 1)
        return
    elseif self.tblLogs.frame then return end

    self:CreateLogsFrame()
    self:PositionLogScreen()
end
function logs:CreateLogsFrame()
    local f = self.tblLogs.frame or CreateFrame('Frame', 'GG_LogsFrame', UIParent, 'BackdropTemplate')
    f:SetSize(base.tblFrame.frame:GetWidth(), 150)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:SetPoint(base.screenPos.point, base.screenPos.x, base.screenPos.y)
    f:EnableMouse(false)
    f:RegisterForDrag('LeftButton')
    f:SetShown(true)
    self.tblLogs.frame = f

    --* Build Title Bar
    local titleBar = self.tblLogs.titleBar or CreateFrame('Frame', 'GG_LogsFrame_TitleBar', f, 'BackdropTemplate')
    titleBar:SetSize(f:GetWidth() - 4, 35)
    titleBar:SetBackdrop(BackdropTemplate())
    titleBar:SetBackdropBorderColor(0, 0, 0, 0)
    titleBar:SetBackdropColor(0, 0, 0, 1)
    titleBar:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -2)
    titleBar:SetShown(true)
    self.tblLogs.titleBar = titleBar

    local title = self.tblLogs.title or titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    title:SetText('Logs')
    title:SetPoint('LEFT', titleBar, 'LEFT', 8, 0)
    title:SetShown(true)
    ns.logsTitle = title

    local closeButton = self.tblLogs.closeButton or CreateFrame('Button', 'GG_LogsCloseButton', titleBar, 'UIPanelCloseButton')
    closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -5, 0)
    closeButton:SetScript('OnClick', function() self:SetShown(false) end)
    closeButton:SetShown(true)

    -- Create log window frame
    local logFrame = self.tblLogs.logFrame or CreateFrame('ScrollFrame', 'GG_LogsLogFrame', f, 'UIPanelScrollFrameTemplate')
    logFrame:SetPoint('TOPLEFT', titleBar, 'BOTTOMLEFT', 10, 0)
    logFrame:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -30, 10)
    logFrame:SetShown(true)
    self.tblLogs.logFrame = logFrame

    local logsContentFrame = self.tblLogs.contentFrame or CreateFrame('Frame', 'GG_BaseLogsContentFrame', logFrame)
    logsContentFrame:SetSize(logFrame:GetWidth(), logFrame:GetHeight())  -- Adjust height depending on content size
    logFrame:SetScrollChild(logsContentFrame)
    logsContentFrame:SetShown(true)
    self.tblLogs.contentFrame = logsContentFrame
end

--* Logs Interaction
function logs:ResetLogs()
    self:ClearLogs()
    self.tblLogs.title:SetText('Logs')
end
function logs:ClearLogs()
    self.logEntries = table.wipe(self.logEntries)
    local logsFrame = self.tblLogs.contentFrame
    for _, child in ipairs({logsFrame:GetRegions()}) do
        child:SetText('')
        child:Hide()
        child:SetParent(nil)
    end
    logsFrame:SetHeight(0)
end
function logs:AddLogEntry(entry, color)
    local lineSpacing = 15
    local logsFrame = self.tblLogs.contentFrame
    local formattedTime = date("%H:%M:%S", GetServerTime())
    -- Add the new entry to the logEntries table
    local text = color and ns.code:cText(color, entry) or entry
    table.insert(self.logEntries, text)

    -- Create a new FontString for the log entry
    local logEntry = logsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logEntry:SetText(formattedTime..': '..text)
    logEntry:SetPoint("TOPLEFT", logsFrame, "TOPLEFT", 10, -lineSpacing * (#self.logEntries - 1))
    logEntry:SetWidth(logsFrame:GetWidth() - 20)
    logEntry:SetJustifyH("LEFT")

    -- Adjust the content frame height to accommodate the new entry
    logsFrame:SetHeight(lineSpacing * #self.logEntries)
    self.tblLogs.logFrame:UpdateScrollChildRect()

    -- Scroll to the bottom to show the latest entry
    self.tblLogs.logFrame:SetVerticalScroll(self.tblLogs.logFrame:GetVerticalScrollRange())
end

--* Other MenuRoutines
function logs:PositionLogScreen()
    if not self.tblLogs.frame then return end

    local f = self.tblLogs.frame
    local firstFrameBottom = base.tblFrame.frame:GetBottom()
    local secondFrameHeight = f:GetHeight()

    -- Calculate the position
    f:ClearAllPoints()
    if firstFrameBottom and (firstFrameBottom - secondFrameHeight < 0) then
        -- Place the second frame above the first frame
        f:SetPoint("BOTTOM", base.tblFrame.frame, "TOP", 0, 0)
    else
        -- Place the second frame below the first frame
        f:SetPoint("TOP", base.tblFrame.frame, "BOTTOM", 0, 0)
    end
end
logs:Init()