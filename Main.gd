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


var undo_redo := UndoRedo.new()

var existing_blocks :Array = []  #Its purpose is to search through blocks in "visual_alternatives"
var visual_alternatives = [] #Holds the data for all blocks
var undo_bin :Array = []
var do_bin :Array = []


func _ready():
	splash_dialog.popup()

	Global.paint_texture = current_texture.texture
	Global.paint_color = current_color.color

	Draw_axes()
	draw_grid(100,10,-1,layer,Color(0.560784, 0.560784, 0.560784))
	draw_grid(100,1,10,layer,Color(0.380392, 0.380392, 0.380392))
	paint(cursor.global_transform, Global.paint_color, Global.paint_texture, CubeMesh.new())


func _physics_process(_delta):
	if position_status.text != str("Position = ",cursor.global_transform.origin):
		position_status.text = str("Position = ",cursor.global_transform.origin)

	if rotation_status.text != str(cursor.rotation_degrees):
		rotation_status.text = str("(",int(cursor.rotation_degrees.x), ", ",int(cursor.rotation_degrees.y), ", ", int(cursor.rotation_degrees.z), ")")

	if Global.hold:
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
			if Input.is_action_pressed("continuos_draw"):
				if Input.is_action_pressed("left click"):
					paint(cursor.global_transform, Global.paint_color, Global.paint_texture, CubeMesh.new())
			else:
				if Input.is_action_just_pressed("left click"):
					paint(cursor.global_transform, Global.paint_color, Global.paint_texture, CubeMesh.new())
	
		elif Global.mode == "Erase":
			if Input.is_action_pressed("left click"):
				paint(cursor.global_transform, Global.paint_color, Global.paint_texture, CubeMesh.new())
		elif Global.mode == "Dropper":
			if Input.is_action_just_pressed("left click"):
				paint(cursor.global_transform, Global.paint_color, Global.paint_texture, CubeMesh.new())
		elif Global.mode == "Paint":
			if Input.is_action_pressed("left click"):
				paint(cursor.global_transform, Global.paint_color, Global.paint_texture, CubeMesh.new())


func paint(var transform, var color, var texture, var shape):
	var item
	if transform.origin in existing_blocks:
		item = canvas.get_child(existing_blocks.find(transform.origin))
		if Global.mode == "Dropper":
			Global.paint_color = item.material.albedo_color
			Global.paint_texture = item.material.albedo_texture
			current_color.color = color
			current_texture.texture = texture
			return
		
		elif Global.mode == "Paint":
			if texture != item.material.albedo_texture || color != item.material.albedo_color:
				var paint_mat = SpatialMaterial.new()
				var old_mat = item.material.duplicate()
				paint_mat.albedo_texture = texture
				paint_mat.albedo_color = color
				undo_redo.create_action("painting")
				undo_redo.add_do_method(self, "add_in_do_bin", [item.get_index(), old_mat, paint_mat, "Paint"])
				undo_redo.add_undo_method(self, "add_in_undo_bin")
				undo_redo.add_do_property(self, "existing_blocks", existing_blocks)
				undo_redo.add_undo_property(self, "existing_blocks", existing_blocks)
				undo_redo.commit_action()
			return

		if not Input.is_action_pressed("continuos_draw"):
			var old_existing_blocks = existing_blocks.duplicate(true)
			existing_blocks.remove(existing_blocks.find(transform.origin))
			undo_redo.create_action("erase")
			undo_redo.add_do_method(self, "add_in_do_bin", [item, item.material, item.global_transform, "Erase", item.get_index()])
			undo_redo.add_undo_method(self, "add_in_undo_bin")
			undo_redo.add_do_property(self, "existing_blocks", existing_blocks)
			undo_redo.add_undo_property(self, "existing_blocks", old_existing_blocks)
			undo_redo.commit_action()
			return
		else:
			return

	if Global.mode == "Erase":
	# the block is already erased
		return

	if Global.mode == "Paint":
	# the block has been painted
		return

	var brush :CSGMesh = preload("res://Brushes/Basic/brush.tscn").instance()
	#set material
	var brush_material = SpatialMaterial.new()
	brush_material.albedo_texture = texture
	brush_material.albedo_color = color
	brush.material = brush_material
	brush.mesh = shape
	
	var old_existing_blocks = existing_blocks.duplicate(true)
	existing_blocks.append(transform.origin)
	
	undo_redo.create_action("draw")
	undo_redo.add_do_method(self, "add_in_do_bin", [brush, brush.material, transform, "Display"])
	undo_redo.add_undo_method(self, "add_in_undo_bin")
	undo_redo.add_do_property(self, "existing_blocks", existing_blocks)
	undo_redo.add_undo_property(self, "existing_blocks", old_existing_blocks)
	undo_redo.commit_action()



