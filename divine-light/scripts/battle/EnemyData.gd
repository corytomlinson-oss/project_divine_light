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
	# The Blighted Reach and the Maw (Act III, 28a; README "The Blighted Maw").
	# The doc calls the first one a Void Sentinel; the Observatory's escape
	# warden already has that name, so it's a Null Sentinel here.
	"Null Sentinel": {"res": 20, "random_immune": 2},
	"Unraveled Soul": {"int": 44, "res": 18, "attack": {"hits": 1, "hits_max": 3}, "abilities": [
		{"name": "Dark Smite", "kind": "magic_all", "chance": 25, "power": 30, "palette": "debuff"},
		{"name": "Death Touch", "kind": "dot_strike", "chance": 25, "poison_power": 8, "bleed_power": 8},
		{"name": "Chaos Bolt", "kind": "magic_single", "chance": 35, "power": 44, "palette": "arcane", "stun_chance": 10},
	]},
	"Entropy Shade": {"int": 40, "res": 26, "weak": ["holy"], "abilities": [
		{"name": "Entropy", "kind": "drain_mp", "chance": 55, "power": 24},
	]},
	"Architect's Thrall": {"int": 46, "res": 22, "weak": ["holy"], "abilities": [
		{"name": "Unmaking", "kind": "charge", "every": 3, "mult": 2.2, "tell": "pulls the light out of the air around it..."},
		{"name": "Void Lance", "kind": "magic_single", "chance": 35, "power": 48, "palette": "debuff"},
	]},
	"Hollow Custodian": {"int": 46, "res": 24, "weak": ["holy"], "random_immune": 1, "abilities": [
		{"name": "Seal of Ruin", "kind": "magic_all", "every": 3, "power": 34, "palette": "debuff"},
		{"name": "Grave Hammer", "kind": "charge", "every": 4, "mult": 2.2, "tell": "raises its broken hammer..."},
	]},
	# Vorath, the Architect (28c; README "Vorath"): phase 1 mirrors the four
	# classes, phase 2 is all area attacks with a rotating immunity (Battle),
	# phase 3 is the Void Form race against the Final Unraveling (Battle).
	"Vorath": {"int": 72, "res": 28, "aura": ["fire", "ice", "lightning", "earth"], "abilities": [
		{"name": "Dark Smite", "kind": "magic_all", "chance": 30, "max_phase": 0, "power": 40, "palette": "debuff"},
		{"name": "Death Touch", "kind": "dot_strike", "every": 4, "max_phase": 0, "poison_power": 10, "bleed_power": 10, "stun_chance": 100},
		{"name": "Void Strike", "kind": "multi_strike", "chance": 30, "max_phase": 0, "hits": 3},
		{"name": "Chaos Bolt", "kind": "aura_bolt", "chance": 60, "max_phase": 0, "power": 55},
		{"name": "Unraveling Wave", "kind": "magic_all", "every": 1, "phase": 1, "max_phase": 1, "power": 48, "palette": "debuff"},
		{"name": "Void Cataclysm", "kind": "magic_all", "chance": 50, "phase": 2, "power": 62, "palette": "debuff"},
		{"name": "Void Strike", "kind": "multi_strike", "chance": 60, "phase": 2, "hits": 3},
	]},
	# Act II side-quest hunts (Milestone 26)
	"Marauder Chief": {"attack": {"steal": 40, "hits": 1, "hits_max": 2}},
	"Snowmane": {"weak": ["fire"], "attack": {"hits": 2}, "abilities": [
		{"name": "Blizzard Howl", "kind": "party_agi_down", "every": 4, "power": 8, "rounds": 2},
		{"name": "Savage Lunge", "kind": "charge", "every": 3, "mult": 2.0, "tell": "crouches low in the snow..."},
	]},
	"Dune Stalker": {"res": 12, "immune": ["earth"], "weak": ["ice"], "abilities": [
		{"name": "Sand Crush", "kind": "charge", "every": 3, "mult": 2.1, "tell": "draws the dunes up around its fists..."},
	]},
	"Reef Horror": {"res": 14, "immune": ["ice"], "weak": ["lightning"], "attack": {"stun_chance": 15}, "abilities": [
		{"name": "Brine Mend", "kind": "heal_allies", "every": 4, "power": 120},
		{"name": "Coral Crush", "kind": "charge", "every": 3, "mult": 2.1, "tell": "hunches, coral spines bristling..."},
	]},
	# The Northern Tundra (Act II, 25b; README "Tundra Kingdom")
	"Frost Wraith": {"int": 30, "res": 18, "weak": ["fire"], "abilities": [
		{"name": "Chilling Mist", "kind": "party_agi_down", "chance": 30, "power": 6, "rounds": 2, "palette": "ice"},
		{"name": "Frost Bolt", "kind": "magic_single", "chance": 40, "power": 30, "palette": "ice"},
	]},
	"Corrupted Knight": {"res": 6, "weak": ["holy"], "attack": {"stun_chance": 10}},
	"Tundra Troll": {"attack": {"target": "front_row"}, "abilities": [
		{"name": "Avalanche Swing", "kind": "charge", "every": 3, "mult": 1.8, "tell": "hoists its club over its head!"},
	]},
	"Blizzard Hawk": {"attack": {"target": "back_row", "hits": 1, "hits_max": 2}, "weak": ["lightning"]},
	# The Duskara Wastes (Act II, 25c; README "Desert Kingdom")
	"Sand Viper": {"attack": {"poison_chance": 100, "poison_power": 6, "poison_rounds": 3}, "weak": ["ice"]},
	"Dust Golem": {"res": 10, "immune": ["earth"], "weak": ["ice"], "abilities": [
		{"name": "Sandslide", "kind": "charge", "every": 3, "mult": 1.8, "tell": "gathers the sand around its fists..."},
	]},
	"Scorched Mage": {"int": 36, "res": 20, "weak": ["ice"], "abilities": [
		{"name": "Flame Wall", "kind": "burn_row", "chance": 45, "power": 26, "rounds": 3, "burn_power": 8},
	]},
	"Dune Marauder": {"attack": {"steal": 35}},
	# The Selavon Coast (Act II, 25d; README "Coastal Kingdom")
	"Sea Specter": {"int": 34, "res": 20, "weak": ["holy"], "abilities": [
		{"name": "Charged Mist", "kind": "magic_single", "chance": 60, "power": 34, "stun_chance": 30, "palette": "lightning"},
	]},
	"Coral Brute": {"res": 12, "immune": ["ice"], "weak": ["lightning"], "attack": {"stun_chance": 10}},
	"Tidal Witch": {"int": 34, "res": 18, "weak": ["lightning"], "abilities": [
		{"name": "Healing Tide", "kind": "heal_allies", "every": 2, "power": 60},
		{"name": "Undertow", "kind": "magic_single", "chance": 35, "power": 30, "palette": "ice"},
	]},
	"Storm Gull": {"attack": {"hits": 2}},
	# The Drowned Fortress's guard and boss (25d)
	"First Mate": {"int": 36, "res": 16, "weak": ["earth"], "attack": {"hits": 1, "hits_max": 2}, "abilities": [
		{"name": "Call the Storm", "kind": "magic_all", "every": 4, "power": 30, "palette": "lightning"},
	]},
	"Drowned Admiral": {"int": 48, "res": 20, "weak": ["earth"], "abilities": [
		# Phase 1: lightning with a chance to paralyze
		{"name": "Thunderclap", "kind": "magic_single", "chance": 50, "max_phase": 0, "power": 46, "stun_chance": 30, "palette": "lightning"},
		# Phase 2: Sea Specters, and a storm aura striking everyone every round
		{"name": "Raise the Drowned", "kind": "summon", "chance": 100, "phase": 1, "max_phase": 1,
			"tell": "raises his cutlass - Sea Specters rise from the flooded deck!",
			"enemies": [
				{"name": "Sea Specter", "hp": 140, "atk": 44, "def": 8, "agi": 16, "xp": 0},
				{"name": "Sea Specter", "hp": 140, "atk": 44, "def": 8, "agi": 16, "xp": 0},
			]},
		{"name": "Storm Aura", "kind": "magic_all", "every": 1, "phase": 1, "max_phase": 1, "power": 28, "palette": "lightning"},
		# Phase 3: a massive strike charged over two rounds - Defend or Sanctuary
		{"name": "Maelstrom Bolt", "kind": "charge_all", "every": 2, "phase": 2, "power": 110,
			"tell": "lifts his cutlass to the sky - the storm gathers around him! (Defend!)"},
		{"name": "Thunderclap", "kind": "magic_single", "chance": 60, "phase": 2, "power": 50, "stun_chance": 30, "palette": "lightning"},
	]},
	# The Sunken Sanctum's guard and boss (25c)
	"Blazing Sentinel": {"int": 36, "res": 16, "weak": ["ice"], "attack": {"burn_chance": 30, "burn_power": 8}, "abilities": [
		{"name": "Wildfire", "kind": "burn_all", "every": 3, "power": 22, "rounds": 3, "burn_power": 9},
		{"name": "Molten Strike", "kind": "charge", "every": 4, "mult": 2.0, "tell": "glows white-hot..."},
	]},
	"Burning Tyrant": {"int": 46, "res": 18, "weak": ["ice"], "aura": ["ice", "lightning"],
		"attack": {"burn_chance": 30, "burn_power": 9}, "abilities": [
		# Phase 1: fire spells and burning blows
		{"name": "Flame Lash", "kind": "magic_single", "chance": 40, "max_phase": 0, "power": 44, "palette": "fire"},
		# Phase 2: the arena itself burns - everyone takes fire every round
		{"name": "Arena Ablaze", "kind": "magic_all", "every": 1, "phase": 1, "max_phase": 1, "power": 26, "palette": "fire"},
		# Phase 3: ice and lightning, switching every cast - keep up
		{"name": "Tempest", "kind": "aura_storm", "every": 3, "phase": 2, "power": 30},
		{"name": "Void Bolt", "kind": "aura_bolt", "every": 1, "phase": 2, "power": 50},
	]},
	# The Frozen Citadel's guard and boss (25b)
	"Frost Warden": {"int": 30, "res": 14, "weak": ["fire"], "abilities": [
		{"name": "Frostbind", "kind": "freeze", "every": 3, "power": 26},
		{"name": "Shatter Strike", "kind": "charge", "every": 4, "mult": 2.0, "tell": "drives its blade into the ice..."},
	]},
	"Ice Knight": {"res": 8, "weak": ["fire"]},
	"Frozen Sovereign": {"int": 40, "res": 16, "weak": ["fire", "holy"], "abilities": [
		# Phase 1: ice and steel, freezing one hero at a time
		{"name": "Frostbind", "kind": "freeze", "every": 3, "max_phase": 0, "power": 30},
		{"name": "Glacial Edge", "kind": "magic_single", "chance": 35, "max_phase": 0, "power": 40, "palette": "ice"},
		# Phase 2: two ice knights, and a blizzard every round
		{"name": "Call the Guard", "kind": "summon", "chance": 100, "phase": 1, "max_phase": 1,
			"tell": "raises its sword - two Ice Knights crack free of the walls!",
			"enemies": [
				{"name": "Ice Knight", "hp": 150, "atk": 46, "def": 20, "agi": 6, "xp": 0},
				{"name": "Ice Knight", "hp": 150, "atk": 46, "def": 20, "agi": 6, "xp": 0},
			]},
		{"name": "Blizzard", "kind": "magic_all", "every": 1, "phase": 1, "max_phase": 1, "power": 26, "palette": "ice"},
		# Phase 3: swallows its knights for power, then berserk ice-and-steel
		{"name": "Frozen Communion", "kind": "absorb", "every": 1, "phase": 2, "power": 6},
		{"name": "Frozen Fury", "kind": "charge", "every": 2, "phase": 2, "mult": 2.2, "tell": "glows white-hot with cold..."},
		{"name": "Glacial Edge", "kind": "magic_single", "chance": 45, "phase": 2, "power": 46, "palette": "ice"},
	]},
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

