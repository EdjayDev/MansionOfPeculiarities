class_name Level_2f_Playground
extends BaseLevel

var companion_luke_subdialogue1 = [
	"I hope she is safe"
]

var companion_ember_subdialogue1 = [
	"I hope he is there"
]

var picked_subdialogue

func _ready() -> void:
	set_level_name("2nd Floor Small Room")
	scene_path = "res://game_scenes/level_2f_playground.tscn"

	await init_level()
	print("Level_2f_Playground ready")
	player.light_main.visible = true	
	game.set_bgmusic_setting(-10.0, 0.9)
	var visited : bool = SessionState.get_scene_data("visited_before", false)
	var subdialogue_timer = Timer.new()
	add_child(subdialogue_timer)
	subdialogue_timer.one_shot = false
	subdialogue_timer.wait_time = 10.0
	subdialogue_timer.start()
	#check companion
	var npc_companion = get_current_companion()
	print("npc companion: ", npc_companion)
	if SessionState.get_difficulty() != "hard":
		match npc_companion.npc_id:
			"luke":
				picked_subdialogue = companion_luke_subdialogue1
			"ember":
				picked_subdialogue = companion_ember_subdialogue1
		subdialogue_timer.timeout.connect(set_subdialogue)
		
	if not visited:
		game.screen_effect_ui.text_chaptername.text = "Chapter 1"
		game.screen_effect_ui.text_chaptertext.text = "Escape"
		game.screen_effect_ui.text_chaptername.visible = true
		game.screen_effect_ui.text_chaptertext.visible = true
		await game.screen_effect_ui.set_effect("show_chapter", 1)
		SessionState.set_scene_data("visited_before", true)
		player.show_emote("exclamation")

func set_subdialogue()->void:
	pass
	#game.set_subdialog(picked_subdialogue, get_current_companion())
