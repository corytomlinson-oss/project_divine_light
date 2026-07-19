extends Node

var party: Array = []


func _ready() -> void:
	if party.is_empty():
		party = [
			Combatant.new("Vael",  150, 10, 12,  6, false, 30, "Vael",  8),
			Combatant.new("Ryn",   100, 14,  8, 10, false,  0, "Ryn",   3),
			Combatant.new("Lyra",   70,  5,  4,  8, false, 50, "Lyra", 15),
			Combatant.new("Silas",  90, 12,  7, 14, false, 30, "Silas",  4),
		]
