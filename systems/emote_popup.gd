extends Node2D
class_name Emote_Popup

@export var duration := 1.2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass
	
func play_emote(emote_name : String)-> void:
	animation_player.play("emote_" + emote_name)
	self.visible = true
	if !is_inside_tree():
		return
	await get_tree().create_timer(duration).timeout
	self.visible = false
	pass
