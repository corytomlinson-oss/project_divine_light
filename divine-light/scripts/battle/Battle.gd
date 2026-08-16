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
		{"name": "Ki Blast",         "cost": 3, "cost_type": "qi", "target": "enemy",        "effect": "physical",     "power": 24, "min_level": 17, "ranged": true},
		{"name": "Mending Flow",     "cost": 4, "cost_type": "qi", "target": "ally_choose",  "effect": "heal",         "power": 55, "min_level": 20},
		{"name": "Storm Flurry",     "cost": 4, "cost_type": "qi", "target": "enemy",        "effect": "multi_hit",    "power": 12, "min_level": 23},
		{"name": "Crippling Strike", "cost": 4, "cost_type": "qi", "target": "enemy",        "effect": "cripple",      "power": 10, "min_level": 26},
		{"name": "Dragon's Maw",     "cost": 5, "cost_type": "qi", "target": "enemy",        "effect": "physical",     "power": 45, "min_level": 29},
		{"name": "Healing Wave",     "cost": 5, "cost_type": "qi", "target": "ally_all",     "effect": "heal_all",     "power": 40, "min_level": 32},
		{"name": "Rising Dragon",    "cost": 6, "cost_type": "qi", "target": "enemy",        "effect": "rising_dragon","power": 70, "min_level": 35},
	],
	"Silas": [
		{"name": "Quick Strike",  "cost": 5,  "cost_type": "mp", "target": "enemy",     "effect": "physical",    "power": 12, "min_level": 1},
		{"name": "Envenom",       "cost": 8,  "cost_type": "mp", "target": "enemy",     "effect": "poison",      "power": 10, "min_level": 4},
		{"name": "Shadow Strike", "cost": 12, "cost_type": "mp", "target": "enemy",     "effect": "physical",    "power": 32, "min_level": 7, "row_restrict": "front"},
		{"name": "Vanish",        "cost": 6,  "cost_type": "mp", "target": "self",      "effect": "vanish",      "power": 0,  "min_level": 10},
		{"name": "Lacerate",      "cost": 14, "cost_type": "mp", "target": "enemy",     "effect": "bleed",       "power": 14, "min_level": 13},
		{"name": "Smoke Bomb",    "cost": 12, "cost_type": "mp", "target": "enemy_all", "effect": "smoke_bomb",  "power": 0,  "min_level": 16},
		{"name": "Expose",        "cost": 8,  "cost_type": "mp", "target": "enemy",     "effect": "expose",      "power": 10, "min_level": 19},
		{"name": "Garrote",       "cost": 14, "cost_type": "mp", "target": "enemy",     "effect": "garrote",     "power": 0,  "min_level": 22},
		{"name": "Flurry",        "cost": 16, "cost_type": "mp", "target": "enemy",     "effect": "multi_hit",   "power": 14, "min_level": 25, "hits": 4},
		{"name": "Toxic Cloud",   "cost": 22, "cost_type": "mp", "target": "enemy_all", "effect": "toxic_cloud", "power": 12, "min_level": 28},
		{"name": "Death Mark",    "cost": 20, "cost_type": "mp", "target": "enemy",     "effect": "death_mark",  "power": 18, "min_level": 31},
		{"name": "Shadowstep",    "cost": 35, "cost_type": "mp", "target": "enemy",     "effect": "shadowstep",  "power": 75, "min_level": 35},
	],
}

const LYRA_STANCES: Array = ["Fire", "Ice", "Lightning", "Earth"]

