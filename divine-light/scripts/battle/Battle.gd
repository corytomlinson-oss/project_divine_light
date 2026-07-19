extends Node2D

enum State { SELECTING, RESOLVING, BATTLE_OVER }
enum MenuState { MAIN, SKILL, ITEM, TARGETING, ALLY_TARGETING }

const CLASS_SKILLS: Dictionary = {
	"Vael": [
		{"name": "Holy Light",    "cost": 10, "cost_type": "mp", "target": "ally",        "effect": "heal",         "power": 25, "min_level": 1},
		{"name": "Smite",         "cost": 8,  "cost_type": "mp", "target": "enemy",       "effect": "holy",         "power": 15, "min_level": 4},
		{"name": "Guard",         "cost": 8,  "cost_type": "mp", "target": "ally_choose", "effect": "guard",        "power": 15, "min_level": 7},
		{"name": "Taunt",         "cost": 6,  "cost_type": "mp", "target": "self",        "effect": "taunt",        "power": 0,  "min_level": 10},
		{"name": "Fortify",       "cost": 15, "cost_type": "mp", "target": "ally_all",    "effect": "fortify",      "power": 10, "min_level": 14},
		{"name": "Divine Strike", "cost": 18, "cost_type": "mp", "target": "enemy",       "effect": "holy_stun",    "power": 30, "min_level": 17},
		{"name": "Divine Shield", "cost": 20, "cost_type": "mp", "target": "ally_all",    "effect": "divine_shield","power": 12, "min_level": 20},
		{"name": "Battle Hymn",   "cost": 18, "cost_type": "mp", "target": "ally_all",    "effect": "battle_hymn",  "power": 8,  "min_level": 23},
		{"name": "Consecrate",    "cost": 25, "cost_type": "mp", "target": "enemy_all",   "effect": "consecrate",   "power": 20, "min_level": 26},
		{"name": "Sanctuary",     "cost": 15, "cost_type": "mp", "target": "ally_choose", "effect": "sanctuary",    "power": 0,  "min_level": 29},
		{"name": "Purify",        "cost": 8,  "cost_type": "mp", "target": "ally_choose", "effect": "purify",       "power": 0,  "min_level": 32},
		{"name": "Divine Wrath",  "cost": 40, "cost_type": "mp", "target": "enemy",       "effect": "holy_wrath",   "power": 60, "min_level": 35},
	],
	"Ryn": [
		{"name": "Iron Fist",        "cost": 1, "cost_type": "qi", "target": "enemy",       "effect": "physical",     "power": 18, "min_level": 1},
		{"name": "Vital Touch",      "cost": 2, "cost_type": "qi", "target": "ally_choose",  "effect": "heal",         "power": 30, "min_level": 4},
		{"name": "Sweep",            "cost": 2, "cost_type": "qi", "target": "enemy_all",    "effect": "sweep",        "power": 12, "min_level": 7},
		{"name": "Pressure Point",   "cost": 2, "cost_type": "qi", "target": "enemy",        "effect": "stun_phys",    "power": 0,  "min_level": 10},
		{"name": "Ki Burst",         "cost": 3, "cost_type": "qi", "target": "enemy",        "effect": "ki_burst",     "power": 22, "min_level": 14},
		{"name": "Ki Blast",         "cost": 3, "cost_type": "qi", "target": "enemy",        "effect": "physical",     "power": 24, "min_level": 17},
		{"name": "Mending Flow",     "cost": 4, "cost_type": "qi", "target": "ally_choose",  "effect": "heal",         "power": 55, "min_level": 20},
		{"name": "Storm Flurry",     "cost": 4, "cost_type": "qi", "target": "enemy",        "effect": "multi_hit",    "power": 12, "min_level": 23},
		{"name": "Crippling Strike", "cost": 4, "cost_type": "qi", "target": "enemy",        "effect": "cripple",      "power": 10, "min_level": 26},
		{"name": "Dragon's Maw",     "cost": 5, "cost_type": "qi", "target": "enemy",        "effect": "physical",     "power": 45, "min_level": 29},
		{"name": "Healing Wave",     "cost": 5, "cost_type": "qi", "target": "ally_all",     "effect": "heal_all",     "power": 40, "min_level": 32},
		{"name": "Rising Dragon",    "cost": 6, "cost_type": "qi", "target": "enemy",        "effect": "rising_dragon","power": 70, "min_level": 35},
	],
	"Lyra": [
		{"name": "Ember",       "cost": 8, "cost_type": "mp", "target": "enemy", "effect": "fire",     "power": 14, "min_level": 1},
	],
	"Silas": [
		{"name": "Quick Strike","cost": 5, "cost_type": "mp", "target": "enemy", "effect": "physical", "power": 12, "min_level": 1},
	],
}

