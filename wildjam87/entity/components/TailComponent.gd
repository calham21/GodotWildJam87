extends Node2D
class_name TailComponent

@export var entity : Entity
@export var tail_scale : float = 1.0
@export var num_nodes : int = 10
@export var min_distance : float = 1.0
@export var node_pos_lerp_seed : float = 4.0
@export var node_offset : Vector2 = Vector2(-2.0, -0.2)
@export var velocity_mult : Vector2 = Vector2(10.0, 7.0)
var nodes : Array = []

func _ready():
	create_body()

func create_body():
	if get_child_count() > 0:
		for i in get_children():
			i.queue_free()
			
	var previous_node_pos : Vector2 = Vector2.ZERO
	for i in range(num_nodes + 1):
		var new_node :Node2D = Node2D.new()
		new_node.position = previous_node_pos + (Vector2.ZERO if i == 0 else node_offset)
		previous_node_pos = new_node.position
		var scale_percent : float = float(i) / num_nodes
		new_node.scale = Vector2.ONE * lerp(6.0, 1.0, scale_percent)
		
		add_child(new_node)
		nodes.append(new_node)
		
var last_nonzero_velocity := Vector2.RIGHT


func _physics_process(delta):
	if get_child_count() == 0:
		return
	
	var entity_vel : Vector2 = entity.get_real_velocity() * velocity_mult
	
	for i in range(1, get_child_count()):
		var prev_node = get_child(i - 1)
		var cur_node = get_child(i)
	
		var pos_offset = lerp(node_offset, abs(node_offset), 1.0)
		var target_pos : Vector2 = prev_node.position + pos_offset
		
		target_pos += -entity_vel * 0.05
		#var gravity_strength := 200.0 # tweak this value for heavier tails
		#var weight_factor := float(i) / num_nodes # more droop toward the tip
		#target_pos.y += gravity_strength * weight_factor * delta
		
		var node_pos_weight : float = 1.0 - exp(-node_pos_lerp_seed * delta)
		cur_node.position = lerp(cur_node.position, target_pos, node_pos_weight)
		
		var dir_to_last_node : Vector2 = cur_node.position - prev_node.position
		var distance_to_last_node : float = dir_to_last_node.length()
		var piece_scale : float = cur_node.scale.x
		if distance_to_last_node > min_distance * piece_scale:
			dir_to_last_node = dir_to_last_node.normalized() * min_distance * piece_scale
			cur_node.position = prev_node.position + dir_to_last_node
		

	queue_redraw()

func _draw():
	for node in nodes:
		draw_circle(node.position, node.scale.x*tail_scale, Color.WHITE)
		
		
