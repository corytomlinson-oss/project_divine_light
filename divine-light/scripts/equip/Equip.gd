extends Node2D

# Milestone 15's equip screen, opened from the pause menu (Milestone 17c; B or
# Start on the map). Closing it returns to the map with the pause menu open
# again, via GameManager.reopen_pause_menu.
#
# Laid out in windows (2026-10-28, Cory: "use the windows to make the screen a
# little easier to read... icons for the equipment"): a header with the hero,
# the list on the left (slot names and item icons), stats on the right (with
# the change an item would make, green up / red down), and a description
# window along the bottom.

enum MenuState { CHARACTER_SELECT, SLOT_SELECT, ITEM_SELECT }

const GOLD := Color(0.91, 0.77, 0.35)
const GREY := Color(0.63, 0.61, 0.72)
const GREEN := Color(0.5, 0.92, 0.5)
const RED := Color(0.95, 0.45, 0.45)
const CLASS_TITLES := {"Vael": "Templar", "Ryn": "Martial Artist", "Lyra": "Invoker", "Silas": "Assassin"}
const STAT_ROWS := [["HP", "hp"], ["MP", "mp"], ["ATK", "atk"], ["DEF", "def"], ["INT", "int"], ["RES", "res"], ["AGI", "agi"]]
# The list shows ROWS at a time and scrolls (playtest pass, 2026-10-24: with
# many accessories in the bag it used to read past its labels).
const ROWS := 8
const ROW_H := 13
const LIST_TOP := 30

var _state: MenuState = MenuState.CHARACTER_SELECT
var _cursor: int = 0
var _member_index: int = 0
var _slot: String = ""
var _item_options: Array = []  # item names; "" means "Unequip"
var _scroll := 0

var _header: Label
var _header_right: Label
var _leads: Array = []    # Label per row (the cursor points at these)
var _icons: Array = []    # TextureRect per row
var _names: Array = []    # Label per row
var _stat_values: Dictionary = {}  # key -> Label (now)
var _stat_after: Dictionary = {}   # key -> Label (after, coloured)
var _info := Label.new()
var _menu_cursor := MenuCursor.new()
var _hint := ScrollHint.new()


func _ready() -> void:
	_build_windows()
	add_child(_menu_cursor)
	_update_ui()


func _window(pos: Vector2, size: Vector2) -> Panel:
	var p := Panel.new()
	p.position = pos
	p.size = size
	add_child(p)
	return p


func _label(pos: Vector2, width: float, color := Color.WHITE, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = Vector2(width, 10)
	l.horizontal_alignment = align
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l


func _build_windows() -> void:
	_window(Vector2(4, 4), Vector2(312, 18))
	_window(Vector2(4, 24), Vector2(204, 114))
	_window(Vector2(212, 24), Vector2(104, 114))
	_window(Vector2(4, 140), Vector2(312, 36))
	_header = _label(Vector2(10, 7), 200, GOLD)
	_header_right = _label(Vector2(160, 7), 150, GREY, HORIZONTAL_ALIGNMENT_RIGHT)
	for i in ROWS:
		var y := LIST_TOP + i * ROW_H
		_leads.append(_label(Vector2(10, y), 52))
		var icon := TextureRect.new()
		icon.position = Vector2(62, y - 1)
		icon.size = Vector2(12, 12)
		add_child(icon)
		_icons.append(icon)
		_names.append(_label(Vector2(76, y), 128))
	_hint.position = Vector2(199, LIST_TOP)
	_hint.height = ROW_H * ROWS - 8
	add_child(_hint)
	_label(Vector2(218, 28), 90, GOLD).text = "Stats"
	for i in STAT_ROWS.size():
		var y := 41 + i * ROW_H
		_label(Vector2(218, y), 26, GREY).text = STAT_ROWS[i][0]
		_stat_values[STAT_ROWS[i][1]] = _label(Vector2(242, y), 24, Color.WHITE, HORIZONTAL_ALIGNMENT_RIGHT)
		_stat_after[STAT_ROWS[i][1]] = _label(Vector2(268, y), 44)
	_info.position = Vector2(10, 143)
	_info.size = Vector2(300, 30)
	_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_info)


