extends Region

# The Blighted Reach - the grey land at the edge of the Blighted Maw (Act III,
# Milestone 28a). Reached by the south road below the Guild once all three
# kingdoms are free. Always drained (its "kingdom" is the Maw itself, freed
# only when Vorath falls). Tiles: reach_tiles.png (ash, dead trees, gate,
# cracked road, the portal, chasm, bones, bridge).
#
#   ^  the road north to the Forest Heartlands
#   H  the Threshold, the last safe haven
#   P  the portal into the Blighted Maw (sealed: the portal key, 28a's quests)
# The ruined shrine to the west is where the Hollow Custodian guards the key's
# frame. Blight seals the eastern hollow until Vorath falls.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTT^TTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTT.........TTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTT.........TTT",
	"TTTTTTTTTTTTTTTTTT.......H.......TTTTT....c....TTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTT.........TTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTT.........TTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTT.........TTT",
	"TTTTTTTTTTTTTTTTTT.......=.......TTTTTTxTTTTTTTTTT",
	"TTTTTT...................=.............x.....TTTTT",
	"TTTTTT...................=....*..............TTTTT",
	"TTTTTT......*............=...................TTTTT",
	"TTTTTT...................=...................TTTTT",
	"TTTTTT...................=......~~~~~~~......TTTTT",
	"TTTT.....................=......~~~~~~~......TTTTT",
	"TTTT.....................=......~~~~~~~......TTTTT",
	"TTTT......================...................TTTTT",
	"TTTT.....................=...................TTTTT",
	"TTTT....c.....~~~~~~~....=...................TTTTT",
	"TTTT..........~~~~~~~....=...................TTTTT",
	"TTTT..........~~~~~~~....=........*.....c....TTTTT",
	"TTTT..........~~~~~~~....=...................TTTTT",
	"TTTT.....................=...................TTTTT",
	"TTTTTT..........*........=...................TTTTT",
	"TTTTTT...................=...................TTTTT",
	"TTTTTTTTTTTTTTTTTTT......=......TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT......=......TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT...*..=......TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT......=...c..TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT......=......TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT......=......TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT.............TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTT......P......TTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]
const CHEST_LOOT := {
	Vector2i(8, 20): {"item": "Hi-Ether", "count": 3},
	Vector2i(29, 30): {"item": "Elixir", "count": 4},
	Vector2i(40, 22): {"gold": 1200},
	Vector2i(42, 6): {"item": "Hi-Potion", "count": 9},   # behind the blight: after Vorath
}


const RESTORED_TILES := preload("res://assets/tilesets/reach_tiles_restored.png")


## After Vorath (playtest pass, 2026-10-24): the Reach is drawn dead, so the
## cleansing shader alone would leave it grey. Swap in the restored atlas
## (same columns) on a copy of the tileset, so an older save loaded later in
## the same session still sees the ash.
func _ready() -> void:
	if Kingdoms.is_cleansed("maw"):
		_tile_map.tile_set = _tile_map.tile_set.duplicate(true)
		var src := _tile_map.tile_set.get_source(_tile_map.tile_set.get_source_id(0)) as TileSetAtlasSource
		src.texture = RESTORED_TILES
	super._ready()


## Once Vorath falls the Unraveling's creatures are gone: no random fights in
## the restored Reach (the visible side-quest hunts still stand).
func is_safe() -> bool:
	return Kingdoms.is_cleansed("maw")


## A little further apart than the forest's 14-26 (2026-10-29, Cory: the
## party met Vorath at level 28).
func encounter_steps() -> Vector2i:
	return Vector2i(18, 32)


func region_id() -> String:
	return "reach"


func map_rows() -> Array:
	return MAP


func entrances() -> Dictionary:
	return {"H": "threshold", "P": "blighted_maw"}


func borders() -> Dictionary:
	return {"^": "overworld"}


func chest_loot() -> Dictionary:
	return CHEST_LOOT


func music() -> String:
	return "overworld" if Kingdoms.is_cleansed("maw") else "reach"  # 30; the forest's theme once it's alive again


func default_arrival() -> String:
	return "from:overworld"
