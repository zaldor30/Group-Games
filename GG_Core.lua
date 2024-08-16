local _, ns = ... -- Namespace (myaddon, namespace)
ns.core = {}
local core = ns.core

-- Application Initialization
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')
local AC, ACD = LibStub('AceConfig-3.0'), LibStub('AceConfigDialog-3.0')
local icon, DB = LibStub('LibDBIcon-1.0'), LibStub('AceDB-3.0')

-- *Blizzard Initialization Called Function
function GG:OnInitialize() core:StartGroupGames() end

function core:Init()
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
                }
            },
        },
        global = {
            settings = {
                showToolTips = true,
                waitTimeForPlayers = 10,
            },
        },
    }
end
function core:StartGroupGames()
    self.isGameRunning = false
    self.runningGame = nil

    self:StartDatabase()
    self:CreateMiniMapIcon()

    ns.win.base:SetShown(true)
end
function core:StartDatabase()
    self.db = DB:New('GroupGamesDB', self.addonSettings)

    self.db.global = self.db.global or self.addonSettings.global or {}
    self.db.profile = self.db.profile or self.addonSettings.profile or {}

    ns.pSettings = self.db.profile.settings or self.addonSettings.profile.settings
    ns.gSettings = self.db.global.settings or self.addonSettings.global.settings

    GG.debug = ns.pSettings.debugMode or false
end
function core:CreateMiniMapIcon()
    local iconData = LibStub("LibDataBroker-1.1"):NewDataObject("GG_Icon", {
        type = 'data source',
        icon = GG.icon,
        OnClick = function(_, button)
            if button == 'LeftButton' then ns.win.base:SetShown(true)
            elseif button == 'RightButton' then Settings.OpenToCategory('Guild Recruiter') end
        end,
        OnTooltipShow = function(GameTooltip)
            local title = L['TITLE']..' ('..GG.version..(GG.isPreRelease and ' '..GG.preReleaseType or '')..')'
            local body = L['TOOLTIP_BODY']
            ns.code:createTooltip(title, body, 'FORCE_TOOLTIP')
        end,
})

    icon:Register('GG_Icon', iconData, ns.pSettings.icon)
end
core:Init()