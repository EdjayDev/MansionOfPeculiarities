class_name npc_ember
extends BaseNPC

var level_1f_dialogue_intro = [
	"These books are weird!",
	"Some are scribbled all over and only a few of them are still readable.",
	"But,[Emphasis=1.0] I'd say as a decoration they look pretty neat.",
	"..."
]

var dialogue_exploration = [
	"."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	initialize_npc()
	set_npc_group("npc")
	
func interact():
	if SessionState.get_scene_data("IntroCutscene", false):
		set_npcdialogue(level_1f_dialogue_intro)
	if SessionState.get_global_data("continue_exploration", false):
		set_npcdialogue(dialogue_exploration)
		return
		
	face_target(player_get)
	print("Talking to NPC...")
	print("Ember is in cutscene? ", in_cutscene)
	var game = get_tree().get_root().get_node("Game") as Game
	game.vn_component_manager.get_dialogue(npc_dialogue, npc_name, npc_dialogue_sprite)
	await game.vn_component_manager.dialogue_finished
	
	#choice_id = await game.vn_component_manager.get_choices(npc_choices)
	forced_animation = false
	
