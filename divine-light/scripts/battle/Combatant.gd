class_name Combatant

var display_name: String
var hp: int
var max_hp: int
var atk: int
var defense: int
var agi: int
var is_enemy: bool = false
var is_ko: bool = false
var defending: bool = false
var queued_action: String = ""


func _init(p_name: String, p_hp: int, p_atk: int, p_def: int, p_agi: int, p_enemy: bool = false) -> void:
	display_name = p_name
	hp = p_hp
	max_hp = p_hp
	atk = p_atk
	defense = p_def
	agi = p_agi
	is_enemy = p_enemy


func is_alive() -> bool:
	return not is_ko


func receive_damage(dmg: int) -> void:
	hp = maxi(0, hp - dmg)
	if hp == 0:
		is_ko = true
