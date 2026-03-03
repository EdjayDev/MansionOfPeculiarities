extends BaseLevel
class_name Level_C2_Graffiti

@onready var global_light: DirectionalLight2D = $Lights/GlobalLight

func _ready() -> void:
	set_level_name("Graffiti")
	scene_path = "res://game_scenes/level_c2_graffiti.tscn"
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
		"There's so much drawing",
		"These room reminded me of him...",
	]
	#test
	global_light.energy = randf_range(0.0, 0.33)
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], get_current_companion())
	pass
