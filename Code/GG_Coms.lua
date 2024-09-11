local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.coms = {}
local coms = ns.coms

function coms:SendChatMessage(msg, channel, target)
    if not msg or msg == '' then return end
    if not channel or channel == '' then channel = IsInRaid() and 'RAID' or 'PARTY' end
    if not target or target == '' then target = nil end

    SendChatMessage(msg, channel, nil, target)
end

--* Addon Communication
function coms:SendCommMessage(msg, channel, target)
    if not msg then return end
    if not channel or channel == '' then channel = IsInRaid() and 'RAID' or 'PARTY'
    else channel = 'PARTY' end

    GG:SendCommMessage(COMM_PREFIX, msg, channel, (target or nil), 'ALERT')
end