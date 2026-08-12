extends TextureButton

class_name Card

signal card_played(card_controller, old_card_controller)

@export var dragging_scale: float = 0.7
@export var hand_scale: float = 0.4
@export var hover_scale: float = 0.8
@export var default_scale: float = 0.5
@export var move_speed: float = 20.0
@export var squash_stretch_weight: float = 0.1
@export var hand_midpoint_screen_height: float = 0.9
@export var hand_hot_zone_screen_height: float = 0.7
@export var card_spacing_percentage: float = 0.1
@export var content: Node2D
@export var letter_text: RichTextLabel
@export var number_text: RichTextLabel
@export var score_text: RichTextLabel
@export var card_image: Sprite2D

#@onready var canvas_shader: ShaderMaterial = content.material as ShaderMaterial
@onready var bg_shader: ShaderMaterial = $Content/Background.material as ShaderMaterial

var item_manager = null

var is_basic_card: bool

var card_value: int:
	get():
		return CardManager.ALPHABET.find(self.letter) * 10 + self.number

var is_playable: int:
	get():
		if not pile_parent:
			return false
		if pile_parent.get_child_count() == 0:
			return true
		else:
			var last_card: Card = pile_parent.get_child(-1)
			if card_value < last_card.card_value:
				return true
			elif letter == "?":
				return true
			elif last_card.letter == "?":
				return true
			else:
				if item_manager.evaluate_play(last_card, self):
					return true
			return false

var is_dragging: bool = false
var in_hand: bool:
	get():
		return get_parent() == hand_parent
var in_deck: bool:
	get():
		return get_parent() == deck_parent
var in_pile: bool:
	get():
		return get_parent() == pile_parent
var in_discard: bool:
	get():
		return get_parent() == discard_parent
var is_draggable: bool = true
var is_hovered: bool = false
var last_pos: Vector2
var viewport_rect = null

var hand_parent = null
var deck_parent = null
var pile_parent = null
var discard_parent = null

var score_text_start_pos = null
var score_text_hidden_pos = null

var active_tween: Tween = null

var letter: String = ""
var number: int = -1
var color: Color
var card_color: CardEnums.CardColor

const colors: Array[Color] = CardEnums.COLOR_MAP
enum card_colors { Pink, Yellow, Blue, Orange, Purple, Green }

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
	if letter == "?":
		score_text.text = "???"
	else:
		score_text.text = str(card_value)
	score_text_start_pos = score_text.position
	score_text.position.y = score_text.position.y + 64
	score_text_hidden_pos = score_text.position
	
	#canvas_shader.set_shader_parameter("time_factor", randf() * 5.0)

func init_card(new_letter: String, num: int, new_color: Color, new_item_manager) -> void:
	if new_item_manager == null:
		assert("Item manager reference required.")
	else:
		item_manager = new_item_manager
	if new_letter == "":
		push_error("NO LETTER")
	else:
		self.letter = new_letter
		letter_text.text = new_letter
		
	if num < 0:
		self.number = randi_range(0, 9)
		number_text.text = str(self.number)
	else:
		self.number = num
		number_text.text = str(num)
	
	letter_text.rotation_degrees = randf_range(-20, 20)
	number_text.rotation_degrees = randf_range(-20, 20)
	
	letter_text.position.y += randf_range(-5, 5)
	letter_text.position.x += randf_range(-5, 5)
	
	number_text.position.y += randf_range(-5, 5)
	number_text.position.x += randf_range(-5, 5)
	
	set_color(new_color)
	
func set_color(new_color: Color) -> void:
	self.card_color = colors.find(new_color) as CardEnums.CardColor
	self.color = new_color
	letter_text.self_modulate = self.color
	number_text.self_modulate = self.color
	for node in content.get_children():
		if node is Sprite2D:
			node.self_modulate = self.color
			
			if node.material:
				(node.material as ShaderMaterial).set_shader_parameter("stripe_color", self.color)

func set_parent_references(hand_parent, deck_parent, pile_parent, discard_parent) -> void:
	self.hand_parent = hand_parent
	self.deck_parent = deck_parent
	self.pile_parent = pile_parent
	self.discard_parent = discard_parent

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			#in_hand = !in_hand
			#if get_parent() != hand_parent:
				#get_parent().remove_child(self)
				#
				#hand_parent.add_child(self)
				#in_hand = true
				#content.rotation = 0
			pass

