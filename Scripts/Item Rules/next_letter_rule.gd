extends AllowPlayRule

class_name NextLetter

func check_rule(last_card, new_card) -> bool:
	if last_card == null or new_card == null:
		return false
		
	if not CardManager.ALPHABET.has(last_card.letter) or not CardManager.ALPHABET.has(new_card.letter):
		return false 
		
	var last_card_letter_index = CardManager.ALPHABET.find(last_card.letter)
	var new_card_letter_index = CardManager.ALPHABET.find(new_card.letter)
	
	if new_card_letter_index == last_card_letter_index + 1:
		return true
	
	return false
