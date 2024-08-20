local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.diceCode = {}
local diceCode = ns.diceCode

function diceCode:ClearAllRows(tblRound)
    if not tblRound then return end

    tblRound.rowsRoll = tblRound.rowsRoll or {}
    for _, row in ipairs(tblRound.rowsRoll) do
        row:Hide()
        row:SetParent(nil)
    end
    tblRound.rowsRoll = table.wipe(tblRound.rowsRoll)
    ns.diceBase.tblBase.playerRolls:SetHeight(0)

    return tblRound
end
function diceCode:CreateButtonFrame(label, btnPoint, parent, parentPoint, pos1, pos2, x, y, useRedHighlight)
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
function diceCode:createContentRow(tblRound, name, rec, yOffset, isTitle)
    local parent = ns.diceBase.tblBase.playerRolls

    rec = type(rec) == 'table' and rec or {
        roll = rec,
        class = nil,
        isHighest = false,
    }

    local lineSpacing = 20
    local row = CreateFrame("Frame", nil, parent)

    row:SetSize(parent:GetWidth(), lineSpacing)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    local highLight = row:CreateTexture(nil, 'OVERLAY')
    highLight:SetAllPoints(row)
    highLight:SetAtlas('bonusobjectives-bar-bg')
    highLight:SetShown(isTitle or false)

    -- First Column - Player Name
    local nameOut = name:gsub('%-.*', '')
    local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", row, "LEFT", 0, 1)
    nameText:SetWidth(parent:GetWidth() * 0.55)  -- Set width for the first column
    nameText:SetJustifyH("LEFT")
    nameText:SetText(rec.class and ns.code:cPlayer(nameOut, rec.class) or nameOut)
    nameText:SetWordWrap(false)

    -- Second column (Value or Roll Result)
    local rollOut = (rec.roll ~= '0' and type(rec.roll) == 'number') and ns.code:FormatNumberWithCommas(rec.roll) or rec.roll
    if rec.roll == '0' then rollOut = ''
    elseif type(rec.roll) == 'number' and rec.isHighest then
        rollOut = ns.code:cText('FF00FF00', rollOut)
    elseif type(rec.roll) == 'number' and rec.isLowest then
        rollOut = ns.code:cText('FFFF0000', rollOut)
    end

    local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    valueText:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
    valueText:SetWidth(parent:GetWidth() * 0.35)  -- Set width for the second column
    valueText:SetJustifyH('CENTER')
    valueText:SetTextColor(1, 1, 1, 1)
    valueText:SetText(rollOut)

    tinsert(tblRound.rowsRoll, row)
    parent:SetHeight(lineSpacing * #tblRound.rowsRoll)

    return tblRound
end