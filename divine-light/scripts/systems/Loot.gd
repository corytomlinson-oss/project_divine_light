class_name Loot
extends RefCounted

# What treasure chests hold (Milestone 23a). Each Act I dungeon keeps its
# captive's armor set in gilded chests - the design doc has set pieces come
# from dungeon chests and shops, never random drops. Plain chests roll from
# TABLE. Rolls use the dungeon's own RNG (DungeonGenerator.place_chests), so a
# chest holds the same thing every time the dungeon is generated.

const DUNGEON_SETS := {
	"cathedral": ["Guardian Plate", "Guardian Helm", "Guardian Gauntlets", "Guardian Emblem"],
	"monastery": ["Iron Monk Gi", "Iron Monk Headband", "Iron Knuckles", "Iron Monk Beads"],
	"observatory": ["Arcane Robe", "Scholar's Circlet", "Scholar's Gloves", "Arcane Focus"],
	"guild": ["Shadow Walker Garb", "Shadow Cowl", "Shadow Grips", "Shadow Sigil"],
	# Act II (25b): each dungeon holds one kind of piece from all four sets.
	"frozen_citadel": ["Sacred Aegis Plate", "Storm Dragon Gi", "Elemental Weave Robe", "Venom Weave Garb"],
	"sunken_sanctum": ["Sacred Aegis Helm", "Storm Dragon Band", "Elemental Weave Hood", "Venom Weave Mask"],
	"drowned_fortress": ["Sacred Aegis Gauntlets", "Storm Dragon Fists", "Elemental Weave Gloves", "Venom Weave Wraps"],
}

# Plain chests: a weighted pick of an item (count = [min, max]) or gold.
const TABLE: Array = [
	{"weight": 30, "item": "Potion", "count": [1, 2]},
	{"weight": 14, "item": "Antidote", "count": [1, 2]},
	{"weight": 14, "item": "Ether", "count": [1, 1]},
	{"weight": 6, "item": "Elixir", "count": [1, 1]},
	{"weight": 28, "gold": [30, 90]},
	{"weight": 4, "item": "Traveler's Ring", "count": [1, 1]},
	{"weight": 4, "item": "Amber Charm", "count": [1, 1]},
]

# Side-room vaults, locked chests and mimics (23b): the best finds.
const RICH_TABLE: Array = [
	{"weight": 25, "item": "Elixir", "count": [1, 2]},
	{"weight": 20, "item": "Ether", "count": [2, 3]},
	{"weight": 30, "gold": [120, 240]},
	{"weight": 5, "item": "Potion", "count": [4, 5]},
	{"weight": 10, "item": "Traveler's Ring", "count": [1, 1]},
	{"weight": 10, "item": "Amber Charm", "count": [1, 1]},
]

const MAX_STACK := 99


## A chest's contents from `table`: {"item", "count"} or {"gold"}.
static func roll(rng: RandomNumberGenerator, table: Array = TABLE) -> Dictionary:
	var total := 0
	for entry: Dictionary in table:
		total += int(entry["weight"])
	var pick := rng.randi_range(1, total)
	for entry: Dictionary in table:
		pick -= int(entry["weight"])
		if pick > 0:
			continue
		if entry.has("gold"):
			return {"gold": rng.randi_range(entry["gold"][0], entry["gold"][1])}
		return {"item": entry["item"], "count": rng.randi_range(entry["count"][0], entry["count"][1])}
	return {"gold": 50}


## Adds a reward to the party's gold/inventory; returns the line to show.
static func give(reward: Dictionary) -> String:
	if reward.has("gold"):
		GameManager.gold += int(reward["gold"])
		return "Found %d gold!" % int(reward["gold"])
	var item: String = reward["item"]
	var count := int(reward.get("count", 1))
	GameManager.inventory[item] = mini(MAX_STACK, int(GameManager.inventory.get(item, 0)) + count)
	if count > 1:
		return "Found %s x%d!" % [item, count]
	var set_id: String = Equipment.DEFS.get(item, {}).get("set_id", "")
	if set_id != "":
		return "Found %s! A piece of the %s." % [item, Equipment.SET_BONUSES[set_id]["name"]]
	return "Found %s!" % item
