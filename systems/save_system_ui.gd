extends CanvasLayer
class_name SaveSystem_UI

signal savesystem_updated
signal request_load_game(slot: int, level_path: String)

@onready var label_title: Label = $SaveSystemUI_Panel/SaveSystemUI_HeaderPanel/label_title

@onready var btn_save_1: Button = $"SaveSystemUI_Panel/VBoxContainer/btn-save1"
@onready var btn_save_2: Button = $"SaveSystemUI_Panel/VBoxContainer/btn-save2"
@onready var btn_save_3: Button = $"SaveSystemUI_Panel/VBoxContainer/btn-save3"

@onready var btn_return: Button = $SaveSystemUI_Panel/SaveSystemUI_HeaderPanel/btn_return

var saving_data = false
	
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_save_slots()
	call_deferred("_deferred_setup")
	btn_save_1.grab_focus()
	
func _deferred_setup() -> void:
	_connect_buttons()
	update_save_slots()

func _connect_buttons() -> void:

	_connect_slot(btn_save_1, 1)
	_connect_slot(btn_save_2, 2)
	_connect_slot(btn_save_3, 3)
	
	btn_return.pressed.connect(_on_return_pressed)

func _connect_slot(button : Button, slot: int) -> void:
	#var btn_save: Button = button.get_node("btn_save")
	#var btn_load: Button = button.get_node("btn_load")
	#btn_save.pressed.connect(_on_save_pressed.bind(slot))
	#btn_load.pressed.connect(_on_load_pressed.bind(slot))
	button.pressed.connect(_on_load_pressed.bind(slot))
	button.pressed.connect(_on_save_pressed.bind(slot))


# ------------------------
# Save / Load
# ------------------------
func _on_save_pressed(slot: int) -> void:
	if not saving_data:
		return
		
	get_tree().paused = true
	print("[SaveSystem_UI] Saving to slot:", slot)

	var p = get_tree().get_first_node_in_group("Player")
	if p:
		SessionState.set_player_health(p.health if "health" in p else 100)
		SessionState.set_inventory(InventoryManager.get_all_items())

	# Get current scene
	var current_scene = get_tree().get_current_scene()

	# Only save if this is a level
	if current_scene is BaseLevel:
		# Guaranteed correct file path
		var level_path = current_scene.scene_file_path
		if level_path == "":
			push_warning("[SaveSystem_UI] WARNING: current level has no file path!")
		else:
			SessionState.set_current_level(level_path)

		# Display name
		SessionState.set_current_level_name(current_scene.get_level_name())
	
	# 1. Get current scene
	var lvl = get_tree().get_current_scene()
	if lvl is BaseLevel:
		SessionState.set_current_level(lvl.scene_path)
		SessionState.set_current_level_name(lvl.get_level_name())

	# 2. Save player position for this scene
	if p:
		SessionState.set_player_position(SessionState.world["current_level_name"], p.global_position)
		
	if get_tree().get_node_count_in_group("npc") > 0:
		for npc in get_tree().get_nodes_in_group("npc"):
			print("NPC: ", npc.npc_id)
			SessionState.set_npc_position(npc.npc_id, SessionState.world["current_level_name"], npc.global_position)
			
	# 3. Save health + inventory
	if p and "health" in p:
		SessionState.set_player_health(p.health)
	SessionState.set_inventory(InventoryManager.get_all_items())
	
	SessionState.set_slot_status("Active")
	SessionState.set_slot_number(slot)
	
	# Save to file
	SaveSystem.save_from_session(slot)
	update_save_slot(slot)
	savesystem_updated.emit()
	print("[SaveSystem_UI] Slot %d saved successfully." % slot)


func _on_load_pressed(slot: int) -> void:
	if saving_data:
		return
	SessionState.reset_session()
	print("[SaveSystem_UI] Loading from slot:", slot)
	if not SaveSystem.slot_exists(slot):
		print("[SaveSystem_UI] Slot empty:", slot)
		return

	# Load session state
	SaveSystem.load_game(slot)
	
	# Get level path from loaded slot
	var world_data = SaveSystem.get_world_data(slot)
	var level_path = world_data.get("current_level", "")
	if level_path == "":
		print("[SaveSystem_UI] ERROR: No level path stored in save slot! Using default.")
		level_path = "res://game_scenes/level_main.tscn"

	print("[SaveSystem_UI] Emitting request to load:", level_path)
	request_load_game.emit(slot, level_path)
	update_save_slot(slot)
	savesystem_updated.emit()
	
# ------------------------
# UI preview
# ------------------------
func update_save_slots() -> void:
	_update_slot(btn_save_1, 1)
	_update_slot(btn_save_2, 2)
	_update_slot(btn_save_3, 3)
	
func update_save_slot(slot: int) -> void:
	match slot:
		1:
			_update_slot(btn_save_1, 1)
		2:
			_update_slot(btn_save_2, 2)
		3:
			_update_slot(btn_save_3, 3)

func _update_slot(button_slot : Button, slot: int) -> void:
	var label: Label = button_slot.get_node("Label")
	var location_label : Label = button_slot.get_node("Location-Label")
	var slot_data: Dictionary = SaveSystem.read_slot(slot)
	var slot_status_data = slot_data.get("slot_status", {})
	var slot_status = slot_status_data.get("status", "Inactive")
	if slot_status == "Inactive" or slot_status == "":
		label.text = "Empty Slot"
		return

	var player_data: Dictionary = slot_data.get("player", {})
	var world_data: Dictionary = slot_data.get("world", {})
	
	var level_name = world_data.get("current_level_name", "Unknown")
	var health = player_data.get("health", 0)
	var items_count = player_data.get("inventory", {}).size()

	label.text = "Location: %s\nHealth: %d\nItems: %d" % [level_name, health, items_count]
	location_label.text = ""
# ------------------------
# UI visibility
# ------------------------
func _on_return_pressed() -> void:
	get_tree().paused = false
	self.visible = false

func show_save_mode(ui_title : String):
	label_title.text = ui_title
	saving_data = true

func show_load_mode(ui_title : String):
	label_title.text = ui_title
	saving_data = false
