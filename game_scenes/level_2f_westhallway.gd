class_name Level_2f_WestHallway
extends BaseLevel

@onready var enemy_shadow_: enemy_shadow = $Y_Sort/Enemy_Shadow
@onready var area_2d: Area2D = $Area2D
@onready var area_halt: Area2D = $Area_Halt

@onready var prop_chandelier_type1_3: Node2D = $"Y_Sort/Props_Container/prop_chandelier-type1_3"
@onready var prop_chandelier_type1_2: Prop_Light = $"Y_Sort/Props_Container/prop_chandelier-type1_2"
@onready var prop_chandelier_type1_4: Prop_Light = $"Y_Sort/Props_Container/prop_chandelier-type1_4"

@onready var intro_shadow_1: Marker2D = $Intro_PathMarkers/intro_shadow_1
@onready var intro_shadow_2: Marker2D = $Intro_PathMarkers/intro_shadow_2
@onready var intro_ember: Marker2D = $Intro_PathMarkers/intro_ember
@onready var intro_luke: Marker2D = $Intro_PathMarkers/intro_luke

@onready var companion_exit_run: Marker2D = $Companion_ExitRun

@onready var dark_swarm: Shadow_Swarm = $Dark_Swarm


func _ready() -> void:
	set_level_name("2nd Floor West Hallway")
	scene_path = "res://game_scenes/level_2f_westhallway.tscn"
	await init_level()
	print("Level 2f West Hallway ready")
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
		game.set_bgmusic_setting(-16.0, 16.0)
		prop_chandelier_type1_3.play_animation_effect("idle_fading")
		await get_tree().create_timer(1.0).timeout
		prop_chandelier_type1_2.play_animation_effect("idle_fading")
		prop_chandelier_type1_4.play_animation_effect("idle_fading")
		game.bg_music_player.stream = level_music
		game.bg_music_player.play()
		area_halt.area_entered.disconnect(halt_music)
		var ember_line = [
		"Hmmmm..."
		]
		var luke_line = [
			"Where are these smoke coming from?"
		]
		for companion in get_companions():
			if companion.npc_id == "ember":
				await get_tree().create_timer(2.0).timeout
				game.set_subdialog(ember_line, companion)
			elif companion.npc_id == "luke":
				await get_tree().create_timer(3.0).timeout
				game.set_subdialog(luke_line, companion)

func entry_shadow()->void:
	var luke_dialogue = [
	"We need to leave now, let's go! [Emphasis=1.0]"
	]

	var ember_dialogue = [
		"What is that?..."
	]
	var luke = get_npc_by_id("luke")
	var ember = get_npc_by_id("ember")
	game.scene_manager.move_to(intro_ember.global_position, ember, 60)
	game.scene_manager.move_to(intro_luke.global_position, luke, 60)
	await game.scene_manager.wait_for([luke,ember])
	
	SessionState.input_locked = true
	game.set_bgmusic_setting(-3.0, 2.0)
	game.scene_manager.shake_camera(player.camera_2d, 2.0, 4.0, 6.0)
	game.play_audio_effect(game.SOUND_SCREAM_SHADOW, -3.0, 2.0, 12.0)
	await get_tree().process_frame

	luke.face_target(enemy_shadow_)
	ember.face_target(enemy_shadow_)
	game.set_subdialog(ember_dialogue, ember)
	await get_tree().create_timer(2.0).timeout
	game.set_subdialog(luke_dialogue, luke)	
	dark_swarm.set_particle_emission(false)
	
	game.scene_manager.reset_camera(player)
	SessionState.input_locked = false
	dark_swarm.dark_swarm()
	dark_swarm.set_particle_emission(true)
	SessionState.set_global_data("faced_shadow", true)
	game.bg_music_player.stream = game.MUSIC_SUSPENSE_ESCAPE
	game.bg_music_player.play()
	game.set_bgmusic_setting(-5.0, 0.6)
	await game.scene_manager.wait_time(0.111)
	companion_exit()
	enemy_chase()
	pass

func companion_exit()->void:
	if SessionState.get_global_data("faced_shadow", false):
		var luke = get_npc_by_id("luke")
		var ember = get_npc_by_id("ember")
		game.scene_manager.move_to(companion_exit_run.global_position, ember, 150)
		game.scene_manager.move_to(companion_exit_run.global_position, luke, 145)
		await game.scene_manager.wait_for([luke])
		luke.visible = false
		ember.visible = false
		return

func enemy_chase()->void:
	if SessionState.get_global_data("faced_shadow", false):
		enemy_shadow_.chase(player, 1.5)
