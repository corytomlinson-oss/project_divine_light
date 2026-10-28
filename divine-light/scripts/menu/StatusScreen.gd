class_name StatusScreen
extends CanvasLayer

# The character screen (2026-10-28, Cory: "a character summary type screen
# that shows me all the stats and I can go through the skills"). Status in
# the pause menu. Two pages per hero, built in code like the quest log:
#   Stats & Gear - level, XP, HP/MP, every stat, the five slots with icons,
#                  and the set bonuses they've mastered for good.
#   Skills       - every skill in the class (learned white, locked grey with
#                  the level it comes at); the cursor walks them and the
#                  bottom window explains the highlighted one.
# Left / Right turns the page, L1 / R1 (prev / next member) changes hero,
# Up / Down moves through the skills, B closes.

signal closed

const GOLD := Color(0.91, 0.77, 0.35)
const GREY := Color(0.63, 0.61, 0.72)
const DIM := Color(0.42, 0.40, 0.50)
const CLASS_TITLES := {"Vael": "Templar", "Ryn": "Martial Artist", "Lyra": "Invoker", "Silas": "Assassin"}
const ROW_H := 13
const SKILL_ROWS := 7   # per column; two columns
const PAGES := ["Stats & Gear", "Skills"]

var _hero := 0
var _page := 0
var _cursor := 0
var _was_paused := false
var _opened_frame := 0
var _content := Control.new()   # everything that changes with hero / page
var _skill_leads: Array = []
var _skills: Array = []          # [{skill, stance}] for the current hero
var _info: Label
var _menu_cursor := MenuCursor.new()
var _battle_consts: Dictionary


static func open(from: Node) -> StatusScreen:
	var screen := StatusScreen.new()
	from.get_tree().current_scene.add_child(screen)
	return screen


func _ready() -> void:
	layer = 20  # with the map and the quest log: above the pause menu
	process_mode = Node.PROCESS_MODE_ALWAYS
	_was_paused = get_tree().paused
	get_tree().paused = true
	_opened_frame = Engine.get_process_frames()
	_battle_consts = load("res://scripts/battle/Battle.gd").get_script_constant_map()
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.12)
	bg.size = Vector2(320, 180)
	add_child(bg)
	add_child(_content)
	add_child(_menu_cursor)
	_build()


# ---------------------------------------------------------------- building

func _window(pos: Vector2, size: Vector2) -> void:
	var p := Panel.new()
	p.position = pos
	p.size = size
	_content.add_child(p)