func _process(_delta: float) -> void:
	match _state:
		MenuState.CHARACTER_SELECT:
			_handle_list_input(GameManager.party.size(), _confirm_character, _exit_to_map)
		MenuState.SLOT_SELECT:
			_handle_list_input(Equipment.SLOTS.size(), _confirm_slot, _back_to_character_select)
		MenuState.ITEM_SELECT:
			_handle_list_input(_item_options.size(), _confirm_item, _back_to_slot_select)


func _handle_list_input(count: int, on_confirm: Callable, on_cancel: Callable) -> void:
	if Input.is_action_just_pressed("cancel"):
		Sfx.play("menu_cancel")
		on_cancel.call()
		return
	if count == 0:
		return
	if UiInput.nav(&"down"):
		Sfx.play("menu_move")
		_cursor = (_cursor + 1) % count
		_update_ui()
	elif UiInput.nav(&"up"):
		Sfx.play("menu_move")
		_cursor = (_cursor - 1 + count) % count
		_update_ui()
	elif Input.is_action_just_pressed("confirm"):
		# Picking the item itself gets the equip clink instead (_confirm_item).
		if _state != MenuState.ITEM_SELECT:
			Sfx.play("menu_confirm")
		on_confirm.call()


func _confirm_character() -> void:
	_member_index = _cursor
	_cursor = 0
	_state = MenuState.SLOT_SELECT
	_update_ui()


func _back_to_character_select() -> void:
	_cursor = _member_index
	_state = MenuState.CHARACTER_SELECT
	_update_ui()


func _confirm_slot() -> void:
	_slot = Equipment.SLOTS[_cursor]
	var member: Combatant = GameManager.party[_member_index]
	_item_options = Equipment.equippable_items_for(member, _slot)
	if member.equipment.get(_slot, "") != "":
		_item_options.append("")
	_cursor = 0
	_scroll = 0
	_state = MenuState.ITEM_SELECT
	_update_ui()


func _back_to_slot_select() -> void:
	_cursor = Equipment.SLOTS.find(_slot)
	_state = MenuState.SLOT_SELECT
	_update_ui()


func _confirm_item() -> void:
	var member: Combatant = GameManager.party[_member_index]
	var item_name: String = _item_options[_cursor]
	if item_name == "":
		Equipment.unequip(member, _slot)
	else:
		Equipment.equip(member, item_name)
	Sfx.play("equip")
	_back_to_slot_select()


func _exit_to_map() -> void:
	Transition.change_scene(GameManager.current_scene_path)


# ---------------------------------------------------------------- drawing

func _clear_rows() -> void:
	for i in ROWS:
		_leads[i].text = ""
		_icons[i].texture = null
		_names[i].text = ""
		_names[i].modulate = Color.WHITE
		_leads[i].add_theme_color_override("font_color", Color.WHITE)
		# the slot-list layout (the item list shifts icon and name left)
		_icons[i].position.x = 62
		_names[i].position.x = 76
	_hint.more_above = false
	_hint.more_below = false


func _row(i: int, lead: String, item_name: String, text: String, lead_color := Color.WHITE) -> void:
	_leads[i].text = "  " + lead
	_leads[i].add_theme_color_override("font_color", lead_color)
	_icons[i].texture = Equipment.icon(item_name) if item_name != "" else null
	_names[i].text = text


## The stats window: the hero's numbers now, and with `deltas` (an item being
## considered) what they'd become, green for better and red for worse.
func _show_stats(member: Combatant, deltas: Dictionary = {}) -> void:
	var now := {"hp": member.max_hp, "mp": member.max_mp, "atk": member.atk, "def": member.defense,
			"int": member.int_stat, "res": member.res_stat, "agi": member.agi}
	for pair: Array in STAT_ROWS:
		var key: String = pair[1]
		var value: Label = _stat_values[key]
		var after: Label = _stat_after[key]
		var d := int(deltas.get(key, 0))
		value.text = "-" if key == "mp" and member.max_mp == 0 and d == 0 else str(now[key])
		if d == 0:
			after.text = ""
		else:
			after.text = "> %d" % (int(now[key]) + d)
			after.add_theme_color_override("font_color", GREEN if d > 0 else RED)