func add_in_do_bin(value):
	# store the orignal for undo/redo purpose
	do_bin.append(value)
	if !undo_bin.empty():
		undo_bin.remove(undo_bin.size() - 1)
	
	# make a copy of orignal to display visually if display is intended
	if do_bin[do_bin.size()-1][3] == "Display":
		var brush :CSGMesh = do_bin[do_bin.size()-1][0].duplicate()
		brush.material = do_bin[do_bin.size()-1][1]
		brush.start_up(do_bin[do_bin.size()-1][2])
		visual_alternatives.append(brush)
		canvas.add_child(brush)

	# if erasure is intended then the block is already in "visual_alternatives"
	# we will delete it.
	elif do_bin[do_bin.size()-1][3] == "Erase":
		if not visual_alternatives.empty():
			#replace the orignal with a copy and delete the orignal
			do_bin[do_bin.size()-1][0] = do_bin[do_bin.size()-1][0].duplicate()
			visual_alternatives[do_bin[do_bin.size()-1][4]].queue_free()
			visual_alternatives.remove(do_bin[do_bin.size()-1][4])
	
	#if paint is intended, we will paint new material at the given index
	#[item.get_index(), old_mat, paint_mat, "Paint"]
	elif do_bin[do_bin.size()-1][3] == "Paint":
		visual_alternatives[do_bin[do_bin.size()-1][0]].material = do_bin[do_bin.size()-1][2]


func add_in_undo_bin():
	# transfer the last entry of "do_bin" into the "undo_bin". you can consider "undo_bin" as a recycle bin
	undo_bin.append(do_bin[do_bin.size() - 1])
	do_bin.remove(do_bin.size() - 1)

	# if display was intended so as this is "UNDO" so we will erase it
	if undo_bin[undo_bin.size()-1][3] == "Display":
		if not visual_alternatives.empty():
			visual_alternatives[visual_alternatives.size() - 1].queue_free()
			visual_alternatives.remove(visual_alternatives.size() - 1)

	# if erasure was intended so as this is "UNDO" so we will display it
	elif undo_bin[undo_bin.size()-1][3] == "Erase":
		var brush :CSGMesh = undo_bin[undo_bin.size()-1][0].duplicate()
		brush.material = undo_bin[undo_bin.size()-1][1]
		brush.start_up(undo_bin[undo_bin.size()-1][2])
		# place it at the same order as it was before as directed by "do_bin[do_bin.size()-1][4]"
		visual_alternatives.insert(undo_bin[undo_bin.size()-1][4], brush)
		canvas.add_child(brush)
		canvas.move_child(brush, undo_bin[undo_bin.size()-1][4])
	
	#if paint was intended, so as this is "UNDO" we will paint the orignal material back
	#[item.get_index(), old_mat, paint_mat, "Paint"]
	elif undo_bin[undo_bin.size()-1][3] == "Paint":
		canvas.get_child(undo_bin[undo_bin.size()-1][0]).material = undo_bin[undo_bin.size()-1][1]


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


func _input(event):
	if event.is_action_pressed("redo", true):
		if undo_redo.has_redo():
			var _available = undo_redo.redo()
	elif event.is_action_pressed("undo", true):
		if undo_redo.has_undo():
			var _available = undo_redo.undo()
