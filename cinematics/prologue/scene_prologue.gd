extends Base_Cinematic
class_name ScenePrologue

@export var cinematic_playing : PackedScene

# Preload backgrounds
var prologue_scenebg_1 = preload("uid://iykv6oy5b0tn")
var prologue_scenebg_2 = preload("uid://5vmfd0kdvg0y")
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
			{"choice_item": "Greet it", "choice_itemid": "item_unknownKey", "choice_response": ["You got a Key!"]},
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
	cinematic_started.emit()
	await cinematic_blackout()
	change_background(prologue_scenebg_1)
	cinematic_show_title(1.0)
	await cinematic_fade_in(1.0)
	await cinematic_narrate(prologue_data["Start"]["narration"])
	
	
	
	
	

	
