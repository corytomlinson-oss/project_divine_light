class_name Quests
extends RefCounted

# Act I side quests (Milestone 24; Cory's calls in CLAUDE.md / DECISIONS.md).
# Every dungeon is sealed until its two quests are done, in order; the second
# hands over the key. A dungeon's quests open once it's the next one on this
# game's route (your starting dungeon has none: you wake up inside it). The
# party-member gates in ActOne.DUNGEONS still apply on top.
#
# State: GameManager.quests (quest id -> stage). Absent = not started; stage
# N = working on steps[N]; stage == steps.size() = done. Keys go in
# GameManager.key_items.
#
# People are "<town>/<npc id>" ("verdance/farmer"). A step is one of:
#   {"talk": who, "lines": [...]}  done by talking to them
#   {"hunt": id}                   done by beating HUNTS[id] on the overworld
#   {"fetch": id}                  done by picking up FETCHES[id] on the overworld
# Lines are cutscene commands (say / narrate / sound).

const QUESTS := {
	# ---------------------------------------------------------- The Cathedral
	"grey_field": {
		"name": "Grey Field", "dungeon": "cathedral", "part": 1, "giver": "verdance/farmer",
		"offer": [
			"say Farmer: You're the one who came down off the hill? Then maybe you can help me.",
			"say Farmer: There's a grey wolf in my east field - big as a calf, eyes like coals. Everywhere it walks, the crops die.",
			"say Farmer: Kill it, and I'll put in a word with the elder. She's the one who chained up the Cathedral.",
		],
		"remind": ["say Farmer: The grey wolf's still out in my field. Just north-east of the village."],
		"steps": [
			{"log": "Hunt the grey wolf blighting the farmer's field, just north-east of Verdance.", "hunt": "grey_fang"},
			{"log": "Tell the farmer in Verdance the wolf is dead.", "talk": "verdance/farmer", "lines": [
				"say Farmer: It's dead? Truly? ...Then the field might come back, given time.",
				"say Farmer: Go and see the elder. I'll tell her you can be trusted.",
			]},
		],
	},
	"sextons_key": {
		"name": "The Sexton's Key", "dungeon": "cathedral", "part": 2, "giver": "verdance/elder",
		"offer": [
			"say Elder: The farmer speaks well of you. So. You want into the Cathedral.",
			"say Elder: When the lights turned violet, we chained its gate. The sexton kept the only key - and then he ran for Edenmere with his family.",
			"say Elder: Edenmere's mayor takes in everyone who flees. Ask the mayor where the sexton went.",
		],
		"remind": ["say Elder: Edenmere lies south-east, past the river. Ask the mayor there about the sexton."],
		"steps": [
			{"log": "Ask Edenmere's mayor about the sexton's key.", "talk": "edenmere/mayor", "lines": [
				"say Mayor: The sexton? Poor man. He reached us half-mad, babbling about bells that ring by themselves.",
				"say Mayor: He left this with me and begged me to throw it in the river. I couldn't bring myself to.",
				"say Mayor: If you mean to go up there... take it. And may the light go with you.",
			]},
		],
		"key": "Cathedral Key",
	},
	# ---------------------------------------------------------- The Monastery
	"closed_gate": {
		"name": "The Closed Gate", "dungeon": "monastery", "part": 1, "giver": "verdance/guard",
		"offer": [
			"say Guard: The Monastery? The monks shut the pilgrim gate when the trouble started. They open it only to pilgrims who carry a token.",
			"say Guard: Edenmere's priestess blesses the tokens. Go and see her at the shrine in the town square.",
		],
		"remind": ["say Guard: The priestess in Edenmere makes the pilgrim tokens. Her shrine's in the town square."],
		"steps": [
			{"log": "Ask Edenmere's priestess for a pilgrim's token.", "talk": "edenmere/priestess", "lines": [
				"say Priestess: A pilgrim's token, for the Monastery? I've not made one in months. No pilgrim has dared the road.",
			]},
		],
	},
	"silverleaf": {
		"name": "Silverleaf", "dungeon": "monastery", "part": 2, "giver": "edenmere/priestess",
		"offer": [
			"say Priestess: A token is woven with silverleaf, and my last bundle crumbled to dust. It grows on the slopes beside the Monastery itself.",
			"say Priestess: Bring me a handful and I'll make your token.",
		],
		"remind": ["say Priestess: Silverleaf grows on the slope just east of the Monastery's doors."],
		"steps": [
			{"log": "Gather silverleaf on the slope just east of the Monastery.", "fetch": "silverleaf"},
			{"log": "Bring the silverleaf to Edenmere's priestess.", "talk": "edenmere/priestess", "lines": [
				"say Priestess: Silverleaf, and fresh. Give me a moment...",
				"say Priestess: There. Show this at the pilgrim gate. The monks - whoever is left - will know it.",
			]},
		],
		"key": "Pilgrim's Token",
	},
	# -------------------------------------------------------- The Observatory
	"lost_cart": {
		"name": "The Lost Cart", "dungeon": "observatory", "part": 1, "giver": "edenmere/smith",
		"offer": [
			"say Smith: You look like you can handle yourself. My last ore cart never arrived - it went off the road on the eastern plain.",
			"say Smith: The driver ran back here white as milk. Says something crawled out of the grass and started picking through the wreck.",
			"say Smith: There was a crate on that cart for the Observatory. Bring it back and I'll make it worth your while.",
		],
		"remind": ["say Smith: The wreck's out on the eastern plain, just west of the Observatory."],
		"steps": [
			{"log": "Clear out whatever is picking at the smith's wrecked cart, just west of the Observatory.", "hunt": "wreck_ghoul"},
			{"log": "Bring the Observatory's crate to Edenmere's smith.", "talk": "edenmere/smith", "lines": [
				"say Smith: You found it! Let's see what's so precious...",
				"narrate The crate is empty but for a folded note.",
			]},
		],
	},
	"star_lock": {
		"name": "The Star Lock", "dungeon": "observatory", "part": 2, "giver": "edenmere/smith",
		"offer": [
			"say Smith: \"Mira - the dome door is star-locked now. Keep the chart I sent you safe. Your brother.\"",
			"say Smith: Mira... that's the innkeeper in Verdance. Her brother's the astronomer up there. Take her the note.",
		],
		"remind": ["say Smith: Take that note to the innkeeper in Verdance. Her name's Mira."],
		"steps": [
			{"log": "Take the astronomer's note to the innkeeper in Verdance.", "talk": "verdance/innkeeper", "lines": [
				"say Innkeeper: That's my brother's hand... He's still up there, isn't he.",
				"say Innkeeper: He sent me this chart before the roads closed. The stars on it open the dome door. Bring him home if you can.",
			]},
		],
		"key": "Star Chart",
	},
	# ------------------------------------------------- The Underground Guild
	"pickpocket": {
		"name": "Pickpocket", "dungeon": "guild", "part": 1, "giver": "edenmere/shopkeeper",
		"offer": [
			"say Shopkeeper: Thief! Robbed me blind this morning - took the strongbox right off my counter!",
			"say Shopkeeper: He ran west, for the ravine road down by the Guild. Red scarf. Catch him and I'll pay you twice what's in it.",
		],
		"remind": ["say Shopkeeper: He ran for the ravine road by the Guild, west of here. Red scarf - you can't miss him."],
		"steps": [
			{"log": "Catch the cutpurse who fled to the ravine road by the Guild.", "hunt": "cutpurse"},
			{"log": "Return the strongbox to Edenmere's shopkeeper.", "talk": "edenmere/shopkeeper", "lines": [
				"say Shopkeeper: My strongbox! Not a coin missing... wait. What's this scrap tucked under the lid?",
			]},
		],
	},
	"password": {
		"name": "The Password", "dungeon": "guild", "part": 2, "giver": "edenmere/shopkeeper",
		"offer": [
			"narrate Scrawled on the scrap: \"Hatch word changes at the new moon. Ask the old fox in Verdance.\"",
			"say Shopkeeper: The old fox in Verdance? That can only be the farmer. He ran with the Guild, years back. Everyone knows it; nobody says it.",
		],
		"remind": ["say Shopkeeper: The old fox in Verdance. Go have a word with that farmer."],
		"steps": [
			{"log": "Ask the farmer in Verdance for the Guild's hatch word.", "talk": "verdance/farmer", "lines": [
				"say Farmer: ...Who told you that? Never mind. I can guess.",
				"say Farmer: I left that life behind. But if it gets those tunnels cleaned out - lean close. The word is \"lantern in the dark.\"",
			]},
		],
		"key": "Guild Password",
	},
}

