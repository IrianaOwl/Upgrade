-- Upgrade.lua: Check for item level upgrades in the player's inventory.

-- This is where we get the players class and spec and also create an empty temporary table to store gear types for the players class and spec
-- We do this because we need to know what types of weapons and armor are valid for the players class and spec 
local _, playerClass = UnitClass("player")
local playerSpecIndex = GetSpecialization()
local validGearTypes = {}

-- Create a function to update the empty table we made and then looks up the classgeartypes table in the classgear.lua that is
-- loaded in the toc file before this one 
-- This ensures that the addon loads the gear types the player is using 
local function UpdateValidGearTypes()
    playerSpecIndex = GetSpecialization()  -- WHY ARE WE CALLING THIS AGAIN WHEN WE CALLED IT ABOVE?
    validGearTypes = {}

    if playerSpecIndex and ClassGearTypes[playerClass] then
        validGearTypes = ClassGearTypes[playerClass][playerSpecIndex] or {}
    else
        print("Invalid class or specialization. Using default gear types.")
        validGearTypes = ClassGearTypes[playerClass] and ClassGearTypes[playerClass]["default"] or {}
    end
end

-- Notice when the player changes spec and update to the gear types for that spec.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function()
    UpdateValidGearTypes()
    print("Specialization changed. Valid gear types updated.")
end)
UpdateValidGearTypes() 

-- Mapping the item types to the paper doll slot names and also adding in readable names that look better when printed.
-- Combined the mapping and readable names in one
local slotNames = {
    ["INVTYPE_HEAD"] = { "HEADSLOT", "Head" },
    ["INVTYPE_NECK"] = { "NECKSLOT", "Neck" },
    ["INVTYPE_SHOULDER"] = { "SHOULDERSLOT", "Shoulders" },
    ["INVTYPE_CLOAK"] = { "BACKSLOT", "Back" },
    ["INVTYPE_CHEST"] = { "CHESTSLOT", "Chest" },
    ["INVTYPE_WRIST"] = { "WRISTSLOT", "Wrist" },
    ["INVTYPE_HAND"] = { "HANDSSLOT", "Hands" },
    ["INVTYPE_WAIST"] = { "WAISTSLOT", "Waist" },
    ["INVTYPE_LEGS"] = { "LEGSSLOT", "Legs" },
    ["INVTYPE_FEET"] = { "FEETSLOT", "Feet" },
    ["INVTYPE_FINGER"] = { { "FINGER0SLOT", "FINGER1SLOT" }, "Ring" },
    ["INVTYPE_TRINKET"] = { { "TRINKET0SLOT", "TRINKET1SLOT" }, "Trinket" },
    ["INVTYPE_WEAPONMAINHAND"] = { "MAINHANDSLOT", "Main Hand" },
    ["INVTYPE_WEAPONOFFHAND"] = { "SECONDARYHANDSLOT", "Off Hand" },
    ["INVTYPE_SHIELD"] = { "SECONDARYHANDSLOT", "Shield" },
    ["INVTYPE_RANGED"] = { "MAINHANDSLOT", "Ranged" },
}

-- Check if the item is useable by the player's class and spec
local function IsValidItemType(itemSubType, equipSlot) -- checks itemsubtype (eg. plate, leather) and equip slot (invtype_head)
    if not validGearTypes or #validGearTypes == 0 then -- checks against the table we created at the beginning that holds the current valid gear types 
        return false -- if they return false, the item is not valid
    end
-- in the validgeartypes table we've also specified exclusions and this checks those, if they are TRUE then we return it 
-- as false, meaning the items are invalid, this is a problem I ran into with shields and ranged weapons specifically
    if validGearTypes.exclusions and validGearTypes.exclusions[itemSubType] then
        return false
    end
end

-- This is the function to print when we find an Upgrade
-- It pulls the items rarity color and formats the items name in that color then prints the item, it's location in the players bags
-- and what item slot in the paper doll that it is an upgrade for.
-- We have to create the function before we call it when we do the comparison below this.
local function PrintUpgradeMessage(itemName, itemRarity, itemLevel, slotName, bag, slot)
    local itemColor = select(4, GetItemQualityColor(itemRarity))
    local coloredItemName = "|c" .. itemColor .. itemName .. "|r"
    print(coloredItemName .. " (Item Level: " .. itemLevel .. ") is an upgrade for your " .. slotName .. "! Found in bag " .. bag .. ", slot " .. slot .. ".")
end

-- Compare inventory items to equipped items, we search through each of the players bags from 0 - 4 (5 is reagent bag, no gear there)
-- It calls the ItemLink which has all the info we need such as the item name, its rarity, its subtype, and its equipment slot
local function CompareInventoryToEquipped()
    local upgradesFound = false

    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName, _, itemRarity, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
                local itemLevel = GetDetailedItemLevelInfo(itemLink) -- we also then pulls the item level from the item link for the comparison 

                if IsValidItemType(itemSubType, equipSlot) then
                    local inventorySlotData = slotNames[equipSlot]
                    if inventorySlotData then
                        local equippedSlots = type(inventorySlotData[1]) == "table" and inventorySlotData[1] or { inventorySlotData[1] }
                        for _, slotId in ipairs(equippedSlots) do
                            local equippedItemLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotId))
                            local equippedItemLevel = equippedItemLink and GetDetailedItemLevelInfo(equippedItemLink) or 0

                            if not equippedItemLink or itemLevel > equippedItemLevel then
                                upgradesFound = true
                                PrintUpgradeMessage(itemName, itemRarity, itemLevel, inventorySlotData[2], bag, slot)
                            end
                        end
                    end
                end
            end
        end
    end

    if not upgradesFound then
        print("No upgrades found!")
    end
end

-- Create the minimap button.
local button = CreateFrame("Button", "UpgradeButton", Minimap)
button:SetSize(24, 24)
button:SetNormalTexture("Interface\\Icons\\UI_AllianceIcon-round")
button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
button:SetScript("OnClick", CompareInventoryToEquipped)
