local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.win = {}
ns.win.base = {}
local base = ns.win.base

--! Create Saved Data on Players in Guild

local function OnDragStart(self)
    if ns.win.base.isMoveLocked then return end
    self:StartMoving()
end
local function OnDragStop(self)
    self:StopMovingOrSizing()

    ns.win.base.screenPos.point,_,_, ns.win.base.screenPos.x, ns.win.base.screenPos.y = self:GetPoint()
    ns.pSettings.screenPos = ns.win.base.screenPos
    base:CreateLogsFrame()
end

function base:Init()
    self.logEntries = {}
    self.logsActive = false

    self.screenPos = nil
    self.isMoveLocked = true

    self.tblMenu = {
        {
            name = 'Dice Games', value = function() return 'SET_TOGGLE' end,
            children = {
                { name = L['SURVIVOR'],
                    value = function() ns.win.diceSurvivor:SetShown(true) end,
                    tooltip = function()
                        ns.code:createTooltip(L['SURVIVOR'], L['SURVIVOR_DESC'], true)
                    end
                },
                {
                    name = L['HIGH_ROLLER'],
                    value = function() self:LoadGame('HIGH_ROLLER') end,
                    tooltip = function()
                        ns.code:createTooltip(L['HIGH_ROLLER'], L['HIGH_ROLLER_DESC'], true)
                    end,
                },
                {
                    name = L['DICE_RACE'],
                    value = function() self:LoadGame('DICE_RACE') end,
                    tooltip = function()
                        ns.code:createTooltip(L['DICE_RACE'], L['DICE_RACE_DESC'], true)
                    end,
                },
                {
                    name = L['TARGET_PRACTICE'],
                    value = function() self:LoadGame('TARGET_PRACTICE') end,
                    tooltip = function()
                        ns.code:createTooltip(L['TARGET_PRACTICE'], L['TARGET_PRACTICE_DESC'], true)
                    end,
                },
            }
        }
    }
    self.tblFrame = {}
end
function base:SetShown(val)
    if not val then
        self.tblFrame.frame:SetShown(false)
    end

    self.screenPos = ns.pSettings.screenPos or {point = 'CENTER', x = 0, y = 0}

    if not self.tblFrame.frame then
        --* Build the base frame
        self:CreateBaseFrame()
        self:CreateMenuFrame()
        self:CreateLogsFrame()

        GGMenu:CreateMenu(self.tblMenu, self.tblFrame.menuFrame)
        GGMenu:UpdateMenuPositions()
    end

    self.tblFrame.frame:SetShown(true)
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

    --* Build the title bar
    local tf = self.tblFrame.tf or CreateFrame('Frame', 'GG_BaseTitleFrame', f, 'BackdropTemplate')
    tf:SetSize(f:GetWidth(), 35)
    tf:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND, nil))
    tf:SetBackdropColor(0, 0, 0, 0.5)
    tf:SetBackdropBorderColor(0, 0, 0, 0)
    tf:SetFrameStrata(DEFAULT_STRATA)
    tf:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
    tf:SetShown(true)
    self.tblFrame.titleFrame = tf

    local title = self.tblFrame.title or tf:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    title:SetText(L['TITLE'])
    title:SetPoint('LEFT', tf, 'LEFT', 8, 0)
    title:SetShown(true)
    self.tblFrame.title = title

    local closeButton = self.tblFrame.closeButton or CreateFrame('Button', 'GG_BaseCloseButton', tf, 'UIPanelCloseButton')
    closeButton:SetPoint('RIGHT', tf, 'RIGHT', -5, 0)
    closeButton:SetScript('OnClick', function() f:Hide() end)
    closeButton:SetShown(true)
    self.tblFrame.closeButton = closeButton

    local lockIcon = self.tblFrame.lockIcon or CreateFrame('Button', 'GG_BaseLockIcon', tf, 'BackdropTemplate')
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
    self.tblFrame.lockIcon = lockIcon
end
function base:CreateMenuFrame()
    local f = self.tblFrame.frame

    local mf = self.tblFrame.menuFrame or CreateFrame('Frame', 'GG_BaseMenuFrame', f, 'BackdropTemplate')
    mf:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 10, 3)
    mf:SetPoint('BOTTOMRIGHT', self.tblFrame.titleFrame, 'BOTTOMRIGHT', f:GetWidth() * -0.7, 0) -- 70% empty space
    mf:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    mf:SetBackdropColor(1, 1, 1, 0)
    mf:SetBackdropBorderColor(1, 1, 1, 0)
    mf:SetShown(true)
    self.tblFrame.menuFrame = mf

    local line = mf:CreateTexture(nil, "OVERLAY")
    line:SetColorTexture(.5, .5, .5, 1)  -- Set the color of the line (R, G, B, A)
    line:SetPoint("TOPRIGHT", mf, "TOPRIGHT", 0, 0)  -- Align the top of the line to the top of the frame
    line:SetPoint("BOTTOMRIGHT", mf, "BOTTOMRIGHT", 0, 5)  -- Align the bottom of the line to the bottom of the frame
    line:SetWidth(2)  -- Set the width of the line (in pixels)
    line:SetShown(true)

    local of = self.tblFrame.outputFrame or CreateFrame('Frame', 'GG_BaseOutputFrame', f, 'BackdropTemplate')
    of:SetPoint('TOPLEFT', mf, 'TOPRIGHT', 5, 0)
    of:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -5, 10)
    of:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    of:SetBackdropColor(1, 1, 1, 0)
    of:SetBackdropBorderColor(1, 1, 1, 0)
    of:SetShown(true)
    self.tblFrame.outputFrame = of
