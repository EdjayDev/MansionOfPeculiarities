extends BaseLevel
class_name Level_C2_Classroom


@onready var blackboard_container: MarginContainer = $"Y_Sort/Props/prop_blackboard-type1_/CanvasLayer/blackboard_container"
@onready var blackboard_text_marker: Marker2D = $"Y_Sort/Props/prop_blackboard-type1_/blackboard_text_marker"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var add_path: Node2D = $Add_Path
var blackboard_text_location 
var added_path : bool = false

func _ready() -> void:
	set_level_name("Classroom")
	scene_path = "res://game_scenes/level_c2_classroom.tscn"
	await init_level()
	var subdialog_timer = Timer.new()
	subdialog_timer.one_shot = false
	subdialog_timer.wait_time = 30.0
	add_child(subdialog_timer)
	subdialog_timer.start()
	if get_current_companion():
		subdialog_timer.timeout.connect(companion_subdialog)
	else:
		subdialog_timer.timeout.connect(player_subdialog)
	

func _process(_delta: float) -> void:
	if !is_inside_tree():
		return
		
	if blackboard_text_marker:
		var world_to_view = blackboard_text_marker.get_canvas_transform()
		var view_position = world_to_view * blackboard_text_marker.global_position
		blackboard_container.global_position = view_position
	if SessionState.get_scene_data("classroom_riddled_answered", false):
		if added_path:
			return
		added_path = true
		trigger_add_path()
		

func player_subdialog()->void:
	var random_subdialog = [
		"Am I trapped",
		"How do I get out"
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], player)
	pass

func companion_subdialog()->void:
	var random_subdialog = [
		"It's been a while",
		"Can't we break outside these walls",
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], get_current_companion())
	pass

func trigger_add_path()->void:
	animation_player.play("add_path", -1, 1)
	await animation_player.animation_finished
	add_path.queue_free()