const LYRA_SKILLS: Dictionary = {
	"Fire": [
		{"name": "Ember",   "cost": 8,  "cost_type": "mp", "target": "enemy",     "effect": "fire",      "power": 14, "min_level": 1},
		{"name": "Flare",   "cost": 14, "cost_type": "mp", "target": "enemy",     "effect": "fire",      "power": 26, "min_level": 8},
		{"name": "Inferno", "cost": 24, "cost_type": "mp", "target": "enemy",     "effect": "fire_burn", "power": 38, "min_level": 24},
	],
	"Ice": [
		{"name": "Frost",    "cost": 8,  "cost_type": "mp", "target": "enemy",     "effect": "ice_slow",      "power": 14, "min_level": 4},
		{"name": "Blizzard", "cost": 16, "cost_type": "mp", "target": "enemy",     "effect": "ice_freeze",    "power": 28, "min_level": 14},
		{"name": "Glacier",  "cost": 26, "cost_type": "mp", "target": "enemy_all", "effect": "ice_freeze_aoe","power": 22, "min_level": 28},
	],
	"Lightning": [
		{"name": "Spark",         "cost": 8,  "cost_type": "mp", "target": "enemy",     "effect": "lightning",          "power": 16, "min_level": 6},
		{"name": "Bolt",          "cost": 18, "cost_type": "mp", "target": "enemy_all", "effect": "lightning_aoe",      "power": 18, "min_level": 18},
		{"name": "Thunderstrike", "cost": 30, "cost_type": "mp", "target": "enemy",     "effect": "lightning_paralyze", "power": 45, "min_level": 32},
	],
	"Earth": [
		{"name": "Tremor", "cost": 12, "cost_type": "mp", "target": "enemy",     "effect": "earth",        "power": 24, "min_level": 10},
		{"name": "Quake",  "cost": 22, "cost_type": "mp", "target": "enemy_all", "effect": "earth_sunder", "power": 20, "min_level": 22},
	],
}

