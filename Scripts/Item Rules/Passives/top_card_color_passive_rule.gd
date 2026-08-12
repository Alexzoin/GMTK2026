extends PassiveRule

class_name TopCardColorPassiveRule

@export var target_color: Color = Color.MAGENTA
@export var draw_amount: int = 1

func _init() -> void:
	trigger = TriggerType.ON_DRAW_AND_PLAY

func check_and_execute(context: Dictionary) -> bool:
	var deck: Node = context.get("deck")
	var card_manager: CardManager = context.get("card_manager")
	var item: Item = context.get("item")
	
	if deck and deck.get_child_count() > 0 and card_manager:
		var top_card: Card = deck.get_child(-1) as Card
		if top_card and top_card.color == target_color:
			print("Top card matches target color: ", target_color)
			if item:
				item.rule_was_used()
			card_manager.draw_cards(draw_amount)
			return true
	return false
