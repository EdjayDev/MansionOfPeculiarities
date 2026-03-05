class_name Level_2f_StorageRoom
extends BaseLevel

func _ready() -> void:
	set_level_name("2nd Floor Storage Room")
	scene_path = "res://game_scenes/level_2f_storageroom.tscn"
	await init_level()
	player.light_main.visible = true
	set_companion_subdialogs()
	
func set_companion_subdialogs()->void:
	var ember_line = [
		"It's dusty here!"
	]
	var luke_line = [
		"There must be something we can find here..."
	]
	for companion in get_companions():
		if companion.npc_id == "ember":
			await get_tree().create_timer(4.0).timeout
			game.set_subdialog(ember_line, companion)
		elif companion.npc_id == "luke":
			await get_tree().create_timer(3.0).timeout
			game.set_subdialog(luke_line, companion)