end
function base:CreateLogsFrame()
    local f = self.tblFrame.frame
    self.tblFrame.logs = self.tblFrame.logs or {}

    -- Determine the screen height and the position of 'f'
    local fBottom = f:GetBottom() -- The bottom Y-coordinate of 'f'
    local logsHeight = 150 -- Desired height of the logs frame

    --* Build the logs frame
    local logs = self.tblFrame.logs.frame or CreateFrame('Frame', 'GG_BaseLogsFrame', f, 'BackdropTemplate')
    logs:ClearAllPoints()
    if fBottom and (fBottom - logsHeight - 5) > 0 then logs:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 0, -5)
    else logs:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 0, 5) end
    logs:SetWidth(f:GetWidth())
    logs:SetHeight(logsHeight)
    logs:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    logs:SetBackdropColor(0, 0, 0, .7)
    logs:SetBackdropBorderColor(1, 1, 1, 1)
    logs:SetFrameStrata(DEFAULT_STRATA)
    logs:SetShown(self.logsActive)
    self.tblFrame.logs.frame = logs

    --* Build the logs title bar
    local logsTitle = self.tblFrame.logs.title or CreateFrame('Frame', 'GG_BaseLogsTitleFrame', logs, 'BackdropTemplate')
    logsTitle:SetSize(logs:GetWidth(), 20)
    logsTitle:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND, nil))
    logsTitle:SetBackdropColor(0, 0, 0, 0.5)
    logsTitle:SetBackdropBorderColor(0, 0, 0, 0)
    logsTitle:SetFrameStrata(DEFAULT_STRATA)
    logsTitle:SetPoint('TOPLEFT', logs, 'TOPLEFT', 0, 0)
    logsTitle:SetShown(true)

    local logsTitleText = self.tblFrame.logs.titleText or logsTitle:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    logsTitleText:SetText('Logs')
    logsTitleText:SetPoint('CENTER', logsTitle, 'CENTER', 8, 0)
    logsTitleText:SetShown(true)
    self.tblFrame.logs.titleText = logsTitleText

    --* Build the logs scroll frame
    local logsScrollFrame = self.tblFrame.logs.scrollFrame or CreateFrame('ScrollFrame', 'GG_BaseLogsScrollFrame', logs, 'UIPanelScrollFrameTemplate')
    logsScrollFrame:SetPoint('TOPLEFT', logs, 'TOPLEFT', 10, -25)
    logsScrollFrame:SetPoint('BOTTOMRIGHT', logs, 'BOTTOMRIGHT', -30, 10)
    logsScrollFrame:SetShown(true)
    self.tblFrame.logs.scrollFrame = logsScrollFrame

    --* Build the logs content frame
    local logsContentFrame = self.tblFrame.logs.contentFrame or CreateFrame('Frame', 'GG_BaseLogsContentFrame', logsScrollFrame)
    logsContentFrame:SetSize(logs:GetWidth() - 40, logsHeight)  -- Adjust height depending on content size
    logsScrollFrame:SetScrollChild(logsContentFrame)
    logsContentFrame:SetShown(true)
    self.tblFrame.logs.contentFrame = logsContentFrame

    --* Build the logs clickable Text object
    local logsText = self.tblFrame.logs.logsText or f:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    logsText :SetText('Logs')
    logsText :SetTextColor(0.5, 0.5, 0.5)
    logsText :SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 10, 10)
    logsText :SetShown(true)
    logsText:SetScript("OnMouseDown", function()
        self.logsActive = not self.logsActive
        self:CreateLogsFrame()
        self.tblFrame.logs.logsText:SetTextColor(self.logsActive and 0 or 0.5, self.logsActive and 1 or 0.5, self.logsActive and 0 or 0.5)
    end)
    self.tblFrame.logs.logsText = logsText
end
function base:ClearLogs()
    self.logEntries = table.wipe(self.logEntries)
    local logsFrame = self.tblFrame.logs.contentFrame
    for _, child in ipairs({self.tblFrame.logs.contentFrame:GetRegions()}) do
        child:SetText('')
        child:Hide()
        child:SetParent(nil)
    end
    logsFrame:SetHeight(0)
