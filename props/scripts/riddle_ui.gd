extends Control
class_name Riddle_UI

@onready var riddle: RichTextLabel = $riddle_bgtexture/riddle_margin/riddle_text
@onready var riddle_answer_input: LineEdit = $riddle_answer_margin/riddle_answer_input

var riddle_answer_reference : String = ""

signal riddle_answered_correctly(isCorrect : bool)
signal riddle_answered_incorrectly

func _ready() -> void:
	riddle_answer_input.text_submitted.connect(verify_riddle_answer)

func verify_riddle_answer(answer : String)->void:
	var player_answer = answer.strip_edges().to_lower()
	var correct_answer = riddle_answer_reference.strip_edges().to_lower()
	if player_answer == correct_answer:
		riddle_answered_correctly.emit(true)
		visible = false
		riddle_answer_input.text = ""
	else:
		riddle_answered_incorrectly.emit()
		visible = false
		riddle_answer_input.text = ""
