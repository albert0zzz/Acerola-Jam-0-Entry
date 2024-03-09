extends CharacterBody3D
# Docc

#region Camera Movement Variables
@export_group("Camera Setup")
@export_range(30, 110) var Field_of_View: float = 75.0
@export var Enable_Camera_Rotation: bool = true
@export var Invert_Camera_Rotation: bool = false
@export var Look_Sensitivity: float = 0.25
@export var Max_Look_Angle: float = 89.0

@export_group("Crosshair")
@export var Lock_and_Hide_Cursor: bool = true
@export var Auto_Crosshair: bool = true
@export var Crosshair_Image: Texture2D = preload("res://addons/Godot Modular FPC/Crosshair.png")
@export var Crosshair_Color: Color = Color("ffffff", 0.6)

@export_group("Zoom")
@export var Enable_Zoom: bool = true
@export var Hold_to_Zoom: bool = true 
@export var Zoom_FOV: float = 30.0
@export var Zoom_FOV_Step_Time: float = 8.0

# Internal Variables
var is_zoomed: bool = false
#endregion

#region Movement Variables
@export_group("Movement Setup")
@export var Enable_Player_Movement: bool = true
@export var Walk_Speed: float = 5.0

# Internal Variables
const gravity: float = 9.8
const lerp_speed: float = 15.0
const air_lerp_speed: float = 3.0
var cur_speed: float = 10.0
var direction := Vector3.ZERO
var is_walking: bool = false

# Sprint
@export var Enable_Sprint: bool = true
@export var Unlimited_Sprint: bool = false
@export var Sprint_Speed: float = 8.0
@export var Sprint_Duration: float = 5.0
@export var Sprint_Cooldown: float = 2.0
@export var Sprint_FOV: float = 80.0
@export var Sprint_FOV_Step_Time: float = 10.0

# Sprint Bar
@export var Use_Sprint_Bar: bool = true
@export var Hide_Full_Bar: bool = true
@export var Bar_BG_Color: Color = Color("999999")
@export var Bar_Color: Color = Color("ffffff")
@export var Bar_Width: float = 0.3
@export var Bar_Height: float = 0.015

# Internal Variables
var is_sprinting: bool = false
var sprint_remaining: float
var is_sprint_cooldown: bool = false
var sprint_cooldown_reset: float

# Jump
@export_subgroup("Jump")
@export var Enable_Jump: bool = true 
@export var Jump_Power: float = 4.5

# Crouch
@export_subgroup("Crouch")
@export var Enable_Crouch: bool = true
@export var Hold_to_Crouch: bool = true
@export_range(0.0, 1.0) var Crouch_Depth: float = 0.6
@export var Crouch_Speed: float = 2.0

# Internal Variables
var is_crouching: bool = false
#endregion

#region Head Bob
@export_group("Head Bob Setup")
@export var Enable_Head_Bob: bool = true
@export var Bob_Speed: float = 10
@export var Bob_Amount: float = 0.08

# Internal variables
var head_bobbing_vector: Vector2 = Vector2.ZERO
var head_bobbing_index: float = 0.0
var head_bobbing_cur_intensity: float = 0.0
#endregion

#region Player Settings
@export_group("Player Settings")
@export var throw_power: float = 15.0
@export var Hitbox_Stand_Height: float = 2.0
@export var Hitbox_Crouch_Height: float = 1.3
@export var head_height: float = 1.8
#endregion

#region Public Variables
var picked_item: bool = false
var inHandItem: RigidBody3D
signal PickedItem(object: Object)
signal DroppedItem()
#endregion

#region Onready Variables
@onready var sprint_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/SprintBar
@onready var crosshair: TextureRect = $Control/Crosshair
@onready var head: Node3D = $Head
@onready var Camera: Camera3D = $Head/Camera3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var stand_collision_shape: CollisionShape3D = $StandCollisionShape
@onready var crouch_collision_shape: CollisionShape3D = $CrouchCollisionShape

