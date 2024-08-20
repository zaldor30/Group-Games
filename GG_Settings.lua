local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')
local icon = LibStub('LibDBIcon-1.0')

ns.addonSettings = {
    name = L['TITLE']..' ('..GG.version..(GG.isPreRelease and ' '..GG.preReleaseType)..')',
    type = 'group',
    args = {
        general = {
            name = L['GENERAL'],
            type = 'group',
            order = 1,
            args = {
                icon = {
                    name = L['ICON'],
                    desc = L['ICON_DESC'],
                    type = 'toggle',
                    get = function() return not ns.pSettings.hideIcon end,
                    set = function(_, value) ns.pSettings.hideIcon = not value end,
                    order = 1,
                },
                console = {
                    name = L['CONSOLE'],
                    desc = L['CONSOLE_DESC'],
                    type = 'toggle',
                    get = function() return not ns.pSettings.hideConsole end,
                    set = function(_, value) ns.pSettings.hideConsole = not value end,
                    order = 3,
                },
                tooltips = {
                    name = L['TOOLTIPS'],
                    desc = L['TOOLTIPS_DESC'],
                    type = 'toggle',
                    get = function() return ns.g.settings.showToolTips end,
                    set = function(_, value) ns.g.settings.showToolTips = value end,
                    order = 4,
                },
                showLog = {
                    name = L['SHOW_LOG'],
                    desc = L['SHOW_LOG_DESC'],
                    type = 'toggle',
                    func = function() return ns.pSettings.showLog end,
                    set = function(_, value) ns.pSettings.showLog = value end,
                    order = 5,
                },
            },
        },
        games = {
            name = L['DICE_GAMES'],
            type = 'group',
            order = 2,
            args = {
                diceRace = {
                    name = L['DICE_RACE'],
                    desc = L['DICE_RACE_DESC'],
                    type = 'group',
                    order = 1,
                    args = {
                        hide = {
                            name = L['HIDE_GAME'],
                            desc = L['HIDE_GAME_DESC'],
                            type = 'toggle',
                            get = function() return ns.gSettings.diceRace.hide end,
                            set = function(_, value) ns.gSettings.diceRace.hide = value end,
                            order = 1,
                        },
                        potAmount = {
                            name = L['POT_AMOUNT'],
                            desc = L['POT_AMOUNT_DESC'],
                            type = 'input',
                            order = 2,
                            get = function() return tostring(ns.gSettings.diceRace.potAmount) or '10000' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.diceRace.potAmount = value
                            end,
                        },
                        joinWaitTime = {
                            name = L['WAIT_FOR_INVITE'],
                            desc = L['WAIT_FOR_INVITE_DESC'],
                            type = 'input',
                            order = 3,
                            get = function() return tostring(ns.gSettings.diceRace.joinWaitTime) or '30' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.diceRace.joinWaitTime = value
                            end,
                        },
                        gameLength = {
                            name = L['GAME_LENGTH'],
                            desc = L['GAME_LENGTH_DESC'],
                            type = 'input',
                            order = 4,
                            get = function() return tostring(ns.gSettings.diceRace.gameLength) or '15' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.diceRace.gameLength = value
                            end,
                        },
                    },
                },
                highRoller = {
                    name = L['HIGH_ROLLER'],
                    desc = L['HIGH_ROLLER_DESC'],
                    type = 'group',
                    order = 2,
                    args = {
                        hide = {
                            name = L['HIDE_GAME'],
                            desc = L['HIDE_GAME_DESC'],
                            type = 'toggle',
                            get = function() return ns.gSettings.highRoller.hide end,
                            set = function(_, value) ns.gSettings.highRoller.hide = value end,
                            order = 1,
                        },
                        potAmount = {
                            name = L['POT_AMOUNT'],
                            desc = L['POT_AMOUNT_DESC'],
                            type = 'input',
                            order = 2,
                            get = function() return tostring(ns.gSettings.highRoller.potAmount) or '10000' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.highRoller.potAmount = value
                            end,
                        },
                        joinWaitTime = {
                            name = L['WAIT_FOR_INVITE'],
                            desc = L['WAIT_FOR_INVITE_DESC'],
                            type = 'input',
                            order = 3,
                            get = function() return tostring(ns.gSettings.highRoller.joinWaitTime) or '30' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.highRoller.joinWaitTime = value
                            end,
                        },
                        gameLength = {
                            name = L['GAME_LENGTH'],
                            desc = L['GAME_LENGTH_DESC'],
                            type = 'input',
                            order = 4,
                            get = function() return tostring(ns.gSettings.highRoller.gameLength) or '15' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.highRoller.gameLength = value
                            end,
                        },
                    },
                },
                survivor = {
                    name = L['SURVIVOR'],
                    desc = L['SURVIVOR_DESC'],
                    type = 'group',
                    order = 3,
                    args = {
                        hide = {
                            name = L['HIDE_GAME'],
                            desc = L['HIDE_GAME_DESC'],
                            type = 'toggle',
                            get = function() return ns.gSettings.survivor.hide end,
                            set = function(_, value) ns.gSettings.survivor.hide = value end,
                            order = 1,
                        },
                        potAmount = {
                            name = L['POT_AMOUNT'],
                            desc = L['POT_AMOUNT_DESC'],
                            type = 'input',
                            order = 2,
                            get = function() return tostring(ns.gSettings.survivor.potAmount) or '10000' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.survivor.potAmount = value
                            end,
                        },
                        joinWaitTime = {
                            name = L['WAIT_FOR_INVITE'],
                            desc = L['WAIT_FOR_INVITE_DESC'],
                            type = 'input',
                            order = 3,
                            get = function() return tostring(ns.gSettings.survivor.joinWaitTime) or '30' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.survivor.joinWaitTime = value
                            end,
                        },
                        gameLength = {
                            name = L['GAME_LENGTH'],
                            desc = L['GAME_LENGTH_DESC'],
                            type = 'input',
                            order = 4,
                            get = function() return tostring(ns.gSettings.survivor.gameLength) or '15' end,
                            set = function(_, value)
                                if type(value) == 'string' and tonumber(value) then value = tonumber(value)
                                else return end
                                ns.gSettings.survivor.gameLength = value
                            end,
                        },
                    },
                }
            },
        }
    }
}