# The Blighted Maw's guard (28b): an Architect's Thrall on floor 4's stairs.
const THRALL_GUARD := {"name": "Architect's Thrall", "hp": 1600, "atk": 76, "def": 26, "agi": 16, "xp": 3500,
		"tell": "narrate Something tall and wrong unfolds from the dark at the foot of the stairs. It has the Architect's mark burned into its chest."}

# The Drowned Fortress's mid-dungeon guard (25d; the doc's Admiral's First
# Mate): very high AGI - often acts before Silas - and a party-wide storm.
const FIRST_MATE := {"name": "First Mate", "hp": 1150, "atk": 60, "def": 20, "agi": 40, "xp": 1600,
		"tell": "say First Mate: The Admiral's orders - none get past this deck alive!"}

# The Sunken Sanctum's mid-dungeon guard (25c; the doc's Blazing Sentinel):
# burns the whole party every third turn.
const BLAZING_SENTINEL := {"name": "Blazing Sentinel", "hp": 950, "atk": 56, "def": 20, "agi": 10, "xp": 1200,
		"tell": "narrate A warrior wreathed in living flame rises from the stairs!"}

# The Frozen Citadel's mid-dungeon guard (25b; the doc's Frost Warden): it
# stands on its floor's stairs (Dungeon.gd); "tell" is for the map,
# Battle ignores it. Freezes one hero solid every third turn.
const FROST_WARDEN := {"name": "Frost Warden", "hp": 700, "atk": 50, "def": 20, "agi": 10, "xp": 900,
		"tell": "narrate An armored knight sheathed in ice turns from the stairs, blade raised!"}

