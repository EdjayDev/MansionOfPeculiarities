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
		"bg": BG_BLUESKY, # Swapped to match your original _ready setup
		"narration": [
			"Three students decided to explore a mansion hidden deep within the forest...",
			"One was eager to go, while another was strongly against it.",
			"Despite the disagreement, you chose to join them."
		],
		"next_key": "Continue" # Added pointers to chain keys dynamically
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
		"required_items": 2,
		"next_key": "Meetup"
	},
	"Meetup": {
		"bg": BG_HOUSE,
		"narration": ["After meeting up with the others, they make their journey...", "You see a dog. You decide to..."],
		"choices": [
			{"choice_item": "Greet it", "choice_itemid": "item_unknownKey", "choice_response": ["You got a Key!"]},
			{"choice_item": "Ignore it", "choice_itemid": "item_ignore"}
		],
		"required_items": 1,
		"next_key": "Meetup2"
	},
	"Meetup2": {
		"bg": BG_HOUSE,
		"narration": ["After heading in, you find a crumpled old map..."],
		"choices": [
			{"choice": "Let's go In!", "choice_id": "go_mansion"},
			{"choice": "Let's go back", "choice_id": "dontgo_mansion"}
		],
		"required_items": 0,
		"next_key": "" # Empty means end of cinematic sequence
	}
}

# The Main entry point called by Game.gd
func start_sequence() -> void:
	cinematic_started.emit()
	await cinematic_blackout()
	
	# Show title card if available
	var title = prologue_data["titlecard"]
	await cinematic_show_title(title["chapter_number"], title["chapter_title"], 1.0)
	
	# Start our processing loop beginning with the "Start" node
	await run_cinematic_node("Start")

# Processes a single block data step dynamically
func run_cinematic_node(node_key: String) -> void:
	if node_key == "" or not prologue_data.has(node_key):
		# No more steps left, wrap up the scene
		await cinematic_fade_out(1.0)
		cinematic_finished.emit(cinematic_playing) 
		return

	var current_step = prologue_data[node_key]
	
	# Update visual background state
	if current_step.has("bg") and current_step["bg"] != null:
		change_background(current_step["bg"])
		await cinematic_fade_in(0.5)

	# Handle Narration sequences
	if current_step.has("narration"):
		await cinematic_narrate(current_step["narration"])

	# Handle Choice interfaces if choices exist
	if current_step.has("choices") and current_step["choices"].size() > 0:
		# Replace this placeholder line with your actual choices UI system logic:
		# await Game.manager.your_choice_ui.display_choices(current_step["choices"], current_step["required_items"])
		pass

	# Advance loop recursively onto the next structural block setup
	var next = current_step.get("next_key", "")
	await run_cinematic_node(next)
