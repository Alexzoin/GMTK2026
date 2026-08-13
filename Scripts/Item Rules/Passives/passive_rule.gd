extends Resource

class_name PassiveRule

enum LogicOperator { AND, OR }

@export var trigger: PassiveTrigger
@export var additional_triggers: Array[PassiveTrigger] = []
@export var trigger_logic: LogicOperator = LogicOperator.AND

@export var effects: Array[PassiveEffect]

func get_all_triggers() -> Array[PassiveTrigger]:
	var result: Array[PassiveTrigger] = []
	if trigger:
		result.append(trigger)
	for t in additional_triggers:
		if t and not result.has(t):
			result.append(t)
	return result

func evaluate_and_execute(event_type: PassiveTrigger.TriggerEvent, context: Dictionary) -> bool:
	var triggers = get_all_triggers()
	if triggers.is_empty():
		return false
		
	var should_execute = false
	
	if trigger_logic == LogicOperator.AND:
		var has_event_match = false
		var all_satisfied = true
		
		for t in triggers:
			if t.event_type == event_type:
				has_event_match = true
			if not t.is_triggered(context):
				all_satisfied = false
				break
				
		should_execute = has_event_match and all_satisfied
		
	elif trigger_logic == LogicOperator.OR:
		for t in triggers:
			if t.event_type == event_type and t.is_triggered(context):
				should_execute = true
				break

	if should_execute:
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