# Visible overworld monsters (24b). Stats are for a lone hero around level 4
# (a quest's dungeon is 2nd, 3rd or 4th on the route depending on the
# starting class) and grow with the party in hunt_enemy().
const HUNTS := {
	"grey_fang": {"cell": Vector2i(21, 20),
		"enemy": {"name": "Grey Fang", "hp": 140, "atk": 27, "def": 5, "agi": 15, "xp": 110},
		"tell": "narrate The grey wolf lifts its head from the dead grass - and charges!",
		"won": "narrate The grey wolf lies still. Already, the grass around it looks a little less grey."},
	"wreck_ghoul": {"cell": Vector2i(52, 20), "prop": Vector2i(51, 20),
		"enemy": {"name": "Wreck Ghoul", "hp": 170, "atk": 29, "def": 7, "agi": 5, "xp": 120},
		"tell": "narrate Something in rotting farm clothes turns from the wreck, pitchfork raised!",
		"won": "narrate The ghoul crumbles. In the wreck, a small sealed crate stamped with stars is still in one piece."},
	"cutpurse": {"cell": Vector2i(30, 36),
		"enemy": {"name": "Cutpurse", "hp": 120, "atk": 25, "def": 5, "agi": 22, "xp": 110},
		"tell": "say Cutpurse: You again? Nobody's taking this box off me!",
		"won": "narrate The cutpurse drops the strongbox and bolts into the trees."},
}

