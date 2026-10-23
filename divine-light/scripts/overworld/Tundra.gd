extends Region

# The Northern Tundra - Nordveil's region (Milestone 25a stub; 25b builds it
# out). Reached by the mountain pass north of the Forest Heartlands once Act I
# is over. Grey and violet while Nordveil is in the Unraveling's grip; the
# blight brambles seal off the west valley (a chest and a spring) until the
# Frozen Sovereign falls. Tile letters are in Region.gd.
#
#   F  The Frozen Citadel    N  Nordveil (town gate)    v  the pass south

const MAP := [
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT....F....TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT....=....TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT....=..*.TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT....=....TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT....=....TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT.*..=....TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTT....=....TTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTT.....=.....TTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTT.....=.....TT.........TTTTT",
	"TTTTT........TTTT.....=.....TT...*.....TTTTT",
	"TTTTT........TTTT.....============N....TTTTT",
	"TTTTT..c.....xxTT.....=.....TT.........TTTTT",
	"TTTTT........xx========.....TT.......c.TTTTT",
	"TTTTT....s...xxTT.....=.....TT.........TTTTT",
	"TTTTT........TTTT.....=.....TTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT..*.....=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=.....*..TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTT........=........TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTvTTTTTTTTTTTTTTTTTTTTT",
]
const CHEST_LOOT := {
	Vector2i(7, 14): {"item": "Elixir", "count": 1},   # the west valley, behind the blight
	Vector2i(37, 15): {"item": "Ether", "count": 2},
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
