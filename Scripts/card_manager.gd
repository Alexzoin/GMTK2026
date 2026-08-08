extends CanvasLayer

class_name CardManager

signal game_over(scored_cards: int)
signal game_won

@onready var card_scene = preload("uid://cbkulcdb3k8uy")

@export var hand: Node
@export var deck: Node
@export var pile: Node
@export var discard: Node

@export var tutorial: Tutorial
@export var ui: UI
@export var item_manager: ItemManager

@export var hand_size: int = 5

@export var make_visible_when_win: Array[Node]

const ALPHABET = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for color in Card.colors:
		print(color.to_html(false))
	create_deck()
	game_over.connect(tutorial._on_no_remaining_playable_cards)
	game_over.connect(ui._on_game_over)
	ui.die_sequence_start.connect(tutorial.hide_all)
	ui.die_sequence_start.connect(_die_sequence_start)
	ui.start_again.connect(_start_new_round)
	ui.die_sequence_start.connect(item_manager.go_to_shop)
	ui.start_again.connect(item_manager.hide_shop)
	game_won.connect(ui._on_game_won)
	game_won.connect(tutorial._on_win_game)
	
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
			new_card.card_played.connect(tutorial._on_card_played)
			new_card.card_played.connect(item_manager._on_card_played)
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
	
	for item in item_manager.owned_items:
		if item.item_type == Item.item_types.passive and item.passive_trigger == Item.passive_trigger_types.on_draw_and_play:
			if item.condition == Item.conditions.top_card_is_pink and (deck.get_child(-1) as Card).color == Color.MAGENTA:
				print("top card is pink")
				if item.passive_effect_type == Item.passive_effect_types.draw_a_card:
					await draw_cards(1)
					item.rule_was_used()
			elif item.condition == Item.conditions.all_hand_green and all_cards_in_hand_color(Color.GREEN):
				if item.passive_effect_type == Item.passive_effect_types.draw_a_card:
					await draw_cards(1)
					item.rule_was_used()
		
func _on_card_played(card: Card, old_card: Card):
	print(card.letter + " " + str(card.number))
	if hand.get_child_count() == 0:
		await draw_cards(hand_size)
		
	for item in item_manager.owned_items:
		print(item.item_name)
		if item.item_type == Item.item_types.passive and (item.passive_trigger == Item.passive_trigger_types.on_draw_and_play or item.passive_trigger == Item.passive_trigger_types.on_card_played):
			print("Triggered")
			if item.condition == Item.conditions.top_card_is_pink and deck.get_child_count() > 0 and (deck.get_child(-1) as Card).color == Color.MAGENTA:
				print("top card is pink")
				if item.passive_effect_type == Item.passive_effect_types.draw_a_card:
					await draw_cards(1)
					item.rule_was_used()
			elif item.condition == Item.conditions.all_hand_green and all_cards_in_hand_color(Color.GREEN):
				if item.passive_effect_type == Item.passive_effect_types.draw_a_card:
					await draw_cards(1)
					item.rule_was_used()
			elif item.condition == Item.conditions.card_played_was_d and card.letter == "D":
				print("D played")
				if item.passive_effect_type == Item.passive_effect_types.draw_a_card:
					await draw_cards(1)
					item.rule_was_used()
	
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
	for item in item_manager.owned_items:
		if item.item_type == Item.item_types.passive and item.passive_trigger == Item.passive_trigger_types.on_shuffle:
			for num in range(10):
				var new_card = card_scene.instantiate()
				var color = Card.colors.pick_random()
				var letter = item.effected_card_criteria_letter
			
				if letter == "" or letter == null:
					letter = ALPHABET.pick_random()
					
				if item.use_color:
					color = Card.colors[item.effected_card_criteria_color]
					
				var num_to_add = num
				if item.effected_card_criteria_number != -1:
					num_to_add = item.effected_card_criteria_number
					
				new_card.init_card(letter, num_to_add, color, item_manager)
				new_card.set_parent_references(hand, deck, pile, discard)
				(new_card as Card).card_played.connect(_on_card_played)
				(new_card as Card).card_played.connect(tutorial._on_card_played)
				(new_card as Card).card_played.connect(item_manager._on_card_played)
				deck.add_child(new_card)
				new_card.global_position = deck.global_position
				print(new_card.color)
				print(new_card.number)
				new_card.is_basic_card = false
	
	var cards = deck.get_children()
	cards.shuffle()
	
	for i in range(cards.size()):
		deck.move_child(cards[i], i)

func all_cards_in_hand_color(color: Color):
	if hand.get_child_count() == 0:
		return false
	
	var all_match = true
	for card in hand.get_children():
		card = card as Card
		if card.color != color:
			all_match = false
	return all_match

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
	for item in item_manager.owned_items:
		if item.item_type == Item.item_types.passive and item.passive_trigger == Item.passive_trigger_types.on_round_start:
			for card in deck.get_children():
				card = card as Card
				if card.letter == item.effected_card_criteria_letter or card.number == item.effected_card_criteria_number or (card.card_color == item.effected_card_criteria_color and item.use_color):
					if item.passive_effect_type == Item.passive_effect_types.move_card:
						var destination: Node = null
						var dest_int: int = item.move_card_destination
						
						if dest_int == 0:
							destination = hand
						elif dest_int == 1:
							destination = deck
						elif dest_int == 2:
							destination = pile
						elif  dest_int == 3:
							destination = discard
						
						print("Card moved to " + destination.name)
						card.reparent(destination)
						
		
	await draw_cards(hand_size)
