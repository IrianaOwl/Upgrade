-- classGear.lua
-- Define the gear types each class can wear for each specialization

ClassGearTypes = {
    WARRIOR = {
        -- Arms Warrior (Specialization 1)
        [1] = {
			"Plate", "Two-Handed Axes", "Two-Handed Swords", "Two-Handed Maces", "Neck", "Finger",  "Trinket", "Back",
			exclusions = {
				["Shields"] = true
			},
		},
        -- Fury Warrior (Specialization 2)
        [2] = {
			"Plate", "Two-Handed Axes", "Two-Handed Swords", "Two-Handed Maces", "Neck", "Finger",  "Trinket", "Back",
			exclusions = {
				["Shields"] = true
			},
		},
        -- Protection Warrior (Specialization 3)
        [3] = {"Plate", "One-Handed Swords", "One-Handed Maces", "One-Handed Axes", "Shields", "Neck", "Finger",  "Trinket", "Back"}
    },
    PALADIN = {
        -- Holy Paladin (Specialization 1)
        [1] = {"Plate", "One-Handed Swords", "One-Handed Maces", "Off-hand", "Shields", "Neck", "Finger",  "Trinket", "Back"},
        -- Protection Paladin (Specialization 2)
        [2] = {"Plate", "One-Handed Swords", "One-Handed Maces", "One-Handed Axes", "Shields", "Neck", "Finger",  "Trinket", "Back"},
        -- Retribution Paladin (Specialization 3)
        [3] = {
			"Plate", "Two-Handed Axes", "Two-Handed Swords", "Two-Handed Maces", "Neck", "Finger",  "Trinket", "Back",
			exclusions = {
				["Shields"] = true
			},
		},			
    },
    DEATHKNIGHT = {
        -- Blood Death Knight (Specialization 1)
        [1] = {"Plate", "Two-Handed Swords", "Two-Handed Maces", "Two-Handed Swords", "Neck", "Finger",  "Trinket", "Back"},
        -- Frost Death Knight (Specialization 2)
        [2] = {"Plate", "One-Handed Axes", "One-Handed Swords", "One-Handed Maces", "Neck", "Finger",  "Trinket", "Back"},
        -- Unholy Death Knight (Specialization 3)
        [3] = {"Plate", "Two-Handed Axes", "Two-Handed Maces", "Two-Handed Swords", "Neck", "Finger",  "Trinket", "Back"}
    },
    HUNTER = {
        -- Beast Mastery Hunter (Specialization 1)
        [1] = {"Mail", "Bows", "Crossbows", "Guns", "Neck", "Finger",  "Trinket", "Back"},
        -- Marksmanship Hunter (Specialization 2)
        [2] = {"Mail", "Bows", "Crossbows", "Guns", "Neck", "Finger",  "Trinket", "Back"},
        -- Survival Hunter (Specialization 3)
        [3] = {
			"Mail", "Staves", "Polearms", "Neck", "Finger",  "Trinket", "Back",
			exclusions = {
				["Bows"] = true,
				["Crossbows"] = true,
				["Guns"] = true,
			}
		}
    },
    SHAMAN = {
        -- Elemental Shaman (Specialization 1)
        [1] = {"Mail", "One-Handed Maces", "One-Handed Daggers", "Off-hand", "Shields", "Neck", "Finger",  "Trinket", "Back"},
        -- Enhancement Shaman (Specialization 2)
        [2] = {"Mail", "One-Handed Maces", "One-Handed Axes", "Fist Weapons", "Neck", "Finger",  "Trinket", "Back"},
        -- Restoration Shaman (Specialization 3)
        [3] = {"Mail", "One-Handed Maces", "One-Handed Daggers", "Off-hand", "Shields", "Neck", "Finger",  "Trinket", "Back"}
    },
    ROGUE = {
        -- Assassination Rogue (Specialization 1)
        [1] = {"Leather", "One-Handed Daggers", "Neck", "Finger",  "Trinket", "Back"},
        -- Outlaw Rogue (Specialization 2)
        [2] = {"Leather", "One-Handed Swords", "One-Handed Axes", "One-Handed Maces", "Fist Weapons", "Neck", "Finger",  "Trinket", "Back"},
        -- Subtlety Rogue (Specialization 3)
        [3] = {"Leather", "One-Handed Daggers", "Neck", "Finger",  "Trinket", "Back"}
    },
    DRUID = {
        -- Balance Druid (Specialization 1)
        [1] = {"Leather", "Staves", "Polearms", "One-Handed Maces", "One-Handed Daggers", "Off-hand", "Neck", "Finger",  "Trinket", "Back"},
        -- Feral Druid (Specialization 2)
        [2] = {"Leather", "Staves", "Polearms", "Neck", "Finger",  "Trinket", "Back"},
        -- Guardian Druid (Specialization 3)
        [3] = {"Leather", "Staves", "Polearms", "Neck", "Finger",  "Trinket", "Back"},
        -- Restoration Druid (Specialization 4)
        [4] = {"Leather", "Staves", "One-Handed Maces", "One-Handed Daggers", "Off-hand", "Neck", "Finger",  "Trinket", "Back"}
    },
    MONK = {
        -- Brewmaster Monk (Specialization 1)
        [1] = {"Leather", "Staves", "Polearms", "Neck", "Finger",  "Trinket", "Back"},
        -- Windwalker Monk (Specialization 2)
        [2] = {"Leather", "One-Handed Maces", "One-Handed Swords", "One-Handed Axes", "Fist Weapons", "Neck", "Finger",  "Trinket", "Back"},
        -- Mistweaver Monk (Specialization 3)
        [3] = {"Leather", "One-Handed Maces", "Staves", "One-Handed Swords", "Neck", "Finger",  "Trinket", "Back"}
    },
    DEMONHUNTER = {
        -- Havoc Demon Hunter (Specialization 1)
        [1] = {"Leather", "One-Handed Swords", "Fist Weapons", "One-Handed Axes", "Warglaives", "Neck", "Finger",  "Trinket", "Back"},
        -- Vengeance Demon Hunter (Specialization 2)
        [2] = {"Leather", "One-Handed Swords", "Fist Weapons", "One-Handed Axes", "Warglaives", "Neck", "Finger",  "Trinket", "Back"}
    },
    PRIEST = {
        -- Holy Priest (Specialization 1)
        [1] = {"Cloth", "One-Handed Maces", "Staves", "One-Handed Daggers", "Wands", "Off-hand", "Neck", "Finger",  "Trinket", "Back"},
        -- Discipline Priest (Specialization 2)
        [2] = {"Cloth", "One-Handed Maces", "Staves", "One-Handed Daggers", "Wands", "Off-hand", "Neck", "Finger",  "Trinket", "Back"},
        -- Shadow Priest (Specialization 3)
        [3] = {"Cloth", "One-Handed Maces", "Staves", "One-Handed Daggers", "Wands", "Off-hand", "Neck", "Finger",  "Trinket", "Back"}
    },
    MAGE = {
        -- Arcane Mage (Specialization 1)
        [1] = {"Cloth", "One-Handed Sword", "Staves", "One-Handed Daggers", "Off-hand", "Wands", "Neck", "Finger",  "Trinket", "Back"},
        -- Fire Mage (Specialization 2)
        [2] = {"Cloth", "One-Handed Sword", "Staves", "One-Handed Daggers", "Off-hand", "Wands", "Neck", "Finger",  "Trinket", "Back"},
        -- Frost Mage (Specialization 3)
        [3] = {"Cloth", "One-Handed Sword", "Staves", "One-Handed Daggers", "Off-hand", "Wands", "Neck", "Finger",  "Trinket", "Back"}
    },
    WARLOCK = {
        -- Affliction Warlock (Specialization 1)
        [1] = {"Cloth", "One-Handed Sword", "Staves", "One-Handed Daggers", "Off-hand", "Wands", "Neck", "Finger",  "Trinket", "Back"},
        -- Demonology Warlock (Specialization 2)
        [2] = {"Cloth", "One-Handed Sword", "Staves", "One-Handed Daggers", "Off-hand", "Wands", "Neck", "Finger",  "Trinket", "Back"},
        -- Destruction Warlock (Specialization 3)
        [3] = {"Cloth", "One-Handed Sword", "Staves", "One-Handed Daggers", "Off-hand", "Wands", "Neck", "Finger",  "Trinket", "Back"}
    },
    EVOKER = {
        -- Devastation Evoker (Specialization 1)
        [1] = {"Mail", "One-Handed Maces", "Staves", "One-Handed Swords", "One-Handed Daggers", "Off-hand", "Neck", "Finger",  "Trinket", "Back"},
        -- Preservation Evoker (Specialization 2)
        [2] = {"Mail", "One-Handed Maces", "Staves", "One-Handed Swords", "One-Handed Daggers", "Off-hand", "Neck", "Finger",  "Trinket", "Back"}
    }
}

return ClassGearTypes
