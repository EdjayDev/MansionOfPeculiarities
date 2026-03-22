extends Node
class_name Base_Cinematic

var vn_manager : VN_Component_Manager
@onready var bg_image: TextureRect = $cnvs_lyr/bg_image

signal cinematic_started
signal cinematic_finished(next_scene: PackedScene)

func change_background(image : Texture2D)->void:
	bg_image.texture = image
