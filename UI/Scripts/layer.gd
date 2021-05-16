extends TextureRect


func _process(_delta):
	if Input.is_action_just_pressed("layer up"):
		get_node("layer").value += 1
	elif Input.is_action_just_pressed("layer down"):
		get_node("layer").value -= 1
