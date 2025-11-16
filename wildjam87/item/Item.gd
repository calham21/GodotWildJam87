extends RigidBody2D
class_name PhysicalItem

@export var grab_point : Marker2D
@export var item_sprite : Sprite2D

var grabbed : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
