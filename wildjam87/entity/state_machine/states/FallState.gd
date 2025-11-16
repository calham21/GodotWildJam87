extends EntityState

func enter(_msg := {}) -> void:
	pass
	#entity.start_fall_tween()
	entity.face_node.position.y = entity.face_node.position.y + 1
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	entity.apply_gravity(entity.stats.fall_gravity)
	entity.apply_movement(entity.stats.move_speed)
	
	if entity.is_on_floor():
		if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Move")
			
			
	if entity.is_on_floor() or entity.coyote_jump == true:
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Jump")
		
func exit() -> void:
	entity.face_node.position.y = -4
