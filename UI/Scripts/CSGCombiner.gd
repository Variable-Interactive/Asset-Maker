extends CSGCombiner


onready var save_dial :FileDialog = Global.find_node_by_name(get_node(".."), "SaveDialog")

func _ready():
	var _error = save_dial.connect("file_selected",self,"save_load")

func save(path):
	var nodes :int = 0
	var shape = []
	var node_transforms :Array = []
	var material = []
	
	nodes = get_child_count()
	for transform in get_children():
		var mesh :CSGMesh = transform
		shape.append(mesh.mesh)
		node_transforms.append(mesh.global_transform)
		material.append(mesh.material)
	
	var file = File.new()
	file.open(path,File.WRITE)
	var data = {"nodes" : nodes,
				"shape" : shape,
				"transforms" : node_transforms,
				"material" : material}
	file.store_var(data,true)
	file.close()


func load_file(path):
	get_parent().existing_blocks = []
	for i in get_children():
		i.queue_free()
	
	var file = File.new()
	file.open(path,File.READ)
	var data :Dictionary = file.get_var(true)
	for i in data.nodes:
		var new_block :CSGMesh = preload("res://Brushes/Basic/brush.tscn").instance()
		
		if "material_albedo" in data:
			new_block.mesh = CubeMesh.new()
		else:
			new_block.mesh = data.shape[i]
		
		add_child(new_block)
		new_block.start_up(data.transforms[i])
		
		var mat := SpatialMaterial.new()
		if "material_albedo" in data:
			mat.albedo_color = data.material_albedo[i]
			mat.albedo_texture = data.material_texture[i]
		else:
			mat = data.material[i]
		
		get_parent().existing_blocks.append(new_block.global_transform.origin)
		
		new_block.material = mat


func save_load(path):
	if save_dial.mode == FileDialog.MODE_SAVE_FILE:
		save(path)
	if save_dial.mode == FileDialog.MODE_OPEN_FILE:
		load_file(path)
