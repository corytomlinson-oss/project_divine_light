extends Region

# The Selavon Coast - Selavon's region (Milestone 25d). Reached by the east
# road out of the Forest Heartlands once Duskara is free. Drained to violet-
# grey while the Drowned Admiral holds Selavon; when he falls the color washes
# back and the blight withers. Tiles: coast_tiles.png (salt grass, cliff,
# gate, boardwalk, sea-stone arch, sea, shells, pier).
#
#   <  the road west to the Forest Heartlands
#   Y  Selavon, on its harbor headland to the north-east
#   D  the Drowned Fortress, on an island at the end of the pier
# Blight seals the north-west cove (a chest and a spring) and the east alcove
# (a chest). A hidden clearing in the south-west (flowers mark the way)
# holds the Tidestone Ring.

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~",
	"TTTT...........TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~",
	"TTTT...........TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~",
	"TTTT....c......TTTTTTTTTTTTTTTTT...............TTT~~~~~~~~~~",
	"TTTT...........TTTTTTTTTTTTTTTTT...............TTT~~~~~~~~~~",
	"TTTT...........TTTTTTTTTTTTTTTTT....c..........TTT~~~~~~~~~~",
	"TTTT.......s...TTTTTTTTTTTTTTTTT......Y........TTT~~~~~~~~~~",
	"TTTT...........TTTTTTTTTTTTTTTTT......=........TTT~~~~~~~~~~",
	"TTTT...........TTTTTTTTTTTTTTTTT......=........TTT~~~~~~~~~~",
	"TTTTTTTTTxTTTTTTTTTTTTTTTTTTTTTT...*..=........TTT~~~~~~~~~~",
	"TTTTTTTTTxTTTTTTTTTTTTTTTTTTTTTT......=........TTT~~~~~~~~~~",
	"T.....................................=..TTTTTTTTT~~~~~~~~~~",
	"T.....................................=..TTTTTTTTT~~~~~~~~~~",
	"T...............T................*....=..TTTTTTTTT~~~~~~~~~~",
	"T.....................................=..TTTTTTTTT~~~~~~~~~~",
	"T...................*.................=..TTTTTTTTT~~~~~~~~~~",
	"T.....................................=..TTTTTTTTT~~~~~~~~~~",
	"T...*.................................=..TTTTTTTTT~~~~~~~~~~",
	"T.....................................=..TTTTTTTTT~~~~~~~~~~",
	"<=====================================...TTTTTTTTT~~~~~~~~~~",
	"T.............................=..........TTTTTTTTT~~~~~~~~~~",
	"T.............................=..........TTTTTTTTT~~~~~~~~~~",
	"T.............................=..........TTTTTTTTT~~~~~~~~~~",
	"T.........*.............T.....=.....T....TT......T~~~~~~~~~~",
	"T.............................=..........TT......T~~~~~~~~~~",
	"T.............................=..........TT......T~~~~~~~~~~",
	"T.............................=..........xx......T~~~~~~~~~~",
	"T.....T.....c.............*...=..........TT...c..T~~~~~~~~~~",
	"T.............................=..........TT......T~~~~~~~~~~",
	"T.................*...........=..........TT......T~~~~~~~~~~",
	"T....*.*......................=..........TTTTTTTTT~~~~~~~~~~",
	"TTTTTTtTTTTTTTTTTTTTTTTTTTTTTTbTTT~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTTTTTtTTTTTTTTTTTTTTTTTTTTTTTbTTT~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTT.......TTTTTTTTTTTTTTTTTTTTbTTT~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTT.......TTTTTTTTTTTTTTTTT.......~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTT...c...TTTTTTTTTTTTTTTTT.......~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTT.......TTTTTTTTTTTTTTTTT.c.....~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTT.......TTTTTTTTTTTTTTTTT...D...~~~~~~~~~~~~~~~~~~~~~~~~~~",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~~~~~~~~~~~~~~~~~~~~~~~~",
]
const CHEST_LOOT := {
	Vector2i(12, 30): {"item": "Hi-Potion", "count": 3},
	Vector2i(36, 8): {"gold": 400},
	Vector2i(28, 39): {"item": "Hi-Ether", "count": 2},
	Vector2i(8, 6): {"item": "Elixir", "count": 3},        # the cove, behind the blight
	Vector2i(46, 30): {"gold": 800},                       # the alcove, behind the blight
	Vector2i(6, 38): {"item": "Tidestone Ring", "count": 1},  # the hidden clearing
}


func region_id() -> String:
	return "coast"


func map_rows() -> Array:
	return MAP


func entrances() -> Dictionary:
	return {"Y": "selavon", "D": "drowned_fortress"}


func borders() -> Dictionary:
	return {"<": "overworld"}


func chest_loot() -> Dictionary:
	return CHEST_LOOT


func music() -> String:
	return "coast"  # falls back to the overworld theme until 27 writes one


func default_arrival() -> String:
	return "from:overworld"
