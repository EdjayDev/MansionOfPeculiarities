extends CanvasLayer
class_name Guide

var game

func _ready() -> void:
	game = get_tree().get_root().get_node("Game") as Game

func _process(_delta: float) -> void:
	if game.is_in_cinematic or game.is_in_cutscene:
		if not visible:
			return
		visible = false

func show_guide()->void:
	visible = true
	pass
