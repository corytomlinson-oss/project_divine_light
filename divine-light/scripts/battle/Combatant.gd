class_name Combatant

const MAX_LEVEL: int = 35
const LEVEL_GAINS: Dictionary = {
	"Vael":  {"hp": 25, "mp":  8, "atk": 3, "def": 4, "int": 3, "agi": 2, "res": 3},
	"Ryn":   {"hp": 17, "mp":  0, "atk": 6, "def": 2, "int": 1, "agi": 4, "res": 2},
	"Lyra":  {"hp": 11, "mp": 15, "atk": 1, "def": 1, "int": 7, "agi": 3, "res": 3},
	"Silas": {"hp": 14, "mp":  9, "atk": 4, "def": 2, "int": 1, "agi": 5, "res": 2},
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
var res_stat: int = 0
var agi: int
var level: int = 1
var xp: int = 0
var xp_to_next: int = 100
var xp_reward: int = 0
var char_class: String = ""
var is_enemy: bool = false
var is_ko: bool = false
var is_stunned: bool = false
var stun_rounds: int = 0
var defending: bool = false
var def_buff: int = 0
var def_buff_rounds: int = 0
var atk_buff: int = 0
var atk_buff_rounds: int = 0
var agi_debuff: int = 0
var agi_debuff_rounds: int = 0
var taunt_rounds: int = 0
var sanctuary: bool = false
var stance: String = "Fire"
var burn_rounds: int = 0
var burn_power: int = 0
var poison_rounds: int = 0
var poison_power: int = 0
var bleed_rounds: int = 0
var bleed_power: int = 0
var evasion_rounds: int = 0
var accuracy_debuff_rounds: int = 0
var row: String = "front"
var queued_action: String = ""
var queued_skill: Dictionary = {}
var queued_target: int = 0
var is_boss: bool = false
var boss_phase: int = 0
var phase_hp_thresholds: Array = []


func _init(p_name: String, p_hp: int, p_atk: int, p_def: int, p_agi: int,
		p_enemy: bool = false, p_mp: int = 0, p_class: String = "", p_int: int = 0, p_res: int = 0) -> void:
	display_name = p_name
	hp = p_hp
	max_hp = p_hp
	mp = p_mp
	max_mp = p_mp
	atk = p_atk
	defense = p_def
	agi = p_agi
	int_stat = p_int
	res_stat = p_res
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
		level_up()
		leveled = true
	return leveled


func level_up() -> void:
	if level >= MAX_LEVEL:
		return
	level += 1
	xp_to_next = roundi(100.0 * pow(float(level), 1.5))
	var g: Dictionary = LEVEL_GAINS.get(char_class, {})
	max_hp   += g.get("hp",  0)
	max_mp   += g.get("mp",  0)
	atk      += g.get("atk", 0)
	defense  += g.get("def", 0)
	int_stat += g.get("int", 0)
	res_stat += g.get("res", 0)
	agi      += g.get("agi", 0)
	hp = max_hp
	mp = max_mp


func level_down() -> void:
	if level <= 1:
		return
	var g: Dictionary = LEVEL_GAINS.get(char_class, {})
	max_hp   -= g.get("hp",  0)
	max_mp   -= g.get("mp",  0)
	atk      -= g.get("atk", 0)
	defense  -= g.get("def", 0)
	int_stat -= g.get("int", 0)
	res_stat -= g.get("res", 0)
	agi      -= g.get("agi", 0)
	level -= 1
	xp_to_next = roundi(100.0 * pow(float(level), 1.5))
	hp = mini(hp, max_hp)
	mp = mini(mp, max_mp)


func to_save_dict() -> Dictionary:
	return {
		"display_name": display_name,
		"char_class": char_class,
		"level": level,
		"xp": xp,
		"xp_to_next": xp_to_next,
		"hp": hp,
		"max_hp": max_hp,
		"mp": mp,
		"max_mp": max_mp,
		"qi": qi,
		"max_qi": max_qi,
		"atk": atk,
		"defense": defense,
		"int_stat": int_stat,
		"res_stat": res_stat,
		"agi": agi,
		"row": row,
		"stance": stance,
		"is_ko": is_ko,
	}


func load_save_dict(data: Dictionary) -> void:
	level = int(data.get("level", level))
	xp = int(data.get("xp", xp))
	xp_to_next = int(data.get("xp_to_next", xp_to_next))
	hp = int(data.get("hp", hp))
	max_hp = int(data.get("max_hp", max_hp))
	mp = int(data.get("mp", mp))
	max_mp = int(data.get("max_mp", max_mp))
	qi = int(data.get("qi", qi))
	max_qi = int(data.get("max_qi", max_qi))
	atk = int(data.get("atk", atk))
	defense = int(data.get("defense", defense))
	int_stat = int(data.get("int_stat", int_stat))
	res_stat = int(data.get("res_stat", res_stat))
	agi = int(data.get("agi", agi))
	row = String(data.get("row", row))
	stance = String(data.get("stance", stance))
	is_ko = bool(data.get("is_ko", is_ko))
