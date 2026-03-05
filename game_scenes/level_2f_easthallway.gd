class_name Level_2f_EastHallway
extends BaseLevel

func _ready() -> void:
	set_level_name("2nd Floor East Hallway")
	scene_path = "res://game_scenes/level_2f_easthallway.tscn"
	await init_level()
	player.light_main.visible = true
