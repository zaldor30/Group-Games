local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.diceGames = ns.diceGames or {}
ns.diceGames.highRoller = {}
local highLow = ns.diceGames.highRoller

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    highLow:SetShown(false)
end

function highLow:Init()
    self.version = '1.0'
    self.gSettings = nil

    self.tblGuildPlayers = {}
    self.tblFrame = {}
    self.tblRound = {
        round = 0,
        bet = 0,
        players = {},
        playerCount = 0,
        tieHighCount = 0,
        tieLowCount = 0,
        rowsRoll = {},
    }
end
function highLow:SetShown(val)
    if not val then
        ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)

        ns.core.activeGame = nil
        ns.core.isGameRunning = false
        self.tblFrame.frame:SetShown(false)
        ns.logs:AddLogEntry(L['HIGH_ROLLER']..' (v'..self.version..') - Closed')
    end

    ns.core.activeGame = L['HIGH_ROLLER']

    ns.observer:Notify('CLOSE_SCREENS')
    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    ns.logs:ClearLogs()
    ns.logsTitle:SetText('Logs: '..L['HIGH_ROLLER']..' (v'..self.version..')')

    self.gSettings = ns.gSettings['highRoller'] or {}
    self.tblRound = table.wipe(self.tblRound)

    local betAmount = (self.gSettings['highRoller'] and self.gSettings['highRoller'].potAmount) and self.gSettings['highRoller'].potAmount or 10000
    self.tblRound.bet = betAmount

    self:CreateBaseFrame()
    self:CreateLeftPane()
    self:LoadPlayerRolls()
    self:CreateRightPane()
    self:SetButtons()

    ns.logs:AddLogEntry(L['HIGH_ROLLER']..' (v'..self.version..') - Initialized')
    ns.logs:AddLogEntry(L['POT_AMOUNT']..': '..ns.code:FormatNumberWithCommas(self.tblRound.bet))
end
function highLow:CreateBaseFrame()
    local of = ns.win.base.tblFrame.middleFrame
    local frame = CreateFrame('Frame', 'GG_Dice_HighRoller', of, 'BackdropTemplate')
    frame:SetPoint('TOPLEFT', of, 'TOPLEFT', 0, 0)
    frame:SetPoint('BOTTOMRIGHT', of, 'BOTTOMRIGHT', 0, 0)
    frame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    frame:SetFrameStrata('DIALOG')
    frame:SetShown(true)
    self.tblFrame.frame = frame
end
function highLow:CreateLeftPane()
    local frame = self.tblFrame.frame

    --* Player Rolls Frame
    local playerRolls = CreateFrame('Frame', 'GG_Dice_HighRoller_PlayerRolls', frame, 'BackdropTemplate')
    playerRolls:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, -5)
    playerRolls:SetSize(200, frame:GetHeight()-20)
    playerRolls:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    playerRolls:SetBackdropColor(1, 1, 1, 0)
    playerRolls:SetBackdropBorderColor(1, 1, 1, 1)
    playerRolls:SetFrameStrata('DIALOG')
    playerRolls:SetShown(true)
    self.tblFrame.playerRolls = playerRolls

    --* Player Rolls ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "GG_Dice_HighRoller_PlayerRolls_ScrollFrame", playerRolls, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(playerRolls:GetWidth()-40, playerRolls:GetHeight()-20)  -- Set the size of the scroll frame
    scrollFrame:SetPoint("CENTER", playerRolls, "CENTER", -10, 0)  -- Position it in the center of the screen

    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()

    local contentFrame = CreateFrame("Frame", "GG_Dice_HighRoller_PlayerRolls_ContentFrame", scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 400)
    scrollFrame:SetScrollChild(contentFrame)

    self.tblFrame.playerRolls.contentFrame = contentFrame
