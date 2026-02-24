extends Node2D
class_name SaveBook_System
var player_nearby = false

const SAVESYSTEM_UI = preload("uid://coxkk35x4355w")
var save_ui : SaveSystem_UI
@onready var save_book_player: AnimationPlayer = $save_book_player
@onready var save_book_particles: CPUParticles2D = $save_book_particles

@onready var area_2d: Area2D = $Area2D
var is_interacting = false

func _ready() -> void:
	save_book_player.play("save_desk_initialize")
	area_2d.body_entered.connect(player_entered)
	area_2d.body_exited.connect(player_exited)
	pass
	
func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("Interact"):
		if is_interacting:
			return
		#get_tree().paused = true
		is_interacting = true
		player_interact()
		is_interacting = false
		#get_tree().paused = false
		pass
	pass
	
func player_entered(body)->void:
	if body.name == "Player":
		player_nearby = true
		save_book_player.play("save_desk_initialize")
		save_book_particles.amount = 32
	pass
	
func player_exited(body)->void:
	if body.name == "Player":
		player_nearby = false
		save_book_particles.amount = 9
	pass
	
func player_interact()->void:
	if not save_ui:
		save_ui = SAVESYSTEM_UI.instantiate()
		add_child(save_ui)
	get_tree().paused = true
	save_ui.visible = true
	save_ui.show_save_mode("SAVE GAME")

func save_data()->void:
	
	pass