end
function base:AddLogEntry(text)
    local logsFrame = self.tblFrame.logs.contentFrame
    -- Add the new entry to the logEntries table
    table.insert(self.logEntries, text)

    -- Create a new FontString for the log entry
    local entry = logsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entry:SetText(text)
    entry:SetPoint("TOPLEFT", logsFrame, "TOPLEFT", 10, -20 * (#self.logEntries - 1))
    entry:SetWidth(logsFrame:GetWidth() - 20)
    entry:SetJustifyH("LEFT")

    -- Adjust the content frame height to accommodate the new entry
    logsFrame:SetHeight(20 * #self.logEntries)

    -- Scroll to the bottom to show the latest entry
    self.tblFrame.logs.scrollFrame:SetVerticalScroll(self.tblFrame.logs.scrollFrame:GetVerticalScrollRange())
end
--* Menu Creation
function base:LoadGame(game)
    ns.code:cOut('Loading game: '..game, 'FF00FF00')
end
function base:MenuRoutines()
    local tblFunc = {}
    local menuTextItems = {}

    function tblFunc:CreateMenuText(name, parent, level, tooltip)
        -- Create the text object
        local text = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetText(name)
        text:SetPoint("LEFT", parent, "LEFT", 10 * level, 0)  -- Indent based on level

        -- Create the highlight texture
        local highlight = parent:CreateTexture(BLUE_HIGHLIGHT, "BACKGROUND")
        highlight:SetColorTexture(.5, .5, .5, 0.3)  -- Yellow color with 30% opacity
        highlight:SetPoint("LEFT", text, "LEFT", -5, 0)  -- Align with text
        highlight:SetPoint("RIGHT", text, "RIGHT", 5, 0)  -- Stretch to the right edge
        highlight:SetHeight(20)  -- Height of the highlight
        highlight:Hide()  -- Initially hide the highlight

        text:SetScript("OnEnter", function()
            if tooltip then tooltip() end
            highlight:Show()  -- Show the highlight when the mouse enters
        end)
        text:SetScript("OnLeave", function()
            GameTooltip:Hide()
            highlight:Hide()  -- Hide the highlight when the mouse leaves
        end)
        return text
    end
    function tblFunc:CreateExpandCollapseButton(text)
        local button = text:GetParent():CreateFontString(nil, "OVERLAY", "GameFontNormalMed2Outline")
        button:SetText("+")
        button:SetPoint("RIGHT", text, "LEFT", 0, 0)
        return button
    end
    function tblFunc:UpdateMenuPositions()
        local yOffset = 0
        for _, textItem in ipairs(menuTextItems) do
            if textItem:IsShown() then
                textItem:SetPoint("TOPLEFT", ns.win.base.tblFrame.menuFrame, "TOPLEFT", 10, yOffset)
                yOffset = yOffset - 20
            end
        end
    end
    function tblFunc:ToggleChildren(parentText, level)
        local isExpanded = parentText.isExpanded

        if isExpanded then
            -- Hide children
            for _, childText in ipairs(menuTextItems) do
                if childText.level > level and childText.parent == parentText then
                    childText:Hide()
                    if childText.expandButton then
                        childText.expandButton:Hide()
                    end
                end
            end
            parentText.expandButton:SetText("+")
        else
            -- Show children
            for _, childText in ipairs(menuTextItems) do
                if childText.level == level + 1 and childText.parent == parentText then
                    childText:Show()
                    if childText.expandButton then
                        childText.expandButton:Show()
                    end
                end
            end
            parentText.expandButton:SetText("-")
        end

        parentText.isExpanded = not isExpanded
        tblFunc:UpdateMenuPositions()
    end
    function tblFunc:CreateMenu(menuItems, parentFrame, level, parentText)
        level = level or 0

        for _, item in ipairs(menuItems) do
            local text = tblFunc:CreateMenuText(item.name, parentFrame, level, item.tooltip)
            text.level = level
            text.parent = parentText
            text:SetScript("OnMouseDown", function()
                local func = item.value()
                if not func then return end

                if func == 'SET_TOGGLE' then
                    tblFunc:ToggleChildren(text, level)
                    return
                else func() end
            end)

            table.insert(menuTextItems, text)

            if item.children then
                local expandButton = tblFunc:CreateExpandCollapseButton(text)
                text.expandButton = expandButton
                text.isExpanded = false
                expandButton:SetText("+")
                expandButton:SetScript("OnMouseDown", function()
                    tblFunc:ToggleChildren(text, level)
                end)

                -- Recursively create children, but hide them initially
                tblFunc:CreateMenu(item.children, parentFrame, level + 1, text)
                for _, childText in ipairs(menuTextItems) do
                    if childText.level > level then
                        childText:Hide()
                    end
                end
            end
        end
    end

    return tblFunc
end
base:Init()

GGMenu = base:MenuRoutines()