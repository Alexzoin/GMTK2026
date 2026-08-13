extends PassiveEffect

class_name AddCardsToDeckEffect

@export var count: int = 10
@export var criteria_letter: String = ""
@export var criteria_number: int = -1
@export var criteria_color: CardEnums.CardColor = CardEnums.CardColor.Pink
@export var use_color: bool = false

func execute(context: Dictionary) -> void:
	var card_manager = context.get("card_manager")
	if not card_manager:
		return
		
	for i in range(count):
		var new_card = card_manager.card_scene.instantiate()
		var color = CardEnums.COLOR_MAP.pick_random()
		var letter = criteria_letter

		if letter == "" or letter == null:
			letter = CardManager.ALPHABET.pick_random()
			
		if use_color:
			color = CardEnums.get_color(criteria_color)
			
		var num_to_add = i % 10
		if criteria_number != -1:
			num_to_add = criteria_number
			
		new_card.init_card(letter, num_to_add, color, card_manager.item_manager)
		new_card.set_parent_references(card_manager.hand, card_manager.deck, card_manager.pile, card_manager.discard)
		new_card.card_played.connect(card_manager.on_card_played)
		card_manager.deck.add_child(new_card)
		new_card.global_position = card_manager.deck.global_position
		new_card.is_basic_card = false
