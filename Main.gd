extends Spatial


onready var layer = Global.find_node_by_name(self, "layer")
onready var cursor = Global.find_node_by_name(self, "Cursor")

onready var position_status = Global.find_node_by_name(self, "Status")
onready var rotation_status = Global.find_node_by_name(self, "RotationStatus")

onready var texture_container = Global.find_node_by_name(self, "Texture")
onready var current_texture :TextureRect = Global.find_node_by_name(self, "CurrentTexture")
onready var current_color :ColorPickerButton = Global.find_node_by_name(self, "CurrentColor")

onready var canvas :CSGCombiner = Global.find_node_by_name(self, "CSGCombiner")
onready var splash_dialog :WindowDialog = Global.find_node_by_name(self, "SplashDialog")

var existing_blocks :Array = [Vector3(0,0,0)] 


func _ready():
	
	splash_dialog.popup()
	
	Global.paint_texture = current_texture.texture
	Global.paint_color = current_color.color
	
	Draw_axes()
	draw_grid(100,10,-1,layer,Color(0.560784, 0.560784, 0.560784))
	draw_grid(100,1,10,layer,Color(0.380392, 0.380392, 0.380392))


func _physics_process(_delta):
	if position_status.text != str("Position = ",cursor.global_transform.origin):
		position_status.text = str("Position = ",cursor.global_transform.origin)
	
	if rotation_status.text != str(cursor.rotation_degrees):
		rotation_status.text = str("(",int(cursor.rotation_degrees.x), ", ",int(cursor.rotation_degrees.y), ", ", int(cursor.rotation_degrees.z), ")")
	
	if get_node("CanvasLayer/Interface").hold:
		return
	
	var space_state = get_world().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var rayOrign = get_node("Camera").project_ray_origin(mouse_position)
	var rayEnd = rayOrign + get_node("Camera").project_ray_normal(mouse_position) * 2000
	var intersection :Dictionary = space_state.intersect_ray(rayOrign,rayEnd)
	
	if not intersection.empty():
		var pos :Vector3= intersection.position
		pos.y = Global.layer_no
		if cursor.global_transform.origin != pos.snapped(Vector3(Global.snapping,pos.y,Global.snapping)):
			cursor.global_transform.origin = pos.snapped(Vector3(Global.snapping,pos.y,Global.snapping))
		
		
		if Global.mode == "Draw":
			if Input.is_action_just_pressed("left click"):
				paint()
		elif Global.mode == "Erase":
			if Input.is_action_pressed("left click"):
				paint()
		elif Global.mode == "Dropper":
			if Input.is_action_just_pressed("left click"):
				paint()


####### Custom Functions
func paint():
	var item
	if cursor.global_transform.origin in existing_blocks:
		item = canvas.get_child(existing_blocks.find(cursor.global_transform.origin))
		if Global.mode == "Dropper":
			Global.paint_color = item.material.albedo_color
			Global.paint_texture = item.material.albedo_texture
			current_color.color = Global.paint_color
			current_texture.texture = Global.paint_texture
			return
		existing_blocks.remove(existing_blocks.find(cursor.global_transform.origin))
		item.queue_free()
		return
	
	if Global.mode == "Erase":
		return
	var brush :CSGMesh = preload("res://Brushes/Basic/brush.tscn").instance()
	
	#set material
	var brush_material = SpatialMaterial.new()
	
	brush_material.albedo_texture = Global.paint_texture
	brush_material.albedo_color = Global.paint_color
	brush.material = brush_material
	brush.mesh = CubeMesh.new()
	canvas.add_child(brush)
	brush.start_up(cursor.global_transform)
	existing_blocks.append(brush.global_transform.origin)


func Draw_axes():
	var axis = Global.find_node_by_name(self, "axes")
	var x_axis = ImmediateGeometry.new()
	var y_axis = ImmediateGeometry.new()
	var z_axis = ImmediateGeometry.new()
	x_axis.material_override = SpatialMaterial.new()
	x_axis.material_override.albedo_color = Color(0.788235, 0.305882, 0.305882)
	y_axis.material_override = SpatialMaterial.new()
	y_axis.material_override.albedo_color = Color(0.305882, 0.788235, 0.324724)
	z_axis.material_override = SpatialMaterial.new()
	z_axis.material_override.albedo_color = Color(0.305882, 0.392157, 0.788235)
	axis.add_child(x_axis)
	axis.add_child(y_axis)
	axis.add_child(z_axis)
	x_axis.begin(Mesh.PRIMITIVE_LINES)
	x_axis.add_vertex(Vector3(-1000000,0,0))
	x_axis.add_vertex(Vector3(10000,0,0))
	x_axis.end()
	y_axis.begin(Mesh.PRIMITIVE_LINES)
	y_axis.add_vertex(Vector3(0,-10000,0))
	y_axis.add_vertex(Vector3(0,10000,0))
	y_axis.end()
	z_axis.begin(Mesh.PRIMITIVE_LINES)
	z_axis.add_vertex(Vector3(0,0,-10000))
	z_axis.add_vertex(Vector3(0,0,10000))
	z_axis.end()


func draw_grid(size,step,breaking :float ,parent,color):
	var plane = ImmediateGeometry.new()
	parent.add_child(plane)
	plane.material_override = SpatialMaterial.new()
	plane.material_override.albedo_color = color
	
	plane.begin(Mesh.PRIMITIVE_LINES)
	var x :float = 0
	while x < size + 1:
		var i :float = x/breaking
		if "." in str(i) or "-" in str(i): #and x != size/2:
			plane.add_vertex(Vector3(x-(size/2),0,-(size/2)))
			plane.add_vertex(Vector3(x-(size/2),0,size/2))
			plane.add_vertex(Vector3(-(size/2),0,x-(size/2)))
			plane.add_vertex(Vector3(size/2,0,x-(size/2)))
		x += step
	plane.end()