func _process(delta: float) -> void:
	time += delta
	var velocity = (global_position - last_pos) / delta
	last_pos = global_position
	
	var base_move_speed = move_speed
	var base_target_scale: float = default_scale
	if is_dragging:
		base_target_scale = dragging_scale
	elif is_hovered:
		base_target_scale = hover_scale
	elif in_hand:
		base_target_scale = hand_scale
	elif in_pile:
		base_target_scale = hover_scale
	elif in_deck:
		base_move_speed = move_speed / 10.0
	elif in_discard:
		base_target_scale = 0.3
	
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
		
		if is_in_hot_zone() and in_hand:
			content.rotation = sin(time * 50.0) / 20.0
		else:
			content.rotation = 0
			
	elif in_hand:
		var space_per_card = size.x * hand_scale
		space_per_card += space_per_card * card_spacing_percentage
		var center_point = viewport_rect.size.x / 2.0
		var total_hand_space = space_per_card * get_parent().get_child_count()
		total_hand_space -= space_per_card * card_spacing_percentage
		
		#Compress cards in hand if hand is too large for the screen.
		var margin = 128
		if total_hand_space > viewport_rect.size.x - margin:
			total_hand_space = viewport_rect.size.x - margin
			space_per_card = (viewport_rect.size.x - margin) / get_parent().get_child_count()
		
		var starting_x = center_point - (total_hand_space / 2.0) + (space_per_card / 2.0)
		var x = starting_x + space_per_card * get_index()
		
		target_pos = Vector2(x, viewport_rect.size.y * hand_midpoint_screen_height)
		target_pos = target_pos - pivot_offset * scale
		
		limit_to_screen = is_hovered
		
		#if not is_playable:
			#canvas_shader.set_shader_parameter("wave_strength", 0.0)
			#canvas_shader.set_shader_parameter("swirl_strength", 0.1)
		#else:
			#canvas_shader.set_shader_parameter("wave_strength", 0)
			#canvas_shader.set_shader_parameter("swirl_strength", 0)
	elif in_deck:
		var num = deck_parent.get_child_count() - get_index()
		target_pos = Vector2(num * 10.0, sin(num) * 10.0) + deck_parent.global_position
		target_pos = target_pos - pivot_offset * scale
	elif in_pile:
		target_pos = pile_parent.global_position + Vector2.RIGHT * get_index() * 10.0
		target_pos = target_pos - pivot_offset * scale
		
		if pile_parent.get_child(-1) == self:
			score_text.position = score_text.position.lerp(score_text_start_pos, base_move_speed * delta)
		else:
			score_text.position = score_text.position.lerp(score_text_hidden_pos, base_move_speed * delta)
	elif in_discard:
		target_pos = discard_parent.global_position + Vector2.DOWN * get_index() * 10.0
		target_pos = target_pos - pivot_offset * scale
			
	if not in_hand:
		is_hovered = false
		
	if limit_to_screen:
		target_pos = (target_pos).clamp(Vector2.ZERO, limit)
		
	global_position = global_position.lerp(target_pos, base_move_speed * delta)

func play_card():
	if not is_playable:
		SoundManager.play(preload("res://Sounds/Tick.wav"))
		print("Card cannot be played.")
		return
	SoundManager.play(preload("res://Sounds/ButtonClick.wav"))
	var old_card: Card = null
	if pile_parent.get_child_count() > 0:
		old_card = pile_parent.get_child(-1) as Card
		
	reparent(pile_parent)
	z_index = 0
	scale = scale / 2.0
	card_played.emit(self, old_card)
	
	if active_tween:
		active_tween.kill()
		active_tween = null
	
	#var tween = create_tween()
	#tween.tween_property(self, "rotation_degrees", randi_range(-10, 10), 0.3)

func draw():
	reparent(hand_parent)
	set_display_as_playable(is_playable)

func set_display_as_playable(val: bool):
	if val:
		bg_shader.set_shader_parameter("stripe_thickness", 0.08)
	else:
		bg_shader.set_shader_parameter("stripe_thickness", 0.0)

func is_in_hot_zone():
	return global_position.y + pivot_offset.y < viewport_rect.size.y * hand_hot_zone_screen_height

func _on_pressed() -> void:
	# Emitted when the button is pressed and then released. 
	# This is the standard "click" event.
	#$Content/Back.visible = !$Content/Back.visible
	pass

func _on_button_down() -> void:
	# Emitted the moment the mouse button is pressed down on the button.
	if in_hand:
		is_dragging = true
		move_to_front()
	pass

func _on_button_up() -> void:
	# Emitted the moment the mouse button is released, 
	# regardless of whether the mouse is still over the button.
	is_dragging = false
	is_hovered = false
	if in_hand and is_in_hot_zone():
		play_card()
		content.rotation = 0
	pass

func _on_toggled(toggled_on: bool) -> void:
	# Emitted when the button changes state (only if 'toggle_mode' is true).
	pass

# --- Control Signal Functions ---

func _on_mouse_entered() -> void:
	# Emitted when the mouse cursor enters the button's bounding box.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_dragging:
		if in_hand:
			SoundManager.play(preload("res://Sounds/Appear.mp3"))
			if letter == "?":
				score_text.text = "???"
			else:
				score_text.text = str(card_value)
			#print("Letter: " + letter)
			is_hovered = true
			z_index = 1
			
			if active_tween:
				active_tween.kill()
				
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(score_text, "position", score_text_start_pos, 0.5)
			
			active_tween = tween
			#play_card()
		elif in_deck:
			if get_index() == deck_parent.get_child_count() - 1:
				score_text.text = str(deck_parent.get_child_count())
				
				if active_tween:
					active_tween.kill()
				
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_ELASTIC)
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(score_text, "position", score_text_start_pos, 0.5)
				
				active_tween = tween
	pass

func _on_mouse_exited() -> void:
	# Emitted when the mouse cursor leaves the button's bounding box.
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_dragging:
		if in_hand or in_deck:
			is_hovered = false
			z_index = 0
			
			if active_tween:
				active_tween.kill()
			
			var tween = create_tween()
			tween.set_trans(Tween.TRANS_ELASTIC)
			tween.tween_property(score_text, "position", score_text_hidden_pos, 1.0)
			
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
