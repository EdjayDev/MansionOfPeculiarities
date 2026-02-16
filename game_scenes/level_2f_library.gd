class_name Level_2f_Library
extends BaseLevel

@onready var neutral_ghost: Neutral_Ghost = $Y_Sort/Neutral_Ghost
@onready var enemy_eye_watcher: Enemy_EyeWatcher = $Y_Sort/Enemy_EyeWatcher
@onready var canvas_modulate: CanvasModulate = $Lights/CanvasModulate

@onready var player_intro: Marker2D = $Intro_Markers/Player_Intro
@onready var companion_intro: Marker2D = $Intro_Markers/Companion_Intro
@onready var ghost_intro: Marker2D = $Intro_Markers/Ghost_Intro
@onready var eye_watcher_intro: Marker2D = $Intro_Markers/EyeWatcher_Intro
@onready var ghost_intro_2: Marker2D = $Intro_Markers/Ghost_Intro2
@onready var companion_intro_2: Marker2D = $Intro_Markers/Companion_Intro2
@onready var player_intro_2: Marker2D = $Intro_Markers/Player_Intro2

var npc_companion : BaseNPC

var ghost_introdialogue_1 = [
	"You can hear me... can't you?",
	"Stay still.[Emphasis=1.0] ",
	"We're both searching for something... [Emphasis=0.325] I can tell."
]

var ghost_introdialogue_2 = [
	"This placed, [Emphasis] at first seems dormant is being watched.",
	"Someone from afar, watching their scene unfold...",
]

var npc_companiondialogue_1 = [
	"Don't you mean that thing over there?....."
]

func _ready() -> void:
	set_level_name("2nd Floor Library")
	scene_path = "res://game_scenes/level_2f_library.tscn"
	await init_level()
	print("Level 2f Library ready")
	player.light_main.visible = true
	
	if SessionState.get_scene_data("2f_library_ghostfree", false):
		neutral_ghost.queue_free()
	if SessionState.get_global_data("eyewatcher_introduction", false):
		game.scene_manager.move_to(ghost_intro_2.global_position, neutral_ghost, 30)
		if enemy_eye_watcher:
			enemy_eye_watcher.set_canvas(canvas_modulate)
		return

	await play_intro_cutscene()
	
func play_intro_cutscene()->void:
	SessionState.input_locked = true
	game.start_cutscene()
	game.scene_manager.move_to(player_intro.global_position, player, 60)
	
	#Player w/ Companioon
	if game_difficulty != "hard":
		npc_companion = get_current_companion()
		game.scene_manager.move_to(companion_intro.global_position, npc_companion, 60)
	
		await game.scene_manager.wait_for([player])
		game.scene_manager.move_to(ghost_intro.global_position, neutral_ghost, 60)
		await game.vn_component_manager.get_dialogue(["We need to find the ke-"], "I", player.player_dialogue_sprite)
		player.show_emote("exclamation")
		
		await game.scene_manager.wait_for([neutral_ghost])
		npc_companion.face_target(neutral_ghost)
		player.face_target(neutral_ghost)
		
		await game.vn_component_manager.get_dialogue(ghost_introdialogue_1, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
		await game.vn_component_manager.get_dialogue(ghost_introdialogue_2, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
		game.scene_manager.move_to(companion_intro_2.global_position, npc_companion, 30)
		await game.scene_manager.wait_for([npc_companion])
		npc_companion.face_target(enemy_eye_watcher)
		await game.vn_component_manager.get_dialogue(npc_companiondialogue_1, npc_companion.name, npc_companion.npc_dialogue_sprite)
		game.scene_manager.move_camera(player, eye_watcher_intro.global_position)
		game.scene_manager.move_to(player_intro_2.global_position, player, 30)
		await game.scene_manager.wait_for([player])
		await get_tree().create_timer(3.0).timeout
		game.scene_manager.move_to(ghost_intro_2.global_position, neutral_ghost, 40)
		game.scene_manager.reset_camera(player)
		player.face_target(enemy_eye_watcher)
		game.end_cutscene(true)
		SessionState.input_locked = false
		SessionState.set_global_data("eyewatcher_introduction", true)
		enemy_eye_watcher.set_canvas(canvas_modulate)
		return
		
	#Player without Companion
	await game.scene_manager.wait_for([player])
	game.scene_manager.move_to(ghost_intro.global_position, neutral_ghost, 60)
	await game.vn_component_manager.get_dialogue(["I need to get the ke-"], "I", player.player_dialogue_sprite)
	player.show_emote("exclamation")
	
	player.face_target(neutral_ghost)
	await game.scene_manager.wait_for([neutral_ghost])
	
	await game.vn_component_manager.get_dialogue(ghost_introdialogue_1, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)

	await game.vn_component_manager.get_dialogue(ghost_introdialogue_2, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
	game.scene_manager.move_to(ghost_intro_2.global_position, neutral_ghost, 30)
	game.scene_manager.reset_camera(player)
	
	game.end_cutscene(true)
	SessionState.input_locked = false
	SessionState.set_global_data("eyewatcher_introduction", true)
	enemy_eye_watcher.set_canvas(canvas_modulate)