const ITEM_DEFS: Dictionary = {
	"Potion":   {"name": "Potion",   "effect": "item_heal",       "power": 50,  "target": "ally_choose"},
	"Elixir":   {"name": "Elixir",   "effect": "item_heal",       "power": 120, "target": "ally_choose"},
	"Ether":    {"name": "Ether",    "effect": "item_restore_mp", "power": 30,  "target": "ally_choose"},
	"Antidote": {"name": "Antidote", "effect": "item_cure_poison","power": 0,   "target": "ally_choose"},
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

# Placeholder stat-only roster for the Milestone 13a test dungeon (The Cathedral).
# The README's Fallen Priest/Cursed Paladin/Shadow Acolyte roles (debuff DEF,
# stun, buff allies) need an enemy-ability system that doesn't exist yet, so
# these are differentiated by stats only for now. Full behavior is Milestone
# 19a's job when the Cathedral's real content gets built.
const CATHEDRAL_ENCOUNTERS: Array = [
	[{"name": "Fallen Priest",  "hp": 45, "atk": 9,  "def": 3, "agi":  8, "xp": 30}],
	[{"name": "Cursed Paladin", "hp": 90, "atk": 10, "def": 9, "agi":  5, "xp": 40}],
	[{"name": "Shadow Acolyte", "hp": 40, "atk": 6,  "def": 4, "agi": 10, "xp": 28},
	 {"name": "Shadow Acolyte", "hp": 40, "atk": 6,  "def": 4, "agi": 10, "xp": 28}],
	[{"name": "Fallen Priest",  "hp": 45, "atk": 9,  "def": 3, "agi":  8, "xp": 30},
	 {"name": "Cursed Paladin", "hp": 90, "atk": 10, "def": 9, "agi":  5, "xp": 40}],
	[{"name": "Cursed Paladin", "hp": 90, "atk": 10, "def": 9, "agi":  5, "xp": 40},
	 {"name": "Shadow Acolyte", "hp": 40, "atk": 6,  "def": 4, "agi": 10, "xp": 28},
	 {"name": "Fallen Priest",  "hp": 45, "atk": 9,  "def": 3, "agi":  8, "xp": 30}],
]

const ENCOUNTER_TABLES: Dictionary = {
	"overworld": ENCOUNTERS,
	"cathedral": CATHEDRAL_ENCOUNTERS,
}

# Milestone 14 test boss for the Cathedral's generated boss room. A stand-in,
# not the real Fallen Guardian (that's Milestone 19a's job, with its own
# 2-phase kit: physical+self-DEF-buff -> corrupted holy magic). This one
# exists to prove the generic system - visible/fixed encounter, phase
# transition, escape lockout, bonus XP - works end to end.
const BOSS_ENCOUNTERS: Dictionary = {
	"cathedral": {
		"name": "Hollow Warden", "hp": 220, "atk": 14, "def": 8, "agi": 9, "xp": 300,
		"phase_hp_thresholds": [0.5],
	},
}

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
var _active_items: Array = []
var _list_scroll: int = 0

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
	GameManager.party_loaded.connect(_update_ui)
	_update_ui()
	_begin_selection()


func _generate_encounter() -> Array:
	if GameManager.pending_boss_battle:
		GameManager.pending_boss_battle = false
		var boss_data: Dictionary = BOSS_ENCOUNTERS.get(GameManager.current_location, {})
		if not boss_data.is_empty():
			var boss: Combatant = _build_enemy(boss_data)
			boss.is_boss = true
			boss.phase_hp_thresholds = boss_data.get("phase_hp_thresholds", []).duplicate()
			return [boss]
	var table: Array = ENCOUNTER_TABLES.get(GameManager.current_location, ENCOUNTERS)
	var group: Array = table[randi() % table.size()]
	var result: Array = []
	for data in group:
		result.append(_build_enemy(data))
	return result


func _build_enemy(data: Dictionary) -> Combatant:
	var e := Combatant.new(data["name"], int(data["hp"]), int(data["atk"]), int(data["def"]), int(data["agi"]), true)
	e.xp_reward = int(data["xp"])
	return e


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
		elif event.keycode == KEY_F3:
			_debug_auto_win()


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
					get_tree().change_scene_to_file(GameManager.current_scene_path)


func _debug_level_all(direction: int) -> void:
	for member in _party:
		if direction > 0:
			member.level_up()
		else:
			member.level_down()
	_update_ui()
	message_label.text = "[DEBUG] Party level %d  (F1=up F2=down)" % _party[0].level


func _debug_auto_win() -> void:
	if state == State.BATTLE_OVER:
		return
	for e in _enemies:
		e.receive_damage(e.hp)
	_update_ui()
	_end_battle(true)


func _handle_menu_input() -> void:
	if _menu_state == MenuState.TARGETING:
		_handle_target_input()
		return
	if _menu_state == MenuState.ALLY_TARGETING:
		_handle_ally_target_input()
		return
	if Input.is_action_just_pressed("ui_down"):
		_menu_cursor = (_menu_cursor + 1) % _menu_options.size()
		_clamp_list_scroll()
		_update_menu()
	elif Input.is_action_just_pressed("ui_up"):
		_menu_cursor = (_menu_cursor - 1 + _menu_options.size()) % _menu_options.size()
		_clamp_list_scroll()
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
			member.queued_action = "swap_row"
			_advance_selection()
		5:
			_attempt_escape()


func _attempt_escape() -> void:
	if _enemies.any(func(e: Combatant) -> bool: return e.is_boss):
		message_label.text = "Can't escape from a boss battle!"
		return
	var party_total := 0
	var party_count := 0
	for m in _party:
		if m.is_alive():
			party_total += m.agi
			party_count += 1
	var enemy_total := 0
	var enemy_count := 0
	for e in _enemies:
		if e.is_alive():
			enemy_total += e.agi
			enemy_count += 1
	var avg_party: float = float(party_total) / max(1, party_count)
	var avg_enemy: float = float(enemy_total) / max(1, enemy_count)
	var chance: int = clampi(50 + roundi((avg_party - avg_enemy) * 2.0), 10, 90)
	if randi() % 100 < chance:
		get_tree().change_scene_to_file(GameManager.current_scene_path)
	else:
		message_label.text = "Couldn't escape!"


func _crit_chance(attacker: Combatant) -> int:
	return mini(50, attacker.agi / 4)


func _roll_crit(attacker: Combatant) -> bool:
	return randi() % 100 < _crit_chance(attacker)


const BACK_ROW_MOD: float = 0.75


func _row_mult(attacker: Combatant, defender: Combatant, ranged: bool = false) -> float:
	if ranged:
		return 1.0
	var mult := 1.0
	if not attacker.is_enemy and attacker.row == "back":
		mult *= BACK_ROW_MOD
	if not defender.is_enemy and defender.row == "back":
		mult *= BACK_ROW_MOD
	return mult


func _open_main_menu() -> void:
	_menu_state = MenuState.MAIN
	_menu_options = ["Attack", "Skill", "Item", "Defend", "Swap Row", "Run"]
	_menu_cursor = 0
	_list_scroll = 0
	_update_menu()
	_update_selection_header()
	_update_ui()


func _open_skill_menu(member: Combatant) -> void:
	if member.char_class == "Lyra":
		_open_lyra_skill_menu(member)
		return
	var all_skills: Array = CLASS_SKILLS.get(member.char_class, [])
	_active_skills = all_skills.filter(
		func(s):
			return member.level >= int(s.get("min_level", 1)) and (s.get("row_restrict", "") == "" or member.row == s["row_restrict"])
	)
	if _active_skills.is_empty():
		message_label.text = "No skills learned yet."
		return
	_menu_state = MenuState.SKILL
	_list_scroll = 0
	_menu_options = []
	for skill in _active_skills:
		var cost_label: String = "(%dQi)" % skill["cost"] if skill["cost_type"] == "qi" else "(%dMP)" % skill["cost"]
		_menu_options.append("%s %s" % [skill["name"], cost_label])
	_menu_cursor = 0
	_update_menu()
	selection_header.text = "-- Skills --"


func _open_lyra_skill_menu(member: Combatant) -> void:
	var current_stance: String = member.stance
	var stance_skills: Array = LYRA_SKILLS.get(current_stance, [])
	var filtered: Array = stance_skills.filter(func(s): return member.level >= int(s.get("min_level", 1)))
	_active_skills = []
	for skill in filtered:
		if skill["name"] == "Tremor" and member.row == "back":
			var back_row_tremor: Dictionary = skill.duplicate()
			back_row_tremor["name"] = "Tremor (AoE)"
			back_row_tremor["effect"] = "earth_aoe"
			back_row_tremor["power"] = 14
			back_row_tremor["target"] = "enemy_all"
			_active_skills.append(back_row_tremor)
		else:
			_active_skills.append(skill)
	for s in LYRA_STANCES:
		if s != current_stance:
			_active_skills.append({
				"name": "Switch: %s" % s, "cost": 0, "cost_type": "mp",
				"target": "self", "effect": "switch_stance", "power": 0,
				"to_stance": s, "min_level": 1,
			})
	_menu_state = MenuState.SKILL
	_list_scroll = 0
	_menu_options = []
	for skill in _active_skills:
		if skill["effect"] == "switch_stance":
			_menu_options.append(skill["name"])
		else:
			_menu_options.append("%s (%dMP)" % [skill["name"], skill["cost"]])
	_menu_cursor = 0
	_update_menu()
	selection_header.text = "-- %s Stance --" % current_stance


func _open_item_menu() -> void:
	_active_items = []
	for item_name in ITEM_DEFS.keys():
		var count: int = int(GameManager.inventory.get(item_name, 0))
		if count > 0:
			_active_items.append(ITEM_DEFS[item_name])
	if _active_items.is_empty():
		message_label.text = "No items available."
		return
	_menu_state = MenuState.ITEM
	_list_scroll = 0
	_menu_options = []
	for item_def in _active_items:
		var item_name: String = item_def["name"]
		var count: int = int(GameManager.inventory.get(item_name, 0))
		_menu_options.append("%s x%d" % [item_name, count])
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
	if _active_items.is_empty():
		return
	var item_def: Dictionary = _active_items[_menu_cursor]
	_enter_ally_targeting("item_use", item_def)


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
		_tick_dot()
		if _enemies.filter(func(e): return e.is_alive()).is_empty():
			_end_battle(true)
			return
		if _party.filter(func(c): return c.is_alive()).is_empty():
			_end_battle(false)
			return
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
		"item_use": _do_item(member, member.queued_skill)
		"swap_row":
			member.row = "back" if member.row == "front" else "front"
			_update_ui()
			message_label.text = "%s moves to the %s row!" % [member.display_name, member.row]


func _do_attack(member: Combatant) -> void:
	var target: Combatant = _get_enemy_target(member)
	if target == null:
		return
	var dmg := maxi(1, (member.atk + member.atk_buff) - (target.defense + target.def_buff) + randi_range(-2, 2))
	dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
	var crit := _roll_crit(member)
	if crit:
		dmg *= 2
	target.receive_damage(dmg)
	if member.max_qi > 0:
		member.qi = mini(member.max_qi, member.qi + 1)
	_update_ui()
	var crit_tag := " CRIT!" if crit else ""
	message_label.text = "%s attacks %s for %d!%s" % [member.display_name, target.display_name, dmg, crit_tag]
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
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-2, 2))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"holy_stun":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-2, 2))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			var stunned := false
			if not target.is_ko and randi() % 100 < 40:
				target.is_stunned = true
				target.stun_rounds = 1
				stunned = true
			_update_ui()
			var suffix := (" CRIT!" if crit else "") + (" Stunned!" if stunned else "")
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"holy_wrath":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-3, 3))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			var suffix := (" CRIT!" if crit else "") + (" Stunned!" if not target.is_ko else "")
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"guard":
			var target: Combatant = _get_ally_target(member, skill)
			var rounds: int = _buff_duration(member, 2)
			target.def_buff = int(power)
			target.def_buff_rounds = rounds
			_update_ui()
			message_label.text = "%s uses %s on %s!\nDEF +%d for %d rounds!" % [member.display_name, skill["name"], target.display_name, power, rounds]

		"taunt":
			member.taunt_rounds = 1
			_update_ui()
			message_label.text = "%s taunts!\nAll enemies must attack %s!" % [member.display_name, member.display_name]

		"fortify":
			var rounds: int = _buff_duration(member, 2)
			for ally in _party:
				if ally.is_alive():
					ally.def_buff = maxi(ally.def_buff, int(power))
					ally.def_buff_rounds = rounds
			_update_ui()
			message_label.text = "%s uses %s!\nAll allies gain DEF for %d rounds!" % [member.display_name, skill["name"], rounds]

		"divine_shield":
			var rounds: int = _buff_duration(member, 2)
			for ally in _party:
				if ally.is_alive() and ally.row == member.row:
					ally.def_buff = maxi(ally.def_buff, int(power))
					ally.def_buff_rounds = rounds
			_update_ui()
			message_label.text = "%s raises %s!\n%s row DEF increased for %d rounds!" % [member.display_name, skill["name"], member.row.capitalize(), rounds]

		"battle_hymn":
			var rounds: int = _buff_duration(member, 2)
			for ally in _party:
				if ally.is_alive():
					ally.atk_buff = maxi(ally.atk_buff, int(power))
					ally.atk_buff_rounds = rounds
			_update_ui()
			message_label.text = "%s sings %s!\nAll allies gain ATK for %d rounds!" % [member.display_name, skill["name"], rounds]

		"consecrate":
			var alive_enemies: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies:
				var dmg: int = maxi(1, power + member.int_stat / 2 - enemy.res_stat + randi_range(-2, 2))
				if _roll_crit(member):
					dmg *= 2
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
			target.poison_rounds = 0
			target.poison_power = 0
			target.bleed_rounds = 0
			target.bleed_power = 0
			_update_ui()
			message_label.text = "%s uses %s on %s!\nAll status effects cleared!" % [member.display_name, skill["name"], target.display_name]

		"physical":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-2, 2))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target, bool(skill.get("ranged", false)))))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"sweep":
			var alive_enemies: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies:
				var dmg: int = maxi(1, power + member.atk / 2 - (enemy.defense + enemy.def_buff) + randi_range(-2, 2))
				dmg = maxi(1, roundi(float(dmg) * _row_mult(member, enemy)))
				if _roll_crit(member):
					dmg *= 2
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
			var dmg: int = maxi(1, power + member.atk - (target.defense + target.def_buff) / 2 + randi_range(-2, 2))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"multi_hit":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var hits: int = int(skill.get("hits", 3))
			var total := 0
			var any_crit := false
			for _h in hits:
				if target.is_alive():
					var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-1, 1))
					dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
					if _roll_crit(member):
						dmg *= 2
						any_crit = true
					target.receive_damage(dmg)
					total += dmg
			_update_ui()
			var crit_tag := " CRIT!" if any_crit else ""
			message_label.text = "%s uses %s!\n%d hits on %s — %d total!%s" % [member.display_name, skill["name"], hits, target.display_name, total, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"cripple":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-1, 1))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.agi_debuff = target.agi / 2
				target.agi_debuff_rounds = 2
			_update_ui()
			var crit_tag2 := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s\nAGI halved for 2 rounds!" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag2]
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
			var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-3, 3))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			var suffix := (" CRIT!" if crit else "") + (" Stunned!" if not target.is_ko else "")
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"switch_stance":
			member.stance = skill["to_stance"]
			_update_ui()
			message_label.text = "%s declares the %s stance!" % [member.display_name, skill["to_stance"]]

		"fire_burn":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-2, 2))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			var burned := false
			if not target.is_ko:
				target.burn_rounds = 3
				target.burn_power = 8 + member.int_stat / 4
				burned = true
			_update_ui()
			var suffix2 := (" CRIT!" if crit else "") + (" Burning!" if burned else "")
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix2]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"ice_slow":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-2, 2))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.agi_debuff = target.agi / 2
				target.agi_debuff_rounds = 1
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s\nAGI lowered for 1 round!" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"ice_freeze":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-2, 2))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			var frozen := false
			if not target.is_ko and randi() % 100 < 40:
				target.is_stunned = true
				target.stun_rounds = 1
				frozen = true
			_update_ui()
			var suffix3 := (" CRIT!" if crit else "") + (" Frozen!" if frozen else "")
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix3]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"ice_freeze_aoe":
			var alive_enemies_ice: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies_ice:
				var dmg: int = maxi(1, power + member.int_stat / 2 - enemy.res_stat + randi_range(-2, 2))
				if _roll_crit(member):
					dmg *= 2
				enemy.receive_damage(dmg)
				if not enemy.is_ko and randi() % 100 < 40:
					enemy.is_stunned = true
					enemy.stun_rounds = 1
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies take ice damage, chance to freeze!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"lightning_aoe":
			var alive_enemies_lt: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies_lt:
				var dmg: int = maxi(1, power + member.int_stat / 2 - enemy.res_stat + randi_range(-2, 2))
				if _roll_crit(member):
					dmg *= 2
				enemy.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies take lightning damage!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"lightning_paralyze":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.int_stat / 2 - target.res_stat + randi_range(-3, 3))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			var suffix4 := (" CRIT!" if crit else "") + (" Paralyzed!" if not target.is_ko else "")
			message_label.text = "%s uses %s on %s for %d!%s" % [member.display_name, skill["name"], target.display_name, dmg, suffix4]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"earth_sunder":
			var alive_enemies_eq: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies_eq:
				var dmg: int = maxi(1, power + member.int_stat / 2 - enemy.res_stat + randi_range(-2, 2))
				if _roll_crit(member):
					dmg *= 2
				enemy.receive_damage(dmg)
				if not enemy.is_ko:
					enemy.def_buff = -12
					enemy.def_buff_rounds = 2
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies take earth damage, DEF lowered!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"earth_aoe":
			var alive_enemies_tr: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies_tr:
				var dmg: int = maxi(1, power + member.int_stat / 2 - enemy.res_stat + randi_range(-2, 2))
				if _roll_crit(member):
					dmg *= 2
				enemy.receive_damage(dmg)
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies take reduced earth damage!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"poison":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-2, 2))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.poison_rounds = 3
				target.poison_power = 8 + member.atk / 6
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s\nPoisoned for 3 rounds!" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"bleed":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-2, 2))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.bleed_rounds = 4
				target.bleed_power = 10 + member.atk / 5
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses %s on %s for %d!%s\nBleeding for 4 rounds! (Purify only)" % [member.display_name, skill["name"], target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"vanish":
			member.evasion_rounds = 1
			member.row = "back"
			_update_ui()
			message_label.text = "%s vanishes into the shadows!\nMoves to the back row, evasion increased!" % member.display_name

		"smoke_bomb":
			var alive_enemies_sb: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies_sb:
				enemy.accuracy_debuff_rounds = 2
			_update_ui()
			message_label.text = "%s throws a smoke bomb!\nAll enemies' accuracy is lowered!" % member.display_name

		"expose":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			if not target.is_ko:
				target.def_buff = -int(power)
				target.def_buff_rounds = 3
			_update_ui()
			message_label.text = "%s exposes %s's weak point!\nDEF lowered — party deals bonus damage!" % [member.display_name, target.display_name]

		"garrote":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			if not target.is_ko:
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			message_label.text = "%s uses %s!\n%s is stunned!" % [member.display_name, skill["name"], target.display_name]

		"toxic_cloud":
			var alive_enemies_tc: Array = _enemies.filter(func(e): return e.is_alive())
			for enemy in alive_enemies_tc:
				var dmg: int = maxi(1, power + member.atk / 2 - (enemy.defense + enemy.def_buff) + randi_range(-2, 2))
				dmg = maxi(1, roundi(float(dmg) * _row_mult(member, enemy)))
				if _roll_crit(member):
					dmg *= 2
				enemy.receive_damage(dmg)
				if not enemy.is_ko:
					enemy.poison_rounds = 3
					enemy.poison_power = 8 + member.atk / 6
			_update_ui()
			message_label.text = "%s uses %s!\nAll enemies poisoned!" % [member.display_name, skill["name"]]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)

		"death_mark":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			if not target.is_ko:
				target.def_buff = -int(power)
				target.def_buff_rounds = 3
			_update_ui()
			message_label.text = "%s marks %s for death!\nThey take increased damage for 3 rounds!" % [member.display_name, target.display_name]

		"shadowstep":
			var target: Combatant = _get_enemy_target(member)
			if target == null:
				return
			var dmg: int = maxi(1, power + member.atk / 2 - (target.defense + target.def_buff) + randi_range(-3, 3))
			dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
			var crit := _roll_crit(member)
			if crit:
				dmg *= 2
			target.receive_damage(dmg)
			if not target.is_ko:
				target.poison_rounds = 3
				target.poison_power = 10 + member.atk / 6
				target.bleed_rounds = 4
				target.bleed_power = 12 + member.atk / 5
				target.is_stunned = true
				target.stun_rounds = 1
			_update_ui()
			var crit_tag := " CRIT!" if crit else ""
			message_label.text = "%s uses Shadowstep on %s for %d!%s\nPoisoned, Bleeding, and Stunned!" % [member.display_name, target.display_name, dmg, crit_tag]
			if _enemies.filter(func(e): return e.is_alive()).is_empty():
				_end_battle(true)


