extends CanvasLayer

class_name CardManager

signal game_over(scored_cards: int)
signal game_won
signal card_played_signal(card: Card, old_card: Card)

@onready var card_scene = preload("uid://cbkulcdb3k8uy")

@export var hand: Node
@export var deck: Node
@export var pile: Node
@export var discard: Node

@export var item_manager: ItemManager

@export var hand_size: int = 5

@export var make_visible_when_win: Array[Node]

const ALPHABET = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for color in Card.colors:
		print(color.to_html(false))
	create_deck()
	
	await draw_cards(hand_size)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#draw_cards(hand_size)
	#if Input.is_key_pressed(Key.KEY_R):
		#get_tree().reload_current_scene()
	pass

func get_top_pile_card() -> Card:
	return pile.get_child(pile.get_child_count() - 1)

func create_deck() -> void:
	for letter in ALPHABET:
		for num in range(10):
			var new_card = card_scene.instantiate() as Card
			new_card.init_card(letter, num, Card.colors.pick_random(), item_manager)
			new_card.set_parent_references(hand, deck, pile, discard)
			new_card.card_played.connect(_on_card_played)
			deck.add_child(new_card)
			new_card.global_position = deck.global_position
			new_card.is_basic_card = true
	
			
	shuffle_deck()
			
			
			
func get_last_played_card() -> Card:
	if pile.get_child_count() > 0:
		return pile.get_child(-1) as Card
	else:
		return null
		
		
func draw_cards(num_cards: int):
	if deck.get_child_count() == 0:
		return
		
	if num_cards > deck.get_child_count():
		num_cards = deck.get_child_count()
		if num_cards == 0:
			return
	
	for i in range(num_cards):
		if(deck.get_child_count() > 0):
			deck.get_child(-1).draw()
			SoundManager.play(preload("res://Sounds/Tick.wav"))
			await get_tree().create_timer(0.2).timeout
		else:
			printerr("TRYING TO DRAW CARDS WHEN NONE LEFT")
		
	
	if deck.get_child_count() == 0:
		return
	
	if item_manager:
		item_manager.process_passives(PassiveTrigger.TriggerEvent.ON_DRAW_AND_PLAY, {
			"card_manager": self,
			"deck": deck,
			"hand": hand,
			"pile": pile,
			"discard": discard
		})
		
func _on_card_played(card: Card, old_card: Card):
	card_played_signal.emit(card, old_card)
	print(card.letter + " " + str(card.number))
	if hand.get_child_count() == 0:
		await draw_cards(hand_size)
		
	if item_manager:
		item_manager.process_passives(PassiveTrigger.TriggerEvent.ON_CARD_PLAYED, {
			"card_manager": self,
			"card": card,
			"old_card": old_card,
			"deck": deck,
			"hand": hand,
			"pile": pile,
			"discard": discard
		})
		item_manager.process_passives(PassiveTrigger.TriggerEvent.ON_DRAW_AND_PLAY, {
			"card_manager": self,
			"card": card,
			"old_card": old_card,
			"deck": deck,
			"hand": hand,
			"pile": pile,
			"discard": discard
		})
	
	var has_playable = false
	for hand_card in hand.get_children():
		hand_card = hand_card as Card
		if hand_card.is_playable:
			has_playable = true
			hand_card.set_display_as_playable(true)
		else:
			hand_card.set_display_as_playable(false)
			
	if not has_playable and deck.get_child_count() > 0:
		game_over.emit(pile.get_child_count())
		print("game over")
	elif not has_playable and deck.get_child_count() == 0:
		game_won.emit()
		SoundManager.play(preload("res://Sounds/15Pens.wav"))
		print("you win")
		for n in make_visible_when_win:
			n.visible = true

func shuffle_deck():
	if item_manager:
		item_manager.process_passives(PassiveTrigger.TriggerEvent.ON_SHUFFLE, {
			"card_manager": self,
			"deck": deck,
			"hand": hand,
			"pile": pile,
			"discard": discard
		})
	
	var cards = deck.get_children()
	cards.shuffle()
	
	for i in range(cards.size()):
		deck.move_child(cards[i], i)

func all_cards_in_hand_color(target_color: CardEnums.CardColor) -> bool:
	if hand.get_child_count() == 0:
		return false
	
	for card in hand.get_children():
		var c = card as Card
		if c and c.card_color != target_color:
			return false
	return true

func restack_all_cards():
	for card in hand.get_children():
		card.reparent(deck)
		
	for card in pile.get_children():
		card.reparent(deck)
		
	for card in discard.get_children():
		card.reparent(deck)
		
	for card in deck.get_children():
		card = card as Card
		card._on_mouse_exited()
		card.z_index = 0
		card.set_color(Card.colors.pick_random())
		card.set_display_as_playable(true)
		
		if not card.is_basic_card:
			card.queue_free()
		
	shuffle_deck()

func _die_sequence_start():
	restack_all_cards()
	#Animate points scoring, send hand offscreen one by one, tween deck off screen left.

func _start_new_round():
	if item_manager:
		item_manager.process_passives(PassiveTrigger.TriggerEvent.ON_ROUND_START, {
			"card_manager": self,
			"deck": deck,
			"hand": hand,
			"pile": pile,
			"discard": discard
		})
		
	await draw_cards(hand_size)
