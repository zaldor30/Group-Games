local _, ns = ... -- Namespace (myaddon, namespace)
ns.core = {}
local core, lCore = ns.core, {}

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

local activeMessage = 'You are in a group, '..L['TITLE']..' is active.'
local inactiveMessage = 'You are not in a group, '..L['TITLE']..' is inactive.'

local REQUEST_WAIT_TIMEOUT = 1 --! Change ME!!

-- *Blizzard Initialization Called Function
function GG:OnInitialize() lCore:StartGroupGames() end
local function GroupRosterUpdate()
    local wasInGroup = core.groupType
    core.groupType = IsInRaid() and 'raid' or 'party'
    if wasInGroup ~= core.groupType then
        ns.observer:Notify('GROUP_TYPE_UPDATE')

        ns.code:cOut(L['TITLE']..' detected a group change.', DEFAULT_CHAT_COLOR)
        if core.groupType then
            ns.code:cOut(activeMessage, DEFAULT_CHAT_COLOR)
            lCore:StartAddonComms()
        else
            ns.code:cOut(inactiveMessage, DEFAULT_CHAT_COLOR)
            GG:UnregisterComm(COMM_PREFIX)
        end
    end
end

function lCore:Init()
    self.defaultDB = {
        profile = {
            settings = {
                icon = {
                    hide = false,
                    minimapPos = 220,
                },
                screenPos = {
                    point = 'CENTER',
                    x = 0, y = 0
                },
                hideConsole = false,
                showLog = false,
            },
            stats = {
                games = {
                    totalRan = 0,
                },
            },
        },
        global = {
            dbVersion = 1,
            settings = {
                showToolTips = true,
            },
            gameSettings = {
                totalRan = 0,
                diceRace = {
                    hide = false,
                    favorite = true,
                    potAmount = 10000,
                    joinWaitTime = 30,
                    gameLength = 15,
                },
                highRoller = {
                    hide = false,
                    favorite = true,
                    potAmount = 10000,
                    joinWaitTime = 30,
                    gameLength = 15,
                },
                survivor = {
                    hide = false,
                    favorite = false,
                    potAmount = 10000,
                    joinWaitTime = 30,
                    gameLength = 15,
                },
                targetPractice = {
                    hide = false,
                    favorite = false,
                    potAmount = 10000,
                    joinWaitTime = 30,
                    gameLength = 15,
                },
            },
        },
    }

    self.clubID = nil
end
function lCore:StartGroupGames()
    ns.code.fPlayerName = ns.code:cPlayer(UnitName('player'), UnitClassBase('player'))

    self:StartDatabase()

    --! Config/Settings Routine

    self:CreateMiniMapIcon()

    ns.code:fOut(L['TITLE']..' '..GG.versionOut, DEFAULT_CHAT_COLOR)
    ns.code:cOut((not self.groupType and inactiveMessage or activeMessage), DEFAULT_CHAT_COLOR)

    if IsInGroup() then self:StartAddonComms() end
    GG:RegisterEvent('GROUP_ROSTER_UPDATE', GroupRosterUpdate)
end

--* Database Initialization
function lCore:StartDatabase()
    local db = DB:New('GroupGamesDB', self.defaultDB, true)

    db.global = db.global.settings and db.global or self.databaseSettings.global
    db.profile = db.profile.settings and db.profile or self.databaseSettings.profile

    ns.p, ns.g = db.profile, db.global
    ns.pSettings, ns.gSettings = ns.p.settings, ns.g.gameSettings
    ns.pStats = ns.p.stats

    local clubID = (IsInGuild() and C_Club.GetGuildClubId()) and C_Club.GetGuildClubId() or nil
    if clubID then
        ns.g[clubID] = ns.g[clubID] or { stats = {} }
        ns.gStats = clubID and ns.g[clubID].stats or nil
    end
end
function lCore:CreateMiniMapIcon()
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GG_Icon", {
        type = 'data source',
        icon = APP_ICON,
        OnClick = function(_, button)
            if not IsInGroup() and button == 'LeftButton' then ns.code:fOut(L['TOOLTIP_NO_GROUP'])
            elseif button == 'LeftButton' then ns.base:SetShown(not ns.base:IsShown())
            elseif button == 'RightButton' then Settings.OpenToCategory('Group Games') end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = L['TITLE']..' ('..GG.version..(GG.isPreRelease and ' '..GG.preReleaseType or '')..')'
            local body = IsInGroup() and L['TOOLTIP_BODY'] or L['TOOLTIP_BODY_NO_GROUP']
            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
        OnLeave = function() GameTooltip:Hide() end,
})

    icon:Register('GG_Icon', iconData, ns.pSettings.icon)
end
function lCore:StartAddonComms()
    local checkRunning = true
    local function OnCommReceived(prefix, message, channel, sender)
        if channel ~= 'PARTY' or channel ~= 'RAID' then return
        elseif sender == UnitName('player') then return
        elseif prefix ~= COMM_PREFIX then return end

        if message == 'GAME_RUNNING' then
            ns.observer:Notify('GAME_RUNNING')
            ns.observer:Notify('CLOSE_ADDON')

            self.pAdmin = sender
            core.canRunGames, checkRunning = false, false
            core.activeGame, core.isGameRunning = nil, false
            ns.code:cOut(sender..' has an active game running.', DEFAULT_CHAT_COLOR)
        elseif message == 'GAME_OVER' then
            ns.observer:Notify('GAME_OVER')

            self.pAdmin = nil
            core.canRunGames, checkRunning = true, true
            core.activeGame, core.isGameRunning = nil, false
            ns.code:cOut(sender..' has ended their game.', DEFAULT_CHAT_COLOR)
        end
    end
    GG:RegisterComm(COMM_PREFIX, OnCommReceived)

    ns.code:dOut('Addon Comms started.')
    ns.coms:SendCommMessage('REQUEST_GAME_STATUS')

    local function CheckGameStatus(remaining)
        if not core.groupType then return
        elseif remaining <= 0 then
            core.canRunGames = true
            ns.code:dOut('No active games detected.', DEFAULT_CHAT_COLOR)
            return
        elseif not checkRunning and self.pAdmin then return
        else
            C_Timer.After(1, function() CheckGameStatus(remaining - 1) end)
        end
    end

    ns.code:dOut('Checking game status.')
    CheckGameStatus(REQUEST_WAIT_TIMEOUT)
end
lCore:Init()

function core:Init()
    self.pAdmin = nil
    self.activeGame = nil
    self.canRunGames = false
    self.isGameRunning = false

    self.groupType = IsInGroup() and (IsInRaid() and 'raid' or 'party') or nil
end
core:Init()