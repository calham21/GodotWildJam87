extends EntityState

func enter(_msg := {}) -> void:
	entity.velocity.y -= entity.stats.jump_force
	print("jump")
	entity.face_node.position.y = entity.face_node.position.y - 2
	#entity.start_jump_tween()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	entity.apply_gravity(entity.stats.gravity)
	entity.apply_movement(entity.stats.move_speed)
	
	if entity.velocity.y > 0:
		state_machine.transition_to("Fall")
		

	if Input.is_action_just_released("jump"):
		print("hello")
		entity.velocity.y = 0
		state_machine.transition_to("Fall")
		
func exit() -> void:
	entity.face_node.position.y = -4
	entity.jumping = false
