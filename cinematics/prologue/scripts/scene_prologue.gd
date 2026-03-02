extends Base_Cinematic
class_name ScenePrologue

@export var set_titleCard : String
@export var set_titleText : String
@export var next_scene: PackedScene

@onready var background_image: TextureRect = $Scene_BG/Background/BackgroundImage

# Preload backgrounds
var prologue_scenebg_1 = preload("res://cinematics/assets/bg_forest.jpg")
var prologue_scenebg_2 = preload("res://cinematics/assets/bg_room.jpg")
var prologue_scenebg_3 = preload("res://cinematics/assets/bg_mansion.png")
var prologue_scenebg_4 = preload("res://cinematics/assets/bg_mansion_doorway.jpg")

# Scene Data
var prologue_data = {
	"Start": {
		"bg": prologue_scenebg_1,
		"narration": [
			"3 students wanted to explore the mansion, well hidden deep inside a forest...",
			"One of the students wants to go, and the other voted against it.",
			"Now you must make a choice..."
		],
		"choices": [
			{"choice": "Decided to go", "choice_id": "enter_mansion"},
			{"choice": "Decided not to go", "choice_id": "leave_mansion"}
		],
		"required_items": 0
	},
	"Continue": {
		"bg": prologue_scenebg_2,
		"narration": ["They prepare for their adventure...", "You bring 2 items. What do you take?"],
		"choices": [
			{"choice_item": "Flashlight", "choice_itemid": "item_flashlight"},
			{"choice_item": "Necklace", "choice_itemid": "item_necklace"},
			{"choice_item": "Compass", "choice_itemid": "item_compass"},
			{"choice_item": "Glue", "choice_itemid": "item_glue"}
		],
		"required_items": 2
	},
	"Meetup": {
		"bg": prologue_scenebg_3,
		"narration": ["After meeting up with the others, they make their journey...", "You see a dog. You decide to..."],
		"choices": [
			{"choice_item": "Greet it", "choice_itemid": "item_unknownKey"},
			{"choice_item": "Ignore it", "choice_itemid": "item_ignore"}
		],
		"required_items": 1
	},
	"Meetup2": {
		"bg": prologue_scenebg_4,
		"narration": ["After heading in, you find a crumpled old map..."],
		"choices": [
			{"choice": "Let's go In!", "choice_id": "go_mansion"},
			{"choice": "Let's go back", "choice_id": "dontgo_mansion"}
		],
		"required_items": 0
	}
}

var prologue_possible_endings = {
	"leave_mansion": {
		"narration": ["You decided not to go."],
		"gameover_text": "Congratulations, Curiosity didn't kill the cat"
		},
	"dontgo_mansion": {
		"narration": ["The group decided to go back."],
		"gameover_text": "Did fear creep inside your mind?"
		
	}
}

func _ready() -> void:
	scene_data = prologue_data
	possible_endings = prologue_possible_endings
	scene_order = prologue_data.keys()
	current_scene_index = 0
	is_running = true
	hasTitleCard = true
	get_titleCard(set_titleCard)
	get_titleText(set_titleText)
	# Start cutscene
	await start_cinematic()

func get_next_scene() -> PackedScene:
	return next_scene
