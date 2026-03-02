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
	pass # Replace with function body.

func set_effect(effect : String, animation_speed: float) -> void:
	print("[ScreenEffect UI]: effect to set: ", effect)
	#var animation_speed = animation_speeds[speed]
	match effect:
		"fade_in":
			animation_player.play("fade_in", -1, animation_speed)
			await animation_player.animation_finished
		"fade_out":
			animation_player.play("fade_out", -1, animation_speed)
			await animation_player.animation_finished
		"show_chapter":
			animation_player.play("show_titlecard", -1, animation_speed)
			await animation_player.animation_finished
		"cutscene_effect":
			letter_box_top.scale.y = 1.25
			letter_box_bottom.scale.y = 1.25
			cinematic_player.play("show_letterbox", -1, animation_speed)
			await cinematic_player.animation_finished
		_:
			print("[ScreenEffect UI] Defaulting to fade_black")
			animation_player.play("fade_black", -1, animation_speed)
			await animation_player.animation_finished

func reset_effect()->void:
	animation_player.play("RESET")
	await animation_player.animation_finished
	pass