end
function highLow:CreateRightPane()
    local frame = self.tblFrame.frame

    --* instructions Frame
    local instructions = CreateFrame('Frame', 'GG_Dice_HighRoller_PlayerRolls', frame, 'BackdropTemplate')
    instructions:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, -5)
    instructions:SetSize(225, 50)
    instructions:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    instructions:SetBackdropColor(1, 1, 1, 0)
    instructions:SetBackdropBorderColor(1, 1, 1, 1)
    instructions:SetFrameStrata('DIALOG')
    instructions:SetShown(true)

    local scrollFrame = CreateFrame("ScrollFrame", "MyScrollableTextFrame", instructions, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(instructions:GetWidth(), instructions:GetHeight())  -- Set the size of the scroll frame
    scrollFrame:SetPoint("CENTER", instructions, "CENTER", 0, 0)  -- Position it in the center of the screen

    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()

    local contentFrame = CreateFrame("Frame", "MyContentFrame", scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 400)

    local text = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -7)  -- Position the text within the content frame
    text:SetWidth(contentFrame:GetWidth() - 20)  -- Make the text fit within the content frame with some padding
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetText(L['HIGH_ROLLER_DESC'])
    local textHeight = text:GetStringHeight()
    contentFrame:SetHeight(textHeight + 10)  -- Add some padding
    scrollFrame:SetScrollChild(contentFrame)

    --* Button Frame
    local buttonFrame = CreateFrame('Frame', 'GG_Dice_HighRoller_PlayerRolls', frame, 'BackdropTemplate')
    buttonFrame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -10, 15)
    buttonFrame:SetPoint('TOPLEFT', instructions, 'BOTTOMLEFT', 0, -5)
    buttonFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    buttonFrame:SetBackdropColor(1, 1, 1, 0)
    buttonFrame:SetBackdropBorderColor(1, 1, 1, 1)
    buttonFrame:SetFrameStrata('DIALOG')
    buttonFrame:SetShown(true)
    self.tblFrame.buttonFrame = buttonFrame

    --* Amount Bet
    -- Create the Bet Amount Label
    local betLabel = buttonFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    betLabel:SetPoint('TOPLEFT', buttonFrame, 'TOPLEFT', 10, -10)
    betLabel:SetText('Bet Amount:')
    betLabel:SetJustifyH('CENTER')

    -- Create the Bet Amount EditBox
    local function updateBet()
        if not highLow.tblRound.bet or highLow.tblRound.bet ~= highLow.tblRound.oldBet then
            highLow.tblRound.oldBet = highLow.tblRound.bet
            ns.logs:AddLogEntry(L['NEW']..' '..L['POT_AMOUNT']..': '..ns.code:FormatNumberWithCommas(highLow.tblRound.bet))
        end
    end

    self.tblRound.bet = 10000
    local betEditBox = CreateFrame('EditBox', 'GG_Dice_Survivor_Bet_EditBox', buttonFrame, 'InputBoxTemplate')
    betEditBox:SetPoint('LEFT', betLabel, 'RIGHT', 5, 0)
    betEditBox:SetSize(90, 20)
    betEditBox:SetAutoFocus(false)
    betEditBox:SetText(tostring(self.tblRound.bet))
    betEditBox:SetNumeric(true)
    betEditBox:SetMaxLetters(8)
    betEditBox:SetJustifyH('CENTER')
    betEditBox:SetTextInsets(5, 5, 0, 0)
    betEditBox:SetScript('OnEnterPressed', function(self)
        self:ClearFocus()
        updateBet()
    end)
    betEditBox:SetScript('OnTextChanged', function(self)
        local bet = type(self:GetText()) ~= 'number' and tonumber(self:GetText()) or self:GetText()
        if bet == '' or not bet then
            self:SetText(tostring(self.tblRound.bet))
            return
        end
        highLow.tblRound.bet = tonumber(bet)
    end)
    betEditBox:SetScript('OnEnter', function(self) highLow.tblRound.oldBet = highLow.tblRound.bet or nil end)
    betEditBox:SetScript('OnLeave', function(self) updateBet() end)
    self.tblFrame.betEditBox = betEditBox

    --* Invite Players Button
    local startFrame, highlight = ns.code:CreateButtonFrame(L['START_GAME'], 'BOTTOMLEFT', buttonFrame, 'BOTTOMLEFT', 10, 10, 100, 25)
    startFrame:SetScript('OnClick', function() self:StartGame() end)
    startFrame:SetScript('OnEnter', function(self)
        highlight:SetShown(true)
        ns.code:createTooltip(L['START_GAME'], L['START_GAME_TOOLTIP'])
    end)
    startFrame:SetScript('OnLeave', function(self)
        highlight:SetShown(false)
        GameTooltip:Hide()
    end)
    self.tblFrame.btnStartGame = startFrame

    --* Cancel Active Game
    local cancelFrame, chighlight = ns.code:CreateButtonFrame(L['CANCEL_GAME'], 'BOTTOMRIGHT', buttonFrame, 'BOTTOMRIGHT', -10, 10, 100, 25)--, 'USE_RED_HIGHLIGHT')
    chighlight:SetVertexColor(1, 0, 0, 1)
    cancelFrame:SetScript('OnClick', function()
        ns.code:Confirmation('Are you sure you want to cancel the round?', function()
            self.tblRound.round = (self.tblRound.round and self.tblRound.round >= 0) and self.tblRound.round - 1 or 1
            ns.logs:AddLogEntry(ns.code:cPlayer(UnitName('player'), UnitClassBase('player'))..ns.code:cText('FFFF0000', ' Stopped the Game'))
            ns.code:SendChatMessage('The game has been cancelled.')
            self:EndGame()
        end)
    end)
    cancelFrame:SetScript('OnEnter', function(self)
        chighlight:SetShown(true)
        ns.code:createTooltip(L['CANCEL_GAME'], L['CANCEL_GAME_TOOLTIP'])
    end)
    cancelFrame:SetScript('OnLeave', function(self)
        chighlight:SetShown(false)
        GameTooltip:Hide()
    end)
    self.tblFrame.btnCancel = cancelFrame

    --* Send Instructions to Chat
    local instFrame, ihighlight = ns.code:CreateButtonFrame(L['SHOW_RULES'], 'BOTTOMLEFT', cancelFrame, 'TOPLEFT', 0, 5, 100, 25)
    instFrame:SetScript('OnClick', function()
        ns.logs:AddLogEntry(L['SHOW_RULES'])
        ns.code:SendChatMessage(L['HIGH_ROLLER_RULES_1'])
        ns.code:SendChatMessage(L['HIGH_ROLLER_RULES_2'])
        ns.code:SendChatMessage(L['HIGH_ROLLER_RULES_3'])
    end)
    instFrame:SetScript('OnEnter', function(self)
        ihighlight:SetShown(true)
        ns.code:createTooltip(L['SHOW_RULES'], L['SHOW_RULES_TOOLTIP'])
    end)
    instFrame:SetScript('OnLeave', function(self)
        ihighlight:SetShown(false)
        GameTooltip:Hide()
    end)
