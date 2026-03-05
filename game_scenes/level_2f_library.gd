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
	"This placed, [Emphasis] though it feels abandoned, is never truly empty.",
	"Someone from afar, watching things unfold...",
]

var npc_companiondialogue_1 = [
	"Don't you mean that thing over there?....."
]

#Level Ghost Interaction
var ghost_interaction_1 = [
	"I need to find it..."
]
var player_ghost_interaction_1 = [
	"What are you looking for?[Emphasis] maybe we can help..."
]
var ghost_interaction_2 = [
	"I'm looking for a book of mine. [Emphasis] It was a book I always read and it was a gift by someone who I really love..."
]
var player_ghost_interaction_2 = [
	"Do you remember what kind of book it is?"
]
var ghost_interaction_3 = [
	"I can't remember what it is, nor can see anything.",
	"But I can feel it..."
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
	enemy_eye_watcher.eyewatcher_particle_emitted.connect(companion_subdialog)

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
		await game.vn_component_manager.get_dialogue(["We need to find the ke-"], player.player_name, player.player_dialogue_sprite)
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
		await game.scene_manager.wait_for([neutral_ghost])
		neutral_ghost.interaction_ready = true
		neutral_ghost.level_interaction_set.connect(interact_ghost)
		return
		
	#Player without Companion
	await game.scene_manager.wait_for([player])
	game.scene_manager.move_to(ghost_intro.global_position, neutral_ghost, 60)
	await game.vn_component_manager.get_dialogue(["I need to get the ke-"], player.player_name, player.player_dialogue_sprite)
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
	await game.scene_manager.wait_for([neutral_ghost])
	neutral_ghost.interaction_ready = true
	neutral_ghost.level_interaction_set.connect(interact_ghost)

func interact_ghost()->void:
	Game.manager.start_cutscene()
	SessionState.input_locked = true
	await game.vn_component_manager.get_dialogue(ghost_interaction_1, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(player_ghost_interaction_1, player.player_name, player.player_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(ghost_interaction_2, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(player_ghost_interaction_2, player.player_name, player.player_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(ghost_interaction_3, neutral_ghost.npc_name, neutral_ghost.npc_dialogue_sprite)
	Game.manager.end_cutscene(true)
	SessionState.input_locked = false
	
func companion_subdialog()->void:
	var eye_watcher_reaction = [
		"We need to be careful",
		"The eyes are are moving!"
	]
	var pickrandom_reaction = eye_watcher_reaction.pick_random()
	game.set_subdialog([pickrandom_reaction], get_current_companion())
	
