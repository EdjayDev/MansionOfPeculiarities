class_name Player
extends CharacterBody2D

# ==========================
# REFERENCES
# ==========================
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var player_dialogue_sprite: Sprite2D = $"Sprite2D-DialogueSprite"

@onready var player_state_machine: Player_State_Machine = $PlayerStateMachine
@onready var player_collision: CollisionShape2D = $CollisionShape2D
@onready var emote_popup: Emote_Popup = $EmotePopup

@onready var light_ambient: PointLight2D = $LightAmbient
@onready var light_main: PointLight2D = $LightMain

@onready var interaction_area: Area2D = $Player_InteractionArea
@onready var interaction_collision_shape_2d: CollisionShape2D = $Player_InteractionArea/CollisionShape2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

# ==========================
# VARIABLES
# ==========================

@export var move_speed = 100.0
@export var health: int = 100

@export var in_cutscene: bool = false
var cancel_cutscene_movement := false
var scene_game
var player_state

const DIR_4 = [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP
]

var facing_direction: Vector2 = Vector2.DOWN
var movement_direction: Vector2 = Vector2.ZERO

# ==========================
# CONFIG: Set this to your NPC layer index (1-based)
# NPCs are on physics layer 2 → bit index = 1 → value = 2
const NPC_LAYER_INDEX := 2  # -> layer number (as shown in editor)
const NPC_LAYER_BIT := 1 << (NPC_LAYER_INDEX - 1)  # correct bit

# ==========================
# READY
# ==========================
func _ready() -> void:
	add_to_group("Player")
	player_state_machine.initialize(self)

	scene_game = get_tree().get_root().get_node("Game") as Game
	# Apply behavior based on initial companion flag.
	# Recommended: use exceptions approach for reliability.
# ==========================
# PROCESS
# ==========================
func _process(_delta):
	if get_parent().is_in_group("debug"):
		visible = true
		camera_2d.position_smoothing_enabled = true
		return
	if scene_game:
		if scene_game.is_in_cinematic:
			visible = false
			return
			
		visible = true
		if scene_game.is_in_cutscene:
			camera_2d.position_smoothing_enabled = false
			return
			
	visible = true
	camera_2d.position_smoothing_enabled = true
	if SessionState.input_locked:
		interaction_area.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		interaction_area.process_mode = Node.PROCESS_MODE_INHERIT
		return
	

func _physics_process(_delta):
	if get_parent().is_in_group("debug"):
		camera_2d.position_smoothing_enabled = true
		movement_direction = Vector2(
			Input.get_axis("LeftA", "RightD"),
			Input.get_axis("UpW", "DownS")
		).normalized()
		move_and_slide()
		return
	if scene_game:
		if scene_game.is_in_cutscene  or in_cutscene:
			movement_direction = velocity.normalized()
			move_and_slide()
			return
		
	if SessionState.input_locked:
		movement_direction = Vector2.ZERO
		return

	camera_2d.position_smoothing_enabled = true
	movement_direction = Vector2(
		Input.get_axis("LeftA", "RightD"),
		Input.get_axis("UpW", "DownS")
	).normalized()
	move_and_slide()
	
# ==========================
# ANIMATION / EMOTES (unchanged)
# ==========================
func on_cutscene_movement(target: Vector2, speed: float) -> void:
	cancel_cutscene_movement = false
	if cancel_cutscene_movement:
		velocity = Vector2.ZERO
		return
	navigation_agent.path_desired_distance = 2.0
	navigation_agent.target_desired_distance = 2.0
	navigation_agent.path_max_distance = 2.0
	navigation_agent.avoidance_enabled = false

	navigation_agent.target_position = target
	while get_tree() and not navigation_agent.is_navigation_finished():
		if cancel_cutscene_movement:
			velocity = Vector2.ZERO
			return
		var next_position := navigation_agent.get_next_path_position()
		var dir := next_position - global_position

		if dir.length() > 1.0:
			velocity = dir.normalized() * speed
		else:
			velocity = Vector2.ZERO
		await get_tree().physics_frame
		
	var direction = (target - global_position).normalized()
	velocity = direction * speed
	print("Distance: ", global_position.distance_to(target))
	if global_position.distance_to(target) <= 1.5:
		velocity = Vector2.ZERO
	
func update_animation(state: String) -> void:
	animation_player.play(state + "_" + set_animationdirection())
	player_state = state

func set_facingdirection() -> bool:
	if movement_direction == Vector2.ZERO:
		return false
		
	var get_direction = int(round((movement_direction + facing_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_direction = DIR_4[get_direction]
		
	if new_direction == facing_direction:
		return false
	
	facing_direction = new_direction
	
	if facing_direction == Vector2.LEFT:
		interaction_collision_shape_2d.position = Vector2.LEFT * 8
		sprite.scale.x = -1
		
	else:
		interaction_collision_shape_2d.position = Vector2.RIGHT * 8
		sprite.scale.x = 1
	return true

func set_animationdirection() -> String:
	match facing_direction:
		Vector2.DOWN: 
			interaction_collision_shape_2d.position = Vector2.DOWN * 8
			return "down"
		Vector2.UP:
			interaction_collision_shape_2d.position = Vector2.UP * 8
			return "up"
		_: 
			return "side"
			
func face_target(face_character: CharacterBody2D) -> void:
	var dir := (face_character.global_position - global_position).normalized()
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.scale.x = 1
			play_custom_animation(player_state + "_side")
		else:
			sprite.scale.x = -1
			play_custom_animation(player_state + "_side")
	else:
		if dir.y > 0:
			play_custom_animation(player_state + "_down")
		else:
			play_custom_animation(player_state + "_up")
			
func play_custom_animation(animation : String)->void:
	animation_player.play(animation)
	pass
	
func show_emote(emote_name: String) -> void:
	if emote_name == null:
		return
	emote_popup.play_emote(emote_name)
	