const ENCOUNTERS: Array = [
	# Singles (2/10 = 20%)
	[{"name": "Blighted Wolf",    "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25}],
	[{"name": "Corrupted Farmer", "hp": 80, "atk": 12, "def": 5, "agi":  4, "xp": 35}],
	# Pairs (5/10 = 50%)
	[{"name": "Blighted Wolf", "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25},
	 {"name": "Blighted Wolf", "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25}],
	[{"name": "Hollow Archer", "hp": 40, "atk": 7,  "def": 2, "agi":  9, "xp": 20},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 5,  "def": 1, "agi": 11, "xp": 18}],
	[{"name": "Blighted Wolf", "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25},
	 {"name": "Hollow Archer", "hp": 40, "atk": 7,  "def": 2, "agi":  9, "xp": 20}],
	[{"name": "Shade Wisp",    "hp": 30, "atk": 5,  "def": 1, "agi": 11, "xp": 18},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 5,  "def": 1, "agi": 11, "xp": 18}],
	[{"name": "Hollow Archer", "hp": 40, "atk": 7,  "def": 2, "agi":  9, "xp": 20},
	 {"name": "Corrupted Farmer", "hp": 80, "atk": 12, "def": 5, "agi": 4, "xp": 35}],
	# Triples (3/10 = 30%)
	[{"name": "Shade Wisp",    "hp": 30, "atk": 5,  "def": 1, "agi": 11, "xp": 18},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 5,  "def": 1, "agi": 11, "xp": 18},
	 {"name": "Corrupted Farmer", "hp": 80, "atk": 12, "def": 5, "agi": 4, "xp": 35}],
	[{"name": "Blighted Wolf", "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25},
	 {"name": "Hollow Archer", "hp": 40, "atk": 7,  "def": 2, "agi":  9, "xp": 20},
	 {"name": "Shade Wisp",    "hp": 30, "atk": 5,  "def": 1, "agi": 11, "xp": 18}],
	[{"name": "Blighted Wolf", "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25},
	 {"name": "Blighted Wolf", "hp": 50, "atk": 8,  "def": 3, "agi": 12, "xp": 25},
	 {"name": "Hollow Archer", "hp": 40, "atk": 7,  "def": 2, "agi":  9, "xp": 20}],
]

# Party
var _party: Array = []
var _party_hp_labels: Array = []
var _party_hp_bars: Array = []

# Enemies (built dynamically each battle)
var _enemies: Array = []
var _enemy_labels: Array = []
var _enemy_hp_bars: Array = []
var _enemy_sprites: Array = []

# Battle state
var _selecting_index: int = 0
var _turn_queue: Array = []
var _level_up_queue: Array = []
var state: State = State.SELECTING

# Menu
var _menu_state: MenuState = MenuState.MAIN
var _menu_cursor: int = 0
var _menu_options: Array = []
var _option_labels: Array = []
var _active_skills: Array = []
var _skill_scroll: int = 0

# Targeting
var _target_index: int = 0
var _target_ally_index: int = 0
var _pending_action: String = ""
var _pending_skill: Dictionary = {}

@onready var message_label: Label = $MessageBox/MessageLabel
@onready var selection_header: Label = $SelectionArea/SelectionHeader
@onready var action_menu: VBoxContainer = $SelectionArea/ActionMenu


func _ready() -> void:
	_option_labels = [
		$SelectionArea/ActionMenu/Option0,
		$SelectionArea/ActionMenu/Option1,
		$SelectionArea/ActionMenu/Option2,
		$SelectionArea/ActionMenu/Option3,
		$SelectionArea/ActionMenu/Option4,
	]
	_party_hp_labels = [
		$PartyPanel/HP_Vael,
		$PartyPanel/HP_Ryn,
		$PartyPanel/HP_Lyra,
		$PartyPanel/HP_Silas,
	]
	_party = GameManager.party
	_setup_party_bars()
	_enemies = _generate_encounter()
	_setup_enemy_ui()
	_update_ui()
	_begin_selection()


func _generate_encounter() -> Array:
	var group: Array = ENCOUNTERS[randi() % ENCOUNTERS.size()]
	var result: Array = []
	for data in group:
		var e := Combatant.new(data["name"], int(data["hp"]), int(data["atk"]), int(data["def"]), int(data["agi"]), true)
		e.xp_reward = int(data["xp"])
		result.append(e)
	return result


func _setup_party_bars() -> void:
	var panel: VBoxContainer = $PartyPanel
	_party_hp_bars = []
	for _i in _party.size():
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(0, 4)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.max_value = 100.0
		bar.value = 100.0
		bar.show_percentage = false
		panel.add_child(bar)
		_party_hp_bars.append(bar)
	for i in _party_hp_bars.size():
		panel.move_child(_party_hp_bars[i], i * 2 + 1)


func _setup_enemy_ui() -> void:
	_enemy_labels = []
	_enemy_hp_bars = []
	_enemy_sprites = []
	var count: int = _enemies.size()
	var gap := 4.0
	var sprite_w := (90.0 - gap * (count - 1)) / count
	var row_h := 22.0

	for i in count:
		var sx := 10.0 + i * (sprite_w + gap)
		var sprite := ColorRect.new()
		sprite.position = Vector2(sx, 5)
		sprite.size = Vector2(sprite_w, 63)
		sprite.color = Color(0.55, 0.12, 0.12, 1)
		$EnemyArea.add_child(sprite)
		_enemy_sprites.append(sprite)

		var label := Label.new()
		label.position = Vector2(108, 5 + i * row_h)
		label.size = Vector2(207, 14)
		label.add_theme_font_size_override("font_size", 8)
		label.text = "  " + _enemies[i].display_name
		$EnemyArea.add_child(label)
		_enemy_labels.append(label)

		var bar_bg := ColorRect.new()
		bar_bg.position = Vector2(108, 5 + i * row_h + 14)
		bar_bg.size = Vector2(207, 4)
		bar_bg.color = Color(0.2, 0.05, 0.05, 1)
		$EnemyArea.add_child(bar_bg)

		var bar_fill := ColorRect.new()
		bar_fill.position = Vector2(108, 5 + i * row_h + 14)
		bar_fill.size = Vector2(207, 4)
		bar_fill.color = Color(0.85, 0.25, 0.25, 1)
		$EnemyArea.add_child(bar_fill)
		_enemy_hp_bars.append(bar_fill)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			_debug_level_all(1)
		elif event.keycode == KEY_F2:
			_debug_level_all(-1)


func _process(_delta: float) -> void:
	match state:
		State.SELECTING:
			_handle_menu_input()
		State.RESOLVING:
			if Input.is_action_just_pressed("ui_accept"):
				_execute_next_turn()
		State.BATTLE_OVER:
			if Input.is_action_just_pressed("ui_accept"):
				if not _level_up_queue.is_empty():
					message_label.text = _level_up_queue.pop_front()
				else:
					get_tree().change_scene_to_file("res://scenes/overworld/Overworld.tscn")


func _debug_level_all(direction: int) -> void:
	for member in _party:
		if direction > 0:
			member.level_up()
		else:
			member.level_down()
	_update_ui()
	message_label.text = "[DEBUG] Party level %d  (F1=up F2=down)" % _party[0].level


func _handle_menu_input() -> void:
	if _menu_state == MenuState.TARGETING:
		_handle_target_input()
		return
	if _menu_state == MenuState.ALLY_TARGETING:
		_handle_ally_target_input()
		return
	if Input.is_action_just_pressed("ui_down"):
		_menu_cursor = (_menu_cursor + 1) % _menu_options.size()
		_clamp_skill_scroll()
		_update_menu()
	elif Input.is_action_just_pressed("ui_up"):
		_menu_cursor = (_menu_cursor - 1 + _menu_options.size()) % _menu_options.size()
		_clamp_skill_scroll()
		_update_menu()
	elif Input.is_action_just_pressed("ui_accept"):
		_confirm_action()
	elif Input.is_action_just_pressed("ui_cancel"):
		if _menu_state != MenuState.MAIN:
			_open_main_menu()
			message_label.text = "What will you do?"


func _handle_target_input() -> void:
	var alive_idx: Array = []
	for i in _enemies.size():
		if _enemies[i].is_alive():
			alive_idx.append(i)
	if alive_idx.is_empty():
		return
	var pos: int = alive_idx.find(_target_index)
	if pos == -1:
		pos = 0
		_target_index = alive_idx[0]

	if Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
		_target_index = alive_idx[(pos + 1) % alive_idx.size()]
		_update_enemy_ui()
	elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up"):
		_target_index = alive_idx[(pos - 1 + alive_idx.size()) % alive_idx.size()]
		_update_enemy_ui()
	elif Input.is_action_just_pressed("ui_accept"):
		_confirm_target()
	elif Input.is_action_just_pressed("ui_cancel"):
		_open_main_menu()
		message_label.text = "What will you do?"


func _handle_ally_target_input() -> void:
	var alive_idx: Array = []
	for i in _party.size():
		if _party[i].is_alive():
			alive_idx.append(i)
	if alive_idx.is_empty():
		return
	var pos: int = alive_idx.find(_target_ally_index)
	if pos == -1:
		pos = 0
		_target_ally_index = alive_idx[0]

	if Input.is_action_just_pressed("ui_down"):
		_target_ally_index = alive_idx[(pos + 1) % alive_idx.size()]
		_update_ui()
	elif Input.is_action_just_pressed("ui_up"):
		_target_ally_index = alive_idx[(pos - 1 + alive_idx.size()) % alive_idx.size()]
		_update_ui()
	elif Input.is_action_just_pressed("ui_accept"):
		_confirm_ally_target()
	elif Input.is_action_just_pressed("ui_cancel"):
		_open_main_menu()
		message_label.text = "What will you do?"


func _confirm_action() -> void:
	match _menu_state:
		MenuState.MAIN:  _confirm_main()
		MenuState.SKILL: _confirm_skill()
		MenuState.ITEM:  _confirm_item()


func _confirm_main() -> void:
	var member: Combatant = _party[_selecting_index]
	match _menu_cursor:
		0: _enter_targeting("attack", {})
		1: _open_skill_menu(member)
		2: _open_item_menu()
		3:
			member.queued_action = "defend"
			_advance_selection()
		4:
			get_tree().change_scene_to_file("res://scenes/overworld/Overworld.tscn")


func _open_main_menu() -> void:
	_menu_state = MenuState.MAIN
	_menu_options = ["Attack", "Skill", "Item", "Defend", "Run"]
	_menu_cursor = 0
	_update_menu()
	_update_selection_header()
	_update_ui()


func _open_skill_menu(member: Combatant) -> void:
	var all_skills: Array = CLASS_SKILLS.get(member.char_class, [])
	_active_skills = all_skills.filter(func(s): return member.level >= int(s.get("min_level", 1)))
	if _active_skills.is_empty():
		message_label.text = "No skills learned yet."
		return
	_menu_state = MenuState.SKILL
	_skill_scroll = 0
	_menu_options = []
	for skill in _active_skills:
		var cost_label: String = "(%dQi)" % skill["cost"] if skill["cost_type"] == "qi" else "(%dMP)" % skill["cost"]
		_menu_options.append("%s %s" % [skill["name"], cost_label])
	_menu_cursor = 0
	_update_menu()
	selection_header.text = "-- Skills --"


func _open_item_menu() -> void:
	_menu_state = MenuState.ITEM
	_menu_options = ["Potion x5", "-- Empty --"]
	_menu_cursor = 0
	_update_menu()
	selection_header.text = "-- Items --"


func _enter_targeting(action: String, skill: Dictionary) -> void:
	_pending_action = action
	_pending_skill = skill
	_menu_state = MenuState.TARGETING
	_target_index = 0
	for i in _enemies.size():
		if _enemies[i].is_alive():
			_target_index = i
			break
	action_menu.visible = false
	selection_header.text = "Target?"
	_update_enemy_ui()
	message_label.text = "Select a target."


func _enter_ally_targeting(action: String, skill: Dictionary) -> void:
	_pending_action = action
	_pending_skill = skill
	_menu_state = MenuState.ALLY_TARGETING
	_target_ally_index = 0
	for i in _party.size():
		if _party[i].is_alive():
			_target_ally_index = i
			break
	action_menu.visible = false
	selection_header.text = "Target Ally?"
	_update_ui()
	message_label.text = "Select an ally."


func _confirm_target() -> void:
	var member: Combatant = _party[_selecting_index]
	member.queued_action = _pending_action
	member.queued_skill = _pending_skill
	member.queued_target = _target_index
	_advance_selection()
	_update_enemy_ui()


func _confirm_ally_target() -> void:
	var member: Combatant = _party[_selecting_index]
	member.queued_action = _pending_action
	member.queued_skill = _pending_skill
	member.queued_target = _target_ally_index
	_menu_state = MenuState.MAIN
	_update_ui()
	_advance_selection()


func _confirm_skill() -> void:
	if _active_skills.is_empty():
		return
	var member: Combatant = _party[_selecting_index]
	var skill: Dictionary = _active_skills[_menu_cursor]
	if skill["cost_type"] == "mp" and member.mp < int(skill["cost"]):
		message_label.text = "Not enough MP!"
		return
	if skill["cost_type"] == "qi" and member.qi < int(skill["cost"]):
		message_label.text = "Not enough Qi!"
		return
	var target_type: String = skill["target"]
	match target_type:
		"ally", "ally_all", "self", "enemy_all":
			member.queued_action = "skill"
			member.queued_skill = skill
			member.queued_target = -1
			_advance_selection()
		"ally_choose":
			_enter_ally_targeting("skill", skill)
		"enemy":
			_enter_targeting("skill", skill)


func _confirm_item() -> void:
	if _menu_cursor == 0:
		var member: Combatant = _party[_selecting_index]
		member.queued_action = "item_potion"
		_advance_selection()


func _advance_selection() -> void:
	_selecting_index += 1
	_skip_ko_members()
	if _selecting_index >= _party.size():
		_begin_resolving()
	else:
		_open_main_menu()
		message_label.text = "What will you do?"


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
	_open_main_menu()
	message_label.text = "What will you do?"


func _begin_resolving() -> void:
	state = State.RESOLVING
	_menu_state = MenuState.MAIN
	action_menu.visible = false
	selection_header.text = ""
	_turn_queue = []
	for member in _party:
		if member.is_alive():
			_turn_queue.append(member)
	for enemy in _enemies:
		if enemy.is_alive():
			_turn_queue.append(enemy)
	_turn_queue.sort_custom(func(a, b): return (a.agi - a.agi_debuff) > (b.agi - b.agi_debuff))
	_update_enemy_ui()
	message_label.text = "Press Enter..."


func _execute_next_turn() -> void:
	while not _turn_queue.is_empty() and _turn_queue[0].is_ko:
		_turn_queue.pop_front()
	if _turn_queue.is_empty():
		for member in _party:
			member.defending = false
		for enemy in _enemies:
			enemy.defending = false
		_tick_buffs()
		_begin_selection()
		return
	var combatant: Combatant = _turn_queue.pop_front()
	if combatant.is_stunned:
		combatant.stun_rounds -= 1
		if combatant.stun_rounds <= 0:
			combatant.is_stunned = false
		message_label.text = "%s is stunned and cannot act!" % combatant.display_name
		return
	if combatant.is_enemy:
		_execute_enemy_turn(combatant)
	else:
		_execute_party_turn(combatant)


func _get_enemy_target(member: Combatant) -> Combatant:
	var idx: int = member.queued_target
	if idx >= 0 and idx < _enemies.size() and _enemies[idx].is_alive():
		return _enemies[idx]
	for e in _enemies:
		if e.is_alive():
			return e
	return null


func _get_ally_target(member: Combatant, skill: Dictionary) -> Combatant:
	if skill["target"] == "ally_choose":
		var idx: int = member.queued_target
		if idx >= 0 and idx < _party.size() and _party[idx].is_alive():
			return _party[idx]
	var alive: Array = _party.filter(func(c): return c.is_alive())
	alive.sort_custom(func(a, b): return float(a.hp) / a.max_hp < float(b.hp) / b.max_hp)
	return alive[0] if not alive.is_empty() else member


func _execute_party_turn(member: Combatant) -> void:
	match member.queued_action:
		"attack":      _do_attack(member)
		"skill":       _do_skill(member, member.queued_skill)
		"defend":
			member.defending = true
			message_label.text = "%s defends!" % member.display_name
		"item_potion": _do_item_potion(member)


func _do_attack(member: Combatant) -> void:
	var target: Combatant = _get_enemy_target(member)
	if target == null:
		return
	var dmg := maxi(1, (member.atk + member.atk_buff) - target.defense + randi_range(-2, 2))
	target.receive_damage(dmg)
	if member.max_qi > 0:
		member.qi = mini(member.max_qi, member.qi + 1)
	_update_ui()
	message_label.text = "%s attacks %s for %d!" % [member.display_name, target.display_name, dmg]
	if _enemies.filter(func(e): return e.is_alive()).is_empty():
		_end_battle(true)


func _do_skill(member: Combatant, skill: Dictionary) -> void:
	if skill["cost_type"] == "mp":
		member.mp -= int(skill["cost"])
	else:
		member.qi -= int(skill["cost"])

	var effect: String = skill["effect"]
	var power: int = int(skill["power"])

	match effect:
		"heal":
			var target: Combatant = _get_ally_target(member, skill)
			var amount: int = power + member.int_stat / 2
			target.hp = mini(target.max_hp, target.hp + amount)
			_update_ui()
			message_label.text = "%s uses %s!\n%s restored %d HP!" % [member.display_name, skill["name"], target.display_name, amount]

		"holy", "fire", "ice", "lightning", "earth":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 + randi_range(-2, 2))
			target.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s on %s for %d!" % [member.display_name, skill["name"], target.display_name, dmg]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"holy_stun":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 + randi_range(-2, 2))
			target.receive_damage(dmg)
			var stunned := false
			if not target.is_ko and randi() % 100 < 40:
				target.is_stunned = true
				target.stun_rounds = 1
				stunned = true
			_update_ui()
			var suffix := " Stunned!" if stunned else ""
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"holy_wrath":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 + randi_range(-3, 3))
			target.receive_damage(dmg)
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			var suffix := " Stunned!" if not target.is_ko else ""
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"guard":
			var target: Combatant = _get_ally_target(member, skill)
			target.def_buff = int(power)
			target.def_buff_rounds = 2
			_update_ui()
			message_label.text = "%s uses %s on %s!\nDEF +%d for 2 rounds!" % [member.display_name, skill["name"], target.display_name, power]

		"taunt":
			member.taunt_rounds = 1
			_update_ui()
			message_label.text = "%s taunts!\nAll enemies must attack %s!" % [member.display_name, member.display_name]

		"fortify":
			for ally in _party:
				if ally.is_alive():
					ally.def_buff = maxi(ally.def_buff, int(power))
					ally.def_buff_rounds = 2
			_update_ui()
			message_label.text = "%s uses %s!\nAll allies gain DEF for 2 rounds!" % [member.display_name, skill["name"]]

		"divine_shield":
			for ally in _party:
				if ally.is_alive():
					ally.def_buff = maxi(ally.def_buff, int(power))
					ally.def_buff_rounds = 2
			_update_ui()
			message_label.text = "%s raises %s!\nParty DEF increased for 2 rounds!" % [member.display_name, skill["name"]]

		"battle_hymn":
			for ally in _party:
				if ally.is_alive():
					ally.atk_buff = maxi(ally.atk_buff, int(power))
					ally.atk_buff_rounds = 2
			_update_ui()
			message_label.text = "%s sings %s!\nAll allies gain ATK for 2 rounds!" % [member.display_name, skill["name"]]

		"consecrate":
			var alive_enemies: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies:
				var dmg: int = maxi(1, power + member.int_stat / 2 + randi_range(-2, 2))
				enemy.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies take holy damage!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"sanctuary":
			var target: Combatant = _get_ally_target(member, skill)
			target.sanctuary = true
			_update_ui()
			message_label.text = "%s casts %s on %s!\nNext hit on them is nullified!" % [member.display_name, skill["name"], target.display_name]

		"purify":
			var target: Combatant = _get_ally_target(member, skill)
			target.is_stunned = false
			target.stun_rounds = 0
			_update_ui()
			message_label.text = "%s uses %s on %s!\nAll status effects cleared!" % [member.display_name, skill["name"], target.display_name]

		"physical":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - target.defense + randi_range(-2, 2))
			target.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s on %s for %d!" % [member.display_name, skill["name"], target.display_name, dmg]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"sweep":
			var alive_enemies: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies:
				var dmg: int = maxi(1, power + member.atk / 2 - enemy.defense + randi_range(-2, 2))
				enemy.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies take damage!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"stun_phys":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			message_label.text = "%s uses %s!\n%s is stunned!" % [member.display_name, skill["name"], target.display_name]

		"ki_burst":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk - target.defense / 2 + randi_range(-2, 2))
			target.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s on %s for %d!" % [member.display_name, skill["name"], target.display_name, dmg]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"multi_hit":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var total := 0
			for _h in 3:
				if target.is_alive():
					var dmg: int = maxi(1, power + member.atk / 2 - target.defense + randi_range(-1, 1))
					target.receive_damage(dmg)
					total += dmg
			_update_ui()
			message_label.text = "%s uses %s!\n3 hits on %s — %d total!" % [member.display_name, skill["name"], target.display_name, total]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"cripple":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - target.defense + randi_range(-1, 1))
			target.receive_damage(dmg)
			if not target.is_ko:
				target.agi_debuff = target.agi / 2
				target.agi_debuff_rounds = 2
			_update_ui()
			message_label.text = "%s uses %s on %s for %d!\nAGI halved for 2 rounds!" % [member.display_name, skill["name"], target.display_name, dmg]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"heal_all":
			var amount: int = power + member.int_stat / 2
			for ally in _party:
				if ally.is_alive():
					ally.hp = mini(ally.max_hp, ally.hp + amount)
			_update_ui()
			message_label.text = "%s uses %s!\nAll allies restored %d HP!" % [member.display_name, skill["name"], amount]

		"rising_dragon":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - target.defense + randi_range(-3, 3))
			target.receive_damage(dmg)
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			var suffix := " Stunned!" if not target.is_ko else ""
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)


