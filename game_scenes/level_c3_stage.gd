extends BaseLevel
class_name Level_C3_Stage

@onready var player_marker: Marker2D = $IntroCutsceneMarkers/Player_Marker
@onready var companion_marker_1: Marker2D = $IntroCutsceneMarkers/Companion_Marker1
@onready var player_marker_2: Marker2D = $IntroCutsceneMarkers/Player_Marker2
@onready var companion_marker_2: Marker2D = $IntroCutsceneMarkers/Companion_Marker2
@onready var stage_marker: Marker2D = $IntroCutsceneMarkers/Stage_Marker

@onready var prop_door_type_1_: Node2D = $Y_Sort/Props_Container/prop_door_type1_
@onready var prop_door_type_1_2: Node2D = $Y_Sort/Props_Container/prop_door_type1_2

@onready var host_intro_area: Area2D = $HostIntro_Cutscene/HostIntro_Area
@onready var doppleganger_1: Marker2D = $HostIntro_Cutscene/Doppleganger_1
@onready var doppleganger_2: Marker2D = $HostIntro_Cutscene/Doppleganger_2
@onready var doppleganger_mark: Marker2D = $HostIntro_Cutscene/Doppleganger_Mark

@onready var doppleganger_sequence_marker: Area2D = $HostIntro_Cutscene/Doppleganger_SequenceMarker
@onready var remove_path: Node2D = $Remove_Path
@onready var stage_play: AnimationPlayer = $StagePlay

@onready var player_1: Marker2D = $HostIntro_Cutscene/Player_1
@onready var companion_1: Marker2D = $HostIntro_Cutscene/Companion_1


@onready var y_sort: Node2D = $Y_Sort

@onready var enemy_host: enemy_shadow = $Y_Sort/Enemy_Host

@onready var lost_companion_stage_marker: Marker2D = $HostIntro_Cutscene/LostCompanion_StageMarker
@onready var doppleganger_stage_marker: Marker2D = $HostIntro_Cutscene/Doppleganger_StageMarker
@onready var host_stage_marker: Marker2D = $HostIntro_Cutscene/Host_StageMarker

@onready var player_mark_end: Marker2D = $Ending/Player_Mark
@onready var companion_mark_end: Marker2D = $Ending/Companion_Mark
@onready var lost_companion_mark_end: Marker2D = $Ending/LostCompanion_Mark

var player_response_2 = null

const NPC_EMBER = preload("uid://0ypoy8tjpj7b")
const NPC_LUKE = preload("uid://c2xd64ynk4nbd")
const NPC_EMBER_DOPPLEGANGER = preload("uid://bbsenksw2acgm")
const NPC_LUKE_DOPPLEGANGER = preload("uid://c76wb230saepg")

var host_intro_cutscene_started : bool

@onready var gpu_particles_2d_1: GPUParticles2D = $Lights/GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $Lights/GPUParticles2D2


var companion : BaseNPC
var doppleganger : BaseNPC
var lost_companion : BaseNPC
var friendship : int = 0
var luke_friendship : int = 0
var ember_friendship : int = 0

func _ready() -> void:
	set_level_name("???")
	scene_path = "res://game_scenes/level_c3_stage.tscn"
	await init_level()
	host_intro_area.body_entered.connect(host_intro_cutscene)
	if SessionState.get_scene_data("stage_intro_complete", false):
		if SessionState.get_difficulty() != "hard":
			companion = get_current_companion()
			if companion.npc_id == "luke":
				doppleganger = NPC_EMBER_DOPPLEGANGER.instantiate()
				doppleganger_mark.add_child(doppleganger)
				lost_companion = NPC_EMBER.instantiate()
				doppleganger_mark.add_child(lost_companion)
			elif companion.npc_id == "ember":
				doppleganger = NPC_LUKE.instantiate()
				doppleganger_mark.add_child(doppleganger)
		return
	await intro_cutscene()

func timer_callback()->void:
	if player_response_2 == null:
		player_response_2 = "nothing"
		game.vn_component_manager.choice_made.emit("nothing")
		lost_companion.face_target(player)
		doppleganger.face_target(player)
		game.vn_component_manager.vn_component_choices_ui.clear_choices()
		
