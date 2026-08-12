extends AllowPlayRule

class_name LetterMatch

@export var last_letter: String
@export var new_letter: String

@export var last_letter_any: bool = false
@export var new_letter_any: bool = false

func check_rule(last_card, new_card) -> bool:
	if last_card == null or new_card == null:
		return false
		
	if last_letter_any and new_letter.to_upper().strip_edges() == new_card.letter:
		return true
	elif new_letter_any and last_letter.to_upper().strip_edges() == last_card.letter:
		return true
	elif last_letter_any and new_letter_any:
		return true
		
	return last_card.letter == last_letter.to_upper().strip_edges() and new_card.letter == new_letter.to_upper().strip_edges()
