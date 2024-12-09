-- Upgrade.lua: Check for item level upgrades in the player's inventory.

-- Load gear types based on class and specialization.
local _, playerClass = UnitClass("player")
local playerSpecIndex = GetSpecialization()
local validGearTypes = {}

-- Update valid gear types based on the player's class and specialization.
local function UpdateValidGearTypes()
    playerSpecIndex = GetSpecialization()
    validGearTypes = {}

    if playerSpecIndex and ClassGearTypes[playerClass] then
        validGearTypes = ClassGearTypes[playerClass][playerSpecIndex] or {}
    else
        print("Invalid class or specialization. Using default gear types.")
        validGearTypes = ClassGearTypes[playerClass] and ClassGearTypes[playerClass]["default"] or {}
    end
end

-- Detect specialization changes.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function()
    UpdateValidGearTypes()
    print("Specialization changed. Valid gear types updated.")
end)

UpdateValidGearTypes()

-- Equipment slot mapping.
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

-- Check if the item is valid for the player's class and spec.
local function IsValidItemType(itemSubType, equipSlot)
    if not validGearTypes or #validGearTypes == 0 then
        return false
    end

    if validGearTypes.exclusions and validGearTypes.exclusions[itemSubType] then
        return false
    end

    return tContains(validGearTypes, itemSubType) or 
           equipSlot == "INVTYPE_FINGER" or 
           equipSlot == "INVTYPE_TRINKET" or 
           equipSlot == "INVTYPE_CLOAK" or 
           equipSlot == "INVTYPE_NECK" or 
           equipSlot == "INVTYPE_RANGED"
end

-- Print the upgrade message.
local function PrintUpgradeMessage(itemName, itemRarity, itemLevel, slotName, bag, slot)
    local itemColor = select(4, GetItemQualityColor(itemRarity))
    local coloredItemName = "|c" .. itemColor .. itemName .. "|r"
    print(coloredItemName .. " (Item Level: " .. itemLevel .. ") is an upgrade for your " .. slotName .. "! Found in bag " .. bag .. ", slot " .. slot .. ".")
end

-- Compare inventory items to equipped items.
local function CompareInventoryToEquipped()
    local upgradesFound = false

    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName, _, itemRarity, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
                local itemLevel = GetDetailedItemLevelInfo(itemLink)

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
