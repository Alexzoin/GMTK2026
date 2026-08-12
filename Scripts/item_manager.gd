extends CanvasLayer
class_name ItemManager
@export var ui_manager: UI
@export var card_manager: CardManager
@export var all_items: Array[PackedScene]
@export var num_items_in_shop: int = 3

@onready var item_pool: Array[PackedScene] = all_items.duplicate_deep()

var item_scenes_in_shop: Array[PackedScene] = []

var owned_items: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Shop Items".visible = false
	$"Item Hand".visible = true

var has_spawned = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_key_pressed(Key.KEY_S):
		#empty_shop()
		#populate_shop()
	#if Input.is_key_pressed(Key.KEY_I) and not has_spawned:
		#has_spawned = true
		#var temp = item_pool[28].instantiate()
		#$"Item Hand".add_child(temp)
		#temp.position = Vector2(randf() * 128, randf() * 128)
		#owned_items.append(temp)
		#temp.is_in_shop = false
		#temp.cost_text.visible = false
		#temp.description_text.visible = false
	pass

func process_passives(event_type: PassiveTrigger.TriggerEvent, context: Dictionary) -> void:
	for item in owned_items:
		item.process_passive_trigger(event_type, context)

func evaluate_card(new_card) -> bool:
	var last_card = card_manager.get_last_played_card()
	if last_card:
		return evaluate_play(last_card, new_card)
	else:
		print("No cards have been played yet.")
		return false

func evaluate_play(current_card, new_card) -> bool:
	var allow_play: bool = false
	for item in owned_items:
		if item.item_type == Item.item_types.play_allower:
			if item.check_rules(current_card, new_card):
				allow_play = true
				
	return allow_play

func _on_card_played(new_card, old_card):
	for item in owned_items:
		if item.item_type == Item.item_types.play_allower:
			if item.check_rules(old_card, new_card):
				item.rule_was_used()
				
		

func populate_shop():
	var num_items_to_add = num_items_in_shop
	if num_items_to_add > item_pool.size():
		num_items_to_add = item_pool.size()
		
	for i in range(num_items_to_add):
		var valid_item_not_found: bool = true
		
		while valid_item_not_found:
			var item_to_add = item_pool.pick_random()
			
			if item_scenes_in_shop.has(item_to_add):
				valid_item_not_found = true
			else:
				item_scenes_in_shop.append(item_to_add)
				valid_item_not_found = false
				
	var count = 0
	for item in item_scenes_in_shop:
		var temp = item.instantiate()
		$"Shop Items".add_child(temp)
		temp.position = Vector2(count * 256, 0)
		temp.scene_resource = item
		temp.item_manager = self
		count += 1
		
		
func empty_shop():
	item_scenes_in_shop = []
	
	for item in $"Shop Items".get_children():
		item.queue_free()
	
func go_to_shop():
	print("go to shop")
	#hide player items
	# populate shop with items and show
	populate_shop()
	$"Item Hand".visible = false
	$"Shop Items".visible = true

func hide_shop():
	empty_shop()
	$"Item Hand".visible = true
	$"Shop Items".visible = false

func try_to_purchase(item) -> bool:
	if item.cost <= ui_manager.total_points:
		print("enough money buying")
		ui_manager.total_points -= item.cost
		item.reparent($"Item Hand")
		item.position = Vector2(randf() * 128, randf() * 128)
		owned_items.append(item)
		
		for i in item_scenes_in_shop:
			if item.scene_resource == i:
				print("item found in list, removing.")
				item_scenes_in_shop.erase(i)
				item_pool.erase(i)
				break
		
		return true
		
	return false
