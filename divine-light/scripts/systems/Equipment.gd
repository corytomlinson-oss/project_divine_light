class_name Equipment
extends RefCounted

# Milestone 15. Pure logic (no scene dependencies, only the GameManager
# autoload for inventory), so it's testable headlessly. Stat bonuses are
# applied by directly adding/subtracting from the Combatant's own stat
# fields on equip/unequip - deliberately not a separate "equipment bonus"
# layer, since that would mean touching every one of the ~40 existing combat
# formula call sites to add it in. Direct mutation means every existing
# formula already picks up gear for free, the same way it already picks up
# level-up gains.

const SLOTS: Array = ["weapon", "armor", "helmet", "gloves", "accessory"]

# item name -> {slot, class ("" = universal, only ever true for accessories
# per the design doc), stat keys (atk/def/int/res/agi/hp/mp), set_id (optional)}
const DEFS: Dictionary = {
	# Vael (Templar)
	"Iron Sword":         {"slot": "weapon",    "class": "Vael", "atk": 8},
	"Steel Sword":        {"slot": "weapon",    "class": "Vael", "atk": 13},  # Edenmere's armory (20d)
	"Guardian Plate":     {"slot": "armor",     "class": "Vael", "def": 6, "set_id": "holy_guardian"},
	"Guardian Helm":      {"slot": "helmet",    "class": "Vael", "def": 3, "set_id": "holy_guardian"},
	"Guardian Gauntlets": {"slot": "gloves",    "class": "Vael", "def": 3, "set_id": "holy_guardian"},
	"Guardian Emblem":    {"slot": "accessory", "class": "",     "res": 3, "set_id": "holy_guardian"},

	# Ryn (Martial Artist)
	"Iron Claws": {"slot": "weapon", "class": "Ryn", "atk": 6},
	"Steel Claws": {"slot": "weapon", "class": "Ryn", "atk": 11},
	"Monk Wraps": {"slot": "armor",  "class": "Ryn", "def": 3},
	"Iron Monk Gi":       {"slot": "armor",     "class": "Ryn", "def": 4, "atk": 2, "set_id": "iron_monk"},
	"Iron Monk Headband": {"slot": "helmet",    "class": "Ryn", "def": 2, "agi": 1, "set_id": "iron_monk"},
	"Iron Knuckles":      {"slot": "gloves",    "class": "Ryn", "atk": 3, "set_id": "iron_monk"},
	"Iron Monk Beads":    {"slot": "accessory", "class": "",    "hp": 20, "set_id": "iron_monk"},

	# Lyra (Invoker)
	"Apprentice Staff": {"slot": "weapon", "class": "Lyra", "atk": 3, "int": 5},
	"Oak Staff":        {"slot": "weapon", "class": "Lyra", "atk": 4, "int": 9},
	"Scholar's Robe":   {"slot": "armor",  "class": "Lyra", "res": 3},
	"Arcane Robe":      {"slot": "armor",     "class": "Lyra", "def": 2, "res": 4, "set_id": "arcane_scholar"},
	"Scholar's Circlet": {"slot": "helmet",   "class": "Lyra", "int": 3, "set_id": "arcane_scholar"},
	"Scholar's Gloves": {"slot": "gloves",    "class": "Lyra", "int": 2, "def": 1, "set_id": "arcane_scholar"},
	"Arcane Focus":     {"slot": "accessory", "class": "",     "mp": 15, "set_id": "arcane_scholar"},

	# Silas (Assassin)
	"Twin Daggers": {"slot": "weapon", "class": "Silas", "atk": 7},
	"Steel Daggers": {"slot": "weapon", "class": "Silas", "atk": 12},
	"Leather Hood": {"slot": "helmet", "class": "Silas", "agi": 3},
	"Shadow Walker Garb": {"slot": "armor",     "class": "Silas", "def": 3, "agi": 2, "set_id": "shadow_walker"},
	"Shadow Cowl":        {"slot": "helmet",    "class": "Silas", "agi": 3, "set_id": "shadow_walker"},
	"Shadow Grips":       {"slot": "gloves",    "class": "Silas", "atk": 3, "set_id": "shadow_walker"},
	"Shadow Sigil":       {"slot": "accessory", "class": "",      "agi": 2, "set_id": "shadow_walker"},

	# Act II's first tier (25b): freed Nordveil's armory, a step up from
	# Edenmere's steel.
	"Frostforged Sword":   {"slot": "weapon", "class": "Vael",  "atk": 19},
	"Frostforged Claws":   {"slot": "weapon", "class": "Ryn",   "atk": 17},
	"Frostforged Staff":   {"slot": "weapon", "class": "Lyra",  "atk": 6, "int": 14},
	"Frostforged Daggers": {"slot": "weapon", "class": "Silas", "atk": 18},
	"Knight's Mail":       {"slot": "armor",  "class": "Vael",  "def": 8},
	"Furred Gi":           {"slot": "armor",  "class": "Ryn",   "def": 5, "agi": 1},
	"Frostweave Robe":     {"slot": "armor",  "class": "Lyra",  "def": 2, "res": 6},
	"Snowfox Leathers":    {"slot": "armor",  "class": "Silas", "def": 4, "agi": 3},
	"Hearthstone Charm":   {"slot": "accessory", "class": "", "res": 5, "hp": 25},
	# Act II's second tier (25c): freed Duskara's armory.
	"Sunsteel Sword":      {"slot": "weapon", "class": "Vael",  "atk": 25},
	"Sunsteel Claws":      {"slot": "weapon", "class": "Ryn",   "atk": 23},
	"Sunsteel Staff":      {"slot": "weapon", "class": "Lyra",  "atk": 8, "int": 19},
	"Sunsteel Daggers":    {"slot": "weapon", "class": "Silas", "atk": 24},
	"Desert Mail":         {"slot": "armor",  "class": "Vael",  "def": 11},
	"Sandwalker Gi":       {"slot": "armor",  "class": "Ryn",   "def": 7, "agi": 2},
	"Mirage Robe":         {"slot": "armor",  "class": "Lyra",  "def": 3, "res": 9},
	"Dune Leathers":       {"slot": "armor",  "class": "Silas", "def": 6, "agi": 4},
	"Oasis Charm":         {"slot": "accessory", "class": "", "res": 6, "hp": 40},
	# Act II's third tier (25d): freed Selavon's armory.
	"Stormsilver Sword":   {"slot": "weapon", "class": "Vael",  "atk": 31},
	"Stormsilver Claws":   {"slot": "weapon", "class": "Ryn",   "atk": 29},
	"Stormsilver Staff":   {"slot": "weapon", "class": "Lyra",  "atk": 10, "int": 24},
	"Stormsilver Daggers": {"slot": "weapon", "class": "Silas", "atk": 30},
	"Tideguard Plate":     {"slot": "armor",  "class": "Vael",  "def": 14},
	"Seafoam Gi":          {"slot": "armor",  "class": "Ryn",   "def": 9, "agi": 3},
	"Tidecaller Robe":     {"slot": "armor",  "class": "Lyra",  "def": 4, "res": 12},
	"Reefrunner Leathers": {"slot": "armor",  "class": "Silas", "def": 8, "agi": 5},
	"Tide Charm":          {"slot": "accessory", "class": "", "res": 8, "hp": 60},
	# Act III's tier (28a): the Threshold's forge.
	"Starforged Sword":    {"slot": "weapon", "class": "Vael",  "atk": 37},
	"Starforged Claws":    {"slot": "weapon", "class": "Ryn",   "atk": 35},
	"Starforged Staff":    {"slot": "weapon", "class": "Lyra",  "atk": 12, "int": 29},
	"Starforged Daggers":  {"slot": "weapon", "class": "Silas", "atk": 36},
	"Starforged Plate":    {"slot": "armor",  "class": "Vael",  "def": 17},
	"Starforged Gi":       {"slot": "armor",  "class": "Ryn",   "def": 11, "agi": 4},
	"Starforged Robe":     {"slot": "armor",  "class": "Lyra",  "def": 5, "res": 15},
	"Starforged Leathers": {"slot": "armor",  "class": "Silas", "def": 10, "agi": 6},
	"Star Charm":          {"slot": "accessory", "class": "", "res": 10, "hp": 80},
	# Act III side-quest rewards (29): each hero's best accessory.
	"Dawn Oath Medallion": {"slot": "accessory", "class": "Vael",  "res": 12, "def": 4, "hp": 100},
	"Grandmaster's Beads": {"slot": "accessory", "class": "Ryn",   "atk": 6, "agi": 4, "hp": 60},
	"Astral Lens":         {"slot": "accessory", "class": "Lyra",  "int": 8, "mp": 50},
	"Ghoststep Charm":     {"slot": "accessory", "class": "Silas", "agi": 7, "atk": 4},

	# Act II armor sets (25b; README "Full Set Bonus"). Spread across Act II
	# (Cory): the Frozen Citadel holds the four armors, Nordveil's armory sells
	# two accessories, the rest come in Duskara and Selavon.
	"Sacred Aegis Plate":     {"slot": "armor",     "class": "Vael",  "def": 10, "res": 2, "set_id": "sacred_aegis"},
	"Sacred Aegis Helm":      {"slot": "helmet",    "class": "Vael",  "def": 5, "res": 1, "set_id": "sacred_aegis"},
	"Sacred Aegis Gauntlets": {"slot": "gloves",    "class": "Vael",  "def": 4, "atk": 2, "set_id": "sacred_aegis"},
	"Aegis Sigil":            {"slot": "accessory", "class": "",      "res": 5, "hp": 30, "set_id": "sacred_aegis"},
	"Storm Dragon Gi":        {"slot": "armor",     "class": "Ryn",   "def": 7, "atk": 3, "set_id": "storm_dragon"},
	"Storm Dragon Band":      {"slot": "helmet",    "class": "Ryn",   "def": 3, "agi": 2, "set_id": "storm_dragon"},
	"Storm Dragon Fists":     {"slot": "gloves",    "class": "Ryn",   "atk": 5, "set_id": "storm_dragon"},
	"Dragon Pearl":           {"slot": "accessory", "class": "",      "hp": 40, "agi": 1, "set_id": "storm_dragon"},
	"Elemental Weave Robe":   {"slot": "armor",     "class": "Lyra",  "def": 4, "res": 7, "set_id": "elemental_weave"},
	"Elemental Weave Hood":   {"slot": "helmet",    "class": "Lyra",  "int": 5, "res": 2, "set_id": "elemental_weave"},
	"Elemental Weave Gloves": {"slot": "gloves",    "class": "Lyra",  "int": 4, "def": 2, "set_id": "elemental_weave"},
	"Prism Focus":            {"slot": "accessory", "class": "",      "mp": 30, "int": 2, "set_id": "elemental_weave"},
	"Venom Weave Garb":       {"slot": "armor",     "class": "Silas", "def": 6, "agi": 3, "set_id": "venom_weave"},
	"Venom Weave Mask":       {"slot": "helmet",    "class": "Silas", "agi": 4, "def": 1, "set_id": "venom_weave"},
	"Venom Weave Wraps":      {"slot": "gloves",    "class": "Silas", "atk": 5, "set_id": "venom_weave"},
	"Viper Fang Charm":       {"slot": "accessory", "class": "",      "agi": 3, "atk": 2, "set_id": "venom_weave"},

	# Act III armor sets (28b; README "Full Set Bonus"): armors, helmets and
	# accessories in the Blighted Maw (floors 2-4), gloves at the Threshold.
	"Divine Champion Plate":     {"slot": "armor",     "class": "Vael",  "def": 14, "res": 4, "set_id": "divine_champion"},
	"Divine Champion Helm":      {"slot": "helmet",    "class": "Vael",  "def": 7, "res": 2, "set_id": "divine_champion"},
	"Divine Champion Gauntlets": {"slot": "gloves",    "class": "Vael",  "def": 6, "atk": 3, "set_id": "divine_champion"},
	"Champion's Halo":           {"slot": "accessory", "class": "",      "res": 7, "hp": 60, "set_id": "divine_champion"},
	"Rising Force Gi":           {"slot": "armor",     "class": "Ryn",   "def": 10, "atk": 5, "set_id": "rising_force"},
	"Rising Force Band":         {"slot": "helmet",    "class": "Ryn",   "def": 5, "agi": 3, "set_id": "rising_force"},
	"Rising Force Fists":        {"slot": "gloves",    "class": "Ryn",   "atk": 7, "set_id": "rising_force"},
	"Phoenix Pearl":             {"slot": "accessory", "class": "",      "hp": 70, "agi": 2, "set_id": "rising_force"},
	"Cosmic Conduit Robe":       {"slot": "armor",     "class": "Lyra",  "def": 6, "res": 10, "set_id": "cosmic_conduit"},
	"Cosmic Conduit Crown":      {"slot": "helmet",    "class": "Lyra",  "int": 7, "res": 3, "set_id": "cosmic_conduit"},
	"Cosmic Conduit Gloves":     {"slot": "gloves",    "class": "Lyra",  "int": 6, "def": 3, "set_id": "cosmic_conduit"},
	"Starlight Focus":           {"slot": "accessory", "class": "",      "mp": 45, "int": 3, "set_id": "cosmic_conduit"},
	"Death's Hand Garb":         {"slot": "armor",     "class": "Silas", "def": 9, "agi": 4, "set_id": "deaths_hand"},
	"Death's Hand Mask":         {"slot": "helmet",    "class": "Silas", "agi": 6, "def": 2, "set_id": "deaths_hand"},
	"Death's Hand Wraps":        {"slot": "gloves",    "class": "Silas", "atk": 7, "set_id": "deaths_hand"},
	"Reaper's Sigil":            {"slot": "accessory", "class": "",      "agi": 4, "atk": 3, "set_id": "deaths_hand"},

	# Universal (any class - accessories have no class restriction per the design doc)
	"Traveler's Ring": {"slot": "accessory", "class": "", "agi": 2},
	"Amber Charm":     {"slot": "accessory", "class": "", "res": 3},
	# One in each of the overworld's hidden clearings (23c), nowhere else.
	"Heartwood Charm":   {"slot": "accessory", "class": "", "hp": 30, "def": 1},
	"Moonstone Pendant": {"slot": "accessory", "class": "", "mp": 20, "int": 2},
	"Fox-Eye Ring":      {"slot": "accessory", "class": "", "agi": 3, "atk": 1},
	# The Northern Tundra's hidden clearing (25b)
	"Snowdrop Charm":    {"slot": "accessory", "class": "", "res": 4, "hp": 40},
	# The Duskara Wastes' hidden clearing (25c)
	"Sunstone Ring":     {"slot": "accessory", "class": "", "atk": 3, "int": 3, "hp": 30},
	# The Selavon Coast's hidden clearing (25d)
	"Tidestone Ring":    {"slot": "accessory", "class": "", "res": 5, "agi": 3, "mp": 25},
}

