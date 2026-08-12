extends AllowPlayRule
class_name ColorMatch

@export var last_color: CardEnums.CardColor = CardEnums.CardColor.Pink
@export var new_color: CardEnums.CardColor = CardEnums.CardColor.Pink

func check_rule(last_card, new_card) -> bool:
	if last_card == null or new_card == null:
		return false
	if last_card.card_color == last_color and new_card.card_color == new_color:
		return true
	
	return false
