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

@onready var luke_wander_1: Marker2D = $PathMarkers_Wander/luke_wander_1
@onready var ember_wander_1: Marker2D = $PathMarkers_Wander/ember_wander_1

@onready var ember_wander_2: Marker2D = $PathMarkers_Wander/ember_wander_2
@onready var luke_wander_2: Marker2D = $PathMarkers_Wander/luke_wander_2

#miscellaneous
var npc_wandering_timer : Timer
var npc_pathing = false
@onready var continue_upstairs: ContinueExploration = $Continue_Upstairs
@onready var bloodleak: Node2D = $Misc/bloodleak
@onready var bloodleak_area: Area2D = $Misc/bloodleak/bloodleak_area
@onready var bloodleak_animplayer: AnimationPlayer = $Misc/bloodleak/bloodleak_animplayer
@onready var movement_guide_player: AnimationPlayer = $movement_guide_marker/movement_guide_player
@onready var movement_guide_area: Area2D = $movement_guide_marker/movement_guide_area
@onready var movement_guide_marker: Marker2D = $movement_guide_marker

var ember_dialogue = [
	#intro dialogue #1
	[
		"Isn't this interesting? [Emphasis=1.5] this mansion is uninhabited.",
		"It seems like they left unprepared, lights are lit, doors are open...",
		"Why don't we go upstairs?"
	],
	#reply #4
	[
		"Fine..."
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
	continue_upstairs.starting_upstairs_sequence.connect(stop_npc_wander_behavior)
	bloodleak_area.body_entered.connect(on_blood_area_enter)
	movement_guide_area.body_exited.connect(on_movement_guide_exit)
	set_level_name("1st Floor Living Room")
	scene_path = "res://game_scenes/level_1f_livingroom.tscn"
	await init_level()
	player.light_ambient.texture_scale = 1.5
	player.light_main.texture_scale = lerp(0.75, 0.8, sin(Time.get_ticks_msec() * 0.001))
	
	if SessionState.get_scene_data("IntroCutscene", false):
		movement_guide_marker.queue_free()
		luke.global_position = SessionState.get_npc_position(luke.npc_id, LEVEL_NAME)
		ember.global_position = SessionState.get_npc_position(ember.npc_id, LEVEL_NAME)
		game.scene_manager.move_to(target_point_npcember_3.global_position, ember, 30, true, "after", "idle_up")
		game.scene_manager.move_to(target_point_npcluke_3.global_position, luke, 30, true, "after", "idle_up")
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
	ember.face_target(luke)
	game.scene_manager.reset_camera(player)
	

	game.end_cutscene(true)
	luke.sync_state()
	ember.sync_state()
	
	SessionState.input_locked = false
	SessionState.set_scene_data("IntroCutscene", true)
	await get_tree().create_timer(0.5).timeout
	npc_wander_play_ember(1.0)
	npc_wander_play_luke(1.0)
	npc_wander()
	game.guide.objective_changed.emit("Explore the Mansion")
	movement_guide_marker.visible = true
	movement_guide_player.play("wasd_guide")
	
func npc_wander()->void:
	npc_wandering_timer = Timer.new()
	continue_upstairs.add_child(npc_wandering_timer)
	npc_wandering_timer.one_shot = false
	npc_wandering_timer.wait_time = 10.0
	npc_wandering_timer.timeout.connect(npc_wander_play_luke)
	npc_wandering_timer.timeout.connect(npc_wander_play_ember)
	npc_wandering_timer.start()
	
func npc_wander_play_luke(wait_time : float = 5.0)->void:
	if npc_pathing:
		return
	var randomize_int = randi_range(1, 3)
	var randomize_wait_time = (randf() + 0.01) * wait_time
	
	print(randomize_wait_time)
	await game.scene_manager.wait_time(randomize_wait_time)
	npc_pathing = true
	match randomize_int:
		1:
			game.scene_manager.move_to(target_point_npcluke_3.global_position, luke, 30, true, "after", "idle_up")
		2:
			game.scene_manager.move_to(luke_wander_1.global_position, luke, 30, true, "after", "idle_up")
		3:
			game.scene_manager.move_to(luke_wander_2.global_position, luke, 30, true, "after", "idle_up")
	await game.scene_manager.wait_for([luke])
	npc_pathing = false
	var luke_subdialogs = [
		"Most of the books are filled with scribbles",
		"There must be something valuable here..."
	]
	var luke_line = luke_subdialogs.pick_random()
	await get_tree().create_timer(randomize_int * 2).timeout
	game.set_subdialog([luke_line], luke)

func npc_wander_play_ember(wait_time : float = 5.0)->void:
	if npc_pathing:
		return
	var randomize_int = randi_range(1, 3)
	var randomize_wait_time = (randf() + 0.01) * wait_time
	
	print(randomize_wait_time)
	await game.scene_manager.wait_time(randomize_wait_time)
	npc_pathing = true
	match randomize_int:
		1:
			game.scene_manager.move_to(target_point_npcember_3.global_position, ember, 30, true, "after", "idle_up")
		2:
			game.scene_manager.move_to(ember_wander_1.global_position, ember, 30, true, "after", "idle_up")
		3:
			game.scene_manager.move_to(ember_wander_2.global_position, ember, 30, true, "after", "idle_up")
	await game.scene_manager.wait_for([ember])
	npc_pathing = false
	var ember_subdialogs = [
		"Hmmm...some pages are scribbled.",
		"I can't read these books..."
	]
	var ember_line = ember_subdialogs.pick_random()
	await get_tree().create_timer(randomize_int * 1.5).timeout
	game.set_subdialog([ember_line], ember)

func stop_npc_wander_behavior()->void:
	game.scene_manager.cancel_all_cutscene_movements()
	npc_wandering_timer.timeout.disconnect(npc_wander_play_luke)
	npc_wandering_timer.timeout.disconnect(npc_wander_play_ember)
	npc_wandering_timer.stop()
	
func on_blood_area_enter(body : CharacterBody2D)->void:
	if body.name == "Player" or body.is_in_group("Player"):
		if bloodleak_animplayer.is_playing():
			return
		bloodleak_animplayer.play("blood_fade")
		await bloodleak_animplayer.animation_finished
		bloodleak.queue_free()
		
func on_movement_guide_exit(body : CharacterBody2D)->void:
	if body.name == "Player" or body.is_in_group("Player"):
		movement_guide_player.play("wasd_guide_remove")
		await movement_guide_player.animation_finished
		movement_guide_marker.queue_free()