func _do_item(member: Combatant, item_def: Dictionary) -> void:
	var item_name: String = item_def["name"]
	var count: int = int(GameManager.inventory.get(item_name, 0))
	if count <= 0:
		message_label.text = "No %s left!" % item_name
		return
	GameManager.inventory[item_name] = count - 1

	var target: Combatant = _get_ally_target(member, item_def)
	var effect: String = item_def["effect"]
	var power: int = int(item_def["power"])

	match effect:
		"item_heal":
			target.hp = mini(target.max_hp, target.hp + power)
			_update_ui()
			message_label.text = "%s uses %s on %s!\nRestored %d HP!" % [member.display_name, item_name, target.display_name, power]
		"item_restore_mp":
			target.mp = mini(target.max_mp, target.mp + power)
			_update_ui()
			message_label.text = "%s uses %s on %s!\nRestored %d MP!" % [member.display_name, item_name, target.display_name, power]
		"item_cure_poison":
			target.poison_rounds = 0
			target.poison_power = 0
			_update_ui()
			message_label.text = "%s uses %s on %s!\nPoison cured!" % [member.display_name, item_name, target.display_name]


func _execute_enemy_turn(enemy: Combatant) -> void:
	var targets: Array = _party.filter(func(c): return c.is_alive())
	if targets.is_empty():
		return

	var phase_note := ""
	if enemy.is_boss:
		phase_note = _check_boss_phase_transition(enemy)

	# Taunt forces all enemies to target the taunting member
	var target: Combatant = null
	for m in _party:
		if m.is_alive() and m.taunt_rounds > 0:
			target = m
			break
	if target == null:
		target = targets[randi() % targets.size()]

	# Smoke Bomb: the enemy's own accuracy is lowered
	if enemy.accuracy_debuff_rounds > 0 and randi() % 100 < 30:
		_update_ui()
		message_label.text = phase_note + "%s's attack misses!" % enemy.display_name
		return

	# Vanish: target has increased evasion this round
	if target.evasion_rounds > 0 and randi() % 100 < 50:
		_update_ui()
		message_label.text = phase_note + "%s dodges %s's attack!" % [target.display_name, enemy.display_name]
		return

	# Sanctuary nullifies the hit entirely
	if target.sanctuary:
		target.sanctuary = false
		_update_ui()
		message_label.text = phase_note + "%s's Sanctuary absorbs\n%s's attack!" % [target.display_name, enemy.display_name]
		return

	var effective_def := target.defense + target.def_buff
	var def_val := effective_def * 2 if target.defending else effective_def
	var dmg := maxi(1, enemy.atk - def_val + randi_range(-1, 1))
	dmg = maxi(1, roundi(float(dmg) * _row_mult(enemy, target)))
	target.receive_damage(dmg)
	var suffix := " (reduced!)" if target.defending else ""
	if enemy.is_boss and enemy.boss_phase >= 1:
		target.def_buff = -4
		target.def_buff_rounds = 2
		suffix += " DEF lowered!"
	_update_ui()
	message_label.text = phase_note + "%s hits %s for %d%s!" % [enemy.display_name, target.display_name, dmg, suffix]
	if _party.filter(func(c): return c.is_alive()).is_empty():
		_end_battle(false)


