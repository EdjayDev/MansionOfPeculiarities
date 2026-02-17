extends BaseLevel
class_name Level_C2_Classroom

func _ready() -> void:
	set_level_name("Classroom")
	scene_path = "res://game_scenes/level_c2_classroom.tscn"
	await init_level()
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
		"Am I trapped",
		"How do I get out"
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], player)
	pass

func companion_subdialog()->void:
	var random_subdialog = [
		"It's been a while",
		"Can't we break outside these walls",
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], get_current_companion())
	pass
