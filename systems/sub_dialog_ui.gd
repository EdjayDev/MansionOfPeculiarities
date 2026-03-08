extends Control
class_name SubDialog_UI

@onready var subdialog_label: RichTextLabel = $MarginContainer/RichTextLabel

var character_sprite_ref
var text_speed_default : float = 0.035

func _ready() -> void:
	visible = false
	pass
	
func _process(_delta: float) -> void:
	if not is_instance_valid(character_sprite_ref):
		queue_free()
		return
	var world_to_view = character_sprite_ref.get_canvas_transform()
	var view_position = world_to_view * character_sprite_ref.global_position + Vector2(size.x / -2, size.y * -3)
	position = view_position
	visible = true

func get_subdialogue(subdialogue: Array, character_speaker : CharacterBody2D)-> void:
	if not subdialog_label:
		push_error("[SubDialog] Sub Dialog UI don't exist")
		return
	subdialog_label.text = ""
	character_sprite_ref = character_speaker.get_node("Sprite2D")
	for line in subdialogue:
		await Game.manager.vn_component_manager.text_effect(subdialog_label, line, text_speed_default)
		await get_tree().create_timer(1.0).timeout
	visible = false
	queue_free()
