extends Node2D
class_name PropInteract_Item

static var active_prop: PropInteract_Item = null

#PROP COMPONENT REFERENCES / RESOURCES
var game : Game = null
@onready var prop_item_canvas_layer: CanvasLayer = $PropItem_CanvasLayer
@onready var riddle_ui: Riddle_UI = $PropItem_CanvasLayer/riddle_ui
var prop_interaction_ui = preload("uid://jf6by2vn3ay3").instantiate()

const PROP_INTERACT_SHADERMATERIAL = preload("uid://dhb3v2brq5pm0")
var prop_visuals: Array[CanvasItem] = []

#PROP 
const sound_interact_book = preload("uid://b2cjo8rlahov8")
const sound_interact_default = preload("uid://b8gkwiqj3mj0q")
const sound_interact_lock = preload("uid://y67bol3wfuhd")

#PROP COMPONENT SIGNALS / FLAGS
var player_nearby = false
signal interaction_allowed(unlocked: bool)
var check_requirement_completed : bool = false
var interaction_choices_successful : bool = false

#PROP COMPONENT EXPORTED SETTINGS
@export_category("Dialogue")
@export var prop_interact_dialogue : Array = []
@export var prop_swap_interact_dialogue = []
@export_category("Inventory")
@export var stop_adding_item : bool = true
@export var difficulty_based : bool = false
@export var item_increment : int = 0
@export var itemid_to_add = ""
@export var item_to_add = ""
@export var itemamount_to_add = 1
@export_category("Interaction")
@export var animation_name : Array[String] = []
@export var animate_prop : bool = false
@export var repeat_animation_speed : float = 1.0
var repeat_animation : bool = false
var animate_player : AnimationPlayer = null
@export var interaction_options : Array[Dictionary] = []
#interaction_options example:
	#{
		#"choice": "Do something",
		#"choice_id": "do_something",
		#"actions": [
			#{"name": "play_prop_narration", "set_value": ["default narration"]},
			##stop_adding: bool, is_difficulty_based: bool, increment: int, item_id: String, item_name: String, amount: int
			#{"name": "set_inventory_settings", "set_value": [true, false, 0, "item_default", "DEFAULT ITEM", 1]}
		#]
	#}
	#{
		#"choice": "Do nothing",
		#"choice_id": "leave",
		#"actions": []
	#}

@export var remove_after : bool = false
@export_category("Prop Interaction Audio")
@export var play_interact_audio : bool = false
@export_enum("default", "book", "lock") var interact_successful_sound : String = "default"
@export_enum("default", "book", "lock") var interact_failed_sound : String = "default"
@export_category("Conditions")
@export var debug : bool = false
@export var entry_transitioner_unlocked : bool = true
@export var interaction_option_dependent : bool = false
@export var unlock_flag : String = ""
@export var can_interact : bool = true
@export var can_interact_multiple_times: bool = false
@export var required_item_id: String = ""
@export var required_item_amount : int = 1
@export var required_item_dialogue : Array[String] = []
@export var prop_required_data : String = ""

var prop_interaction_sounds = {
	"default": sound_interact_default,
	"book": sound_interact_book,
	"lock": sound_interact_lock
}

var interact_done = false
var is_interacting = false

func _ready() -> void:
	game = get_tree().get_root().get_node("Game") as Game
	set_process_unhandled_input(false) 
	prop_item_canvas_layer.layer = 4
	riddle_ui.visible = false
	riddle_ui.riddle_answered_correctly.connect(set_interaction_choices_state)
	
	for sprites in get_parent().get_children():
		if sprites is Sprite2D:	
			prop_visuals.append(sprites)
		for sprites_ in sprites.get_children():
			if sprites_ is Sprite2D:
				prop_visuals.append(sprites_)
	
	if get_parent().has_node("Area2D"):
		var area_2d = get_parent().get_node_or_null("Area2D")
		area_2d.area_entered.connect(_on_area_entered)
		area_2d.area_exited.connect(_on_area_exited)
	if animate_prop:
		for child in get_parent().get_children():
			if child is AnimationPlayer:
				animate_player = child
				break
			if not animate_player:
				push_warning("animate prop true but missing AnimationPlayer in: " + get_parent().name)
	load_saved_state()
	
