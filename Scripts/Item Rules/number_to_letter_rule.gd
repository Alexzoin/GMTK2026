extends AllowPlayRule
class_name NumberToLetter

@export var last_number: int = -1
@export var new_number: int = -1

@export var last_letter: String
@export var new_letter: String

func check_rule(last_card: Card, new_card: Card) -> bool:
	if last_card == null or new_card == null:
		return false
		
	if last_number == -1 and new_number == -1:
		assert("At least 1 number must be set.")
	
	if last_number != -1:
		if last_number == last_card.number and new_letter == new_card.letter:
			return true
			
	if new_number != -1:
		if new_number == new_card.number and last_letter == last_card.letter:
			return true
	return false
