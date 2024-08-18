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
function highLow:StartGame()
    ns.core.isGameRunning = true

    self.tblRound.round = self.tblRound.round and self.tblRound.round + 1 or 1
    self.tblRound.players = {}

    ns.logs:AddLogEntry('Round: '..self.tblRound.round..' - Betting: '..ns.code:FormatNumberWithCommas(self.tblRound.bet)..' gold', 'FF00FF00')

    self:SetButtons()

    ns.logs:AddLogEntry('Invites started. Game will start in '..(ns.gameSettings['highRoller'].joinWaitTime or 30)..' seconds.')
    ns.code:SendChatMessage('Press 1 to join the game. Bet: '..ns.code:FormatNumberWithCommas(self.tblRound.bet)..' gold')
    ns.code:SendChatMessage('You have '..(ns.gameSettings['highRoller'].joinWaitTime or 30)..' before the game starts.')

    ns.code:GetJoiningPlayers(ns.diceGames.highRoller.tblRound)
    ns.code:CountDowntimer(30, function()
        ns.code:StopJoiningPlayers()
        ns.logs:AddLogEntry('Invites complete, found '..self.tblRound.playerCount..' players.')
        if self.tblRound.playerCount < 2 then
            ns.logs:AddLogEntry('Not enough players to start the game. Cancelling...', 'FFFF0000')
            ns.code:SendChatMessage('Not enough players to start the game. Cancelling...')
            self:EndGame()
            return
        end

        self:StartRolling()
    end)
end
function highLow:StartRolling()
end
function highLow:EndGame()
    ns.core.isGameRunning = false

    self:SetButtons()

    self.tblRound.players = {}
end
highLow:Init()