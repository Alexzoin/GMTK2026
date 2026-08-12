extends Resource

class_name PassiveRule

@export var trigger: PassiveTrigger
@export var effects: Array[PassiveEffect]

func evaluate_and_execute(event_type: PassiveTrigger.TriggerEvent, context: Dictionary) -> bool:
	if not trigger:
		return false
		
	if trigger.event_type == event_type and trigger.is_triggered(context):
		var executed_any = false
		for effect in effects:
			if effect:
				effect.execute(context)
				executed_any = true
				
		if executed_any:
			var item = context.get("item")
			if item and item.has_method("rule_was_used"):
				item.rule_was_used()
		return executed_any
		
	return false
