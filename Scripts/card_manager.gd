extends CanvasLayer

class_name CardManager

signal game_over(scored_cards: int)

@onready var card_scene = preload("uid://cbkulcdb3k8uy")

@export var hand: Node
@export var deck: Node
@export var pile: Node
@export var discard: Node

@export var tutorial: Tutorial
@export var ui: UI

@export var hand_size: int = 5

var colors: Array[Color] = [Color.MAGENTA, Color.YELLOW, Color.AQUA, Color.ORANGE, Color.PURPLE, Color.GREEN]

const ALPHABET = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for color in colors:
		print(color.to_html(false))
	create_deck()
	game_over.connect(tutorial._on_no_remaining_playable_cards)
	game_over.connect(ui._on_game_over)
	ui.die_sequence_start.connect(tutorial.hide_all)
	ui.die_sequence_start.connect(_die_sequence_start)
	ui.start_again.connect(_start_new_round)
	
	draw_cards(hand_size)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#draw_cards(hand_size)
	pass

func get_top_pile_card() -> Card:
	return pile.get_child(pile.get_child_count() - 1)

func create_deck() -> void:
	for letter in ALPHABET:
		for num in range(10):
			var new_card = card_scene.instantiate()
			new_card.init_card(letter, num, colors.pick_random())
			new_card.set_parent_references(hand, deck, pile, discard)
			(new_card as Card).card_played.connect(_on_card_played)
			(new_card as Card).card_played.connect(tutorial._on_card_played)
			deck.add_child(new_card)
			new_card.global_position = deck.global_position
			
	shuffle_deck()
			
func draw_cards(num_cards: int):
	if num_cards > deck.get_child_count():
		num_cards = deck.get_child_count()
	
	for i in range(num_cards):
		deck.get_child(-1).draw()
		
func _on_card_played(card: Card):
	print(card.letter + " " + str(card.number))
	if hand.get_child_count() == 0:
		draw_cards(hand_size)
	
	var has_playable = false
	for hand_card in hand.get_children():
		hand_card = hand_card as Card
		if hand_card.is_playable:
			has_playable = true
			
	if not has_playable:
		game_over.emit(pile.get_child_count())
		print("game over")

func shuffle_deck():
	var cards = deck.get_children()
	cards.shuffle()
	
	for i in range(cards.size()):
		deck.move_child(cards[i], i)

func restack_all_cards():
	for card in hand.get_children():
		card.reparent(deck)
		
	for card in pile.get_children():
		card.reparent(deck)
		
	for card in discard.get_children():
		card.reparent(deck)
		
	for card in deck.get_children():
		card.set_color(colors.pick_random())
		
	shuffle_deck()

func _die_sequence_start():
	restack_all_cards()
	#Animate points scoring, send hand offscreen one by one, tween deck off screen left.

func _start_new_round():
	draw_cards(hand_size)
