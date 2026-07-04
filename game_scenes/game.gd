class_name Game
extends Node2D

static var manager: Game
# COLOR PRESETS
static var BACKGROUND : Color =  Color("2F2929")

# SOUNDS
const MUSIC_PROLOGUE := preload("res://systems/sounds/sound_ambient_night.mp3")
const MUSIC_DEFAULT := preload("res://systems/sounds/sound_ambient-room.mp3")
const MUSIC_SUSPENSE_ESCAPE := preload("res://systems/sounds/sound_suspense_escape.mp3")
const SOUND_SCREAM_SHADOW = preload("uid://bte3i624y25g5")

# ==========================
# NODES
# ==========================
@onready var player: Player = %Player
@onready var scene_manager: SceneManager = %Scene_Manager as SceneManager 
@onready var scene_ui_canvas_layer: CanvasLayer = $SceneUI_CanvasLayer
@onready var vn_component_manager: VN_Component_Manager = %VN_Component_Manager as VN_Component_Manager
@onready var screen_effect_ui: ScreenEffect_UI = %ScreenEffect_UI as ScreenEffect_UI
@onready var game_over : Game_Over = %Game_Over as Game_Over
@onready var choice_timer: Choice_Timer = $SceneUI_CanvasLayer/Choice_Timer
@onready var sub_dialog_container: Control = $SceneUI_CanvasLayer/SubDialog_Container

const subdialog_ui := preload("uid://cvpkaehqmm82b")


@onready var inventory_ui: Inventory_UI = %InventoryUI as Inventory_UI
@onready var guide: Guide = %Guide as Guide
 
@onready var audio_container: Node2D = $Audio_Container
@onready var bg_music_player: AudioStreamPlayer2D = %MainAudio_Player
@onready var bg_audio_effects: AudioStreamPlayer2D = %AudioEffects
var bg_music_pitchscale_range = randf_range(0.9, 1.25)
var bg_music_volumedb_range = randf_range(-2.0, 1.0)

# ==========================
# LEVELS
# ==========================
var scene_prologue := "res://cinematics/prologue/prologue.tscn"
# ==========================
# VARIABLES
# ==========================
var is_transitioning := false
signal cutscene_started
signal cutscene_finished
var is_in_cutscene : bool = false
var is_in_cinematic : bool = false

@export var bg_music : AudioStream

var spawn_marker_id = SessionState.world.get("requested_spawn_marker", "")
var companion_marker_id = SessionState.world.get("requested_companion_marker", [])

# ==========================
# READY
# ==========================
func _ready() -> void:
	Game.manager = self
	var level_to_load = SessionState.requested_level_path
	SessionState.requested_level_path = ""
	if not player.is_in_group("Player"):
		player.add_to_group("Player")
	
	player.visible = false
	guide.visible = false
	inventory_ui.visible = false
	
	# Load level if resuming
	if level_to_load != "":
		print("[Game] Loading requested:", level_to_load, "marker:", spawn_marker_id)
		await load_level(level_to_load, spawn_marker_id, companion_marker_id)
	else:
		print("[Game] New game → Prologue")
		await load_level(scene_prologue, "Player_Spawn", [])

	var saveui = get_tree().get_first_node_in_group("save_ui")
	if saveui:
		saveui.request_load_game.connect(_on_request_load_game)
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		pass
	pass
# ==========================
# LEVEL LOADING
# ==========================
func load_level(level_path: String, spawn_marker: String = "", companion_marker: Array = []) -> void:
	print("loading: ", level_path)
	scene_manager.cancel_all_cutscene_movements()
	SessionState.set_temp_data(level_path, spawn_marker, companion_marker, SessionState.global_data)
	is_in_cinematic = false
	is_in_cutscene = false
	if is_transitioning:
		return
	is_transitioning = true
	SessionState.world["requested_spawn_marker"] = spawn_marker
	SessionState.world["requested_companion_marker"] = companion_marker

	await screen_effect_ui.set_effect("fade_instant", 1)
	var level_scene: PackedScene = load(level_path)
	if not level_scene:
		push_error("[Game] FAILED TO LOAD:", level_path)
		is_transitioning = false
		return

	var old_parent = player.get_parent()
	if old_parent and old_parent != self:
		old_parent.remove_child(player)
		add_child(player)
	for child in scene_manager.get_children():
		child.queue_free()
		print("[GAME] Old scene removed successfully...")
	var new_scene = level_scene.instantiate()
	print("[GAME] NEW SCENE LOADED: ", new_scene)
	scene_manager.add_child(new_scene)
	# Determine level name
	if new_scene.has_method("get_level_name"):
		SessionState.world["current_level_name"] = new_scene.get_level_name()
	else:
		SessionState.world["current_level_name"] = level_path.get_file().get_basename()

	print("[Game] Loaded Scene: ", new_scene)
	#SessionState.is_transitioning = false
	if is_in_cinematic:
		SessionState.input_locked = true
		pass
	else:
		var ysort := new_scene.get_node_or_null("Y_Sort")
		if ysort:
			await get_tree().process_frame
			_reparent_player(ysort, new_scene, spawn_marker)
			print("[GAME] Resetting Effect ON Player SPAWN")
			# COMPANION SPAWN
			if new_scene.has_method("_spawn_companion"):
				new_scene._spawn_companion(companion_marker)
			screen_effect_ui.reset_effect()
		else:
			push_error("[Game] Y_Sort missing!")
	# Handle special cases
		# Handle special cases (cutscenes / endings)
	if new_scene is ScenePrologue:
		bg_music_player.stream = MUSIC_PROLOGUE
		bg_music_player.pitch_scale = randf_range(0.9, 1.25)
		bg_music_player.volume_db = randf_range(4.0, 8.0)
		bg_music_player.play()
		# Connect cinematic_finished if available
		if new_scene.has_signal("cinematic_finished"):
			new_scene.cinematic_finished.connect(_on_cinematic_finished)
		# Prefer explicit start methods if provided, otherwise try generic ones
		else:
			# If the scene already starts itself (like ScenePrologue did in _ready), do nothing.
			print("[Game] ScenePrologue loaded — no explicit start method found, assuming scene handles itself.")
	else:
		bg_music_player.stream = MUSIC_DEFAULT
		bg_music_player.pitch_scale = bg_music_pitchscale_range
		bg_music_player.volume_db = bg_music_volumedb_range
		bg_music_player.play()
		screen_effect_ui.set_effect("fade_in", 1)
		guide.show_guide()

	is_transitioning = false
	print("[Game] Load complete.")
	return