# set_id -> data describing the bonus. Act I's four sets are all wired up
# (Milestone 23a; their pieces sit in the gilded chests of each class's
# dungeon - Loot.gd). Each bonus is checked where its mechanic lives in
# Battle.gd: _buff_duration() (Holy Guardian), the basic attack's Qi gain
# (Iron Monk), _confirm_skill() (Arcane Scholar), the "vanish" effect
# (Shadow Walker). Acts II/III add theirs the same way.
const SET_BONUSES: Dictionary = {
	"holy_guardian": {"name": "Holy Guardian Set", "buff_duration_bonus": 1},
	"iron_monk": {"name": "Iron Monk Set", "desc": "Basic attacks build +1 extra Qi"},
	"arcane_scholar": {"name": "Arcane Scholar Set", "desc": "Switching stance is a free action"},
	"shadow_walker": {"name": "Shadow Walker Set", "desc": "Vanish makes Silas untargetable for the round"},
	# Act II (25b)
	"sacred_aegis": {"name": "Sacred Aegis Set", "desc": "Divine Shield protects the whole party"},
	"storm_dragon": {"name": "Storm Dragon Set", "desc": "Ryn's healing restores 30% more"},
	"elemental_weave": {"name": "Elemental Weave Set", "desc": "Back-row Tremor deals full damage"},
	"venom_weave": {"name": "Venom Weave Set", "desc": "Silas's poison lasts 5 rounds"},
	# Act III (28b)
	"divine_champion": {"name": "Divine Champion Set", "desc": "Resurrection revives at full HP"},
	"rising_force": {"name": "Rising Force Set", "desc": "Rising Dragon costs 4 Qi instead of 6"},
	"cosmic_conduit": {"name": "Cosmic Conduit Set", "desc": "Lyra's spells cost 25% less MP"},
	"deaths_hand": {"name": "Death's Hand Set", "desc": "Shadowstep deals 30% more damage"},
}


