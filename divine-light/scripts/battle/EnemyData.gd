class_name EnemyData
extends RefCounted

# Every enemy and encounter as data (Milestone 20a; moved out of Battle.gd).
#
# Encounter tables list groups of enemies by stats. Behavior comes from the
# enemy's KIT, looked up by name, so the same enemy acts the same everywhere:
#   attack    - modifiers on its basic attack: hits (extra swings), target
#               ("back_row" = prefers the back row), poison_chance/_power/
#               _rounds, stun_chance (percent)
#   abilities - special moves, checked in order each turn; the first one that
#               qualifies is used instead of attacking. Keys: name, kind,
#               chance (percent) or every (every Nth turn), phase / max_phase
#               (boss phases it's allowed in), power, rounds, mult, palette.
#               Kinds: party_def_down, ally_atk_up, self_def_up, charge (a
#               telegraphed heavy blow next turn), magic_single, magic_all.
#   weak      - elements that deal 1.5x damage to it (holy, fire, ice,
#               lightning, earth)
#   int / res - magic stats (enemy spells use int; party spells hit res)

const KITS := {
	# Forest Heartlands (the overworld)
	"Blighted Wolf": {"attack": {"hits": 2}},
	"Hollow Archer": {"attack": {"target": "back_row"}},
	"Shade Wisp": {"attack": {"poison_chance": 40, "poison_power": 4, "poison_rounds": 3}, "res": 12},
	"Corrupted Farmer": {},
	# The Cathedral
	"Fallen Priest": {"int": 12, "res": 10, "abilities": [
		{"name": "Dark Litany", "kind": "party_def_down", "chance": 45, "power": 4, "rounds": 2},
	]},
	"Cursed Paladin": {"res": 3, "attack": {"stun_chance": 20}},
	"Shadow Acolyte": {"abilities": [
		{"name": "Unholy Blessing", "kind": "ally_atk_up", "chance": 40, "power": 4, "rounds": 2},
	]},
	# The Cathedral's escape warden: armored and slow, but punishes mistakes -
	# it raises its hammer a turn early, so Defend is the answer.
	"Hollow Warden": {"abilities": [
		{"name": "Crushing Blow", "kind": "charge", "every": 3, "max_phase": 0, "mult": 2.5, "tell": "raises its hammer high!"},
		{"name": "Crushing Blow", "kind": "charge", "every": 2, "phase": 1, "mult": 2.5, "tell": "raises its hammer high!"},
	]},
	# The Cathedral's boss (holds Vael): hardens its armor, then turns dark
	# versions of Vael's own holy magic on the party. Weak to holy.
	"Fallen Guardian": {"int": 22, "res": 10, "weak": ["holy"], "abilities": [
		{"name": "Iron Faith", "kind": "self_def_up", "every": 3, "max_phase": 0, "power": 8, "rounds": 2},
		{"name": "Profane Consecrate", "kind": "magic_all", "every": 3, "phase": 1, "power": 16, "palette": "debuff"},
		{"name": "Dark Smite", "kind": "magic_single", "chance": 45, "phase": 1, "power": 26, "palette": "debuff"},
	]},
}

