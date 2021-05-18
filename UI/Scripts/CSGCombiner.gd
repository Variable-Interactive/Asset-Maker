extends CSGCombiner


onready var save_dial :FileDialog = Global.find_node_by_name(get_node(".."), "SaveDialog")
onready var img_errors = false

func _ready():
	var _error = save_dial.connect("file_selected",self,"save_load")

func save(path :String):
	var nodes :int = 0
	var shape = []
	var node_transforms :Array = []
	var material = []
	
	nodes = get_child_count()
	for transform in get_children():
		var mesh :CSGMesh = transform
		shape.append(mesh.mesh.duplicate())
		node_transforms.append(mesh.global_transform)
		material.append(mesh.material.duplicate())
	
	var file = File.new()
	var err = file.open(path,File.WRITE)
	
	if err != OK:
		Global.pop_error("Error saving file", err)
		return
	
	var data = {"nodes" : nodes,
				"shape" : shape,
				"transforms" : node_transforms,
				"material" : material}
	file.store_var(data,true)
	file.close()
	
	Global.pop_success(str("Saved ", path.get_file()))


func load_file(path :String):
	
	var file = File.new()
	var err = file.open(path,File.READ)
	
	if err != OK:
		Global.pop_error("Error loading file", err)
		return

	get_parent().existing_blocks = []
	get_parent().visual_alternatives = []
	get_parent().do_bin = []
	get_parent().undo_bin = []
	get_parent().undo_redo = UndoRedo.new()
	
	for i in get_children():
		i.queue_free()
	
	var data = file.get_var(true)
	for i in data.nodes:
		var new_block :CSGMesh = preload("res://Brushes/Basic/brush.tscn").instance()

		if "material_albedo" in data:
			new_block.mesh = CubeMesh.new()
		else:
			new_block.mesh = data.shape[i]

		var new_mat = SpatialMaterial.new()
		
		if "material_albedo" in data:
			new_mat.albedo_color = data.material_albedo[i]
			new_mat.albedo_texture = data.material_texture[i]
		else:
			new_mat = data.material[i]
		
		if new_mat.albedo_texture != null:
			if new_mat.albedo_texture.get_data() == null:
				new_mat.albedo_texture = null
				img_errors = true
		new_block.material = new_mat
		
		new_block.start_up(data.transforms[i])
		add_child(new_block)

		get_parent().existing_blocks.append(data.transforms[i].origin)
		get_parent().visual_alternatives.append(new_block)
		get_parent().do_bin.append([new_block, new_block.material, new_block.transform, "Display"])

	if !img_errors:
		Global.pop_success(str("Loaded ", path.get_file()))
	else:
		Global.pop_success(str("Loaded ", path.get_file(), "\n BUT \n", "Some textures that were used in the image are no longer in their expected locations (if you are a contributor, you have probably moved the textures from \"res://Brushes/Basic/\" re-locating them would fix the issue)").c_unescape())


func save_load(path):
	if save_dial.mode == FileDialog.MODE_SAVE_FILE:
		save(path)
	if save_dial.mode == FileDialog.MODE_OPEN_FILE:
		load_file(path)
