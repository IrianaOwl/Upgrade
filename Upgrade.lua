-- Upgrade.lua
-- Check for item level upgrades in the player's inventory and print that to the chat box,
-- all pretty and color-coded to item rarity when you click a button.
-- Also adds "Upgrade available!" in red text to tooltips for better items.

local _, playerClass = UnitClass("player")
local playerSpecIndex = GetSpecialization()
local validGearTypes = {}

-- Update valid gear types based on the player's class and specialization
local function UpdateValidGearTypes()
    playerSpecIndex = GetSpecialization()
    validGearTypes = {}
    if playerSpecIndex and ClassGearTypes[playerClass] then
        validGearTypes = ClassGearTypes[playerClass][playerSpecIndex] or {}
    else
        print("Invalid class or specialization. Falling back to default gear types.")
        validGearTypes = ClassGearTypes[playerClass] and ClassGearTypes[playerClass]["default"] or {}
    end
end

-- Frame for login + spec change
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        UpdateValidGearTypes()
        print("Upgrade addon loaded. Valid gear types initialized.")
        self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local newSpec = GetSpecialization()
        if newSpec ~= playerSpecIndex then
            playerSpecIndex = newSpec
            UpdateValidGearTypes()
            print("Specialization changed, valid gear types updated.")
        end
    end
end)

-- Mapping equip slots to Blizzard slot names
local slotNames = {
    ["INVTYPE_HEAD"] = "HEADSLOT",
    ["INVTYPE_NECK"] = "NECKSLOT",
    ["INVTYPE_SHOULDER"] = "SHOULDERSLOT",
    ["INVTYPE_CLOAK"] = "BACKSLOT",
    ["INVTYPE_CHEST"] = "CHESTSLOT",
    ["INVTYPE_ROBE"] = "CHESTSLOT",
    ["INVTYPE_SHIRT"] = "SHIRTSLOT",
    ["INVTYPE_TABARD"] = "TABARDSLOT",
    ["INVTYPE_WRIST"] = "WRISTSLOT",
    ["INVTYPE_HAND"] = "HANDSSLOT",
    ["INVTYPE_WAIST"] = "WAISTSLOT",
    ["INVTYPE_LEGS"] = "LEGSSLOT",
    ["INVTYPE_FEET"] = "FEETSLOT",
    ["INVTYPE_FINGER"] = {"FINGER0SLOT", "FINGER1SLOT"},
    ["INVTYPE_TRINKET"] = {"TRINKET0SLOT", "TRINKET1SLOT"},
    ["INVTYPE_2HWEAPON"] = "MAINHANDSLOT",
    ["INVTYPE_WEAPON"] = "MAINHANDSLOT",
    ["INVTYPE_WEAPONMAINHAND"] = "MAINHANDSLOT",
    ["INVTYPE_WEAPONOFFHAND"] = "SECONDARYHANDSLOT",
    ["INVTYPE_HOLDABLE"] = "SECONDARYHANDSLOT",
    ["INVTYPE_SHIELD"] = "SECONDARYHANDSLOT",
    ["INVTYPE_RANGED"] = "MAINHANDSLOT",
}

-- Friendly slot names for printing
local slotNamesReadable = {
    HEADSLOT = "Head",
    NECKSLOT = "Neck",
    SHOULDERSLOT = "Shoulders",
    BACKSLOT = "Back",
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
    SECONDARYHANDSLOT = "Off Hand",
}

-- Check if item type is valid for player
local function IsValidItemType(itemSubType, equipSlot)
    if not validGearTypes or #validGearTypes == 0 then
        return false
    end
    if validGearTypes.exclusions and validGearTypes.exclusions[itemSubType] then
        return false
    end
    return tContains(validGearTypes, itemSubType)
        or equipSlot == "INVTYPE_FINGER"
        or equipSlot == "INVTYPE_TRINKET"
        or equipSlot == "INVTYPE_CLOAK"
        or equipSlot == "INVTYPE_NECK"
        or equipSlot == "INVTYPE_RANGED"
end

-- Check if an item is an upgrade
local function IsUpgradeItem(itemLink, equipSlot)
    if not itemLink then return false end
    local itemLevel = GetDetailedItemLevelInfo(itemLink)
    if not itemLevel then return false end
    local inventorySlotId = slotNames[equipSlot]
    if not inventorySlotId then return false end

    if type(inventorySlotId) == "table" then
        for _, slotId in ipairs(inventorySlotId) do
            local equippedLink = GetInventoryItemLink("player", GetInventorySlotInfo(slotId))
            local equippedItemLevel = equippedLink and GetDetailedItemLevelInfo(equippedLink) or 0
            if itemLevel > equippedItemLevel then
                return true
            end
        end
    else
        local equippedLink = GetInventoryItemLink("player", GetInventorySlotInfo(inventorySlotId))
        local equippedItemLevel = equippedLink and GetDetailedItemLevelInfo(equippedLink) or 0
        if itemLevel > equippedItemLevel then
            return true
        end
    end
    return false
end

-- Print upgrade message
local function PrintUpgradeMessage(itemName, itemRarity, itemLevel, inventorySlotId, bag, slot)
    local itemColor = select(4, GetItemQualityColor(itemRarity))
    local coloredItemName = "|c" .. itemColor .. itemName .. "|r"
    local message = string.format("%s (Item Level: %d) is an upgrade for your %s!",
        coloredItemName, itemLevel, slotNamesReadable[inventorySlotId])
    print(message .. string.format(" Found in bag %d, slot %d.", bag, slot))
end

-- Tooltip hook: mark upgrades
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if not data then return end
    if not tooltip.GetItem then return end  -- CHECK: method exists
    local name, itemLink = tooltip:GetItem()
    if not itemLink then return end

    local itemName, _, _, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
    if not itemName then return end

    if not IsValidItemType(itemSubType, equipSlot) then return end

    if IsUpgradeItem(itemLink, equipSlot) then
        tooltip:AddLine("|cffff2020Upgrade available!|r", 1, 0, 0)
        tooltip:Show()
    end
end)


-- Compare inventory to equipped items
local function CompareInventoryToEquipped()
    local upgradesFound = false
    for bag = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName, _, itemRarity, _, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
                if IsValidItemType(itemSubType, equipSlot) and IsUpgradeItem(itemLink, equipSlot) then
                    local inventorySlotId = slotNames[equipSlot]
                    if inventorySlotId then
                        if type(inventorySlotId) == "table" then
                            for _, slotId in ipairs(inventorySlotId) do
                                PrintUpgradeMessage(itemName, itemRarity, GetDetailedItemLevelInfo(itemLink), slotId, bag, slot)
                                upgradesFound = true
                            end
                        else
                            PrintUpgradeMessage(itemName, itemRarity, GetDetailedItemLevelInfo(itemLink), inventorySlotId, bag, slot)
                            upgradesFound = true
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

-- Minimap button
local button = CreateFrame("Button", "UpgradeButton", Minimap)
button:SetSize(24, 24)
button:SetNormalTexture("Interface\\ICONS\\Garrison_GreenArmorUpgrade.BLP")
button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
button:SetScript("OnClick", CompareInventoryToEquipped)