# A mimic (23b) - only in rescue dungeons, so there's always a party.
const MIMIC := {"name": "Mimic", "hp": 170, "atk": 32, "def": 12, "agi": 9, "xp": 120}

# Location -> table. "cathedral_escape" is the Cathedral as a starting dungeon.
# The Northern Tundra (25b): the doc's four, for four heroes around level 7-9
# (groups are capped at one more than the party, max 3).
const TUNDRA_ENCOUNTERS: Array = [
	[{"name": "Frost Wraith",     "hp": 110, "atk": 40, "def": 6,  "agi": 14, "xp": 70},
	 {"name": "Blizzard Hawk",    "hp": 90,  "atk": 42, "def": 6,  "agi": 26, "xp": 65}],
	[{"name": "Corrupted Knight", "hp": 170, "atk": 46, "def": 26, "agi": 6,  "xp": 85},
	 {"name": "Frost Wraith",     "hp": 110, "atk": 40, "def": 6,  "agi": 14, "xp": 70}],
	[{"name": "Tundra Troll",     "hp": 230, "atk": 52, "def": 12, "agi": 5,  "xp": 95},
	 {"name": "Blizzard Hawk",    "hp": 90,  "atk": 42, "def": 6,  "agi": 26, "xp": 65}],
	[{"name": "Blizzard Hawk",    "hp": 90,  "atk": 42, "def": 6,  "agi": 26, "xp": 65},
	 {"name": "Blizzard Hawk",    "hp": 90,  "atk": 42, "def": 6,  "agi": 26, "xp": 65},
	 {"name": "Frost Wraith",     "hp": 110, "atk": 40, "def": 6,  "agi": 14, "xp": 70}],
	[{"name": "Tundra Troll",     "hp": 230, "atk": 52, "def": 12, "agi": 5,  "xp": 95}],
]
# The Frozen Citadel (25b): the knights and wraiths hold the fortress, the
# trolls guard its gates; a little heavier than the open tundra.
const CITADEL_ENCOUNTERS: Array = [
	[{"name": "Corrupted Knight", "hp": 180, "atk": 48, "def": 26, "agi": 6,  "xp": 90},
	 {"name": "Corrupted Knight", "hp": 180, "atk": 48, "def": 26, "agi": 6,  "xp": 90}],
	[{"name": "Frost Wraith",     "hp": 120, "atk": 42, "def": 6,  "agi": 14, "xp": 75},
	 {"name": "Frost Wraith",     "hp": 120, "atk": 42, "def": 6,  "agi": 14, "xp": 75},
	 {"name": "Corrupted Knight", "hp": 180, "atk": 48, "def": 26, "agi": 6,  "xp": 90}],
	[{"name": "Tundra Troll",     "hp": 240, "atk": 54, "def": 12, "agi": 5,  "xp": 100},
	 {"name": "Frost Wraith",     "hp": 120, "atk": 42, "def": 6,  "agi": 14, "xp": 75}],
	[{"name": "Corrupted Knight", "hp": 180, "atk": 48, "def": 26, "agi": 6,  "xp": 90},
	 {"name": "Blizzard Hawk",    "hp": 95,  "atk": 44, "def": 6,  "agi": 26, "xp": 70}],
]

