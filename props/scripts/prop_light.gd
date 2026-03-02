extends Node2D
class_name Prop_Light

@onready var light: PointLight2D = $Sprite2D/PointLight2D

@export_category("Light Settings")
@export var light_energy : float = 0.66
@export var cast_shadow : bool = false
@export_enum("idle_light", "idle_fading", "idle_unlit") var light_states : String = "idle_light"
@export var light_flicker : bool = false
@export var light_flicker_rate : float = 0.5
@export var light_flicker_scale_min : float = 0.8
@export var light_flicker_scale_max : float = 1.0

@onready var light_animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	light.energy = light_energy
	light.shadow_enabled = cast_shadow
	var chosen_state = light_states
	play_animation_effect(chosen_state)
	if light_flicker:
		start_light_flicker()

func play_animation_effect(animation: String, animation_speed : float = 1.0)->void:
	print("Playing Animation: ", animation)
	light_animation_player.play(animation,-1, animation_speed)
	await light_animation_player.animation_finished

func start_light_flicker( )->void:
	while light_flicker and is_inside_tree():
		light.texture_scale = randf_range(
			light_flicker_scale_min,
			light_flicker_scale_max
		)
		await get_tree().create_timer(light_flicker_rate).timeout
		

	
	
