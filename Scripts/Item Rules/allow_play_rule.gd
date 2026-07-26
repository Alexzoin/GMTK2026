extends Resource
class_name AllowPlayRule

func check_rule(last_card: Card, new_card: Card) -> bool:
	assert("Must override check_rule() function.")
	return false