## Boss fights get harder as they take damage, checked once per boss turn
## (not the instant a threshold is crossed) so it reads as "the boss recoils,
## then comes back stronger" rather than interrupting whatever just hit it.
## Returns a message prefix (with trailing newline) if a transition happened
## this turn, so the caller can fold it into whatever message it shows next
## instead of the transition note getting silently overwritten a line later.
## Milestone 14 test boss just permanently hits harder past the threshold -
## real bosses (Milestone 19a/22b-d) will want per-phase skill kits, which
## needs an enemy-ability dispatch system that doesn't exist yet.
func _check_boss_phase_transition(enemy: Combatant) -> String:
	if enemy.boss_phase >= enemy.phase_hp_thresholds.size():
		return ""
	var hp_frac: float = float(enemy.hp) / float(enemy.max_hp) if enemy.max_hp > 0 else 0.0
	if hp_frac > enemy.phase_hp_thresholds[enemy.boss_phase]:
		return ""
	enemy.boss_phase += 1
	enemy.atk += 6
	return "%s enters a new phase! Its attacks grow fiercer!\n" % enemy.display_name


## Milestone 15's one wired-up Full Set Bonus: Vael's Holy Guardian Set
## ("all buff skills last 1 extra round"). The other 11 sets in the design
## doc each change a different, specific skill's behavior and aren't
## implemented yet - add a check here (or a similarly-named helper) when
## each one is actually needed, same pattern as this one.
func _buff_duration(caster: Combatant, base_rounds: int) -> int:
	if Equipment.has_set_bonus(caster, "holy_guardian"):
		return base_rounds + int(Equipment.SET_BONUSES["holy_guardian"]["buff_duration_bonus"])
	return base_rounds


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
		if c.evasion_rounds > 0:
			c.evasion_rounds -= 1
		if c.accuracy_debuff_rounds > 0:
			c.accuracy_debuff_rounds -= 1


