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
    ["INVTYPE_2HWEAPON"] = 16, -- Two-Handed uses the Main Hand slot
    ["INVTYPE_WEAPONMAINHAND"] = nil, -- Exclude Main Hand weapons
    ["INVTYPE_WEAPONOFFHAND"] = nil, -- Exclude Off Hand weapons
    ["INVTYPE_HOLDABLE"] = nil, -- Exclude Held in Off Hand
    ["INVTYPE_RANGED"] = nil, -- Exclude Ranged
    ["INVTYPE_THROWN"] = nil, -- Exclude Thrown
    ["INVTYPE_RANGEDRIGHT"] = nil, -- Exclude Right Ranged (guns, bows)
    ["INVTYPE_TABARD"] = nil, -- Exclude Tabard
}

-- Define the slot names
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
    [16] = "Two-Handed Weapon",
}

-- Rarity color codes so it's pretty
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

-- Function to check if an item is Plate armor
local function IsPlateArmor(itemLink)
    local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemLink)
    return itemType == "Armor" and itemSubType == "Plate"
end

-- Function to compare inventory items with equipped items and print upgrades
local function CompareInventoryToEquipped()
    local printedItems = {} -- Table to keep track of printed items
    for bag = 0, 4 do  -- Loop through the bags (0 to 4)
        local numSlots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemLink = C_Container.GetContainerItemLink(bag, slot)
            if itemLink then
                local itemName, _, itemRarity, itemLevel, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink)
                local inventorySlotId = slotNames[equipSlot]

                -- Check if item is Plate armor, a valid two-handed weapon, or other types
                local isPlate = IsPlateArmor(itemLink)
                local validTwoHanded = equipSlot == "INVTYPE_2HWEAPON" and (itemSubType == "Two-Handed Swords" or itemSubType == "Two-Handed Maces" or itemSubType == "Two-Handed Axes" or itemSubType == "Polearms")
                local validNeck = equipSlot == "INVTYPE_NECK"
                local validFinger = equipSlot == "INVTYPE_FINGER"
                local validTrinket = equipSlot == "INVTYPE_TRINKET"

                -- Only process if item is Plate armor, valid two-handed weapon, neck, finger, or trinket
                if (isPlate or validTwoHanded or validNeck or validFinger or validTrinket) then
                    -- For valid two-handed weapons, use slot ID 16; for other types, use the correct slot ID
                    local equippedItemLevel = GetEquippedItemLevel(inventorySlotId or (validTwoHanded and 16 or (validNeck and 2 or (validFinger and 11 or (validTrinket and 13 or nil)))))

                    -- If the inventory item has a higher item level than the equipped one and hasn't been printed yet
                    if itemLevel > equippedItemLevel and not printedItems[itemLink] then
                        local rarityColor = rarityColors[itemRarity] or "|cffffffff" -- Default to white if rarity not found
                        local readableSlotName = readableSlotNames[inventorySlotId] or equipSlot
                        print(string.format("%sUpgrade found: %s%s (Item Level: %d) in Bag %d, Slot %d is better than equipped %s", 
                            rarityColor, itemName, "|r", itemLevel, bag, slot, readableSlotName))
                        
                        -- Mark this item as printed using itemLink
                        printedItems[itemLink] = true
                    end
                end
            end
        end
    end
end

-- Create a frame for the minimap button
local button = CreateFrame("Button", "UpgradeButton", Minimap)
button:SetSize(24, 24) -- Size of the button
button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10) -- Position the button

-- Set up the button appearance
button:SetNormalTexture("Interface\\Icons\\UI_AllianceIcon-round")
button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
button:GetNormalTexture():SetSize(24, 24)



-- Set button functionality
button:SetScript("OnClick", function()
    CompareInventoryToEquipped()
end)

-- Register event to compare items when the bags are updated
local frame = CreateFrame("Frame")
frame:RegisterEvent("BAG_UPDATE")
frame:SetScript("OnEvent", function() end) -- Disable automatic printing on bag update