func _do_item_potion(member: Combatant) -> void:
	var amount := 50
	member.hp = mini(member.max_hp, member.hp + amount)
	_update_ui()
	message_label.text = "%s uses Potion!\nRestores %d HP!" % [member.display_name, amount]


func _execute_enemy_turn(enemy: Combatant) -> void:
	var targets: Array = _party.filter(func(c): return c.is_alive())
	if targets.is_empty():
		return

	# Taunt forces all enemies to target the taunting member
	var target: Combatant = null
	for m in _party:
		if m.is_alive() and m.taunt_rounds > 0:
			target = m
			break
	if target == null:
		target = targets[randi() % targets.size()]

	# Sanctuary nullifies the hit entirely
	if target.sanctuary:
		target.sanctuary = false
		_update_ui()
		message_label.text = "%s's Sanctuary absorbs\n%s's attack!" % [target.display_name, enemy.display_name]
		return

	var effective_def := target.defense + target.def_buff
	var def_val := effective_def * 2 if target.defending else effective_def
	var dmg := maxi(1, enemy.atk - def_val + randi_range(-1, 1))
	target.receive_damage(dmg)
	var suffix := " (reduced!)" if target.defending else ""
	_update_ui()
	message_label.text = "%s hits %s for %d%s!" % [enemy.display_name, target.display_name, dmg, suffix]
	if _party.filter(func(c): return c.is_alive()).is_empty():
		_end_battle(false)


