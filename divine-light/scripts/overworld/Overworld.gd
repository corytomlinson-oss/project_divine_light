extends Region

# The Forest Heartlands - Act I's overworld (Milestone 20a; made about three
# times bigger in 23c; since 25a just this region's data on top of Region.gd,
# which has the tile letters and everything every overworld map does).
#
#   V  Verdance        E  Edenmere   (town gates)
#   C  The Cathedral   M  The Monastery   O  The Observatory
#   G  The Underground Guild                        (dungeon arches)
#   ^  the mountain pass north to the Tundra (Nordveil)          (25a)
#   <  the west road to the Duskara Wastes, >  the east road to the Selavon
#      Coast; each opens once the kingdom before it is freed
#   v  the south road below the Guild to the Blighted Reach (Act III, 28a):
#      opens once all three kingdoms are free
#
# Three hidden clearings sit in the forest, each holding a chest with an
# accessory you can't get anywhere else (one has a spring too). They show on
# screen through the trees; the way in starts by a patch of flowers.

const MAP := [
	"TTTTTTTTTTTT^TTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTT=TTTTTTTTTTTTTTTTTTT.~~.TTTTTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTT..=.TTTTTTTTTTTTTTTTTT.~~.TTTTTTTTTTTT....*.TTTTTTTTTT",
	"TTTTTTTTTT.........TTTTTTTTTTTTT.~~.TTTTTTTTTTT........TTTTTTTTT",
	"TTTTTTTTTT...........TTTTTTTTTTT.~~.TTTTTTTTT..........TTTTTTTTT",
	"TTTTTTTTT............*.TTTTTTTTT.~~.TTT...TTT............TTTTTTT",
	"TTTTTTTT......C.........TTTTTTTT.~~TTT...c.TTT....M........TTTTT",
	"TTTTTTT.......=.*.......TTTTTTTT.~~TTT......TT....=.........TTTT",
	"TTTTTTTT......=.........TTTTTTTT.~~TTT.....TTT....=.........TTTT",
	"TTTTTTTTT.....=.T.....TTTTTTTTTT*~~.TTT...TTT.....=........TTTTT",
	"TTTTTTTTTTT...=TTTTTTTTTTTTTTTTT.~~.TTTTtTTTTTTTTT=TTT...TTTTTTT",
	"TTTT..TTTTTTTT=TTT..TTTTTTTTTTTTT.~~.TTTtTTTTTTTTT=TTTTTTTTTTTTT",
	"TT..c..TTTTTTT===........TTTTTTTT.~~.TTTtTTTTTTTTT=TTTTTTTTTTTTT",
	"TT.....TTTTTTTTT=......c...TTTTTT.~~.TTTtTTT=======TTTTTTTTTTTTT",
	"TT...s.TTTTTTTTT=T..*.......TTTTT.~~.TTTtttt=TTTTTTTTTTTTTTTTTTT",
	"TTTT..TTTTTTTTTT=T.........TTTTTT.~~.TTTTTTT=.TTTTTTTTTTTTTTTTTT",
	"TTTTTtTTTTTTTTTT=T.....TTTTTTTTTT.~~.TTTTTT.=.*TTTTTTT....TTTTTT",
	"TTTTTtttTTTTTTTT=TT.......TTTTTTT.~~.TTTTT..=..TTTTTT.........TT",
	"TTTTTTTtTTTTTT..=.......*.TTTTTTT.~~.TTT....=..TTTTT...........T",
	"TTTTTTTtTTTT....=..........TTTTTT.~~.TTT....=....TT............T",
	"TTTTTTTt*.......=..........TTTTTT.~~.TT.....=....*.............T",
	"TTTTTT***.......=...*.....TTTTTTT.~~.TT.....=...c.............TT",
	"TTTT..***.......=.........TTTTTTTT.~~.T.....=...........==O...TT",
	"<===............=.........TTTTTTT.~~.T*.....=...........=..*.TTT",
	"TTTT.*..........V=================bb=====================....==>",
	"TTTT.........*..=.*...*...TTTTTTT.~~.TT....TT.................TT",
	"TTTT...c........=...*.....TTTTTTT.~~.TTTTTTTTTTT...........*..TT",
	"TTTTTT..........=.........TTTTTTT.~~.TTTTTTTTTTTTT.....*.....c.T",
	"TTTTTTTTT.......=.........TTTTTTT.~~.TTTTTTTTTTTTTT............T",
	"TTTTTTTTTTTTT...=..*......TTTTTTT.~~*TTTTTTTTTTTTTTTT.........TT",
	"TTTTT....TTTT...==================bb======TTTTTTT..TTTTTTT..*TTT",
	"TTTT......T..*.T.*.....TTTT=TTTTT.~~....T=TTTTTT....TTTTTTTTTTTT",
	"TTT.............TTTTTTTTTTT=TTTTTT.~~....=TTTTTT.....TTTTTTTTTTT",
	"TT....~~~~.......TTTTTTTTTT=TTTTTT.~~....=.TTTT...........TTTTTT",
	"TT...~~~~~~~~....TTTTTT..*.=TTTTTT.~~....=.TTT.............TTTTT",
	"TT...~~~~~~~~..*TTTTTT....*=....TT.~~....==========E.......TTTTT",
	"TTT..~~~~~~~....TTTTTT.....=.......~~.TTTTTT.............*..TTTT",
	"TTTT..~~~~~....TTTTTTT....*=........~~.TTTTT................TTTT",
	"TTTTc.........TTTT.TTTT....G........~~.TTTTT..c.............TTTT",
	"TTTT*.......TTTT.c...TTT**.....c....~~.TTTTTT....*..........TTTT",
	"TTTT....TTTTTTTT...*.ttt**..........~~.TTTTTTT......TT.....TTTTT",
	"TTTTT.TTTTTTTTTT.....TTT**...TTTTTT.~~.TTTTTTTT..*.TTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTT...TTTTTTT.~~.TTTTTTTTTTTTTTTTTTTTTTTTT",
	"TTTTTTTTTTTTTTTTTTTTTTTTTTvTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTTTT",
]
# What each chest holds (23c), hand-picked: supplies along the way, and an
# accessory found nowhere else in each hidden clearing.
const CHEST_LOOT := {
	Vector2i(7, 26): {"item": "Potion", "count": 3},
	Vector2i(23, 13): {"gold": 80},
	Vector2i(48, 21): {"item": "Ether", "count": 2},
	Vector2i(61, 27): {"item": "Antidote", "count": 3},
	Vector2i(46, 38): {"gold": 120},
	Vector2i(31, 39): {"item": "Elixir", "count": 1},
	Vector2i(4, 38): {"item": "Traveler's Ring", "count": 1},
	Vector2i(4, 12): {"item": "Heartwood Charm", "count": 1},    # clearing by the Cathedral
	Vector2i(41, 6): {"item": "Moonstone Pendant", "count": 1},  # clearing by the Monastery
	Vector2i(17, 39): {"item": "Fox-Eye Ring", "count": 1},      # clearing by the Guild
}

func region_id() -> String:
	return "overworld"


func map_rows() -> Array:
	return MAP


func entrances() -> Dictionary:
	return {"V": "verdance", "E": "edenmere", "C": "cathedral", "M": "monastery", "O": "observatory", "G": "guild"}


func borders() -> Dictionary:
	return {"^": "tundra", "<": "desert", ">": "coast", "v": "reach"}


func chest_loot() -> Dictionary:
	return CHEST_LOOT


func music() -> String:
	return "overworld"


func default_arrival() -> String:
	return "verdance"