func intro_cutscene()->void:
	var companion_dialogue_ember = [
		["Uhhm...[Emphasis]Did we finally get out?"],
		["There's a stage over there, and seats around us.[Emphasis]Hmmmm, it seems like we are in a theatre room this time..."]
	]
	
	var companion_dialogue_luke = [
		["Did we finally get out?"],
		["There's a vast seats around us and stage over there with podiums, and a large bench at the top. This room is kind of like a courtroom if anything..."]
	]
	var companion_dialogue = []
	
	var player_dialogue = [
		["What is this place..."],
		["I have a bad feeling about this. Let's find the exit!"]
	]
	var player_response1 = [
		{"choice": "No, what do you think?", "choice_id": "sarcastic"},
		{"choice": "I think so", "choice_id": "reassure"},
		{"choice": "...", "choice_id": "nothing"}
	]
	if SessionState.get_difficulty() != "hard":
		companion = get_current_companion()
		if companion.npc_id == "luke":
			companion_dialogue.append_array(companion_dialogue_luke)
			doppleganger = NPC_EMBER_DOPPLEGANGER.instantiate()
			lost_companion = NPC_EMBER.instantiate()
			y_sort.add_child(doppleganger)
			y_sort.add_child(lost_companion)
			doppleganger.global_position = doppleganger_mark.global_position
			lost_companion.global_position = doppleganger_mark.global_position
			
		elif companion.npc_id == "ember":
			companion_dialogue.append_array(companion_dialogue_ember)
			doppleganger = NPC_LUKE.instantiate()
			lost_companion = NPC_LUKE_DOPPLEGANGER.instantiate()
			y_sort.add_child(doppleganger)
			y_sort.add_child(lost_companion)
			
			doppleganger.global_position = doppleganger_mark.global_position
			lost_companion.global_position = doppleganger_mark.global_position
		lost_companion.play_custom_animation("idle_down")
		doppleganger.play_custom_animation("idle_down")	
		game.start_cutscene()
		SessionState.input_locked = true
		game.scene_manager.move_to(player_marker.global_position, player, 30)
		game.scene_manager.move_to(companion_marker_1.global_position, companion, 30)
		await game.scene_manager.wait_for([companion])
		player.navigation_agent.target_reached.emit()
		companion.face_target(player)
		await game.vn_component_manager.get_dialogue(companion_dialogue[0], companion.npc_name, companion.npc_dialogue_sprite)
		player.face_target(companion)
		var friendship_check = await game.vn_component_manager.get_choices(player_response1)
		match friendship_check:
			"sarcastic":
				friendship -= 2
			"reassure":
				friendship += 1
			"nothing":
				friendship -= 1
		await game.scene_manager.wait_time(1.0)	
		game.scene_manager.move_to(player_marker_2.global_position, player, 30, true, "after", "idle_up")
		await game.scene_manager.wait_time(1.5)
		game.scene_manager.move_to(companion_marker_2.global_position, companion, 30, true, "after", "idle_up")
		await game.scene_manager.wait_for([player])
		await game.vn_component_manager.get_dialogue(player_dialogue[0], player.player_name, player.player_dialogue_sprite)
		game.scene_manager.move_camera(player, stage_marker.global_position)
		player.camera_2d.zoom = Vector2(2.0, 2.0) 
		await game.vn_component_manager.get_dialogue(companion_dialogue[1], companion.npc_name, companion.npc_dialogue_sprite)
		game.scene_manager.move_camera(player, player.global_position)
		player.play_custom_animation("idle_down")
		companion.play_custom_animation("idle_down")
		stage_play.play("remove_path")
		await stage_play.animation_finished
		await game.vn_component_manager.get_dialogue(player_dialogue[1], player.player_name, player.player_dialogue_sprite)
		remove_path.queue_free()
		await game.scene_manager.wait_time(1.0)
		game.scene_manager.reset_camera(player)
		game.end_cutscene(true)
		SessionState.input_locked = false
		SessionState.set_scene_data("stage_intro_complete", true)