func _tick_buffs() -> void:
	for c in _party + _enemies:
		if c.def_buff_rounds > 0:
			c.def_buff_rounds -= 1
			if c.def_buff_rounds <= 0:
				c.def_buff = 0
		if c.atk_buff_rounds > 0:
			c.atk_buff_rounds -= 1
			if c.atk_buff_rounds <= 0:
				c.atk_buff = 0
		if c.agi_debuff_rounds > 0:
			c.agi_debuff_rounds -= 1
			if c.agi_debuff_rounds <= 0:
				c.agi_debuff = 0
		if c.taunt_rounds > 0:
			c.taunt_rounds -= 1


func _end_battle(victory: bool) -> void:
	state = State.BATTLE_OVER
	action_menu.visible = false
	selection_header.text = ""
	if victory:
		_level_up_queue = []
		var total_xp: int = 0
		for e in _enemies:
			total_xp += e.xp_reward
		for member in _party:
			if member.gain_xp(total_xp):
				_level_up_queue.append(_build_levelup_text(member))
		_update_ui()
		message_label.text = "Victory! +%d XP\nPress Enter." % total_xp
	else:
		message_label.text = "The party has fallen...\nPress Enter."


func _build_levelup_text(member: Combatant) -> String:
	var g: Dictionary = Combatant.LEVEL_GAINS.get(member.char_class, {})
	var line2 := "HP+%d ATK+%d DEF+%d AGI+%d" % [g.get("hp", 0), g.get("atk", 0), g.get("def", 0), g.get("agi", 0)]
	var line3 := "INT+%d" % g.get("int", 0)
	if g.get("mp", 0) > 0:
		line3 = "MP+%d %s" % [g.get("mp", 0), line3]
	return "%s reached Level %d!\n%s\n%s  Press Enter." % [member.display_name, member.level, line2, line3]


