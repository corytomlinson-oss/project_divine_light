class_name EnemyData
extends RefCounted

# Every enemy and encounter as data (Milestone 20a; moved out of Battle.gd).
#
# Encounter tables list groups of enemies by stats. Behavior comes from the
# enemy's KIT, looked up by name, so the same enemy acts the same everywhere:
#   attack    - modifiers on its basic attack: hits (swings; hits_max for a
#               random 2-3), target ("back_row" = prefers the back row),
#               poison_chance/_power/_rounds, stun_chance, berserk (percent
#               chance to hit one of its own allies instead)
#   actions   - actions per round (default 1); actions_max_phase limits it
#   counter_from_phase - boss phase from which it counters every physical
#               attack (the counter_stance ability does it for a few rounds)
#   abilities - special moves, checked in order each turn; the first one that
#               qualifies is used instead of attacking. Keys: name, kind,
#               chance (percent) or every (every Nth turn), phase / max_phase
#               (boss phases it's allowed in), power, rounds, mult, palette.
#               Kinds: party_def_down, ally_atk_up, self_def_up, charge (a
#               telegraphed heavy blow next turn), counter_stance (hits back
#               at physical attacks for `rounds`), magic_single, magic_all.
#   weak      - elements that deal 1.5x damage to it (holy, fire, ice,
#               lightning, earth)
#   int / res - magic stats (enemy spells use int; party spells hit res)
#   short     - a shorter name for the enemy list when the full one won't fit
#               (it's 104px wide; messages always use the full name)

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
	# The Monastery (20b)
	"Corrupted Monk": {"attack": {"hits": 2, "hits_max": 3}},
	"Berserk Warrior": {"attack": {"berserk": 30}},
	"Iron Sentinel": {"res": 2},
	# The Monastery's escape warden (a Ryn start): a fast two-hit striker that
	# settles into a guarding stance - strike into it and it counters. The
	# lesson is timing: Defend, heal or build Qi until the stance drops.
	"Sparring Master": {"attack": {"hits": 2}, "abilities": [
		{"name": "Iron Guard", "kind": "counter_stance", "every": 3, "max_phase": 0, "rounds": 2, "tell": "settles into a guarding stance!"},
		{"name": "Iron Guard", "kind": "counter_stance", "every": 2, "phase": 1, "rounds": 2, "tell": "settles into a guarding stance!"},
	]},
	# The Monastery's boss (holds Ryn): acts twice a round, then in phase 2
	# counters every physical blow. Weakness: magic - spells aren't countered.
	"Corrupted Grandmaster": {"short": "Grandmaster", "attack": {"hits": 2}, "actions": 2, "actions_max_phase": 0, "counter_from_phase": 1},
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

# A rescue dungeon is at its hardest when it's the second on a route: the
# starting hero comes alone, around level 5 (nobody's been rescued yet). So
# rescue tables are tuned for one hero at ~5; later routes arrive stronger, with
# company, and find them easier - there's no level scaling. Group size still
# follows the party (at most one more enemy than party members).
const CATHEDRAL_ENCOUNTERS: Array = [
	[{"name": "Fallen Priest",  "hp": 60,  "atk": 26, "def": 6,  "agi": 10, "xp": 45}],
	[{"name": "Cursed Paladin", "hp": 100, "atk": 30, "def": 14, "agi": 6,  "xp": 60}],
	[{"name": "Shadow Acolyte", "hp": 50,  "atk": 24, "def": 7,  "agi": 13, "xp": 40},
	 {"name": "Shadow Acolyte", "hp": 50,  "atk": 24, "def": 7,  "agi": 13, "xp": 40}],
	[{"name": "Fallen Priest",  "hp": 60,  "atk": 26, "def": 6,  "agi": 10, "xp": 45},
	 {"name": "Cursed Paladin", "hp": 100, "atk": 30, "def": 14, "agi": 6,  "xp": 60}],
	[{"name": "Cursed Paladin", "hp": 100, "atk": 30, "def": 14, "agi": 6,  "xp": 60},
	 {"name": "Shadow Acolyte", "hp": 50,  "atk": 24, "def": 7,  "agi": 13, "xp": 40},
	 {"name": "Fallen Priest",  "hp": 60,  "atk": 26, "def": 6,  "agi": 10, "xp": 45}],
]

