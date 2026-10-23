extends Region

# The Duskara Wastes - Duskara's region (Milestone 25c). Reached by the west
# road out of the Forest Heartlands once Nordveil is free. Drained to violet-
# grey while the Burning Tyrant holds Duskara; when he falls the color washes
# back and the blight withers. Tile letters are in Region.gd; tiles are
# desert_tiles.png (sand, dune rock, gate, flagstone road, sandstone arch,
# oasis water, scrub, bridge).
#
#   >  the road east to the Forest Heartlands
#   K  Duskara, north of the crossroads by its oasis
#   S  the Sunken Sanctum, half-buried in the south-western dunes
# Blight seals the north-west canyon (a chest) and the south-east alcove (a
# chest and a spring). A hidden clearing south of the road (flowers mark the
# way through the rock) holds the Sunstone Ring.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.......................TTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.......................TTTTTTT",
	"TTTTTTTTTT.............TTTTTTT....*.............*....TTTTTTT",
	"TTTTTTTTTT.............TTTTTTT.......................TTTTTTT",
	"TTTTTTTTTT..c..........TTTTTTT........K..............TTTTTTT",
	"TTTTTTTTTT.............TTTTTTT........=.....~~~~~~...TTTTTTT",
	"TTTTTTTTTT.............xx.............=.....~~~~~~...TTTTTTT",
	"TTTTTTTTTT.............TTTTTTT........=.....~~~~~~...TTTTTTT",
	"TTTTTTTTTT....*........TTTTTTT......T.=.....~~~~~~...TTTTTTT",
	"TTTTTTTTTT.............TTTTTTT........=..............TTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT........=..............TTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT........=...........c..TTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT........=...T..........TTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT........=..............TTTTTTT",
	"TTTTTTTT..............................=...................TT",
	"TTTTTTTT..............................=.*.................TT",
	"TTTTTTTT............T.....*...........=...................TT",
	"TTTTTTTT..............................=...................TT",
	"TTTTTTTT........======================.====================>",
	"TTTTTTTT........=.........................................TT",
	"TTTTTTTT..c.....=.........................................TT",
	"TTTTTTTT........=...........................*.............TT",
	"TTTTTTTT........=.............T...........................TT",
	"TTTTTTTT........=...............*.*.......................TT",
	"TTTTTT..........=........TTTTTTTTtTTTTTTTTTTTTTTTxTTTTTTTTTT",
	"TTTTTT..........=.....*..TTTTTTTTtTTTTTTTTTTTTTTTxTTTTTTTTTT",
	"TTTTTT..........=........TTTTTTTTtTTTTTTTTTTTTTTTxTTTTTTTTTT",
	"TTTTTT..........S........TTTTTTTTtTTTTTTTTTT...........TTTTT",
	"TTTTTT......*............TTTTT.......TTTTTTT...........TTTTT",
	"TTTTTT...................TTTTT.......TTTTTTT...........TTTTT",
	"TTTTTT..T................TTTTT.......TTTTTTT..s........TTTTT",
	"TTTTTT...................TTTTT.......TTTTTTT........c..TTTTT",
	"TTTTTT..............c....TTTTT...c...TTTTTTT...........TTTTT",
	"TTTTTT...................TTTTT.......TTTTTTT...........TTTTT",
	"TTTTTT...................TTTTT.......TTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]
const CHEST_LOOT := {
	Vector2i(20, 36): {"item": "Hi-Potion", "count": 2},
	Vector2i(50, 15): {"item": "Ether", "count": 3},
	Vector2i(10, 24): {"gold": 300},
	Vector2i(12, 8): {"item": "Hi-Ether", "count": 1},      # the canyon, behind the blight
	Vector2i(52, 35): {"gold": 600},                       # the alcove, behind the blight
	Vector2i(33, 36): {"item": "Sunstone Ring", "count": 1},  # the hidden clearing
}


func region_id() -> String:
	return "desert"


func map_rows() -> Array:
	return MAP


func entrances() -> Dictionary:
	return {"K": "duskara", "S": "sunken_sanctum"}


func borders() -> Dictionary:
	return {">": "overworld"}


func chest_loot() -> Dictionary:
	return CHEST_LOOT


func music() -> String:
	return "desert"  # falls back to the overworld theme until 27 writes one


func default_arrival() -> String:
	return "from:overworld"
