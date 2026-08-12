extends PassiveTrigger

class_name OnRoundStartTrigger

func _init() -> void:
	event_type = TriggerEvent.ON_ROUND_START

func is_triggered(_context: Dictionary) -> bool:
	return true