func _clamp_skill_scroll() -> void:
	if _menu_state != MenuState.SKILL:
		return
	var page: int = _option_labels.size()
	if _menu_cursor < _skill_scroll:
		_skill_scroll = _menu_cursor
	elif _menu_cursor >= _skill_scroll + page:
		_skill_scroll = _menu_cursor - page + 1


func _update_menu() -> void:
	action_menu.visible = true
	var page: int = _option_labels.size()
	for i in page:
		var idx: int = (_skill_scroll + i) if _menu_state == MenuState.SKILL else i
		if idx < _menu_options.size():
			_option_labels[i].text = ("> " if idx == _menu_cursor else "  ") + _menu_options[idx]
			_option_labels[i].visible = true
		else:
			_option_labels[i].text = ""
			_option_labels[i].visible = false


func _update_selection_header() -> void:
	if _selecting_index >= _party.size():
		return
	var member: Combatant = _party[_selecting_index]
	if member.char_class == "Ryn":
		var pips := ""
		for i in member.max_qi:
			pips += "●" if i < member.qi else "○"
		selection_header.text = "%s: %s" % [member.display_name, pips]
	elif member.max_mp > 0:
		selection_header.text = "%s: %d/%d MP" % [member.display_name, member.mp, member.max_mp]
	else:
		selection_header.text = member.display_name + ":"


