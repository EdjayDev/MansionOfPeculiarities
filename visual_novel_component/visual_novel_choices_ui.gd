class_name VN_ChoicesUI extends Control 

@onready var vbox_choices_container: VBoxContainer = $Vbox_ChoicesContainer
@onready var button_template: Button = $button_template

signal choice_selected (choice : String)
signal choice_selected_items (choice : Array)
var Choice_Items : Array = []
var last_choices : Array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vbox_choices_container.visible = false
	button_template.visible = false
	pass # Replace with function body.
	
func set_choices(choices: Array) -> void:
	# remove previously created buttons
	clear_choices()
			
	for choice in choices:
		var new_choicebtn = button_template.duplicate()
		new_choicebtn.text = choice["choice"]
		vbox_choices_container.add_child(new_choicebtn)
		new_choicebtn.visible = true
		vbox_choices_container.visible = true
		
		new_choicebtn.pressed.connect(func(): 
			on_choice_selected(choice["choice_id"])
		)

func set_multiple_choices(choices: Array, minimum: int, max : int)->void:
	clear_choices()
	for choice in choices:
		var new_choicebtn = button_template.duplicate()
		new_choicebtn.text = choice["chpoce"]
		vbox_choices_container.add_child(new_choicebtn)
		new_choicebtn.visible = true
		vbox_choices_container.visible = true
		
		var temp_choice_id = choice["choice_id"]
		var choice_id = new_choicebtn.pressed.connect(get_multiple_choices(temp_choice_id))
		print(choice_id)
		
func get_multiple_choices(choice_id : String)->String:
	return choice_id
	
func set_multiplechoices_ofItems(choices_items: Array, required : int) -> void:
	clear_choices()
	last_choices = choices_items
	print("Required selection: ", required)
	for choice in choices_items:
		var new_choicebtn = button_template.duplicate()
		new_choicebtn.text = choice["choice_item"]
		vbox_choices_container.add_child(new_choicebtn)
		new_choicebtn.visible = true
		vbox_choices_container.visible = true
		
		new_choicebtn.pressed.connect(func():
			new_choicebtn.set_meta("selected", !new_choicebtn.get_meta("selected", false))
			if new_choicebtn.get_meta("selected"):
				new_choicebtn.modulate = Color(0.9, 0, 0)
			else:
				new_choicebtn.modulate = Color(1, 1, 1)
			on_choice_item_selected(choice["choice_itemid"], required)
		)
	pass
	

func on_choice_selected(choice_id : String) -> void:
	choice_selected.emit(choice_id)
	vbox_choices_container.visible = false
	pass

func on_choice_item_selected(choice_id : String, required : int) -> void:
	var existing_index = -1
	for i in range(Choice_Items.size()):
		if typeof(Choice_Items[i]) == TYPE_DICTIONARY and Choice_Items[i].get("choice_itemid", "") == choice_id:
			existing_index = i
			break
		
	if existing_index != -1:
		print("Removed Item(s): ", choice_id)
		Choice_Items.remove_at(existing_index)
	else:
		var item_data = {
			"choice_itemid": choice_id,
			"choice_item": find_choice_name(choice_id)
		}
		Choice_Items.append(item_data)
		print("Selected Item(s): ", Choice_Items)
	
	if Choice_Items.size() == required:
		InventoryManager.add_items(Choice_Items)
		print("Added Item(s): ", Choice_Items)
		choice_selected_items.emit(Choice_Items)
		vbox_choices_container.visible = false	
	pass
	
func find_choice_name(choice_id: String) -> String:
	for c in last_choices:
		if c["choice_itemid"] == choice_id:
			return c["choice_item"]
	return choice_id


func clear_choices() -> void:
	Choice_Items.clear()
	for child in vbox_choices_container.get_children():
		if child != button_template:
			child.queue_free()
	pass
