class_name EnemyData
extends RefCounted

# Every enemy and encounter as data (Milestone 20a; moved out of Battle.gd).
#
# Encounter tables list groups of enemies by stats. Behavior comes from the
# enemy's KIT, looked up by name, so the same enemy acts the same everywhere:
#   attack    - modifiers on its basic attack: hits (swings; hits_max for a
#               random 2-3), target ("back_row" = prefers the back row),
#               poison_chance/_power/_rounds, stun_chance, berserk (percent
#               chance to hit one of its own allies instead), random_status
#               (percent chance of poison / silence / DEF down / stun),
#               bleed_chance/_power/_rounds, steal (percent chance to pocket
#               one of the party's consumables; recovered on victory)
#   actions   - actions per round (default 1); actions_max_phase limits it
#   counter_from_phase - boss phase from which it counters every physical
#               attack (the counter_stance ability does it for a few rounds)
#   abilities - special moves, checked in order each turn; the first one that
#               qualifies is used instead of attacking. Keys: name, kind,
#               chance (percent) or every (every Nth turn), phase / max_phase
#               (boss phases it's allowed in), power, rounds, mult, palette.
#               Kinds: party_def_down, ally_atk_up, self_def_up, charge (a
#               telegraphed heavy blow next turn), counter_stance (hits back
#               at physical attacks for `rounds`), magic_single, magic_all,
#               silence (one party member can't use skills on their next
#               turn), aura_bolt / aura_storm (one target / everyone, in the
#               element of its current aura, which then moves on),
#               dot_strike (a hit that always poisons and bleeds), summon
#               (adds `enemies` - list of stat dicts - when none of its adds
#               are alive and 3+ turns have passed since the last summon;
#               adds flee when the summoner falls).
#   aura      - elements its aura cycles through, one step per aura spell;
#               aura_weakness: true makes it weak to whatever beats the
#               current one (fire <-> ice, lightning <-> earth)
#   immune_from_phase - boss phase from which it's immune to one element
#               (one the party can actually deal, if any)
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
	# A chest that bites (23b): telegraphs a big chomp every third turn;
	# old dry wood, so fire finds it.
	"Mimic": {"res": 8, "weak": ["fire"], "abilities": [
		{"name": "Gnash", "kind": "charge", "every": 3, "mult": 2.2, "tell": "opens its jaws wide!"},
	]},
	# Side-quest hunts (Milestone 24): marked, nastier versions of a forest
	# wolf, a farmer gone wrong and a thief, each with a move to watch for.
	"Grey Fang": {"attack": {"hits": 2}, "abilities": [
		{"name": "Savage Lunge", "kind": "charge", "every": 3, "mult": 2.0, "tell": "lowers its head and snarls!"},
	]},
	"Wreck Ghoul": {"weak": ["fire"], "attack": {"poison_chance": 35, "poison_power": 4, "poison_rounds": 3}, "abilities": [
		{"name": "Grave Swing", "kind": "charge", "every": 3, "mult": 2.2, "tell": "raises its pitchfork high!"},
	]},
	"Cutpurse": {"attack": {"steal": 40}},
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
	# The Observatory (20c)
	"Void Mage": {"int": 12, "res": 10, "aura": ["fire", "ice", "lightning"], "aura_weakness": true, "abilities": [
		{"name": "Void Bolt", "kind": "aura_bolt", "chance": 70, "power": 12},
	]},
	"Astral Familiar": {"res": 12, "attack": {"random_status": 40}},
	"Corrupted Scholar": {"int": 10, "res": 10, "abilities": [
		{"name": "Hush", "kind": "silence", "chance": 45},
	]},
	# The Observatory's escape warden (a Lyra start): a spell-casting construct,
	# near-immune to blows but brittle to magic and weak to fire - Lyra's Ember
	# is the answer. It gathers the void a turn before a heavy blast.
	"Void Sentinel": {"int": 12, "res": 0, "weak": ["fire"], "abilities": [
		{"name": "Void Nova", "kind": "charge", "every": 3, "max_phase": 0, "mult": 2.2, "tell": "draws the void into itself!"},
		{"name": "Void Nova", "kind": "charge", "every": 2, "phase": 1, "mult": 2.2, "tell": "draws the void into itself!"},
		{"name": "Void Bolt", "kind": "magic_single", "chance": 40, "power": 20, "palette": "arcane"},
	]},
	# The Observatory's boss (holds Lyra): its spells cycle fire -> ice ->
	# lightning; in phase 2 it becomes immune to an element the party uses.
	# Weak to earth.
	"Void Archmage": {"short": "Archmage", "int": 24, "res": 14, "weak": ["earth"], "aura": ["fire", "ice", "lightning"], "immune_from_phase": 1, "abilities": [
		{"name": "Void Storm", "kind": "aura_storm", "every": 3, "power": 14},
		{"name": "Void Bolt", "kind": "aura_bolt", "chance": 75, "max_phase": 0, "power": 22},
		{"name": "Void Bolt", "kind": "aura_bolt", "chance": 85, "phase": 1, "power": 30},
	]},
	# The Underground Guild (20d)
	"Shadow Thief": {"attack": {"steal": 35}},
	"Venomous Cutthroat": {"attack": {"poison_chance": 30, "poison_power": 4}, "abilities": [
		{"name": "Twin Fangs", "kind": "dot_strike", "chance": 35},
	]},
	"Hired Muscle": {},
	# The Guild's escape warden (a Silas start): dirty fighting - poisoned
	# knuckles, a telegraphed gut punch, and a trick that poisons and bleeds.
	"Corrupted Enforcer": {"short": "Enforcer", "attack": {"poison_chance": 25, "poison_power": 3}, "abilities": [
		{"name": "Gut Punch", "kind": "charge", "every": 3, "max_phase": 0, "mult": 2.2, "tell": "cracks its knuckles and grins..."},
		{"name": "Gut Punch", "kind": "charge", "every": 2, "phase": 1, "mult": 2.2, "tell": "cracks its knuckles and grins..."},
		{"name": "Dirty Trick", "kind": "dot_strike", "chance": 30, "poison_power": 3, "bleed_power": 3},
	]},
	# The Guild's boss (holds Silas): two quick strikes that carry random
	# ailments; in phase 2 it calls in Shadow Thieves. Weak to holy.
	"Shadow Lord": {"weak": ["holy"], "attack": {"hits": 2, "random_status": 30}, "abilities": [
		{"name": "Call the Guild", "kind": "summon", "chance": 100, "phase": 1, "tell": "whistles - Shadow Thieves drop from the rafters!",
		 "enemies": [
			{"name": "Shadow Thief", "hp": 40, "atk": 22, "def": 5, "agi": 22, "xp": 0},
			{"name": "Shadow Thief", "hp": 40, "atk": 22, "def": 5, "agi": 22, "xp": 0},
		 ]},
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

# The Observatory as a starting dungeon: a lone level-1 Lyra (fragile, but
# her Ember hits hard).
const OBSERVATORY_ESCAPE_ENCOUNTERS: Array = [
	[{"name": "Void Mage",         "hp": 26, "atk": 9,  "def": 3, "agi": 7,  "xp": 22}],
	[{"name": "Astral Familiar",   "hp": 20, "atk": 10, "def": 2, "agi": 18, "xp": 22}],
	[{"name": "Corrupted Scholar", "hp": 30, "atk": 11, "def": 4, "agi": 5,  "xp": 25}],
	[{"name": "Void Mage",         "hp": 26, "atk": 9,  "def": 3, "agi": 7,  "xp": 22},
	 {"name": "Astral Familiar",   "hp": 20, "atk": 10, "def": 2, "agi": 18, "xp": 22}],
	[{"name": "Corrupted Scholar", "hp": 30, "atk": 11, "def": 4, "agi": 5,  "xp": 25},
	 {"name": "Astral Familiar",   "hp": 20, "atk": 10, "def": 2, "agi": 18, "xp": 22}],
]

# The Observatory when you come to rescue Lyra (a lone hero around 5 at worst).
const OBSERVATORY_ENCOUNTERS: Array = [
	[{"name": "Void Mage",         "hp": 55, "atk": 24, "def": 7,  "agi": 12, "xp": 45}],
	[{"name": "Astral Familiar",   "hp": 45, "atk": 26, "def": 6,  "agi": 24, "xp": 45}],
	[{"name": "Corrupted Scholar", "hp": 65, "atk": 28, "def": 9,  "agi": 9,  "xp": 50}],
	[{"name": "Void Mage",         "hp": 55, "atk": 24, "def": 7,  "agi": 12, "xp": 45},
	 {"name": "Corrupted Scholar", "hp": 65, "atk": 28, "def": 9,  "agi": 9,  "xp": 50}],
	[{"name": "Astral Familiar",   "hp": 45, "atk": 26, "def": 6,  "agi": 24, "xp": 45},
	 {"name": "Void Mage",         "hp": 55, "atk": 24, "def": 7,  "agi": 12, "xp": 45},
	 {"name": "Corrupted Scholar", "hp": 65, "atk": 28, "def": 9,  "agi": 9,  "xp": 50}],
]

# The Guild as a starting dungeon: a lone level-1 Silas.
const GUILD_ESCAPE_ENCOUNTERS: Array = [
	[{"name": "Shadow Thief",       "hp": 24, "atk": 12, "def": 2, "agi": 16, "xp": 22}],
	[{"name": "Venomous Cutthroat", "hp": 28, "atk": 13, "def": 3, "agi": 10, "xp": 25}],
	[{"name": "Hired Muscle",       "hp": 48, "atk": 16, "def": 5, "agi": 3,  "xp": 30}],
	[{"name": "Shadow Thief",       "hp": 24, "atk": 12, "def": 2, "agi": 16, "xp": 22},
	 {"name": "Venomous Cutthroat", "hp": 28, "atk": 13, "def": 3, "agi": 10, "xp": 25}],
	[{"name": "Hired Muscle",       "hp": 48, "atk": 16, "def": 5, "agi": 3,  "xp": 30},
	 {"name": "Shadow Thief",       "hp": 24, "atk": 12, "def": 2, "agi": 16, "xp": 22}],
]

# The Guild when you come to rescue Silas (a lone hero around 5 at worst).
const GUILD_ENCOUNTERS: Array = [
	[{"name": "Shadow Thief",       "hp": 50,  "atk": 28, "def": 7,  "agi": 22, "xp": 45}],
	[{"name": "Venomous Cutthroat", "hp": 58,  "atk": 30, "def": 8,  "agi": 14, "xp": 50}],
	[{"name": "Hired Muscle",       "hp": 110, "atk": 36, "def": 12, "agi": 4,  "xp": 60}],
	[{"name": "Hired Muscle",       "hp": 110, "atk": 36, "def": 12, "agi": 4,  "xp": 60},
	 {"name": "Venomous Cutthroat", "hp": 58,  "atk": 30, "def": 8,  "agi": 14, "xp": 50}],
	[{"name": "Shadow Thief",       "hp": 50,  "atk": 28, "def": 7,  "agi": 22, "xp": 45},
	 {"name": "Venomous Cutthroat", "hp": 58,  "atk": 30, "def": 8,  "agi": 14, "xp": 50},
	 {"name": "Hired Muscle",       "hp": 110, "atk": 36, "def": 12, "agi": 4,  "xp": 60}],
]

# Act II stand-ins (25a), so the Frozen Citadel's floors, guard and boss can
# be played through; 25b replaces them with the real kits and numbers. The
# guard stands on its floor's stairs (Dungeon.gd); "tell" / "tint" are for
# the map, Battle ignores them.
const FROST_WARDEN := {"name": "Frost Warden", "hp": 360, "atk": 40, "def": 14, "agi": 10, "xp": 400,
		"tell": "narrate An armored knight sheathed in ice turns from the stairs, blade raised!",
		"tint": Color(0.8, 0.92, 1.15)}

# A mimic (23b) - only in rescue dungeons, so there's always a party.
const MIMIC := {"name": "Mimic", "hp": 170, "atk": 32, "def": 12, "agi": 9, "xp": 120}

# Location -> table. "cathedral_escape" is the Cathedral as a starting dungeon.
const ENCOUNTER_TABLES: Dictionary = {
	"overworld": FOREST_ENCOUNTERS,
	"cathedral": CATHEDRAL_ENCOUNTERS,
	"cathedral_escape": CATHEDRAL_ESCAPE_ENCOUNTERS,
	"monastery": MONASTERY_ENCOUNTERS,
	"monastery_escape": MONASTERY_ESCAPE_ENCOUNTERS,
	"observatory": OBSERVATORY_ENCOUNTERS,
	"observatory_escape": OBSERVATORY_ESCAPE_ENCOUNTERS,
	"guild": GUILD_ENCOUNTERS,
	"guild_escape": GUILD_ESCAPE_ENCOUNTERS,
}

# Bosses by id. The escape warden is tuned for a lone hero around level 2-3.
const BOSSES := {
	# Act II stand-in (25a): the Frozen Citadel's boss until 25b builds the
	# real three-phase Frozen Sovereign.
	"frozen_sovereign": {
		"name": "Frozen Sovereign", "hp": 900, "atk": 46, "def": 16, "agi": 9, "xp": 1500,
		"phase_hp_thresholds": [0.66, 0.33],
	},
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
	# The Observatory's escape warden, tuned for a lone Lyra around level 2-3.
	"void_sentinel": {
		"name": "Void Sentinel", "hp": 150, "atk": 18, "def": 16, "agi": 5, "xp": 150,
		"phase_hp_thresholds": [0.5],
	},
	# The Guild's escape warden, tuned for a lone Silas around level 2-3.
	"corrupted_enforcer": {
		"name": "Corrupted Enforcer", "hp": 120, "atk": 19, "def": 6, "agi": 8, "xp": 150,
		"phase_hp_thresholds": [0.5],
	},
	"shadow_lord": {
		"name": "Shadow Lord", "hp": 260, "atk": 30, "def": 10, "agi": 18, "xp": 400,
		"phase_hp_thresholds": [0.5],
	},
	"void_archmage": {
		"name": "Void Archmage", "hp": 270, "atk": 24, "def": 10, "agi": 11, "xp": 400,
		"phase_hp_thresholds": [0.5],
	},
	"corrupted_grandmaster": {
		"name": "Corrupted Grandmaster", "hp": 280, "atk": 34, "def": 12, "agi": 16, "xp": 400,
		"phase_hp_thresholds": [0.5],
	},
}


# Enemies with no art of their own yet borrow another enemy's sprite, scaled
# up (whole-number, nearest) and tinted - e.g. "New Enemy": {"sprite":
# "cursed_paladin", "scale": 2, "tint": Color(...)}. Empty since every Act I
# enemy got real art in Milestone 21; Act II's new enemies can use it until
# their own art pass.
# Enemies without their own art yet borrow another's (Battle.gd, Dungeon.gd).
const STAND_INS := {
	"Frost Warden": {"sprite": "cursed_paladin"},
	"Frozen Sovereign": {"sprite": "fallen_guardian"},
}


static func kit(enemy_name: String) -> Dictionary:
	return KITS.get(enemy_name, {})
