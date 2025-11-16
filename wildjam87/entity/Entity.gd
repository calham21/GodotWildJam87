extends CharacterBody2D
class_name Entity


enum ControlMode {PLAYER, AI}
@export var control_type : ControlMode

@export_group("Movement")
@export var jumping : bool = false
var coyote_jump = false
var walk_tween: Tween
var jump_tween: Tween
var fall_tween: Tween
var saved_direction = 1

#Stats
@export_group("Stats")
@export var stats : EntityStats

@export_group("Collisions")
@export var hip_col : CollisionShape2D
@export var body_col : CollisionShape2D
@export var tail_col_array : Array[CollisionShape2D]

@export_group("Visuals")
@export var visual_container : Node2D
@export var tail : TailComponent
@export var hip_node : Sprite2D
@export var body_node : Sprite2D
@export var head_node : Sprite2D
@export var face_node : Sprite2D
@export var body_overlap_ray : Array[RayCast2D] = []

@export_group("Limbs")
@export var arms_array : Array[Arm] = []
@export var active_arm : Arm
@export var selected_index : int = 0

var default_body_pos : Vector2

#Visual Component
#Behaviour Component
#Pathfinding Component
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_breath_tween()
	default_body_pos = body_node.position
	

func _physics_process(delta: float) -> void:
	update_body_collision_lean()
	if control_type == ControlMode.PLAYER:
		player_control()
	else:
		print("ai")
	
	var offset_global = body_node.global_transform.basis_xform(body_node.offset)

	# Apply transform + offset
	body_col.global_transform = Transform2D(
		body_node.global_rotation,
		body_node.global_position + offset_global
	)
	
	if Input.is_action_pressed("down"):
		body_node.rotation = lerp(body_node.rotation, body_node.rotation + deg_to_rad(saved_direction*100), 0.2)
	else:
		pass
	
func player_control():
	var was_on_floor = is_on_floor()
	if Input.is_action_just_pressed("scroll_up"):
		change_target(1)
	elif Input.is_action_just_pressed("scroll_down"):
		change_target(-1)
	
	arm_look_at(get_global_mouse_position())
	active_arm_control()
	
	move_and_slide()
	
	var just_left_ground = !is_on_floor() and was_on_floor
	if just_left_ground && velocity.y >= 0:
		coyote_jump = true
		await(get_tree().create_timer(0.5).timeout)
		coyote_jump = false
		
func ai_control():
	pass
	
func apply_movement(speed):
	var direction := Input.get_axis("left", "right")
	if direction:
		saved_direction = direction
		#hip_node.rotation = lerp(hip_node.rotation, deg_to_rad(direction*7.5), 0.1)
		body_node.rotation = lerp(body_node.rotation, deg_to_rad(direction*25), 0.15)
		face_node.position.x = direction * 2
		velocity.x = direction * speed
	else:
		#hip_node.rotation = lerp(hip_node.rotation, deg_to_rad(0.0), 0.25)
		body_node.rotation = lerp(body_node.rotation, deg_to_rad(0.0), 0.15)
		face_node.position.x = 0
		velocity.x = lerp(velocity.x, 0.0, 0.5)
		
	
func change_target(direction):
	selected_index = (selected_index + direction) % arms_array.size()
	if selected_index < 0:
		selected_index = arms_array.size() - 1
	active_arm = arms_array[selected_index]
	#select(selected_index)
	
	
func apply_gravity(gravity):
	if not is_on_floor():
		velocity.y -= gravity
		
func start_walk_tween():
	_run_walk_cycle()

func _run_walk_cycle():
	var offset := randf_range(0.5, 1.5)
	#print(offset)
	#var dur := randf_range(0.1, 0.25)

	walk_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	walk_tween.tween_property(visual_container, "position:y", visual_container.position.y - offset, 0.1).set_ease(Tween.EASE_IN_OUT)
	walk_tween.tween_property(visual_container, "position:y", 0.0, 0.05)
	walk_tween.tween_property(visual_container, "position:y", visual_container.position.y + offset, 0.1).set_ease(Tween.EASE_IN_OUT)
	walk_tween.tween_property(visual_container, "position:y", 0.0, 0.05)
	walk_tween.finished.connect(_run_walk_cycle)

