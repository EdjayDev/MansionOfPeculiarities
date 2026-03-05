class_name Level_2f_WestHallway
extends BaseLevel

@onready var enemy_shadow_: enemy_shadow = $Y_Sort/Enemy_Shadow
@onready var area_2d: Area2D = $Area2D
@onready var area_halt: Area2D = $Area_Halt

@onready var prop_chandelier_type1_3: Node2D = $"Y_Sort/Props/prop_chandelier-type1_3"

@onready var intro_shadow_1: Marker2D = $Intro_PathMarkers/intro_shadow_1
@onready var intro_shadow_2: Marker2D = $Intro_PathMarkers/intro_shadow_2
@onready var intro_ember: Marker2D = $Intro_PathMarkers/intro_ember
@onready var intro_luke: Marker2D = $Intro_PathMarkers/intro_luke

@onready var companion_exit_run: Marker2D = $Companion_ExitRun

@onready var dark_swarm: Shadow_Swarm = $Dark_Swarm


var player_dialogue = [
	"What is that?"
]

var luke_dialogue = [
	"We need to leave now, let's go! [Emphasis=1.0]"
]

var ember_dialogue = [
	"Why it looks like..."
]

func _ready() -> void:
	set_level_name("2nd Floor West Hallway")
	scene_path = "res://game_scenes/level_2f_westhallway.tscn"
	await init_level()
	print("Level 2f Bigroom ready")
	player.light_main.visible = true
	dark_swarm.set_particle_emission(true)
	area_2d.area_entered.connect(_on_area_entered)
	area_halt.area_entered.connect(halt_music)
	
	
func _on_area_entered(area):
	if SessionState.get_global_data("faced_shadow"):
		#luke.global_position = target_point_npc_luke.global_position
		#ember.global_position = target_point_npc_ember.global_position
		return
	if area.name == "Player_InteractionArea":
		entry_shadow()

func halt_music(area):
	if SessionState.get_global_data("faced_shadow", false):
		return
	if area.name == "Player_InteractionArea":
		game.scene_manager.move_to(intro_shadow_1.global_position, enemy_shadow_, 130)
		game.set_bgmusic_setting(-16.0, 16.0)
		prop_chandelier_type1_3.play_animation_effect("idle_fading")
		game.bg_music_player.stream = level_music
		game.bg_music_player.play()
		area_halt.area_entered.disconnect(halt_music)

func entry_shadow()->void:
	var luke = get_npc_by_id("luke")
	var ember = get_npc_by_id("ember")
	
	SessionState.input_locked = true

	await get_tree().process_frame
	
	game.scene_manager.move_camera(player, intro_shadow_1.global_position)
	
	game.scene_manager.move_to(intro_ember.global_position, ember, 60)
	game.scene_manager.move_to(intro_luke.global_position, luke, 60)
	await game.scene_manager.wait_for([luke,ember])
	
	game.set_bgmusic_setting(-3.0, 3.0)
	game.scene_manager.move_to(intro_shadow_2.global_position, enemy_shadow_, 20)
	
	luke.face_target(enemy_shadow_)
	ember.face_target(enemy_shadow_)
	dark_swarm.set_particle_emission(false)
	await game.vn_component_manager.get_dialogue(player_dialogue, player.player_name, player.player_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(ember_dialogue, "Ember", ember.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(luke_dialogue, "Luke", luke.npc_dialogue_sprite, 0.005)
	
	game.scene_manager.reset_camera(player)
	dark_swarm.dark_swarm()
	game.end_cutscene(true)
	dark_swarm.set_particle_emission(true)
	SessionState.input_locked = false
	SessionState.set_global_data("faced_shadow", true)
	game.bg_music_player.stream = game.MUSIC_SUSPENSE_ESCAPE
	game.bg_music_player.play()
	game.set_bgmusic_setting(-10.0, 0.6)
	await game.scene_manager.wait_time(0.111)
	companion_exit()
	enemy_chase()
	pass

func companion_exit()->void:
	if SessionState.get_global_data("faced_shadow", false):
		var luke = get_npc_by_id("luke")
		var ember = get_npc_by_id("ember")
		print("GOING EXIT!!!")
		game.scene_manager.move_to(companion_exit_run.global_position, ember, 150)
		game.scene_manager.move_to(companion_exit_run.global_position, luke, 145)
		await game.scene_manager.wait_for([luke])
		luke.visible = false
		ember.visible = false
		return

func enemy_chase()->void:
	if SessionState.get_global_data("faced_shadow", false):
		enemy_shadow_.chase(player, 1.5)
