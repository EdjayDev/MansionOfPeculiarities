extends Node
class_name Session_State

var input_locked : bool = false
var is_game_over : bool = false

#Player Temporary Data
var temp_player_position
var temp_level_path
var temp_spawn_marker
var temp_companion_marker
var temp_global_data

#Saved Slot State
var slot_status := {
	"status": "",
	"slot": -1
}

# Player session state
var player := {
	"health": 100,
	"inventory": {},      # { item_id: {display_name, amount}, ... }
	"scenes": {},          # per-level data: scenes["Level_Main"] = {"position": Vector2}
	"difficulty": "",
	"companion": {
		"active": false,
		"npcs": [],
	}
}

# World session state
var world := {
	"current_level": "",
	"current_level_name": "",
	"levels_completed": [],
	"npcs": {
		
	}
}

var global_data: Dictionary = {}

var requested_level_path: String = ""
var requested_spawn_id: String = "start"

#test
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact"):
		var game = get_tree().get_root().get_node("Game") as Game
		#print("Session Input Locked: ", input_locked)
		#print("Game is in cutscene: ", game.is_in_cutscene)
		#game.cancel_all_cutscene_movements()
		#print("Saved Data: ", SaveSystem.save_data)
		#print("Session Slot status: ", slot_status)
		#InventoryManager.add_item("item_silverkey", "Silver Key", 1)
		#print("Temp Global Data: ", temp_global_data)
		#print("Global Data: ", global_data)
		#game.set_game_over("TEST", "TESTING THE GAME", "default")
		#print("[SESSION STATE] session state game over: ", SessionState.is_game_over)
		#print("[SESSION STATE] session state is_transitioning: ", Game.manager.is_transitioning)
		#game.scene_manager.shake_camera(active_player.camera_2d, 1.0, 2.0, 4.0)
		#Game.manager.choice_timer.start_choice_timer()
		#Game.manager.set_subdialog(["The eyes are moving"], get_tree().get_first_node_in_group("Player"))
		#print(get_tree().get_first_node_in_group("Player").global_position)
		#Game.manager.choice_timer.start_choice_timer()
		pass

func set_temp_data(level_path : String, spawn_marker : String, companion_marker : Array, session_global_data : Dictionary)->void:
	temp_level_path = level_path
	temp_spawn_marker = spawn_marker
	temp_companion_marker = companion_marker
	temp_global_data = session_global_data.duplicate(true)
	pass


# --- Helpers ---
func reset_session()->void:
	input_locked = false

	# Player session state
	player = {
		"health": 100,
		"inventory": {},      # { item_id: {display_name, amount}, ... }
		"scenes": {},          # per-level data: scenes["Level_Main"] = {"position": Vector2}
		"difficulty": "",
		"companion": {
			"active": false,
			"npcs": [],
		}
	}

	# World session state
	world = {
		"current_level": "",
		"current_level_name": "",
		"levels_completed": [],
		"npcs": {
			
		}
	}

	global_data = {}

	requested_level_path = ""
	requested_spawn_id = "start"
	
func set_slot_status(status : String)->void:
	slot_status["status"] = status
	pass

func set_slot_number(slot_number)->void:
	slot_status["slot"] = slot_number
		
func get_slot_status()->String:
	return slot_status["status"]

func get_slot_number()->int:
	return slot_status["slot"]

func set_scene_data(key: String, value : Variant) -> void:
	var level_name = world["current_level_name"]
	if not player["scenes"].has(level_name):
		player["scenes"][level_name] = {}
	player["scenes"][level_name][key] = value

func get_scene_data(key: String, default_value = null):
	var level_name = world["current_level_name"]
	if player["scenes"].has(level_name) and player	["scenes"][level_name].has(key):
		return player["scenes"][level_name][key]
	print("[Session] Default Value: ", default_value)
	return default_value

func set_global_data(key: String, value: Variant) -> void:
	global_data[key] = value

func get_global_data(key: String, default_value: Variant = null) -> Variant:
	if global_data.has(key):
		return global_data[key]
	return default_value
	
func set_player_position(level_name: String, pos: Vector2) -> void:
	# Always store the explicit Vector2 the caller gives (caller should pass actual player.pos)
	if not player["scenes"].has(level_name):
		player["scenes"][level_name] = {}
	player["scenes"][level_name]["position"] = pos

func get_player_position(level_name: String) -> Variant:
	# Return null when there is no saved position
	if player["scenes"].has(level_name) and player["scenes"][level_name].has("position"):
		return player["scenes"][level_name]["position"]
	return null

func set_player_health(h: int) -> void:
	player["health"] = h

func set_inventory(inv: Dictionary) -> void:
	player["inventory"] = inv

func set_difficulty(difficulty : String)->void:
	player["difficulty"] = difficulty

func get_difficulty()->String:
	return player["difficulty"]

func set_current_level(level_name: String) -> void:
	world["current_level"] = level_name

func set_current_level_name(level_name: String) -> void:
	world["current_level_name"] = level_name

func add_completed_level(level_name: String) -> void:
	if not world["levels_completed"].has(level_name):
		world["levels_completed"].append(level_name)

# Make pos optional (pass null if you don't have a pos to record)
func add_companion(npc_id: String, npc_file_path: String) -> void:
	var companions = player["companion"]["npcs"]
	print("npc id: ", npc_id)
	print("npc file path: ", npc_file_path)
	# Prevent duplicates
	for c in companions:
		if c["npc_id"] == npc_id:
			return

	companions.append({
		"npc_id": npc_id,
		"scene": npc_file_path
	})

	player["companion"]["active"] = true

func remove_companion(npc_id: String) -> void:
	var companions = player["companion"]["npcs"]

	for i in range(companions.size()):
		if companions[i]["npc_id"] == npc_id:
			companions.remove_at(i)
			break

	if companions.is_empty():
		player["companion"]["active"] = false

func clear_companion() -> void:
	player["companion"]["npcs"].clear()
	player["companion"]["active"] = false

func get_companion_id() -> Array:
	var ids: Array = []
	for c in player["companion"]["npcs"]:
		ids.append(c["npc_id"])
	return ids

func player_has_companion() -> bool:
	return player["companion"]["active"]

#NPC
func set_npc_position(npc_id : String, level_name: String, pos: Vector2) -> void:
	# Always store the explicit Vector2 the caller gives (caller should pass actual player.pos)
	if not world["npcs"].has(level_name):
		world["npcs"][level_name] = {}
	if not world["npcs"][level_name].has(npc_id):
		world["npcs"][level_name][npc_id] = {}
	
	world["npcs"][level_name][npc_id]["position"] = pos

func get_npc_position(npc_id: String, level_name: String) -> Vector2:
	if world["npcs"].has(level_name) and world["npcs"][level_name].has(npc_id):
		return world["npcs"][level_name][npc_id].get("position", Vector2.ZERO)
	return Vector2.ZERO
