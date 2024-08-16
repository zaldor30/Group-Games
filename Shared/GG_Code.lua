local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

local LibDeflate = LibStub:GetLibrary("LibDeflate")
local aceSerializer = LibStub:GetLibrary("AceSerializer-3.0")

ns.code = {}
local code = ns.code
function code:Init()
    self.fPlayerName = nil
end
-- *Console Text Output Routines
function code:cText(color, text)
    if text == '' then return end

    color = color == '' and 'FFFFFFFF' or color
    return '|c'..color..text..'|r'
end
function code:cPlayer(name, class, color) -- Colorize player names
    if name == '' or ((not class or class == '') and (not color or color == '')) or not name then return end
    local c = (not class or class == '') and color or select(4, GetClassColor(class))

    if c then return code:cText(c, name)
    else return end
end
function code:consolePrint(msg, color, noPrefix) -- Console print routine
    if msg == '' or not msg then return end

    local prefix = not noPrefix and self:cText(GG.color, 'GR: ') or ''
    color = strlen(color) == 6 and 'FF'..color or color
    DEFAULT_CHAT_FRAME:AddMessage(prefix..code:cText(color or 'FFFFFFFF', msg))
end
function code:cOut(msg, color, noPrefix) -- Console print routine
    if msg == '' or not msg then return end

    --!Check to show console messages
    code:consolePrint(msg, (color or '97FFFFFF'), noPrefix)
end
function code:dOut(msg, color, noPrefix) -- Debug print routine
    if msg == '' or not GG.debug then return end
    code:consolePrint(msg, (color or 'FFD845D8'), noPrefix)
end
function code:fOut(msg, color, noPrefix) -- Force console print routine)
    if msg == '' then return
    else code:consolePrint(msg, (color or '97FFFFFF'), noPrefix) end
end
-- *Tooltip Routine
function code:createTooltip(text, body, force, frame)
    if not force and not ns.gSettings.showToolTips then return end
    local uiScale, x, y = UIParent:GetEffectiveScale(), GetCursorPosition()
    if frame then uiScale, x, y = 0, 0, 0 end
    CreateFrame("GameTooltip", nil, nil, "GameTooltipTemplate")
    GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR") -- Attaches the tooltip to cursor
    GameTooltip:SetPoint("BOTTOMLEFT", (frame or nil), "BOTTOMLEFT", (uiScale ~= 0 and (x / uiScale) or 0),  (uiScale ~= 0  and (y / uiScale) or 0))
    GameTooltip:SetText(text)
    if body then GameTooltip:AddLine(body,1,1,1) end
    GameTooltip:Show()
end
--* Other Routines
function code:FormatNumberWithCommas(number)
    local formatted, k = tostring(number), nil
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end
function code:SendChatMessage(msg, channel, target)
    if not msg or msg == '' then return end
    if not channel or channel == '' then channel = IsInRaid() and 'RAID' or 'PARTY' end
    if not target or target == '' then target = nil end

    SendChatMessage(msg, channel, nil, target)
end
function code:CountDowntimer(seconds, callback)
    if not seconds then return true end

    if seconds == 0 then
        self:SendChatMessage(callback)
        return
    elseif seconds == 10 then
        self:SendChatMessage('10 seconds remaining!')
    elseif seconds < 5 then
        self:SendChatMessage(seconds..' seconds remaining!')
    end
    C_Timer.After(1, function() self:CountDowntimer(seconds - 1, callback) end)
end