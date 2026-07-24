extends TextureButton

class_name Item

var dragging_scale: float = 0.7
var hand_scale: float = 0.4
var hover_scale: float = 0.8
var default_scale: float = 0.5
var move_speed: float = 20.0
var squash_stretch_weight: float = 0.1
var hand_midpoint_screen_height: float = 0.9
var hand_hot_zone_screen_height: float = 0.7
var card_spacing_percentage: float = 0.1

@export var content: Node2D
@export var name_text: RichTextLabel
@export var card_image: Sprite2D

@export var cost: int = 1


var is_hovered: bool = false
var last_pos: Vector2
var viewport_rect = null

var name_text_start_pos = null
var name_text_hidden_pos = null

var active_tween: Tween = null

var time = 0.0

func _ready() -> void:
	self.pressed.connect(_on_pressed)
	self.button_down.connect(_on_button_down)
	self.button_up.connect(_on_button_up)
	self.toggled.connect(_on_toggled)
	
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	self.focus_entered.connect(_on_focus_entered)
	self.focus_exited.connect(_on_focus_exited)
	self.gui_input.connect(_on_gui_input)
	self.resized.connect(_on_resized)
	self.minimum_size_changed.connect(_on_minimum_size_changed)
	
	viewport_rect = get_viewport_rect()
	name_text_start_pos = name_text.position
	name_text.position.y = name_text.position.y + 64
	name_text_hidden_pos = name_text.position
	
	#canvas_shader.set_shader_parameter("time_factor", randf() * 5.0)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			pass

func _process(delta: float) -> void:
	time += delta
	var velocity = (global_position - last_pos) / delta
	last_pos = global_position
	
	var base_move_speed = move_speed
	var base_target_scale: float = default_scale
	if is_hovered:
		base_target_scale = hover_scale
	
	var target_scale = Vector2(base_target_scale, base_target_scale)
	
	# Distorts the target scale based on movement velocity
	if velocity.length() > 0.1:
		target_scale.x += abs(velocity.x) * (squash_stretch_weight / 1000.0)
		target_scale.y += abs(velocity.y) * (squash_stretch_weight / 1000.0)
		
	scale = scale.lerp(target_scale, 1.0 - exp(-10 * delta)).clamp(Vector2.ZERO, Vector2.ONE * 10)
	
	var target_pos = global_position
	var limit = viewport_rect.size - size * scale
	var limit_to_screen: bool = false
		
	if limit_to_screen:
		target_pos = (target_pos).clamp(Vector2.ZERO, limit)
		
	global_position = global_position.lerp(target_pos, base_move_speed * delta)

func _on_pressed() -> void:
	# Emitted when the button is pressed and then released. 
	# This is the standard "click" event.
	#$Content/Back.visible = !$Content/Back.visible
	pass

func _on_button_down() -> void:
	pass

func _on_button_up() -> void:
	# Emitted the moment the mouse button is released, 
	# regardless of whether the mouse is still over the button.
	is_hovered = false
	pass

func _on_toggled(toggled_on: bool) -> void:
	# Emitted when the button changes state (only if 'toggle_mode' is true).
	pass

# --- Control Signal Functions ---

func _on_mouse_entered() -> void:
	# Emitted when the mouse cursor enters the button's bounding box.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#print("Letter: " + letter)
		is_hovered = true
		z_index = 1
		
		if active_tween:
			active_tween.kill()
			
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(name_text, "position", name_text_start_pos, 0.5)
		
		active_tween = tween
	pass

func _on_mouse_exited() -> void:
	# Emitted when the mouse cursor leaves the button's bounding box.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_hovered = false
		z_index = 0
		
		if active_tween:
			active_tween.kill()
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(name_text, "position", name_text_hidden_pos, 1.0)
		
		active_tween = tween
	pass

func _on_focus_entered() -> void:
	# Emitted when the button gains keyboard/controller focus.
	pass

func _on_focus_exited() -> void:
	# Emitted when the button loses keyboard/controller focus.
	pass

func _on_resized() -> void:
	# Emitted when the button's size changes.
	pass

func _on_minimum_size_changed() -> void:
	# Emitted when the custom minimum size or content size changes.
	pass
