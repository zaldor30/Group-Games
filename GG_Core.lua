local _, ns = ... -- Namespace (myaddon, namespace)
ns.core = {}
local core, lCore = ns.core, {}

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

local activeMessage = L['TITLE']..' is active.'
local inactiveMessage = L['TITLE']..' is inactive.'

-- *Blizzard Initialization Called Function
function GG:OnInitialize() lCore:StartGroupGames() end
local function GroupRosterUpdate()
    local wasInGroup = core.groupType
    core.groupType = IsInRaid() and 'raid' or 'party'
    if wasInGroup ~= core.groupType then
        ns.observer:Notify('GROUP_TYPE_UPDATE')
        if core.groupType then ns.code:fOut(activeMessage)
        else ns.code:fOut(inactiveMessage) end
    end
end

local defaultDB = {
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
            survivor = {
                hide = false,
                potAmount = 10000,
                joinWaitTime = 30,
                gameLength = 15,
            },
            highRoller = {
                hide = false,
                potAmount = 10000,
                joinWaitTime = 30,
                gameLength = 15,
            },
            targetPractice = {
                hide = false,
                potAmount = 10000,
                joinWaitTime = 30,
                gameLength = 15,
            },
            diceRace = {
                hide = false,
                potAmount = 10000,
                joinWaitTime = 30,
                gameLength = 15,
            },
        },
    },
}
function lCore:Init()
    self.activeGame = nil
    self.isGameRunning = false

    self.guildSettings = {
        stats = {},
    }

    self.clubID = nil
end
function lCore:StartGroupGames()
    ns.code.fPlayerName = ns.code:cPlayer(UnitName('player'), UnitClassBase('player'))

    self:CheckGuild()
    self:SetupDatabase()

    AC:RegisterOptionsTable('GG_Options', ns.addonSettings) -- Register the options table
    ns.addonOptions = ACD:AddToBlizOptions('GG_Options', 'Group Games') -- Add the options table to the Blizzard menu

    self:CreateMiniMapIcon()

    ns.code:fOut(L['TITLE']..' (v'..GG.version..(GG.isPreRelease and ' '..GG.preReleaseType or '')..') - '..(IsInGroup() and 'Active' or 'Inactive'))
    GG:RegisterEvent('GROUP_ROSTER_UPDATE', GroupRosterUpdate)
end
function lCore:CheckGuild()
    if not IsInGuild() then return end
    local clubID = C_Club.GetGuildClubId()
    if not clubID then return end

    self.clubID = clubID
end
function lCore:SetupDatabase()
    local db = DB:New('GroupGamesDB', defaultDB, true)

    db.global = db.global.settings and db.global or self.databaseSettings.global
    db.profile = db.profile.settings and db.profile or self.databaseSettings.profile

    ns.g, ns.p = db.global, db.profile

    ns.gSettings = db.global.gameSettings
    ns.pSettings = db.profile.settings
    ns.pStats = db.profile.stats

    if self.clubID then
        db.global[self.clubID] = db.global[self.clubID] or self.guildSettings
        ns.gStats = db.global[self.clubID].stats
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
lCore:Init()

function core:Init()
    self.groupType = IsInGroup() and (IsInRaid() and 'raid' or 'party') or nil
end
core:Init()
