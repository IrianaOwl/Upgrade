-- classGear.lua
-- Define the gear types each class can wear

ClassGearTypes = {
    -- Strength-based Plate classes
    WARRIOR = {"Plate", "Two-Handed Axes", "Two-Handed Swords", "Two-Handed Maces", "One-Handed Axes", "One-Handed Swords", "Shields", "Finger", "Trinket", "Back"},
    PALADIN = {"Plate", "Two-Handed Axes", "Two-Handed Swords", "Two-Handed Maces", "One-Handed Axes", "One-Handed Swords", "Shields", "Finger", "Trinket", "Back"},
    DEATHKNIGHT = {"Plate", "Two-Handed Axes", "Two-Handed Swords", "One-Handed Axes", "One-Handed Swords", "Finger", "Trinket", "Back"},

    -- Agility-based Mail classes
    HUNTER = {"Mail", "Bows", "Guns", "Crossbows", "Finger", "Trinket", "Back"},
    SHAMAN = {"Mail", "One-Handed Axes", "One-Handed Maces", "Staves", "Shields", "Finger", "Trinket", "Back"},

    -- Agility-based Leather classes
    ROGUE = {"Leather", "One-Handed Swords", "One-Handed Daggers", "Fist Weapons", "Finger", "Trinket", "Back"},
    DRUID = {"Leather", "Staves", "Fist Weapons", "One-Handed Maces", "Finger", "Trinket", "Back"},

    -- Agility-based Leather or Cloth (for Feral/Guardian/Boomkin) or Intellect-based Cloth (for Healing/Casting)
    MONK = {"Leather", "One-Handed Swords", "Fist Weapons", "Staves", "Finger", "Trinket", "Back"},
    DEMONHUNTER = {"Leather", "One-Handed Swords", "Fist Weapons", "Finger", "Trinket", "Back"},

    -- Intellect-based Cloth classes
    PRIEST = {"Cloth", "Staves", "One-Handed Maces", "Finger", "Trinket", "Back"},
    MAGE = {"Cloth", "Staves", "One-Handed Daggers", "Finger", "Trinket", "Back"},
    WARLOCK = {"Cloth", "Staves", "One-Handed Daggers", "Finger", "Trinket", "Back"},

    -- Intellect-based Mail (for Elemental/Healing) and Agility-based Mail (for Enhancement)
    EVOKER = {"Mail", "Staves", "One-Handed Maces", "Finger", "Trinket", "Back"},

    -- Classes not using Plate/Mail/Leather/Cloth (future expansions)
    -- Add any other new or upcoming classes here if needed
}

-- You may add more exclusions or specific handling for weapons, shields, etc.
