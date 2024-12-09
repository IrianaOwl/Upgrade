-- Upgrade.lua
-- Check for item level upgrades in the player's inventory and print that to the chat box, all pretty and color-coded to item rarity when you click a button

-- Load gear types based on class and specialization from classGear.lua
local _, playerClass = UnitClass("player") -- gets the class of the player character and assigns it to playerClass
local playerSpecIndex = GetSpecialization()  -- Get specialization index
local validGearTypes = {} -- Holds valid gear types based on the class and specialization

-- Function to update valid gear types based on the player's class and specialization
local function UpdateValidGearTypes()
    playerSpecIndex = GetSpecialization()  -- Get the current specialization index
    validGearTypes = {}  -- Clear the previous gear types

    -- Check if the player's specialization is valid and exists in ClassGearTypes
    if playerSpecIndex and ClassGearTypes[playerClass] then
        -- Check if the specialization exists for this class
        validGearTypes = ClassGearTypes[playerClass][playerSpecIndex] or {}
    else
        print("Invalid class or specialization. Falling back to default gear types.")
        -- Optionally set some default valid gear types if no specialization data is available
        validGearTypes = ClassGearTypes[playerClass] and ClassGearTypes[playerClass]["default"] or {}
    end
end


-- Register for specialization change event
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- To handle initial spec setting when entering the game

-- Event handler to update valid gear types when the specialization changes
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        UpdateValidGearTypes()  -- Update valid gear types when spec changes
        print("Specialization changed, valid gear types updated.")
    end
end)

-- Call UpdateValidGearTypes initially to set the valid gear types when the addon loads
UpdateValidGearTypes()

-- Maps equipment types to the internal slot names (Used in GetInventorySlotInfo)
local slotNames = {
    ["INVTYPE_HEAD"] = "HEADSLOT",
    ["INVTYPE_NECK"] = "NECKSLOT",
    ["INVTYPE_SHOULDER"] = "SHOULDERSLOT",
    ["INVTYPE_CLOAK"] = "BACKSLOT", -- Ensure this is present for back items
    ["INVTYPE_CHEST"] = "CHESTSLOT",
    ["INVTYPE_ROBE"] = "CHESTSLOT",
    ["INVTYPE_SHIRT"] = "SHIRTSLOT",
    ["INVTYPE_TABARD"] = "TABARDSLOT",
    ["INVTYPE_WRIST"] = "WRISTSLOT",
    ["INVTYPE_HAND"] = "HANDSSLOT",
    ["INVTYPE_WAIST"] = "WAISTSLOT",
    ["INVTYPE_LEGS"] = "LEGSSLOT",
    ["INVTYPE_FEET"] = "FEETSLOT",
    ["INVTYPE_FINGER"] = {"FINGER0SLOT", "FINGER1SLOT"}, -- Rings
    ["INVTYPE_TRINKET"] = {"TRINKET0SLOT", "TRINKET1SLOT"}, -- Trinkets
    ["INVTYPE_2HWEAPON"] = "MAINHANDSLOT", -- 2H weapons
    ["INVTYPE_WEAPON"] = "MAINHANDSLOT", -- 1H weapons
    ["INVTYPE_WEAPONMAINHAND"] = "MAINHANDSLOT", -- Main hand weapon
    ["INVTYPE_WEAPONOFFHAND"] = "SECONDARYHANDSLOT", -- Off hand weapon
    ["INVTYPE_HOLDABLE"] = "SECONDARYHANDSLOT", -- Holdable items
    ["INVTYPE_SHIELD"] = "SECONDARYHANDSLOT", -- Shields
    -- Treat ranged weapons like 2H weapons for inventory comparison
    ["INVTYPE_RANGED"] = "MAINHANDSLOT", -- Ranged weapons (Bows, Crossbows, Guns) are treated as 2H weapons
}

