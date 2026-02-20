class_name InGameMenu_UI
extends CanvasLayer

@onready var game_menu_panel: Panel = %GameMenu_Panel
@onready var btn_load: Button = %btn_Load
@onready var save_system_ui: SaveSystem_UI = %SaveSystem_UI
@onready var btn_quit: Button = %btn_Quit
@onready var btn_options: Button = %btn_Options


func _ready() -> void:
	add_to_group("ingame_menu")
	game_menu_panel.visible = false
	save_system_ui.request_load_game.connect(_on_request_load_game)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("GameMenu"):
		if save_system_ui.visible:
			save_system_ui.visible = false
			game_menu_panel.visible = not game_menu_panel.visible
			return
		elif event.is_action_pressed("GameMenu"):
			game_menu_panel.visible = not game_menu_panel.visible
			return
		else:
			game_menu_panel.visible = false
			return
			
	if btn_load.button_pressed:
		loaddata_save_system_ui()
		pass
	if btn_options.button_pressed:
		
		pass
		
	if btn_quit.button_pressed:
		SessionState.reset_session()
		get_tree().change_scene_to_file("res://systems/main_menu_ui.tscn")

func savedata_save_system_ui() -> void:
	save_system_ui.visible = true
	game_menu_panel.visible = false
	# Set buttons correctly
	save_system_ui.show_save_mode("SAVE GAME")

func loaddata_save_system_ui() -> void:
	save_system_ui.visible = true
	game_menu_panel.visible = false
	# Set buttons correctly
	save_system_ui.show_load_mode("LOAD GAME")

func _on_request_load_game(slot : int, level_path: String) -> void:
	# Close menus
	save_system_ui.visible = false
	game_menu_panel.visible = false

	SessionState.requested_level_path = level_path
	SessionState.requested_spawn_id = SaveSystem.get_world_data(slot).get("spawn_id", "start")

	get_tree().change_scene_to_file("res://game_scenes/game.tscn")