func load_saved_state()->void:
	await get_tree().process_frame
	# Load saved state
	if prop_required_data != "":
		if SessionState.get_scene_data(prop_required_data, false):
			required_item_id = ""
			required_item_dialogue = []
			interaction_option_dependent = false
			if prop_swap_interact_dialogue:
				prop_interact_dialogue = prop_swap_interact_dialogue
			repeat_animation = true
			if remove_after:
				get_parent().queue_free()
			
func _on_area_entered(area) -> void:
	if area.name == "Player_InteractionArea":
		player_nearby = true
		PropInteract_Item.active_prop = self
		set_process_unhandled_input(true) 
		for sprite in prop_visuals:
			sprite.material = PROP_INTERACT_SHADERMATERIAL
		if SessionState.get_scene_data(prop_required_data, false) and repeat_animation:
			complete_interaction()

func _on_area_exited(area) -> void:
	if area.name == "Player_InteractionArea":
		player_nearby = false
		if PropInteract_Item.active_prop == self:
			PropInteract_Item.active_prop = null
		set_process_unhandled_input(false) 
		for sprite in prop_visuals:
			sprite.material = null	

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("Interact"):
		return
	if is_interacting:
		return
	if interact_done and not can_interact_multiple_times:
		return
	
	get_viewport().set_input_as_handled()
	is_interacting = true
	await interact()
	is_interacting = false

func interact() -> void:
	SessionState.input_locked = true
	check_requirement_completed = false
	if !can_interact:
		is_interacting = false 
		return
		
	check_prop_inventory_setting()
	await play_prop_narration()
	print("[PROP INTERACT] NARRATION DONE")
	if prop_required_data != "":
		if SessionState.get_scene_data(prop_required_data, false):
			return
	check_prop_requirements()
	print("[PROP INTERACT] CHECK PROP DONE")
	if interaction_option_dependent:
		await handle_interaction_options()
	play_prop_audio()
	apply_inventory_settings()
	
	if remove_after:
		get_parent().queue_free()

	if can_complete_interaction():
		await complete_interaction()


func play_prop_narration(custom_narration : Array = []) -> void:
	if not custom_narration.is_empty():
		prop_interact_dialogue = custom_narration
	if prop_interact_dialogue.is_empty():
		return
	
	var resolved_dialogue: Array[String] = []

	for line in prop_interact_dialogue:
		if "{amount}" in line:
			line = line.replace("{amount}", str(itemamount_to_add))
		resolved_dialogue.append(line)

	await game.vn_component_manager.get_narration(resolved_dialogue)
	if prop_swap_interact_dialogue:
		prop_interact_dialogue = prop_swap_interact_dialogue
	
func play_prop_audio()->void:
	if !play_interact_audio:
		return
	var prop_audio_player = game.bg_audio_effects as AudioStreamPlayer2D
	prop_audio_player.pitch_scale = 1.25
	prop_audio_player.volume_db = -2.0
	
	if not check_requirement_completed:
		prop_audio_player.stream = prop_interaction_sounds.get(interact_failed_sound, sound_interact_default)
		prop_audio_player.play()
		return
	
	prop_audio_player.stream = prop_interaction_sounds.get(interact_successful_sound, sound_interact_default)
	prop_audio_player.play()

func can_complete_interaction()->bool:
	if not check_requirement_completed:
		return false
		
	if interaction_option_dependent:
		return interaction_choices_successful
	
	return true	

func play_prop_animation()->void:
	if not animate_prop:
		return
	if not animate_player:
		return
	if animate_player.is_playing():
		return 
	var animation : Animation = animate_player.get_animation(animation_name[0])
	animation.loop_mode = Animation.LOOP_NONE
	SessionState.input_locked = true
	if repeat_animation:
		animate_player.play(animation_name[0], -1, repeat_animation_speed)
	else:
		animate_player.play(animation_name[0], -1, 1)
	await animate_player.animation_finished
	SessionState.input_locked = false
		
