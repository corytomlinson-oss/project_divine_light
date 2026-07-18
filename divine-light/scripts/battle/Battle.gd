extends Node2D

enum State { SELECTING, RESOLVING, BATTLE_OVER }

var _party: Array = []
var _enemy: Combatant = null
var _selecting_index: int = 0
var _turn_queue: Array = []
var _menu_cursor: int = 0
var _menu_options: Array = ["Attack", "Defend", "Run"]
var _option_labels: Array = []
var _party_hp_labels: Array = []

var state: State = State.SELECTING

@onready var message_label: Label = $MessageBox/MessageLabel
@onready var enemy_hp_bar: ProgressBar = $EnemyArea/EnemyHPBar
@onready var enemy_name_label: Label = $EnemyArea/EnemyName
@onready var selection_header: Label = $SelectionArea/SelectionHeader
@onready var action_menu: VBoxContainer = $SelectionArea/ActionMenu


func _ready() -> void:
	_option_labels = [
		$SelectionArea/ActionMenu/Option0,
		$SelectionArea/ActionMenu/Option1,
		$SelectionArea/ActionMenu/Option2,
	]
	_party_hp_labels = [
		$PartyPanel/HP_Vael,
		$PartyPanel/HP_Ryn,
		$PartyPanel/HP_Lyra,
		$PartyPanel/HP_Silas,
	]
	_setup_combatants()
	enemy_name_label.text = _enemy.display_name
	_update_ui()
	_begin_selection()


func _setup_combatants() -> void:
	_party = [
		Combatant.new("Vael",  150, 10, 12,  6),
		Combatant.new("Ryn",   100, 14,  8, 10),
		Combatant.new("Lyra",   70,  5,  4,  8),
		Combatant.new("Silas",  90, 12,  7, 14),
	]
	_enemy = Combatant.new("Blighted Wolf", 50, 8, 3, 12, true)


func _process(_delta: float) -> void:
	match state:
		State.SELECTING:
			_handle_menu_input()
		State.RESOLVING:
			if Input.is_action_just_pressed("ui_accept"):
				_execute_next_turn()
		State.BATTLE_OVER:
			if Input.is_action_just_pressed("ui_accept"):
				get_tree().change_scene_to_file("res://scenes/overworld/Overworld.tscn")


func _handle_menu_input() -> void:
	if Input.is_action_just_pressed("ui_down"):
		_menu_cursor = (_menu_cursor + 1) % _menu_options.size()
		_update_menu()
	elif Input.is_action_just_pressed("ui_up"):
		_menu_cursor = (_menu_cursor - 1 + _menu_options.size()) % _menu_options.size()
		_update_menu()
	elif Input.is_action_just_pressed("ui_accept"):
		_confirm_action()


func _confirm_action() -> void:
	var member: Combatant = _party[_selecting_index]
	match _menu_cursor:
		0: member.queued_action = "attack"
		1: member.queued_action = "defend"
		2:
			get_tree().change_scene_to_file("res://scenes/overworld/Overworld.tscn")
			return

	_selecting_index += 1
	_skip_ko_members()

	if _selecting_index >= _party.size():
		_begin_resolving()
	else:
		_menu_cursor = 0
		_update_menu()
		_update_selection_header()


func _skip_ko_members() -> void:
	while _selecting_index < _party.size() and _party[_selecting_index].is_ko:
		_selecting_index += 1


func _begin_selection() -> void:
	state = State.SELECTING
	_selecting_index = 0
	_skip_ko_members()

	if _selecting_index >= _party.size():
		_end_battle(false)
		return

	action_menu.visible = true
	_menu_cursor = 0
	_update_menu()
	_update_selection_header()
	message_label.text = "What will you do?"


func _begin_resolving() -> void:
	state = State.RESOLVING
	action_menu.visible = false
	selection_header.text = ""

	_turn_queue = []
	for member in _party:
		if member.is_alive():
			_turn_queue.append(member)
	_turn_queue.append(_enemy)
	_turn_queue.sort_custom(func(a, b): return a.agi > b.agi)

	message_label.text = "Press Enter..."


func _execute_next_turn() -> void:
	while not _turn_queue.is_empty() and _turn_queue[0].is_ko:
		_turn_queue.pop_front()

	if _turn_queue.is_empty():
		for member in _party:
			member.defending = false
		_enemy.defending = false
		_begin_selection()
		return

	var combatant: Combatant = _turn_queue.pop_front()

	if combatant.is_enemy:
		_execute_enemy_turn(combatant)
	else:
		_execute_party_turn(combatant)


func _execute_party_turn(member: Combatant) -> void:
	match member.queued_action:
		"attack":
			var dmg := maxi(1, member.atk - _enemy.defense + randi_range(-2, 2))
			_enemy.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s attacks for %d!" % [member.display_name, dmg]
			if _enemy.is_ko:
				_end_battle(true)
		"defend":
			member.defending = true
			message_label.text = "%s defends!" % member.display_name


func _execute_enemy_turn(enemy: Combatant) -> void:
	var targets: Array = _party.filter(func(c): return c.is_alive())
	if targets.is_empty():
		return
	var target: Combatant = targets[randi() % targets.size()]
	var def_val := target.defense * 2 if target.defending else target.defense
	var dmg := maxi(1, enemy.atk - def_val + randi_range(-1, 1))
	target.receive_damage(dmg)
	var suffix := " (reduced!)" if target.defending else ""
	_update_ui()
	message_label.text = "%s hits %s for %d%s!" % [enemy.display_name, target.display_name, dmg, suffix]

	if _party.filter(func(c): return c.is_alive()).is_empty():
		_end_battle(false)


func _end_battle(victory: bool) -> void:
	state = State.BATTLE_OVER
	action_menu.visible = false
	selection_header.text = ""
	if victory:
		message_label.text = "%s defeated!\nVictory! Press Enter." % _enemy.display_name
	else:
		message_label.text = "The party has fallen...\nPress Enter."


func _update_menu() -> void:
	for i in _option_labels.size():
		_option_labels[i].text = ("> " if i == _menu_cursor else "  ") + _menu_options[i]


func _update_selection_header() -> void:
	if _selecting_index < _party.size():
		selection_header.text = _party[_selecting_index].display_name + ":"


func _update_ui() -> void:
	enemy_hp_bar.value = float(_enemy.hp) / float(_enemy.max_hp) * 100.0
	for i in _party.size():
		var member: Combatant = _party[i]
		var label: Label = _party_hp_labels[i]
		if member.is_ko:
			label.text = "%s  --/--" % member.display_name
			label.modulate = Color(0.5, 0.5, 0.5)
		else:
			label.text = "%s  %d/%d" % [member.display_name, member.hp, member.max_hp]
			label.modulate = Color(1, 1, 1)
