extends BaseNPC
class_name Neutral_Ghost


@export_category("Item Fields")
@export var cherished_items : Array = []
@export var gift_item_id = ""
@export var gift_item = ""

@export_category("Item Drops")
@onready var ghost_drop: Sprite2D = $ghost_drop
@export var ghost_drop_required_data : String
@export var ghost_drop_dialogue : Array[String]= []

@onready var ghost_drop_interaction_area: Area2D = $ghost_drop/Area2D
@onready var ghost_drop_prop_component: PropInteract_Item = $ghost_drop/PropInteractItem_Component

signal level_interaction_set
var interaction_ready = false
var dialogue = [
	"This place still remembers me",
	"It must be somewhere...",
]

var random_dialogue = [
	["The silence keeps correcting my breathing."],
	["I cut the endings because they hurt less that way."],
	["Someone always stood where I should have been."],
	["The pauses were safer than the words. I hid there."],
	["I don’t remember my voice anymore. Only the shape it made."],
	["Something rewrites me when I repeat myself."],
	["Nothing I made survived me. That feels deliberate."],
	["I stayed awake rewriting the same moment until it stopped breathing."],
	["I taught silence how to speak. It learned too well."],
	["If I stop arranging things, everything collapses. Including me."]
]

var dialogue_gratitude = [
	"...Yes.",
	"I remember it now.",
	"I was afraid to leave without it.",
	"Thank you… for seeing me."
]

var dialogue_hate = [
	"That's not it..."
]
var dialogue_exploration = [
	".."
]

var choices = [
	{"choice": "...", "choice_id" : "do_nothing"}
]

var item_choices = [
	{"choice": "Give Item", "choice_id" : "give_item"},
	{"choice": "...", "choice_id" : "do_nothing"}
]

func _ready():
	initialize_npc()
	set_npc_group("neutral")
	set_npcdialogue(dialogue)
	
	ghost_drop.visible = false
	ghost_drop_prop_component.prop_interact_dialogue = ghost_drop_dialogue
	ghost_drop_prop_component.prop_required_data = ghost_drop_required_data
	ghost_drop_prop_component.process_mode = Node.PROCESS_MODE_DISABLED
	

func interact()->void:
	if !interaction_ready:
		return
	face_target(player_get)
	if SessionState.get_scene_data("interacted_ghost", false):
		set_npcdialogue(random_dialogue[randi_range(0, random_dialogue.size()-1)])
		if InventoryManager.equipped_item:
			var choice = await Game.manager.vn_component_manager.get_choices(item_choices)
			if choice == "give_item":
				print("equipped item: ", InventoryManager.equipped_item)
				give_cherish_item(InventoryManager.equipped_item)
				return
			else:
				return
	level_interaction_set.emit()
	SessionState.set_scene_data("interacted_ghost", true)
	
func give_cherish_item(item : String)->void:
	SessionState.input_locked = true
	var game = get_tree().get_root().get_node("Game") as Game
	if item in cherished_items:
		SessionState.input_locked = true
		game.start_cutscene()
		face_target(player_get)
		npc_area_2d.process_mode = Node.PROCESS_MODE_DISABLED
		await game.vn_component_manager.get_dialogue(dialogue_gratitude, "?", npc_dialogue_sprite)
		
		game.end_cutscene(true)
		SessionState.input_locked = false
		SessionState.set_scene_data(ghost_drop_required_data, true)
		ghost_drop_prop_component.process_mode = Node.PROCESS_MODE_INHERIT
		InventoryManager.remove_item(item)
		await play_custom_animation("ghost_fading")
	else:
		await game.vn_component_manager.get_dialogue(dialogue_hate, "?", npc_dialogue_sprite)
	pass