const FETCHES := {
	"silverleaf": {"cell": Vector2i(54, 4),
		"text": "narrate Silver-veined leaves, cool to the touch. You gather a good handful."},
}

# What a dungeon's door says while it's sealed (the member gate is checked
# first, so this only shows once the right hero is with you).
const SEAL_TEXT := {
	"cathedral": "Heavy chains bind the Cathedral gate, fastened with a great iron lock. Someone in Verdance must hold the key.",
	"monastery": "The pilgrim gate is barred. A carved sign reads: \"Pilgrims, show your token.\" Someone in the towns may know how to get one.",
	"observatory": "The dome door has no handle - only a ring of brass stars that turn. Without knowing the pattern, it won't budge. Someone in the towns may know it.",
	"guild": "A voice hisses through the hatch: \"Word?\" You don't know it, and the hatch stays shut. Someone in the towns may know the word.",
}
const OPEN_TEXT := {
	"cathedral": "The sexton's key turns with a groan, and the chains slide to the ground.",
	"monastery": "You hold up the pilgrim's token. After a long moment, the bar on the other side scrapes back.",
	"observatory": "You turn the brass stars to match the chart. Something deep in the door clicks.",
	"guild": "\"Lantern in the dark,\" you whisper. The hatch creaks open.",
}

const QUEST_COLOR := Color(1.0, 0.55, 0.85)  # map markers


# ---------------------------------------------------------------- state

static func stage(id: String) -> int:
	return int(GameManager.quests.get(id, -1))


static func is_started(id: String) -> bool:
	return stage(id) >= 0


static func is_done(id: String) -> bool:
	return stage(id) >= QUESTS[id]["steps"].size()


static func is_active(id: String) -> bool:
	return is_started(id) and not is_done(id)


static func current_step(id: String) -> Dictionary:
	return QUESTS[id]["steps"][stage(id)] if is_active(id) else {}


## The other quest for the same dungeon, part 1 for part 2.
static func _previous(id: String) -> String:
	var q: Dictionary = QUESTS[id]
	for other: String in QUESTS:
		if QUESTS[other]["dungeon"] == q["dungeon"] and QUESTS[other]["part"] == q["part"] - 1:
			return other
	return ""


## Ready to be offered: its dungeon is next on the route (and isn't where you
## started), and part 1 is done if this is part 2.
static func is_available(id: String) -> bool:
	if is_started(id):
		return false
	var dungeon: String = QUESTS[id]["dungeon"]
	if ActOne.next_dungeon() != dungeon or ActOne.is_start_dungeon(dungeon) or has_key(dungeon):
		return false
	var prev := _previous(id)
	return prev == "" or is_done(prev)


static func key_for(dungeon: String) -> String:
	for id: String in QUESTS:
		if QUESTS[id]["dungeon"] == dungeon and QUESTS[id].has("key"):
			return QUESTS[id]["key"]
	return ""


static func has_key(dungeon: String) -> bool:
	return GameManager.key_items.has(key_for(dungeon))


## The quest seal: open if you started here, already cleared it, or have the key.
static func is_unsealed(dungeon: String) -> bool:
	return ActOne.is_start_dungeon(dungeon) or ActOne.is_cleared(dungeon) or has_key(dungeon)


# ---------------------------------------------------------------- talking