func _update_enemy_ui() -> void:
	for i in _enemies.size():
		if i >= _enemy_labels.size():
			break
		var enemy: Combatant = _enemies[i]
		var label: Label = _enemy_labels[i]
		var bar: ColorRect = _enemy_hp_bars[i]
		var pct: float = float(enemy.hp) / float(enemy.max_hp) if not enemy.is_ko else 0.0

		if enemy.is_ko:
			label.text = "  %s  ---" % enemy.display_name
			label.modulate = Color(0.5, 0.5, 0.5)
			bar.size.x = 0.0
		elif _menu_state == MenuState.TARGETING and i == _target_index:
			label.text = "> %s" % enemy.display_name
			label.modulate = Color(1.0, 1.0, 0.3)
			bar.size.x = 207.0 * pct
			bar.color = Color(1.0, 1.0, 0.3, 1)
		else:
			label.text = "  %s" % enemy.display_name
			label.modulate = Color(1.0, 1.0, 1.0)
			bar.size.x = 207.0 * pct
			bar.color = Color(0.85, 0.25, 0.25, 1)


func _update_ui() -> void:
	_update_enemy_ui()
	for i in _party.size():
		var member: Combatant = _party[i]
		var label: Label = _party_hp_labels[i]
		var pct: float = float(member.hp) / float(member.max_hp) if member.max_hp > 0 else 0.0
		var label_tint: Color
		var bar_tint: Color

		var name_str: String
		if _menu_state == MenuState.ALLY_TARGETING:
			name_str = ("> " if i == _target_ally_index else "  ") + member.display_name
		else:
			name_str = member.display_name

		if member.is_ko:
			label.text = "%s L%d  --/--" % [name_str, member.level]
			label_tint = Color(0.5, 0.5, 0.5)
			bar_tint   = Color(0.5, 0.5, 0.5)
		else:
			label.text = "%s L%d  %d/%d" % [name_str, member.level, member.hp, member.max_hp]
			if pct > 0.5:
				label_tint = Color(1.0, 1.0, 1.0)
				bar_tint   = Color(0.3, 0.9, 0.3)
			elif pct > 0.25:
				label_tint = Color(1.0, 0.85, 0.1)
				bar_tint   = Color(1.0, 0.85, 0.1)
			else:
				label_tint = Color(1.0, 0.35, 0.35)
				bar_tint   = Color(1.0, 0.35, 0.35)

		if _menu_state == MenuState.ALLY_TARGETING and i == _target_ally_index and not member.is_ko:
			label_tint = Color(1.0, 1.0, 0.3)

		label.modulate = label_tint
		if i < _party_hp_bars.size():
			_party_hp_bars[i].value    = pct * 100.0
			_party_hp_bars[i].modulate = bar_tint
