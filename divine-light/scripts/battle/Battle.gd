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

# Enemy stats, kits (abilities, attack modifiers, weaknesses) and encounter
# tables live in EnemyData.gd (Milestone 20a).

# Milestone 14's boss system: EnemyData.BOSSES by id, picked per location.
const LOCATION_BOSSES := {
	"cathedral": "fallen_guardian",
	"cathedral_escape": "hollow_warden",
}

const BATTLE_BACKGROUNDS: Dictionary = {
	"overworld": "res://assets/ui/battle_bg_forest.png",
}

# Battlefield (Milestone 17b, SNES layout): enemies on the left and the party on
# the right stand on the same ground, above the windows that start at y=112.
# Enemies spread evenly across ENEMY_FIELD_X (left, right edge), feet on
# ENEMY_FEET_Y; odd slots stand a step further back so a group reads as a
# formation instead of a lineup.
const ENEMY_FIELD_X := Vector2(12, 150)
const ENEMY_FEET_Y := 102.0
const ENEMY_BACK_STAGGER := 8.0

# Bottom windows. The left one (commands, or the enemy list) is at least
# LEFT_WINDOW_W wide - "Corrupted Farmer" is 92px - and the command window
# widens past it for long skill/item lists, over the party window.
const LEFT_WINDOW_W := 104.0
const ENEMY_LIST_BAR_W := 88.0
const HP_BAR_W := 50.0
const MP_BAR_W := 34.0
const BAR_TRACK := Color(0.16, 0.15, 0.22)
const HP_GREEN := Color(0.3, 0.9, 0.3)
const ENEMY_RED := Color(0.85, 0.25, 0.25)
const MP_TEXT := Color(0.67, 0.75, 1.0)
const MP_BLUE := Color(0.43, 0.55, 1.0)
const ROW_GREY := Color(0.63, 0.61, 0.72)
const TARGET_YELLOW := Color(1.0, 1.0, 0.3)

# Party formation: a diagonal line, FF6-style, stepping down and right per
# slot across the battlefield's right side. Slots are grouped by
# row - front-row members take the upper-left slots, back-row members the
# lower-right ones - so the back-row shift only ever widens the gap between the
# two groups. (Shifting back-row members within a fixed party-order line made
# them collide with whoever came next; any shift big enough to notice a row
# swap was bigger than the spacing.) The acting member steps toward the
# enemies. Values are each sprite's top-left corner.
const PARTY_ORIGIN := Vector2(214, 30)
const PARTY_STEP := Vector2(22, 16)
const PARTY_BACK_ROW_X := 18.0
const PARTY_STEP_FORWARD := 5.0
const PARTY_WALK_SPEED := 60.0

# Battle messages advance on their own (Milestone 17d), like the SNES games:
# a base pause plus a little per character, capped; A skips ahead. The
# end-of-battle messages (victory, level-ups) still wait for A.
const MESSAGE_BASE_TIME := 0.8
const MESSAGE_TIME_PER_CHAR := 0.02
const MESSAGE_MAX_TIME := 2.6

# Party
var _party: Array = []
# Party window rows, one entry per member (null where a member has no MP or Qi).
var _party_name_labels: Array = []
var _party_row_labels: Array = []
var _party_hp_labels: Array = []
var _party_hp_bars: Array = []
var _party_mp_labels: Array = []
var _party_mp_bars: Array = []
var _party_qi_pips: Array = []

# Enemies (built dynamically each battle)
var _enemies: Array = []
var _enemy_labels: Array = []
var _enemy_hp_bars: Array = []
var _enemy_sprites: Array = []
# Per-enemy animation state, parallel to _enemy_sprites: resting position (the
# point every tween returns to), last seen HP (a drop means "just got hit"),
# whether the death fade already played, and the running tween (killed before
# a new one starts, so a hit landing mid-lunge doesn't leave it off-position).
var _enemy_home: Array = []
var _enemy_last_hp: Array = []
var _enemy_death_shown: Array = []
var _enemy_tweens: Array = []
# Party battle sprites (parallel to _party; null for a member with no art).
# Same animation bookkeeping as the enemy arrays above, plus _party_acting:
# the member stepping forward, either choosing a command or taking a turn.
var _party_sprites: Array = []
var _party_last_hp: Array = []
var _party_ko_shown: Array = []
var _party_tweens: Array = []
var _party_acting: int = -1

# Battle state
var _selecting_index: int = 0
# Who has picked an action this round, and in what order - L1/R1 can choose
# members out of order, and B on the command menu steps back through this.
var _chosen: Array = []
var _chosen_order: Array = []
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

@onready var message_label: Label = $MessageBanner/MessageLabel
@onready var message_banner: PanelContainer = $MessageBanner
@onready var command_window: Panel = $CommandWindow
@onready var command_title: Label = $CommandWindow/Title
@onready var action_menu: VBoxContainer = $CommandWindow/ActionMenu
@onready var enemy_window: Panel = $EnemyWindow
@onready var party_window: Panel = $PartyWindow

var _cursor := MenuCursor.new()
var _scroll_hint := ScrollHint.new()
# Blinking arrow in the banner's corner while a message waits for A.
var _advance_hint := ScrollHint.new()
var _blink := 0.0
var _message_timer := 0.0
# Combat effects (Milestone 18). While an action's effect plays (_acting), the
# turn doesn't advance and its damage hasn't been applied yet.
var _fx := BattleFx.new()
var _acting := false
# The element of the party action being resolved ("" = physical) and whether
# it just hit a weakness (Milestone 20a).
var _skill_element := ""
var _weak_hit := false


func _ready() -> void:
	_option_labels = action_menu.get_children()
	_party = GameManager.party
	add_child(_cursor)
	command_window.add_child(_scroll_hint)
	add_child(_advance_hint)
	_setup_background()
	_setup_party_window()
	_enemies = _generate_encounter()
	var boss_fight: bool = _enemies.any(func(e: Combatant) -> bool: return e.is_boss)
	Music.play("boss" if boss_fight else "battle", "battle")
	_setup_enemy_ui()
	_setup_party_sprites()
	_setup_fx()
	GameManager.party_loaded.connect(_update_ui)
	_update_ui()
	_begin_selection()


func _generate_encounter() -> Array:
	if not GameManager.debug_encounter.is_empty():
		var forced: Array = []
		for data: Dictionary in GameManager.debug_encounter:
			var e := _build_enemy(data)
			e.is_boss = data.get("is_boss", false)
			e.phase_hp_thresholds = data.get("phase_hp_thresholds", []).duplicate()
			forced.append(e)
		GameManager.debug_encounter = []
		return forced
	if GameManager.pending_boss_battle:
		GameManager.pending_boss_battle = false
		var boss_data: Dictionary = EnemyData.BOSSES.get(LOCATION_BOSSES.get(GameManager.current_location, ""), {})
		if not boss_data.is_empty():
			var boss: Combatant = _build_enemy(boss_data)
			boss.is_boss = true
			boss.phase_hp_thresholds = boss_data.get("phase_hp_thresholds", []).duplicate()
			return [boss]
	var table: Array = EnemyData.ENCOUNTER_TABLES.get(GameManager.current_location, EnemyData.FOREST_ENCOUNTERS)
	# Groups sized to the party (Milestone 20a): at most one enemy more than
	# there are party members, so a lone hero at the start of Act I isn't
	# thrown against three at once.
	var fitting: Array = table.filter(func(g: Array) -> bool: return g.size() <= _party.size() + 1)
	if not fitting.is_empty():
		table = fitting
	var group: Array = table[randi() % table.size()]
	var result: Array = []
	for data in group:
		result.append(_build_enemy(data))
	return result


