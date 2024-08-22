local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.tGame = {}
local gBase, tGame = {}, ns.tGame

local function obsCLOSE_SCANNER()
    ns.observer:Unregister('CLOSE_SCREENS', obsCLOSE_SCANNER)
    --gBase:SetShown(false)
end

function gBase:Init()
    self.version = '1.0.0'
end
function gBase:SetShown(val)
    if not val then
        tGame.tblBase.frame:SetShown(false)
        return
    end

    ns.observer:Register('CLOSE_SCREENS', obsCLOSE_SCANNER)

    if tGame.tblBase.frame then
        tGame:ClearData()
        tGame.tblBase.frame:SetShown(true)
        return
    end

    tGame:ClearData()
    self:CreateBaseFrame()
    self:CreateLeftPane()
    self:CreateInstructionsPane()
    self:CreateControlPane()
end
function gBase:CreateBaseFrame()
    local of = ns.gameFrame

    local frame = CreateFrame('Frame', 'GG_Dice_HighRoller', of, 'BackdropTemplate')
    frame:SetPoint('TOPLEFT', of, 'TOPLEFT', 0, 0)
    frame:SetPoint('BOTTOMRIGHT', of, 'BOTTOMRIGHT', 0, 0)
    frame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    frame:SetFrameStrata('DIALOG')
    frame:SetShown(true)
    tGame.tblBase.frame = frame
end
function gBase:CreateLeftPane()
    local frame = tGame.tblBase.frame

    --* Player Rolls Frame
    local playerRolls = CreateFrame('Frame', 'GG_tGame_PlayerRolls', frame, 'BackdropTemplate')
    playerRolls:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, 0)
    playerRolls:SetSize(200, frame:GetHeight())
    playerRolls:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    playerRolls:SetBackdropColor(1, 1, 1, 0)
    playerRolls:SetBackdropBorderColor(1, 1, 1, 1)
    playerRolls:SetFrameStrata('DIALOG')
    playerRolls:SetShown(true)

    --* Player Rolls ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", "GG_tGame_PlayerRolls_ScrollFrame", playerRolls, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(playerRolls:GetWidth()-30, playerRolls:GetHeight()-20)  -- Set the size of the scroll frame
    scrollFrame:SetPoint("CENTER", playerRolls, "CENTER", 0, 0)  -- Position it in the center of the screen

    local contentFrame = CreateFrame("Frame", "GG_tGame_PlayerRolls_ContentFrame", scrollFrame)
    contentFrame:SetSize(scrollFrame:GetWidth(), 0)
    scrollFrame:SetScrollChild(contentFrame)

    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
    scrollBar:Hide()

    tGame.tblBase.playerRolls = contentFrame
    ns.tGame.playerRolls = contentFrame
end
function gBase:CreateInstructionsPane()
    local frame = tGame.tblBase.frame

    --* instructions Frame
    local instructions = CreateFrame('Frame', 'GG_tGame_PlayerRolls', frame, 'BackdropTemplate')
    instructions:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -10, 0)
    instructions:SetSize(225, 50)
    instructions:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    instructions:SetBackdropColor(1, 1, 1, 0)
    instructions:SetBackdropBorderColor(1, 1, 1, 1)
    instructions:SetFrameStrata('DIALOG')
    instructions:SetShown(true)
    tGame.tblBase.instructions = tGame.tblBase.instructions or {}
    tGame.tblBase.instructions.frame = instructions

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
    ns.tGame.instructions = text
end
function gBase:CreateControlPane()
    local frame = tGame.tblBase.frame
    local instructions = tGame.tblBase.instructions.frame

    --* Button Frame
    local buttonFrame = CreateFrame('Frame', 'GG_tGame_PlayerRolls', frame, 'BackdropTemplate')
    buttonFrame:SetPoint('TOPLEFT', instructions, 'BOTTOMLEFT', 0, 0)
    buttonFrame:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -10, 0)
    buttonFrame:SetBackdrop(BackdropTemplate(BLANK_BACKGROUND))
    buttonFrame:SetBackdropColor(1, 1, 1, 0)
    buttonFrame:SetBackdropBorderColor(1, 1, 1, 1)
    buttonFrame:SetFrameStrata('DIALOG')
    buttonFrame:SetShown(true)
    tGame.tblBase.buttonFrame = buttonFrame
end
gBase:Init()

function tGame:Init()
    self.tblBase = {}
end
function tGame:SetShown(val) gBase:SetShown(val) end
function tGame:ClearData()
    if not tGame.tblBase.instructions then return end
    local buttonFrame = tGame.tblBase.buttonFrame
    if buttonFrame then
        for _, child in ipairs({buttonFrame:GetChildren()}) do
            if type(child.GetText) == "function" then child:SetText('') end
            child:Hide()
            child:SetParent(nil)
        end
    end

    local instructionsText = tGame.tblBase.instructions.contentText
    if instructionsText then instructionsText:SetText('') end
end
tGame:Init()

--* Globals
--[[
    ns.tGame.tblBase.frame
    ns.tGame.playerRolls (contentFrame)
    ns.tGame.tblBase.instructions.frame (frame)
    ns.tGame.instructions (contentText)
    ns.tGame.tblBase.buttonFrame (frame)
--]]