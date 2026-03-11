extends Node2D
class_name SceneTransitioner

var scene_transitioner_player : Player
	
@export var auto_trigger_default : bool = true
var trigger_enabled : bool = false
@export var load_level: String

@export var randomize_level : bool = false
@export var random_level_list : Array[String] = []

@export var difficulty_based : bool = false
@export var difficulty_easy_level : String
@export var difficulty_medium_level : String
@export var difficulty_hard_level : String

@export var have_directional_guide : bool = false
@export var directional_guide_direction : String
@onready var transitioner_animator: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
var transitioner_animator_playing : bool = false

@export var spawn_marker_name: String = ""  # e.g. "Player_Spawn"
@export var companion_spawn_marker: Array = []
@export var autosave_on_transition: bool = false

@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	scene_transitioner_player = Game.manager.scene_manager.get_tree().get_first_node_in_group("Player")

	if auto_trigger_default:
		if area_2d:
			area_2d.body_entered.connect(_on_body_entered)
			area_2d.body_exited.connect(_on_body_exited)
	var prop_interact := get_parent().get_node_or_null("PropInteractItem_Component")
	if prop_interact:
		prop_interact.interaction_allowed.connect(start_transition)

func _process(_delta: float) -> void:
	if have_directional_guide and scene_transitioner_player.global_position.distance_to(self.global_position) < 200:
		transitioner_animator.play("show_direction_" + directional_guide_direction.to_lower())
		sprite_2d.scale = Vector2(3, 3)
func enable_area_trigger()->void:
	if trigger_enabled:
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exited)
		
func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	start_transition()

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		pass

func start_forced_transition():
	start_transition()

# ---------------------------------------------------------------------
func start_transition(trigger_area: bool = false) -> void:
	if SessionState.is_game_over or Game.manager.is_transitioning:
		return
	if trigger_area:
		enable_area_trigger()
	if Game.manager.is_in_cutscene:
		await Game.manager.cutscene_finished
	if randomize_level:
		spawn_marker_name = "Player_fromRandom"
		companion_spawn_marker = ["Companion_fromRandom"]
	var player = get_tree().get_first_node_in_group("Player")

	# -------------------- SAVE PLAYER --------------------
	if player:
		SessionState.set_player_health(player.health)
		SessionState.set_inventory(InventoryManager.get_all_items())

		if spawn_marker_name == "":
			SessionState.set_player_position(
				SessionState.world["current_level_name"],
				player.global_position
			)
			print("[SceneTransitioner] Saved player position (no marker).")
		else:
			print("[SceneTransitioner] Using spawn marker:", spawn_marker_name)
			
	#NPCS
	if get_tree().get_node_count_in_group("npc") > 0:
		for npc in get_tree().get_nodes_in_group("npc"):
			SessionState.set_npc_position(npc.npc_id, SessionState.world["current_level_name"], npc.global_position)
		pass
	
	# -------------------- SAVE COMPANION --------------------
	if player and SessionState.player_has_companion():
		SessionState.get_companion_id()

	# -------------------- SAVE MARKERS --------------------
	SessionState.world["requested_spawn_marker"] = spawn_marker_name
	SessionState.world["requested_companion_marker"] = companion_spawn_marker
	
	# Save target level
	SessionState.set_current_level(load_level)
	if autosave_on_transition:
		SaveSystem.save_from_session(1)

	print("Entering Other Level: ", SessionState.world["requested_companion_marker"])
	call_deferred("_delegate_scene_change")

func _delegate_scene_change() -> void:
	var game = get_tree().get_root().get_node_or_null("Game") as Game
	if not game:
		push_error("[SceneTransitioner] Game node not found!")
		return
	if not game.has_method("load_level"):
		push_error("[SceneTransitioner] Game.load_level() not found!")
		return
	
	if randomize_level and not random_level_list.is_empty():
		load_level = random_level_list.pick_random()
	if difficulty_based:
		var difficulty = SessionState.get_difficulty()
		print("DIFFICULTY", difficulty)
		match difficulty:
			"easy":
				load_level = difficulty_easy_level
			"medium":
				load_level = difficulty_medium_level
			"hard":
				load_level = difficulty_hard_level
		
	print("Spawn Marker: ", spawn_marker_name, " Companion Marker: ", companion_spawn_marker)
	await game.load_level(load_level, spawn_marker_name, companion_spawn_marker)
