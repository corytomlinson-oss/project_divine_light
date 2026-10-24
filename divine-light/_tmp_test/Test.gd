extends Node
# Playtest pass 3: load every Act II / III map in each state and screenshot it.

const OUT := "C:/vs_workspace/games/project_divine_light/previews/tour/"

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

func shot(name: String, scene: String, floor_n := 0) -> void:
	GameManager.dungeon_floor = floor_n
	GameManager.arrival = ""
	GameManager.has_pending_spawn = false
	get_tree().change_scene_to_file(scene)
	await frames(10)
	while Transition.is_busy() or Cutscene.is_playing():
		await frames(5)
	await frames(20)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUT + name + ".png")
	print("SHOT ", name)

func flags(list: Array) -> void:
	for f: String in list:
		GameManager.story_flags[f] = true

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	await frames(2)
	clicker()
	GameManager.start_new_game("Vael")
	for c in ["Ryn", "Lyra", "Silas"]:
		GameManager.recruit(c)
	flags(["act_one_complete", "threshold_arrived", "met_frank", "verdance_frank"])
	flags(["cleansed_nordveil", "cleansed_duskara", "cleansed_selavon", "act_two_complete"])
	await shot("r1_reach_before", "res://scenes/overworld/Reach.tscn")
	flags(["cleansed_maw", "game_complete"])
	await shot("r2_reach_after", "res://scenes/overworld/Reach.tscn")
	print("MUSIC ", Music._current)
	GameManager.story_flags.erase("cleansed_maw")
	await shot("r3_reach_before_again", "res://scenes/overworld/Reach.tscn")
	print("TOUR DONE")
	get_tree().quit()
