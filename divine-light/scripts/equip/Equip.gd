extends Node2D

# Milestone 15's equip screen. First overworld-accessible UI (opened via a
# dedicated key from Player.gd, works from both Overworld and dungeons since
# Player.gd is shared) - deliberately NOT the full "B = main menu" shell the
# design doc's controller mapping describes, since Formation/Inventory/Party
# status screens don't exist yet either. Just this one screen for now.

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


func _ready() -> void:
	for i in 5:
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 8)
		option_list.add_child(label)
		_option_labels.append(label)
	_update_ui()


func _process(_delta: float) -> void:
	match _state:
		MenuState.CHARACTER_SELECT:
			_handle_list_input(GameManager.party.size(), _confirm_character, _exit_to_map)
		MenuState.SLOT_SELECT:
			_handle_list_input(Equipment.SLOTS.size(), _confirm_slot, _back_to_character_select)
		MenuState.ITEM_SELECT:
			_handle_list_input(_item_options.size(), _confirm_item, _back_to_slot_select)


func _handle_list_input(count: int, on_confirm: Callable, on_cancel: Callable) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		on_cancel.call()
		return
	if count == 0:
		return
	if Input.is_action_just_pressed("ui_down"):
		_cursor = (_cursor + 1) % count
		_update_ui()
	elif Input.is_action_just_pressed("ui_up"):
		_cursor = (_cursor - 1 + count) % count
		_update_ui()
	elif Input.is_action_just_pressed("ui_accept"):
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
	_back_to_slot_select()


func _exit_to_map() -> void:
	get_tree().change_scene_to_file(GameManager.current_scene_path)


## Shows partial progress ("2/4 equipped"), not just the fully-active state -
## found during playtesting that only announcing the bonus once it's already
## complete makes it easy to think a set is finished when it's actually
## missing a piece, especially the universal accessory slot, which can end
## up equipped on a different character by accident since nothing restricts
## it to this one.
func _set_progress_text(member: Combatant, set_id: String, set_name: String) -> String:
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

	match _state:
		MenuState.CHARACTER_SELECT:
			title_label.text = "Equip - Select Character"
			stats_label.text = ""
			help_label.text = "Up/Down: Select   A: Confirm   B: Close"
			var party: Array = GameManager.party
			for i in party.size():
				var member: Combatant = party[i]
				_option_labels[i].text = ("> " if i == _cursor else "  ") + "%s  Lv%d %s" % [member.display_name, member.level, member.char_class]
				_option_labels[i].visible = true

		MenuState.SLOT_SELECT:
			var member: Combatant = GameManager.party[_member_index]
			title_label.text = "%s - Equipment" % member.display_name
			var stats_text := "ATK %d  DEF %d  INT %d  RES %d  AGI %d" % [member.atk, member.defense, member.int_stat, member.res_stat, member.agi]
			stats_text += _set_progress_text(member, "holy_guardian", "Holy Guardian Set")
			stats_label.text = stats_text
			help_label.text = "Up/Down: Select   A: Confirm   B: Back"
			for i in Equipment.SLOTS.size():
				var slot: String = Equipment.SLOTS[i]
				var equipped: String = member.equipment.get(slot, "")
				var shown: String = equipped if equipped != "" else "-- empty --"
				_option_labels[i].text = ("> " if i == _cursor else "  ") + "%s: %s" % [slot.capitalize(), shown]
				_option_labels[i].visible = true

		MenuState.ITEM_SELECT:
			var member: Combatant = GameManager.party[_member_index]
			title_label.text = "%s - %s" % [member.display_name, _slot.capitalize()]
			stats_label.text = ""
			help_label.text = "Up/Down: Select   A: Equip   B: Back"
			if _item_options.is_empty():
				_option_labels[0].text = "No equippable items."
				_option_labels[0].visible = true
			else:
				for i in _item_options.size():
					var item_name: String = _item_options[i]
					var shown: String
					if item_name == "":
						shown = "Unequip"
					else:
						shown = "%s (x%d)" % [item_name, int(GameManager.inventory.get(item_name, 0))]
						var set_id: String = Equipment.DEFS.get(item_name, {}).get("set_id", "")
						if set_id != "":
							shown += " [%s]" % Equipment.SET_BONUSES.get(set_id, {}).get("name", set_id)
					_option_labels[i].text = ("> " if i == _cursor else "  ") + shown
					_option_labels[i].visible = true
