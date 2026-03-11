extends CharacterBody2D
class_name BaseNPC

# -----------------------------
# ENUMS & STATE
# -----------------------------
enum NPCState { IDLE, WALK }
enum NPCBehavior {WANDER, PATROL}

var state: NPCState = NPCState.IDLE
var prev_state: NPCState = NPCState.IDLE

var is_interacting
# -----------------------------
# NODES & REFERENCES
# -----------------------------
var animation_player : AnimationPlayer

var scene_game : Game
# -----------------------------
# EXPORTED / FLAGS
# -----------------------------
@export_category("NPC Initialize Data")
@export_file("*.tscn") var npc_file_path : String
@export var npc_id: String
@export var npc_name: String = "Actor"
@export var npc_dialogue : Array
@export var npc_choices : Array
@export var npc_dialogue_sprite : Sprite2D
@export var npc_area_2d: Area2D
@export var npc_navigation_agent : NavigationAgent2D

@export_category("NPC Behavior")
@export var is_following_player: bool = false
@export var follow_target: CharacterBody2D = null
@export var player_get : Player
var facing_target : bool = false
var looking_target = null

# -----------------------------
# DATA
# -----------------------------
var is_npc_sync : bool 
var forced_animation := false

var delta_data
var last_direction: String = "down"
var in_cutscene = false
var player_nearby: bool = false
var has_faced_target : bool = false
var cancel_cutscene_movement := false

var follow_speed : float = 100.0
var acceleration = 400
var friction = 400
var choice_id: String

# -----------------------------
# READY
# -----------------------------
func _ready():
	pass
# -----------------------------
# AREA SIGNALS
# -----------------------------
func _on_area_entered(area: Area2D) -> void:
	var player := area.owner
	if player is Player:
		player_nearby = true
		var player_object: Player = area.get_parent()
		player_object.player_interactables.append(self)
		
func _on_area_exited(area):
	if area.name == "Player_InteractionArea":
		player_nearby = false
		var player_object: Player = area.get_parent()
		player_object.player_interactables.erase(self)

func character_in_cutscene_handler() -> void:
	scene_game = get_tree().get_root().get_node("Game")
	if scene_game:
		scene_game.cutscene_started.connect(_on_cutscene_started)
		scene_game.cutscene_finished.connect(_on_cutscene_ended)

		if scene_game.is_in_cutscene:
			_on_cutscene_started()
		
func sync_state()->void:
	if SessionState.player_has_companion():
		var player_companion = SessionState.get_companion_id()
		if player_companion.has(npc_id):
			add_to_group("companion")
			follow_target = get_tree().get_first_node_in_group("Player")
			is_following_player = true
	player_get = get_tree().get_first_node_in_group("Player")
	pass
	
func _on_cutscene_started():
	velocity = Vector2.ZERO
	if npc_navigation_agent:
		npc_navigation_agent.set_velocity_forced(Vector2.ZERO)
		npc_navigation_agent.set_velocity(Vector2.ZERO)
		npc_navigation_agent.velocity_computed.disconnect(_on_velocity_computed)

	state = NPCState.IDLE
	in_cutscene = true

func _on_cutscene_ended():
	if npc_navigation_agent:
		npc_navigation_agent.velocity_computed.connect(_on_velocity_computed)
	sync_state()
	in_cutscene = false
	
# -----------------------------
# PROCESS (INPUT ONLY)
# -----------------------------
func _process(_delta):
	if in_cutscene:
		is_npc_sync = false
		is_following_player = false
		
# -----------------------------
# PHYSICS PROCESS
# -----------------------------
func _physics_process(delta):
	delta_data = delta
	
	if not in_cutscene:
		update_ai_velocity()

	update_state_from_velocity()
	update_animation()
	move_and_slide()
	
# -----------------------------
# AI MOVEMENT (ONLY WRITES VELOCITY)
# -----------------------------
func update_ai_velocity():
	if is_following_player and follow_target:
		facing_target = true
		
		npc_navigation_agent.target_desired_distance = 20.0
		npc_navigation_agent.path_desired_distance = 30.0
		npc_navigation_agent.path_max_distance = 4.0
		follow_speed = follow_target.move_speed
		npc_navigation_agent.target_position = follow_target.global_position
		
		if not npc_navigation_agent.is_navigation_finished():
			var next_pos = npc_navigation_agent.get_next_path_position()
			var dir = (next_pos - global_position).normalized()
			var desired_velocity = dir * follow_speed
			# Smoothly interpolate using acceleration if you want
			npc_navigation_agent.set_velocity(npc_navigation_agent.get_velocity().move_toward(desired_velocity, acceleration * delta_data))
		else:
			npc_navigation_agent.set_velocity(npc_navigation_agent.get_velocity().move_toward(Vector2.ZERO, friction * delta_data))

