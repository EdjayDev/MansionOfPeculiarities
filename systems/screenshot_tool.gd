extends Node
class_name ScreenshotTool

## The file path template for each screenshot.
@export var screenshot_path_template: String = "screenshot {year}-{month}-{day} {hour}-{minute}-{second}.png"
## The key to press to take each screenshot.
@export var screenshot_key: String = "1"
## Whether to resize the window to [code]screenshot_resize_resolution[/code] before taking each screenshot.
@export var screenshot_resize: bool = true
## The resolution in pixels for each screenshot.
@export var screenshot_resize_resolution: Vector2i = Vector2i(3840, 2160)
## Whether to save each screenshot using lossy compression.
@export var screenshot_lossy: bool = false
## The quality to save each screenshot if using lossy compression.
@export_range(0.0, 1.0) var screenshot_lossy_quality: float = 0.75
## Whether the screenshot tool should run outside the editor.
@export var run_in_export: bool = false

func _input(event: InputEvent) -> void:
	if !run_in_export and !OS.has_feature("editor"):
		return
	
	if event is InputEventKey:
		if event.pressed and event.as_text() == screenshot_key:
			take_screenshot()

func take_screenshot() -> void:
	var original_window_size: Vector2i = get_window().size
	if screenshot_resize:
		get_window().size = screenshot_resize_resolution
	
	await RenderingServer.frame_post_draw
	var screenshot: Image = get_viewport().get_texture().get_image()
	var screenshot_datetime: Dictionary = Time.get_datetime_dict_from_system()
	
	get_window().size = original_window_size
	
	var screenshot_path: String = screenshot_path_template.format(screenshot_datetime)
	
	match screenshot_path.get_extension():
		"webp": screenshot.save_webp(screenshot_path, screenshot_lossy, screenshot_lossy_quality)
		"png": screenshot.save_png(screenshot_path)
		"jpg", "jpeg": screenshot.save_jpg(screenshot_path, screenshot_lossy_quality)
		"dds": screenshot.save_dds(screenshot_path)
		"exr": screenshot.save_exr(screenshot_path)
		_: push_error("Invalid extension for screenshot."); return
