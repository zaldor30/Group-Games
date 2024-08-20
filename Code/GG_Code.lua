local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.code, ns.ggMenu = {}, {}
local code, ggMenu = ns.code, ns.ggMenu

function code:Init()
    self.fPlayerName = nil
end
-- *Console Text Output Routines
function code:cText(color, text)
    if text == '' then return end

    color = (not color or color == '') and 'FFFFFFFF' or color
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

    local prefix = not noPrefix and self:cText(DEFAULT_CHAT_COLOR, 'GR: ') or ''
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
--* General Routines
function code:FormatNumberWithCommas(number)
    local formatted, k = tostring(number), nil
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

--* Dropdown Menu
function ggMenu:ClearMenu(dropdownFrame)
    -- Hide the existing dropdown menu if it exists
    if dropdownFrame then
        dropdownFrame:Hide()
        dropdownFrame:SetParent(nil)  -- Detach it from its parent
    end
end
function ggMenu:CreateMenu(parent, tblEntries, defaultText, width)
    if not parent or not tblEntries then
        code:fOut('CreateMenu: Parent or entries not provided.', 'FF0000')
        return
    end
    
    local menuEntries, menuWidth = tblEntries, width or 200

    -- Create a frame for the dropdown menu
    local dropdownFrame = CreateFrame("Frame", "MyDropdownMenu", parent, "UIDropDownMenuTemplate")
    dropdownFrame:SetPoint('CENTER', parent, 'CENTER', 0, 0)

    -- Set default text before an item is selected
    UIDropDownMenu_SetText(dropdownFrame, defaultText)
    UIDropDownMenu_SetWidth(dropdownFrame, menuWidth)

    -- Center the default text
    local dropdownText = _G[dropdownFrame:GetName().."Text"]
    _G[dropdownFrame:GetName().."Text"] = nil
    dropdownText:ClearAllPoints()
    dropdownText:SetPoint("CENTER", dropdownFrame, "CENTER", 0, 2)
    dropdownText:SetJustifyH("CENTER")

    -- Initialize the dropdown menu
    UIDropDownMenu_Initialize(dropdownFrame, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()

        if level == 1 then
            for _, item in ipairs(menuEntries) do
                info.text = item.text
                info.notCheckable = item.notCheckable
                info.hasArrow = item.hasArrow
                info.menuList = item.menuList
                info.func = item.func
                UIDropDownMenu_AddButton(info)
            end
        elseif menuList then
            for _, childItem in ipairs(menuList) do
                info.text = childItem.text
                info.notCheckable = childItem.notCheckable
                info.func = childItem.func
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    return dropdownFrame
end