func _tick_dot() -> void:
	for c in _party + _enemies:
		if c.burn_rounds > 0 and c.is_alive():
			c.receive_damage(c.burn_power)
			c.burn_rounds -= 1
			if c.burn_rounds <= 0:
				c.burn_power = 0
		if c.poison_rounds > 0 and c.is_alive():
			c.receive_damage(c.poison_power)
			c.poison_rounds -= 1
			if c.poison_rounds <= 0:
				c.poison_power = 0
		if c.bleed_rounds > 0 and c.is_alive():
			c.receive_damage(c.bleed_power)
			c.bleed_rounds -= 1
			if c.bleed_rounds <= 0:
				c.bleed_power = 0
	_update_ui()


func _end_battle(victory: bool) -> void:
	state = State.BATTLE_OVER
	action_menu.visible = false
	selection_header.text = ""
	if victory:
		_level_up_queue = []
		var total_xp: int = 0
		for e in _enemies:
			total_xp += e.xp_reward
			if e.is_boss:
				GameManager.defeated_bosses[GameManager.current_location] = true
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


func _clamp_list_scroll() -> void:
	if _menu_state != MenuState.SKILL and _menu_state != MenuState.ITEM and _menu_state != MenuState.MAIN:
		return
	var page: int = _option_labels.size()
	if _menu_cursor < _list_scroll:
		_list_scroll = _menu_cursor
	elif _menu_cursor >= _list_scroll + page:
		_list_scroll = _menu_cursor - page + 1


