extends BaseLevel
class_name Level_Main

@onready var luke: npc_luke = $Y_Sort/NPC_Luke
@onready var ember: npc_ember = $Y_Sort/NPC_Ember

#cutscene markers
@onready var target_point_camera: Marker2D = $PathMarkers_Intro/TargetPoint_camera
@onready var target_point_player: Marker2D = $PathMarkers_Intro/TargetPoint_Player
@onready var target_point_npc_luke: Marker2D = $PathMarkers_Intro/TargetPoint_npcluke
@onready var target_point_npc_ember: Marker2D = $PathMarkers_Intro/TargetPoint_npcember

@onready var target_point_npc_ember_2: Marker2D = $"PathMarkers_Intro/TargetPoint_npcember-2"
@onready var target_point_npc_luke_2: Marker2D = $"PathMarkers_Intro/TargetPoint_npcluke-2"

@onready var target_point_npcember_3: Marker2D = $"PathMarkers_Intro/TargetPoint_npcember-3"
@onready var target_point_npcluke_3: Marker2D = $"PathMarkers_Intro/TargetPoint_npcluke-3"

var ember_dialogue = [
	#intro dialogue #1
	[
		"Isn't this interesting? [Emphasis=1.5] this mansion is uninhabited.",
		"It seems like they left unprepared, lights are lit, doors are open...",
		"Why don't we go upstairs?"
	],
	#reply #4
	[
		"..."
	]
]

var luke_dialogue = [
	#reply #2
	[
		"We dont know that yet...",
		"Maybe we can find something here about the people of this mansion"
	],
	#continue #3
	[
		"For now, let's just stay here so we dont lose each other."
	]
]

var luke_interaction_dialogue = [
	"It seems "
]

func _ready() -> void:
	set_level_name("1st Floor Living Room")
	scene_path = "res://game_scenes/level_1f_livingroom.tscn"
	await init_level()
	player.light_ambient.texture_scale = 1.5
	player.light_main.texture_scale = 0.75
	print("Level_Main ready")
	
	if SessionState.get_scene_data("IntroCutscene", false) == true:
		luke.global_position = SessionState.get_npc_position(luke.npc_id, LEVEL_NAME)
		ember.global_position = SessionState.get_npc_position(ember.npc_id, LEVEL_NAME)
		npc_wander()
		return
		
	await intro_cutscene()

func intro_cutscene() -> void:
	SessionState.input_locked = true
	await get_tree().process_frame
	game.start_cutscene()
	
	#cutscene flow
	game.scene_manager.move_to(target_point_player.global_position, player, 30)
	game.scene_manager.move_to(target_point_npc_luke.global_position, luke, 30)
	#this move_to should get awaited
	game.scene_manager.move_to(target_point_npc_ember.global_position, ember, 35, true, "after", "idle_down")
	await game.scene_manager.wait_for([ember])
	#timer before ember facing down
	await get_tree().create_timer(1).timeout
	#wait for ember dialogue before proceeding to luke
	await game.vn_component_manager.get_dialogue(ember_dialogue[0], ember.npc_name, ember.npc_dialogue_sprite)
	#wait for luke reply to finish before proceeding
	await game.vn_component_manager.get_dialogue(luke_dialogue[0], luke.npc_name, luke.npc_dialogue_sprite)
	
	game.scene_manager.move_camera(player, target_point_camera.global_position)
	
	game.scene_manager.move_to(target_point_npc_luke_2.global_position, luke, 20)
	game.vn_component_manager.get_dialogue(luke_dialogue[1], luke.npc_name, luke.npc_dialogue_sprite)
	#wait for ember to reach the target before facing down
	game.scene_manager.move_to(target_point_npc_ember_2.global_position, ember, 30, true, "after", "idle_down")
	await game.scene_manager.wait_for([ember])
	#after reaching the target ember will have dialogue that should get awaited before resetting the camera and ending cutscene
	await game.vn_component_manager.get_dialogue(ember_dialogue[1], ember.npc_name, ember.npc_dialogue_sprite)
	
	game.scene_manager.reset_camera(player)
	
	#both of these two movement will go to their spot but only then idle_up should be played when they reach their respective spots
	game.scene_manager.move_to(target_point_npcember_3.global_position, ember, 30, true, "after", "idle_up")
	game.scene_manager.move_to(target_point_npcluke_3.global_position, luke, 30, true, "after", "idle_up")
	game.end_cutscene(true)
	luke.sync_state()
	ember.sync_state()
	
	SessionState.input_locked = false
	SessionState.set_scene_data("IntroCutscene", true)
	await get_tree().create_timer(0.5).timeout
	npc_wander()


@onready var luke_wander_1: Marker2D = $PathMarkers_Wander/luke_wander_1
@onready var ember_wander_1: Marker2D = $PathMarkers_Wander/ember_wander_1
func npc_wander()->void:
	game.scene_manager.move_to(target_point_npcember_3.global_position, ember, 30, true, "after", "idle_up")
	game.scene_manager.move_to(target_point_npcluke_3.global_position, luke, 30, true, "after", "idle_up")
	if game.scene_manager.cancel_scene_movement:
		return
	await game.scene_manager.wait_time(1.0)
	print("Game cancel movement: ", game.scene_manager.cancel_scene_movement)
	game.scene_manager.move_to(ember_wander_1.global_position, ember, 30, true, "after", "idle_up")
	if game.scene_manager.cancel_scene_movement:
		return
	await game.scene_manager.wait_time(4.0)
	game.scene_manager.move_to(luke_wander_1.global_position, luke, 30, true, "after", "idle_up")
