extends Control
class_name  ScreenEffect_UI

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cinematic_player: AnimationPlayer = $Cinematic_Player
@onready var text_chaptername: RichTextLabel = $text_chaptername
@onready var text_chaptertext: RichTextLabel = $text_chaptertext

@onready var texture_rect: TextureRect = $TextureRect
@onready var cinematic_letter_box: Control = $"Cinematic-LetterBox"
@onready var letter_box_top: TextureRect = $"Cinematic-LetterBox/LetterBox-Top"
@onready var letter_box_bottom: TextureRect = $"Cinematic-LetterBox/LetterBox-Bottom"

#future implementation
enum effects 
{
	fade_in,
	fade_out,
	show_chapter,
	cutscene_effect,
}
enum screen_effects_speed
{
	slow,
	normal,
	fast
}
var animation_speeds = {
	screen_effects_speed.slow : 0.5,
	screen_effects_speed.normal : 1.0,
	screen_effects_speed.fast : 2.0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass # Replace with function body.

func set_effect(effect : String, animation_speed: float) -> void:
	print("[ScreenEffect UI]: effect to set: ", effect)
	var animation_name = ""
	match effect:
		"fade_in":
			animation_name = "fade_in"
		"fade_out":
			animation_name = "fade_out"
		"show_chapter":
			animation_name = "show_titlecard"
		"cutscene_effect":
			letter_box_top.scale.y = 1.25
			letter_box_bottom.scale.y = 1.25
			cinematic_player.stop()
			cinematic_player.play("show_letterbox", -1, animation_speed)
			await cinematic_player.animation_finished
			return
		_:
			print("[ScreenEffect UI] Defaulting to fade_black")
			animation_name = "fade_black"

	animation_player.stop()
	animation_player.play(animation_name, -1, animation_speed)
	await animation_player.animation_finished

func show_chapter(chapter_name : String, chapter_text : String, speed : float = 1.0)->void:
	text_chaptername.text = chapter_name
	text_chaptertext.text = chapter_text
	await set_effect("show_chapter", speed)
	

func reset_effect()->void:
	animation_player.play("RESET")
	await animation_player.animation_finished
	pass
