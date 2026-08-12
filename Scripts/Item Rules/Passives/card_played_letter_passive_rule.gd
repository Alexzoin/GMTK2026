extends PassiveRule

class_name CardPlayedLetterPassiveRule

@export var target_letter: String = "D"
@export var draw_amount: int = 1

func _init() -> void:
	trigger = TriggerType.ON_CARD_PLAYED

func check_and_execute(context: Dictionary) -> bool:
	var card: Card = context.get("card")
	var card_manager: CardManager = context.get("card_manager")
	var item: Item = context.get("item")
	
	if card and card_manager:
		if card.letter.to_upper() == target_letter.to_upper():
			print("Played card letter matched target: ", target_letter)
			if item:
				item.rule_was_used()
			card_manager.draw_cards(draw_amount)
			return true
	return false
