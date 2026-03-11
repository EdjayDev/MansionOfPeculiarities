extends BaseLevel
class_name Level_2f


@onready var intro_player: Marker2D = $Intro_PathMarkers/intro_player
@onready var intro_ember: Marker2D = $Intro_PathMarkers/intro_ember
@onready var intro_luke: Marker2D = $Intro_PathMarkers/intro_luke

@onready var intro_player_2: Marker2D = $Intro_PathMarkers/intro_player2
@onready var intro_ember_2: Marker2D = $Intro_PathMarkers/intro_ember2
@onready var intro_luke_2: Marker2D = $Intro_PathMarkers/intro_luke2

@onready var outro_exit: Marker2D = $Intro_PathMarkers/outro_exit
@onready var shadow: enemy_shadow = $Y_Sort/Enemy_Shadow
@onready var shadow_mark: Marker2D = $Intro_PathMarkers/shadow_mark

@onready var dark_swarm: Shadow_Swarm = $Dark_Swarm

@onready var new_path_runaway: Node2D = $NewPath_Runaway
@onready var remove_path: Node2D = $NewPath_Runaway/Remove_Path
@onready var new_path: Node2D = $NewPath_Runaway/New_Path

@onready var ghost_exit: Marker2D = $Intro_PathMarkers/ghost_exit
@onready var shadow_mark_2: Marker2D = $Intro_PathMarkers/shadow_mark2

var choices = [
	{"choice": "Grab Luke", "choice_id": "easy"},
	{"choice": "Grab Ember", "choice_id": "medium"},
	{"choice": "Run Away", "choice_id": "hard"}
]

func _ready() -> void:
	set_level_name("2nd Floor")
	scene_path = "res://game_scenes/level_2f.tscn"
	await init_level()
	print("Level 2f ready")
	#Game.manager.choice_timer.connect()
	await intro_cutscene()
	
func intro_cutscene() -> void:
	var luke = get_npc_by_id("luke")
	var ember = get_npc_by_id("ember")
	if SessionState.get_global_data("faced_shadow", false):
		prologue_end_cutscene()
		return
	#If Intro Cutscene for this level has been finished
	if SessionState.get_scene_data("IntroCutscene_2f", false):
		luke.global_position = SessionState.get_npc_position(luke.npc_id, LEVEL_NAME)
		ember.global_position = SessionState.get_npc_position(ember.npc_id, LEVEL_NAME)
		return
		
	#Intro Cutscene
	SessionState.input_locked = true
	await get_tree().process_frame
	game.start_cutscene()
	
	#cutscene flow
	game.scene_manager.move_to(intro_player.global_position, player, 20)
	game.scene_manager.move_to(intro_luke.global_position, luke, 20)
	game.scene_manager.move_to(intro_ember.global_position, ember, 20)
	
	await game.scene_manager.wait_for([luke,ember])
	
	game.end_cutscene(true)
	SessionState.input_locked = false
	SessionState.set_scene_data("IntroCutscene_2f", true)

