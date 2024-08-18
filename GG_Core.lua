local _, ns = ... -- Namespace (myaddon, namespace)
ns.core = {}
local core = ns.core

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

-- *Blizzard Initialization Called Function
function GG:OnInitialize() core:StartGroupGames() end

local function GroupRosterUpdate()
    core.isInGroup = IsInGroup()
    core.groupType = IsInRaid() and 'raid' or 'party'
    ns.observer:Notify('GROUP_ROSTER_UPDATE')
end

function core:Init()
    self.isGameRunning = false
    self.activeGame = nil

    self.isInGroup = false
    self.groupType = IsInRaid() and 'raid' or 'party'

    self.playerStats = {
        gamesWon = 0,
        gamesLost = 0,
        winStreak = 0,
        lossStreak = 0,
        moneyWon = 0,
        moneyLost = 0,
        -- Add game then these stats again
        -- stats[game][player] = playerStats
        -- stats[pName-Realm] = playerStats
    }

    self.addonSettings = {
        profile = {
            settings = {
                debugMode = false,
                icon = {
                    hide = false,
                    minimapPos = 220,
                },
                screenPos = {
                    point = 'CENTER',
                    x = 0, y = 0
                },
                hideConsole = false,
            },
            stats = {
                self.playerStats,
                games = {
                    totalRan = 0,
                },
            },
        },
        global = {
            settings = {
                showToolTips = true,
            },
            gameSettings = {
                survivor = {
                    hide = false,
                    potAmount = 10000,
                    joinWaitTime = 30,
                    rollTime = 15,
                },
                highRoller = {
                    hide = false,
                    potAmount = 10000,
                    joinWaitTime = 30,
                },
                targetPractice = {
                    hide = false,
                    potAmount = 10000,
                    joinWaitTime = 30,
                },
                diceRace = {
                    hide = false,
                    potAmount = 10000,
                    joinWaitTime = 30,
                },
            },
            stats = {},
            gameStats = {
                totalRan = 0,
            },
        },
    }
end

--[[ ns Variables
    global = Global
    pSettings = Profile settings
    gSettings = Game settings
]]
function core:StartGroupGames()
    self.isInGroup = IsInGroup()
    self.groupType = IsInRaid() and 'raid' or 'party'
    self.isGameRunning = false
    self.activeGame = nil

    self:StartDatabase()
    self:StartGuildSave()
    self:CreateMiniMapIcon()

    GG:RegisterEvent('GROUP_ROSTER_UPDATE', GroupRosterUpdate) -- Make sure in group or not
end
function core:StartDatabase()
    self.db = DB:New('GroupGamesDB', self.addonSettings)

    self.db.global = self.db.global or {}
    self.db.profile = self.db.profile or {}

    ns.global = self.db.global
    ns.profile = self.db.profile or self.addonSettings.profile

    ns.pSettings, ns.gSettings = ns.profile.settings, ns.global.settings
    ns.pStats, ns.pGames = ns.profile.stats, ns.global.games

    GG.debug = ns.pSettings.debugMode or false
end
function core:StartGuildSave()
    if not IsInGuild() then return end
    local clubID = C_Club.GetGuildClubId()
    if not clubID then return end

    ns.global[clubID] = ns.global[clubID] or self.addonSettings.global

    ns.global[clubID] = ns.global[clubID] or self.addonSettings.global
    ns.gStats = ns.global[clubID].stats
    ns.gGames = ns.global[clubID].games
    ns.gameSettings = ns.global[clubID].gameSettings
end
function core:CreateMiniMapIcon()
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GG_Icon", {
        type = 'data source',
        icon = GG.icon,
        OnClick = function(_, button)
            if not self.isInGroup and button ~= 'RightButton' then ns.code:fOut(L['TOOLTIP_NO_GROUP'])
            elseif button == 'LeftButton' then ns.win.base:SetShown(true)
            elseif button == 'RightButton' then Settings.OpenToCategory('Guild Recruiter') end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = L['TITLE']..' ('..GG.version..(GG.isPreRelease and ' '..GG.preReleaseType or '')..')'
            local body = self.isInGroup and L['TOOLTIP_BODY'] or L['TOOLTIP_BODY_NO_GROUP']
            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
})

    icon:Register('GG_Icon', iconData, ns.pSettings.icon)
end
core:Init()