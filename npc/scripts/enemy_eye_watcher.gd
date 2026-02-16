extends BaseEnemy
class_name Enemy_EyeWatcher

@onready var eyes_timer: Timer = Timer.new()
@onready var global_light: DirectionalLight2D = $global_light
var WARNING_DURATION : float = 0.5
var warning_active = false
var warned = false

@onready var eye_watcher_audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var state_
var canvas_modulate: CanvasModulate
var default_canvas_color: Color

const ENRAGED_TINT := Color(0.996, 0.043, 0.043, 1.0) #pure red default color
const WARNING_DARK_TINT := Color(0.15, 0.15, 0.18) # near-black, cold
const WARNING_TINT := Color(1.0, 0.258, 0.258, 1.0)
const DEFAULT_OPEN_LENGTH := 10.0  # length of "opening_eyes" animation
const DEFAULT_CLOSE_LENGTH := 5.0  # length of "closing_eyes" animation (example)

@onready var eyewatcher_particle_2d: GPUParticles2D = $eyewatcher_particle2d

func _ready() -> void:
	initialize_npc()
	state_ = "normal"
	set_npc_group("enemy")
	add_child(eyes_timer)
	eyes_timer.one_shot = false
	eyewatcher_particle_2d.emitting = false

func set_difficulty_timer() -> void:
	var difficulty = SessionState.get_difficulty()
	match difficulty:
		"easy":
			eyes_timer.wait_time = 20.0
		"medium":
			eyes_timer.wait_time = 10.0
		"hard":
			eyes_timer.wait_time = 5.0
		_:
			eyes_timer.wait_time = 30.0

func eyes_open() -> void:
	eyes_timer.stop()
	print("start_again")
	# Play "opening_eyes" scaled to fit interval
	var open_speed = DEFAULT_OPEN_LENGTH / eyes_timer.wait_time
	await play_custom_animation("opening_eyes", open_speed)
	eye_watcher_audio.play()
	eye_watcher_audio.volume_db = randf_range(-2.0, 3.0)
	eye_watcher_audio.pitch_scale = randf_range(4.0, 10.0)
	state_ = "enraged"
	# Schedule closing right after opening finishes
	await get_tree().create_timer(DEFAULT_CLOSE_LENGTH).timeout
	state_ = "normal"
	eye_watcher_audio.play()
	eye_watcher_audio.volume_db = randf_range(-20.0, -10.0)
	eye_watcher_audio.pitch_scale = randf_range(0.3, 0.9)
	warned = false
	# Play "closing_eyes" at default speed
	await play_custom_animation("closing_eyes", open_speed)
	eyes_timer.start()

func _process(_delta: float) -> void:
	check_eye_watcher()

# =========================
# CORE LOGIC
# =========================
func check_eye_watcher() -> void:
	if canvas_modulate == null:
		return

	if state_ == "enraged":
		apply_enraged_visuals()

		if player_is_moving():
			start_warning()
		else:
			reset_warning()
	else:
		reset_warning()
		clear_enraged_visuals()


# =========================
# PLAYER MOVEMENT CHECK
# =========================
func player_is_moving() -> bool:
	var moving := player_get.velocity != Vector2.ZERO
	return moving

# =========================
# WARNING LOGIC
# =========================
func start_warning() -> void:
	if warning_active:
		return

	warning_active = true
	play_warning_effects()

	if not warned:
		await get_tree().create_timer(WARNING_DURATION).timeout	
	warned = true
	if state_ == "enraged" and player_is_moving():
		game_over()
	else:
		reset_warning()

func reset_warning() -> void:
	if warning_active:
		warning_active = false
		reset_visuals()

# =========================
# EFFECTS
# =========================
func set_canvas(canvas: CanvasModulate) -> void:
	canvas_modulate = canvas
	default_canvas_color = canvas.color
	
	set_difficulty_timer()
	eyes_timer.start()
	eyes_timer.timeout.connect(eyes_open)

func apply_enraged_visuals() -> void:
	if canvas_modulate == null:
		return

	global_light.energy = 0.15
	global_light.color = Color.WHITE
	global_light.visible = true
	canvas_modulate.color = default_canvas_color.lerp(ENRAGED_TINT, 0.35)

	
func clear_enraged_visuals() -> void:

	global_light.visible = false
	canvas_modulate.color = default_canvas_color
	
func play_warning_effects() -> void:
	# Crush brightness instead of adding color
	canvas_modulate.color = default_canvas_color.lerp(
		WARNING_DARK_TINT,
		0.75
	)

	play_custom_animation("eye_focus", 1.0)


func reset_visuals() -> void:
	if state_ == "enraged":
		apply_enraged_visuals()
	else:
		clear_enraged_visuals()

# =========================
# GAME OVER
# =========================
func game_over() -> void:
	print("GAME OVER – YOU MOVED")
	scene_game.set_game_over("Caught You")
