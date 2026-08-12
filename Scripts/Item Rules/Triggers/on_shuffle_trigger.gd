extends PassiveTrigger

class_name OnShuffleTrigger

func _init() -> void:
	event_type = TriggerEvent.ON_SHUFFLE

func is_triggered(_context: Dictionary) -> bool:
	return true
