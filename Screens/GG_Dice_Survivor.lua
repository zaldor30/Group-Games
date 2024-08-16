local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.win.diceSurvivor = {}
local diceSurvivor = ns.win.diceSurvivor

local function obsLOGS_STATE(action, ...)
    if action == 'CLEAR_LOGS' then ns.win.base:ClearLogs()
    elseif action == 'ADD_LOG_ENTRY' then ns.win.base:AddLogEntry(...) end
end
local function obsCLOSE_SCANNER()
    ns.observer:Unregister('LOGS_STATE', obsLOGS_STATE)
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    diceSurvivor:SetShown(false)
end

function diceSurvivor:Init()
    self.isGameRunning = false
    self.waitingPlayers = 0

    self.tblFrame = {}
    self.tblRolls = {}
    self.tblRound = {}
end
function diceSurvivor:SetShown(val)
    if ns.core.isGameRunning then
        ns.code:fOut(ns.core.runningGame..' is currently running. Please wait until the game is over.')
        return
    end
    if not val then
        ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)

        ns.core.runningGame = nil
        ns.core.isGameRunning = false

        ns.win.base:SetShown(false)
        self.tblFrame.frame:SetShown(false)
        return
    end

    ns.core.runningGame = 'Survivor'
    self.waitingPlayers = ns.gSettings.waitTimeForPlayers or 10

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('LOGS_STATE', obsLOGS_STATE)
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    self:CreateFrame()
    self:CreateRollFrame()

    ns.observer:Notify('LOGS_STATE', 'CLEAR_LOGS')
    ns.win.base.tblFrame.logs.titleText:SetText(L['SURVIVOR']..' Logs')
    ns.observer:Notify('LOGS_STATE', 'ADD_LOG_ENTRY', 'Game Started: Survivor')
    ns.observer:Notify('LOGS_STATE', 'ADD_LOG_ENTRY', 'Bet Amount: '..ns.code:FormatNumberWithCommas(self.tblRound.bet))
