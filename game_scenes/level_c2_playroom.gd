extends BaseLevel
class_name Level_C2_Playroom

func _ready() -> void:
	set_level_name("Playroom")
	scene_path = "res://game_scenes/level_c2_playroom.tscn"
	await init_level()
	player.light_main.visible = true
	await intro_cutscene()
	var subdialog_timer = Timer.new()
	subdialog_timer.one_shot = false
	subdialog_timer.wait_time = 30.0
	add_child(subdialog_timer)
	subdialog_timer.start()
	if get_current_companion():
		subdialog_timer.timeout.connect(companion_subdialog)
	else:
		subdialog_timer.timeout.connect(player_subdialog)
	
func player_subdialog()->void:
	var random_subdialog = [
		"This place is very weird...",
		"How do I get out"
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], player)
	pass

func companion_subdialog()->void:
	var random_subdialog = [
		"I remember seeing this somewhere...",
		"mmm, I feeling dizzy...",
	]
	#test
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], get_current_companion())
	pass

@onready var player_: Marker2D = $IntroCutscene/Player_
func intro_cutscene()->void:
	game.start_cutscene()
	SessionState.input_locked = true
	game.scene_manager.move_to(player_.global_position, player, 50)
	game.end_cutscene(true)
	SessionState.input_locked = false
	pass
