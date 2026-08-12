extends PassiveRule

class_name AllHandColorPassiveRule

@export var target_color: Color = Color.GREEN
@export var draw_amount: int = 1

func _init() -> void:
	trigger = TriggerType.ON_DRAW_AND_PLAY

func check_and_execute(context: Dictionary) -> bool:
	var hand: Node = context.get("hand")
	var card_manager: CardManager = context.get("card_manager")
	var item: Item = context.get("item")
	
	if hand and card_manager and hand.get_child_count() > 0:
		if card_manager.all_cards_in_hand_color(target_color):
			if item:
				item.rule_was_used()
			card_manager.draw_cards(draw_amount)
			return true
	return false
