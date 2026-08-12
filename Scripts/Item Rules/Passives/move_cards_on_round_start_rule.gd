extends PassiveRule

class_name MoveCardsOnRoundStartRule

@export var criteria_letter: String = ""
@export var criteria_number: int = -1
@export var criteria_color: Card.card_colors
@export var use_color: bool = false
@export_enum("hand", "deck", "pile", "discard") var destination: int = 0

func _init() -> void:
	trigger = TriggerType.ON_ROUND_START

func check_and_execute(context: Dictionary) -> bool:
	var deck: Node = context.get("deck")
	var card_manager: CardManager = context.get("card_manager")
	var item: Item = context.get("item")
	
	if not deck or not card_manager:
		return false
		
	var dest_node: Node = null
	if destination == 0:
		dest_node = card_manager.hand
	elif destination == 1:
		dest_node = card_manager.deck
	elif destination == 2:
		dest_node = card_manager.pile
	elif destination == 3:
		dest_node = card_manager.discard

	if not dest_node:
		return false

	var moved_any = false
	for card in deck.get_children():
		var c = card as Card
		if not c:
			continue
		var matches_letter = (criteria_letter != "" and c.letter == criteria_letter)
		var matches_number = (criteria_number != -1 and c.number == criteria_number)
		var matches_color = (use_color and c.card_color == criteria_color)
		
		if matches_letter or matches_number or matches_color:
			c.reparent(dest_node)
			moved_any = true
			print("Moved card ", c.letter, c.number, " to ", dest_node.name)

	if moved_any and item:
		item.rule_was_used()

	return moved_any