# The Duskara Wastes and the Sunken Sanctum (25c): four heroes around level 9-11.
const DESERT_ENCOUNTERS: Array = [
	[{"name": "Sand Viper",    "hp": 120, "atk": 48, "def": 8,  "agi": 24, "xp": 85},
	 {"name": "Sand Viper",    "hp": 120, "atk": 48, "def": 8,  "agi": 24, "xp": 85}],
	[{"name": "Dust Golem",    "hp": 260, "atk": 54, "def": 22, "agi": 4,  "xp": 110},
	 {"name": "Scorched Mage", "hp": 130, "atk": 40, "def": 8,  "agi": 12, "xp": 95}],
	[{"name": "Dune Marauder", "hp": 170, "atk": 50, "def": 14, "agi": 18, "xp": 95},
	 {"name": "Sand Viper",    "hp": 120, "atk": 48, "def": 8,  "agi": 24, "xp": 85}],
	[{"name": "Scorched Mage", "hp": 130, "atk": 40, "def": 8,  "agi": 12, "xp": 95},
	 {"name": "Dune Marauder", "hp": 170, "atk": 50, "def": 14, "agi": 18, "xp": 95},
	 {"name": "Sand Viper",    "hp": 120, "atk": 48, "def": 8,  "agi": 24, "xp": 85}],
	[{"name": "Dust Golem",    "hp": 260, "atk": 54, "def": 22, "agi": 4,  "xp": 110}],
]
const SANCTUM_ENCOUNTERS: Array = [
	[{"name": "Scorched Mage", "hp": 140, "atk": 42, "def": 8,  "agi": 12, "xp": 100},
	 {"name": "Scorched Mage", "hp": 140, "atk": 42, "def": 8,  "agi": 12, "xp": 100}],
	[{"name": "Dust Golem",    "hp": 270, "atk": 56, "def": 22, "agi": 4,  "xp": 115},
	 {"name": "Sand Viper",    "hp": 125, "atk": 50, "def": 8,  "agi": 24, "xp": 90}],
	[{"name": "Dust Golem",    "hp": 270, "atk": 56, "def": 22, "agi": 4,  "xp": 115},
	 {"name": "Scorched Mage", "hp": 140, "atk": 42, "def": 8,  "agi": 12, "xp": 100},
	 {"name": "Sand Viper",    "hp": 125, "atk": 50, "def": 8,  "agi": 24, "xp": 90}],
	[{"name": "Dune Marauder", "hp": 180, "atk": 52, "def": 14, "agi": 18, "xp": 100},
	 {"name": "Scorched Mage", "hp": 140, "atk": 42, "def": 8,  "agi": 12, "xp": 100}],
]

