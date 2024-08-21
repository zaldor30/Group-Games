local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.logs = {}
local logs = ns.logs

--* Logs Routine
function logs:Init()
    self.logEntries = {}
    self.logsActive = false

    self.tblLogs = {}
end
function logs:SetShown(val, start)
    local base = ns.base.bFrame

    if self.tblLogs.frame then self.tblLogs.frame:SetShown(val) end
    if not val and not start then
        self.logsActive = false
        base.logsButton:SetTextColor(1, 1, 1, 1)
        return
    elseif self.tblLogs.frame then return end

    if not self.tblLogs.frame then self:CreateLogsFrame() end
    self:PositionLogScreen()

    if start then
        self:AddLogEntry('Group Games '..GG.versionOut..' Started', DEFAULT_CHAT_COLOR)
        self:AddLogEntry('Logs Started.', 'FF00FF00')
    end

    self.tblLogs.frame:SetShown(self.logsActive)
end
function logs:CreateLogsFrame()
    local base = ns.base.bFrame

    local f = self.tblLogs.frame or CreateFrame('Frame', 'GG_LogsFrame', UIParent, 'BackdropTemplate')
    f:SetSize(base.frame:GetWidth(), 150)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
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
    closeButton:SetSize(20, 20)
    closeButton:SetScript('OnClick', function() self:SetShown(false) end)
    closeButton:SetShown(true)

    -- Create log scroll frame
    local logScrollFrame = self.tblLogs.logFrame or CreateFrame('ScrollFrame', 'GG_LogsLogFrame', f, 'UIPanelScrollFrameTemplate')
    logScrollFrame:SetPoint('TOPLEFT', titleBar, 'BOTTOMLEFT', 10, 0)
    logScrollFrame:SetWidth(f:GetWidth() - 40)
    logScrollFrame:SetShown(true)
    self.tblLogs.logFrame = logScrollFrame

    local scrollBar = _G[logScrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()  -- Hide the scrollbar initially

    local logsContentFrame = self.tblLogs.contentFrame or CreateFrame('Frame', 'GG_BaseLogsContentFrame', logScrollFrame)
    logsContentFrame:SetSize(logScrollFrame:GetWidth(), 15)  -- Adjust height depending on content size
    logScrollFrame:SetScrollChild(logsContentFrame)
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
    self.tblLogs.logFrame:SetHeight(0)
end
function logs:AddLogEntry(entry, color)
    local lineSpacing = 15
    local logsContentFrame = self.tblLogs.contentFrame
    local formattedTime = date("%H:%M:%S", GetServerTime())
    -- Add the new entry to the logEntries table
    local text = color and ns.code:cText(color, entry) or entry
    table.insert(self.logEntries, text)

    -- Create a new FontString for the log entry
    local logEntry = logsContentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    logEntry:SetText(formattedTime..': '..text)
    logEntry:SetPoint("TOPLEFT", logsContentFrame, "TOPLEFT", 10, -lineSpacing * (#self.logEntries - 1))
    logEntry:SetWidth(logsContentFrame:GetWidth() - 20)
    logEntry:SetJustifyH("LEFT")
    logEntry:SetWordWrap(false)

    -- Adjust the content frame height to accommodate the new entry
    local logHeight = lineSpacing * #self.logEntries
    self.tblLogs.logFrame:SetHeight(logHeight)
    self.tblLogs.logFrame:UpdateScrollChildRect()

    -- Scroll to the bottom to show the latest entry
    self.tblLogs.logFrame:SetVerticalScroll(self.tblLogs.logFrame:GetVerticalScrollRange())
end

--* Other MenuRoutines
function logs:PositionLogScreen()
    if not self.tblLogs.frame then return end

    local f = self.tblLogs.frame
    local base = ns.base.bFrame.frame
    local firstFrameBottom = base:GetBottom()
    local secondFrameHeight = f:GetHeight()

    -- Calculate the position
    f:ClearAllPoints()
    if firstFrameBottom and (firstFrameBottom - secondFrameHeight < 0) then
        -- Place the second frame above the first frame
        f:SetPoint("BOTTOM", base, "TOP", 0, 0)
    else
        -- Place the second frame below the first frame
        f:SetPoint("TOP", base, "BOTTOM", 0, 0)
    end
end
logs:Init()