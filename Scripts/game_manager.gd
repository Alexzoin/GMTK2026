extends Node2D

class_name GameManager

@export var card_manager: CardManager
@export var item_manager: ItemManager
@export var ui: UI
@export var tutorial: Tutorial

func _ready() -> void:
	if card_manager:
		card_manager.game_over.connect(_on_game_over)
		card_manager.game_won.connect(_on_game_won)
		card_manager.card_played_signal.connect(_on_card_played)
	
	if ui:
		ui.die_sequence_start.connect(_on_die_sequence_start)
		ui.start_again.connect(_on_start_again)

func _on_card_played(card: Card, old_card: Card) -> void:
	if tutorial:
		tutorial.on_card_played(card, old_card)
	if item_manager:
		item_manager.on_card_played(card, old_card)

func _on_game_over(score: int) -> void:
	if tutorial:
		tutorial.on_no_remaining_playable_cards(score)
	if ui:
		ui.on_game_over(score)

func _on_game_won() -> void:
	if ui:
		ui.on_game_won()
	if tutorial:
		tutorial.on_win_game()

func _on_die_sequence_start() -> void:
	if tutorial:
		tutorial.hide_all()
	if card_manager:
		card_manager.die_sequence_start()
	if item_manager:
		item_manager.go_to_shop()

func _on_start_again() -> void:
	if item_manager:
		item_manager.hide_shop()
	if card_manager:
		card_manager.start_new_round()
