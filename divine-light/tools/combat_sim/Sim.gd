extends Node
# Combat rework simulation (2026-11-01): checkpoints through the whole game at
# an expected level and gear, real Battle scenes, a "sensible player" AI.
# Each checkpoint: some random fights from the area (HP carries over), then the
# boss from full HP, then the same boss 3 levels higher.

var B: Dictionary
var planned: Dictionary = {}  # heroes already being healed this round
var STATE_SELECTING := 0
var STATE_OVER := 2
var only := ""

const SETS := {
	"Vael": ["Guardian Plate", "Guardian Helm", "Guardian Gauntlets", "Guardian Emblem"],
	"Ryn": ["Iron Monk Gi", "Iron Monk Headband", "Iron Knuckles", "Iron Monk Beads"],
	"Lyra": ["Arcane Robe", "Scholar's Circlet", "Scholar's Gloves", "Arcane Focus"],
	"Silas": ["Shadow Walker Garb", "Shadow Cowl", "Shadow Grips", "Shadow Sigil"],
}
const IRON := {"Vael": "Iron Sword", "Ryn": "Iron Claws", "Lyra": "Apprentice Staff", "Silas": "Twin Daggers"}
const STEEL := {"Vael": "Steel Sword", "Ryn": "Steel Claws", "Lyra": "Oak Staff", "Silas": "Steel Daggers"}
const ACT1_END := ["Guardian Plate", "Guardian Helm", "Guardian Gauntlets", "Guardian Emblem", "Iron Monk Gi", "Iron Monk Headband", "Iron Knuckles", "Iron Monk Beads", "Arcane Robe", "Scholar's Circlet", "Scholar's Gloves", "Arcane Focus", "Shadow Walker Garb", "Shadow Cowl", "Shadow Grips", "Shadow Sigil", "Steel Sword", "Steel Claws", "Oak Staff", "Steel Daggers"]
const NORD := ["Sacred Aegis Plate", "Storm Dragon Gi", "Elemental Weave Robe", "Venom Weave Garb", "Frostforged Sword", "Frostforged Claws", "Frostforged Staff", "Frostforged Daggers", "Aegis Sigil", "Dragon Pearl"]
const DUSK := ["Sacred Aegis Helm", "Storm Dragon Band", "Elemental Weave Hood", "Venom Weave Mask", "Sunsteel Sword", "Sunsteel Claws", "Sunsteel Staff", "Sunsteel Daggers", "Prism Focus", "Viper Fang Charm"]
const SELA := ["Sacred Aegis Gauntlets", "Storm Dragon Fists", "Elemental Weave Gloves", "Venom Weave Wraps", "Stormsilver Sword", "Stormsilver Claws", "Stormsilver Staff", "Stormsilver Daggers"]
const ACT3 := ["Starforged Sword", "Starforged Claws", "Starforged Staff", "Starforged Daggers", "Divine Champion Gauntlets", "Rising Force Fists", "Cosmic Conduit Gloves", "Death's Hand Wraps"]
const MAW := ["Divine Champion Plate", "Rising Force Gi", "Cosmic Conduit Robe", "Death's Hand Garb", "Divine Champion Helm", "Rising Force Band", "Cosmic Conduit Crown", "Death's Hand Mask", "Champion's Halo", "Phoenix Pearl", "Starlight Focus", "Reaper's Sigil"]


func _ready() -> void:
	if has_meta("driver"):
		_run()
		return
	var driver := Node.new()
	driver.set_script(get_script())
	driver.set_meta("driver", true)
	driver.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(driver)


func frames(n: int) -> void:
	for i in n:
		await get_tree().process_frame


func clicker() -> void:
	while true:
		if Cutscene.is_playing():
			var down := InputEventAction.new()
			down.action = &"confirm"
			down.pressed = true
			Input.parse_input_event(down)
			await frames(2)
			var up := InputEventAction.new()
			up.action = &"confirm"
			up.pressed = false
			Input.parse_input_event(up)
		await frames(3)


# ------------------------------------------------------------------ party
func party() -> Array:
	return GameManager.party


func make_party(classes: Array, level: int, gear: Array) -> void:
	GameManager.start_new_game(classes[0])
	for c: String in classes.slice(1):
		GameManager.recruit(c)
	for m: Combatant in party():
		for slot: String in m.equipment:
			m.equipment[slot] = ""
		while m.level < level:
			m.level_up()
	GameManager.inventory = {}
	for item: String in gear:
		for m: Combatant in party():
			if Equipment.can_equip(m, item) and _slot_wanted(m, item):
				Equipment.equip(m, item)
				break
	restore()


func _slot_wanted(m: Combatant, item: String) -> bool:
	var slot: String = Equipment.DEFS[item]["slot"]
	var cur: String = m.equipment.get(slot, "")
	if cur == item:
		return false
	if slot == "accessory" and cur != "" and Equipment.DEFS[item]["class"] == "":
		return false
	return true


