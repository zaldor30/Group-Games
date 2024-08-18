-- Localization file for English/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GroupGames", "enUS", true)

--* Typical Buttons
L['NEW'] = 'New'

L['TITLE'] = 'Group Games'
L['TOOLTIP_BODY'] = [[
LEFT CLICK - Open Group Games
RIGHT CLICK - Open Settings
]]
L['TOOLTIP_BODY_NO_GROUP'] = [[
You must be in a group to use Group Games.

Right Click - Open Settings]]
L['TOOLTIP_NO_GROUP'] = 'You must be in a group to use Group Games.'

--* General Localization
L['POT_AMOUNT'] = 'Pot Amount'
L['START_GAME'] = 'Start Game'
L['START_GAME_TOOLTIP'] = 'Invites then starts the game.'
L['CANCEL_GAME'] = 'Cancel Game'
L['CANCEL_GAME_TOOLTIP'] = 'Cancel the current game.'
L['SHOW_RULES'] = 'Show Rules'
L['SHOW_RULES_TOOLTIP'] = 'Sends the rules to chat.'

--* Dice Games
L['DICE_GAMES'] = 'Dice Games'
L['SURVIVOR'] = 'Survivor'
L['SURVIVOR_DESC'] = [[
Players roll and the lowest roll is out.
Players keep rolling until a player rolls
a 1 is out and the remaining player wins!]]
L['SURVIVOR_HELP'] = [[
Players will use the /roll command to roll.
The player with the lowest roll is out.
Players will then use /roll <lowest roll>.
When there are only two players left, the
player that rolls a 1 loses.]]
L['HIGH_ROLLER'] = 'High Roller'
L['HIGH_ROLLER_DESC'] = 'Players will /roll <amount of bet> and the lowest roll will pay highest roll the difference.'
L['HIGH_ROLLER_RULES_1'] = 'When prompted, press 1 to join the game.'
L['HIGH_ROLLER_RULES_2'] = 'When the game starts, all participating players will /roll <amount of bet>.'
L['HIGH_ROLLER_RULES_3'] = 'The player with the lowest roll will pay the player with the highest roll the difference.'
L['TARGET_PRACTICE'] = 'Target Practice'
L['TARGET_PRACTICE_DESC'] = 'Players will roll to see who gets the closest to a chosen number.'
L['TARGET_PRACTICE_HELP'] = [[
The person running the game will choose a number.
Players will then /roll to see who gets the closest.
The player that gets the closest wins!]]
L['DICE_RACE'] = 'Dice Race'
L['DICE_RACE_DESC'] = 'Players will /roll 100 until they roll higher than a chosen number.'
L['DICE_RACE_HELP'] = [[
The person running the game will choose a number.
Players will then /roll 100 until they roll higher
than the chosen number. The first player to roll
higher than the chosen number wins!]]