extends CanvasLayer

class_name Tutorial

@export var show_text_at_card_number: Dictionary[int, RichTextLabel]
@export var kill_text: RichTextLabel
@export var win_text: RichTextLabel

var tutorial_text_starting_positions: Dictionary[RichTextLabel, Vector2]

var cards_played: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for text_node in get_children():
		tutorial_text_starting_positions[text_node as RichTextLabel] = text_node.position
		text_node.visible = false
		
	show_text_at_card_number[0].visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_card_played(card: Card, old_card: Card):
	cards_played += 1
	
	for text_node in show_text_at_card_number.values():
		text_node.visible = false
		
	if show_text_at_card_number.has(cards_played):
		show_text_at_card_number[cards_played].visible = true
		
func on_no_remaining_playable_cards(score: int):
	kill_text.visible = true

func on_win_game():
	win_text.visible = true

func hide_all():
	cards_played = 0
	for text_node in get_children():
		text_node.visible = false
