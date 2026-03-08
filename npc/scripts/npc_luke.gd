class_name npc_luke
extends BaseNPC

var level_1f_dialogue_intro = [
	"These books… they look fragile",
	"and it seems like they are fond of folk literatures and novels",
	"Most of the pages are barely readable… some are almost falling apart."
]

var dialogue_exploration = [
	".."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	super._ready()
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
	print("Luke is in cutscene? ", in_cutscene)
	var game = get_tree().get_root().get_node("Game")
	game.vn_component_manager.get_dialogue(npc_dialogue, npc_name, npc_dialogue_sprite)
	await game.vn_component_manager.dialogue_finished

	#choice_id = await game.vn_component_manager.get_choices(npc_choices)
	forced_animation = false