static func can_equip(member: Combatant, item_name: String) -> bool:
	var def: Dictionary = DEFS.get(item_name, {})
	if def.is_empty():
		return false
	var required_class: String = def.get("class", "")
	return required_class == "" or required_class == member.char_class


static func equip(member: Combatant, item_name: String) -> bool:
	if not can_equip(member, item_name):
		return false
	if int(GameManager.inventory.get(item_name, 0)) <= 0:
		return false

	var def: Dictionary = DEFS[item_name]
	var slot: String = def["slot"]
	unequip(member, slot)

	GameManager.inventory[item_name] = int(GameManager.inventory[item_name]) - 1
	if GameManager.inventory[item_name] <= 0:
		GameManager.inventory.erase(item_name)

	_apply_stats(member, def, 1)
	member.equipment[slot] = item_name
	member.hp = mini(member.hp, member.max_hp)
	member.mp = mini(member.mp, member.max_mp)
	update_mastery(member)
	return true


static func unequip(member: Combatant, slot: String) -> void:
	var item_name: String = member.equipment.get(slot, "")
	if item_name == "":
		return
	_apply_stats(member, DEFS.get(item_name, {}), -1)
	member.equipment[slot] = ""
	GameManager.inventory[item_name] = int(GameManager.inventory.get(item_name, 0)) + 1
	member.hp = mini(member.hp, member.max_hp)
	member.mp = mini(member.mp, member.max_mp)