## Someone in town was spoken to. Returns the lines to say (empty: nothing to
## do with quests, use their usual talk), and moves quests along: finishes a
## step that was waiting on them, then offers whatever they have next - so a
## giver can close one quest and hand out the next in one conversation.
static func talk(who: String) -> Array:
	var lines: Array = []
	for id: String in QUESTS:
		var step := current_step(id)
		if step.get("talk", "") == who:
			lines.append_array(step["lines"])
			lines.append_array(advance(id))
	for id: String in QUESTS:
		if QUESTS[id]["giver"] == who and is_available(id):
			GameManager.quests[id] = 0
			Sfx.play("menu_confirm")
			lines.append_array(QUESTS[id]["offer"])
			lines.append("narrate New quest: %s." % QUESTS[id]["name"])
	if lines.is_empty():
		for id: String in QUESTS:
			if QUESTS[id]["giver"] == who and is_active(id):
				lines.append_array(QUESTS[id]["remind"])
				break
	return lines


## True if talking to them would do something for a quest (town map markers).
static func has_business(who: String) -> bool:
	for id: String in QUESTS:
		if current_step(id).get("talk", "") == who:
			return true
		if QUESTS[id]["giver"] == who and is_available(id):
			return true
	return false


## Someone in this town has quest business (overworld map markers).
static func town_has_business(town: String) -> bool:
	for id: String in QUESTS:
		var who: String = current_step(id).get("talk", "")
		if who.begins_with(town + "/"):
			return true
		if QUESTS[id]["giver"].begins_with(town + "/") and is_available(id):
			return true
	return false


## Next step; on the last one, the reward. Returns the lines announcing it.
static func advance(id: String) -> Array:
	GameManager.quests[id] = stage(id) + 1
	if not is_done(id):
		return []
	return _reward(id)


## XP and gold, more for a dungeon later on the route; the key on part 2.
static func _reward(id: String) -> Array:
	var q: Dictionary = QUESTS[id]
	var lines: Array = ["sound level_up", "narrate Quest complete: %s!" % q["name"]]
	if q.has("key"):
		GameManager.key_items[q["key"]] = true
		lines.append("narrate Received the %s." % q["key"])
	var depth := 0
	for d: String in ActOne.DUNGEONS:
		if ActOne.is_cleared(d):
			depth += 1
	depth = clampi(depth, 1, 3)
	var xp: int = (90 if q["part"] == 1 else 130) * depth
	var gold: int = (50 if q["part"] == 1 else 80) * depth
	GameManager.gold += gold
	lines.append("narrate The party gains %d XP and %d gold." % [xp, gold])
	for m: Combatant in GameManager.party:
		if m.gain_xp(xp):
			lines.append("narrate %s reached Level %d!" % [m.display_name, m.level])
	return lines


# ---------------------------------------------------------------- overworld

## The hunt or fetch spots the current steps call for: {kind, id, cell}.
static func active_spots() -> Array:
	var spots: Array = []
	for id: String in QUESTS:
		var step := current_step(id)
		if step.has("hunt"):
			spots.append({"kind": "hunt", "id": step["hunt"], "cell": HUNTS[step["hunt"]]["cell"]})
		elif step.has("fetch"):
			spots.append({"kind": "fetch", "id": step["fetch"], "cell": FETCHES[step["fetch"]]["cell"]})
	return spots


## A hunt or fetch step is done. Returns the quest's lines (reward, if any).
static func complete_spot(kind: String, spot_id: String) -> Array:
	for id: String in QUESTS:
		if current_step(id).get(kind, "") == spot_id:
			return advance(id)
	return []


## The hunt target, sized to the party: a lone hero meets the base numbers;
## each extra hero adds HP and a little bite, so it stays a real fight
## whether its dungeon is 2nd or 4th on the route.
static func hunt_enemy(hunt_id: String) -> Dictionary:
	var e: Dictionary = HUNTS[hunt_id]["enemy"].duplicate()
	var extra := maxi(0, GameManager.party.size() - 1)
	e["hp"] = int(e["hp"] * (1.0 + 0.7 * extra))
	e["atk"] = int(e["atk"]) + 3 * extra
	e["def"] = int(e["def"]) + extra
	e["xp"] = int(e["xp"]) * (1 + extra)
	return e


# ---------------------------------------------------------------- quest log

## For the Quests screen: active quests first (with what to do now), then done.
static func log_entries() -> Array:
	var active: Array = []
	var done: Array = []
	for id: String in QUESTS:
		if is_active(id):
			active.append({"name": QUESTS[id]["name"], "text": current_step(id)["log"], "done": false})
		elif is_done(id):
			done.append({"name": QUESTS[id]["name"], "text": "Done.", "done": true})
	return active + done
