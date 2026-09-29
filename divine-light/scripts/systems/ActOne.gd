class_name ActOne
extends RefCounted

# Act I's structure as data (Milestone 20a), straight from the design doc:
# four class dungeons, who's held captive in each, the gate on each door, and
# the order each starting class visits them. Every gate is met by the party
# member rescued just before it, so the routes always work.
#
# A dungeon is "cleared" once its story flag is set ("cleared_cathedral"),
# when the player escapes it or rescues its captive.

const DUNGEONS := {
	"cathedral": {
		"name": "The Cathedral", "captive": "Vael", "gate": "",
		"scene": "res://scenes/dungeon/CathedralDungeon.tscn",
		"gate_text": "",
	},
	"monastery": {
		"name": "The Monastery", "captive": "Ryn", "gate": "Vael",
		"scene": "",
		"gate_text": "A seal of pale holy light bars the doors. Only someone who carries holy power could break it.",
	},
	"observatory": {
		"name": "The Observatory", "captive": "Lyra", "gate": "Ryn",
		"scene": "",
		"gate_text": "A great stone slab has fallen across the entrance. It would take real strength to move it.",
	},
	"guild": {
		"name": "The Underground Guild", "captive": "Silas", "gate": "Lyra",
		"scene": "",
		"gate_text": "Arcane runes crawl across the hatch. Someone versed in magic might be able to read them.",
	},
}

# Starting class -> dungeon order. The first is where they wake up captive.
const ROUTES := {
	"Vael": ["cathedral", "monastery", "observatory", "guild"],
	"Ryn": ["monastery", "observatory", "guild", "cathedral"],
	"Lyra": ["observatory", "guild", "cathedral", "monastery"],
	"Silas": ["guild", "cathedral", "monastery", "observatory"],
}

# What's built so far. Only Vael's start (the Cathedral) exists until
# Milestones 20b-20d add the other dungeons.
const PLAYABLE_STARTS: Array = ["Vael"]


static func start_dungeon(cls: String) -> String:
	return ROUTES[cls][0]


## True when the player woke up here (their own class's dungeon).
static func is_start_dungeon(id: String) -> bool:
	return GameManager.starting_class != "" and start_dungeon(GameManager.starting_class) == id


static func is_cleared(id: String) -> bool:
	return GameManager.has_flag("cleared_" + id)


## The door's gate is met when the party includes the class it asks for.
## Your own starting dungeon has no gate - you're already inside.
static func can_enter(id: String) -> bool:
	var gate: String = DUNGEONS[id]["gate"]
	return gate == "" or GameManager.has_member(gate) or is_start_dungeon(id)


## The next dungeon on this game's route that hasn't been cleared, or "".
static func next_dungeon() -> String:
	var cls := GameManager.starting_class if GameManager.starting_class != "" else "Vael"
	for id: String in ROUTES[cls]:
		if not is_cleared(id):
			return id
	return ""
