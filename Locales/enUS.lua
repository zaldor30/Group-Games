-- Localization file for English/United States
local L = LibStub("AceLocale-3.0"):NewLocale("GroupGames", "enUS", true)

L['TITLE'] = 'Group Games'
L['TOOLTIP_BODY'] = [[
LEFT CLICK - Open Group Games
RIGHT CLICK - Open Settings
]]

--* Dice Games
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
L['HIGH_ROLLER_DESC'] = 'Players will /roll <amount of bet> and the highest roll wins.'
L['HIGH_ROLLER_HELP'] = [[
dice game where there is a pot of gold, and
each player rolls a die (usually /roll 10000).
The player with the highest roll wins the pot,
and the loser (the one with the lowest roll) pays
the difference between their roll and the
winner's roll to the winner.]]
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