func _update_menu() -> void:
	action_menu.visible = true
	var page: int = _option_labels.size()
	var scrollable: bool = _menu_state == MenuState.SKILL or _menu_state == MenuState.ITEM or _menu_state == MenuState.MAIN
	for i in page:
		var idx: int = (_list_scroll + i) if scrollable else i
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
	var row_label: String = "Front" if member.row == "front" else "Back"
	if member.char_class == "Ryn":
		var pips := ""
		for i in member.max_qi:
			pips += "●" if i < member.qi else "○"
		selection_header.text = "%s (%s): %s" % [member.display_name, row_label, pips]
	elif member.char_class == "Lyra":
		selection_header.text = "%s (%s) [%s]: %d/%d MP" % [member.display_name, row_label, member.stance, member.mp, member.max_mp]
	elif member.max_mp > 0:
		selection_header.text = "%s (%s): %d/%d MP" % [member.display_name, row_label, member.mp, member.max_mp]
	else:
		selection_header.text = "%s (%s):" % [member.display_name, row_label]


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
		var row_tag: String = "F" if member.row == "front" else "B"

		if member.is_ko:
			label.text = "%s %s L%d  --/--" % [name_str, row_tag, member.level]
			label_tint = Color(0.5, 0.5, 0.5)
			bar_tint   = Color(0.5, 0.5, 0.5)
		else:
			label.text = "%s %s L%d  %d/%d" % [name_str, row_tag, member.level, member.hp, member.max_hp]
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