func complete_interaction()->void:
	await play_prop_animation()
	if entry_transitioner_unlocked:
		interaction_allowed.emit()
	repeat_animation = false
	interact_done = true
	is_interacting = false
	SessionState.input_locked = false

func check_prop_requirements()->void:
	if required_item_id != "":
		if not InventoryManager.has_required_item(required_item_id, required_item_amount):
			if debug:
				SessionState.set_global_data("debug", true)
			await game.vn_component_manager.get_narration(required_item_dialogue)
			print("You need ", required_item_id, " to interact!")
			is_interacting = false
			SessionState.input_locked = false
			return

	check_requirement_completed = true
	if not interaction_option_dependent:
		SessionState.set_scene_data(prop_required_data, true)

func check_prop_inventory_setting()->void:
	if difficulty_based:
		var difficulty = SessionState.get_difficulty()
		match difficulty:
			"easy":
				itemamount_to_add = 1
				required_item_amount = 1
			"medium":
				itemamount_to_add = 2
				required_item_amount = 2
			"hard":
				itemamount_to_add = 3
				required_item_amount = 3
		if item_increment > 0:
			itemamount_to_add += item_increment

func handle_interaction_options()->void:
	if not check_requirement_completed:
		return
	if interaction_options.is_empty():
		return
	var choices_selection = []
	for choice_list in interaction_options:
		var get_choices_dictionary = {}
		get_choices_dictionary["choice"] = choice_list["choice"]
		get_choices_dictionary["choice_id"] = choice_list["choice_id"]
		choices_selection.append(get_choices_dictionary)
	var choice_id_selected = await game.vn_component_manager.get_choices(choices_selection)
	for choice in interaction_options:
		if choice["choice_id"] != choice_id_selected:
			continue

		execute_choice_actions(choice)
		return
		
func execute_choice_actions(selected_choice: Dictionary) -> void:
	print("Selected Choice: ", selected_choice)
	if not selected_choice.has("actions"):
		return
	
	for action_dict in selected_choice["actions"]:
		if not action_dict.has("name"):
			continue

		var func_name = action_dict["name"]
		var parameter_value = action_dict.get("set_value", [])

		if has_method(func_name):
			callv(func_name, parameter_value)
	
func apply_inventory_settings()->void:
	print("[PropInteract] Applying inventory settings")
	if not check_requirement_completed:
		return
	if interaction_option_dependent:
		if not interaction_choices_successful:
			return
	InventoryManager.remove_item(required_item_id, required_item_amount)
	if itemid_to_add != "" and item_to_add != "":
		InventoryManager.add_item(itemid_to_add, item_to_add, itemamount_to_add, interaction_options)
		print("[PropInteract] Adding item: ", itemid_to_add, item_to_add)
	if stop_adding_item:
		itemid_to_add = ""
		item_to_add = ""


##########################################		
#Interaction_Options Callable Functions
##########################################
func show_riddle_ui(riddle_text : String, answer : String)->void:
	riddle_ui.riddle.text = riddle_text
	riddle_ui.riddle_answer_reference = answer
	riddle_ui.visible = true
	pass

func set_prop_game_over(game_over_text : String, game_over_flavortext: String)->void:
	Game.manager.set_game_over(game_over_text, game_over_flavortext)

func set_inventory_settings(stop_adding: bool, is_difficulty_based: bool, increment: int, item_id: String, item_name: String, amount: int) -> void:
	self.stop_adding_item = stop_adding
	self.difficulty_based = is_difficulty_based
	self.item_increment = increment
	self.itemid_to_add = item_id
	self.item_to_add = item_name
	self.itemamount_to_add = amount

func set_interaction_choices_state(value : bool):
	interaction_choices_successful = value
	if value:
		SessionState.set_scene_data(prop_required_data, true)
		
