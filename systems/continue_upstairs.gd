extends Node2D
class_name ContinueExploration

@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var area_2d: Area2D = $Area2d
@onready var static_body_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var area_2d_collision: CollisionShape2D = $Area2d/CollisionShape2D
@onready var player_nearby = false

@onready var target_point_npcluke: Marker2D = $TargetPoint_npcluke
@onready var target_point_npcember: Marker2D = $TargetPoint_npcember
@onready var target_point_player: Marker2D = $TargetPoint_player

@onready var target_point_player_2: Marker2D = $TargetPoint_player2
@onready var target_point_luke_2: Marker2D = $TargetPoint_luke2
@onready var target_point_ember_2: Marker2D = $TargetPoint_ember2

@onready var luke: npc_luke = $"../Y_Sort/NPC_Luke"
@onready var ember: npc_ember = $"../Y_Sort/NPC_Ember"

var player : Player
var game : Game
var npc_companion

var confirmation_message = [
	"Continue exploration upstairs"
]

var confirmation = [
	{"choice" : "Go upstairs", "choice_id" : "continue"},
	{"choice" : "Stay here", "choice_id" : "stay"}
]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Player
	game = get_tree().get_root().get_node("Game") as Game
	
	area_2d.body_entered.connect(_body_entered)
	area_2d.body_exited.connect(_body_exited)

func _body_entered(body) -> void:
	print("BODY HAS ENTERED: ", body)
	if not body.is_in_group("Player"):
		return
	player_nearby = true
	player_notice()
	
func _body_exited(body) -> void:
	if body.is_in_group("Player"):
		player_nearby = false

func player_notice() -> void:
	await game.vn_component_manager.get_narration(confirmation_message)
	var choice_id = await game.vn_component_manager.get_choices(confirmation)
	print("Choice ID: ", choice_id)
	
	if choice_id == "stay":
		print("Player chose to stay")
		game.scene_manager.move_to(player.global_position + Vector2(0, 50), player, 50, true, "before", "idle_down")
		return
	play_cutscene()


func play_cutscene() -> void:
	SessionState.input_locked = true
	print("Input disabled.")
	
	_play_cutscene_sequence()
	
	static_body_collision.disabled = true
	area_2d_collision.disabled = true
	print("Pathway opened.")

	SessionState.input_locked = false
	print("Input enabled.")

func _play_cutscene_sequence() -> void:
	game.scene_manager.cancel_all_cutscene_movements()
	var player_line: Array[String] = [
		"Guys, let's head upstairs.",
	]
	
	var ember_line: Array = [
		["Hey, what with the enthusiasm...",
		"You're pumped now too, huh?"],
		["Even luke seems fired up, nice!"]
	]
	
	var luke_line: Array = [
		["On your lead-",
		"There's not much to explore here anyways..."
		]
	]
	
	game.start_cutscene()
	game.screen_effect_ui.set_effect("fade_in", 0.5)
	await game.scene_manager.wait_time(2.0)
	
	game.scene_manager.move_to(target_point_player.global_position, player, 30, true, "after", "idle_down")
	await game.vn_component_manager.get_dialogue(player_line, "I", player.player_dialogue_sprite)
	game.scene_manager.move_to(target_point_npcember.global_position, ember, 40, true, "after", "idle_up")
	game.scene_manager.move_to(target_point_npcluke.global_position, luke, 45, true, "after", "idle_up")
	await game.vn_component_manager.get_dialogue(ember_line[0], ember.npc_name, ember.npc_dialogue_sprite)
	await game.vn_component_manager.get_dialogue(luke_line[0], luke.npc_name, luke.npc_dialogue_sprite)
	ember.face_target(luke)
	await game.vn_component_manager.get_dialogue(ember_line[1], ember.npc_name, ember.npc_dialogue_sprite)
	
	game.scene_manager.move_to(target_point_player_2.global_position, player, 60, false, "", "")
	#wait for player to move ahead
	await game.scene_manager.wait_time(0.5)
	game.scene_manager.move_to(target_point_luke_2.global_position, luke, 60)
	await game.scene_manager.wait_time(1.5)
	game.scene_manager.move_to(target_point_ember_2.global_position, ember, 60)
	
	SessionState.add_companion(luke.npc_id, luke.npc_file_path)
	SessionState.add_companion(ember.npc_id, ember.npc_file_path)
	await game.scene_manager.wait_for([player])
	
	game.end_cutscene(true)
	SessionState.input_locked = false
	SessionState.set_global_data("continue_exploration", true)
	
	
