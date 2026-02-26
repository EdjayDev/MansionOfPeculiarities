extends BaseLevel
class_name Level_C2_Bedroom

func _ready() -> void:
	set_level_name("Bedroom")
	scene_path = "res://game_scenes/level_c2_bedroom.tscn"
	await init_level()
	var subdialog_timer = Timer.new()
	subdialog_timer.one_shot = false
	subdialog_timer.wait_time = 30.0
	add_child(subdialog_timer)
	subdialog_timer.start()
	if get_current_companion():
		subdialog_timer.timeout.connect(companion_subdialog)
	
func companion_subdialog()->void:
	var random_subdialog = [
		"I once see a bedroom like exactly like this.",
		"Too many bookshelves for a bedroom don't you think?",
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], get_current_companion())
	pass