# The Forest Heartlands overworld: tuned (20a) for a lone hero around level 3
# fresh out of the Cathedral; groups stay small while the party is small.
const FOREST_ENCOUNTERS: Array = [
	[{"name": "Blighted Wolf",    "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22}],
	[{"name": "Corrupted Farmer", "hp": 90, "atk": 32, "def": 6, "agi":  4, "xp": 34}],
	[{"name": "Blighted Wolf", "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22},
	 {"name": "Blighted Wolf", "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22}],
	[{"name": "Hollow Archer", "hp": 38, "atk": 25, "def": 3, "agi": 10, "xp": 20},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 23, "def": 2, "agi": 12, "xp": 18}],
	[{"name": "Blighted Wolf", "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22},
	 {"name": "Hollow Archer", "hp": 38, "atk": 25, "def": 3, "agi": 10, "xp": 20}],
	[{"name": "Shade Wisp",    "hp": 30, "atk": 23, "def": 2, "agi": 12, "xp": 18},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 23, "def": 2, "agi": 12, "xp": 18}],
	[{"name": "Hollow Archer", "hp": 38, "atk": 25, "def": 3, "agi": 10, "xp": 20},
	 {"name": "Corrupted Farmer", "hp": 90, "atk": 32, "def": 6, "agi": 4, "xp": 34}],
	[{"name": "Shade Wisp",    "hp": 30, "atk": 23, "def": 2, "agi": 12, "xp": 18},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 23, "def": 2, "agi": 12, "xp": 18},
	 {"name": "Corrupted Farmer", "hp": 90, "atk": 32, "def": 6, "agi": 4, "xp": 34}],
	[{"name": "Blighted Wolf", "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22},
	 {"name": "Hollow Archer", "hp": 38, "atk": 25, "def": 3, "agi": 10, "xp": 20},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 23, "def": 2, "agi": 12, "xp": 18}],
	[{"name": "Blighted Wolf", "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22},
	 {"name": "Blighted Wolf", "hp": 42, "atk": 26, "def": 4, "agi": 14, "xp": 22},
	 {"name": "Hollow Archer", "hp": 38, "atk": 25, "def": 3, "agi": 10, "xp": 20}],
]

# The Cathedral when you woke up in it: you're alone and level 1, so these
# are weaker cousins of the real garrison below (same enemies and kits).
const CATHEDRAL_ESCAPE_ENCOUNTERS: Array = [
	[{"name": "Shadow Acolyte", "hp": 26, "atk": 16, "def": 2, "agi": 7, "xp": 22}],
	[{"name": "Fallen Priest",  "hp": 30, "atk": 15, "def": 2, "agi": 6, "xp": 25}],
	[{"name": "Cursed Paladin", "hp": 44, "atk": 18, "def": 5, "agi": 4, "xp": 32}],
	[{"name": "Shadow Acolyte", "hp": 26, "atk": 16, "def": 2, "agi": 7, "xp": 22},
	 {"name": "Fallen Priest",  "hp": 30, "atk": 15, "def": 2, "agi": 6, "xp": 25}],
	[{"name": "Shadow Acolyte", "hp": 26, "atk": 16, "def": 2, "agi": 7, "xp": 22},
	 {"name": "Shadow Acolyte", "hp": 26, "atk": 16, "def": 2, "agi": 7, "xp": 22}],
]

# The Cathedral when you come to rescue Vael: tuned for two heroes around
# level 5 (e.g. Silas's route, where it's the second dungeon). Later routes
# arrive stronger and find it easier - there's no level scaling.
const CATHEDRAL_ENCOUNTERS: Array = [
	[{"name": "Fallen Priest",  "hp": 70,  "atk": 24, "def": 6,  "agi": 10, "xp": 45}],
	[{"name": "Cursed Paladin", "hp": 120, "atk": 28, "def": 14, "agi": 6,  "xp": 60}],
	[{"name": "Shadow Acolyte", "hp": 60,  "atk": 22, "def": 7,  "agi": 13, "xp": 40},
	 {"name": "Shadow Acolyte", "hp": 60,  "atk": 22, "def": 7,  "agi": 13, "xp": 40}],
	[{"name": "Fallen Priest",  "hp": 70,  "atk": 24, "def": 6,  "agi": 10, "xp": 45},
	 {"name": "Cursed Paladin", "hp": 120, "atk": 28, "def": 14, "agi": 6,  "xp": 60}],
	[{"name": "Cursed Paladin", "hp": 120, "atk": 28, "def": 14, "agi": 6,  "xp": 60},
	 {"name": "Shadow Acolyte", "hp": 60,  "atk": 22, "def": 7,  "agi": 13, "xp": 40},
	 {"name": "Fallen Priest",  "hp": 70,  "atk": 24, "def": 6,  "agi": 10, "xp": 45}],
]

# Location -> table. "cathedral_escape" is the Cathedral as a starting dungeon.
const ENCOUNTER_TABLES: Dictionary = {
	"overworld": FOREST_ENCOUNTERS,
	"cathedral": CATHEDRAL_ENCOUNTERS,
	"cathedral_escape": CATHEDRAL_ESCAPE_ENCOUNTERS,
}

# Bosses by id. The escape warden is tuned for a lone hero around level 2-3.
const BOSSES := {
	"hollow_warden": {
		"name": "Hollow Warden", "hp": 120, "atk": 26, "def": 6, "agi": 3, "xp": 150,
		"phase_hp_thresholds": [0.5],
	},
	"fallen_guardian": {
		"name": "Fallen Guardian", "hp": 420, "atk": 34, "def": 14, "agi": 8, "xp": 400,
		"phase_hp_thresholds": [0.5],
	},
}


# Enemies with no art of their own yet borrow another enemy's sprite, scaled
# up (whole-number, nearest) and tinted, until the Act I art pass (21).
const STAND_INS := {
	"Fallen Guardian": {"sprite": "cursed_paladin", "scale": 2, "tint": Color(0.78, 0.64, 0.36)},
}


static func kit(enemy_name: String) -> Dictionary:
	return KITS.get(enemy_name, {})