func on_cutscene_movement(target: Vector2, speed: float) -> void:
	if !is_inside_tree():
		return
	facing_target = false
	forced_animation = false
	cancel_cutscene_movement = false
	npc_navigation_agent.path_desired_distance = 2.0
	npc_navigation_agent.target_desired_distance = 2.0
	npc_navigation_agent.path_max_distance = 2.0
	npc_navigation_agent.target_position = target
	
	while not npc_navigation_agent.is_navigation_finished():
		if cancel_cutscene_movement:
			velocity = Vector2.ZERO
			return
		var next_position := npc_navigation_agent.get_next_path_position()
		var dir := (next_position - global_position).normalized()

		velocity = dir * speed
		await get_tree().physics_frame
		if !is_inside_tree():
			return
	var direction = (target - global_position).normalized()
	velocity = direction * speed
	if global_position.distance_to(target) <= 2.0:
		velocity = Vector2.ZERO

# -----------------------------
# STATE FROM VELOCITY (IMPORTANT)
# -----------------------------
func update_state_from_velocity():
	if velocity.length() > 0.1:
		state = NPCState.WALK
	else:
		state = NPCState.IDLE
		velocity = Vector2.ZERO
# -----------------------------
# NPC BEHAVIOR 
# -----------------------------

# -----------------------------
# ANIMATION (VELOCITY-DRIVEN)
# -----------------------------
func update_animation(custom_animation : String = ""):
	if not animation_player:
		return
	if velocity.length() > 5.0: 
		forced_animation = false
		looking_target = null
	if forced_animation:
		return
	if not custom_animation.is_empty():
		animation_player.play(custom_animation)
		return
	if is_following_player and follow_target or facing_target:
		last_direction = face_target(follow_target)
		if looking_target:
			last_direction = face_target(looking_target)
	else:
		last_direction = animation_direction(velocity)
	if state == NPCState.WALK:
		animation_player.play("walk_" + last_direction)
	else:
		if animation_player.has_animation("idle_" + last_direction):
			animation_player.play("idle_" + last_direction)

# -----------------------------
# CUTSCENE ANIMATION (OPTIONAL)
# -----------------------------
func play_custom_animation(animation: String, speed : float = 1.0) -> void:
	velocity = Vector2.ZERO
	forced_animation = true
	
	var parts := animation.split("_")
	if parts.size() > 1:
		last_direction = parts[1]
	
	if animation_player.has_animation(animation):
		animation_player.play(animation, -1, speed)
		await animation_player.animation_finished
	else:
		print("Animation not found:", animation)
# -----------------------------
# DIRECTION DECODER
# -----------------------------
func animation_direction(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	else:
		return "down" if dir.y > 0 else "up"

func face_target(face_character: CharacterBody2D) -> String:
	if face_character == null:
		return last_direction
	facing_target = true
	var dir := (face_character.global_position - global_position).normalized()
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			return "right"
		else:
			
			return "left"
	else:
		if dir.y > 0:
			
			return "down"
		else:
			
			return "up"
		
# -----------------------------
# INTERACTION
# -----------------------------
func start_interaction():
	if is_interacting:
		return
	is_interacting = true
	await interact()
	is_interacting = false
	
func interact():
	pass

# -----------------------------
# SETTERS
# -----------------------------
func initialize_npc()->void:
	animation_player = get_node("AnimationPlayer")
	set_npc_file_path(npc_file_path)
	set_npc_id(npc_id)
	set_npc_name(npc_name)
	set_npcdialogue(npc_dialogue)
	set_npcchoices(npc_choices)	
	set_npc_dialogue_sprite(npc_dialogue_sprite)
	set_area2d(npc_area_2d)
	set_navigation_agent(npc_navigation_agent)
	
	character_in_cutscene_handler()
	sync_state()
	pass

#optional setter
func set_npc_group(group_name : String)->void:
	add_to_group(group_name)

func set_npc_id(id_: String):
	if not id_ or not npc_id:
		npc_id = npc_name.to_lower()
		return
	npc_id = id_
	
func set_npc_name(name_: String):
	npc_name = name_

func set_npcdialogue(dialogue_: Array):
	npc_dialogue = dialogue_

func set_npcchoices(choices: Array):
	npc_choices = choices

func set_npc_dialogue_sprite(sprite: Sprite2D):
	npc_dialogue_sprite = sprite

func set_area2d(area2d_: Area2D):
	if not area2d_:
		npc_area_2d = get_node_or_null("$Area2D")
		return
	npc_area_2d = area2d_
	npc_area_2d.area_entered.connect(_on_area_entered)
	npc_area_2d.area_exited.connect(_on_area_exited)

func set_navigation_agent(navigation_agent_reference : NavigationAgent2D)->void:
	if not navigation_agent_reference:
		print("NPC: ", npc_name, " don't have navigation_agent_reference")
		return
	npc_navigation_agent = navigation_agent_reference
	npc_navigation_agent.radius = 3.0
	npc_navigation_agent.velocity_computed.connect(_on_velocity_computed)
	npc_navigation_agent.avoidance_enabled = true
	npc_navigation_agent.debug_enabled = false
	
func set_npc_file_path(file_path : String)->void:
	npc_file_path = file_path

func _on_velocity_computed(safe_velocity : Vector2)->void:
	if is_following_player and follow_target:
		var dir = safe_velocity.normalized()
		velocity = dir * follow_speed * 0.9
	else:
		velocity = safe_velocity
