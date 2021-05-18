extends Control





func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	$AnimationPlayer.play("startup")


func _on_AnimationPlayer_animation_finished(_anim_name):
	OS.set_window_maximized(true)
	yield(get_tree().create_timer(0.5), "timeout")
	var _error = get_tree().change_scene("res://Main.tscn")
