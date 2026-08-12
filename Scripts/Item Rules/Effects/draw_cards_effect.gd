extends PassiveEffect

class_name DrawCardsEffect

@export var draw_amount: int = 1

func execute(context: Dictionary) -> void:
	var card_manager = context.get("card_manager")
	if card_manager:
		card_manager.draw_cards(draw_amount)
