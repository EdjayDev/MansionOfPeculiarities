extends Control
class_name Game_Over

var game : Game

@onready var game_over_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var game_over_player: AnimationPlayer = $AnimationPlayer
@onready var text_game_over: RichTextLabel = $text_GameOver
@onready var text_flavortext: RichTextLabel = $text_flavortext

@onready var flow_container: FlowContainer = $FlowContainer
@onready var button_retry: Button = $FlowContainer/button_retry
@onready var button_quit: Button = $FlowContainer/button_quit

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	game = get_tree().get_root().get_node("Game") as Game
	flow_container.visible = false
	button_retry.pressed.connect(game_retry)
	button_quit.pressed.connect(game_quit)
	
func game_over_screen(text : String = "GAME OVER", flavor_text : String = "", player : Player = null, mode : String = "default")->void:
	print("[GAMEOVER] GAME OVER INITIALIZED")
	SessionState.input_locked = true
	await game.screen_effect_ui.set_effect("fade_out", 1)
	await game.screen_effect_ui.set_effect("fade_black", 1)
	text_game_over.text = text
	text_flavortext.text = flavor_text
	if player and mode == "cinematic":
		text_game_over.theme.default_font_size = 64
		game_over_player.play("show_cinematic_text", -1, 0.5)
		SessionState.input_locked = true
		await game_over_player.animation_finished
		print("[GAME OVER] Game Over animation finished")
		game_quit()
		return	
	SessionState.input_locked = true
	player.global_position = SessionState.temp_player_position
	game_over_audio.volume_db = 1.0
	game_over_audio.pitch_scale = 1.25
	game_over_audio.play()
	game_over_player.play("show_text", -1, 0.5)
	await game_over_player.animation_finished
	
func reset_game_over_display()->void:
	game_over_player.play("RESET")
	game_over_audio.stop()
	
func game_retry()->void:
	get_tree().paused = false
	SessionState.input_locked = false
	SessionState.global_data = SessionState.temp_global_data
	await game.load_level(SessionState.temp_level_path, SessionState.temp_spawn_marker, SessionState.temp_companion_marker)
	reset_game_over_display()
	SessionState.is_game_over = false
	
func game_quit()->void:
	game.is_in_cinematic = false
	get_tree().paused = false
	SessionState.reset_session()
	get_tree().change_scene_to_file("res://systems/main_menu_ui.tscn")
	SessionState.is_game_over = false
	print("[GAME OVER] Quitting to main menu")
