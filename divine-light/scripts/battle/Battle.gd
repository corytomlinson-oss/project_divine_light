extends Node2D

enum State { PLAYER_TURN, BATTLE_OVER }

var player_hp: int = 150
var player_max_hp: int = 150
var player_atk: int = 10
var player_def: int = 5
var player_defending: bool = false

var enemy_display_name: String = "Blighted Wolf"
var enemy_hp: int = 50
var enemy_max_hp: int = 50
var enemy_atk: int = 8
var enemy_def: int = 3

var state: State = State.PLAYER_TURN
var _menu_cursor: int = 0
var _menu_options: Array = ["Attack", "Defend", "Run"]
var _option_labels: Array = []

@onready var message_label: Label = $MessageBox/MessageLabel
@onready var enemy_hp_bar: ProgressBar = $EnemyArea/EnemyHPBar
@onready var enemy_name_label: Label = $EnemyArea/EnemyName
@onready var player_hp_label: Label = $PlayerArea/PlayerHPLabel
@onready var action_menu: VBoxContainer = $ActionMenu


func _ready() -> void:
	_option_labels = [
		$ActionMenu/Option0,
		$ActionMenu/Option1,
		$ActionMenu/Option2,
	]
	enemy_name_label.text = enemy_display_name
	_update_ui()
	_update_menu()
	message_label.text = "A %s appeared!" % enemy_display_name


func _process(_delta: float) -> void:
	if state == State.PLAYER_TURN:
		_handle_menu_input()
	elif state == State.BATTLE_OVER and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/overworld/Overworld.tscn")


func _handle_menu_input() -> void:
	if Input.is_action_just_pressed("ui_down"):
		_menu_cursor = (_menu_cursor + 1) % _menu_options.size()
		_update_menu()
	elif Input.is_action_just_pressed("ui_up"):
		_menu_cursor = (_menu_cursor - 1 + _menu_options.size()) % _menu_options.size()
		_update_menu()
	elif Input.is_action_just_pressed("ui_accept"):
		match _menu_cursor:
			0: _on_attack()
			1: _on_defend()
			2: _on_run()


func _update_menu() -> void:
	for i in _option_labels.size():
		_option_labels[i].text = ("> " if i == _menu_cursor else "  ") + _menu_options[i]


func _update_ui() -> void:
	enemy_hp_bar.value = float(enemy_hp) / float(enemy_max_hp) * 100.0
	player_hp_label.text = "HP %d/%d" % [player_hp, player_max_hp]


func _on_attack() -> void:
	player_defending = false
	var dmg := maxi(1, player_atk - enemy_def + randi_range(-2, 2))
	enemy_hp = maxi(0, enemy_hp - dmg)
	_update_ui()

	if enemy_hp == 0:
		message_label.text = "You attack for %d!\n%s is defeated!\nPress Enter to continue." % [dmg, enemy_display_name]
		state = State.BATTLE_OVER
		action_menu.visible = false
		return

	_enemy_turn("You attack for %d!" % dmg)


func _on_defend() -> void:
	player_defending = true
	_enemy_turn("You brace for impact!")


func _on_run() -> void:
	get_tree().change_scene_to_file("res://scenes/overworld/Overworld.tscn")


func _enemy_turn(player_action_text: String) -> void:
	var effective_def := player_def * 2 if player_defending else player_def
	var dmg := maxi(1, enemy_atk - effective_def + randi_range(-1, 1))
	player_hp = maxi(0, player_hp - dmg)
	player_defending = false
	_update_ui()

	var suffix := " (reduced!)" if effective_def > player_def else ""

	if player_hp == 0:
		message_label.text = "%s\n%s hits for %d%s.\nDefeated! Press Enter." % [
				player_action_text, enemy_display_name, dmg, suffix]
		state = State.BATTLE_OVER
		action_menu.visible = false
		return

	message_label.text = "%s\n%s hits for %d%s." % [
			player_action_text, enemy_display_name, dmg, suffix]
