extends Node2D
class_name SceneManager

signal character_reach_target(character : CharacterBody2D)

var waiting_for : Dictionary = {}
var cancel_scene_movement : bool = false

func _ready() -> void:
	var game = get_tree().get_root().get_node("Game") as Game
	game.cutscene_started.connect(on_scene_cutscene_started)
	game.cutscene_finished.connect(on_scene_cutscene_finished)
	
#pass the position where the character should move ex. Marker2D position
func move_to(target_location: Vector2, character: CharacterBody2D, speed: float, has_custom_animation: bool = false, animation_timing: String = "", animation: String = "") -> void:
	if not get_tree():
		return
	if not is_instance_valid(character):
		return
	if not character.has_method("on_cutscene_movement"):
		return
	character.in_cutscene = true
	
	if has_custom_animation and animation_timing == "before":
		character.play_custom_animation(animation)

	await character.on_cutscene_movement(target_location, speed)

	if not is_instance_valid(character):
		return
	if character.cancel_cutscene_movement:
		return
	if !is_inside_tree():
		return
	await get_tree().physics_frame

	if has_custom_animation and animation_timing == "after":
		character.play_custom_animation(animation)
	
	character.in_cutscene = false
	character.velocity = Vector2.ZERO
	character_reach_target.emit(character)

func move_camera(character : CharacterBody2D, target_position: Vector2)->void:
	var scene_camera := Camera2D.new()
	add_child(scene_camera)
	scene_camera.add_to_group("scene_camera")
	scene_camera.enabled = true
	scene_camera.make_current()
	scene_camera.zoom = Vector2(3, 3)
	scene_camera.global_position = character.global_position
	var tween := create_tween()
	tween.tween_property(
		scene_camera,
		"global_position",
		target_position,
		5.0
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	character.camera_2d.enabled = false
	pass

func shake_camera(scene_camera : Camera2D, shake_power: float, max_power: float, duration : float)->void:
	var shake_camera_timer = Timer.new()
	add_child(shake_camera_timer)
	shake_camera_timer.one_shot = true
	shake_camera_timer.wait_time = duration
	shake_camera_timer.start()
		
	var original_rotation = scene_camera.rotation
	var original_offset = scene_camera.offset
	
	scene_camera.zoom = Vector2(3, 3)
	#shake
	while is_instance_valid(shake_camera_timer) and shake_camera_timer.time_left > 0:
		scene_camera.rotation = shake_power * max_power * randf()
		scene_camera.offset.y = shake_power * max_power * randf()
		scene_camera.offset.x = shake_power * max_power * randf()
		await get_tree().process_frame
	
	scene_camera.rotation = original_rotation
	scene_camera.offset = original_offset

func wait_for(characters : Array)->void:
	waiting_for.clear()
	for character in characters:
		waiting_for[character] = true
	while not waiting_for.is_empty():
		var arrived = await character_reach_target
		waiting_for.erase(arrived)
	print("[scene manager] Waiting DONE: ", characters)
	pass
	
func wait_time(time : float)->void:
	if cancel_scene_movement:
		return
	await get_tree().create_timer(time).timeout

func on_scene_cutscene_started()->void:
	cancel_all_cutscene_movements()
	
func on_scene_cutscene_finished()->void:
	cancel_all_cutscene_movements()

func cancel_all_cutscene_movements():
	cancel_scene_movement = true
	for character in get_tree().get_nodes_in_group("npc") + get_tree().get_nodes_in_group("player"):
		character.cancel_cutscene_movement = true
	cancel_scene_movement = false
	
func reset_camera(character : CharacterBody2D)->void:
	var scene_cameras = get_tree().get_nodes_in_group("scene_camera")
	for camera in scene_cameras:
		camera.queue_free()
	character.camera_2d.enabled = true
	character.camera_2d.make_current()
	pass
