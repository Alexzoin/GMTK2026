extends Resource

class_name PassiveRule

enum TriggerType { ON_ROUND_START, ON_SHUFFLE, ON_DRAW_AND_PLAY, ON_CARD_PLAYED }

@export var trigger: TriggerType

func check_and_execute(context: Dictionary) -> bool:
	assert("check_and_execute must be overridden in child passive rules.")
	return false
