local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.code, ns.observer = {}, {}
local code, observer = ns.code, ns.observer

-- * Observer Routines
function observer:Init()
    self.tblObservers = {}
end
function observer:Register(event, callback)
    if not event or not callback then return end

    if not self.tblObservers[event] then self.tblObservers[event] = {} end
    table.insert(self.tblObservers[event], callback)
end
function observer:Unregister(event, callback)
    if not event or not callback then return end
    if not self.tblObservers[event] then return end
    for i=#self.tblObservers[event],1,-1 do
        if self.tblObservers[event][i] == callback then
            table.remove(self.tblObservers[event], i)
        end
    end
end
function observer:UnregisterAll(event)
    if not event then return end
    if not self.tblObservers[event] then return end
    for i=#self.tblObservers[event],1,-1 do
        table.remove(self.tblObservers[event], i)
    end
end
function observer:Notify(event, ...)
    if not event or not self.tblObservers[event] then return end

    for i=1,#self.tblObservers[event] do
        if self.tblObservers[event][i] then
            self.tblObservers[event][i](...) end
    end
end
observer:Init()

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
    if msg == '' or not msg then return
    elseif ns.pSettings.hideConsole then return end

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

--* Game Routines
function code:GetGuildPlayers()
    local tbl = {}

    C_GuildInfo.GuildRoster()
    for i = 1, GetNumGuildMembers() do
        local name, _, _, _, class, _, _, _, online = GetGuildRosterInfo(i)
        if online then
            tbl[name] = {name = name, class = class}
        end
    end

    return tbl
end
function code:CountDowntimer(seconds, callback)
    if not seconds or not ns.core.isGameRunning then return end

    if seconds == 0 then callback() return
    elseif seconds == 10 then
        self:SendChatMessage('10 seconds remaining!')
    elseif seconds <= 5 then
        self:SendChatMessage(seconds..' seconds remaining!')
    end
    C_Timer.After(1, function() self:CountDowntimer(seconds - 1, callback) end)
end

function code:StopJoiningPlayers() self:GetJoiningPlayers(nil, true) end
function code:GetJoiningPlayers(tbl, stopListening)
    local tblGuildPlayers = not stopListening and ns.code:GetGuildPlayers() or {}
    local function ChatListener(event, message, sender, ...)
        if message:trim() ~= '1' and message:trim() ~= '0' then return
        elseif event ~= 'CHAT_MSG_RAID' and event ~= 'CHAT_MSG_PARTY' and
            event ~= 'CHAT_MSG_RAID_LEADER' and event ~= 'CHAT_MSG_PARTY_LEADER' then return end

        local name = sender:find(UnitName('player')) and 'player' or sender
        local class = UnitClassBase(name)
        name = class and ns.code:cPlayer(sender, class) or sender

        if message:trim() == '1' and not tbl.players[sender] then
            tbl.playerCount = tbl.playerCount + 1
            tbl.players[sender] = tblGuildPlayers[sender] and true or false
            ns.logs:AddLogEntry(name..' has joined the game.')
        elseif message:trim() == '0' and tbl.players[sender] then
            tbl.playerCount = tbl.playerCount - 1
            tbl.players[sender] = nil
            ns.logs:AddLogEntry(name..' has left the game.')
        end
    end

    if stopListening then
        GG:UnregisterEvent(ns.core.groupType == 'raid' and 'CHAT_MSG_RAID' or 'CHAT_MSG_PARTY', ChatListener)
        GG:UnregisterEvent(ns.core.groupType == 'raid' and 'CHAT_MSG_RAID_LEADER' or 'CHAT_MSG_PARTY_LEADER', ChatListener)
        return
    end

    tbl.players = {}
    tbl.playerCount = 0
    GG:RegisterEvent(ns.core.groupType == 'raid' and 'CHAT_MSG_RAID' or 'CHAT_MSG_PARTY', ChatListener)
    GG:RegisterEvent(ns.core.groupType == 'raid' and 'CHAT_MSG_RAID_LEADER' or 'CHAT_MSG_PARTY_LEADER', ChatListener)
end

--* General Routines
function code:FormatNumberWithCommas(number)
    local formatted, k = tostring(number), nil
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

--* Frame Routines
function code:CreateButtonFrame(label, btnPoint, parent, parentPoint, pos1, pos2, x, y, useRedHighlight)
    local frame = CreateFrame('Button', nil, parent, 'BackdropTemplate')
    frame:SetSize(x, y)
    frame:SetPoint(btnPoint, parent, parentPoint, pos1, pos2)
    frame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(1, 1, 1, 1)

    local highLight = frame:CreateTexture(nil, 'OVERLAY')
    highLight:SetSize(frame:GetWidth()-3, frame:GetHeight()-3)
    highLight:SetPoint('CENTER', frame, 'CENTER', 0, 0)
    highLight:SetAtlas(useRedHighlight and RED_HIGHLIGHT or BLUE_OUTLINE_HIGHLIGHT)
    highLight:SetShown(false)

    local text = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    text:SetPoint('CENTER', frame, 'CENTER', 0, 0)
    text:SetText(label)
    text:SetTextColor(1, 1, 1, 1)
    text:SetJustifyH('CENTER')

    frame:SetScript('OnEnable', function()
        frame:SetBackdropBorderColor(1, 1, 1, 1)
        text:SetTextColor(1, 1, 1, 1)
    end)
    frame:SetScript('OnDisable', function()
        frame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        text:SetTextColor(0.5, 0.5, 0.5, 1)
    end)

    return frame, highLight
end
function code:Confirmation(msg, func)
    StaticPopupDialogs["MY_YES_NO_DIALOG"] = {
        text = msg,
        button1 = "Yes",
        button2 = "No",
        OnAccept = func,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
    }
    StaticPopup_Show("MY_YES_NO_DIALOG")
end

--* Communication Routines
function code:SendChatMessage(msg, channel, target)
    if not msg or msg == '' then return end
    if not channel or channel == '' then channel = IsInRaid() and 'RAID' or 'PARTY' end
    if not target or target == '' then target = nil end

    SendChatMessage(msg, channel, nil, target)
end
code:Init()