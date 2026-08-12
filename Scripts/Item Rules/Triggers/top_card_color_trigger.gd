extends PassiveTrigger

class_name TopCardColorTrigger

@export var target_color: CardEnums.CardColor = CardEnums.CardColor.Pink

func _init() -> void:
	event_type = TriggerEvent.ON_DRAW_AND_PLAY

func is_triggered(context: Dictionary) -> bool:
	var deck: Node = context.get("deck")
	if deck and deck.get_child_count() > 0:
		var top_card = deck.get_child(-1)
		if top_card and top_card.card_color == target_color:
			return true
	return false
