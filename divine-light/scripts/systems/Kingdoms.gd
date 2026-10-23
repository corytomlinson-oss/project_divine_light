class_name Kingdoms
extends RefCounted

# Act II's structure as data (Milestone 25a), like ActOne for Act I: the three
# corrupted kingdoms, their region maps, towns and dungeons, and the order
# they open in (Cory, 2026-10-23: fixed - Nordveil, Duskara, Selavon;
# cleansing one opens the road to the next).
#
# A kingdom is "cleansed" once its dungeon's boss falls (story flag
# "cleansed_<id>"). The region map then turns from grey wasteland to living
# land (the first time you're back there, as a wave across the screen), its
# blight brambles vanish (new paths), and its town switches to its "after"
# state (Town.cleansed()).

const ORDER: Array = ["nordveil", "duskara", "selavon"]

const KINGDOMS := {
	"nordveil": {
		"name": "Nordveil", "region": "tundra", "town": "nordveil", "dungeon": "frozen_citadel", "after": "",
		"road_text": "The mountain pass is buried under snow and ice.",
		"cleansed_text": "The blizzard breaks. For the first time in months, sunlight touches the snow of Nordveil.",
	},
	"duskara": {
		"name": "Duskara", "region": "desert", "town": "duskara", "dungeon": "sunken_sanctum", "after": "nordveil",
		"road_text": "The western road vanishes into a wall of blowing, burning sand. Better to free Nordveil first.",
		"cleansed_text": "The heat breaks. A cool wind rolls across the dunes of Duskara.",
	},
	"selavon": {
		"name": "Selavon", "region": "coast", "town": "selavon", "dungeon": "drowned_fortress", "after": "duskara",
		"road_text": "Storm surf has swallowed the eastern road. Better to free Duskara first.",
		"cleansed_text": "The storm clouds tear open. Calm light spreads across the waters of Selavon.",
	},
}

# Region maps (25a): location id -> name, scene, and the kingdom whose
# corruption it shows ("" for the Forest Heartlands). A region's scene is ""
# until its milestone builds it.
const REGIONS := {
	"overworld": {"name": "Forest Heartlands", "scene": "res://scenes/overworld/Overworld.tscn", "kingdom": ""},
	"tundra": {"name": "The Northern Tundra", "scene": "res://scenes/overworld/Tundra.tscn", "kingdom": "nordveil"},
	"desert": {"name": "The Duskara Wastes", "scene": "", "kingdom": "duskara"},
	"coast": {"name": "The Selavon Coast", "scene": "", "kingdom": "selavon"},
}

# Act II dungeon scenes ("" until built; Region says "not yet").
const DUNGEON_SCENES := {
	"frozen_citadel": "res://scenes/dungeon/FrozenCitadel.tscn",
	"sunken_sanctum": "",
	"drowned_fortress": "",
}

const DUNGEON_NAMES := {
	"frozen_citadel": "The Frozen Citadel",
	"sunken_sanctum": "The Sunken Sanctum",
	"drowned_fortress": "The Drowned Fortress",
}

# Kingdoms whose content is built (25b-25d each add theirs). Until then its
# road stays closed with a "coming later" note, even after Act I.
const BUILT: Array = []
# Development and tests: treat every kingdom as built.
static var dev_open := false


static func is_built(id: String) -> bool:
	return dev_open or id in BUILT


static func is_cleansed(id: String) -> bool:
	return GameManager.has_flag("cleansed_" + id)


## The road into this kingdom is open: built, and the one before it is free
## (Nordveil: Act I is over).
static func is_open(id: String) -> bool:
	if not is_built(id):
		return false
	var before: String = KINGDOMS[id]["after"]
	return GameManager.has_flag("act_one_complete") if before == "" else is_cleansed(before)


## The first kingdom not yet freed, or "".
static func next_kingdom() -> String:
	for id: String in ORDER:
		if not is_cleansed(id):
			return id
	return ""


static func all_cleansed() -> bool:
	return ORDER.all(func(id: String) -> bool: return is_cleansed(id))


## Its boss has fallen. The region map plays the cleansing wave the next time
## it loads ("cleanse_wave_<id>", cleared once it has played).
static func cleanse(id: String) -> void:
	GameManager.story_flags["cleansed_" + id] = true
	GameManager.story_flags["cleanse_wave_" + id] = true


## What a closed road says.
static func road_text(id: String) -> String:
	if not is_built(id):
		return "%s (Act II: coming in a later update.)" % KINGDOMS[id]["road_text"]
	return KINGDOMS[id]["road_text"]


static func for_region(region: String) -> String:
	return REGIONS.get(region, {}).get("kingdom", "")


static func for_dungeon(dungeon: String) -> String:
	for id: String in KINGDOMS:
		if KINGDOMS[id]["dungeon"] == dungeon:
			return id
	return ""


## Location names for the save screen and the map title (GameManager.location_name).
static func location_name(id: String) -> String:
	if REGIONS.has(id):
		return REGIONS[id]["name"]
	if KINGDOMS.has(id):
		return KINGDOMS[id]["name"]
	if DUNGEON_NAMES.has(id):
		return DUNGEON_NAMES[id]
	return ""
