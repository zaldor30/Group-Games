local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.diceGames = ns.diceGames or {}
ns.diceGames.highRoller = {}
local hRoller = {}
local tblBase = ns.diceBase.tblBase

function hRoller:Init()
    self.version = '1.0.0'

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
function ns.diceGames.highRoller:SetShown(val) hRoller:SetShown(val) end
function hRoller:SetShown(val)
    if not val then
        return
    end

    ns.core.isGameRunning = false
    ns.core.activeGame = L['HIGH_ROLLER']
    ns.diceBase:SetShown(true)

    self.tblRound = ns.diceCode:ClearAllRows(self.tblRound, self.tblFrame.prContentFrame)

    ns.diceBase:ClearData()
    self:LoadPlayerRolls()
    self:CreateGameControls()

    local iContentText = tblBase.instructions.contentText
    iContentText:SetText(L['HIGH_ROLLER_DESC'])
end
function hRoller:LoadPlayerRolls()
    local yOffset = -20
    local pContentFrame = tblBase.playerRolls

    self.tblRound.rowsRoll = table.wipe(self.tblRound.rowsRoll)
    ns.diceCode:ClearAllRows(self.tblRound)
    self.tblRound = ns.diceCode:createContentRow(self.tblRound, 'Player Name', 'Roll Result', 0, true)
end
function hRoller:CreateGameControls()
    local buttonFrame = ns.diceBase.tblBase.buttonFrame

    --* Amount Bet
    -- Create the Bet Amount Label
    local betLabel = buttonFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    betLabel:SetPoint('TOPLEFT', buttonFrame, 'TOPLEFT', 10, -10)
    betLabel:SetText('Bet Amount:')
    betLabel:SetJustifyH('CENTER')

    -- Create the Bet Amount EditBox
    local function updateBet()
        if not self.tblRound.bet or self.tblRound.bet ~= self.tblRound.oldBet then
            self.tblRound.oldBet = self.tblRound.bet
            ns.logs:AddLogEntry(L['NEW']..' '..L['POT_AMOUNT']..': '..ns.code:FormatNumberWithCommas(self.tblRound.bet))
        end
    end

    self.tblRound.bet = 10000
    local betEditBox = CreateFrame('EditBox', 'GG_Dice_Survivor_Bet_EditBox', buttonFrame, 'InputBoxTemplate')
    betEditBox:SetPoint('LEFT', betLabel, 'RIGHT', 10, 0)
    betEditBox:SetSize(buttonFrame:GetWidth() - betLabel:GetWidth() - 30, 20)
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
        hRoller.tblRound.bet = tonumber(bet)
    end)
    betEditBox:SetScript('OnEnter', function(self) hRoller.tblRound.oldBet = hRoller.tblRound.bet or nil end)
    betEditBox:SetScript('OnLeave', function(self) updateBet() end)
    self.tblFrame.betEditBox = betEditBox
end
hRoller:Init()