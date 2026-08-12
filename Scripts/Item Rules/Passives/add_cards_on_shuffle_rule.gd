extends PassiveRule

class_name AddCardsOnShuffleRule

@export var criteria_letter: String = ""
@export var criteria_number: int = -1
@export var criteria_color: Card.card_colors
@export var use_color: bool = false

func _init() -> void:
	trigger = TriggerType.ON_SHUFFLE

func check_and_execute(context: Dictionary) -> bool:
	var card_manager: CardManager = context.get("card_manager")
	var item: Item = context.get("item")
	
	if not card_manager:
		return false
		
	for num in range(10):
		var new_card = card_manager.card_scene.instantiate() as Card
		var color = Card.colors.pick_random()
		var letter = criteria_letter

		if letter == "" or letter == null:
			letter = CardManager.ALPHABET.pick_random()
			
		if use_color:
			color = Card.colors[criteria_color]
			
		var num_to_add = num
		if criteria_number != -1:
			num_to_add = criteria_number
			
		new_card.init_card(letter, num_to_add, color, card_manager.item_manager)
		new_card.set_parent_references(card_manager.hand, card_manager.deck, card_manager.pile, card_manager.discard)
		new_card.card_played.connect(card_manager._on_card_played)
		card_manager.deck.add_child(new_card)
		new_card.global_position = card_manager.deck.global_position
		new_card.is_basic_card = false

	if item:
		item.rule_was_used()

	return true
