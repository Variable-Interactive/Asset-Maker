extends CSGMesh


onready var cursor = get_node("../../Cursor")


func start_up(block_transform :Transform):
	global_transform = block_transform


func _process(_delta):
	
	if Global.assist_mode:
		if (global_transform.origin.distance_to(cursor.global_transform.origin)) <= 1.5:
			if get_node_or_null("Node") == null:
				var indicator = preload("res://Brushes/Basic/BrushPosition.tscn").instance()
				add_child(indicator)
				get_node("Node/Spatial").global_transform.origin = global_transform.origin
				get_node("Node/Spatial").scale.x = scale.y
				get_node("Node/Spatial").scale.y = scale.y
				if scale.y < 0.2:
						get_node("Node/Spatial/Coordinates").emission_color = Color(1, 1, 1)
						get_node("Node/Spatial/Coordinates").color = Color(0, 0, 0)
				get_node("Node/Spatial/Coordinates").text = str(global_transform.origin)
			
			var coordinates :KinematicBody = get_node("Node/Spatial")
			var look_dir :Vector3 = get_node("../../Camera").global_transform.origin
			look_dir.y = coordinates.global_transform.origin.y
			coordinates.look_at(look_dir,Vector3.UP)
			coordinates.visible = true
	if (global_transform.origin.distance_to(cursor.global_transform.origin)) >= 1.5:
		if get_node_or_null("Node") != null:
			get_node("Node").queue_free()
