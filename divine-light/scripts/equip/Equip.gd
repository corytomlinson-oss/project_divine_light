extends Node2D

# Milestone 15's equip screen, opened from the pause menu (Milestone 17c; B or
# Start on the map). Closing it returns to the map with the pause menu open
# again, via GameManager.reopen_pause_menu.

enum MenuState { CHARACTER_SELECT, SLOT_SELECT, ITEM_SELECT }

var _state: MenuState = MenuState.CHARACTER_SELECT
var _cursor: int = 0
var _member_index: int = 0
var _slot: String = ""
var _item_options: Array = []  # item names; "" means "Unequip"

@onready var title_label: Label = $TitleLabel
@onready var stats_label: Label = $StatsLabel
@onready var help_label: Label = $HelpLabel
@onready var option_list: VBoxContainer = $OptionList

var _option_labels: Array = []
var _menu_cursor := MenuCursor.new()
# The item list shows ROWS at a time and scrolls (playtest pass, 2026-10-24:
# with more than 5 accessories in the bag it read past its 5 labels).
const ROWS := 5
var _scroll := 0
var _hint := ScrollHint.new()


func _ready() -> void:
	add_child(_menu_cursor)
	add_child(_hint)
	for i in ROWS:
		var label := Label.new()
		option_list.add_child(label)
		_option_labels.append(label)
	_update_ui()


func _process(_delta: float) -> void:
	# The arrows follow the list's real layout (not known until it's drawn).
	var last: Label = _option_labels[ROWS - 1]
	_hint.position = option_list.position + Vector2(option_list.size.x - 8, 2)
	_hint.height = maxf(10.0, last.position.y + last.size.y - 6)
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


## Shows partial progress ("2/4 equipped"), not just the fully-active state -
## found during playtesting that only announcing the bonus once it's already
## complete makes it easy to think a set is finished when it's actually
## missing a piece, especially the universal accessory slot, which can end
## up equipped on a different character by accident since nothing restricts
## it to this one.
func _set_progress_text(member: Combatant, set_id: String) -> String:
	var count := 0
	for slot in ["armor", "helmet", "gloves", "accessory"]:
		var item_name: String = member.equipment.get(slot, "")
		if item_name != "" and Equipment.DEFS.get(item_name, {}).get("set_id", "") == set_id:
			count += 1
	if count == 0:
		return ""
	var status := " - active, buffs +1 round" if count == 4 else ""
	return "\n%s: %d/4 equipped%s" % [set_name, count, status]


func _update_ui() -> void:
	for label in _option_labels:
		label.visible = false
	_hint.more_above = false
	_hint.more_below = false
	if _state != MenuState.ITEM_SELECT:
		_menu_cursor.target = _option_labels[mini(_cursor, ROWS - 1)]

	match _state:
		MenuState.CHARACTER_SELECT:
			title_label.text = "Equip - Select Character"
			stats_label.text = ""
			help_label.text = "Up/Down: Select   A: Confirm   B: Close"
			var party: Array = GameManager.party
			for i in party.size():
				var member: Combatant = party[i]
				_option_labels[i].text = "  " + "%s  Lv%d %s" % [member.display_name, member.level, member.char_class]
				_option_labels[i].visible = true

		MenuState.SLOT_SELECT:
			var member: Combatant = GameManager.party[_member_index]
			title_label.text = "%s - Equipment" % member.display_name
			var stats_text := "ATK %d  DEF %d  INT %d  RES %d  AGI %d" % [member.atk, member.defense, member.int_stat, member.res_stat, member.agi]
			for set_id: String in Equipment.SET_BONUSES:
				stats_text += _set_progress_text(member, set_id)
			stats_label.text = stats_text
			help_label.text = "Up/Down: Select   A: Confirm   B: Back"
			for i in Equipment.SLOTS.size():
				var slot: String = Equipment.SLOTS[i]
				var equipped: String = member.equipment.get(slot, "")
				var shown: String = equipped if equipped != "" else "-- empty --"
				_option_labels[i].text = "  " + "%s: %s" % [slot.capitalize(), shown]
				_option_labels[i].visible = true

		MenuState.ITEM_SELECT:
			var member: Combatant = GameManager.party[_member_index]
			title_label.text = "%s - %s" % [member.display_name, _slot.capitalize()]
			stats_label.text = ""
			help_label.text = "Up/Down: Select   A: Equip   B: Back"
			if _item_options.is_empty():
				_option_labels[0].text = "No equippable items."
				_menu_cursor.target = null
				_option_labels[0].visible = true
			else:
				# keep the cursor's row in the visible window
				_scroll = clampi(_scroll, maxi(0, _cursor - ROWS + 1), mini(_cursor, maxi(0, _item_options.size() - ROWS)))
				_menu_cursor.target = _option_labels[_cursor - _scroll]
				_hint.more_above = _scroll > 0
				_hint.more_below = _scroll + ROWS < _item_options.size()
				for row in mini(ROWS, _item_options.size() - _scroll):
					var i: int = _scroll + row
					var item_name: String = _item_options[i]
					var shown: String
					if item_name == "":
						shown = "Unequip"
					else:
						shown = "%s (x%d)" % [item_name, int(GameManager.inventory.get(item_name, 0))]
						var set_id: String = Equipment.DEFS.get(item_name, {}).get("set_id", "")
						if set_id != "":
							shown += " [%s]" % Equipment.SET_BONUSES.get(set_id, {}).get("name", set_id)
					_option_labels[row].text = "  " + shown
					_option_labels[row].visible = true
