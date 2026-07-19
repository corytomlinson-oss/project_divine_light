class_name Combatant

const LEVEL_GAINS: Dictionary = {
	"Vael":  {"hp": 25, "mp":  8, "atk": 3, "def": 4, "int": 3, "agi": 2},
	"Ryn":   {"hp": 17, "mp":  0, "atk": 6, "def": 2, "int": 1, "agi": 4},
	"Lyra":  {"hp": 11, "mp": 15, "atk": 1, "def": 1, "int": 7, "agi": 3},
	"Silas": {"hp": 14, "mp":  9, "atk": 4, "def": 2, "int": 1, "agi": 5},
}

var display_name: String
var hp: int
var max_hp: int
var mp: int = 0
var max_mp: int = 0
var qi: int = 0
var max_qi: int = 0
var atk: int
var defense: int
var int_stat: int = 0
var agi: int
var level: int = 1
var xp: int = 0
var xp_to_next: int = 100
var xp_reward: int = 0
var char_class: String = ""
var is_enemy: bool = false
var is_ko: bool = false
var defending: bool = false
var queued_action: String = ""
var queued_skill: Dictionary = {}
var queued_target: int = 0


func _init(p_name: String, p_hp: int, p_atk: int, p_def: int, p_agi: int,
		p_enemy: bool = false, p_mp: int = 0, p_class: String = "", p_int: int = 0) -> void:
	display_name = p_name
	hp = p_hp
	max_hp = p_hp
	mp = p_mp
	max_mp = p_mp
	atk = p_atk
	defense = p_def
	agi = p_agi
	int_stat = p_int
	is_enemy = p_enemy
	char_class = p_class
	if p_class == "Ryn":
		max_qi = 6
		qi = 0


func is_alive() -> bool:
	return not is_ko


func receive_damage(dmg: int) -> void:
	hp = maxi(0, hp - dmg)
	if hp == 0:
		is_ko = true


func gain_xp(amount: int) -> bool:
	xp += amount
	var leveled := false
	while xp >= xp_to_next:
		xp -= xp_to_next
		_level_up()
		leveled = true
	return leveled


func _level_up() -> void:
	level += 1
	xp_to_next = roundi(100.0 * pow(float(level), 1.5))
	var g: Dictionary = LEVEL_GAINS.get(char_class, {})
	max_hp   += g.get("hp",  0)
	max_mp   += g.get("mp",  0)
	atk      += g.get("atk", 0)
	defense  += g.get("def", 0)
	int_stat += g.get("int", 0)
	agi      += g.get("agi", 0)
	hp = max_hp
	mp = max_mp
