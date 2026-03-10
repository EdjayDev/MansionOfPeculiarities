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

const EMBER_DOUBLE = preload("uid://cmpm8nthykf05")
const LUKE_DOUBLE = preload("uid://do5h724s74s6y")
const ROSE_DOUBLE = preload("uid://y2xntg7g1n3i")

var host_intro_cutscene_started : bool

var companion : BaseNPC
var doppleganger
var friendship : int = 0

func _ready() -> void:
	set_level_name("???")
	scene_path = "res://game_scenes/level_c3_stage.tscn"
	await init_level()
	host_intro_area.body_entered.connect(host_intro_cutscene)
	if SessionState.get_scene_data("stage_intro_complete", false):
		companion = get_current_companion()
		return
	await intro_cutscene()
	
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
			doppleganger = npc_ember.new()
			doppleganger_mark.add_child(doppleganger)
		elif companion.npc_id == "ember":
			companion_dialogue.append_array(companion_dialogue_ember)
			doppleganger = npc_luke.new()
			doppleganger_mark.add_child(doppleganger)
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
		await game.vn_component_manager.get_dialogue(player_dialogue[1], player.player_name, player.player_dialogue_sprite)
		game.scene_manager.move_camera(player, player.global_position)
		await game.scene_manager.wait_time(1.0)
		game.scene_manager.reset_camera(player)
		game.end_cutscene(true)
		SessionState.input_locked = false
		SessionState.set_scene_data("stage_intro_complete", true)

func host_intro_cutscene(body_entered)->void:
	var companion_dialogue = [
		["Did you heard that, the door is opening!"]
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
		
	await game.scene_manager.wait_time(5.0)
	far_door.get_node("AnimationPlayer").play("door_open")
	game.vn_component_manager.get_dialogue(companion_dialogue[0], companion.npc_name, companion.npc_dialogue_sprite)
	game.scene_manager.move_camera(player, far_door_marker.global_position)
	await game.scene_manager.wait_time(2.5)
	game.scene_manager.reset_camera(player)
	while player.global_position.distance_to(far_door) > randf_range(50, 70):
		pass
	
	
	
	
		
		
		
		
		