-- Maps the internal slot names to something nicer to look at when printed
local slotNamesReadable = {
    HEADSLOT = "Head",
    NECKSLOT = "Neck",
    SHOULDERSLOT = "Shoulders",
    BACKSLOT = "Back",  -- Ensure this is included
    CHESTSLOT = "Chest",
    SHIRTSLOT = "Shirt",
    TABARDSLOT = "Tabard",
    WRISTSLOT = "Wrist",
    HANDSSLOT = "Hands",
    WAISTSLOT = "Waist",
    LEGSSLOT = "Legs",
    FEETSLOT = "Feet",
    FINGER0SLOT = "Ring 1",
    FINGER1SLOT = "Ring 2",
    TRINKET0SLOT = "Trinket 1",
    TRINKET1SLOT = "Trinket 2",
    MAINHANDSLOT = "Main Hand",
    SECONDARYHANDSLOT = "Off Hand"
}

-- Function to check if the item is a valid type, it checks validGearTypes which is defined for the current class and specialization.
-- It also checks for Miscellaneous, Finger, Trinket, and Cloak because those are often special cases.
local function IsValidItemType(itemSubType, equipSlot)
    -- First, check if validGearTypes exists for the class and spec
    if not validGearTypes or #validGearTypes == 0 then
        return false  -- If no valid gear types exist for the class/spec, return false
    end


    -- Check exclusions for the specific specialization
    if validGearTypes.exclusions and validGearTypes.exclusions[itemSubType] then
        return false  -- If the item subtype is in the exclusions list, return false
    end
    -- Check if the item is in the valid gear types for the specialization or is a special case like rings, trinkets, or cloaks
    return tContains(validGearTypes, itemSubType) or 
           equipSlot == "INVTYPE_FINGER" or 
           equipSlot == "INVTYPE_TRINKET" or 
           equipSlot == "INVTYPE_CLOAK" or
           equipSlot == "INVTYPE_NECK" or
           equipSlot == "INVTYPE_RANGED" -- Treating ranged weapons like 2H weapons for comparison
end

-- Function to print the upgrade message with the info listed in brackets next to the function name, then call the item rarity color and make it pretty
local function PrintUpgradeMessage(itemName, itemRarity, itemLevel, inventorySlotId, bag, slot)
    local itemColor = select(4, GetItemQualityColor(itemRarity))
    local coloredItemName = "|c" .. itemColor .. itemName .. "|r" -- Color the item name
    print(coloredItemName .. " (Item Level: " .. itemLevel .. ") is an upgrade for your " .. slotNamesReadable[inventorySlotId] .. "! Found in bag " .. bag .. ", slot " .. slot .. ".")
end

-- Function to compare items in the inventory with equipped items
local function CompareInventoryToEquipped()
    local upgradesFound = false

    -- Loop through all of the players bags
    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                -- Retrieve item info from inventory
                local itemName, _, itemRarity, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
                local itemLevel = GetDetailedItemLevelInfo(itemLink)

                -- Check if item type matches the class-specific gear types
                if IsValidItemType(itemSubType, equipSlot) then
                    local inventorySlotId = slotNames[equipSlot]

                    if inventorySlotId then
                        local equippedItemLink
                        if type(inventorySlotId) == "table" then
                            -- Handle slots with multiple possible locations (e.g., finger/trinket)
                            for _, slotId in ipairs(inventorySlotId) do
                                equippedItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotId))
                                local equippedItemLevel = equippedItemLink and GetDetailedItemLevelInfo(equippedItemLink) or 0

                                -- Check for upgrades
                                if not equippedItemLink or itemLevel > equippedItemLevel then
                                    upgradesFound = true
                                    PrintUpgradeMessage(itemName, itemRarity, itemLevel, slotId, bag, slot)
                                end
                            end
                        else
                            -- Single item slot, like main hand
                            equippedItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(inventorySlotId))
                            local equippedItemLevel = equippedItemLink and GetDetailedItemLevelInfo(equippedItemLink) or 0

                            -- Check for upgrades
                            if not equippedItemLink or itemLevel > equippedItemLevel then
                                upgradesFound = true
                                PrintUpgradeMessage(itemName, itemRarity, itemLevel, inventorySlotId, bag, slot)
                            end
                        end
                    end
                end
            end
        end
    end

    -- If no upgrades were found, print a message saying so
    if not upgradesFound then
        print("No upgrades found!")
    end
end


-- Create the minimap button
local button = CreateFrame("Button", "UpgradeButton", Minimap)
button:SetSize(24, 24)
button:SetNormalTexture("Interface\\Icons\\UI_AllianceIcon-round")
button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
button:SetScript("OnClick", CompareInventoryToEquipped)
