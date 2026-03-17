extends CanvasLayer
class_name Guide

signal objective_changed(objective : String)
@onready var v_box_container: NinePatchRect = $Control/VBoxContainer
@onready var objectives_title: Label = $Control/VBoxContainer/objectives_title
@onready var objectives_text: RichTextLabel = $Control/VBoxContainer/objectives_text

var game : Game

func _ready() -> void:
	game = get_tree().get_root().get_node("Game") as Game
	objective_changed.connect(set_objective)
	
func _process(_delta: float) -> void:
	if game.is_in_cinematic or game.is_in_cutscene:
		if not visible:
			return
		visible = false

func set_objective(objective_to_set : String)->void:
	objectives_text.text = objective_to_set

func show_guide()->void:
	visible = true
	pass
