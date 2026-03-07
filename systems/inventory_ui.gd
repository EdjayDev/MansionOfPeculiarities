class_name Inventory_UI
extends CanvasLayer

@onready var inventory_panel: Panel = $Inventory_Panel
@onready var v_box_container: VBoxContainer = $Inventory_Panel/PanelContainer/VBoxContainer
@onready var template_button: Button = $Inventory_Panel/PanelContainer/VBoxContainer/template_button

func _ready() -> void:
	InventoryManager.inventory_updated.connect(update_inventory)
	update_inventory()

func update_inventory() -> void:
	# Clear previous buttons, except the template
	for child in v_box_container.get_children():
		if child != template_button:
			child.queue_free()
	
	# Loop through items and create buttons from template
	for item_id in InventoryManager.get_all_items().keys():
		var item_data = InventoryManager.items[item_id]
		var display_name = item_data.get("display_name", item_id)
		var amount = item_data.get("amount", 0)

		# Duplicate the template button
		var button = template_button.duplicate()
		button.text = "%s x%d" % [display_name, amount]
		button.focus_mode = Control.FOCUS_ALL
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.visible = true  # Make sure the duplicate is visible

		# Connect signal for this specific item
		button.pressed.connect(_on_item_selected.bind(item_id))
		
		# Add to the VBoxContainer
		v_box_container.add_child(button)

	# Focus the first real item (skip template if it’s hidden)
	var first_button = null
	for child in v_box_container.get_children():
		if child != template_button:
			first_button = child
			break

	if first_button:
		first_button.grab_focus()

func _on_item_selected(item_id):
	InventoryManager.equip_item(item_id)
	
func focus_first_item():
	for child in v_box_container.get_children():
		if child != template_button:
			child.grab_focus()
			break
			
func _unhandled_input(event: InputEvent) -> void:
	if SessionState.input_locked:
		return

	# Interact: press the currently focused button
	if event.is_action_pressed("Interact"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused.is_class("Button") and focused != template_button:
			focused.emit_signal("pressed")

	# Toggle inventory
	if event.is_action_pressed("Inventory"):
		visible = !visible
		if visible:
			focus_first_item()
