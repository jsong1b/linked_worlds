extends Node
# This just loads the first scene - set start_scene to yours

@export var start_scene : PackedScene

func _ready():
	get_tree().change_scene_to_packed.call_deferred(start_scene)
	