static func _apply_stats(member: Combatant, def: Dictionary, sign: int) -> void:
	member.atk += sign * int(def.get("atk", 0))
	member.defense += sign * int(def.get("def", 0))
	member.int_stat += sign * int(def.get("int", 0))
	member.res_stat += sign * int(def.get("res", 0))
	member.agi += sign * int(def.get("agi", 0))
	member.max_hp += sign * int(def.get("hp", 0))
	member.max_mp += sign * int(def.get("mp", 0))


## True only when every one of armor/helmet/gloves/accessory is equipped and
## shares this set_id. Weapons are deliberately excluded - "Weapons upgrade
## independently and are not part of sets" per the design doc.
## All four pieces of the set worn right now (decides the hero's look).
static func wears_full_set(member: Combatant, set_id: String) -> bool:
	for slot in ["armor", "helmet", "gloves", "accessory"]:
		var item_name: String = member.equipment.get(slot, "")
		if item_name == "" or DEFS.get(item_name, {}).get("set_id", "") != set_id:
			return false
	return true


## Whether the set's bonus applies. Completing a set masters its bonus for
## good (Cory, 2026-10-25: "the set bonuses stack"), so a hero keeps every
## bonus they've ever completed, whatever they wear now.
static func has_set_bonus(member: Combatant, set_id: String) -> bool:
	if member == null:
		return false
	if set_id in member.mastered_sets:
		return true
	if wears_full_set(member, set_id):
		member.mastered_sets.append(set_id)
		return true
	return false


## Records any set this member is wearing complete (after equipping, loading).
static func update_mastery(member: Combatant) -> void:
	for set_id: String in SET_BONUSES:
		if wears_full_set(member, set_id) and not set_id in member.mastered_sets:
			member.mastered_sets.append(set_id)


# ---------------------------------------------------------------- describing gear
# What a piece does, in words (2026-10-25, Cory: "there isn't like a tool tip
# for the equipment"). Used by the equip screen and the shops.
const STAT_LABELS := [["atk", "ATK"], ["def", "DEF"], ["int", "INT"], ["res", "RES"], ["agi", "AGI"], ["hp", "HP"], ["mp", "MP"]]


## "ATK +6, HP +40" (every stat the item gives).
static func stat_text(item_name: String) -> String:
	var def: Dictionary = DEFS.get(item_name, {})
	var parts: Array = []
	for pair: Array in STAT_LABELS:
		if int(def.get(pair[0], 0)) != 0:
			parts.append("%s %+d" % [pair[1], int(def[pair[0]])])
	return ", ".join(parts) if not parts.is_empty() else "no stats"


## "Armor - DEF +10, RES +2 (Vael only)".
static func describe(item_name: String) -> String:
	var def: Dictionary = DEFS.get(item_name, {})
	if def.is_empty():
		return ""
	var who: String = def.get("class", "")
	return "%s - %s%s" % [String(def.get("slot", "")).capitalize(), stat_text(item_name), (" (%s only)" % who) if who != "" else ""]


## How this member's stats would change by putting `item_name` in its slot
## ("" = taking off what's there): "ATK +6, DEF -2", or "No change".
static func compare_text(member: Combatant, slot: String, item_name: String) -> String:
	var now: Dictionary = DEFS.get(member.equipment.get(slot, ""), {})
	var next: Dictionary = DEFS.get(item_name, {})
	var parts: Array = []
	for pair: Array in STAT_LABELS:
		var d := int(next.get(pair[0], 0)) - int(now.get(pair[0], 0))
		if d != 0:
			parts.append("%s %+d" % [pair[1], d])
	return ", ".join(parts) if not parts.is_empty() else "No change"


## The piece's set and its bonus, and where this member stands with it.
static func set_text(member: Combatant, item_name: String) -> String:
	var set_id: String = DEFS.get(item_name, {}).get("set_id", "")
	if set_id == "":
		return ""
	var def: Dictionary = SET_BONUSES[set_id]
	var bonus: String = def.get("desc", "buff skills last 1 extra round")
	var status := "mastered - yours for good" if member != null and set_id in member.mastered_sets else "wear all 4 to master it"
	return "%s: %s (%s)" % [def["name"], bonus, status]


## Items in inventory this member could equip into this specific slot.
static func equippable_items_for(member: Combatant, slot: String) -> Array:
	var result: Array = []
	for item_name in GameManager.inventory.keys():
		var def: Dictionary = DEFS.get(item_name, {})
		if def.get("slot", "") == slot and int(GameManager.inventory[item_name]) > 0 and can_equip(member, item_name):
			result.append(item_name)
	return result
