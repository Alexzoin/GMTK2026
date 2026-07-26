extends Node2D

@onready var starting_pos = position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if get_child_count() > 90:
		var amount_to_move = get_child_count() - 90
		
		position = lerp(position, Vector2(starting_pos.x - (amount_to_move * 10), starting_pos.y), delta)
	else:
		position = starting_pos