@onready var ray_hit: RayCast3D = $Head/Camera3D/RayHit
@onready var interact_text: Label = $Control/InteractText
@onready var pick_up_slot: Node3D = $Head/PickUpSlot
@onready var drop_text: Label = $Control/DropText
@onready var level: Node3D = $".."
@onready var hand_collision_shape: CollisionShape3D = $HandCollisionShape
@onready var hotbar: HBoxContainer = $Control/Hotbar
@onready var jump_boost_cooldown: Timer = $JumpBoostCooldown
@onready var dash_cooldown: Timer = $DashCooldown

var dash_used: bool = false
const SLOT = preload("res://slot.tscn")

#endregion

func _ready() -> void:
	if !Unlimited_Sprint:
		sprint_remaining = Sprint_Duration
		sprint_cooldown_reset = Sprint_Cooldown
	if Lock_and_Hide_Cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Auto_Crosshair:
		crosshair.visible = true
		crosshair.texture = Crosshair_Image
		crosshair.modulate = Crosshair_Color
	else:
		crosshair.visible = false
	
	if Use_Sprint_Bar:
		sprint_bar.visible = true
		
		var screen_width: float = ProjectSettings.get(
			"display/window/size/viewport_width")
		var screen_height: float = ProjectSettings.get(
			"display/window/size/viewport_height")
		sprint_bar.custom_minimum_size.x = screen_width * Bar_Width
		sprint_bar.custom_minimum_size.y = screen_height * Bar_Height
		var bar_sb := StyleBoxFlat.new()
		var bar_bg_sb := StyleBoxFlat.new()
		sprint_bar.add_theme_stylebox_override("fill", bar_sb)
		sprint_bar.add_theme_stylebox_override("background", bar_bg_sb)
		bar_sb.bg_color = Bar_Color
		bar_bg_sb.bg_color = Bar_BG_Color
		if Hide_Full_Bar:
			sprint_bar.modulate.a = 0.0
	else:
		sprint_bar.visible = false
	stand_collision_shape.shape.height = Hitbox_Stand_Height
	crouch_collision_shape.shape.height = Hitbox_Crouch_Height
	
