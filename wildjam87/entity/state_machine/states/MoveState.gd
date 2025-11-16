extends EntityState

func enter(_msg := {}) -> void:
	pass
	#entity.start_walk_tween()
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	entity.apply_gravity(entity.stats.gravity)
	entity.apply_movement(entity.stats.move_speed)
	
	if entity.velocity.y < 0 or not entity.is_on_floor():
		state_machine.transition_to("Fall")

	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		state_machine.transition_to("Idle")
		
	if entity.is_on_floor() or entity.coyote_jump == true:
		if Input.is_action_just_pressed("jump"):
			entity.jumping = true
	if entity.jumping == true:
		state_machine.transition_to("Jump")
		
func exit() -> void:
	pass
	#entity.stop_walk_tween()
	
