extends HBoxContainer

const SLOT = preload("res://slot.tscn")

@onready var slots = get_children()
signal index(i: int)

var current_index: int:
	set(value):
		current_index = value
		reset_focus()
		set_focus()

func _ready() -> void:
	current_index = 0

func reset_focus():
	for slot in slots:
		slot.set_process_input(false)

func set_focus():
	get_child(current_index).grab_focus()
	get_child(current_index).set_process_input(true)
	index.emit(current_index) # in pickup slot


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Scroll_Down"):
		if current_index == get_child_count() - 1:
			current_index = 0
		else:
			current_index += 1
		
	if event.is_action_pressed("Scroll_Up"):
		if current_index == 0:
			current_index = get_child_count() - 1
		else:
			current_index -= 1
	
	if event.is_action_pressed("First_Slot"):
		current_index = 0
	if event.is_action_pressed("Second_Slot"):
		current_index = 1
	if event.is_action_pressed("Trird_Slot"):
		current_index = 2
	if event.is_action_pressed("Fourth_Slot"):
		current_index = 3

func add_item(stats, skill):
	if slots[current_index].stats == null:
		slots[current_index].stats = stats
		slots[current_index].skill = skill
		return
	#if slots[current_index].stats == null:
		#slots[current_index].stats = stats
		#slots[current_index].skill = skill
		#return

func drop_item(stats, skill):
	if slots[current_index].stats != null:
		slots[current_index].stats = null
		slots[current_index].skill = null
		return

func check_item_here(stats) -> bool: 
	var here: bool
	
	if get_child(current_index).stats != null:
		here = true
	else:
		here = false
	return here
