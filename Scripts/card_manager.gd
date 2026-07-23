extends CanvasLayer

class_name CardManager

@onready var card_scene = preload("uid://cbkulcdb3k8uy")

@export var hand: Node
@export var deck: Node
@export var pile: Node
@export var discard: Node

var colors: Array[Color]

const ALPHABET = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	colors = [Color.MAGENTA, Color.YELLOW, Color.AQUA, Color.ORANGE, Color.PURPLE, Color.GREEN]
	create_deck()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		draw_cards(5)
	pass

func get_top_pile_card() -> Card:
	return pile.get_child(pile.get_child_count() - 1)

func create_deck() -> void:
	for letter in ALPHABET:
		for num in range(10):
			var new_card = card_scene.instantiate()
			new_card.init_card(letter, num, colors.pick_random())
			new_card.set_parent_references(hand, deck, pile, discard)
			deck.add_child(new_card)
			
	var cards = deck.get_children()
	cards.shuffle()
	for i in range(cards.size()):
		deck.move_child(cards[i], i)
			
func draw_cards(num_cards: int):
	if num_cards > deck.get_child_count():
		num_cards = deck.get_child_count()
	
	for i in range(num_cards):
		deck.get_child(-1).draw()
		
