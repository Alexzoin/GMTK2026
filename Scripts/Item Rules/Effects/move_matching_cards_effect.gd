extends PassiveEffect

class_name MoveMatchingCardsEffect

@export var criteria_letter: String = ""
@export var criteria_number: int = -1
@export var criteria_color: CardEnums.CardColor = CardEnums.CardColor.Pink
@export var use_color: bool = false
@export_enum("hand", "deck", "pile", "discard") var destination: int = 3 # Default discard

func execute(context: Dictionary) -> void:
	var card_manager = context.get("card_manager")
	var deck: Node = context.get("deck")
	if not card_manager or not deck:
		return
		
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
		return

	for card in deck.get_children():
		var c = card
		if not c:
			continue
		var matches_letter = (criteria_letter != "" and c.letter == criteria_letter)
		var matches_number = (criteria_number != -1 and c.number == criteria_number)
		var matches_color = (use_color and c.card_color == criteria_color)
		
		if matches_letter or matches_number or matches_color:
			c.reparent(dest_node)
			print("MoveMatchingCardsEffect: Moved card ", c.letter, c.number, " to ", dest_node.name)
