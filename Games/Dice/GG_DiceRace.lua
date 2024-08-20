local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub('AceLocale-3.0'):GetLocale('GroupGames') -- Locale

ns.diceGames = ns.diceGames or {}
ns.diceGames.diceRace = ns.diceGames.diceRace or {}
local diceRace = ns.diceGames.diceRace

function diceRace:Init()
end
function diceRace:SetShown(val)
    ns.diceBase:SetShown(val)
end
diceRace:Init()