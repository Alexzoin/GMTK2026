extends Resource

class_name PassiveTrigger

enum TriggerEvent { ON_ROUND_START, ON_SHUFFLE, ON_DRAW_AND_PLAY, ON_CARD_PLAYED }

@export var event_type: TriggerEvent

func is_triggered(context: Dictionary) -> bool:
	assert("is_triggered must be overridden in child triggers.")
	return false
