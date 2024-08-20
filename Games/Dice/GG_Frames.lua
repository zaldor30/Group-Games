local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.diceBase = {}
local dBase, diceBase = {}, ns.diceBase

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    --dBase:SetShown(false)
end

function dBase:Init()
    self.version = '1.0.0'
end
function dBase:SetShown(val)
    if not val then
        diceBase.tblBase.frame:SetShown(false)
        return
    end

    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    if diceBase.tblBase.frame then
        diceBase:ClearData()
        diceBase.tblBase.frame:SetShown(true)
        return
    end

    diceBase:ClearData()
    self:CreateBaseFrame()
    self:CreateLeftPane()
    self:CreateInstructionsPane()
    self:CreateControlPane()
end
function dBase:CreateBaseFrame()
    local of = ns.gameFrame

    local frame = CreateFrame('Frame', 'GG_Dice_HighRoller', of, 'BackdropTemplate')
    frame:SetPoint('TOPLEFT', of, 'TOPLEFT', 0, 0)
    frame:SetPoint('BOTTOMRIGHT', of, 'BOTTOMRIGHT', 0, 0)
    frame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    frame:SetFrameStrata('DIALOG')
    frame:SetShown(true)
    diceBase.tblBase.frame = frame
end
function dBase:CreateLeftPane()
    local frame = diceBase.tblBase.frame

    --* Player Rolls Frame
    local playerRolls = CreateFrame('Frame', 'GG_Dice_Base_PlayerRolls', frame, 'BackdropTemplate')
    playerRolls:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, 0)
    playerRolls:SetSize(200, frame:GetHeight())
    playerRolls:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    playerRolls:SetBackdropColor(1, 1, 1, 0)
    playerRolls:SetBackdropBorderColor(1, 1, 1, 1)
    playerRolls:SetFrameStrata('DIALOG')
    playerRolls:SetShown(true)

    --* Player Rolls ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "GG_Dice_Base_PlayerRolls_ScrollFrame", playerRolls, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(playerRolls:GetWidth()-20, playerRolls:GetHeight()-20)  -- Set the size of the scroll frame
    scrollFrame:SetPoint("CENTER", playerRolls, "CENTER", 0, 0)  -- Position it in the center of the screen

    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()  -- Hide the scrollbar initially

    local contentFrame = CreateFrame("Frame", "GG_Dice_Base_PlayerRolls_ContentFrame", scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 0)
    scrollFrame:SetScrollChild(contentFrame)

    diceBase.tblBase.playerRolls = contentFrame
end
function dBase:CreateInstructionsPane()
    local frame = diceBase.tblBase.frame

    --* instructions Frame
    local instructions = CreateFrame('Frame', 'GG_Dice_Base_PlayerRolls', frame, 'BackdropTemplate')
    instructions:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, 0)
    instructions:SetSize(225, 50)
    instructions:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    instructions:SetBackdropColor(1, 1, 1, 0)
    instructions:SetBackdropBorderColor(1, 1, 1, 1)
    instructions:SetFrameStrata('DIALOG')
    instructions:SetShown(true)
    diceBase.tblBase.instructions = diceBase.tblBase.instructions or {}
    diceBase.tblBase.instructions.frame = instructions

    local scrollFrame = CreateFrame("ScrollFrame", "MyScrollableTextFrame", instructions, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(instructions:GetWidth(), instructions:GetHeight())  -- Set the size of the scroll frame
    scrollFrame:SetPoint("CENTER", instructions, "CENTER", 0, 0)  -- Position it in the center of the screen

    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()

    local contentFrame = CreateFrame("Frame", "MyContentFrame", scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 400)

    local text = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -7)  -- Position the text within the content frame
    text:SetWidth(contentFrame:GetWidth() - 20)  -- Make the text fit within the content frame with some padding
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetText('')
    local textHeight = text:GetStringHeight()
    contentFrame:SetHeight(textHeight + 10)  -- Add some padding
    scrollFrame:SetScrollChild(contentFrame)
    diceBase.tblBase.instructions.contentText = text
end
function dBase:CreateControlPane()
    local frame = diceBase.tblBase.frame
    local instructions = diceBase.tblBase.instructions.frame

    --* Button Frame
    local buttonFrame = CreateFrame('Frame', 'GG_Dice_Base_PlayerRolls', frame, 'BackdropTemplate')
    buttonFrame:SetPoint('TOPLEFT', instructions, 'BOTTOMLEFT', 0, 0)
    buttonFrame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -10, 0)
    buttonFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    buttonFrame:SetBackdropColor(1, 1, 1, 0)
    buttonFrame:SetBackdropBorderColor(1, 1, 1, 1)
    buttonFrame:SetFrameStrata('DIALOG')
    buttonFrame:SetShown(true)
    diceBase.tblBase.buttonFrame = buttonFrame
end
dBase:Init()

function diceBase:Init()
    self.tblBase = {}
end
function diceBase:SetShown(val) dBase:SetShown(val) end
function diceBase:ClearData()
    if not diceBase.tblBase.instructions then return end
    local buttonFrame = diceBase.tblBase.buttonFrame
    if buttonFrame then
        for _, child in ipairs({buttonFrame:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end
    end

    local instructionsText = diceBase.tblBase.instructions.contentText
    if instructionsText then
        instructionsText:SetText(' ')
    end
end
diceBase:Init()

--* Globals
--[[
    ns.diceBase.tblBase.frame
    ns.diceBase.tblBase.playerRolls (contentFrame)
    ns.diceBase.tblBase.instructions.frame (frame)
    ns.diceBase.tblBase.instructions.contentText (contentText)
    ns.diceBase.tblBase.buttonFrame (frame)
--]]