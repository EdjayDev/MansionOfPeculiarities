class_name Level_2f_GuestRoom
extends BaseLevel

func _ready() -> void:
	set_level_name("2nd Floor Guest Room")
	scene_path = "res://game_scenes/level_2f_guestroom.tscn"
	await init_level()
	player.light_main.visible = true
	set_companion_subdialogs()
	
func set_companion_subdialogs()->void:
	var ember_line = [
		"This room is quite neat..."
	]
	var luke_line = [
		"This must've been a room for their guest"
	]
	for companion in get_companions():
		if companion.npc_id == "ember":
			await get_tree().create_timer(4.0).timeout
			game.set_subdialog(ember_line, companion)
		elif companion.npc_id == "luke":
			await get_tree().create_timer(3.0).timeout
			game.set_subdialog(luke_line, companion)
