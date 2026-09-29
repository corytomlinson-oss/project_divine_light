class_name ShopMenu
extends CanvasLayer

# A shop screen (Milestone 20a: Frank's stall in Verdance). A list of items
# with prices; A buys one (if you can afford it), B leaves. Shows your gold,
# how many you own, and what the selected item does.
#
#   await ShopMenu.open(self, [{"item": "Potion", "price": 20}, ...])

signal closed

const ITEM_TEXT := {
	"Potion": "Restores 50 HP to one ally.",
	"Elixir": "Restores 120 HP to one ally.",
	"Ether": "Restores 30 MP to one ally.",
	"Antidote": "Cures poison.",
}
const MAX_STACK := 99

var _stock: Array = []
var _index := 0
var _rows: Array = []
var _cursor := MenuCursor.new()
var _gold_label := Label.new()
var _owned_label := Label.new()
var _info_label := Label.new()
var _opened_frame := 0


## Opens the shop over the current scene and waits until it closes.
static func open(from: Node, stock: Array) -> void:
	var shop := ShopMenu.new()
	shop._stock = stock
	# Like the pause menu: the map is paused underneath, the shop keeps running.
	shop.process_mode = Node.PROCESS_MODE_ALWAYS
	var tree := from.get_tree()
	tree.current_scene.add_child(shop)
	tree.paused = true
	await shop.closed
	tree.paused = false


func _ready() -> void:
	layer = 20
	_opened_frame = Engine.get_process_frames()
	var list := Panel.new()
	list.position = Vector2(4, 4)
	list.size = Vector2(200, 8 + 10 * maxi(_stock.size(), 1))
	add_child(list)
	for i in _stock.size():
		var entry: Dictionary = _stock[i]
		var name_label := _label(list, "  " + String(entry["item"]), Vector2(8, 4 + i * 10), 150)
		_label(list, "%dg" % entry["price"], Vector2(140, 4 + i * 10), 52, HORIZONTAL_ALIGNMENT_RIGHT)
		_rows.append(name_label)
	var side := Panel.new()
	side.position = Vector2(208, 4)
	side.size = Vector2(108, 38)
	add_child(side)
	_gold_label.position = Vector2(8, 4)
	_gold_label.size = Vector2(92, 10)
	_gold_label.add_theme_color_override("font_color", Color(0.91, 0.77, 0.35))
	side.add_child(_gold_label)
	_owned_label.position = Vector2(8, 16)
	_owned_label.size = Vector2(92, 10)
	side.add_child(_owned_label)
	var info := Panel.new()
	info.position = Vector2(4, 140)
	info.size = Vector2(312, 36)
	add_child(info)
	_info_label.position = Vector2(8, 5)
	_info_label.size = Vector2(296, 26)
	_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_info_label)
	add_child(_cursor)
	_refresh()


func _label(parent: Control, text: String, pos: Vector2, width: float, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = Vector2(width, 10)
	label.horizontal_alignment = align
	parent.add_child(label)
	return label


func _refresh() -> void:
	_gold_label.text = "%d gold" % GameManager.gold
	if _stock.is_empty():
		return
	var item: String = _stock[_index]["item"]
	_owned_label.text = "Owned: %d" % int(GameManager.inventory.get(item, 0))
	_info_label.text = _describe(item)
	_cursor.target = _rows[_index]
	for i in _rows.size():
		var affordable: bool = GameManager.gold >= int(_stock[i]["price"])
		_rows[i].modulate = Color.WHITE if affordable else Color(0.55, 0.55, 0.62)


func _describe(item: String) -> String:
	if ITEM_TEXT.has(item):
		return ITEM_TEXT[item]
	var def: Dictionary = Equipment.DEFS.get(item, {})
	if def.is_empty():
		return ""
	var parts: Array = []
	for stat: String in ["atk", "def", "int", "res", "agi"]:
		if def.has(stat):
			parts.append("%s +%d" % [stat.to_upper(), def[stat]])
	var who: String = def.get("class", "")
	return "%s. %s%s" % [String(def.get("slot", "")).capitalize(), ", ".join(parts), (" (%s only)" % who) if who != "" else " (anyone)"]


func _process(_delta: float) -> void:
	if Engine.get_process_frames() == _opened_frame or _stock.is_empty() and not Input.is_action_just_pressed("cancel"):
		return
	if UiInput.nav(&"down") or UiInput.nav(&"up"):
		Sfx.play("menu_move")
		_index = posmod(_index + (1 if UiInput.nav(&"down") else -1), _stock.size())
		_refresh()
	elif Input.is_action_just_pressed("confirm"):
		_buy()
	elif Input.is_action_just_pressed("cancel"):
		Sfx.play("menu_cancel")
		closed.emit()
		queue_free()


func _buy() -> void:
	var item: String = _stock[_index]["item"]
	var price: int = int(_stock[_index]["price"])
	var owned := int(GameManager.inventory.get(item, 0))
	if GameManager.gold < price or owned >= MAX_STACK:
		Sfx.play("menu_cancel")
		return
	GameManager.gold -= price
	GameManager.inventory[item] = owned + 1
	Sfx.play("equip" if Equipment.DEFS.has(item) else "item")
	_refresh()
