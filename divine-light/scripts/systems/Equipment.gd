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
	"Guardian Plate":     {"slot": "armor",     "class": "Vael", "def": 6, "set_id": "holy_guardian"},
	"Guardian Helm":      {"slot": "helmet",    "class": "Vael", "def": 3, "set_id": "holy_guardian"},
	"Guardian Gauntlets": {"slot": "gloves",    "class": "Vael", "def": 3, "set_id": "holy_guardian"},
	"Guardian Emblem":    {"slot": "accessory", "class": "",     "res": 3, "set_id": "holy_guardian"},

	# Ryn (Martial Artist)
	"Iron Claws": {"slot": "weapon", "class": "Ryn", "atk": 6},
	"Monk Wraps": {"slot": "armor",  "class": "Ryn", "def": 3},

	# Lyra (Invoker)
	"Apprentice Staff": {"slot": "weapon", "class": "Lyra", "atk": 3, "int": 5},
	"Scholar's Robe":   {"slot": "armor",  "class": "Lyra", "res": 3},

	# Silas (Assassin)
	"Twin Daggers": {"slot": "weapon", "class": "Silas", "atk": 7},
	"Leather Hood": {"slot": "helmet", "class": "Silas", "agi": 3},

	# Universal (any class - accessories have no class restriction per the design doc)
	"Traveler's Ring": {"slot": "accessory", "class": "", "agi": 2},
}

# set_id -> data describing the bonus. Only "holy_guardian" (Vael's Act I
# set, "all buff skills last 1 extra round") is actually wired up as a real
# mechanic - see Battle.gd's _buff_duration(). The README lists 11 more
# (3 sets x 4 classes), each its own unique skill-behavior change; those
# aren't implemented yet since there's no real loot to award them through
# until Act I/II content exists. Add here + wire the actual mechanic when
# each one is needed, same pattern as this one.
const SET_BONUSES: Dictionary = {
	"holy_guardian": {"name": "Holy Guardian Set", "buff_duration_bonus": 1},
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
static func has_set_bonus(member: Combatant, set_id: String) -> bool:
	for slot in ["armor", "helmet", "gloves", "accessory"]:
		var item_name: String = member.equipment.get(slot, "")
		if item_name == "" or DEFS.get(item_name, {}).get("set_id", "") != set_id:
			return false
	return true


## Items in inventory this member could equip into this specific slot.
static func equippable_items_for(member: Combatant, slot: String) -> Array:
	var result: Array = []
	for item_name in GameManager.inventory.keys():
		var def: Dictionary = DEFS.get(item_name, {})
		if def.get("slot", "") == slot and int(GameManager.inventory[item_name]) > 0 and can_equip(member, item_name):
			result.append(item_name)
	return result