func stock(items: Dictionary) -> void:
	for k: String in items:
		GameManager.inventory[k] = int(items[k])


func restore() -> void:
	for m: Combatant in party():
		m.is_ko = false
		m.hp = m.max_hp
		m.mp = m.max_mp
		m.qi = 0


# ------------------------------------------------------------------ AI
func alive_enemies(b: Node) -> Array:
	return b._enemies.filter(func(e: Combatant) -> bool: return e.is_alive())


func weakest_enemy_index(b: Node) -> int:
	var best := -1
	var best_hp := 1 << 30
	for i in b._enemies.size():
		var e: Combatant = b._enemies[i]
		if e.is_alive() and e.hidden_rounds <= 0:
			var score: int = e.hp - (100000 if e.is_boss else 0)
			if score < best_hp:
				best_hp = score
				best = i
	return maxi(best, 0)


func lyra_stance(b: Node, current: String) -> String:
	var foes := alive_enemies(b)
	if foes.any(func(e: Combatant) -> bool: return not e.aura_cycle.is_empty()):
		return current  # a shifting aura: just keep casting
	var best := current
	var best_score := -999
	for s: String in ["Fire", "Ice", "Lightning", "Earth"]:
		var el := s.to_lower()
		var score := 0
		for e: Combatant in foes:
			if b._is_weak(e, el):
				score += 2
			if el in e.immune:
				score -= 3
		if score > best_score:
			best_score = score
			best = s
	return best


func queue(m: Combatant, action: String, skill: Dictionary, target: int) -> void:
	m.queued_action = action
	m.queued_skill = skill
	m.queued_target = target


## A skill's damage as a multiple of a basic attack (roughly).
func skill_score(m: Combatant, s: Dictionary, n_alive: int) -> float:
	if not s.has("mult"):
		return 0.0
	var p := float(s["mult"]) * float(s.get("hits", 3 if s["effect"] == "multi_hit" else 1))
	if m.char_class == "Lyra":
		p *= float(m.int_stat) / maxf(1.0, m.atk)
	if s["target"] == "enemy_all":
		p *= maxf(1.0, n_alive * 0.75)
	return p


func choose(b: Node, m: Combatant, boss_fight: bool) -> void:
	var team: Array = b._party
	var foes := alive_enemies(b)
	var fallen := team.filter(func(c: Combatant) -> bool: return c.is_ko)
	var hurt := team.filter(func(c: Combatant) -> bool: return c.is_alive() and float(c.hp) / c.max_hp < 0.45 and not planned.has(c))
	hurt.sort_custom(func(a: Combatant, c: Combatant) -> bool: return float(a.hp) / a.max_hp < float(c.hp) / c.max_hp)
	b._open_skill_menu(m)
	var skills: Array = b._active_skills.duplicate()
	var affordable := func(s: Dictionary) -> bool:
		return (m.mp >= int(s["cost"])) if s["cost_type"] == "mp" else (m.qi >= int(s["cost"]))
	var vorath := foes.any(func(e: Combatant) -> bool: return e.display_name == "Vorath")
	if m.char_class == "Lyra" and not vorath:
		var want := lyra_stance(b, m.stance)
		if want != m.stance:
			for s: Dictionary in skills:
				if s["effect"] == "switch_stance" and s["to_stance"] == want:
					if Equipment.has_set_bonus(m, "arcane_scholar"):
						m.stance = want
						b._open_skill_menu(m)
						skills = b._active_skills.duplicate()
						break
					queue(m, "skill", s, -1)
					return
	if not fallen.is_empty():
		for s: Dictionary in skills:
			if s["effect"] == "resurrect" and affordable.call(s):
				queue(m, "skill", s, -1)
				return
		if int(GameManager.inventory.get("Phoenix Feather", 0)) > 0 and m.char_class != "Vael":
			queue(m, "item_use", B["ITEM_DEFS"]["Phoenix Feather"], -1)
			return
	if not hurt.is_empty():
		var low_count := team.filter(func(c: Combatant) -> bool: return c.is_alive() and float(c.hp) / c.max_hp < 0.55).size()
		var best_heal := {}
		for s: Dictionary in skills:
			if not affordable.call(s):
				continue
			if s["effect"] == "heal_all" and low_count >= 2:
				best_heal = s
				break
			if s["effect"] == "heal" and (best_heal.is_empty() or int(s["power"]) > int(best_heal["power"])):
				best_heal = s
		if not best_heal.is_empty() and (m.char_class == "Ryn" or m.char_class == "Vael"):
			planned[hurt[0]] = true
			queue(m, "skill", best_heal, team.find(hurt[0]))
			return
		if float(hurt[0].hp) / hurt[0].max_hp < 0.3:
			for item: String in ["Hi-Potion", "Elixir", "Potion"]:
				if int(GameManager.inventory.get(item, 0)) > 0:
					planned[hurt[0]] = true
					queue(m, "item_use", B["ITEM_DEFS"][item], team.find(hurt[0]))
					return
	if m.max_mp > 0 and float(m.mp) / m.max_mp < 0.15:
		for item: String in ["Hi-Ether", "Ether"]:
			if int(GameManager.inventory.get(item, 0)) > 0:
				queue(m, "item_use", B["ITEM_DEFS"][item], team.find(m))
				return
	var best := {}
	var best_score := 1.1
	for s: Dictionary in skills:
		if not str(s["target"]).begins_with("enemy") or not affordable.call(s):
			continue
		if s["cost_type"] == "mp" and not boss_fight and m.mp - int(s["cost"]) < m.max_mp * 0.3:
			continue
		var sc := skill_score(m, s, foes.size())
		if sc > best_score:
			best_score = sc
			best = s
	if not best.is_empty():
		queue(m, "skill", best, weakest_enemy_index(b))
		return
	queue(m, "attack", {}, weakest_enemy_index(b))