func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back")
	apply_gravity(delta)
	handle_camera_zoom(delta)
	handle_sprint(input_dir, delta)
	handle_jump()
	handle_crouch(delta)
	handle_headBob(delta)
	handle_pick_n_drop()
	handle_movement(input_dir, delta)
	apply_friction(input_dir, delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= gravity * delta

func handle_camera_zoom(delta: float) -> void:
	if Enable_Zoom:
		# Changes is_zoomed when key is pressed
		# Behavior for toogle zoom
		if Input.is_action_just_pressed("Zoom_Key") && !Hold_to_Zoom && !is_sprinting:
			if !is_zoomed:
				is_zoomed = true
			else:
				is_zoomed = false
		# Changes is_zoomed when key is pressed
		# Behavior for hold to zoom
		if Hold_to_Zoom && !is_sprinting:
			if Input.is_action_pressed("Zoom_Key"):
				is_zoomed = true
			else:
				is_zoomed = false
		# Lerps camera.fov to allow for a smooth transistion
		if is_zoomed:
			Camera.fov = lerp(Camera.fov, 30.0, Zoom_FOV_Step_Time * delta)
		elif !is_zoomed && !is_sprinting:
			Camera.fov = lerp(Camera.fov, Field_of_View, Zoom_FOV_Step_Time * delta)

func handle_sprint(input_dir: Vector2, delta: float) -> void:
	if Enable_Sprint:
		if is_sprinting && input_dir != Vector2.ZERO:
			is_zoomed = false
			Camera.fov = lerp(Camera.fov, Sprint_FOV, Sprint_FOV_Step_Time * delta)
			# Drain sprint remaining while sprinting
			if !Unlimited_Sprint:
				sprint_remaining -= 1 * delta
				if sprint_remaining <= 0:
					is_sprinting = false
					is_sprint_cooldown = true
		elif (is_on_floor() || !is_sprinting):
			# Regain sprint while not sprinting and is on floor
			sprint_remaining += 1 * delta
			sprint_remaining = clamp(sprint_remaining, 0, Sprint_Duration)
		# Handles sprint cooldown 
		# When sprint remaining == 0 stops sprint ability until hitting cooldown
		if is_sprint_cooldown:
			Sprint_Cooldown -= 1 * delta
			if Sprint_Cooldown <= 0:
				is_sprint_cooldown = false
		else:
			Sprint_Cooldown = sprint_cooldown_reset
			
		# Handles sprintBar 
		if Use_Sprint_Bar && !Unlimited_Sprint:
			var sprint_remaining_percent: float = sprint_remaining / Sprint_Duration
			sprint_bar.value = sprint_remaining_percent

func handle_jump() -> void:
	# Gets input and calls jump method
	if Enable_Jump && Input.is_action_pressed("Jump_Key") && is_on_floor():
		# Adds force to the player rigidbody to jump
		velocity.y = Jump_Power

func handle_crouch(delta: float) -> void:
	if Enable_Crouch:
		if Hold_to_Crouch:
			if Input.is_action_pressed("Crouch_Key"):
				# Crouching
				stand_collision_shape.disabled = true
				crouch_collision_shape.disabled = false
				is_crouching = true
			elif !ray_cast_3d.is_colliding():
				# Standing
				stand_collision_shape.disabled = false
				crouch_collision_shape.disabled = true
				is_crouching = false
		else:
			if Input.is_action_just_pressed("Crouch_Key"):
				if is_crouching && !ray_cast_3d.is_colliding():
					# Standing
					stand_collision_shape.disabled = false
					crouch_collision_shape.disabled = true
					is_crouching = false
				else:
					# Crouching
					stand_collision_shape.disabled = true
					crouch_collision_shape.disabled = false
					is_crouching = true
		if is_crouching:
			head.position.y = lerp(
				head.position.y, 
				head_height * Crouch_Depth, 
				delta * lerp_speed,
				)
		else:
			head.position.y = lerp(head.position.y, head_height, delta * lerp_speed)

func handle_headBob(delta: float) -> void:
	if Enable_Head_Bob:
		if is_walking:
			# Calculates HeadBob speed during sprint
			if is_sprinting:
				head_bobbing_index += delta * (Bob_Speed + Sprint_Speed)
			# Calculates HeadBob speed during crouching movement
			elif is_crouching:
				head_bobbing_index += delta * (Bob_Speed + Crouch_Speed)
			# Calculates HeadBob speed during walking
			else:
				head_bobbing_index += delta * Bob_Speed;
			# Applies HeadBob movement
			head_bobbing_vector.y = sin(head_bobbing_index)
			head_bobbing_vector.x = sin(head_bobbing_index/2)
			
			Camera.position.y = lerp(
				Camera.position.y,
				head_bobbing_vector.y * (Bob_Amount / 2),
				delta * lerp_speed
				)
			Camera.position.x = lerp(
				Camera.position.x,
				head_bobbing_vector.x * (Bob_Amount),
				delta * lerp_speed
				)
		else:
			# Resets when play stops moving
			#head_bobbing_index = 0
			Camera.position.y = lerp(Camera.position.y, 0.0, delta * lerp_speed)
			Camera.position.x = lerp(Camera.position.x, 0.0, delta * lerp_speed)

func handle_movement(input_dir: Vector2, delta: float) -> void:
	if is_on_floor():
		direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
		dash_used = false
	else:
		if input_dir != Vector2.ZERO:
			direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if is_on_floor(): #and dash_cooldown.time_left == 0
		velocity.x = lerp(velocity.x, cur_speed * direction.x, 1)
		velocity.z = lerp(velocity.z, cur_speed * direction.z, 1)
	if dash_used == false:
		velocity.x = direction.x * cur_speed
		velocity.z = direction.z * cur_speed
	
	#if direction:
		#velocity.x = direction.x * cur_speed
		#velocity.z = direction.z * cur_speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, cur_speed)
		#velocity.z = move_toward(velocity.z, 0, cur_speed)
	
	if Input.is_action_just_pressed("Interact_Key") and !(ray_hit.get_collider() is Cube):
		if pick_up_slot.get_child(hotbar.current_index).skill != null:
			#print("bruh")
			if pick_up_slot.get_child(hotbar.current_index).skill.name == "Jump Boost": # and jump_boost_cooldown.time_left == 0
				print("Jump Boost")
				velocity.y = Jump_Power * 2
				jump_boost_cooldown.start()
			if pick_up_slot.get_child(hotbar.current_index).skill.name == "Dash": #and dash_cooldown.time_left == 0
				print("Dash")
				#var dash_vec = -head.global_transform.basis.z
				dash_used = true
				velocity.y = 3
				velocity.z = -head.global_transform.basis.z.z * 25
				velocity.x = -head.global_transform.basis.z.x * 25
				print_debug(velocity)
				dash_cooldown.start()
				
			if pick_up_slot.get_child(hotbar.current_index).skill.name == "Explosion Boost":
				print("Explosion Boost")
			if pick_up_slot.get_child(hotbar.current_index).skill.name == "No Skill":
				print("No Skill")
	
	if Enable_Player_Movement:
		if input_dir != Vector2.ZERO && is_on_floor():
			is_walking = true
		else:
			is_walking = false
		
		if Enable_Sprint && Input.is_action_pressed("Sprint_Key") && sprint_remaining > 0.0 && !is_sprint_cooldown && !is_crouching && (input_dir != Vector2.ZERO):
			#cur_speed = lerp(cur_speed, Sprint_Speed, delta * lerp_speed)
			cur_speed = move_toward(cur_speed, Sprint_Speed, lerp_speed)
			is_sprinting = true
		else:
			is_sprinting = false
			if Enable_Crouch && is_crouching && is_on_floor():
				#cur_speed = lerp(cur_speed, Crouch_Speed, delta * lerp_speed)
				cur_speed = move_toward(cur_speed, Crouch_Speed, lerp_speed)
			else:
				#cur_speed = lerp(cur_speed, Walk_Speed, delta * lerp_speed)
				cur_speed = move_toward(cur_speed, Walk_Speed, lerp_speed)

func apply_friction(input_dir: Vector2, delta: float):
	if !input_dir and is_on_floor():
		#velocity.x = move_toward(velocity.x, 0.0, 10)
		#velocity.z = move_toward(velocity.z, 0.0, 10)
		#velocity.x = direction.x * cur_speed
		#velocity.z = direction.z * cur_speed
		pass
	

func handle_pick_n_drop():
	var collider = ray_hit.get_collider()

	# Picking mech
	if collider is Cube: # && !picked_item
		interact_text.visible = true
		if Input.is_action_just_pressed("Interact_Key") and !(pick_up_slot.get_child(hotbar.current_index) is Cube):
			PickedItem.emit(collider) # to abstract item
	else:
		interact_text.visible = false

	# Dropping mech
	if Input.is_action_just_pressed("Drop_Key"):
		if pick_up_slot.get_child(hotbar.current_index) is Cube:
			DroppedItem.emit()
	if pick_up_slot.get_child(hotbar.current_index) is Cube:
		var hand_item = pick_up_slot.get_child(hotbar.current_index)
		hand_collision_shape.disabled = false
		hand_collision_shape.global_transform = hand_item.get_node("CollisionShape3D").global_transform
	else:
		hand_collision_shape.disabled = true

func add_item(stats, skill):
	hotbar.add_item(stats, skill)

func drop_item(stats, skill):
	hotbar.drop_item(stats, skill)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if Enable_Camera_Rotation:
				if !Invert_Camera_Rotation:
					rotate_y(deg_to_rad(-event.relative.x * Look_Sensitivity))
				else:
					rotate_y(deg_to_rad(event.relative.x * Look_Sensitivity))
				head.rotate_x(deg_to_rad(-event.relative.y * Look_Sensitivity))
				head.rotation.x = clamp(
					head.rotation.x, 
					deg_to_rad(-Max_Look_Angle), 
					deg_to_rad(Max_Look_Angle),
					)