# ==========================
# PLAYER RE-PARENTING
# ==========================
func _reparent_player(ysort_node: Node, level_scene: Node, marker: String) -> void:
	if not is_instance_valid(player):
		push_error("[Game] Player invalid!")
		return
	
	if player.get_parent():
		player.get_parent().remove_child(player)

	ysort_node.add_child(player)
	var spawn_pos := Vector2.ZERO

	# Priority 2 → Saved position (only for save load)
	if SaveSystem.is_loading_from_file:
		var level_name = SessionState.world.get("current_level_name", "")
		var saved_pos = SessionState.get_player_position(level_name)
		if saved_pos != Vector2.ZERO:
			spawn_pos = saved_pos
			print("[Game] Using saved player position.")
		SaveSystem.is_loading_from_file = false
	# Priority 1 → Spawn marker
	elif marker != "":
		var spawn_node = level_scene.get_node_or_null(marker)
		if spawn_node:
			spawn_pos = spawn_node.global_position
			print("[Game] Player marker used:", marker)
	
	SessionState.temp_player_position = spawn_pos
	player.global_position = spawn_pos
	player.visible = true
	print("[Game] Player moved:", spawn_pos)

# ==========================
# LOADING FROM SAVE
# ==========================
func _on_request_load_game(level_path: String) -> void:
	print("[Game] Load saved game level:", level_path)
	SaveSystem.is_loading_from_file = true
	await load_level(level_path, "", [])
	_apply_player_state_from_session()
	SaveSystem.is_loading_from_file = false

func _apply_player_state_from_session() -> void:
	var p = get_tree().get_first_node_in_group("Player")
	if not p:
		return

	p.health = SessionState.player["health"]

	InventoryManager.clear_inventory()
	InventoryManager.load_items(SessionState.player["inventory"])

	print("[Game] Player restored.")

func _on_cinematic_finished(next_scene: PackedScene) -> void:
	if next_scene and next_scene.resource_path:
		call_deferred("load_level", next_scene.resource_path, "Player_Spawn", [])
	else:
		push_error("[Game] Invalid next scene!")

# ====================================
# Cutscene Handler
# ====================================
func start_cutscene() -> void:
	inventory_ui.visible = !visible
	if is_in_cutscene:
		return
	is_in_cutscene = true
	player.velocity = Vector2.ZERO
	player.movement_direction = Vector2.ZERO
	player.cancel_cutscene_movement = true
	cutscene_started.emit()
	await screen_effect_ui.set_effect("cutscene_effect", 1)

func end_cutscene(reset_effect : bool) -> void:
	if !is_in_cutscene:
		return
	if reset_effect: 
		await screen_effect_ui.reset_effect()
	is_in_cutscene = false
	cutscene_finished.emit()
	guide.show_guide()

func set_subdialog(subdialogue: Array, character_speaker: CharacterBody2D):
	print("[SUBDIALOG] speaker: ", character_speaker)
	var subdialog : SubDialog_UI = subdialog_ui.instantiate()
	sub_dialog_container.add_child(subdialog)
	subdialog.get_subdialogue(subdialogue, character_speaker)
	
func set_game_over(text : String = "GAME OVER", flavor_text : String = "", mode : String = "default")->void:
	if is_transitioning or SessionState.is_game_over:
		return
	SessionState.is_game_over = true
	await game_over.game_over_screen(text, flavor_text, player, mode)
	guide.visible = false

	bg_music_player.volume_db = randf_range(-30.0, -20.0)
	bg_music_player.pitch_scale = randf_range(2.0, 3.5)
	pass

func set_bgmusic_setting(volume : float, pitch : float)->void:
	bg_music_player.volume_db = volume
	bg_music_player.pitch_scale = pitch

func play_audio_effect(sound, volume : float, pitch : float, duration : float = -1.0)->void:
	var audio_effect = AudioStreamPlayer2D.new()
	audio_container.add_child(audio_effect)
	audio_effect.stream = sound
	audio_effect.volume_db = volume
	audio_effect.pitch_scale = pitch
	audio_effect.play()
	await get_tree().create_timer(duration).timeout
	var tween = create_tween()
	tween.tween_property(
		audio_effect,
		"volume_db",
		-50.0,
		3.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	audio_effect.queue_free()
