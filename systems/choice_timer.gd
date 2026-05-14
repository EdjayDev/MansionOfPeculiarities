extends CanvasLayer
class_name Choice_Timer

signal choice_timer_finished

@onready var container: CenterContainer = $Control/Container
@onready var choicetimer_player: AnimatedSprite2D = $Control/Container/ChoiceTimer_Player
@onready var main_animation_player: AnimationPlayer = $main_animation_player

var is_running: bool = false
var current_speed: float = 1.0

func _ready() -> void:
	choice_timer_finished.connect(stop_choice_timer)
	choicetimer_player.visible = false


func start_choice_timer(speed: float = 1.0) -> void:
	if is_running:
		return
	
	is_running = true
	current_speed = speed
	
	choicetimer_player.visible = true
	
	main_animation_player.play("start_animation")
	await main_animation_player.animation_finished
	
	_center_timer()
	
	choicetimer_player.frame = 0
	choicetimer_player.play("choice_timer_countdown", current_speed)
	
	await choicetimer_player.animation_finished
	
	if is_running:
		choice_timer_finished.emit()


func stop_choice_timer() -> void:
	if !is_running:
		return
	
	is_running = false
	
	choicetimer_player.pause()
	
	main_animation_player.play("stop_animation")
	await main_animation_player.animation_finished
	
	choicetimer_player.stop()
	choicetimer_player.visible = false


func _center_timer() -> void:
	var half_y := container.size.y / 2
	var half_x := container.size.x / 2
	
	choicetimer_player.position = Vector2(half_x, half_y)


func reset_choice_timer() -> void:
	stop_choice_timer()
	choicetimer_player.frame = 0


func set_consequence() -> void:
	pass
