extends AllowPlayRule
class_name ColorMatch

@export var last_color: Card.card_colors
@export var new_color: Card.card_colors

func check_rule(last_card: Card, new_card: Card) -> bool:
	if last_card == null or new_card == null:
		return false
	if last_card.card_color == last_color and new_card.card_color == new_color:
		return true
	
	return false