func _label(text: String, pos: Vector2, width: float, color := Color.WHITE, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = Vector2(width, 10)
	l.horizontal_alignment = align
	l.add_theme_color_override("font_color", color)
	_content.add_child(l)
	return l


func _member() -> Combatant:
	return GameManager.party[clampi(_hero, 0, GameManager.party.size() - 1)]


func _build() -> void:
	for child in _content.get_children():
		child.queue_free()
	_skill_leads = []
	var m := _member()
	# header: portrait (their current look), name, class, level, HP / MP / XP
	_window(Vector2(4, 4), Vector2(312, 38))
	var portrait := TextureRect.new()
	var frame := AtlasTexture.new()
	var form := SetLooks.form_texture(m)
	if form != null:
		frame.atlas = form
		frame.region = Rect2(0, 0, SetLooks.FORM_W, 32)
		portrait.position = Vector2(6, 7)
	else:
		frame.atlas = load("res://assets/sprites/%s_walk.png" % m.char_class.to_lower())
		frame.region = Rect2(0, 0, 16, 32)
		portrait.position = Vector2(10, 7)
	portrait.texture = frame
	portrait.material = SetLooks.material_for(m)
	_content.add_child(portrait)
	_label(m.display_name, Vector2(36, 9), 60, GOLD)
	_label("%s   Lv %d" % [CLASS_TITLES.get(m.char_class, ""), m.level], Vector2(80, 9), 140, GREY)
	_label("< %s >" % PAGES[_page], Vector2(186, 9), 124, GOLD, HORIZONTAL_ALIGNMENT_RIGHT)
	var resource := ("Qi max %d" % m.max_qi) if m.max_qi > 0 else ("MP %d/%d" % [m.mp, m.max_mp])
	var next_xp := "max level" if m.level >= Combatant.MAX_LEVEL else "%d XP to Lv %d" % [maxi(0, m.xp_to_next - m.xp), m.level + 1]
	_label("HP %d/%d    %s    %s" % [m.hp, m.max_hp, resource, next_xp], Vector2(36, 22), 276)
	if _page == 0:
		_build_stats(m)
	else:
		_build_skills(m)
	_info = Label.new()
	_info.position = Vector2(10, 143)
	_info.size = Vector2(300, 30)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(_info)
	_update_info()


func _build_stats(m: Combatant) -> void:
	_window(Vector2(4, 44), Vector2(100, 94))
	var rows := [["ATK", m.atk], ["DEF", m.defense], ["INT", m.int_stat], ["RES", m.res_stat], ["AGI", m.agi]]
	for i in rows.size():
		_label(rows[i][0], Vector2(12, 50 + i * ROW_H), 30, GREY)
		_label(str(rows[i][1]), Vector2(44, 50 + i * ROW_H), 50, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
	_label("Row", Vector2(12, 50 + 5 * ROW_H), 30, GREY)
	_label(m.row.capitalize(), Vector2(44, 50 + 5 * ROW_H), 50, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
	_window(Vector2(108, 44), Vector2(208, 94))
	for i in Equipment.SLOTS.size():
		var slot: String = Equipment.SLOTS[i]
		var worn: String = m.equipment.get(slot, "")
		var y := 50 + i * ROW_H
		_label("Acc." if slot == "accessory" else slot.capitalize(), Vector2(116, y), 44, GREY)
		if worn != "":
			var icon := TextureRect.new()
			icon.texture = Equipment.icon(worn)
			icon.position = Vector2(160, y - 1)
			_content.add_child(icon)
		_label(worn if worn != "" else "- empty -", Vector2(174, y), 138, Color.WHITE if worn != "" else DIM)
	var look := SetLooks.active_set(m)
	if look != "":
		_label("Look: " + String(Equipment.SET_BONUSES[look]["name"]).trim_suffix(" Set"), Vector2(116, 50 + 5 * ROW_H), 196, GOLD)


func _build_skills(m: Combatant) -> void:
	_window(Vector2(4, 44), Vector2(312, 94))
	_skills = []
	if m.char_class == "Lyra":
		var lyra: Dictionary = _battle_consts["LYRA_SKILLS"]
		for stance: String in _battle_consts["LYRA_STANCES"]:
			for sk: Dictionary in lyra.get(stance, []):
				_skills.append({"skill": sk, "stance": stance})
	else:
		for sk: Dictionary in _battle_consts["CLASS_SKILLS"].get(m.char_class, []):
			_skills.append({"skill": sk, "stance": ""})
	_cursor = clampi(_cursor, 0, maxi(0, _skills.size() - 1))
	for i in mini(_skills.size(), SKILL_ROWS * 2):
		var sk: Dictionary = _skills[i]["skill"]
		var col := i / SKILL_ROWS
		var x := 8 + col * 154
		var y := 49 + (i % SKILL_ROWS) * 12  # 7 rows fit the window at 12px
		var learned := m.level >= int(sk.get("min_level", 1))
		var lead := _label("  " + String(sk["name"]), Vector2(x, y), 100, Color.WHITE if learned else DIM)
		_skill_leads.append(lead)
		var cost := ("%d Qi" % sk["cost"]) if sk["cost_type"] == "qi" else ("%d MP" % sk["cost"])
		_label(cost if learned else "Lv %d" % sk["min_level"], Vector2(x + 100, y), 46, GREY if learned else DIM, HORIZONTAL_ALIGNMENT_RIGHT)


func _update_info() -> void:
	var m := _member()
	if _page == 0:
		_menu_cursor.target = null
		var bonuses: Array = []
		for set_id: String in m.mastered_sets:
			var def: Dictionary = Equipment.SET_BONUSES.get(set_id, {})
			bonuses.append("%s: %s" % [String(def.get("name", set_id)).trim_suffix(" Set"), def.get("desc", "buff skills last 1 extra round")])
		_info.text = ("Set bonuses kept for good - " + "; ".join(bonuses) + ".") if not bonuses.is_empty() \
				else "No set bonuses yet. Wear all four pieces of a set to master its bonus for good."
		return
	if _skills.is_empty():
		_info.text = ""
		return
	var entry: Dictionary = _skills[_cursor]
	var sk: Dictionary = entry["skill"]
	var help: String = _battle_consts["SKILL_HELP"].get(sk["name"], "")
	var where := (" (%s stance)" % entry["stance"]) if entry["stance"] != "" else ""
	var learned := m.level >= int(sk.get("min_level", 1))
	_info.text = "%s%s: %s%s" % [sk["name"], where, help, "" if learned else " Learned at level %d." % sk["min_level"]]
	_menu_cursor.target = _skill_leads[_cursor] if _cursor < _skill_leads.size() else null


# ---------------------------------------------------------------- input

func _process(_delta: float) -> void:
	if Engine.get_process_frames() == _opened_frame:
		return  # the press that opened it is still "just pressed"
	if Input.is_action_just_pressed(&"cancel") or Input.is_action_just_pressed(&"pause"):
		Sfx.play("menu_cancel")
		get_tree().set_deferred("paused", _was_paused)
		closed.emit()
		queue_free()
		return
	var party_size: int = GameManager.party.size()
	if Input.is_action_just_pressed(&"next_member") or Input.is_action_just_pressed(&"prev_member"):
		Sfx.play("menu_move")
		_hero = posmod(_hero + (1 if Input.is_action_just_pressed(&"next_member") else -1), party_size)
		_cursor = 0
		_build()
	elif UiInput.nav(&"right") or UiInput.nav(&"left"):
		Sfx.play("menu_move")
		_page = 1 - _page
		_build()
	elif _page == 1 and not _skills.is_empty() and (UiInput.nav(&"down") or UiInput.nav(&"up")):
		Sfx.play("menu_move")
		var count := mini(_skills.size(), SKILL_ROWS * 2)
		_cursor = posmod(_cursor + (1 if UiInput.nav(&"down") else -1), count)
		_update_info()
