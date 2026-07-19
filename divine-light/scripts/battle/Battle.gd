extends Node2D

enum State { SELECTING, RESOLVING, BATTLE_OVER }
enum MenuState { MAIN, SKILL, ITEM, TARGETING }

const CLASS_SKILLS: Dictionary = {
	"Vael": [
		{"name": "Holy Light", "cost": 10, "cost_type": "mp", "target": "ally",  "effect": "heal",     "power": 25},
		{"name": "Smite",      "cost": 8,  "cost_type": "mp", "target": "enemy", "effect": "holy",     "power": 15},
	],
	"Ryn": [
		{"name": "Iron Fist",   "cost": 1, "cost_type": "qi", "target": "enemy", "effect": "physical", "power": 18},
	],
	"Lyra": [
		{"name": "Ember",       "cost": 8, "cost_type": "mp", "target": "enemy", "effect": "fire",     "power": 14},
	],
	"Silas": [
		{"name": "Quick Strike","cost": 5, "cost_type": "mp", "target": "enemy", "effect": "physical", "power": 12},
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

# Targeting
var _target_index: int = 0
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
	var row_h := 22.0  # 14px label + 4px bar + 4px gap

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

		# HP bar: background + fill as ColorRects (respect size directly, no theme minimum)
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


func _handle_menu_input() -> void:
	if _menu_state == MenuState.TARGETING:
		_handle_target_input()
		return
	if Input.is_action_just_pressed("ui_down"):
		_menu_cursor = (_menu_cursor + 1) % _menu_options.size()
		_update_menu()
	elif Input.is_action_just_pressed("ui_up"):
		_menu_cursor = (_menu_cursor - 1 + _menu_options.size()) % _menu_options.size()
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
	_update_enemy_ui()


func _open_skill_menu(member: Combatant) -> void:
	_active_skills = CLASS_SKILLS.get(member.char_class, [])
	if _active_skills.is_empty():
		message_label.text = "No skills learned yet."
		return
	_menu_state = MenuState.SKILL
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


func _confirm_target() -> void:
	var member: Combatant = _party[_selecting_index]
	member.queued_action = _pending_action
	member.queued_skill = _pending_skill
	member.queued_target = _target_index
	_advance_selection()
	_update_enemy_ui()


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
	if skill["target"] == "ally":
		member.queued_action = "skill"
		member.queued_skill = skill
		member.queued_target = -1
		_advance_selection()
	else:
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
	_turn_queue.sort_custom(func(a, b): return a.agi > b.agi)
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
		_begin_selection()
		return
	var combatant: Combatant = _turn_queue.pop_front()
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
	var dmg := maxi(1, member.atk - target.defense + randi_range(-2, 2))
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

	if effect == "heal":
		var alive: Array = _party.filter(func(c): return c.is_alive())
		alive.sort_custom(func(a, b): return float(a.hp) / a.max_hp < float(b.hp) / b.max_hp)
		var target: Combatant = alive[0]
		var amount: int = power + member.int_stat / 2
		target.hp = mini(target.max_hp, target.hp + amount)
		_update_ui()
		message_label.text = "%s uses %s!\n%s restores %d HP!" % [member.display_name, skill["name"], target.display_name, amount]
	else:
		var target: Combatant = _get_enemy_target(member)
		if target == null:
			return
		var dmg: int
		if effect in ["holy", "fire", "ice", "lightning", "earth"]:
			dmg = maxi(1, power + member.int_stat / 2 + randi_range(-2, 2))
		else:
			dmg = maxi(1, power + member.atk / 2 - target.defense + randi_range(-2, 2))
		target.receive_damage(dmg)
		_update_ui()
		message_label.text = "%s uses %s on %s for %d!" % [member.display_name, skill["name"], target.display_name, dmg]
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


func _update_menu() -> void:
	action_menu.visible = true
	for i in _option_labels.size():
		if i < _menu_options.size():
			_option_labels[i].text = ("> " if i == _menu_cursor else "  ") + _menu_options[i]
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
		if member.is_ko:
			label.text = "%s L%d  --/--" % [member.display_name, member.level]
			label_tint = Color(0.5, 0.5, 0.5)
			bar_tint   = Color(0.5, 0.5, 0.5)
		else:
			label.text = "%s L%d  %d/%d" % [member.display_name, member.level, member.hp, member.max_hp]
			if pct > 0.5:
				label_tint = Color(1.0, 1.0, 1.0)
				bar_tint   = Color(0.3, 0.9, 0.3)
			elif pct > 0.25:
				label_tint = Color(1.0, 0.85, 0.1)
				bar_tint   = Color(1.0, 0.85, 0.1)
			else:
				label_tint = Color(1.0, 0.35, 0.35)
				bar_tint   = Color(1.0, 0.35, 0.35)
		label.modulate = label_tint
		if i < _party_hp_bars.size():
			_party_hp_bars[i].value    = pct * 100.0
			_party_hp_bars[i].modulate = bar_tint
