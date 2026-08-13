extends AllowPlayRule
class_name NumberMatchRule

@export var last_number: int
@export var new_number: int

@export var last_number_any: bool = false
@export var new_number_any: bool = false

func check_rule(last_card, new_card) -> bool:
	if last_card == null or new_card == null:
		return false
		
	if last_number == last_card.number and new_number == new_card.number:
		return true
	return false
