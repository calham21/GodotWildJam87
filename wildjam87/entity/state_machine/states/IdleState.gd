
extends EntityState

func enter(_msg := {}) -> void:
	entity.velocity.x = 0.0
	
func update(_delta: float) -> void:
		entity.hip_node.rotation = lerp(entity.hip_node.rotation, deg_to_rad(0.0), 0.25)
		entity.body_node.rotation = lerp(entity.body_node.rotation, deg_to_rad(0.0), 0.15)
	
func physics_update(_delta: float) -> void:
	entity.apply_gravity(entity.stats.gravity)
	
	if entity.velocity.y < 0 or not entity.is_on_floor():
		state_machine.transition_to("Fall")
		
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		state_machine.transition_to("Move")
		
	if entity.is_on_floor() or entity.coyote_jump == true:
		if Input.is_action_just_pressed("jump"):
			entity.jumping = true
	if entity.jumping == true:
		state_machine.transition_to("Jump")
			
		
func exit() -> void:
	pass
