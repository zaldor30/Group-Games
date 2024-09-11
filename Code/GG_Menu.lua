local _, ns = ... -- Namespace (myaddon, namespace)
local L = LibStub("AceLocale-3.0"):GetLocale('GroupGames')

ns.ggMenu = {}
local ggMenu = ns.ggMenu

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
        ns.code:fOut('CreateMenu: Parent or entries not provided.', 'FF0000')
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
                if not item.hide then
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        elseif menuList then
            for _, childItem in ipairs(menuList) do
                info.text = childItem.text
                info.notCheckable = childItem.notCheckable
                info.func = childItem.func
                if not childItem.hide then
                    UIDropDownMenu_AddButton(info, level)
                end
            end
        end
    end)

    return dropdownFrame
end
function ggMenu:ClearButtons(buttons)
    for _, button in ipairs(buttons) do
        button:Hide()           -- Hide the button
        button:SetParent(nil)   -- Detach the button from its parent
    end
    wipe(buttons)               -- Clear the table
end
function ggMenu:CreateFavoriteButtons(parent, menuEntries, buttonWidth, buttonHeight, padding)
    local buttons = {}
    local index = 1

    buttonWidth = buttonWidth or 100
    buttonHeight = buttonHeight or 25
    padding = padding or 5

    local count = 0
    for _, entry in ipairs(menuEntries) do
        count = count + 1
        if count > 6 then break end
        if entry.menuList then
            for _, item in ipairs(entry.menuList) do
                if item.fav and not item.hide then
                    -- Create the button
                    local button, highlight = ns.code:CreateButton(item.text, "TOPLEFT", parent, "TOPLEFT", 0, 0, buttonWidth, buttonHeight)

                    -- Calculate position
                    local row = math.floor((index - 1) / 2)
                    local col = (index - 1) % 2

                    -- Set position
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", parent, "TOPLEFT", col * (buttonWidth + padding), -row * (buttonHeight + padding))

                    -- Set the button's click function
                    button:SetScript("OnClick", item.func)
                    button:SetScript("OnEnter", function(self)
                        highlight:SetShown(true)
                    end)
                    button:SetScript("OnLeave", function(self)
                        highlight:SetShown(false)
                    end)

                    -- Store the button in the table
                    table.insert(buttons, button)

                    -- Increment the index for positioning
                    index = index + 1
                end
            end
        end
    end

    return buttons
end