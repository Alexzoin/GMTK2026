extends CanvasLayer

class_name UI

signal die_sequence_start
signal start_again

var last_round_score: int = 0
var total_points = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Die Button".visible = false
	$"Current Points Label".visible = false
	$"Current Points Label".text = str(total_points)
	$"Live Again Button".visible = false

func _process(delta: float) -> void:
	pass


func _on_die_button_pressed() -> void:
	#Reshuffle the deck
	#Award points for cards
	total_points += last_round_score
	$"Current Points Label".text = str(total_points)
	$"Current Points Label".visible = true
	$"Die Button".visible = false
	$"Live Again Button".visible = true
	
	die_sequence_start.emit()

func _on_game_over(score: int):
	last_round_score = score
	$"Die Button".visible = true
	


func _on_live_again_button_pressed() -> void:
	$"Current Points Label".visible = false
	$"Live Again Button".visible = false
	
	start_again.emit()