## The sets this hero has mastered (their bonuses stay for good).
func _mastered_text(member: Combatant) -> String:
	var names: Array = []
	for set_id: String in member.mastered_sets:
		names.append(String(Equipment.SET_BONUSES.get(set_id, {}).get("name", set_id)).trim_suffix(" Set"))
	return "" if names.is_empty() else "Mastered: " + ", ".join(names)


func _join(lines: Array) -> String:
	return "\n".join(lines.filter(func(l: String) -> bool: return l != ""))


func _title(member: Combatant) -> String:
	return "%s   Lv %d %s" % [member.display_name, member.level, CLASS_TITLES.get(member.char_class, "")]


func _update_ui() -> void:
	_clear_rows()
	match _state:
		MenuState.CHARACTER_SELECT:
			_header.text = "Equip"
			_header_right.text = "Choose a hero"
			var party: Array = GameManager.party
			for i in party.size():
				var m: Combatant = party[i]
				_row(i, m.display_name, "", "Lv %d %s" % [m.level, CLASS_TITLES.get(m.char_class, "")])
				_names[i].modulate = GREY
			var member: Combatant = party[clampi(_cursor, 0, party.size() - 1)]
			_show_stats(member)
			_info.text = _join(["Choose a hero to change their equipment.", _mastered_text(member)])
			_menu_cursor.target = _leads[_cursor]

		MenuState.SLOT_SELECT:
			var member: Combatant = GameManager.party[_member_index]
			_header.text = _title(member)
			_header_right.text = "Equipment"
			for i in Equipment.SLOTS.size():
				var slot: String = Equipment.SLOTS[i]
				var worn: String = member.equipment.get(slot, "")
				_row(i, "Acc." if slot == "accessory" else slot.capitalize(), worn, worn if worn != "" else "- empty -", GREY)
				if worn == "":
					_names[i].modulate = GREY
			_show_stats(member)
			var here: String = member.equipment.get(Equipment.SLOTS[_cursor], "")
			if here == "":
				_info.text = _join(["Nothing equipped here.", _mastered_text(member)])
			else:
				var set_line := Equipment.set_text(member, here)
				# three lines fit: the mastered list only when there's no set line
				_info.text = _join([Equipment.describe(here), set_line, _mastered_text(member) if set_line == "" else ""])
			_menu_cursor.target = _leads[_cursor]

		MenuState.ITEM_SELECT:
			var member: Combatant = GameManager.party[_member_index]
			_header.text = _title(member)
			_header_right.text = "Choose: " + ("Accessory" if _slot == "accessory" else _slot.capitalize())
			if _item_options.is_empty():
				_names[0].text = "Nothing in the bag fits here."
				_names[0].modulate = GREY
				_show_stats(member)
				_info.text = "Find or buy more gear: chests, armories, and Frank."
				_menu_cursor.target = null
				return
			# keep the cursor's row in the visible window
			_scroll = clampi(_scroll, maxi(0, _cursor - ROWS + 1), mini(_cursor, maxi(0, _item_options.size() - ROWS)))
			_hint.more_above = _scroll > 0
			_hint.more_below = _scroll + ROWS < _item_options.size()
			for row in mini(ROWS, _item_options.size() - _scroll):
				var item_name: String = _item_options[_scroll + row]
				if item_name == "":
					_row(row, "", "", "Take it off")
					_names[row].modulate = GREY
				else:
					var count := int(GameManager.inventory.get(item_name, 0))
					_row(row, "", item_name, item_name + ("  x%d" % count if count > 1 else ""))
				_icons[row].position.x = 22
				_names[row].position.x = 36
			var chosen: String = _item_options[_cursor]
			_show_stats(member, Equipment.stat_deltas(member, _slot, chosen))
			if chosen == "":
				_info.text = "Take off the %s." % member.equipment.get(_slot, "")
			else:
				_info.text = _join([Equipment.describe(chosen), Equipment.set_text(member, chosen)])
			_menu_cursor.target = _leads[_cursor - _scroll]
