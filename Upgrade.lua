-- Mapping item types to the slot they are in on the character window
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

-- Make the slot numbers readable
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

-- Rarity color codes so it's pretty when it prints
local rarityColors = {
    [1] = "|cffffffff", -- Common
    [2] = "|cff1eff00", -- Uncommon
    [3] = "|cff0070dd", -- Rare
    [4] = "|cffa335ee", -- Epic
    [5] = "|cffff8000", -- Legendary
}

-- Here we check the item level of the players equipped items, if nothing is equipped, it's 0
local function GetEquippedItemLevel(slotId) -- defining the function, in this case GetEquippedItemLevel with the parameter slotID, which represents the slot ID of the item we are checking eg. Head, Neck
    local itemLink = GetInventoryItemLink("player", slotId) --gets the item link for an item in a specified slot, its checking player, then slot ID and returns a link to the item equipped 
    if itemLink then -- this checks to see if an item link was succesfully obtained
        local _, _, _, itemLevel = GetItemInfo(itemLink) -- gets detailed info from the item link, the underscores are values we aren't using for comparing upgrades like item name and rarity, but item level is returned as its named specifically
        return itemLevel or 0 -- this returns the item level if there is an item equipped, if there isn't it defaults to 0
    end
    return 0 -- if no item link is found and the function returns 0, there is no item equipped
end

-- Check if an item is Armor and if that armor is plate 
local function IsPlateArmor(itemLink) -- defines a local function IsPlateArmor that checks the item link 
    local _, _, _, _, _, itemType, itemSubType = GetItemInfo(itemLink) -- as with the other function, we're check GetItemInfo for item type and item subtype, the underscore are data we aren't looking at
    return itemType == "Armor" and itemSubType == "Plate" -- here we're looking specifically for item type armor and even more specifically for plate armor, we only want to check items have both parameters returned true 
end

-- This part gathers information from the inventory and identifies where it would go if it is equipped eg. itemslot 
local function CompareInventoryToEquipped() -- defines a local function that we will use to compare equipped items to inventory items 
    local printedItems = {} -- creates an empty table to keep track of which items are already printed to prevent them from printing multiple times
    for bag = 0, 4 do  -- looks at the items in the players bags 0 backpack through 4 additional bags 
        local numSlots = C_Container.GetContainerNumSlots(bag) -- the funtion c_container.GetContainerNumSlots(bag) retrives the number of slots in the current (bag), numSlots will return the number of slots 
        for slot = 1, numSlots do -- this looks at all the slots in a bag, from slot 1 to what is returned by numSlots
            local itemLink = C_Container.GetContainerItemLink(bag, slot) -- this gets the itemLink to whatever item is in a given bag and slot combination, determined by the last two lines 
            if itemLink then -- this is checking if there is an item there or not 
                local itemName, _, itemRarity, itemLevel, _, _, itemSubType, _, equipSlot = GetItemInfo(itemLink) -- if an item exists it uses GetItemInfo to get the specified data, as before underscores are data we aren't looking at 
                local inventorySlotId = slotNames[equipSlot] -- this looks up the inventory slot based on the equipslot value using the slotnames table, eg. if equipslot is INVTYPE_HEAD, inventory slot would be 1

                -- Check if an item is Plate, a valid two-handed weapon, or accessories, results are stored in the variables listed 
                local isPlate = IsPlateArmor(itemLink) -- this variable calls the previous function we made to check if something is plate 
                local validTwoHanded = equipSlot == "INVTYPE_2HWEAPON" and (itemSubType == "Two-Handed Swords" or itemSubType == "Two-Handed Maces" or itemSubType == "Two-Handed Axes" or itemSubType == "Polearms") -- here we're looking for specific 2hand weapons only, so we defining it by some of the itemSubTypes, they have to be a two handed weapon AND one of the other subtypes
                local validNeck = equipSlot == "INVTYPE_NECK" -- same thing but with neck items
                local validFinger = equipSlot == "INVTYPE_FINGER" -- again same with rings
                local validTrinket = equipSlot == "INVTYPE_TRINKET" -- and the same with trinkets

                -- Now that we defined what we're looking for, we check to see if inventory items we looked at are valid and then compares them to equipped items
                if (isPlate or validTwoHanded or validNeck or validFinger or validTrinket) then -- if the above definitions are true we continue, if false, its skipped
                    local equippedItemLevel = GetEquippedItemLevel(inventorySlotId or (validTwoHanded and 16 or (validNeck and 2 or (validFinger and 11 or (validTrinket and 13 or nil))))) -- For 2hand weapons, we checking slot ID 16; for other types, use the correct slot ID 
						-- here the variable equippedItemLevel stores the item level of the currently equipped item in the slot listed in the arguement, GetEquippedItemLevel is the function we made above, the arguement is checking the "valid" items from inventory against the inventory slot id
					
                    -- Here is where we determine if something is an upgrade, check the rarity and name and formats the print message
                    if itemLevel > equippedItemLevel then -- this is the comparison of the item level of the inventory item to the one currently equipped
                        local rarityColor = rarityColors[itemRarity] or "|cffffffff" -- this calls the rarity color so the printed message is pretty, no rarity is found, it'll just be white
                        local readableSlotName = readableSlotNames[inventorySlotId] or equipSlot -- this looks up the readable slot name so that it doesn't just say invslot_head or something 
                        print(string.format("%sUpgrade found: %s%s (Item Level: %d) in Bag %d, Slot %d is better than equipped %s",  -- this is the formatting for the printed message
                            rarityColor, itemName, "|r", itemLevel, bag, slot, readableSlotName)) 
                                                
                    end
                end
            end
        end
    end
end
-- Here we are making a button to press to print if there is an upgrade, originally it just printed whenever there was a change in the players inventory, but that was really messy.
-- Make the button 
local button = CreateFrame("Button", "UpgradeButton", Minimap) -- creates a variable and then defines it, createframe is making the ui element and then we've defined it as a buton, gave it a name, and parents it to the minimap 
button:SetSize(24, 24) -- Size of the button in pixels
button:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -10, -10) -- Position the button around the Minimap

-- what the button looks like 
button:SetNormalTexture("Interface\\Icons\\UI_AllianceIcon-round") -- sets the image that will display where the button is 
button:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9) -- this crops the image and zooms in slightly to remove edges, found this online, gonna play with it later to see if I actually need it
button:GetNormalTexture():SetSize(24, 24) -- this sets the image to the same size as the button 

-- make the button work on click 
button:SetScript("OnClick", function() -- defines the script that will run when the button is clicked
    CompareInventoryToEquipped() -- this is the function that is called when the button is clicked, comparing the inventory items to the equipped items, which is the function we made above.
end)