func _build_enemy(data: Dictionary) -> Combatant:
	var e := Combatant.new(data["name"], int(data["hp"]), int(data["atk"]), int(data["def"]), int(data["agi"]), true)
	e.xp_reward = int(data["xp"])
	var kit: Dictionary = EnemyData.kit(e.display_name)
	e.abilities = kit.get("abilities", [])
	e.attack_mods = kit.get("attack", {})
	e.weak = kit.get("weak", [])
	e.int_stat = int(kit.get("int", 0))
	e.res_stat = int(kit.get("res", 0))
	return e


## One row per member: name, row, HP numbers over a bar, then MP numbers over
## a bar or Ryn's Qi pips. Positions are local to the party window; the name
## keeps a two-space indent so the glove fits in front of it for ally targeting.
func _setup_party_window() -> void:
	for i in _party.size():
		var member: Combatant = _party[i]
		var y := 4.0 + i * 15.0
		_party_name_labels.append(_window_label(party_window, Vector2(8, y), 38))
		var row_label := _window_label(party_window, Vector2(46, y), 10)
		row_label.modulate = ROW_GREY
		_party_row_labels.append(row_label)
		_party_hp_labels.append(_window_label(party_window, Vector2(50, y), 60, HORIZONTAL_ALIGNMENT_RIGHT))
		_party_hp_bars.append(_window_bar(party_window, Vector2(60, y + 10), HP_BAR_W, HP_GREEN))
		# Status icons (18d) in the gap between the HP and MP columns.
		var icons := StatusIcons.new()
		icons.combatant = member
		icons.position = Vector2(113, y + 3)
		party_window.add_child(icons)
		if member.max_qi > 0:
			var pips := QiPips.new()
			pips.position = Vector2(166, y + 2)
			party_window.add_child(pips)
			_party_qi_pips.append(pips)
			_party_mp_labels.append(null)
			_party_mp_bars.append(null)
		else:
			_party_qi_pips.append(null)
			var mp_label := _window_label(party_window, Vector2(148, y), 60, HORIZONTAL_ALIGNMENT_RIGHT)
			mp_label.modulate = MP_TEXT
			_party_mp_labels.append(mp_label)
			_party_mp_bars.append(_window_bar(party_window, Vector2(174, y + 10), MP_BAR_W, MP_BLUE))


