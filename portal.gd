extends Area3D
# Place this somewhere in your scene. You can alter its appearance, etc,
# but don't remove the given code

# ------------
@export var destination : PackedScene

func _on_body_entered(body):
	if body is FPSPlayer:
		print("changing to ", destination)
		if destination:
			get_tree().change_scene_to_packed.call_deferred(destination)
		else:
			get_tree().reload_current_scene.call_deferred()
# ------------
