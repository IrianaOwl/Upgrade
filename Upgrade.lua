-- Define slot names to map item types to their slot IDs
local slotNames = {
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_BODY"] = 4, -- Shirt
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5, -- Robe uses the Chest slot
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = 11, -- Finger 1 or Finger 2
    ["INVTYPE_TRINKET"] = 13, -- Trinket 1 or Trinket 2
    ["INVTYPE_CLOAK"] = 15, -- Back
    ["INVTYPE_WEAPON"] = 16, -- Main Hand or Off Hand
    ["INVTYPE_SHIELD"] = 17, -- Off Hand
    ["INVTYPE_2HWEAPON"] = 16, -- Two-Handed uses the Main Hand slot
    ["INVTYPE_WEAPONMAINHAND"] = 16, -- Main Hand
    ["INVTYPE_WEAPONOFFHAND"] = 17, -- Off Hand
    ["INVTYPE_HOLDABLE"] = 17, -- Held in Off Hand
    ["INVTYPE_RANGED"] = 18,
    ["INVTYPE_THROWN"] = 18,
    ["INVTYPE_RANGEDRIGHT"] = 18, -- Right Ranged (guns, bows)
    ["INVTYPE_TABARD"] = 19,
}

-- Define readable slot names
local readableSlotNames = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [4] = "Shirt",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger",
    [13] = "Trinket",
    [15] = "Back",
    [16] = "Weapon",
    [17] = "Shield",
    [18] = "Ranged",
    [19] = "Tabard",
}

-- Define item rarity color codes
local rarityColors = {
    [1] = "|cffffffff", -- Common
    [2] = "|cff1eff00", -- Uncommon
    [3] = "|cff0070dd", -- Rare
    [4] = "|cffa335ee", -- Epic
    [5] = "|cffff8000", -- Legendary
}

-- Function to get equipped item level for a specific slot
local function GetEquippedItemLevel(slotId)
    local itemLink = GetInventoryItemLink("player", slotId)
    if itemLink then
        local _, _, _, itemLevel = GetItemInfo(itemLink)
        return itemLevel or 0
    end
    return 0
end

-- Function to compare inventory items with equipped items and print upgrades
local function CompareInventoryToEquipped()
    local printedItems = {} -- Table to keep track of printed items
    for bag = 0, 4 do  -- Loop through the bags (0 to 4)
        local slots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, slots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName, _, itemRarity, itemLevel, _, _, _, _, equipSlot = GetItemInfo(itemLink)
                local inventorySlotId = slotNames[equipSlot]

                if inventorySlotId then
                    local equippedItemLevel = GetEquippedItemLevel(inventorySlotId)

                    -- If the inventory item has a higher item level than the equipped one and hasn't been printed yet
                    if itemLevel > equippedItemLevel and not printedItems[itemLink] then
                        local rarityColor = rarityColors[itemRarity] or "|cffffffff" -- Default to white if rarity not found
                        local readableSlotName = readableSlotNames[inventorySlotId] or equipSlot
                        print(string.format("%sUpgrade found: %s%s (Item Level: %d) in Bag %d, Slot %d is better than equipped %s", 
                            rarityColor, itemName, "|r", itemLevel, bag, slot, readableSlotName))
                        
                        -- Mark this item as printed
                        printedItems[itemLink] = true
                    end
                end
            end
        end
    end
end

-- Register event to compare items when the player logs in or reloads the UI
local frame = CreateFrame("Frame")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", CompareInventoryToEquipped)