# The Selavon Coast and the Drowned Fortress (25d): four heroes ~level 11-13.
const COAST_ENCOUNTERS: Array = [
	[{"name": "Storm Gull",  "hp": 120, "atk": 50, "def": 8,  "agi": 28, "xp": 100},
	 {"name": "Storm Gull",  "hp": 120, "atk": 50, "def": 8,  "agi": 28, "xp": 100}],
	[{"name": "Coral Brute", "hp": 320, "atk": 60, "def": 26, "agi": 5,  "xp": 130},
	 {"name": "Tidal Witch", "hp": 150, "atk": 42, "def": 10, "agi": 14, "xp": 115}],
	[{"name": "Sea Specter", "hp": 140, "atk": 44, "def": 8,  "agi": 16, "xp": 110},
	 {"name": "Storm Gull",  "hp": 120, "atk": 50, "def": 8,  "agi": 28, "xp": 100}],
	[{"name": "Tidal Witch", "hp": 150, "atk": 42, "def": 10, "agi": 14, "xp": 115},
	 {"name": "Sea Specter", "hp": 140, "atk": 44, "def": 8,  "agi": 16, "xp": 110},
	 {"name": "Storm Gull",  "hp": 120, "atk": 50, "def": 8,  "agi": 28, "xp": 100}],
	[{"name": "Coral Brute", "hp": 320, "atk": 60, "def": 26, "agi": 5,  "xp": 130}],
]
const FORTRESS_ENCOUNTERS: Array = [
	[{"name": "Sea Specter", "hp": 150, "atk": 46, "def": 8,  "agi": 16, "xp": 115},
	 {"name": "Sea Specter", "hp": 150, "atk": 46, "def": 8,  "agi": 16, "xp": 115}],
	[{"name": "Coral Brute", "hp": 330, "atk": 62, "def": 26, "agi": 5,  "xp": 135},
	 {"name": "Tidal Witch", "hp": 160, "atk": 44, "def": 10, "agi": 14, "xp": 120}],
	[{"name": "Coral Brute", "hp": 330, "atk": 62, "def": 26, "agi": 5,  "xp": 135},
	 {"name": "Sea Specter", "hp": 150, "atk": 46, "def": 8,  "agi": 16, "xp": 115},
	 {"name": "Tidal Witch", "hp": 160, "atk": 44, "def": 10, "agi": 14, "xp": 120}],
	[{"name": "Storm Gull",  "hp": 125, "atk": 52, "def": 8,  "agi": 28, "xp": 105},
	 {"name": "Sea Specter", "hp": 150, "atk": 46, "def": 8,  "agi": 16, "xp": 115}],
]