# ------------------------------------------------------------------ fights
var results: Array = []

func fight(label: String, location: String, enemies: Array, boss_fight := false) -> Dictionary:
	GameManager.current_location = location
	GameManager.debug_encounter = enemies
	get_tree().change_scene_to_file("res://scenes/battle/Battle.tscn")
	await frames(6)
	var b: Node = get_tree().current_scene
	var rounds := 0
	var guard_frames := 0
	var kos := 0
	var was_ko := {}
	var start_hp := party_hp()
	var min_hp := start_hp
	while b.state != STATE_OVER and rounds < 60:
		guard_frames += 1
		if guard_frames > 60000:
			print("STUCK ", label)
			break
		if b.state == STATE_SELECTING and not b._acting and not Cutscene.is_playing():
			planned = {}
			for m: Combatant in b._party:
				if m.is_alive():
					choose(b, m, boss_fight)
			b._reset_choices()
			for i in b._party.size():
				b._chosen[i] = true
			b._begin_resolving()
			rounds += 1
		for m: Combatant in b._party:
			if m.is_ko and not was_ko.get(m, false):
				kos += 1
			was_ko[m] = m.is_ko
		min_hp = minf(min_hp, party_hp())
		await get_tree().process_frame
	var won: bool = b._victory if b.state == STATE_OVER else false
	var r := {"label": label, "won": won, "rounds": rounds, "start": start_hp, "min": min_hp, "end": party_hp(), "kos": kos}
	print("  %-46s %s %2d rds | HP %3d%% -> low %3d%% -> %3d%% | KOs %d | %s" % [label.left(46), "WON " if won else "LOST", rounds, 100 * start_hp, 100 * min_hp, 100 * r["end"], kos, levels_short()])
	results.append(r)
	return r


func party_hp() -> float:
	var hp := 0
	var mx := 0
	for m: Combatant in party():
		hp += m.hp
		mx += m.max_hp
	return float(hp) / maxi(1, mx)


func levels_short() -> String:
	var out := []
	for m: Combatant in party():
		out.append("%s%d%s" % [m.display_name.left(2), m.level, "x" if m.is_ko else ""])
	return " ".join(out)


func randoms(label: String, location: String, n: int) -> void:
	var table: Array = EnemyData.ENCOUNTER_TABLES[location]
	table = table.filter(func(g: Array) -> bool: return g.size() <= party().size() + 1)
	for i in n:
		var group: Array = table[(i * 7 + 3) % table.size()]
		var names := []
		for e: Dictionary in group:
			names.append(e["name"])
		var r: Dictionary = await fight("%s #%d %s" % [label, i + 1, "+".join(names)], location, group.duplicate(true))
		if not r["won"]:
			restore()


func boss(label: String, location: String, data: Dictionary) -> void:
	var e: Dictionary = data.duplicate(true)
	e["is_boss"] = true
	restore()
	await fight(label, location, [e], true)


## A checkpoint: randoms at `level`, the boss at `level` and at `level + 3`.
func checkpoint(title: String, classes: Array, level: int, gear: Array, items: Dictionary, location: String, n_randoms: int, boss_label: String, boss_data: Dictionary) -> void:
	if only != "" and not title.contains(only):
		return
	print("== %s (Lv %d)" % [title, level])
	make_party(classes, level, gear)
	stock(items)
	if n_randoms > 0:
		await randoms(location, location, n_randoms)
	if not boss_data.is_empty():
		stock(items)
		await boss(boss_label, location, boss_data)
		make_party(classes, level + 3, gear)
		stock(items)
		await boss(boss_label + " (+3 levels)", location, boss_data)


