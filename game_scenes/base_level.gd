extends Node2D
class_name BaseLevel

signal companion_spawned
var screen_effects_reseted : bool = false

@export_category("Sound")
@export var level_music : AudioStream

var chosen_random_levels : Array = []
var random_level_list : Array = [
	"classroom",
	"bedroom",
	"emptyroom",
	"flowers",
	"graffiti",
	"food",
	"bloodyroom",
	"toys",
	"theater",
	"axe",
	"hallwaycorpse",
	"mirrors",
	"museum",
	"dressingroom"
] 
	
var game_difficulty : String = ""
var game : Game
var LEVEL_NAME := ""
var scene_path := ""
var player: Player = null
var companions_list : Array[BaseNPC] = []

const COMPANION_SCENES := {
	"B": "res://npc/b.tscn",
	"C": "res://npc/c.tscn"
}

func _ready() -> void:
	print("Game node found")
	_auto_detect_scene_path()
	_auto_detect_level_name()
	await init_level()

func init_level() -> void:
	game = get_tree().get_root().get_node_or_null("Game") as Game
	if SessionState.get_difficulty():
		game_difficulty = SessionState.get_difficulty()
	if not game:
		push_error("[BaseLevel] Game node not found")
	if scene_path != "":
		SessionState.set_current_level(scene_path)
	SessionState.set_current_level_name(LEVEL_NAME)
	await locate_player()
	_apply_session_to_player()
	await companion_spawned
	
func _auto_detect_scene_path() -> void:
	if "scene_file_path" in self:
		scene_path = str(self.scene_file_path)
	else:
		scene_path = ""
	if scene_path == "":
		push_warning("[BaseLevel] Scene has no file path! (Probably instanced in-memory)")
	else:
		print("[BaseLevel] Detected scene path:", scene_path)

func _auto_detect_level_name() -> void:
	if LEVEL_NAME == "":
		LEVEL_NAME = name

func set_level_name(level_name: String) -> void:
	LEVEL_NAME = level_name
	SessionState.set_current_level_name(LEVEL_NAME)

func get_level_name() -> String:
	return LEVEL_NAME

func locate_player() -> void:
	while true:
		if not get_tree():
			return
		await get_tree().process_frame
		var p = get_tree().get_first_node_in_group("Player")
		if p and is_instance_valid(p):
			player = p
			return

func _apply_session_to_player() -> void:
	if not player or not is_instance_valid(player):
		push_warning("[BaseLevel] Player not found during load.")
		return

	if SessionState.player.has("health") and "health" in player:
		player.health = SessionState.player["health"]

	# Inventory
	if SaveSystem.is_loading_from_file and SessionState.player.has("inventory"):
		InventoryManager.set_all_items(SessionState.player["inventory"])
	elif SessionState.player["inventory"].size() == 0:
		InventoryManager.add_item("potion", "Black Book", 1)
		InventoryManager.add_item("sword", "Red Book", 1)
		SessionState.player["inventory"] = InventoryManager.get_all_items()
	else:
		InventoryManager.set_all_items(SessionState.player["inventory"])

	# Restore player position
	if SessionState.player["scenes"].has(LEVEL_NAME):
		var scene_data = SessionState.player["scenes"][LEVEL_NAME]
		if scene_data.has("position"):
			player.global_position = scene_data["position"]

func _spawn_companion(companion_marker: Array = []) -> void:
	if SessionState.player["difficulty"] == "Hard":
		return
	if not SessionState.player_has_companion():
		companion_spawned.emit()
		return
	
	var companions = SessionState.player["companion"]["npcs"]
	if companions.is_empty():
		return
	
	await get_tree().process_frame

	var ysort: Node = get_node_or_null("Y_Sort")
	if not ysort:
		push_warning("[BaseLevel] Y_Sort missing! Adding to level root.")
		ysort = self
	
	for i in range(companions.size()):
		var data = companions[i]
		
		if not data.has("scene"):
			push_error("[BaseLevel] Companion has no scene:", data)
			continue
		var packed_scene : PackedScene = load(data["scene"])

		if not packed_scene:
			push_error("[BaseLevel] Failed to load:", data["scene"])
			continue

		# Instantiate and add to scene
		var npc = packed_scene.instantiate()
		npc.name = data["npc_id"]
		ysort.add_child(npc)

		companions_list.append(npc)
		# Optional spawn marker per companion
		if i < companion_marker.size():
			var marker_name = companion_marker[i]
			var marker := get_node_or_null(marker_name)
			if marker:
				npc.global_position = marker.global_position
			else:
				npc.global_position = player.global_position
		else:
			npc.global_position = player.global_position
	companion_spawned.emit()

func pick_randomlevel()->String:
	var random_level = random_level_list.pick_random()
	if random_level in chosen_random_levels:
		pass
	chosen_random_levels.append(random_level)
	return "res://gamescenes/level_c2_%s.tscn" % random_level

func get_companions()-> Array[BaseNPC]:
	return companions_list
	
func get_current_companion()-> BaseNPC:
	if companions_list.size() > 0:
		return companions_list[0]
	return

func get_npc_by_id(id: String) -> BaseNPC:
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.npc_id == id:
			return npc
	return null