func prologue_end_cutscene()->void:
	var dialogue_facingluke = [
		"I think we lost that thing..."
	]
	var luke_dialogue = [
		"I knew this will be a bad idea...[Emphasis]",
		"We need to get out but where should we go?"
	]
	
	var ember_dialogue = [
		"That path wasn't there before right, guys?"
	]
	var luke = get_npc_by_id("luke")
	var ember = get_npc_by_id("ember")
	remove_path.queue_free()
	new_path.visible = true
	
	SessionState.input_locked = true
	await get_tree().process_frame
	game.start_cutscene()
	
	game.scene_manager.move_to(intro_player_2.global_position, player, 70)
	game.scene_manager.move_to(intro_luke_2.global_position, luke, 70)
	game.scene_manager.move_to(intro_ember_2.global_position, ember, 70)
	await game.scene_manager.wait_for([player, luke, ember])
	
	luke.face_target(player)
	player.face_target(luke)
	ember.face_target(player)
	await game.vn_component_manager.get_dialogue(dialogue_facingluke, player.player_name, player.player_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(luke_dialogue, luke.npc_name, luke.npc_dialogue_sprite)
	player.face_target(ember)
	await game.vn_component_manager.get_dialogue(ember_dialogue, ember.npc_name, ember.npc_dialogue_sprite)
	game.scene_manager.move_camera(player, player.global_position - Vector2(0, 100))
	await game.scene_manager.wait_time(2.0)
	game.scene_manager.move_camera(player, player.global_position)
	game.scene_manager.reset_camera(player)
	dark_swarm.dark_swarm(4.0)
	dark_swarm.set_particle_emission(true)
	await get_tree().create_timer(2.5).timeout

	game.scene_manager.move_to(shadow_mark.global_position, shadow, 20)
	game.scene_manager.shake_camera(player.camera_2d, 1.0, 2.0, 5.0) 
	player.face_target(shadow)
	ember.face_target(shadow)
	luke.face_target(shadow)
	Game.manager.choice_timer.start_choice_timer()
	game.set_subdialog(["We need to get to the other side of the hallway!"], luke)
	game.set_subdialog(["Maybe we should try that new path..."], ember)
	game.set_subdialog(["No! That could be a dead end. We don't know what's ahead."], luke)
	game.set_subdialog(["Dead ends are boring. I say we take the risk!"], ember)
	game.set_subdialog(["Ember, we can't just take that kind of risk!"], luke)
	game.set_subdialog(["We don't have time to argue. We have to choose now!"], luke)
	Game.manager.choice_timer.choice_timer_finished.connect(curse_player)
	var difficulty = await game.vn_component_manager.get_choices(choices)
	if difficulty:
		Game.manager.choice_timer.choice_timer_finished.disconnect(curse_player)
		await Game.manager.choice_timer.stop_choice_timer()
	match difficulty:
		"easy":
			SessionState.remove_companion("ember")
			ember.is_following_player = false
			await game.vn_component_manager.get_dialogue(["luke come with me!"], player.player_name, player.player_dialogue_sprite)
			game.scene_manager.move_to(luke.global_position, player, 60)
			await game.scene_manager.wait_for([player])
			game.scene_manager.move_to(outro_exit.global_position, player, 130)
			game.scene_manager.move_to(outro_exit.global_position, luke, 120)
			ember.face_target(player)
			game.scene_manager.move_to(ghost_exit.global_position, ember, 95)
			await game.scene_manager.wait_for([player,luke])
			player.visible = false
			luke.visible = false
			await game.scene_manager.wait_time(1.0)
		"medium":
			SessionState.remove_companion("luke")
			await game.vn_component_manager.get_dialogue(["ember come with me!"], player.player_name, player.player_dialogue_sprite)
			game.scene_manager.move_to(ember.global_position, player, 60)
			await game.scene_manager.wait_for([player])
			game.scene_manager.move_to(outro_exit.global_position, player, 130)
			game.scene_manager.move_to(outro_exit.global_position, ember, 125)
			luke.face_target(player)
			game.scene_manager.move_to(ghost_exit.global_position, luke, 85)
			luke.is_following_player = false
			await game.scene_manager.wait_for([player,ember])
			player.visible = false
			ember.visible = false
			await game.scene_manager.wait_time(1.0)
		"hard":
			SessionState.clear_companion()
			game.scene_manager.move_to(outro_exit.global_position, player, 130)
			luke.face_target(player)
			ember.face_target(player)
			await get_tree().create_timer(1.5).timeout
			game.scene_manager.move_to(ghost_exit.global_position, ember, 115)
			game.scene_manager.move_to(ghost_exit.global_position, luke, 95)
			ember.is_following_player = false
			luke.is_following_player = false
			await game.scene_manager.wait_for([player])
			await game.vn_component_manager.get_dialogue(["..."], player.player_name, player.player_dialogue_sprite)
			player.face_target(shadow)
			player.play_custom_animation("idle_up")
			await game.scene_manager.wait_time(1.0)
			player.visible = false

	SessionState.set_difficulty(difficulty)
	SessionState.set_scene_data("IntroCutscene_2f_end", true)
	game.end_cutscene(true)
	SessionState.input_locked = false
	return

func curse_player()->void:
	SessionState.set_difficulty("hard")
	SessionState.set_scene_data("IntroCutscene_2f_end", true)
	await Game.manager.choice_timer.stop_choice_timer()
	Game.manager.vn_component_manager.vn_component_choices_ui.clear_choices()
	SessionState.clear_companion()
	var luke = get_npc_by_id("luke")
	var ember = get_npc_by_id("ember")
	game.scene_manager.move_to(shadow_mark_2.global_position, shadow, 30)
	await game.scene_manager.wait_time(2.0)
	await game.vn_component_manager.get_dialogue(["( I can't move... )"], player.player_name, player.player_dialogue_sprite)
	luke.animation_player.pause()
	ember.animation_player.pause()
	await game.scene_manager.wait_time(1.5)
	await game.vn_component_manager.get_dialogue(["( Luke...? Ember..? )"], player.player_name, player.player_dialogue_sprite)
	var luke_tween = create_tween()
	luke_tween.tween_property(luke, "modulate", Game.manager.BACKGROUND, 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var ember_tween = create_tween()
	ember_tween.tween_property(ember, "modulate", Game.manager.BACKGROUND, 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await game.scene_manager.wait_time(1.0)
	await game.vn_component_manager.get_dialogue(["..."], player.player_name, player.player_dialogue_sprite)
	var player_tween = create_tween()
	player_tween.tween_property(player, "modulate", Game.manager.BACKGROUND, 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	player.animation_player.pause()
	await game.scene_manager.wait_time(2.0)
	await game.screen_effect_ui.set_effect("fade_out", 0.5)
	game.load_level("res://game_scenes/level_2f_playground.tscn", "Player_from2F")
	game.end_cutscene(true)
	player.modulate = Color.WHITE
	player.play_custom_animation("idle_up")