end
function highLow:SetButtons()
    if not self.tblFrame.betEditBox:IsEnabled() then self.tblFrame.betEditBox:Enable() end
    if not self.tblFrame.btnStartGame:IsEnabled() then self.tblFrame.btnStartGame:Enable() end
    if not self.tblFrame.btnCancel:IsEnabled() then self.tblFrame.btnCancel:Enable() end

    if not ns.core.isGameRunning then self.tblFrame.btnCancel:Disable() end
    if ns.core.isGameRunning then
        self.tblFrame.betEditBox:Disable()
        self.tblFrame.btnStartGame:Disable()
    end
end

--* Game Controls
function highLow:clearAllRows()
    self.tblRound.rowsRoll = self.tblRound.rowsRoll or {}
    for _, row in ipairs(self.tblRound.rowsRoll) do
        row:Hide()
        row:SetParent(nil)
    end
    self.tblRound.rowsRoll = table.wipe(self.tblRound.rowsRoll)
    self.tblFrame.playerRolls.contentFrame:SetHeight(0)
end
function highLow:LoadPlayerRolls()
    local contentFrame = self.tblFrame.playerRolls.contentFrame

    local function createContentRow(parent, name, rec, yOffset, isTitle)
        rec = type(rec) == 'table' and rec or {
            roll = rec,
            class = nil,
            isHighest = false,
        }
        local lineSpacing = 20
        local row = CreateFrame("Frame", nil, parent)

        row:SetSize(parent:GetWidth(), lineSpacing)
        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

        local highLight = row:CreateTexture(nil, 'OVERLAY')
        highLight:SetAllPoints(row)
        highLight:SetAtlas('bonusobjectives-bar-bg')
        highLight:SetShown(isTitle or false)

        -- First Column - Player Name
        local nameOut = name:gsub('%-.*', '')
        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameText:SetPoint("LEFT", row, "LEFT", 0, 1)
        nameText:SetWidth(parent:GetWidth() * 0.5)  -- Set width for the first column
        nameText:SetJustifyH("LEFT")
        nameText:SetText(rec.class and ns.code:cPlayer(nameOut, rec.class) or nameOut)
        nameText:SetWordWrap(false)

        -- Second column (Value or Roll Result)
        local rollOut = (rec.roll ~= '0' and type(rec.roll) == 'number') and ns.code:FormatNumberWithCommas(rec.roll) or rec.roll
        if rec.roll == '0' then rollOut = ''
        elseif type(rec.roll) == 'number' and rec.isHighest then
            rollOut = ns.code:cText('FF00FF00', rollOut)
        elseif type(rec.roll) == 'number' and rec.isLowest then
            rollOut = ns.code:cText('FFFF0000', rollOut)
        end

        local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueText:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
        valueText:SetWidth(parent:GetWidth() * 0.4)  -- Set width for the second column
        valueText:SetJustifyH('CENTER')
        valueText:SetTextColor(1, 1, 1, 1)
        valueText:SetText(rollOut)

        tinsert(self.tblRound.rowsRoll, row)
        parent:SetHeight(lineSpacing * #self.tblRound.rowsRoll)
    end

    local yOffset = -20

    self:clearAllRows()
    self.tblRound.rowsRoll = self.tblRound.rowsRoll or {}
    createContentRow(contentFrame, 'Player Name', 'Roll Result', 0, true)
    for k, v in pairs(self.tblRound.players or {}) do
        createContentRow(contentFrame, k, v or false, yOffset)
        yOffset = yOffset - 20
    end
end
function highLow:StartGame()
    ns.core.isGameRunning = true
    local waitTime = ns.gameSettings['highRoller'].joinWaitTime or 30

    self.tblRound.round = self.tblRound.round and self.tblRound.round + 1 or 1
    self.tblRound.players = self.tblRound.players and table.wipe(self.tblRound.players) or {}

    self:LoadPlayerRolls()
    ns.logs:AddLogEntry('Round: '..self.tblRound.round..' - Betting: '..ns.code:FormatNumberWithCommas(self.tblRound.bet)..' gold', 'FF00FF00')

    self:SetButtons()

    --ns.logs:AddLogEntry('Invites started. Game will start in '..waitTime..' seconds.')
    ns.code:SendChatMessage('Press 1 to join the game. Bet: '..ns.code:FormatNumberWithCommas(self.tblRound.bet)..' gold')
    ns.code:SendChatMessage('You have '..waitTime..' seconds before the game starts.')

    ns.code:GetJoiningPlayers(ns.diceGames.highRoller.tblRound, function()
         ns.diceGames.highRoller:LoadPlayerRolls() end)
    ns.code:CountDowntimer(waitTime, function()
        ns.code:StopJoiningPlayers()
        ns.logs:AddLogEntry('Invites complete, found '..self.tblRound.playerCount..' players.')
        if self.tblRound.playerCount < (GG.isPreRelease and 1 or 2) then
            ns.logs:AddLogEntry('Not enough players to start the game. Cancelling...', 'FFFF0000')
            ns.code:SendChatMessage('Not enough players to start the game. Cancelling...')
            self:EndGame()
            return
        end

        self:StartRolling()
    end)
end
function highLow:StartRolling()
    local rollTime = ns.gameSettings['highRoller'].rollTime or 15

    ns.logs:AddLogEntry(ns.code:cText('FF00FF00', 'Game has started. Players are rolling...'))
    ns.code:SendChatMessage('Rolling has started. You have '..(ns.gameSettings['highRoller'].rollTime or 15)..' seconds to roll.')
    ns.code:SendChatMessage('Type /roll '..self.tblRound.bet..' to roll.')

    ns.code:CapturePlayerRolls(ns.diceGames.highRoller.tblRound, function()
        ns.diceGames.highRoller:LoadPlayerRolls() end)
    ns.code:CountDowntimer(rollTime, function()
        ns.code:StopCapturingPlayerRolls()
        ns.logs:AddLogEntry('Rolling complete. Calculating results...')
        ns.code:SendChatMessage('Rolling complete. Calculating results...')

        self:CalculateResults()
    end)
end
function highLow:CalculateResults()
    local highestRoll, lowestRoll = 0, 0
    local highestPlayer, lowestPlayer = {}, {}
    for k, v in pairs(self.tblRound.players) do
        local fName = v.class and ns.code:cPlayer(k, v.class) or k
        if v.isHighest then
            highestRoll = v.roll
            tinsert(highestPlayer, {name = k, fName = fName, roll = v.roll})
        end
        if v.isLowest then
            lowestRoll = v.roll
            tinsert(lowestPlayer, {name = k, fName = fName, roll = v.roll})
        end
    end

    local tieLow, tieHigh = self.tblRound.tieLowCount, self.tblRound.tieHighCount
    local owed = highestRoll - lowestRoll
    local owedEach = owed / tieHigh
    local payEach = owedEach / tieLow

    if tieHigh == 1 then
        ns.logs:AddLogEntry('The highest roll was '..highestPlayer[1].roll..' by '..highestPlayer[1].fName)
        ns.code:SendChatMessage('The highest roll was '..highestPlayer[1].roll..' by '..highestPlayer[1].name)
    else
        local msg, msg2 = 'The highest roll was '..highestRoll, 'The highest roll was '..highestRoll
        for k, v in pairs(highestPlayer) do
            msg = msg..' by '..v.fName..(k == tieHigh and '.' or ' and ')
            msg2 = msg2..' by '..v.name..(k == tieHigh and '.' or ' and ')
        end
        ns.logs:AddLogEntry(msg)
        ns.logs:AddLogEntry('Each player will receive '..ns.code:cText('FF00FF00', ns.code:FormatNumberWithCommas(owedEach))..' gold.')

        ns.code:SendChatMessage(msg2)
        ns.code:SendChatMessage('Each player will receive '..ns.code:FormatNumberWithCommas(owedEach)..' gold.')
    end

    if tieLow == 1 then
        ns.logs:AddLogEntry('The lowest roll was '..lowestPlayer[1].roll..' by '..lowestPlayer[1].fName)
        ns.logs:AddLogEntry(lowestPlayer[1].fName..' will pay '..ns.code:cText('FF00FF00', ns.code:FormatNumberWithCommas(owed))..' gold.')

        ns.code:SendChatMessage('The lowest roll was '..lowestPlayer[1].roll..' by '..lowestPlayer[1].name)
        ns.code:SendChatMessage(lowestPlayer[1].name..' will pay '..ns.code:FormatNumberWithCommas(owed)..' gold.')
    else
        local msg, msg2 = 'The lowest roll was '..lowestRoll, 'The lowest roll was '..lowestRoll
        for k, v in pairs(lowestPlayer) do
            msg = msg..' by '..v.fName..(k == #lowestPlayer and '.' or ' and ')
            msg2 = msg2..' by '..v.name..(k == #lowestPlayer and '.' or ' and ')
        end
        ns.logs:AddLogEntry(msg)
        ns.logs:AddLogEntry('Each player will pay '..ns.code:cText('FF00FF00', ns.code:FormatNumberWithCommas(payEach))..' gold.')

        ns.code:SendChatMessage(msg2)
        ns.code:SendChatMessage('Each player will pay '..ns.code:FormatNumberWithCommas(payEach)..' gold.')
    end

    self:EndGame(true)
end
function highLow:EndGame(normalEnd)
    ns.core.isGameRunning = false

    self:SetButtons()

    self.tblRound.players = {}
    if normalEnd then
        ns.logs:AddLogEntry(ns.code:cText('FFFF0000', 'Round '..self.tblRound.round..' has ended.'))
    end
end
highLow:Init()