func stop_walk_tween():
	if walk_tween:
		walk_tween.kill()
	var tween := get_tree().create_tween()
	tween.tween_property(visual_container, "position:y", 0.0, 0.21)
	
func start_jump_tween():
	if fall_tween:
		if fall_tween.is_running():
			fall_tween.kill()
			
	jump_tween = get_tree().create_tween()
	jump_tween.tween_property(body_node, "position:y", body_node.position.y + 10.0, 0.3)
	#jump_tween.tween_property(body_node, "rotation", body_node.rotation + deg_to_rad(saved_direction*60), 0.15).set_ease(Tween.EASE_IN_OUT)
	jump_tween.tween_property(body_node, "position:y", default_body_pos.y, 0.15).set_ease(Tween.EASE_IN_OUT)
	
	
func start_fall_tween():
	if jump_tween:
		if jump_tween.is_running():
			jump_tween.kill()
			
	fall_tween = get_tree().create_tween()
	fall_tween.tween_property(body_node, "position:y", body_node.position.y - 5.0, 0.5)
	#jump_tween.tween_property(body_node, "rotation", body_node.rotation + deg_to_rad(saved_direction*60), 0.15).set_ease(Tween.EASE_IN_OUT)
	fall_tween.tween_property(body_node, "position:y", default_body_pos.y, 0.15).set_ease(Tween.EASE_IN_OUT)
	
func start_breath_tween():
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(body_node, "position:y", body_node.position.y - 1.0, 1.0)
	tween.tween_property(body_node, "position:y", body_node.position.y + 1.0, 1.3)
	
var last_lean_angle : float = 0.0
func update_body_collision_lean():
	var rc = get_first_colliding_ray()
	if rc != null:
		var origin = rc.global_position
		var hit = rc.get_collision_point()
		var angle_to_hit = (hit - origin).angle()
		var ray_end = rc.to_global(rc.target_position)
		var max_dist = origin.distance_to(ray_end)
		var dist = origin.distance_to(hit)
		var proximity = 1.0 - clamp(dist / max_dist, 0.0, 1.0)
		if velocity.x > 0:
			last_lean_angle = -angle_to_hit * proximity * 2.2
		elif velocity.x < 0:
			last_lean_angle = angle_to_hit * proximity * 2.2
		body_node.rotation = lerp_angle(body_node.rotation, last_lean_angle, 0.15)
		head_node.rotation = lerp_angle(head_node.rotation, last_lean_angle/2, 0.15)
	else:
		body_node.rotation = lerp_angle(body_node.rotation, 0.0, 0.1)
		head_node.rotation = lerp_angle(head_node.rotation, 0.0, 0.1)

func get_first_colliding_ray() -> RayCast2D:
	for rc in body_overlap_ray:
		#print(rc)
		if rc.is_colliding():
			return rc
	return null
	
func active_arm_control():
	if not active_arm:
		return
	
	if Input.is_action_just_pressed("interact"):
		if active_arm.can_pickup and active_arm.item_in_range and not active_arm.current_item:
			active_arm.pickup_item()

	if Input.is_action_just_pressed("drop"):
		if active_arm.current_item:
			active_arm.drop_item()

	
func arm_look_at(target : Vector2):
	if active_arm: 
		active_arm.sprite.frame = 0
		active_arm.look_at(target)
		if target.x < global_position.x:
			active_arm.scale.y = -1
		elif target.x > global_position.x:
			active_arm.scale.y = 1
	for arm in arms_array:
		if arm != active_arm:
			arm.scale.y = 1
			arm.sprite.frame = 1
			arm.rotation = lerp(arm.rotation, deg_to_rad(90), 0.2)