# ------------------------------------------------------------------ run
func _run() -> void:
	await frames(2)
	only = OS.get_environment("SIM_ONLY")
	B = load("res://scripts/battle/Battle.gd").get_script_constant_map()
	Engine.time_scale = 16.0
	clicker()
	var bosses: Dictionary = EnemyData.BOSSES
	var few := {"Potion": 3, "Phoenix Feather": 1}
	# Act I: escapes alone at 2, a rescue alone at 5, a rescue with three at 8
	await checkpoint("I escape: Vael", ["Vael"], 2, [], few, "cathedral_escape", 3, "Hollow Warden", bosses["hollow_warden"])
	await checkpoint("I escape: Ryn", ["Ryn"], 2, [], few, "monastery_escape", 2, "Sparring Master", bosses["sparring_master"])
	await checkpoint("I escape: Lyra", ["Lyra"], 2, [], few, "observatory_escape", 2, "Void Sentinel", bosses["void_sentinel"])
	await checkpoint("I escape: Silas", ["Silas"], 2, [], few, "guild_escape", 2, "Corrupted Enforcer", bosses["corrupted_enforcer"])
	await checkpoint("I forest: Vael", ["Vael"], 4, [IRON["Vael"]], few, "overworld", 3, "", {})
	await checkpoint("I 2nd dungeon: Vael", ["Vael"], 5, SETS["Vael"] + [STEEL["Vael"]], {"Potion": 5, "Phoenix Feather": 1}, "monastery", 3, "Corrupted Grandmaster", bosses["corrupted_grandmaster"])
	await checkpoint("I 2nd dungeon: Ryn", ["Ryn"], 5, SETS["Ryn"] + [STEEL["Ryn"]], {"Potion": 5, "Phoenix Feather": 1}, "cathedral", 3, "Fallen Guardian", bosses["fallen_guardian"])
	await checkpoint("I 2nd dungeon: Lyra", ["Lyra"], 5, SETS["Lyra"] + [STEEL["Lyra"]], {"Potion": 5, "Phoenix Feather": 1}, "guild", 3, "Shadow Lord", bosses["shadow_lord"])
	await checkpoint("I 2nd dungeon: Silas", ["Silas"], 5, SETS["Silas"] + [STEEL["Silas"]], {"Potion": 5, "Phoenix Feather": 1}, "observatory", 3, "Void Archmage", bosses["void_archmage"])
	await checkpoint("I 3rd dungeon: duo", ["Vael", "Ryn"], 7, SETS["Vael"] + SETS["Ryn"] + [STEEL["Vael"], STEEL["Ryn"]], {"Potion": 6, "Ether": 3, "Phoenix Feather": 2}, "observatory", 3, "Void Archmage", bosses["void_archmage"])
	await checkpoint("I 4th dungeon: trio", ["Vael", "Ryn", "Lyra"], 8, SETS["Vael"] + SETS["Ryn"] + SETS["Lyra"] + [STEEL["Vael"], STEEL["Ryn"], STEEL["Lyra"]], {"Potion": 6, "Ether": 3, "Phoenix Feather": 2}, "guild", 3, "Shadow Lord", bosses["shadow_lord"])
	# Act II
	var ii := {"Potion": 10, "Ether": 5, "Hi-Potion": 3, "Phoenix Feather": 2}
	var four := ["Vael", "Ryn", "Lyra", "Silas"]
	await checkpoint("II Nordveil", four, 9, ACT1_END, ii, "frozen_citadel", 4, "Frozen Sovereign", bosses["frozen_sovereign"])
	await checkpoint("II Duskara", four, 11, ACT1_END + NORD, ii, "sunken_sanctum", 4, "Burning Tyrant", bosses["burning_tyrant"])
	await checkpoint("II Selavon", four, 13, ACT1_END + NORD + DUSK, ii, "drowned_fortress", 4, "Drowned Admiral", bosses["drowned_admiral"])
	# Act III
	var iii := {"Hi-Potion": 10, "Hi-Ether": 5, "Elixir": 3, "Phoenix Feather": 3}
	await checkpoint("III Reach", four, 16, ACT1_END + NORD + DUSK + SELA + ACT3, iii, "reach", 4, "Hollow Custodian", Quests.hunt_enemy("hollow_custodian"))
	await checkpoint("III Maw", four, 19, ACT1_END + NORD + DUSK + SELA + ACT3 + MAW, iii, "blighted_maw", 4, "Architect's Thrall", EnemyData.THRALL_GUARD)
	await checkpoint("III Vorath", four, 21, ACT1_END + NORD + DUSK + SELA + ACT3 + MAW, iii, "blighted_maw", 0, "VORATH", bosses["vorath"])
	print("SIM DONE")
	Engine.time_scale = 1.0
	get_tree().quit()
