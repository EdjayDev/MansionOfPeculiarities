extends CanvasLayer
class_name Choice_Timer

signal choice_timer_finished

@onready var container: CenterContainer = $Control/Container
@onready var choicetimer_player: AnimatedSprite2D = $Control/Container/ChoiceTimer_Player
@onready var main_animation_player: AnimationPlayer = $main_animation_player
var choice_timer_frames = 16

func _ready() -> void:
	choice_timer_finished.connect(stop_choice_timer)
	choicetimer_player.visible = false
	
func start_choice_timer(speed : float = 1.0)->void:
	main_animation_player.play("start_animation")
	await main_animation_player.animation_finished
	choicetimer_player.frame = 0
	var half_y = container.size.y / 2
	var half_x = container.size.x / 2
	choice_timer_frames = choicetimer_player.frame
	choicetimer_player.position = Vector2(half_x, half_y)
	choicetimer_player.play("choice_timer_countdown", speed)
	await choicetimer_player.animation_finished
	choice_timer_finished.emit()
	
func stop_choice_timer()->void:
	choicetimer_player.pause()
	main_animation_player.play("stop_animation")
	await main_animation_player.animation_finished
	choicetimer_player.stop()
	
func set_consequence()->void:
	pass

	
