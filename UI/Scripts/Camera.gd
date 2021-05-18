extends Camera
var can_move = false
export (float) var speed = 10
var mouse_delta :Vector2
var sensitivity :float = 10

func _process(delta):
	if Global.hold:
		return
	
	if Input.is_action_pressed("mouse drag"):
		rotate_object_local(Vector3.RIGHT,deg2rad(mouse_delta.y * sensitivity * delta))
		rotate_y(deg2rad(mouse_delta.x * sensitivity * delta))
	mouse_delta = Vector2.ZERO
	var dir = Vector3.ZERO
	if Input.is_action_pressed("up"):
		global_transform.origin.y += speed * delta
		#dir -= transform.basis.z
	
	elif Input.is_action_pressed("down"):
		global_transform.origin.y -= speed * delta
		#dir += transform.basis.z
	
	elif Input.is_action_pressed("forward"):
		var vect :Vector3= transform.basis.z
		vect.y = 0
		vect = vect.normalized()
		dir -= vect
	
	elif Input.is_action_pressed("backward"):
		var vect :Vector3= transform.basis.z
		vect.y = 0
		vect = vect.normalized()
		dir += vect
	
	if Input.is_action_pressed("rotate left"):
		rotate_y(deg2rad(100 * delta))
	
	elif Input.is_action_pressed("left"):
		dir -= transform.basis.x
	
	if Input.is_action_pressed("rotate right"):
		rotate_y(deg2rad(-100 * delta))
	
	elif Input.is_action_pressed("right"):
		dir += transform.basis.x
	transform.origin += dir.normalized() * speed * delta


func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
