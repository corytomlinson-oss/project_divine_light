extends Node

signal party_loaded

const SAVE_DIR: String = "user://saves/"
const SAVE_SLOTS: int = 3

var party: Array = []
var inventory: Dictionary = {}


func _ready() -> void:
	if party.is_empty():
		party = [
			Combatant.new("Vael",  150, 10, 12,  6, false, 30, "Vael",  8, 8),
			Combatant.new("Ryn",   100, 14,  8, 10, false,  0, "Ryn",   3, 5),
			Combatant.new("Lyra",   70,  5,  4,  8, false, 50, "Lyra", 15, 8),
			Combatant.new("Silas",  90, 12,  7, 14, false, 30, "Silas",  4, 5),
		]
		party[0].row = "front"  # Vael
		party[1].row = "front"  # Ryn
		party[2].row = "back"   # Lyra
		party[3].row = "back"   # Silas
	if inventory.is_empty():
		inventory = {
			"Potion": 10,
			"Elixir": 3,
			"Ether": 5,
			"Antidote": 5,
		}


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_F5:
		save_game(1)
		print("Saved to slot 1.")
	elif event.keycode == KEY_F6:
		if load_game(1):
			print("Loaded slot 1.")
		else:
			print("No save found in slot 1.")


func save_game(slot: int) -> bool:
	if slot < 1 or slot > SAVE_SLOTS:
		return false
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")
	var file := FileAccess.open(_slot_path(slot), FileAccess.WRITE)
	if file == null:
		return false
	var data := {
		"party": party.map(func(c: Combatant) -> Dictionary: return c.to_save_dict()),
		"inventory": inventory.duplicate(),
	}
	file.store_string(JSON.stringify(data))
	return true


func load_game(slot: int) -> bool:
	var path := _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var save_party: Array = parsed.get("party", [])
	for i in mini(save_party.size(), party.size()):
		party[i].load_save_dict(save_party[i])
	var save_inventory: Dictionary = parsed.get("inventory", {})
	inventory.clear()
	for item_name in save_inventory:
		inventory[item_name] = int(save_inventory[item_name])
	party_loaded.emit()
	return true


func save_exists(slot: int) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func _slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot
