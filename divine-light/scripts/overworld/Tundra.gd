extends Region

# The Northern Tundra - Nordveil's region (Milestone 25a stub, built out in
# 25b). Reached by the mountain pass north of the Forest Heartlands once Act I
# is over. Grey and violet while Nordveil is in the Unraveling's grip; when
# the Frozen Sovereign falls the color washes back and the blight withers.
# Tile letters are in Region.gd; tiles are tundra_tiles.png (same columns as
# the forest's: snow, pines, gate, packed-snow road, icy arch, frozen lake,
# frost tufts, bridge).
#
#   v  the pass south to the Forest Heartlands
#   N  Nordveil, on its plateau to the east      F  the Frozen Citadel, up
#                                                   the mountain road
# A frozen river crosses the middle (one bridge). Blight seals the west
# valley (a chest and a spring) and the alcove north of the crossroads. A
# hidden clearing in the south-west (flowers mark the way through the pines)
# holds a charm found nowhere else.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTFTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=...T.TTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT...*.=.....TTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TT.......TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TT....c..TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=..*..TT.......TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TT.......TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT..T..=.....TTTTTxTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TTTTTxTT............TTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT.....=.....TTTTTxTT............TTTT",
	"TTTT.......TT.................=.......................c.TTTT",
	"TTTT.......TT.................=.........................TTTT",
	"TTTT..c....xx.................=.....*...................TTTT",
	"TTTT.......xx.................=.........................TTTT",
	"TTTT.......xx.................======================N...TTTT",
	"TTTT.......xx.................=.........................TTTT",
	"TTTT.......xx...........*.....=.................*.......TTTT",
	"TTTT....s..TT.................=.........................TTTT",
	"TTTT.......TT.........T.......=......T..................TTTT",
	"TTTTTTTTTTTTT.*...............=....................TTTTTTTTT",
	"TTTTTTTTTTTTT.................=...............c....TTTTTTTTT",
	"TTTTTTTTTTTTT.................=....................TTTTTTTTT",
	"TTTTTT~~~~~~~~~~~~~~~~~~~~~~~~b~~~~~~~~~~~~~~~~~~~~~~~~TTTTT",
	"TTTTTT~~~~~~~~~~~~~~~~~~~~~~~~b~~~~~~~~~~~~~~~~~~~~~~~~TTTTT",
	"TTTTTTTTTTTTTTTT..............=..............TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTT..............=...........*..TTTTTTTTTTTTTTT",
	"TTTT.......TTTTT....*.........=..............TTTTTTTTTTTTTTT",
	"TTTT.......TTTTT..............=..............TTTTTTTTTTTTTTT",
	"TTTT.......TTTTT*..T..........=..............TTTTTTTTTTTTTTT",
	"TTTT..c....ttttt..............=..............TTTTTTTTTTTTTTT",
	"TTTT.......TTTTT*.............=.......*......TTTTTTTTTTTTTTT",
	"TTTT.......TTTTT..............=..............TTTTTTTTTTTTTTT",
	"TTTT.......TTTTT..c...........=.........T....TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTT..............=..............TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTT..............=..............TTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTvTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
]
# What each chest holds (25b): supplies along the road, better behind the
# blight, and the Snowdrop Charm in the hidden clearing.
const CHEST_LOOT := {
	Vector2i(18, 38): {"item": "Potion", "count": 4},
	Vector2i(46, 26): {"item": "Ether", "count": 2},
	Vector2i(54, 16): {"gold": 220},
	Vector2i(6, 18): {"item": "Elixir", "count": 2},     # west valley, behind the blight
	Vector2i(42, 10): {"gold": 450},                     # north alcove, behind the blight
	Vector2i(6, 35): {"item": "Snowdrop Charm", "count": 1},  # the hidden clearing
}


func region_id() -> String:
	return "tundra"


func map_rows() -> Array:
	return MAP


func entrances() -> Dictionary:
	return {"F": "frozen_citadel", "N": "nordveil"}


func borders() -> Dictionary:
	return {"v": "overworld"}


func chest_loot() -> Dictionary:
	return CHEST_LOOT


func music() -> String:
	return "tundra"  # falls back to the overworld theme until 27 writes one


func default_arrival() -> String:
	return "from:overworld"
