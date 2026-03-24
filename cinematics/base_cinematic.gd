extends Node
class_name Base_Cinematic

var vn_manager : VN_Component_Manager
var screen_effect : ScreenEffect_UI
@onready var bg_image: TextureRect = $cnvs_lyr/bg_image

signal cinematic_starte
signal cinematic_finished(next_scene: PackedScene)

func change_background(image : Texture2D)->void:
	bg_image.texture = image

func fade_out(duration : float = 1.0)->void:
	pass