func _window_label(parent: Control, pos: Vector2, width: float, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = Vector2(width, 10)
	label.horizontal_alignment = align
	parent.add_child(label)
	return label


## A 3px bar (dark track + fill) inside a window. Returns the fill, whose
## width the caller sets from the value it shows.
func _window_bar(parent: Control, pos: Vector2, width: float, color: Color) -> ColorRect:
	var track := ColorRect.new()
	track.position = pos
	track.size = Vector2(width, 3)
	track.color = BAR_TRACK
	parent.add_child(track)
	var fill := ColorRect.new()
	fill.position = pos
	fill.size = Vector2(width, 3)
	fill.color = color
	parent.add_child(fill)
	return fill


func _setup_enemy_ui() -> void:
	_enemy_labels = []
	_enemy_hp_bars = []
	_enemy_sprites = []
	_enemy_home = []
	_enemy_last_hp = []
	_enemy_death_shown = []
	_enemy_tweens = []
	var count: int = _enemies.size()
	var slot_w: float = (ENEMY_FIELD_X.y - ENEMY_FIELD_X.x) / count
	for i in count:
		var cx: float = ENEMY_FIELD_X.x + slot_w * (i + 0.5)
		var feet: float = ENEMY_FEET_Y - (ENEMY_BACK_STAGGER if i % 2 == 1 else 0.0)
		var sprite: CanvasItem = _make_enemy_sprite(_enemies[i].display_name)
		if sprite == null:
			# No art for this enemy yet - keep the old placeholder block.
			var rect := ColorRect.new()
			rect.size = Vector2(24, 40)
			rect.position = Vector2(cx - 12.0, feet - 40.0)
			rect.color = Color(0.55, 0.12, 0.12, 1)
			sprite = rect
		else:
			# Centered sprite standing on its feet line, whatever its height.
			var h: float = (sprite as AnimatedSprite2D).sprite_frames.get_frame_texture(&"default", 0).get_height()
			sprite.position = Vector2(cx, feet - h / 2.0)
		$EnemyArea.add_child(sprite)
		# Status icons (18d) just above the sprite, riding along with it.
		var icons := StatusIcons.new()
		icons.combatant = _enemies[i]
		icons.centered = true
		if sprite is AnimatedSprite2D:
			var top: float = (sprite as AnimatedSprite2D).sprite_frames.get_frame_texture(&"default", 0).get_height() / 2.0
			icons.position = Vector2(0, -top - 8.0)
		else:
			icons.position = Vector2(12, -8)
		sprite.add_child(icons)
		_enemy_sprites.append(sprite)
		_enemy_home.append(sprite.position)
		_enemy_last_hp.append(_enemies[i].hp)
		_enemy_death_shown.append(false)
		_enemy_tweens.append(null)

		# Enemy window row: name with the HP bar under it.
		var y := 4.0 + i * 16.0
		var label := _window_label(enemy_window, Vector2(8, y), ENEMY_LIST_BAR_W)
		label.text = _enemies[i].display_name
		_enemy_labels.append(label)
		_enemy_hp_bars.append(_window_bar(enemy_window, Vector2(8, y + 10), ENEMY_LIST_BAR_W, ENEMY_RED))


func _setup_background() -> void:
	var path: String = BATTLE_BACKGROUNDS.get(GameManager.current_location, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var art := TextureRect.new()
	art.name = "BackgroundArt"
	art.texture = load(path)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	# Directly above the plain Background, below everything else.
	move_child(art, $Background.get_index() + 1)


## Each party member's overworld walk set doubles as their battle sprite: the
## side-view animations mirrored with flip_h to face the enemies on the left.
func _setup_party_sprites() -> void:
	var area := Node2D.new()
	area.name = "PartyArea"
	# Lower in the line draws in front, even mid-walk after a row swap.
	area.y_sort_enabled = true
	add_child(area)
	# Above the background and enemy area, below the message box and menus.
	move_child(area, $EnemyArea.get_index() + 1)
	_party_sprites = []
	_party_last_hp = []
	_party_ko_shown = []
	_party_tweens = []
	for i in _party.size():
		var member: Combatant = _party[i]
		var path := "res://assets/sprites/%s_frames.tres" % member.char_class.to_lower()
		var sprite: AnimatedSprite2D = null
		if ResourceLoader.exists(path):
			sprite = AnimatedSprite2D.new()
			sprite.sprite_frames = load(path)
			sprite.flip_h = true
			sprite.play(&"idle_side")
			sprite.position = _party_home(i)
			area.add_child(sprite)
		_party_sprites.append(sprite)
		_party_last_hp.append(member.hp)
		_party_ko_shown.append(false)
		_party_tweens.append(null)
	_animate_party_hp_changes(true)


## Effects draw above the fighters and below the windows; the battlefield
## (background art, enemies, party) is what shakes.
func _setup_fx() -> void:
	add_child(_fx)
	move_child(_fx, $PartyArea.get_index() + 1)
	for node_name in ["BackgroundArt", "EnemyArea", "PartyArea"]:
		var node := get_node_or_null(node_name)
		if node != null:
			_fx.shake_nodes.append(node)


## Member i's place in the line: front-row members first, then back-row
## members, each group in party order.
func _party_slot(i: int) -> int:
	var slot := 0
	var row: String = _party[i].row
	for j in _party.size():
		var other: String = _party[j].row
		if (other == "front" and row == "back") or (other == row and j < i):
			slot += 1
	return slot


## Where member i should stand right now (sprite center), from row and turn.
func _party_home(i: int) -> Vector2:
	var member: Combatant = _party[i]
	var pos := PARTY_ORIGIN + PARTY_STEP * _party_slot(i) + Vector2(8, 16)
	if member.row == "back":
		pos.x += PARTY_BACK_ROW_X
	if member.is_ko:
		pos.y += 8.0  # lying down: a 32x16 shape resting on the same feet line
	elif i == _party_acting:
		pos.x -= PARTY_STEP_FORWARD
	return pos


func _restart_party_tween(i: int) -> Tween:
	if _party_tweens[i] != null:
		_party_tweens[i].kill()
	var t := create_tween()
	_party_tweens[i] = t
	return t


## Hop toward the enemies and back, for attacks and offensive skills.
func _anim_party_attack(i: int) -> void:
	var sprite: AnimatedSprite2D = _party_sprites[i]
	if sprite == null:
		return
	var home := _party_home(i)
	sprite.position = home
	var t := _restart_party_tween(i)
	t.tween_property(sprite, "position", home - Vector2(8, 0), 0.08)
	t.tween_property(sprite, "position", home, 0.12)


## Same HP-diff approach as _animate_enemy_hp_changes(): hits flash and
## shake, KO tips the sprite over backward and darkens it, and a revive
## stands it back up. `instant` skips animation (battle start, e.g. a member
## who was already KO'd going in).
func _animate_party_hp_changes(instant: bool = false) -> void:
	for i in mini(_party.size(), _party_sprites.size()):
		var sprite: AnimatedSprite2D = _party_sprites[i]
		var member: Combatant = _party[i]
		if sprite == null:
			continue
		if member.is_ko and not _party_ko_shown[i]:
			_party_ko_shown[i] = true
			var t := _restart_party_tween(i)
			sprite.play(&"idle_side")
			if instant:
				sprite.rotation = PI / 2.0
				sprite.modulate = Color(0.45, 0.4, 0.55)
				sprite.position = _party_home(i)
			else:
				Sfx.play("hit")
				sprite.modulate = Color(2.5, 2.5, 2.5)
				t.set_parallel(true)
				t.tween_property(sprite, "rotation", PI / 2.0, 0.25)
				t.tween_property(sprite, "position", _party_home(i), 0.25)
				t.tween_property(sprite, "modulate", Color(0.45, 0.4, 0.55), 0.35)
		elif not member.is_ko and _party_ko_shown[i]:
			_party_ko_shown[i] = false
			var t := _restart_party_tween(i)
			t.set_parallel(true)
			t.tween_property(sprite, "rotation", 0.0, 0.2)
			t.tween_property(sprite, "position", _party_home(i), 0.2)
			t.tween_property(sprite, "modulate", Color.WHITE, 0.2)
		elif not member.is_ko and member.hp < _party_last_hp[i] and not instant:
			_tween_hurt(_restart_party_tween(i), sprite, _party_home(i))
			Sfx.play("hit")
		if not instant:
			_popup_hp_change(sprite, _party_last_hp[i] - member.hp)
		_party_last_hp[i] = member.hp


## Runs every frame: works out who is stepping forward, then walks any sprite
## that isn't mid-animation toward where it belongs (so row swaps, Vanish and
## turn changes all move smoothly without a hook in each of them).
func _update_party_positions(delta: float) -> void:
	if state == State.SELECTING:
		_party_acting = _selecting_index
	elif state != State.RESOLVING:
		_party_acting = -1
	for i in mini(_party.size(), _party_sprites.size()):
		var sprite: AnimatedSprite2D = _party_sprites[i]
		if sprite == null:
			continue
		var t: Tween = _party_tweens[i]
		if t != null and t.is_running():
			continue
		var target := _party_home(i)
		if sprite.position.is_equal_approx(target):
			if not _party[i].is_ko and sprite.animation != &"idle_side":
				sprite.play(&"idle_side")
			continue
		sprite.position = sprite.position.move_toward(target, PARTY_WALK_SPEED * delta)
		if not _party[i].is_ko:
			sprite.play(&"walk_side")


## Battle sprite for an enemy, from assets/sprites/enemies/<name_in_snake_case>.png
## (2 idle frames side by side, see assets/sprites/source/build_enemies.py).
## Returns null when an enemy has no art yet.
func _make_enemy_sprite(enemy_name: String) -> AnimatedSprite2D:
	var path := "res://assets/sprites/enemies/%s.png" % enemy_name.to_lower().replace(" ", "_")
	var stand_in: Dictionary = {}
	if not ResourceLoader.exists(path):
		stand_in = EnemyData.STAND_INS.get(enemy_name, {})
		if stand_in.is_empty():
			return null
		path = "res://assets/sprites/enemies/%s.png" % stand_in["sprite"]
	var tex: Texture2D = load(path)
	if stand_in.has("scale"):
		# Scale the image itself (not the node), so status icons and effect
		# positions attached to the sprite stay normal size.
		var k: int = stand_in["scale"]
		var img := tex.get_image()
		img.resize(img.get_width() * k, img.get_height() * k, Image.INTERPOLATE_NEAREST)
		tex = ImageTexture.create_from_image(img)
	var w := int(tex.get_width() / 2.0)
	var frames := SpriteFrames.new()
	frames.set_animation_speed(&"default", 2.0)
	for f in 2:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(f * w, 0, w, tex.get_height())
		frames.add_frame(&"default", atlas)
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	# Slightly different pace and phase per enemy, so a group of the same
	# enemy doesn't breathe in lockstep.
	sprite.speed_scale = randf_range(0.85, 1.15)
	sprite.play(&"default")
	sprite.frame_progress = randf()
	if stand_in.has("tint"):
		sprite.self_modulate = stand_in["tint"]
	return sprite


## Floating number over a fighter whose HP just changed (Milestone 17d): white
## for damage, green for healing. Called from the same HP-diff passes that
## drive the hurt/KO animations, so every source (attacks, skills, items,
## poison ticks) shows one without a hook of its own.
func _popup_hp_change(target: CanvasItem, damage: int) -> void:
	if damage == 0 or target == null:
		return
	var label := Label.new()
	label.text = str(absi(damage))
	label.add_theme_color_override("font_color", Color.WHITE if damage > 0 else Color(0.45, 1.0, 0.45))
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(40, 10)
	label.position = (_popup_anchor(target) - Vector2(20, 10)).round()
	# Keep it clear of the message banner (the top party slot sits under it):
	# below a 2-line banner (bottom y=31) even after floating up 8px. The
	# banner may not have resized to this turn's message yet, so don't use
	# its current size.
	if message_banner.visible:
		label.position.y = maxf(label.position.y, 40.0)
	add_child(label)
	# Drawn under the (opaque) banner, so a number that ends up behind a tall
	# message is hidden rather than printed over the text.
	move_child(label, message_banner.get_index())
	var t := create_tween()
	t.tween_property(label, "position:y", label.position.y - 8.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_interval(0.45)
	t.tween_property(label, "modulate:a", 0.0, 0.25)
	t.tween_callback(label.queue_free)


## Just above the top of a fighter's sprite (centered sprites) or placeholder
## block (ColorRect, top-left positioned).
func _popup_anchor(target: CanvasItem) -> Vector2:
	if target is Control:
		var rect := target as Control
		return rect.position + Vector2(rect.size.x / 2.0, 0)
	var sprite := target as AnimatedSprite2D
	var tex: Texture2D = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
	var half_h := tex.get_height() / 2.0 if tex != null else 16.0
	return sprite.position - Vector2(0, half_h)


func _restart_enemy_tween(i: int) -> Tween:
	if _enemy_tweens[i] != null:
		_enemy_tweens[i].kill()
	var sprite: CanvasItem = _enemy_sprites[i]
	sprite.position = _enemy_home[i]
	var t := create_tween()
	_enemy_tweens[i] = t
	return t


## Short hop toward the party when an enemy takes its turn.
func _anim_enemy_attack(i: int) -> void:
	if i < 0 or i >= _enemy_sprites.size():
		return
	var home: Vector2 = _enemy_home[i]
	var t := _restart_enemy_tween(i)
	t.tween_property(_enemy_sprites[i], "position", home + Vector2(6, 0), 0.08)
	t.tween_property(_enemy_sprites[i], "position", home, 0.12)


## White flash plus a quick side-to-side shake when an enemy loses HP.
func _anim_enemy_hurt(i: int) -> void:
	_tween_hurt(_restart_enemy_tween(i), _enemy_sprites[i], _enemy_home[i])


## Shared by enemies and party: white flash plus a quick side-to-side shake
## around `home`, played on the caller's (already reset) tween.
func _tween_hurt(t: Tween, sprite: CanvasItem, home: Vector2) -> void:
	sprite.modulate = Color(2.5, 2.5, 2.5)
	t.set_parallel(true)
	t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	var delay := 0.0
	for dx: int in [2, -2, 1, 0]:
		t.tween_property(sprite, "position", home + Vector2(dx, 0), 0.04).set_delay(delay)
		delay += 0.04


## The Unraveling takes it back: flash, then sink while fading to violet.
func _anim_enemy_death(i: int) -> void:
	var sprite: CanvasItem = _enemy_sprites[i]
	var t := _restart_enemy_tween(i)
	sprite.modulate = Color(2.5, 2.5, 2.5)
	t.tween_property(sprite, "modulate", Color(0.8, 0.35, 1.0, 1.0), 0.12)
	t.tween_property(sprite, "modulate", Color(0.8, 0.35, 1.0, 0.0), 0.5)
	t.parallel().tween_property(sprite, "position", _enemy_home[i] + Vector2(0, 4), 0.5)


## Called from _update_enemy_ui(): compares each enemy's HP to what it was on
## the previous refresh, so every damage source (attacks, skills, poison/
## burn/bleed ticks, the F3 debug win) animates without hooking each one.
func _animate_enemy_hp_changes() -> void:
	for i in mini(_enemies.size(), _enemy_sprites.size()):
		var enemy: Combatant = _enemies[i]
		if enemy.is_ko:
			if not _enemy_death_shown[i]:
				_enemy_death_shown[i] = true
				_anim_enemy_death(i)
		elif enemy.hp < _enemy_last_hp[i]:
			_anim_enemy_hurt(i)
		_popup_hp_change(_enemy_sprites[i], _enemy_last_hp[i] - enemy.hp)
		_enemy_last_hp[i] = enemy.hp


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			_debug_level_all(1)
		elif event.keycode == KEY_F2:
			_debug_level_all(-1)
		elif event.keycode == KEY_F3:
			_debug_auto_win()


func _process(delta: float) -> void:
	_update_party_positions(delta)
	_cursor.target = _cursor_target()
	_update_windows()
	_update_advance_hint(delta)
	match state:
		State.SELECTING:
			_handle_menu_input()
		State.RESOLVING:
			if not _acting:
				_message_timer -= delta
				if Input.is_action_just_pressed("confirm") or _message_timer <= 0.0:
					_advance_turn()
		State.BATTLE_OVER:
			if Input.is_action_just_pressed("confirm"):
				if not _level_up_queue.is_empty():
					Sfx.play("level_up")
					message_label.text = _level_up_queue.pop_front()
				else:
					Transition.change_scene(GameManager.current_scene_path)


## Which bottom-left window is up: the commands while a member is choosing
## (picking an ally included), the enemy list otherwise (picking an enemy,
## actions playing out, battle over). The banner shows whenever there's a
## message and is resized to fit it, so a 3-line message just grows it.
func _update_windows() -> void:
	var choosing := state == State.SELECTING and _menu_state != MenuState.TARGETING
	command_window.visible = choosing
	_scroll_hint.visible = action_menu.visible
	enemy_window.visible = not choosing
	message_banner.visible = message_label.text != ""
	message_banner.size = message_banner.get_combined_minimum_size()


## How long the current message stays up before the next action plays.
func _message_time() -> float:
	return minf(MESSAGE_MAX_TIME, MESSAGE_BASE_TIME + MESSAGE_TIME_PER_CHAR * message_label.text.length())


## The banner's "press A" arrow: blinks in its bottom-right corner while an
## end-of-battle message waits for confirm (action messages move on by
## themselves, see _message_time()).
func _update_advance_hint(delta: float) -> void:
	_blink = fmod(_blink + delta, 0.8)
	var waiting := state == State.BATTLE_OVER and message_banner.visible
	_advance_hint.visible = waiting and _blink < 0.5
	_advance_hint.more_below = true
	_advance_hint.height = 0.0
	_advance_hint.position = message_banner.position + message_banner.size - Vector2(13, 8)


## What the menu cursor should point at right now (a menu label, a party
## name, or an enemy sprite), or null to hide it.
func _cursor_target() -> CanvasItem:
	if state != State.SELECTING:
		return null
	match _menu_state:
		MenuState.TARGETING:
			return _enemy_sprites[_target_index] if _target_index < _enemy_sprites.size() else null
		MenuState.ALLY_TARGETING:
			return _party_name_labels[_target_ally_index] if _target_ally_index < _party_name_labels.size() else null
	if not action_menu.visible:
		return null
	var row: int = _menu_cursor - _list_scroll
	return _option_labels[row] if row >= 0 and row < _option_labels.size() else null


func _debug_level_all(direction: int) -> void:
	for member in _party:
		if direction > 0:
			member.level_up()
		else:
			member.level_down()
	_update_ui()
	message_label.text = "[DEBUG] Party level %d  (F1=up F2=down)" % _party[0].level


func _debug_auto_win() -> void:
	if state == State.BATTLE_OVER or _acting:
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
	if UiInput.nav(&"down"):
		Sfx.play("menu_move")
		message_label.text = ""
		_menu_cursor = (_menu_cursor + 1) % _menu_options.size()
		_clamp_list_scroll()
		_update_menu()
	elif UiInput.nav(&"up"):
		Sfx.play("menu_move")
		message_label.text = ""
		_menu_cursor = (_menu_cursor - 1 + _menu_options.size()) % _menu_options.size()
		_clamp_list_scroll()
		_update_menu()
	elif Input.is_action_just_pressed("confirm"):
		Sfx.play("menu_confirm")
		_confirm_action()
	elif Input.is_action_just_pressed("cancel"):
		if _menu_state != MenuState.MAIN:
			Sfx.play("menu_cancel")
			_open_main_menu()
			message_label.text = ""
		elif not _chosen_order.is_empty():
			Sfx.play("menu_cancel")
			_step_back()
	elif _menu_state == MenuState.MAIN:
		_handle_shortcuts()


## Command-menu shortcuts from the design doc's controller mapping: X jumps
## to Items, Y defends at once, L1/R1 switch to another member who hasn't
## chosen yet (the round resolves once everyone alive has).
func _handle_shortcuts() -> void:
	if Input.is_action_just_pressed("item_shortcut"):
		Sfx.play("menu_confirm")
		_open_item_menu()
	elif Input.is_action_just_pressed("defend_shortcut"):
		Sfx.play("menu_confirm")
		_party[_selecting_index].queued_action = "defend"
		_advance_selection()
	elif Input.is_action_just_pressed("next_member") or Input.is_action_just_pressed("prev_member"):
		var step := 1 if Input.is_action_just_pressed("next_member") else -1
		var other := _next_unchosen(_selecting_index, step)
		if other != -1 and other != _selecting_index:
			Sfx.play("menu_move")
			_selecting_index = other
			_open_main_menu()
			message_label.text = ""


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

	if UiInput.nav(&"right") or UiInput.nav(&"down"):
		Sfx.play("menu_move")
		_target_index = alive_idx[(pos + 1) % alive_idx.size()]
		_update_enemy_ui()
	elif UiInput.nav(&"left") or UiInput.nav(&"up"):
		Sfx.play("menu_move")
		_target_index = alive_idx[(pos - 1 + alive_idx.size()) % alive_idx.size()]
		_update_enemy_ui()
	elif Input.is_action_just_pressed("confirm"):
		Sfx.play("menu_confirm")
		_confirm_target()
	elif Input.is_action_just_pressed("cancel"):
		Sfx.play("menu_cancel")
		_open_main_menu()
		message_label.text = ""


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

	if UiInput.nav(&"down"):
		Sfx.play("menu_move")
		_target_ally_index = alive_idx[(pos + 1) % alive_idx.size()]
		_update_ui()
	elif UiInput.nav(&"up"):
		Sfx.play("menu_move")
		_target_ally_index = alive_idx[(pos - 1 + alive_idx.size()) % alive_idx.size()]
		_update_ui()
	elif Input.is_action_just_pressed("confirm"):
		Sfx.play("menu_confirm")
		_confirm_ally_target()
	elif Input.is_action_just_pressed("cancel"):
		Sfx.play("menu_cancel")
		_open_main_menu()
		message_label.text = ""


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
		Transition.change_scene(GameManager.current_scene_path)
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
	_update_command_title()
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
	command_title.text = "Skills"


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
	command_title.text = "%s Stance" % current_stance


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
	command_title.text = "Items"


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
	_update_enemy_ui()


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
	command_title.text = "Use on?"
	_update_ui()


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
	_chosen[_selecting_index] = true
	_chosen_order.append(_selecting_index)
	var next := _next_unchosen(_selecting_index, 1)
	if next == -1:
		_begin_resolving()
	else:
		_selecting_index = next
		_open_main_menu()
		message_label.text = ""


## B on the command menu: back to whoever chose last, to change their pick.
## Nothing was spent yet - MP, Qi and items are paid when the action runs.
func _step_back() -> void:
	var previous: int = _chosen_order.pop_back()
	_chosen[previous] = false
	_party[previous].queued_action = ""
	_selecting_index = previous
	_open_main_menu()
	message_label.text = ""


## The next alive member after `from` (stepping by `step`, wrapping around)
## who hasn't chosen this round, or -1 if nobody is left. Can return `from`
## itself when it's the only one left.
func _next_unchosen(from: int, step: int) -> int:
	var n := _party.size()
	for k in range(1, n + 1):
		var i := posmod(from + step * k, n)
		if _party[i].is_alive() and not _chosen[i]:
			return i
	return -1


func _reset_choices() -> void:
	_chosen = []
	for _member in _party:
		_chosen.append(false)
	_chosen_order = []


func _begin_selection() -> void:
	state = State.SELECTING
	_reset_choices()
	_selecting_index = _next_unchosen(-1, 1)
	if _selecting_index == -1:
		_selecting_index = 0
		_end_battle(false)
		return
	action_menu.visible = true
	_open_main_menu()
	message_label.text = ""


func _begin_resolving() -> void:
	state = State.RESOLVING
	_party_acting = -1
	_menu_state = MenuState.MAIN
	action_menu.visible = false
	command_title.text = ""
	_turn_queue = []
	for member in _party:
		if member.is_alive():
			_turn_queue.append(member)
	for enemy in _enemies:
		if enemy.is_alive():
			_turn_queue.append(enemy)
	_turn_queue.sort_custom(func(a, b): return (a.agi - a.agi_debuff) > (b.agi - b.agi_debuff))
	_update_enemy_ui()
	_advance_turn()


## Runs the next action (its effect, then its result) and starts the message
## timer once it's done. Nothing advances in between.
func _advance_turn() -> void:
	_acting = true
	await _execute_next_turn()
	_acting = false
	_message_timer = _message_time()


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
	# The acting party member steps forward for their turn (enemies: nobody).
	_party_acting = _party.find(combatant)
	if combatant.is_stunned:
		combatant.stun_rounds -= 1
		if combatant.stun_rounds <= 0:
			combatant.is_stunned = false
		message_label.text = "%s is stunned and cannot act!" % combatant.display_name
		return
	if combatant.is_enemy:
		await _execute_enemy_turn(combatant)
	else:
		await _execute_party_turn(combatant)


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


## Milestone 18 impact timing: the effect's wind-up / travel plays first (the
## banner shows the skill or item name meanwhile), then the action's logic runs
## - damage, messages, possibly the battle's end - and the impact effect plays
## at that same moment, so hurt flashes and damage numbers land with it.
## Targets are worked out before the logic runs, from the same helpers it uses.
func _execute_party_turn(member: Combatant) -> void:
	var offensive: bool = member.queued_action == "attack" \
			or (member.queued_action == "skill" and str(member.queued_skill.get("target", "")).begins_with("enemy"))
	var recipe: Dictionary = FxRecipes.for_member(member)
	var targets: Array = _fx_targets(member, recipe)
	if offensive:
		_anim_party_attack(_party.find(member))
	var sound := _party_action_sound(member)
	if sound != "":
		Sfx.play(sound)
	if member.queued_action == "skill" or member.queued_action == "item_use":
		message_label.text = member.queued_skill.get("name", "")
	var caster: CanvasItem = _party_sprites[_party.find(member)]
	if not recipe.is_empty() and caster != null:
		await _fx.cast(recipe, caster, targets)
	if not recipe.is_empty():
		_fx.impact(recipe, targets)
		if recipe.get("sound", "") != "":
			Sfx.play(recipe["sound"])
	_skill_element = _element_of(member)
	_weak_hit = false
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
	if _weak_hit:
		message_label.text += " Weak!"
	_skill_element = ""


## The element a party action deals ("" for plain physical), from the skill's
## effect name - the same words FxRecipes keys off.
func _element_of(member: Combatant) -> String:
	if member.queued_action != "skill":
		return ""
	var effect: String = member.queued_skill.get("effect", "")
	if effect.begins_with("holy") or effect == "consecrate":
		return "holy"
	for element: String in ["fire", "ice", "lightning", "earth"]:
		if effect.contains(element):
			return element
	return ""


## Deals damage from a party action, 1.5x if the enemy is weak to the
## action's element. Returns what was actually dealt (for the message).
func _hit(target: Combatant, dmg: int) -> int:
	if target.is_enemy and _skill_element != "" and _skill_element in target.weak:
		dmg = roundi(dmg * 1.5)
		_weak_hit = true
	target.receive_damage(dmg)
	return dmg


## The sprites a party member's action will land on, resolved the same way
## the action's logic resolves them (so before it runs, while every target is
## still standing).
func _fx_targets(member: Combatant, recipe: Dictionary) -> Array:
	var fighters: Array = []
	match member.queued_action:
		"attack":
			fighters = [_get_enemy_target(member)]
		"item_use":
			fighters = [_get_ally_target(member, member.queued_skill)]
		"skill":
			var skill: Dictionary = member.queued_skill
			match str(skill.get("target", "")):
				"enemy":
					fighters = [_get_enemy_target(member)]
				"enemy_all":
					fighters = _enemies.filter(func(e: Combatant) -> bool: return e.is_alive())
				"ally", "ally_choose":
					fighters = [_get_ally_target(member, skill)]
				"ally_all":
					fighters = _party.filter(func(c: Combatant) -> bool:
						return c.is_alive() and (not recipe.get("row_only", false) or c.row == member.row))
				"self":
					fighters = [member]
	var sprites: Array = []
	for f in fighters:
		var sprite := _sprite_of(f)
		if sprite != null:
			sprites.append(sprite)
	return sprites


func _sprite_of(c: Combatant) -> CanvasItem:
	if c == null:
		return null
	if c.is_enemy:
		var i := _enemies.find(c)
		return _enemy_sprites[i] if i >= 0 and i < _enemy_sprites.size() else null
	var j := _party.find(c)
	return _party_sprites[j] if j >= 0 and j < _party_sprites.size() else null


## Weapon users (Ryn, Silas) sound physical when they hit enemies; everything
## else a skill does - Vael's holy magic, Lyra's spells, any heal or buff - is
## a spell. Defend and Swap Row are silent.
func _party_action_sound(member: Combatant) -> String:
	match member.queued_action:
		"attack":
			return "attack"
		"item_use":
			return "item"
		"skill":
			var targets_enemy: bool = str(member.queued_skill.get("target", "")).begins_with("enemy")
			if targets_enemy and member.char_class in ["Ryn", "Silas"]:
				return "attack"
			return "spell"
	return ""


func _do_attack(member: Combatant) -> void:
	var target: Combatant = _get_enemy_target(member)
	if target == null:
		return
	var dmg := maxi(1, (member.atk + member.atk_buff) - (target.defense + target.def_buff) + randi_range(-2, 2))
	dmg = maxi(1, roundi(float(dmg) * _row_mult(member, target)))
	var crit := _roll_crit(member)
	if crit:
		dmg *= 2
	dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
				dmg = _hit(enemy, dmg)
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
			dmg = _hit(target, dmg)
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
				dmg = _hit(enemy, dmg)
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
			dmg = _hit(target, dmg)
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
					dmg = _hit(target, dmg)
					total += dmg
			_update_ui()
			var crit_tag := " CRIT!" if any_crit else ""
			message_label.text = "%s uses %s!\n%d hits on %s - %d total!%s" % [member.display_name, skill["name"], hits, target.display_name, total, crit_tag]
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
				dmg = _hit(enemy, dmg)
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
				dmg = _hit(enemy, dmg)
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
			dmg = _hit(target, dmg)
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
				dmg = _hit(enemy, dmg)
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
				dmg = _hit(enemy, dmg)
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
			dmg = _hit(target, dmg)
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
			dmg = _hit(target, dmg)
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
			message_label.text = "%s exposes %s's weak point!\nDEF lowered - party deals bonus damage!" % [member.display_name, target.display_name]

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
				dmg = _hit(enemy, dmg)
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
			dmg = _hit(target, dmg)
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


## An enemy's turn (Milestone 20a): a blow it telegraphed last turn lands now;
## otherwise the first ability in its kit that qualifies this turn; otherwise
## its basic attack (with the kit's attack modifiers). Kits: EnemyData.gd.
func _execute_enemy_turn(enemy: Combatant) -> void:
	var targets: Array = _party.filter(func(c): return c.is_alive())
	if targets.is_empty():
		return
	enemy.turns_taken += 1
	var phase_note := ""
	if enemy.is_boss:
		phase_note = _check_boss_phase_transition(enemy)
		if phase_note != "":
			await _play_boss_phase_change(enemy)
	if not enemy.charging.is_empty():
		var charged: Dictionary = enemy.charging
		enemy.charging = {}
		await _enemy_attack(enemy, targets, phase_note, charged)
		return
	var ability := _choose_ability(enemy)
	if not ability.is_empty():
		await _enemy_ability(enemy, ability, targets, phase_note)
		return
	await _enemy_attack(enemy, targets, phase_note, {}, int(enemy.attack_mods.get("hits", 1)))


## The first ability whose boss phase and timing allow it this turn, or {}.
## "every": N fires on every Nth turn; otherwise "chance" is a percent roll.
func _choose_ability(enemy: Combatant) -> Dictionary:
	for a: Dictionary in enemy.abilities:
		if enemy.boss_phase < int(a.get("phase", 0)) or enemy.boss_phase > int(a.get("max_phase", 99)):
			continue
		if a.has("every"):
			if enemy.turns_taken % int(a["every"]) == 0:
				return a
		elif randi() % 100 < int(a.get("chance", 0)):
			return a
	return {}


## Taunt wins; back-row hunters (Hollow Archer) pick the back row 75% of the
## time when anyone's there; otherwise anyone.
func _pick_target(enemy: Combatant, targets: Array) -> Combatant:
	for m: Combatant in targets:
		if m.taunt_rounds > 0:
			return m
	if enemy.attack_mods.get("target", "") == "back_row":
		var back := targets.filter(func(m: Combatant) -> bool: return m.row == "back")
		if not back.is_empty() and randi() % 100 < 75:
			return back[randi() % back.size()]
	return targets[randi() % targets.size()]


## A basic attack - `hits` swings (Blighted Wolf: 2) - or, with `charged`,
## the heavy blow it telegraphed last turn (damage x its "mult").
func _enemy_attack(enemy: Combatant, targets: Array, phase_note: String, charged: Dictionary, hits := 1) -> void:
	_anim_enemy_attack(_enemies.find(enemy))
	var target := _pick_target(enemy, targets)
	var recipe: Dictionary = FxRecipes.ENEMY_ATTACK if charged.is_empty() else FxRecipes.ENEMY_HEAVY
	var enemy_sprite: CanvasItem = _sprite_of(enemy)
	var target_sprite: CanvasItem = _sprite_of(target)
	var hit_targets: Array = [target_sprite] if target_sprite != null else []
	await _fx.cast(recipe, enemy_sprite, hit_targets)

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

	var mult: float = float(charged.get("mult", 1.0))
	var total := 0
	var swings := 0
	for h in hits:
		if not target.is_alive():
			break
		if h > 0:
			await _fx.create_tween().tween_interval(0.18).finished
			_anim_enemy_attack(_enemies.find(enemy))
		_fx.impact(recipe, hit_targets)
		if not charged.is_empty():
			Sfx.play("earth")
		var effective_def := target.defense + target.def_buff
		var def_val := effective_def * 2 if target.defending else effective_def
		var dmg := maxi(1, enemy.atk + enemy.atk_buff - def_val + randi_range(-1, 1))
		dmg = maxi(1, roundi(float(dmg) * _row_mult(enemy, target) * mult))
		target.receive_damage(dmg)
		total += dmg
		swings += 1
		_update_ui()

	var reduced := " (reduced)" if target.defending else ""
	var status := ""
	var mods := enemy.attack_mods
	if target.is_alive() and randi() % 100 < int(mods.get("poison_chance", 0)):
		target.poison_rounds = int(mods.get("poison_rounds", 3))
		target.poison_power = int(mods.get("poison_power", 4))
		status += " Poisoned!"
	if target.is_alive() and randi() % 100 < int(mods.get("stun_chance", 0)):
		target.is_stunned = true
		target.stun_rounds = 1
		status += " Stunned!"
	_update_ui()
	if not charged.is_empty():
		message_label.text = phase_note + "%s unleashes %s!\n%s takes %d%s!%s" % [enemy.display_name, charged.get("name", "a heavy blow"), target.display_name, total, reduced, status]
	elif swings > 1:
		message_label.text = phase_note + "%s strikes %s %d times for %d%s!%s" % [enemy.display_name, target.display_name, swings, total, reduced, status]
	else:
		message_label.text = phase_note + "%s hits %s for %d%s!%s" % [enemy.display_name, target.display_name, total, reduced, status]
	if _party.filter(func(c): return c.is_alive()).is_empty():
		_end_battle(false)


## A special move from the enemy's kit. The banner names it while the enemy
## gathers power, then it resolves.
func _enemy_ability(enemy: Combatant, a: Dictionary, targets: Array, phase_note: String) -> void:
	var ability_name: String = a.get("name", "")
	var pal: Array = BattleFx.PALETTES.get(a.get("palette", "debuff"), BattleFx.PALETTES["debuff"])
	var enemy_sprite: CanvasItem = _sprite_of(enemy)
	message_label.text = phase_note + "%s uses %s!" % [enemy.display_name, ability_name]
	if enemy_sprite != null:
		await _fx.charge(BattleFx.anchor(enemy_sprite), pal)
	var power: int = int(a.get("power", 0))
	var rounds: int = int(a.get("rounds", 2))
	match str(a.get("kind", "")):
		"party_def_down":
			for m: Combatant in targets:
				m.def_buff = -power
				m.def_buff_rounds = rounds
				_fx_on(m, "sinking", "debuff")
			Sfx.play("spell")
			message_label.text = phase_note + "%s chants %s!\nThe party's DEF falls!" % [enemy.display_name, ability_name]
		"ally_atk_up":
			for e: Combatant in _enemies:
				if e.is_alive():
					e.atk_buff = power
					e.atk_buff_rounds = rounds
					_fx_on(e, "sparkles", "debuff")
			Sfx.play("spell")
			message_label.text = phase_note + "%s casts %s!\nThe enemies' ATK rises!" % [enemy.display_name, ability_name]
		"self_def_up":
			enemy.def_buff = power
			enemy.def_buff_rounds = rounds
			_fx_on(enemy, "ring", "shield")
			Sfx.play("holy")
			message_label.text = phase_note + "%s uses %s!\nIts armor hardens!" % [enemy.display_name, ability_name]
		"charge":
			enemy.charging = a
			_fx_on(enemy, "stars", "enemy")
			message_label.text = phase_note + "%s %s" % [enemy.display_name, a.get("tell", "gathers its strength...")]
		"magic_single":
			var target := _pick_target(enemy, targets)
			var dmg := maxi(1, power + enemy.int_stat / 2 - target.res_stat + randi_range(-2, 2))
			_fx_on(target, "pillar", a.get("palette", "debuff"))
			Sfx.play("holy")
			target.receive_damage(dmg)
			_update_ui()
			message_label.text = phase_note + "%s casts %s!\n%s takes %d!" % [enemy.display_name, ability_name, target.display_name, dmg]
		"magic_all":
			_fx.flash(pal[0], 0.4)
			Sfx.play("thunder")
			for m: Combatant in targets:
				_fx_on(m, "burst", a.get("palette", "debuff"))
				m.receive_damage(maxi(1, power + enemy.int_stat / 2 - m.res_stat + randi_range(-2, 2)))
			_update_ui()
			message_label.text = phase_note + "%s casts %s!\nThe whole party is struck!" % [enemy.display_name, ability_name]
	_update_ui()
	if _party.filter(func(c): return c.is_alive()).is_empty():
		_end_battle(false)


## One BattleFx impact of `kind` in `palette` on a fighter.
func _fx_on(c: Combatant, kind: String, palette: String) -> void:
	var sprite := _sprite_of(c)
	if sprite != null:
		_fx.impact({"impact": kind, "palette": palette, "size": 12.0}, [sprite])


## Boss fights get harder as they take damage, checked once per boss turn
## (not the instant a threshold is crossed) so it reads as "the boss recoils,
## then comes back stronger" rather than interrupting whatever just hit it.
## Returns a message prefix (with trailing newline) if a transition happened
## this turn, so the caller can fold it into whatever message it shows next
## instead of the transition note getting silently overwritten a line later.
## What changes per phase is the boss's kit (abilities with "phase" /
## "max_phase" in EnemyData.gd, Milestone 20a).
func _check_boss_phase_transition(enemy: Combatant) -> String:
	if enemy.boss_phase >= enemy.phase_hp_thresholds.size():
		return ""
	var hp_frac: float = float(enemy.hp) / float(enemy.max_hp) if enemy.max_hp > 0 else 0.0
	if hp_frac > enemy.phase_hp_thresholds[enemy.boss_phase]:
		return ""
	enemy.boss_phase += 1
	return "%s enters a new phase!\n" % enemy.display_name


## The boss powering up (18d): violet flash, a big shake and a thunder crack,
## then a lasting reddish tint so the stronger phase is visible. The tint is
## on self_modulate, which the hurt/death tweens (on modulate) don't touch.
func _play_boss_phase_change(enemy: Combatant) -> void:
	var sprite := _sprite_of(enemy)
	if sprite == null:
		return
	message_label.text = "%s is enraged!" % enemy.display_name
	Sfx.play("thunder")
	_fx.flash(BattleFx.PALETTES["debuff"][0], 0.5, 0.4)
	_fx.shake(4.0, 0.5)
	_fx.burst(BattleFx.anchor(sprite), BattleFx.PALETTES["debuff"], 22.0, 0.5)
	sprite.self_modulate = Color(1.25, 0.72, 0.8)
	await _fx.create_tween().tween_interval(0.6).finished


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


## Poison / burn / bleed damage at the end of a round. Each tick also puffs a
## small effect on the fighter (18d); the numbers come from _update_ui().
func _tick_dot() -> void:
	var sounds := {}
	for c in _party + _enemies:
		var sprite := _sprite_of(c)
		if sprite != null and c.is_alive():
			if c.burn_rounds > 0:
				_fx.burst(BattleFx.anchor(sprite), BattleFx.PALETTES["fire"], 8.0)
				sounds["fire"] = true
			if c.poison_rounds > 0:
				_fx.cloud(BattleFx.anchor(sprite), BattleFx.PALETTES["poison"])
				sounds["poison"] = true
			if c.bleed_rounds > 0:
				_fx.sparkles(BattleFx.anchor(sprite), BattleFx.PALETTES["enemy"], false)
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
	for sound: String in sounds:
		Sfx.play(sound)
	_update_ui()


func _end_battle(victory: bool) -> void:
	state = State.BATTLE_OVER
	action_menu.visible = false
	command_title.text = ""
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
		Music.stop(0.3)
		Sfx.play("victory")
		message_label.text = "Victory! Gained %d XP." % total_xp
	else:
		Music.stop(1.0)
		message_label.text = "The party has fallen..."


func _build_levelup_text(member: Combatant) -> String:
	var g: Dictionary = Combatant.LEVEL_GAINS.get(member.char_class, {})
	# Two lines: the message box only has room for two.
	var line1 := "%s reached Level %d!  HP+%d" % [member.display_name, member.level, g.get("hp", 0)]
	if g.get("mp", 0) > 0:
		line1 += " MP+%d" % g.get("mp", 0)
	var line2 := "ATK+%d DEF+%d INT+%d AGI+%d" % [g.get("atk", 0), g.get("def", 0), g.get("int", 0), g.get("agi", 0)]
	return "%s\n%s" % [line1, line2]


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
			_option_labels[i].text = "  " + _menu_options[idx]
			_option_labels[i].visible = true
		else:
			_option_labels[i].text = ""
			_option_labels[i].visible = false
	command_window.size.x = _command_window_width()
	# Arrows beside the first and last visible rows when the list continues.
	_scroll_hint.position = Vector2(command_window.size.x - 11.0, 16.0)
	_scroll_hint.height = 42.0
	_scroll_hint.more_above = scrollable and _list_scroll > 0
	_scroll_hint.more_below = scrollable and _list_scroll + page < _menu_options.size()


## At least LEFT_WINDOW_W; wider when a skill/item name needs it (the widest,
## "Shadow Strike (12MP)", is 110px plus the cursor indent), leaving room on
## the right for the scroll arrows.
func _command_window_width() -> float:
	var font: Font = command_title.get_theme_font("font")
	var font_size: int = command_title.get_theme_font_size("font_size")
	var widest := font.get_string_size(command_title.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	for option: String in _menu_options:
		widest = maxf(widest, font.get_string_size("  " + option, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
	return maxf(LEFT_WINDOW_W, ceilf(widest) + 24.0)


func _update_command_title() -> void:
	if _selecting_index >= _party.size():
		return
	var member: Combatant = _party[_selecting_index]
	command_title.text = member.display_name
	if member.char_class == "Lyra":
		command_title.text += " [%s]" % member.stance


func _update_enemy_ui() -> void:
	_animate_enemy_hp_changes()
	for i in _enemies.size():
		if i >= _enemy_labels.size():
			break
		var enemy: Combatant = _enemies[i]
		var label: Label = _enemy_labels[i]
		var bar: ColorRect = _enemy_hp_bars[i]
		var pct: float = float(enemy.hp) / float(enemy.max_hp) if not enemy.is_ko else 0.0
		bar.size.x = ENEMY_LIST_BAR_W * pct
		if enemy.is_ko:
			label.modulate = Color(0.5, 0.5, 0.5)
		elif _menu_state == MenuState.TARGETING and i == _target_index:
			label.modulate = TARGET_YELLOW
			bar.color = TARGET_YELLOW
		else:
			label.modulate = Color.WHITE
			bar.color = ENEMY_RED


func _update_ui() -> void:
	_update_enemy_ui()
	_animate_party_hp_changes()
	for i in _party.size():
		var member: Combatant = _party[i]
		var pct: float = float(member.hp) / float(member.max_hp) if member.max_hp > 0 else 0.0
		var tint: Color
		var bar_tint: Color
		if member.is_ko:
			tint = Color(0.5, 0.5, 0.5)
			bar_tint = tint
		elif pct > 0.5:
			tint = Color.WHITE
			bar_tint = HP_GREEN
		elif pct > 0.25:
			tint = Color(1.0, 0.85, 0.1)
			bar_tint = tint
		else:
			tint = Color(1.0, 0.35, 0.35)
			bar_tint = tint
		var name_label: Label = _party_name_labels[i]
		name_label.text = "  " + member.display_name
		name_label.modulate = tint
		if _menu_state == MenuState.ALLY_TARGETING and i == _target_ally_index and not member.is_ko:
			name_label.modulate = TARGET_YELLOW
		_party_row_labels[i].text = "F" if member.row == "front" else "B"
		_party_hp_labels[i].text = "--/--" if member.is_ko else "%d/%d" % [member.hp, member.max_hp]
		_party_hp_labels[i].modulate = tint
		_party_hp_bars[i].size.x = 0.0 if member.is_ko else HP_BAR_W * pct
		_party_hp_bars[i].color = bar_tint
		if _party_qi_pips[i] != null:
			_party_qi_pips[i].max_qi = member.max_qi
			_party_qi_pips[i].qi = member.qi
		elif member.max_mp > 0:
			_party_mp_labels[i].text = "%d/%d" % [member.mp, member.max_mp]
			_party_mp_bars[i].size.x = MP_BAR_W * float(member.mp) / float(member.max_mp)
		else:
			_party_mp_labels[i].text = ""
			_party_mp_bars[i].size.x = 0.0