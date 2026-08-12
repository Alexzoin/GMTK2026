extends PassiveTrigger

class_name AllHandColorTrigger

@export var target_color: CardEnums.CardColor = CardEnums.CardColor.Green

func _init() -> void:
	event_type = TriggerEvent.ON_DRAW_AND_PLAY

func is_triggered(context: Dictionary) -> bool:
	var hand: Node = context.get("hand")
	var card_manager = context.get("card_manager")
	
	if hand and card_manager and hand.get_child_count() > 0:
		return card_manager.all_cards_in_hand_color(target_color)
	return false
