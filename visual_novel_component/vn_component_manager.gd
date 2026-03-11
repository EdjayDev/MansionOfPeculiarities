class_name VN_Component_Manager extends Control

@onready var vn_dialog_ui: Control = $VN_Component_DialogUI
@onready var vn_narration_ui: Control = $VN_Component_NarrationUI

@onready var narration_text: RichTextLabel = $VN_Component_NarrationUI/PanelContainer/RichTextLabel

@onready var dialog_container: Control = $VN_Component_DialogUI/Dialog
@onready var dialogue_speaker: Label = $VN_Component_DialogUI/Dialog/Speaker/Label
@onready var dialogue_text: RichTextLabel = $VN_Component_DialogUI/Dialog/MarginContainer/RichTextLabel
@onready var dialogue_speaker_sprite: Sprite2D = $VN_Component_DialogUI/Dialog/speaker_sprite

@onready var vn_component_choices_ui: VN_ChoicesUI = $VN_Component_ChoicesUI

@export var text_speed_default = 0.035
@export var skiptext = false

var vn_timer_on = false
var vn_timer = 0

signal narration_finished
signal dialogue_started
signal dialogue_finished
signal choice_made
signal choice_item_made

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vn_dialog_ui.visible = false
	vn_narration_ui.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	dialogue_started.connect(dialogue_finished_handler)

func dialogue_finished_handler()->void:
	Game.manager.inventory_ui.visible = false
	pass
	
func get_dialogue(dialogue: Array, speaker_name : String, speaker_sprite : Sprite2D, text_speed : float = text_speed_default)-> void:
	if !is_inside_tree():
		return
	dialogue_started.emit()
	SessionState.input_locked = true
	vn_dialog_ui.visible = true
	dialogue_text.text = ""
	dialogue_speaker.text = speaker_name
	dialogue_speaker_sprite.texture = speaker_sprite.texture
	dialogue_speaker_sprite.scale = speaker_sprite.scale
	dialogue_speaker_sprite.region_enabled = speaker_sprite.region_enabled
	dialogue_speaker_sprite.region_rect = speaker_sprite.region_rect
	dialog_container.size.y = round(dialog_container.size.y)
	for line in dialogue:
		await text_effect(dialogue_text, line, text_speed)
		await get_tree().create_timer(1.0, true).timeout
	vn_dialog_ui.visible = false
	dialogue_finished.emit()
	SessionState.input_locked = false

func get_narration(narration: Array, text_speed = text_speed_default) -> void:
	await _run_narration(narration, text_speed)

func _run_narration(narration: Array, text_speed) -> void:
	dialogue_started.emit()
	SessionState.input_locked = true
	narration_text.text = ""
	vn_narration_ui.visible = true
	
	for line in narration:
		await text_effect(narration_text, line, text_speed)
		await get_tree().create_timer(1.0, true).timeout
		
	vn_narration_ui.visible = false
	SessionState.input_locked = false

func text_effect(label: RichTextLabel, text: String, text_speed: float = text_speed_default) -> void:
	if !is_inside_tree():
		return
	skiptext = false
	label.text = ""
	var i = 0
	while i < text.length():
		if skiptext:
			# Remove all [Emphasis] tags
			var cleaned_text = text.replace("[Emphasis]", "")
			while cleaned_text.find("[Emphasis=") != -1:
				var start_idx = cleaned_text.find("[Emphasis=")
				var end_idx = cleaned_text.find("]", start_idx)
				if end_idx != -1:
					cleaned_text = cleaned_text.substr(0, start_idx) + cleaned_text.substr(end_idx + 1)
				else:
					break
			label.text = cleaned_text
			break  # stop typing loop

		# Emphasis tag handling
		if text.substr(i, 10) == "[Emphasis]":
			await get_tree().create_timer(1.0, true, true).timeout
			i += 10
			continue
		elif text.substr(i, 10) == "[Emphasis=":
			var j = i + 10
			var duration_str = ""
			while j < text.length() and text[j] != "]":
				duration_str += text[j]
				j += 1
			var duration = float(duration_str)
			await get_tree().create_timer(duration, true, true).timeout
			i = j + 1
			continue
		if label == null:
			return
		label.text += text[i]
		i += 1
		await get_tree().create_timer(text_speed, true, true).timeout
		
func get_choices(choices: Array) -> String:
	SessionState.input_locked = true
	print("getting choices")
	vn_component_choices_ui.set_choices(choices)
	vn_component_choices_ui.choice_selected.connect(_on_choice_selected)
	
	# Wait for the signal
	var choice_id: String = await self.choice_made
	vn_component_choices_ui.choice_selected.disconnect(_on_choice_selected)
	SessionState.input_locked = false
	return choice_id
	
# Internal helper for signal connection
func _on_choice_selected(choice_id: String) -> void:
	choice_made.emit(choice_id)
	
func get_choices_items(choices_items : Array, required : int) -> Array:
	SessionState.input_locked = true
	print("getting item choices")

	# Clear previous selections
	var result_items := []

	# Set multiple item choices in the UI
	vn_component_choices_ui.set_multiplechoices_ofItems(choices_items, required)

	# Wait for player to select the required number of items
	var selected_items: Array = await vn_component_choices_ui.choice_selected_items
	result_items = selected_items.duplicate()

	# Disconnect the signal so it doesn't fire multiple times
	if vn_component_choices_ui.choice_selected_items.is_connected(choice_selected_item):
		vn_component_choices_ui.choice_selected_items.disconnect(choice_selected_item)
	
	SessionState.input_locked = false
	return result_items
	
func choice_selected(choice_id : String) -> void:
	choice_made.emit(choice_id)
	vn_component_choices_ui.choice_selected.disconnect(choice_selected)
	pass

func choice_selected_item(selected_items : Array) ->void:
	choice_item_made.emit(selected_items)
	#vn_component_choices_ui.choice_selected_items.disconnect
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SkipText"):
		print("[VN Manager] SKIPPING")
		skiptext = true
		return
	skiptext = false
