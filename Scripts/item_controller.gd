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

var item_manager: ItemManager = null

@onready var content: Node2D = $Content
@onready var name_text: RichTextLabel = $Content/Name
@onready var card_image: Sprite2D = $Content/Image
@onready var description_text: RichTextLabel = $Content/Description
@onready var cost_text: RichTextLabel = $Content/Cost

@export var cost: int = 1
@export var item_name: String
@export var description: String
@export var item_type: item_types

enum item_types { play_allower, consumable, passive }
#play_allower - adds a condition that allows more cards to be played
#consumable - does an effect when clicked on eg. "discard all blue cards in hand", "draw another hand_size of cards", "discard the top card of the deck"
#passive - "Every 3 cards you play, play the top card of the deck", "Wehever you play a blue card, make a random card in your hand blue.", "When you start a new life, remove all A cards from the deck."

@export var play_allow_rules: Array[AllowPlayRule]
@export var passive_rules: Array[PassiveRule]

var scene_resource = null

func process_passive_trigger(event_type: PassiveTrigger.TriggerEvent, context: Dictionary) -> void:
	context["item"] = self
	for rule in passive_rules:
		if rule:
			rule.evaluate_and_execute(event_type, context)

var is_hovered: bool = false
var last_pos: Vector2
var viewport_rect = null

var name_text_start_pos = null
var name_text_hidden_pos = null

var active_tween: Tween = null

var time = 0.0

var is_in_shop: bool = true

var is_dragging: bool = false
var is_draggable: bool:
	get():
		return !is_in_shop
		
var rule_used_count = 0

func check_rules(current_card: Card, new_card: Card) -> bool:
	for rule in play_allow_rules:
		if rule.check_rule(current_card, new_card):
			return true
	
	return false

func rule_was_used():
	SoundManager.play(preload("res://Sounds/MenuSelect.wav"))
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(content, "rotation_degrees", 360.0, 1.5)
	
	var reset_rot = func(): content.rotation_degrees = 0.0
	
	tween.finished.connect(reset_rot)
	
	rule_used_count += 1

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
	
	name_text.text = item_name
	cost_text.text = "$" + str(cost)
	description_text.text = description
	
	description_text.visible = false
	
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
	
	if is_dragging:
		target_pos = get_global_mouse_position() - pivot_offset * scale
		limit_to_screen = true
		
		content.rotation = 0
		
	if limit_to_screen:
		target_pos = (target_pos).clamp(Vector2.ZERO, limit)
		
	global_position = global_position.lerp(target_pos, base_move_speed * delta)

func _on_pressed() -> void:
	# Emitted when the button is pressed and then released. 
	# This is the standard "click" event.
	print("Clicked")
	if item_manager and is_in_shop:
		if item_manager.try_to_purchase(self):
			SoundManager.play(preload("res://Sounds/Spend.wav"))
			is_in_shop = false
			cost_text.visible = false
			description_text.visible = false
		else:
			SoundManager.play(preload("res://Sounds/Tick.wav"))
	pass

func _on_button_down() -> void:
	if is_draggable:
		is_dragging = true
		move_to_front()
	pass

func _on_button_up() -> void:
	# Emitted the moment the mouse button is released, 
	# regardless of whether the mouse is still over the button.
	is_dragging = false
	#is_hovered = false
	pass

func _on_toggled(toggled_on: bool) -> void:
	# Emitted when the button changes state (only if 'toggle_mode' is true).
	pass

# --- Control Signal Functions ---

func _on_mouse_entered() -> void:
	# Emitted when the mouse cursor enters the button's bounding box.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		SoundManager.play(preload("res://Sounds/Snowman Hit.wav"))
		is_hovered = true
		z_index = 1
		description_text.visible = true
		
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
	
	#if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
	if true:
		is_hovered = false
		z_index = 0
		description_text.visible = false
		
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
