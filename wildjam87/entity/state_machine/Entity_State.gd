# Boilerplate class to get full autocompletion and type checks for the `player` when coding the player's states.
# Without this, we have to run the game to see typos and other errors the compiler could otherwise catch while scripting.
class_name EntityState
extends State

# Typed reference to the player node.
var entity: Entity
## For modular use of states and animations. It works so WHO CARES NERD!!!!
## As a rule of thumb, the main animation should be the first added to the array,
@export var anim_names : Array[StringName]
## Use to ingore the secondary animation some states switch to.
@export var ignore_secondary_anim : bool = false

## Use to disable sprite rotation (eg. Unique animation based on camera position)
@export var disable_sprite_rotation : bool = false


func _ready() -> void:
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner.ready
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	entity = owner as Entity
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(entity != null)
