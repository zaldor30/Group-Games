local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.logs = {}
local logs = ns.logs

function logs:Init()
    self.logsActive = false

    self.tblFrame = {}
    self.logEntries = {}
end
function logs:SetShown(val, start)
    local base = ns.base.tblFrame

    if not start then self.logsActive = val end
    if not val and not start then
        self.tblFrame.frame:Hide()
        base.logsButton:SetTextColor(1, 1, 1, 1)
        return
    end

    if not self.tblFrame.frame then
        self:CreateLogsFrame()
        self:CreateEntryFrame()
        self.tblFrame.frame:SetShown(false)
        if start then
            self:AddLogEntry('Group Games '..GG.versionOut..' Started', DEFAULT_CHAT_COLOR)
            self:AddLogEntry('Logs Started.', 'FF00FF00')
            return
        end
    end

    self:PositionLogScreen()
    self.tblFrame.frame:SetShown(not start)
end
function logs:CreateLogsFrame()
    local base = ns.base.tblFrame

    local f = self.tblFrame.frame or CreateFrame('Frame', 'GG_LogsFrame', UIParent, 'BackdropTemplate')
    f:SetSize(base.frame:GetWidth(), 150)
    f:SetBackdrop(BackdropTemplate())
    f:SetFrameStrata(DEFAULT_STRATA)
    f:SetClampedToScreen(true)
    f:EnableMouse(false)
    f:SetShown(true)
    self.tblFrame.frame = f

    --* Build Title Bar
    local titleBar = self.tblFrame.titleBar or CreateFrame('Frame', 'GG_LogsFrame_TitleBar', f, 'BackdropTemplate')
    titleBar:SetSize(f:GetWidth() - 4, 35)
    titleBar:SetBackdrop(BackdropTemplate())
    titleBar:SetBackdropBorderColor(0, 0, 0, 0)
    titleBar:SetBackdropColor(0, 0, 0, 1)
    titleBar:SetPoint('TOPLEFT', f, 'TOPLEFT', 2, -2)
    titleBar:SetShown(true)
    self.tblFrame.titleBar = titleBar

    local title = self.tblFrame.title or titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    title:SetText('Logs')
    title:SetPoint('LEFT', titleBar, 'LEFT', 8, 0)
    title:SetShown(true)
    ns.logsTitle = title

    local closeButton = self.tblFrame.closeButton or CreateFrame('Button', 'GG_LogsCloseButton', titleBar, 'UIPanelCloseButton')
    closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -5, 0)
    closeButton:SetSize(20, 20)
    closeButton:SetScript('OnClick', function() self:SetShown(false) end)
    closeButton:SetShown(true)
end
function logs:CreateEntryFrame()
    local f = self.tblFrame

    local insetFrame = CreateFrame("Frame", "InsetFrame", f.frame, "BackdropTemplate")
    insetFrame:SetPoint('TOPLEFT', f.titleBar, 'BOTTOMLEFT', 5, 0)
    insetFrame:Size(f.frame:GetWidth() - 15, f.frame:GetHeight() - 45)

    -- Set the backdrop for the inset frame (opaque white or any desired color)
    insetFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 12,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    insetFrame:SetBackdropColor(1, 1, 1, 1)  -- Opaque white
    insetFrame:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)  -- Light gray border

    -- Create the scroll frame inside the inset frame
    local logScrollFrame = CreateFrame("ScrollFrame", "InsetScrollFrame", insetFrame, "UIPanelScrollFrameTemplate")
    logScrollFrame:SetSize(insetFrame:GetWidth() - 20, insetFrame:GetHeight() - 20)  -- Leave space for the scrollbar
    logScrollFrame:SetPoint("TOPLEFT", insetFrame, "TOPLEFT", 10, -10)  -- Position it with some padding
    f.logFrame = logScrollFrame

    -- Create the content frame inside the scroll frame
    local contentFrame = CreateFrame("Frame", "InsetContentFrame", logScrollFrame)
    contentFrame:SetSize(logScrollFrame:GetWidth(), 15)  -- Double the height for scroll demonstration
    logScrollFrame:SetScrollChild(contentFrame)
    f.contentFrame = contentFrame

    local scrollBar = _G[logScrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()  -- Hide the scrollbar initially
end

--* Other MenuRoutines
function logs:PositionLogScreen()
    if not self.tblFrame.frame then return end

    local f = self.tblFrame.frame
    local base = ns.base.tblFrame.frame
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
function logs:AddLogEntry(entry, color)
    local lineSpacing = 15
    local logsContentFrame = self.tblFrame.contentFrame
    local formattedTime = date("%H:%M:%S", GetServerTime())
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
    self.tblFrame.logFrame:SetHeight(logHeight)
    self.tblFrame.logFrame:UpdateScrollChildRect()

    -- Scroll to the bottom to show the latest entry
    self.tblFrame.logFrame:SetVerticalScroll(self.tblFrame.logFrame:GetVerticalScrollRange())
end
function logs:ClearLogs()
    self.logEntries = table.wipe(self.logEntries)
    local logsFrame = self.tblFrame.contentFrame
    for _, child in ipairs({logsFrame:GetRegions()}) do
        child:SetText('')
        child:Hide()
        child:SetParent(nil)
    end
    self.tblFrame.logFrame:SetHeight(0)
end
logs:Init()