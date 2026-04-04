extends Node
class_name Base_Cinematic

const BG_BLUESKY = preload("uid://h742hnmb65m3")
const BG_HOUSE = preload("uid://5vmfd0kdvg0y")


@onready var bg_image: TextureRect = $"Base Nodes/bg_image"

signal cinematic_started
signal cinematic_finished(next_scene: PackedScene)

func change_background(image : Texture2D)->void:
	bg_image.texture = image

func cinematic_blackout()->void:
	await Game.manager.screen_effect_ui.set_effect("fade_black", 1.0)
	
func cinematic_fade_out(duration : float = 1.0)->void:
	await Game.manager.screen_effect_ui.set_effect("fade_out", duration)

func cinematic_fade_in(duration : float = 1.0)->void:
	await Game.manager.screen_effect_ui.set_effect("fade_in", duration)

func cinematic_show_title(chapter_name : String, chapter_text : String, speed : float)->void:
	await Game.manager.screen_effect_ui.show_chapter(chapter_name, chapter_text, speed)
		   
func cinematic_narrate(narration : Array)->void:
	await Game.manager.vn_component_manager.get_narration(narration)