func host_intro_cutscene(_body_entered)->void:
	var host_dialogue = [
		["You can call me Host."],
		["Let's play a game"],
		["find your real friend between these 2, and I can let some of you escape"],
		["Just find the difference"]
	]
	
	var companion_dialogue = [
		["Did you heard that, the door is opening!"],
		[lost_companion.npc_name + "!"],
		["No..."],
		["Who are you?"],
		["And the rules?"],
				
	]
	var lost_companion_ember_dialogue = [
		["You guys! Im so glad to see you"],
		["Rose? W-why?[Emphasis] did I do something wrong?"],
		["Then why?"],
		["No! I’m Ember. Luke, Rose, please believe me."],
		["You! You black monster! This is all your fault!"]
	]
	var player_responese2 = [
		{"choice": "STAY RIGHT THERE!", "choice_id": "reject"},
		{"choice": "Do nothing", "choice_id": "nothing"}
	]
	var player_intro_host_dialogue = [
		["STAY RIGHT THERE!"]
	]
	var doppleganger_dialogue = [
		["NO! that’s not me!"],
		["You’re not, I’m Ember!"],
		["If it weren’t for you, I wouldn’t have been separated from my friends!"]
	]
	if host_intro_cutscene_started:
		return
	host_intro_cutscene_started = true
	var far_door
	var far_door_marker
	var near_door
	var near_door_marker
	if player.global_position.distance_to(prop_door_type_1_.global_position) > player.global_position.distance_to(prop_door_type_1_2.global_position):
		far_door = prop_door_type_1_
		far_door_marker = doppleganger_1
		near_door = prop_door_type_1_2
		near_door_marker = doppleganger_2
	else:
		far_door = prop_door_type_1_2
		far_door_marker = doppleganger_2
		near_door = prop_door_type_1_
		near_door_marker = doppleganger_1
		
	await game.scene_manager.wait_time(2.0)
	far_door.get_node("AnimationPlayer").play("door_open")
	await game.scene_manager.wait_time(1.0)
	game.scene_manager.move_camera(player, far_door_marker.global_position)
	await game.vn_component_manager.get_dialogue(companion_dialogue[0], companion.npc_name, companion.npc_dialogue_sprite)
	await game.scene_manager.wait_time(1.5)
	game.scene_manager.reset_camera(player)
	await doppleganger_sequence_marker.area_entered
	game.start_cutscene()
	SessionState.input_locked = true
	#game.scene_manager.cancel_all_cutscene_movements()
	#Lost Companion appears
	lost_companion.global_position = far_door_marker.global_position
	game.scene_manager.move_camera(player, lost_companion.global_position)
	await game.vn_component_manager.get_dialogue(companion_dialogue[1], companion.npc_name, companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(lost_companion_ember_dialogue[0], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
	game.scene_manager.move_to(player_1.global_position, player, 20)
	game.scene_manager.move_to(companion_1.global_position, companion, 20)
	game.scene_manager.move_to(player.global_position, lost_companion, 50)
	game.scene_manager.reset_camera(player)
	var lost_companion_camera = Camera2D.new()
	lost_companion_camera.zoom = Vector2(3.0, 3.0)
	lost_companion.add_child(lost_companion_camera)
	lost_companion_camera.make_current()
	await game.scene_manager.wait_time(2.0)
	lost_companion_camera.queue_free()
	Game.manager.choice_timer.start_choice_timer(2.5)
	Game.manager.choice_timer.choice_timer_finished.connect(timer_callback)

	var choice_result = await game.vn_component_manager.get_choices(player_responese2)
	if player_response_2 == null:
		player_response_2 = choice_result

	var stop_distance := 100
	if player_response_2 == "nothing":
		stop_distance = 50

	while lost_companion.global_position.distance_to(player.global_position) > stop_distance:
		player.face_target(lost_companion)
		companion.face_target(lost_companion)
		await get_tree().physics_frame

	lost_companion.npc_navigation_agent.target_position = lost_companion.global_position
	lost_companion.face_target(player)
	companion.face_target(lost_companion)

	await Game.manager.choice_timer.stop_choice_timer()
	if Game.manager.choice_timer.choice_timer_finished.is_connected(timer_callback):
		Game.manager.choice_timer.choice_timer_finished.disconnect(timer_callback)

	match player_response_2:
		"reject":
			await game.vn_component_manager.get_dialogue(player_intro_host_dialogue[0], player.player_name, player.player_dialogue_sprite)
			await game.vn_component_manager.get_dialogue(lost_companion_ember_dialogue[1], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
			await game.vn_component_manager.get_dialogue(companion_dialogue[2], companion.npc_name, companion.npc_dialogue_sprite)
			await game.vn_component_manager.get_dialogue(lost_companion_ember_dialogue[2], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
		"nothing":
			pass
	game.scene_manager.reset_camera(player)
	near_door.get_node("AnimationPlayer").play("door_open")
	await game.scene_manager.wait_time(1.5)
	doppleganger.global_position = near_door_marker.global_position
	await game.scene_manager.wait_time(0.5)
	game.scene_manager.move_camera(player, doppleganger.global_position)
	await game.vn_component_manager.get_dialogue(doppleganger_dialogue[0], doppleganger.npc_name, doppleganger.npc_dialogue_sprite)
	game.scene_manager.move_to(player.global_position, doppleganger, 70)
	game.vn_component_manager.get_dialogue(["What is happening!?"], companion.npc_name, companion.npc_dialogue_sprite)
	await game.scene_manager.wait_time(1.5)
	game.scene_manager.reset_camera(player)
	while doppleganger.global_position.distance_to(player.global_position) > stop_distance:
		player.face_target(doppleganger)
		companion.face_target(doppleganger)
		await get_tree().physics_frame
	doppleganger.npc_navigation_agent.target_position = doppleganger.global_position
	doppleganger.face_target(player)
	await game.vn_component_manager.get_dialogue(lost_companion_ember_dialogue[3], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(doppleganger_dialogue[1], doppleganger.npc_name, doppleganger.npc_dialogue_sprite)
	await game.scene_manager.wait_time(1.0)
	doppleganger.face_target(enemy_host)
	lost_companion.face_target(enemy_host)
	player.face_target(enemy_host)
	companion.face_target(enemy_host)
	enemy_host.visible = true
	await game.scene_manager.wait_time(1.5)
	game.scene_manager.move_camera(player, enemy_host.global_position)
	await game.vn_component_manager.get_dialogue(["...!"], player.player_name, player.player_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(["( I can't speak...[Emphasis] and move!)"], player.player_name, player.player_dialogue_sprite)
	await game.screen_effect_ui.set_effect("fade_out", 1.0)
	lost_companion.global_position = lost_companion_stage_marker.global_position
	doppleganger.global_position = doppleganger_stage_marker.global_position
	enemy_host.global_position = host_stage_marker.global_position
	doppleganger.play_custom_animation("idle_down")
	lost_companion.play_custom_animation("idle_down")
	game.scene_manager.move_camera(player, enemy_host.global_position)
	await game.screen_effect_ui.set_effect("fade_in", 1.0)
	await game.vn_component_manager.get_dialogue(lost_companion_ember_dialogue[4], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(doppleganger_dialogue[2], doppleganger.npc_name, doppleganger.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(companion_dialogue[3], companion.npc_name, companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(host_dialogue[0], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	var player_host_question = [
		{"choice": "What do you want?", "choice_id": "ask_host"},
		{"choice": "Let us go!", "choice_id": "letgo_host"}
	]
	
	var player_host_response = await game.vn_component_manager.get_choices(player_host_question)
	match player_host_response:
		"ask_host":
			luke_friendship += 1
		"letgo_host":
			ember_friendship += 1
	await game.vn_component_manager.get_dialogue(host_dialogue[1], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(host_dialogue[2], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(companion_dialogue[4], companion.npc_name, companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(host_dialogue[3], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	run_stage_play()

func run_stage_play()->void:
	var host_dialogue_stage_play = [
		["So, who is the real " + lost_companion.npc_name + "?"]
	]
	var game_instructions = [
		"TRY TO SPOT THE DIFFERENCE!"
	]
	var difference_choices : Dictionary
	match game_difficulty:
		"easy":
			difference_choices = {
			"choices": [
			{"choice": "HAIR", "choice_id": "hair"},
			{"choice": "EARS", "choice_id": "ears"},
			{"choice": "EARRINGS", "choice_id": "earrings"},
			{"choice": "EYES", "choice_id": "eye"},
			{"choice": "RIBBON", "choice_id": "ribbon"},
			{"choice": "CLOTH", "choice_id": "cloth"},
			],
			"min_choice": 1,
			"max_choice": 3,
			"right_answer": [""]
		}
		"medium":
			difference_choices = {
			"choices": [
			{"choice": "HAIR", "choice_id": "hair"},
			{"choice": "EARS", "choice_id": "ears"},
			{"choice": "EARRINGS", "choice_id": "earrings"},
			{"choice": "EYES", "choice_id": "eye"},
			{"choice": "RIBBON", "choice_id": "ribbon"},
			{"choice": "CLOTH", "choice_id": "cloth"},
			],
			"min_choice": 1,
			"max_choice": 3
		}
	
	await game.vn_component_manager.get_narration(game_instructions)              
	var selected_choices = await game.vn_component_manager.get_multiplechoices(difference_choices["choices"], difference_choices["min_choice"], difference_choices["max_choice"])
	#match selected_choices:
	await game.vn_component_manager.get_dialogue(host_dialogue_stage_play[0], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	var choose_ember_choices = [
		{"choice": "Ember 1", "choice_id": "lost_companion"},
		{"choice": "Ember 2", "choice_id": "doppleganger"}
	]
	var escapee
	var chosen_lost_companion = await game.vn_component_manager.get_choices(choose_ember_choices)
	match chosen_lost_companion:
		"lost_companion":
			escapee = lost_companion
		"doppleganger":
			escapee = doppleganger
	#skipped chosen dialogue - test
	await Game.manager.screen_effect_ui.set_effect("fade_out", 0.5)
	Game.manager.scene_manager.reset_camera(player)
	enemy_host.global_position = doppleganger_mark.global_position
	
	player.global_position = player_mark_end.global_position
	lost_companion.global_position = lost_companion_mark_end.global_position
	companion.global_position = companion_mark_end.global_position  
	await Game.manager.screen_effect_ui.set_effect("fade_in", 0.5)
	#face target alt
	lost_companion.play_custom_animation("idle_up")
	companion.play_custom_animation("idle_up")
	player.play_custom_animation("idle_up")
	lost_companion.face_target(enemy_host)
	companion.face_target(enemy_host)
	player.face_target(enemy_host)

	await game.vn_component_manager.get_dialogue(["It would be best if your group decides who stay here"], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(["All those troubles to find out who the real me is, and one of us must stay?!"], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(["And...who gets to decide that?"], companion.npc_name, companion.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(["the script must be followed, with these 2 keys that I’ll provide you, Rose gets to decide who gets to escape or stay"], enemy_host.npc_name, enemy_host.npc_dialogue_sprite)
	#face target alt
	lost_companion.play_custom_animation("idle_down")
	companion.play_custom_animation("idle_down")
	lost_companion.face_target(player)
	companion.face_target(player)

	await game.vn_component_manager.get_narration(["Luke and Ember looks to you, worried…", "Who will stay?[Emphasis=2.0]"])
	var character_stay_choices = [
		{"choice": "Luke", "choice_id": "luke_stay"},
		{"choice": "Ember", "choice_id": "ember_stay"},
		{"choice": "You", "choice_id": "stay"}
	]
	var staying_character
	var character_stay = await game.vn_component_manager.get_choices(character_stay_choices)
	enemy_host.queue_free()
	match character_stay:
		"luke_stay":
			await game.vn_component_manager.get_dialogue(["I Understand..."], companion.npc_name, companion.npc_dialogue_sprite)
			staying_character = get_npc_by_id("luke")
		"ember_stay":
			await game.vn_component_manager.get_dialogue(["Its…[Emphasis=2.0] its alright, I’ll find my way out on my own..."], lost_companion.npc_name, lost_companion.npc_dialogue_sprite)
			staying_character = get_npc_by_id("ember")
		"stay":
			await game.vn_component_manager.get_dialogue(["Are you serious?"], companion.npc_name, companion.npc_dialogue_sprite)
			await game.vn_component_manager.get_dialogue(["How selfless of you..."], companion.npc_name, companion.npc_dialogue_sprite)
			player.visible = false
			staying_character = player
		
	var tween = create_tween()
	tween.tween_property(
		staying_character,
		"modulate",
		Color(0, 0, 0, 0), 
		5.0
	).set_trans(Tween.TRANS_CUBIC)
	await Game.manager.screen_effect_ui.set_effect("fade_out", 0.5)
