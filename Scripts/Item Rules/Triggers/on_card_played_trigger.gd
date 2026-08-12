extends PassiveTrigger

class_name OnCardPlayedTrigger

@export var target_letter: String = ""
@export var target_number: int = -1
@export var target_color: CardEnums.CardColor = CardEnums.CardColor.Pink
@export var use_color: bool = false

func _init() -> void:
	event_type = TriggerEvent.ON_CARD_PLAYED

func is_triggered(context: Dictionary) -> bool:
	var card = context.get("card")
	if not card:
		return false
		
	var letter_match = (target_letter == "" or card.letter.to_upper() == target_letter.to_upper())
	var number_match = (target_number == -1 or card.number == target_number)
	var color_match = (not use_color or card.card_color == target_color)
	
	return letter_match and number_match and color_match
