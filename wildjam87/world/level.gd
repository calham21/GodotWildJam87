extends Node2D
class_name Level

@onready var ground_tilemap: TileMapLayer = $GroundTilemap
@onready var background_tilemap: TileMapLayer = $BackgroundTilemap

var astar_grid: AStarGrid2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#add_depth()

func init_astar_grid():
	astar_grid = AStarGrid2D.new()
	astar_grid.size = ground_tilemap.get_used_rect().size
	astar_grid.cell_size = ground_tilemap.tile_set.tile_size
	astar_grid.update()
	
func add_depth():
	var layers = 40
	for i in layers:
		var cl = CanvasLayer.new()
		cl.follow_viewport_enabled = true
		print("foreground")
		var new
		if i >= 30:
			new = ground_tilemap.duplicate()
		else:
			new = background_tilemap.duplicate()
		cl.add_child(new)
		new.show()
		#if randi_range(0, 2) == 2:
			#for child in new.get_children():
				#child.call_deferred("queue_free")
		cl.layer = i - layers
		cl.follow_viewport_scale = remap(-cl.layer, layers, 0, 0.90, 1.0)
		add_child(cl)
