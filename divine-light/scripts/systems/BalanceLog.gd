extends Node

# Balance logging (2026-10-29, Cory: "everytime I gain experience, how much
# damage I do, how much damage bosses do... so we can use the logs to fine
# tune the game"). One file per play session, one JSON object
# per line (user://balance_logs, apart from the engine's own user://logs):
#   session      - the game started
#   battle_start - where, the enemies, and each hero's level, stats and gear
#   action       - one turn: who acted, the battle message, and every HP change
#                  it caused (damage, healing, poison ticks, Frank...)
#   battle_end   - won / lost / auto-win (F3), rounds, XP, gold, each hero's
#                  HP left, and damage dealt / taken per fighter
#   xp           - XP gained (battle or quest) and levels reached
#   quest        - a quest's reward
# On Windows: %APPDATA%/Godot/app_userdata/divine_light/balance_logs.
# tools/balance_report.py turns a log into a readable summary.

const DIR := "user://balance_logs"

var _file: FileAccess
var _started_msec := 0
var _battle_msec := 0
var _round := 0
var _snapshot: Dictionary = {}   # Combatant -> hp before the current action
var _actor := ""
var _action := ""
var _battle_fighters: Array = []
var _dealt: Dictionary = {}      # name -> damage dealt this battle
var _taken: Dictionary = {}      # name -> damage taken this battle
var _healed: Dictionary = {}     # name -> HP restored to their side this battle


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	_file = FileAccess.open("%s/session_%s.jsonl" % [DIR, stamp], FileAccess.WRITE)
	_started_msec = Time.get_ticks_msec()
	write("session", {"date": Time.get_datetime_string_from_system(), "version": ProjectSettings.get_setting("application/config/version", "")})


## Appends one event. Flushed every line so a crash loses nothing.
func write(kind: String, data: Dictionary) -> void:
	if _file == null:
		return
	var line := {"t": kind, "sec": (Time.get_ticks_msec() - _started_msec) / 1000}
	line.merge(data)
	_file.store_line(JSON.stringify(line))
	_file.flush()


static func hero(c: Combatant) -> Dictionary:
	return {"name": c.display_name, "lv": c.level, "hp": c.hp, "max_hp": c.max_hp, "mp": c.mp, "max_mp": c.max_mp,
		"atk": c.atk, "def": c.defense, "int": c.int_stat, "res": c.res_stat, "agi": c.agi, "row": c.row,
		"gear": c.equipment.duplicate()}


# ---------------------------------------------------------------- battles

func battle_start(party: Array, enemies: Array) -> void:
	_battle_msec = Time.get_ticks_msec()
	_round = 0
	_snapshot = {}
	_dealt = {}
	_taken = {}
	_healed = {}
	_battle_fighters = party + enemies
	write("battle_start", {
		"location": GameManager.current_location,
		"boss": enemies.any(func(e: Combatant) -> bool: return e.is_boss),
		"enemies": enemies.map(func(e: Combatant) -> Dictionary: return {"name": e.display_name, "hp": e.max_hp, "atk": e.atk, "def": e.defense, "agi": e.agi, "xp": e.xp_reward}),
		"party": party.map(hero),
	})


func new_round() -> void:
	_round += 1


## Starts an action; the HP changes up to the next begin / end are its own.
func begin(actor: String, action: String) -> void:
	end_action("")
	_actor = actor
	_action = action
	for c: Combatant in _battle_fighters:
		_snapshot[c] = c.hp


## Writes the action begun last, with every HP change since (nothing if no
## action is open or nothing changed and no message).
func end_action(message: String) -> void:
	if _snapshot.is_empty():
		return
	var changes: Array = []
	for c: Combatant in _snapshot:
		var delta: int = c.hp - int(_snapshot[c])
		if delta == 0:
			continue
		changes.append({"who": c.display_name, "hp": delta, "left": c.hp, "ko": c.is_ko})
		if delta < 0:
			_taken[c.display_name] = int(_taken.get(c.display_name, 0)) - delta
			_dealt[_actor] = int(_dealt.get(_actor, 0)) - delta
		else:
			_healed[_actor] = int(_healed.get(_actor, 0)) + delta
	_snapshot = {}
	if changes.is_empty() and message == "":
		return
	write("action", {"round": _round, "actor": _actor, "action": _action, "msg": message.replace("\n", " / "), "changes": changes})


## Picks up fighters that join mid-fight (summons) so their HP is tracked.
func add_fighter(c: Combatant) -> void:
	if not c in _battle_fighters:
		_battle_fighters.append(c)


func battle_end(result: String, party: Array, xp: int, gold: int) -> void:
	write("battle_end", {
		"location": GameManager.current_location,
		"result": result,
		"rounds": _round,
		"seconds": (Time.get_ticks_msec() - _battle_msec) / 1000,
		"xp": xp, "gold": gold,
		"party": party.map(func(c: Combatant) -> Dictionary: return {"name": c.display_name, "lv": c.level, "hp": c.hp, "max_hp": c.max_hp, "ko": c.is_ko}),
		"dealt": _dealt, "taken": _taken, "healed": _healed,
	})
	_battle_fighters = []


# ---------------------------------------------------------------- XP

func xp(source: String, amount: int, member: Combatant, level_before: int) -> void:
	write("xp", {"source": source, "who": member.display_name, "amount": amount, "lv_before": level_before, "lv": member.level, "xp": member.xp, "to_next": member.xp_to_next})
