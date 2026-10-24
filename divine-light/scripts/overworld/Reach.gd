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
	return "reach"  # Milestone 30


func default_arrival() -> String:
	return "from:overworld"