# The Blighted Reach (28a): four heroes around level 14-16.
const REACH_ENCOUNTERS: Array = [
	[{"name": "Entropy Shade",  "hp": 180, "atk": 56, "def": 10, "agi": 22, "xp": 240},
	 {"name": "Unraveled Soul", "hp": 240, "atk": 62, "def": 16, "agi": 18, "xp": 270}],
	[{"name": "Null Sentinel",  "hp": 300, "atk": 64, "def": 28, "agi": 8,  "xp": 260},
	 {"name": "Entropy Shade",  "hp": 180, "atk": 56, "def": 10, "agi": 22, "xp": 240}],
	[{"name": "Unraveled Soul", "hp": 240, "atk": 62, "def": 16, "agi": 18, "xp": 270},
	 {"name": "Unraveled Soul", "hp": 240, "atk": 62, "def": 16, "agi": 18, "xp": 270}],
	[{"name": "Architect's Thrall", "hp": 520, "atk": 70, "def": 24, "agi": 14, "xp": 480}],
]

# The Blighted Maw (28b): heavier than the Reach, four heroes ~level 16-21.
const MAW_ENCOUNTERS: Array = [
	[{"name": "Unraveled Soul", "hp": 270, "atk": 66, "def": 16, "agi": 18, "xp": 300},
	 {"name": "Unraveled Soul", "hp": 270, "atk": 66, "def": 16, "agi": 18, "xp": 300},
	 {"name": "Entropy Shade",  "hp": 200, "atk": 60, "def": 10, "agi": 22, "xp": 270}],
	[{"name": "Null Sentinel",  "hp": 340, "atk": 68, "def": 28, "agi": 8,  "xp": 290},
	 {"name": "Null Sentinel",  "hp": 340, "atk": 68, "def": 28, "agi": 8,  "xp": 290}],
	[{"name": "Architect's Thrall", "hp": 560, "atk": 74, "def": 24, "agi": 14, "xp": 510},
	 {"name": "Entropy Shade",  "hp": 200, "atk": 60, "def": 10, "agi": 22, "xp": 270}],
	[{"name": "Architect's Thrall", "hp": 560, "atk": 74, "def": 24, "agi": 14, "xp": 510},
	 {"name": "Architect's Thrall", "hp": 560, "atk": 74, "def": 24, "agi": 14, "xp": 510}],
]

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
	"tundra": TUNDRA_ENCOUNTERS,
	"frozen_citadel": CITADEL_ENCOUNTERS,
	"desert": DESERT_ENCOUNTERS,
	"sunken_sanctum": SANCTUM_ENCOUNTERS,
	"coast": COAST_ENCOUNTERS,
	"reach": REACH_ENCOUNTERS,
	"blighted_maw": MAW_ENCOUNTERS,
	"drowned_fortress": FORTRESS_ENCOUNTERS,
}

