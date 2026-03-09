extends BaseLevel
class_name Level_C3_Stage

@onready var global_light: DirectionalLight2D = $Lights/GlobalLight

@onready var player_marker: Marker2D = $IntroCutsceneMarkers/Player_Marker
@onready var companion_marker_1: Marker2D = $IntroCutsceneMarkers/Companion_Marker1
@onready var player_marker_2: Marker2D = $IntroCutsceneMarkers/Player_Marker2
@onready var companion_marker_2: Marker2D = $IntroCutsceneMarkers/Companion_Marker2
@onready var stage_marker: Marker2D = $IntroCutsceneMarkers/Stage_Marker


var friendship : int = 0

func _ready() -> void:
	set_level_name("???")
	scene_path = "res://game_scenes/level_c3_stage.tscn"
	await init_level()
	await intro_cutscene()
	
func intro_cutscene()->void:
	var companion_dialogue = [
	["Did we finally get out?"],
	["There's a stage over there, and seats around us.[Emphasis] It seems like we are in a theatre room this time..."]
	]
	var player_dialogue = [
		["What is this place..."],
		["And a large bench at the top, if anything this looks more like a courtroom",
		"s find a way out immediately!"]
	]
	var player_response1 = [
		{"choice": "No, what do you think?", "choice_id": "sarcastic"},
		{"choice": "I think so", "choice_id": "reassure"},
		{"choice": "...", "choice_id": "nothing"}
	]
	if SessionState.get_difficulty() != "hard":
		var companion : BaseNPC = get_current_companion()
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
		await game.vn_component_manager.get_dialogue(companion_dialogue[1], companion.npc_name, companion.npc_dialogue_sprite)
		game.scene_manager.move_camera(player, stage_marker.global_position)
		
		
		
		
