extends Node2D
class_name MainMenu_UI

const GAME = preload("uid://ceow7wr54ok86")
const color_disabled : Color = Color(0.13, 0.03, 0.02, 1.0)

@onready var save_system_ui: SaveSystem_UI = %SaveSystem_UI
@onready var main_menu_audioplayer: AudioStreamPlayer2D = $main_menu_audioplayer

var has_saved_data : bool = false
@onready var btn_continue: Button = $mainmenu_ui/mainmenu_control/ButtonContainer/btn_continue

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_audioplayer.play()
	save_system_ui.request_load_game.connect(_on_request_load_game)
	for save_slot in SaveSystem.save_data:
		if not SaveSystem.save_data[save_slot]["player"].is_empty():
			has_saved_data = true
	if !has_saved_data:
		btn_continue.add_theme_color_override("font_color", color_disabled)
		btn_continue.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_new_game_pressed() -> void:
	SessionState.reset_session()
	if GAME:
		get_tree().change_scene_to_packed(GAME)
	else:
		push_error("[MAIN MENU] GAME NOT FOUND")

func _on_continue_pressed() -> void:
	save_system_ui.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("GameMenu") and save_system_ui.visible:
		save_system_ui.visible = false

func _on_request_load_game(slot: int, level_path: String) -> void:
	print("[MainMenu_UI] Loading Game scene, level:", level_path)
	
	# Save requested level in SessionState
	SessionState.requested_level_path = level_path
	SessionState.requested_spawn_id = SaveSystem.get_world_data(slot).get("spawn_id", "start")
	# Load Game scene
	if GAME:
		get_tree().change_scene_to_packed(GAME)
	else:
		push_error("[MAIN MENU] GAME NOT FOUND")