# Bosses by id. The escape warden is tuned for a lone hero around level 2-3.
const BOSSES := {
	# Nordveil's boss (25b; README "Act II Kingdom Bosses"): three phases at
	# 66% / 33% HP - freezing steel, then two Ice Knights and a blizzard every
	# round, then it swallows the knights and goes berserk. Tuned for four
	# heroes around level 8-9.
	# Duskara's boss (25c; README "Act II Kingdom Bosses"): phases at 66% /
	# 33% - fire and burning blows, then the arena burns every round, then
	# rapid ice and lightning. Tuned for four heroes around level 10-11.
	# Selavon's boss (25d): phases at 66% / 33% - paralyzing lightning, then
	# Sea Specters and a storm every round, then a strike charged over two
	# rounds that only Defend or Sanctuary softens. Four heroes ~level 12-13.
	# The final boss (28c): phases at 66% / 33%. Tuned for four heroes around
	# level 21-23 with Act III gear, plus Frank in phase 3.
	"vorath": {
		"name": "Vorath", "hp": 9000, "atk": 95, "def": 30, "agi": 16, "xp": 0,
		"phase_hp_thresholds": [0.7, 0.4],  # playtest pass: phase 3 long enough for the Final Unraveling race
	},
	"drowned_admiral": {
		"name": "Drowned Admiral", "hp": 2600, "atk": 62, "def": 20, "agi": 13, "xp": 4200,
		"phase_hp_thresholds": [0.66, 0.33],
	},
	"burning_tyrant": {
		"name": "Burning Tyrant", "hp": 2000, "atk": 58, "def": 18, "agi": 11, "xp": 3200,
		"phase_hp_thresholds": [0.66, 0.33],
	},
	"frozen_sovereign": {
		"name": "Frozen Sovereign", "hp": 1500, "atk": 54, "def": 18, "agi": 9, "xp": 2400,
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
const STAND_INS := {}


static func kit(enemy_name: String) -> Dictionary:
	return KITS.get(enemy_name, {})
