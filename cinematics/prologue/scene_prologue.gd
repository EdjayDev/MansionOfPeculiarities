extends Base_Cinematic
class_name ScenePrologue

@export var cinematic_playing : PackedScene

# Scene Data
var prologue_data = {
	"titlecard" : {
		"chapter_number" : "Chapter 1",
		"chapter_title" : "Escape"
	},
	"Start": {
		"bg": BG_HOUSE,
		"narration": [
			"Three students decided to explore a mansion hidden deep within the forest...",
			"One was eager to go, while another was strongly against it.",
		    "Despite the disagreement, you chose to join them."
		]
	},
	"Continue": {
		"bg": BG_HOUSE,
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
		"bg": BG_HOUSE,
		"narration": ["After meeting up with the others, they make their journey...", "You see a dog. You decide to..."],
		"choices": [
			{"choice_item": "Greet it", "choice_itemid": "item_unknownKey", "choice_response": ["You got a Key!"]},
			{"choice_item": "Ignore it", "choice_itemid": "item_ignore"}
		],
		"required_items": 1
	},
	"Meetup2": {
		"bg": BG_HOUSE,
		"narration": ["After heading in, you find a crumpled old map..."],
		"choices": [
			{"choice": "Let's go In!", "choice_id": "go_mansion"},
			{"choice": "Let's go back", "choice_id": "dontgo_mansion"}
		],
		"required_items": 0
	}
}

func _ready() -> void:
	cinematic_started.emit()
	await cinematic_blackout()
	change_background(BG_BLUESKY)
	await cinematic_fade_in(1.0)
	await cinematic_narrate(prologue_data["Start"]["narration"])
	