# The Monastery as a starting dungeon: a lone level-1 Ryn.
const MONASTERY_ESCAPE_ENCOUNTERS: Array = [
	[{"name": "Corrupted Monk",  "hp": 26, "atk": 13, "def": 2, "agi": 9, "xp": 22}],
	[{"name": "Berserk Warrior", "hp": 32, "atk": 15, "def": 3, "agi": 5, "xp": 25}],
	[{"name": "Iron Sentinel",   "hp": 40, "atk": 12, "def": 9, "agi": 2, "xp": 30}],
	[{"name": "Corrupted Monk",  "hp": 26, "atk": 13, "def": 2, "agi": 9, "xp": 22},
	 {"name": "Berserk Warrior", "hp": 32, "atk": 15, "def": 3, "agi": 5, "xp": 25}],
	[{"name": "Berserk Warrior", "hp": 32, "atk": 15, "def": 3, "agi": 5, "xp": 25},
	 {"name": "Berserk Warrior", "hp": 32, "atk": 15, "def": 3, "agi": 5, "xp": 25}],
]

# The Monastery when you come to rescue Ryn (a lone hero around 5 at worst).
const MONASTERY_ENCOUNTERS: Array = [
	[{"name": "Corrupted Monk",  "hp": 55, "atk": 32, "def": 8,  "agi": 14, "xp": 45}],
	[{"name": "Berserk Warrior", "hp": 65, "atk": 36, "def": 8,  "agi": 8,  "xp": 50}],
	[{"name": "Iron Sentinel",   "hp": 85, "atk": 28, "def": 22, "agi": 3,  "xp": 60}],
	[{"name": "Corrupted Monk",  "hp": 55, "atk": 32, "def": 8,  "agi": 14, "xp": 45},
	 {"name": "Iron Sentinel",   "hp": 85, "atk": 28, "def": 22, "agi": 3,  "xp": 60}],
	[{"name": "Berserk Warrior", "hp": 65, "atk": 36, "def": 8,  "agi": 8,  "xp": 50},
	 {"name": "Corrupted Monk",  "hp": 55, "atk": 32, "def": 8,  "agi": 14, "xp": 45},
	 {"name": "Iron Sentinel",   "hp": 85, "atk": 28, "def": 22, "agi": 3,  "xp": 60}],
]

# Location -> table. "cathedral_escape" is the Cathedral as a starting dungeon.
const ENCOUNTER_TABLES: Dictionary = {
	"overworld": FOREST_ENCOUNTERS,
	"cathedral": CATHEDRAL_ENCOUNTERS,
	"cathedral_escape": CATHEDRAL_ESCAPE_ENCOUNTERS,
	"monastery": MONASTERY_ENCOUNTERS,
	"monastery_escape": MONASTERY_ESCAPE_ENCOUNTERS,
}

# Bosses by id. The escape warden is tuned for a lone hero around level 2-3.
const BOSSES := {
	"hollow_warden": {
		"name": "Hollow Warden", "hp": 120, "atk": 26, "def": 6, "agi": 3, "xp": 150,
		"phase_hp_thresholds": [0.5],
	},
	"fallen_guardian": {
		"name": "Fallen Guardian", "hp": 300, "atk": 30, "def": 12, "agi": 8, "xp": 400,
		"phase_hp_thresholds": [0.5],
	},
	# The Monastery's escape warden, tuned for a lone Ryn around level 2-3.
	"sparring_master": {
		"name": "Sparring Master", "hp": 110, "atk": 18, "def": 5, "agi": 12, "xp": 150,
		"phase_hp_thresholds": [0.5],
	},
	"corrupted_grandmaster": {
		"name": "Corrupted Grandmaster", "hp": 280, "atk": 34, "def": 12, "agi": 16, "xp": 400,
		"phase_hp_thresholds": [0.5],
	},
}


# Enemies with no art of their own yet borrow another enemy's sprite, scaled
# up (whole-number, nearest) and tinted, until the Act I art pass (21).
const STAND_INS := {
	"Fallen Guardian": {"sprite": "cursed_paladin", "scale": 2, "tint": Color(0.78, 0.64, 0.36)},
	"Corrupted Monk": {"sprite": "shadow_acolyte", "tint": Color(0.95, 0.7, 0.45)},
	"Berserk Warrior": {"sprite": "corrupted_farmer", "tint": Color(1.0, 0.55, 0.5)},
	"Iron Sentinel": {"sprite": "cursed_paladin", "tint": Color(0.62, 0.66, 0.78)},
	"Sparring Master": {"sprite": "shadow_acolyte", "tint": Color(0.75, 0.9, 1.0)},
	"Corrupted Grandmaster": {"sprite": "shadow_acolyte", "scale": 2, "tint": Color(0.95, 0.6, 0.35)},
}


static func kit(enemy_name: String) -> Dictionary:
	return KITS.get(enemy_name, {})
