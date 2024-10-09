-- Upgrade.lua
-- Check for item level upgrades in the player's inventory and print that to the chat box, all pretty and color-coded to item rarity when you click a button

-- Load class gear types from classGear.lua
local _, playerClass = UnitClass("player")
local validGearTypes = ClassGearTypes[playerClass] or {}

-- Mapping of inventory slots to readable names
local slotNamesReadable = {
    HeadSlot = "Head",
    NeckSlot = "Neck",
    ShoulderSlot = "Shoulders",
    BackSlot = "Back",  -- Ensure this is included
    ChestSlot = "Chest",
    ShirtSlot = "Shirt",
    TabardSlot = "Tabard",
    WristSlot = "Wrist",
    HandsSlot = "Hands",
    WaistSlot = "Waist",
    LegsSlot = "Legs",
    FeetSlot = "Feet",
    Finger0Slot = "Ring 1",
    Finger1Slot = "Ring 2",
    Trinket0Slot = "Trinket 1",
    Trinket1Slot = "Trinket 2",
    MainHandSlot = "Main Hand",
    SecondaryHandSlot = "Off Hand",
}

-- Mapping of equipped item types to their corresponding inventory slot IDs
local slotNames = {
    ["INVTYPE_HEAD"] = "HeadSlot",
    ["INVTYPE_NECK"] = "NeckSlot",
    ["INVTYPE_SHOULDER"] = "ShoulderSlot",
    ["INVTYPE_CLOAK"] = "BackSlot", -- Ensure this is present for back items
    ["INVTYPE_CHEST"] = "ChestSlot",
    ["INVTYPE_ROBE"] = "ChestSlot",
    ["INVTYPE_SHIRT"] = "ShirtSlot",
    ["INVTYPE_TABARD"] = "TabardSlot",
    ["INVTYPE_WRIST"] = "WristSlot",
    ["INVTYPE_HAND"] = "HandsSlot",
    ["INVTYPE_WAIST"] = "WaistSlot",
    ["INVTYPE_LEGS"] = "LegsSlot",
    ["INVTYPE_FEET"] = "FeetSlot",
    ["INVTYPE_FINGER"] = {"Finger0Slot", "Finger1Slot"}, -- Rings
    ["INVTYPE_TRINKET"] = {"Trinket0Slot", "Trinket1Slot"}, -- Trinkets
    ["INVTYPE_2HWEAPON"] = "MainHandSlot", -- 2H weapons
    ["INVTYPE_WEAPON"] = "MainHandSlot", -- 1H weapons
    ["INVTYPE_WEAPONMAINHAND"] = "MainHandSlot", -- Main hand weapon
    ["INVTYPE_WEAPONOFFHAND"] = "SecondaryHandSlot", -- Off hand weapon
    ["INVTYPE_HOLDABLE"] = "SecondaryHandSlot", -- Holdable items
}

local function CompareInventoryToEquipped()
    local printedItems = {}
    local upgradesFound = false

    -- Loop through the player's bags (bag slots 0 through 4)
    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                -- Retrieve item info from inventory
                local itemName, _, itemRarity, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
                local itemLevel = GetDetailedItemLevelInfo(itemLink)

                -- Check if item type matches the class-specific gear types
                local isValidType = false
                if tContains(validGearTypes, itemSubType) or itemSubType == "Miscellaneous" then
                    isValidType = true
                else
                    -- Check for alternative types if the item is a finger, trinket, or back item
                    if equipSlot == "INVTYPE_FINGER" or equipSlot == "INVTYPE_TRINKET" or equipSlot == "INVTYPE_CLOAK" then
                        isValidType = true
                    end
                end

                if isValidType then
                    local inventorySlotId = slotNames[equipSlot]

                    if inventorySlotId then
                        if type(inventorySlotId) == "table" then
                            -- Handle slots with multiple possible locations (e.g., finger/trinket)
                            for _, slotId in ipairs(inventorySlotId) do
                                local equippedItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotId))

                                -- If there's no equipped item, consider it an upgrade
                                if not equippedItemLink or (itemLevel > GetDetailedItemLevelInfo(equippedItemLink)) then
                                    upgradesFound = true
                                    printedItems[itemLink] = true

                                    -- Color-coded item rarity
                                    local itemColor = select(4, GetItemQualityColor(itemRarity))
                                    local coloredItemName = "|c" .. itemColor .. itemName .. "|r" -- Color the item name

                                    -- Include the bag and slot number in the print message
                                    print(coloredItemName .. " (Item Level: " .. itemLevel .. ") is an upgrade for your " .. slotNamesReadable[slotId] .. "! Found in bag " .. bag .. ", slot " .. slot .. ".")
                                end
                            end
                        else
                            -- For single slots (e.g., head, chest, back)
                            local equippedItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(inventorySlotId))

                            -- If there's no equipped item, consider it an upgrade
                            if not equippedItemLink or (itemLevel > GetDetailedItemLevelInfo(equippedItemLink)) then
                                upgradesFound = true
                                printedItems[itemLink] = true

                                -- Color-coded item rarity
                                local itemColor = select(4, GetItemQualityColor(itemRarity))
                                local coloredItemName = "|c" .. itemColor .. itemName .. "|r" -- Color the item name

                                -- Include the bag and slot number in the print message
                                print(coloredItemName .. " (Item Level: " .. itemLevel .. ") is an upgrade for your " .. slotNamesReadable[inventorySlotId] .. "! Found in bag " .. bag .. ", slot " .. slot .. ".")
                            end
                        end
                    end
                end
            end
        end
    end

    -- If no upgrades are found, print a message
    if not upgradesFound then
        print("No Upgrades found!")
    end
end

-- Create the minimap button
local button = CreateFrame("Button", "UpgradeButton", Minimap)
button:SetSize(24, 24)
button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10)

-- Set button textures
button:SetNormalTexture("Interface/Icons/UI_AllianceIcon-round")
button:SetHighlightTexture("Interface/Icons/UI_AllianceIcon-round")

-- Click event to check for upgrades
button:SetScript("OnClick", CompareInventoryToEquipped)