end
function diceSurvivor:CreateFrame()
    local of = ns.win.base.tblFrame.outputFrame

    local frame = CreateFrame('Frame', 'GG_Dice_Survivor', of, 'BackdropTemplate')
    frame:SetPoint('TOPLEFT', of, 'TOPLEFT', 0, 0)
    frame:SetPoint('BOTTOMRIGHT', of, 'BOTTOMRIGHT', 0, 0)
    frame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    frame:SetBackdropColor(1, 1, 1, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    frame:SetFrameStrata('DIALOG')
    frame:SetShown(true)

    frame.title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
    frame.title:SetPoint('TOP', frame, 'TOP', 0, -10)
    frame.title:SetText(L['SURVIVOR'])

    self.tblFrame.frame = frame
end
function diceSurvivor:CreateRollFrame()
    local frame = self.tblFrame.frame

    local rollFrame = CreateFrame('Frame', 'GG_Dice_Survivor_Roll', frame, 'BackdropTemplate')
    rollFrame:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -40)
    rollFrame:SetPoint('BOTTOM', frame, 'BOTTOM', -10, 10)
    rollFrame:SetWidth(175)
    rollFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    rollFrame:SetBackdropColor(1, 1, 1, 0)
    rollFrame:SetBackdropBorderColor(1, 1, 1, 1)
    rollFrame:SetFrameStrata('DIALOG')
    rollFrame:SetShown(true)

    -- Create the ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "GG_Dice_Survivor_ScrollFrame", rollFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", rollFrame, "TOPLEFT", 10, -5)  -- Adjust position under the title
    scrollFrame:SetPoint("BOTTOMRIGHT", rollFrame, "BOTTOMRIGHT", -30, 10)  -- Make space for the scrollbar

    -- Create the scrollable content frame
    local contentFrame = CreateFrame("Frame", "GG_Dice_Survivor_ContentFrame", scrollFrame)
    contentFrame:SetSize(rollFrame:GetWidth() - 40, 400)  -- Adjust height depending on content size
    scrollFrame:SetScrollChild(contentFrame)

    self.tblFrame.rollFrame = rollFrame
    self.tblFrame.contentFrame = contentFrame
    diceSurvivor:LoadPlayerRolls()

    -- Create Bet Amount Frame
    local betFrame = CreateFrame('Frame', 'GG_Dice_Survivor_Bet', frame, 'BackdropTemplate')
    betFrame:SetPoint('TOPLEFT', rollFrame, 'TOPRIGHT', 10, 0)
    betFrame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -10, 10)
    betFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    betFrame:SetBackdropColor(1, 1, 1, 0)
    betFrame:SetBackdropBorderColor(1, 1, 1, 1)
    betFrame:SetFrameStrata('DIALOG')
    betFrame:SetShown(true)

    -- Create the Bet Amount Label
    local betLabel = betFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    betLabel:SetPoint('TOPLEFT', betFrame, 'TOPLEFT', 10, -5)
    betLabel:SetText('Bet Amount:')
    betLabel:SetJustifyH('CENTER')

    -- Create the Bet Amount EditBox
    self.tblRound.bet = 10000
    local betEditBox = CreateFrame('EditBox', 'GG_Dice_Survivor_Bet_EditBox', betFrame, 'InputBoxTemplate')
    betEditBox:SetPoint('TOPLEFT', betLabel, 'BOTTOMLEFT', 0, -5)
    betEditBox:SetSize(90, 20)
    betEditBox:SetAutoFocus(false)
    betEditBox:SetText(tostring(self.tblRound.bet))
    betEditBox:SetNumeric(true)
    betEditBox:SetMaxLetters(8)
    betEditBox:SetJustifyH('CENTER')
    betEditBox:SetTextInsets(5, 5, 0, 0)
    betEditBox:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)
    betEditBox:SetScript('OnTextChanged', function(self)
        local bet = type(self:GetText()) ~= 'number' and tonumber(self:GetText()) or self:GetText()
        if bet == '' or not bet and diceSurvivor.tblRound.bet then
            self:SetText(ns.code:FormatNumberWithCommas(diceSurvivor.tblRound.bet))
            return
        end
        diceSurvivor.tblRound.bet = bet
    end)
    betEditBox:SetScript('OnEnter', function(self)
        diceSurvivor.tblRound.oldBet = diceSurvivor.tblRound.bet or nil
    end)
    betEditBox:SetScript('OnLeave', function(self)
        if not diceSurvivor.tblRound.bet or diceSurvivor.tblRound.bet ~= diceSurvivor.tblRound.oldBet then
            diceSurvivor.tblRound.oldBet = diceSurvivor.tblRound.bet
            ns.observer:Notify('LOGS_STATE', 'ADD_LOG_ENTRY', 'Bet Amount: '..ns.code:FormatNumberWithCommas(diceSurvivor.tblRound.bet))
        end
    end)
    self.tblFrame.betEditBox = betEditBox

    -- Create Ask Players Button
    local askButton = CreateFrame('Button', 'GG_Dice_Survivor_Ask', betFrame, 'UIPanelButtonTemplate')
    askButton:SetPoint('TOPLEFT', betEditBox, 'BOTTOMLEFT', 0, -5)
    askButton:SetSize(90, 20)
    askButton:SetText('Ask Players')
    askButton:SetScript('OnClick', function(self)
        ns.core.isGameRunning = true
        ns.observer:Notify('LOGS_STATE', 'ADD_LOG_ENTRY', 'Asking players to join the game.')
        ns.code:SendChatMessage('Next game is Survivor. Bet Amount: '..ns.code:FormatNumberWithCommas(diceSurvivor.tblRound.bet)..' gold.')
        ns.code:SendChatMessage('Type 1 to join the game or 0 to leave the game.')
        betEditBox:Disable()
        self:Disable()

        ns.observer:Notify('LOGS_STATE', 'ADD_LOG_ENTRY', 'Waiting '..diceSurvivor.waitingPlayers..'s for players to join the game.')
        ns.code:CountDowntimer(diceSurvivor.waitingPlayers, 'Please type /roll '..diceSurvivor.tblRound.bet..' now.')
    end)
    self.tblFrame.askButton = askButton
end
function diceSurvivor:LoadPlayerRolls()
    local contentFrame = self.tblFrame.contentFrame

    -- Function to create a row with two columns
    local function CreateContentRow(parent, name, roll, yOffset)
        local row = CreateFrame("Frame", nil, parent)
        row:SetSize(parent:GetWidth(), 20)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

        -- First column (Player Name)
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", row, "LEFT", 0, 0)
        nameText:SetWidth(70)  -- Set width for the first column
        nameText:SetJustifyH(not name:find('Player Name') and "LEFT" or 'CENTER')
        nameText:SetText(UnitClass(name) and ns.code:cPlayer(name, select(2, UnitClass(name))) or name)

        -- Second column (Value or Roll Result)
        local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueText:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
        valueText:SetWidth(50)  -- Set width for the second column
        valueText:SetJustifyH(not name:find('Player Name') and "LEFT" or 'CENTER')
        valueText:SetText(roll)

        return row
    end
    CreateContentRow(contentFrame, 'Player Name', 'Roll', 0)
    CreateContentRow(contentFrame, UnitName('player'), '1000000', -20)
end

--* Game Functions
function diceSurvivor:ResetGame()
    ns.core.isGameRunning = false
    self.tblRound = {}

    self.tblFrame.betEditBox.Enable()
    self.tblFrame.askButton.Enable()
end
diceSurvivor:Init()