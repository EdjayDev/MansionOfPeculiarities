extends BaseLevel
class_name Level_C2_Emptyroom

@onready var block_player: AnimationPlayer = $Block_Pathway/block_player

@onready var prop_light_candle_type_1_: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_"
@onready var prop_light_candle_type_1_2: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_2"
@onready var prop_light_candle_type_1_3: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_3"
@onready var prop_light_candle_type_1_4: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_4"
@onready var prop_light_candle_type_1_5: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_5"
@onready var prop_light_candle_type_1_6: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_6"
@onready var prop_light_candle_type_1_7: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_7"
@onready var prop_light_candle_type_1_8: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_8"
@onready var prop_light_candle_type_1_9: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_9"
@onready var prop_light_candle_type_1_10: Prop_Light = $"Y_Sort/Props/prop_light_candle-type1_10"

var max_subdialog = 2 
var min_subdialog = 0

var unlit_candles : Array = []
var prop_to_unlit : Array = []
	
func _ready() -> void:
	set_level_name("Emptyroom")
	scene_path = "res://game_scenes/level_c2_emptyroom.tscn"
	await init_level()
	
	prop_to_unlit = [
		prop_light_candle_type_1_,
		prop_light_candle_type_1_2,
		prop_light_candle_type_1_3,
		prop_light_candle_type_1_4,
		prop_light_candle_type_1_5,
		prop_light_candle_type_1_6,
		prop_light_candle_type_1_7,
		prop_light_candle_type_1_8,
		prop_light_candle_type_1_9,
		prop_light_candle_type_1_10
	]
	
	var subdialog_timer = Timer.new()
	subdialog_timer.one_shot = false
	subdialog_timer.wait_time = 9.0
	add_child(subdialog_timer)
	subdialog_timer.start()
	if get_current_companion():
		subdialog_timer.timeout.connect(companion_subdialog)
	else:
		subdialog_timer.timeout.connect(player_subdialog)
	await get_tree().create_timer(3.0).timeout
	block_player.play("block_path", -1, 1)
	var proplight_unlit_timer = Timer.new()
	proplight_unlit_timer.one_shot = false
	proplight_unlit_timer.wait_time = 1.0
	add_child(proplight_unlit_timer)
	proplight_unlit_timer.start()
	proplight_unlit_timer.timeout.connect(unlit_proplight)

func unlit_proplight()->void:
	var available_proplight = return_available_proplights()
	if available_proplight.is_empty():
		Game.manager.set_game_over("TRAPPED", "The last light faded")
		return
	var picked_to_unlit : Prop_Light = available_proplight.pick_random()
	unlit_candles.append(picked_to_unlit)
	await picked_to_unlit.play_animation_effect("idle_fading", 1.0)

func player_subdialog()->void:
	var random_subdialog = [
		"Am I trapped",
		"How do I get out"
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], player)

func return_available_proplights()->Array:
	var returned_available_proplight = []
	for light in prop_to_unlit:
		if light not in unlit_candles:
			returned_available_proplight.append(light)
	return returned_available_proplight

func companion_subdialog()->void:
	if min_subdialog == max_subdialog:
		return
	var random_subdialog = [
		"We are trapped!",
		"How do we get out",
		"The candles are fading"
	]
	var picked_subdialog = random_subdialog.pick_random()
	Game.manager.set_subdialog([picked_subdialog], get_current_companion())
	min_subdialog += 1
