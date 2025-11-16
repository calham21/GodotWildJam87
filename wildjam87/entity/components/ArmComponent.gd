extends Node2D
class_name Arm

@onready var sprite: Sprite2D = $Sprite
@onready var hand: Marker2D = $Hand
@onready var hand_pickup_area: Area2D = $Hand/HandPickupArea

@export var can_pickup : bool = false
@export var item_in_range : PhysicalItem
@export var current_item : PhysicalItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(current_item)
	if current_item:
		current_item.rotation = rotation
		current_item.scale.y = scale.y
		var grab_global = current_item.grab_point.global_position
		# Move item so grab_point lands on the hand
		current_item.global_position += hand.global_position - grab_global

func pickup_item():
	if can_pickup and item_in_range and !item_in_range.grabbed:
		item_in_range.grabbed = true
		item_in_range.freeze = true
		current_item = item_in_range
		current_item.rotation = deg_to_rad(0.0)
		print(current_item)
		
func drop_item():
	print(current_item)
	if current_item:
		print(current_item)
		current_item.grabbed = false
		current_item.freeze = false
		
		#Stop following the hand
		current_item = null

func _on_hand_pickup_area_body_entered(body: Node2D) -> void:
	can_pickup = true
	if body is PhysicalItem:
		#print(body)
		item_in_range = body

func _on_hand_pickup_area_body_exited(body: Node2D) -> void:
	can_pickup = false
	item_in_range = null
