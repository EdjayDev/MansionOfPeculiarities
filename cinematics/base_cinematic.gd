extends Node
class_name Base_Cinematic

signal cinematic_finished(next_scene: PackedScene)

var hasTitleCard = false
var first_transition = true
var current_scene_index := 0
var scene_order: Array = []
var scene_data: Dictionary = {}
var possible_endings: Dictionary = {}
var is_running : bool = false
var on_ending : bool = false

var titleCard = ""
var titleText = ""
var narration: Array = []
var choices: Array = []
var required_selection: int = 0

@onready var game: Game = get_tree().get_root().get_node("Game")
@onready var vn_component_manager: VN_Component_Manager = get_tree().root.get_node("Game/SceneUI_CanvasLayer/VN_Component_Manager")
@onready var effect_ui: ScreenEffect_UI = get_tree().root.get_node("Game/SceneUI_CanvasLayer/ScreenEffect_UI")

# -------------------------
# CINEMATIC FLOW
# -------------------------
func start_cinematic() -> void:
	print("[CINEMATIC] Starting cinematic")
	
	# FULL RESET
	first_transition = true
	on_ending = false
	is_running = true
	current_scene_index = 0
	
	game.is_in_cinematic = true
	await run_cinematic_flow()

func run_cinematic_flow() -> void:
	while is_running and current_scene_index < scene_order.size():
		var key = scene_order[current_scene_index]

		# Await this to ensure background fades finish
		await load_scene(key)

		# Show narration
		await vn_component_manager.get_narration(narration)
		

		# Show choices if available
		if choices.size() > 0:
			var chosen
			if required_selection > 0:
				chosen = await vn_component_manager.get_choices_items(choices, required_selection)
			else:
				chosen = await vn_component_manager.get_choices(choices)

			await apply_conditions(chosen)
		
		current_scene_index += 1

	# Cinematic finished -> emit next scene
	if on_ending:
		print("ON ENDING ", on_ending)
		return
	if not is_running or current_scene_index >= scene_order.size():
		cinematic_finished.emit(get_next_scene())

# -------------------------
# SCENE LOADING
# -------------------------
func load_scene(key: String) -> void:
	print("loading scene on cutscene")
	var data = scene_data.get(key, {})
	narration = data.get("narration", [])
	choices = data.get("choices", [])
	required_selection = data.get("required_items", 0)
	# Change background if specified
	if data.has("bg") and has_node("Scene_BG/Background/BackgroundImage"):
		await change_background(data["bg"])
	first_transition = false

func change_background(new_bg: Texture) -> void:
	var bg_node: TextureRect = $Scene_BG/Background/BackgroundImage
	if bg_node == null or new_bg == null:
		push_error("[CUTSCENE] BG node for cinematic missing!")
		return

	if effect_ui and !first_transition:
		print("[CINEMATIC] AWAITING FADEOUT")
		await effect_ui.set_effect("fade_out", 2)
	else:
		print("[CINEMATIC] AWAITING FADEBLACK")
		await effect_ui.set_effect("fade_instant", 1)
		if hasTitleCard:
			effect_ui.text_chaptername.text = titleCard
			effect_ui.text_chaptertext.text = titleText
			effect_ui.text_chaptername.visible = true
			effect_ui.text_chaptertext.visible = true
			await effect_ui.set_effect("show_chapter", 1)
			
	bg_node.texture = new_bg
	print("successfully change bg on cutscene")
	if effect_ui:
		await effect_ui.set_effect("fade_in", 0.5)
		
# -------------------------
# CHOICE / CONDITIONS
# -------------------------
func apply_conditions(chosen: Variant) -> void:
	if chosen == null:
		push_warning("apply_conditions received null")
		return
	
	if typeof(chosen) == TYPE_ARRAY:
		print("Player selected items: ", chosen)
		# Handle inventory items here if needed
		return

	if typeof(chosen) != TYPE_STRING:
		push_warning("Unexpected choice type: " + str(typeof(chosen)))
		return
		
	print("Chosen: ", chosen)
	print("Current Possible endings: ", possible_endings)
	if possible_endings.has(chosen):
		await run_ending(chosen)
		pass

func run_ending(key: String) -> void:
	is_running = false
	on_ending = true
	
	var ending = possible_endings.get(key, {})
	var end_narr = ending.get("narration", [])
	var gameover_text = ending.get("gameover_text", "")
	await vn_component_manager.get_narration(end_narr)
	await game.set_game_over(gameover_text, "", "cinematic")
	print("Ending reached:", key)

# -------------------------
# OVERRIDABLE
# -------------------------
func get_next_scene() -> PackedScene:
	push_warning("get_next_scene() not overridden in child class!")
	return null

func get_titleCard(set_titlecard : String)-> void:
	titleCard = set_titlecard

func get_titleText(set_titletext : String)-> void:
	titleText = set_titletext
