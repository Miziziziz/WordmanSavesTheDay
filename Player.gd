extends KinematicBody2D

onready var submit_word_display = $CanvasLayer/WordDisplay/SubmitWord
onready var clear_word_display = $CanvasLayer/WordDisplay/ClearWord
onready var word_display = $CanvasLayer/WordDisplay
onready var word_display_start_pos = word_display.rect_global_position

onready var restart_button = $CanvasLayer/RestartButton

onready var anim_player = $AnimationPlayer

export var move_accel = 50
export var max_speed = 250
var move_drag = 0.0
var stop_drag = 0.95

var velocity : Vector2
export var health = 5
var dead = false

func _ready():
	move_drag = float(move_accel) / max_speed
	
	submit_word_display.hide()
	clear_word_display.hide()
	
	restart_button.connect("button_up", self, "restart")
	restart_button.hide()
	update_letters_display()

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if dead:
		return
	
	if Input.is_action_just_pressed("submit"):
		submit_word()
	if Input.is_action_just_pressed("clear"):
		clear_word()
	
	if Input.is_action_just_pressed("select_letter"):
		attempt_select_letter(get_global_mouse_position())
	


func _physics_process(delta):
	if dead:
		return
	var move_vec = Vector2()
	move_vec.y -= int(Input.is_action_pressed("move_up"))
	move_vec.y += int(Input.is_action_pressed("move_down"))
	move_vec.x -= int(Input.is_action_pressed("move_left"))
	move_vec.x += int(Input.is_action_pressed("move_right"))
	move_vec = move_vec.normalized()
	
	var drag = move_drag
	if move_vec.length_squared() < 0.01:
		anim_player.play("idle")
		drag = stop_drag
	else:
		anim_player.play("walk")
	
	velocity += move_accel * move_vec - velocity * drag
	move_and_slide(velocity, Vector2.ZERO)
	
	for i in get_slide_count():
		var coll = get_slide_collision(i)
		if coll.collider is LetterBullet and !coll.collider.destroyed:
			coll.collider.destroy()
			hurt()

var letters_selected = []
func attempt_select_letter(pos: Vector2):
	var query = Physics2DShapeQueryParameters.new()
	var select_transform = Transform2D()
	select_transform.origin = pos
	query.set_transform(select_transform)
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 3
	query.set_shape(circle_shape)
	query.collision_layer = 4
	var space_state = get_world_2d().get_direct_space_state()
	var results = space_state.intersect_shape(query)
	var letter_selected : Node2D
	var unselected = false
	for item_data in results:
		var item = item_data.collider
		if item.has_method("select") and item.select():
			letter_selected = item
			break
		elif item.has_method("unselect") and item.unselect():
			letter_selected = item
			unselected = true
			break
	if unselected:
		unselect_letter(letter_selected)
	else:
		select_letter(letter_selected)

var cur_word = ""
func update_letters_display():
	var s = ""
	for letter_obj in letters_selected:
		if is_instance_valid(letter_obj):
			s += letter_obj.letter
	cur_word = s
	word_display.text = cur_word
	word_display.rect_size = word_display.get_minimum_size()
	word_display.rect_global_position = word_display_start_pos
	word_display.rect_position.x -= word_display.rect_size.x/2.0
	submit_word_display.visible = Words.is_word_valid(cur_word)
	clear_word_display.visible = s != ""

func submit_word():
	if !Words.is_word_valid(cur_word):
		return
	var points = pow(2, letters_selected.size())
	for letter  in letters_selected.duplicate():
		letter.destroy()
	clear_word()
	get_tree().call_group("boss", "damage", points)
	

func clear_word():
	get_tree().call_group("letters", "unselect")
	letters_selected = []
	update_letters_display()

func select_letter(letter_obj: LetterBullet):
	if !is_instance_valid(letter_obj):
		return
	letters_selected.append(letter_obj)
	letter_obj.select()
	letter_obj.connect("destroyed", self, "unselect_letter")
	update_letters_display()

func unselect_letter(letter_obj: LetterBullet):
	if !is_instance_valid(letter_obj):
		return
	letters_selected.erase(letter_obj)
	letter_obj.unselect()
	letter_obj.disconnect("destroyed", self, "unselect_letter")
	update_letters_display()

func hurt():
	if dead:
		return
	health -= 1
	if health <= 0:
		dead = true
		health = 0
		restart_button.show()
		anim_player.play("die")
	var ind = 0
	for c in $CanvasLayer/HealthDisplay.get_children():
		c.hide()
		if ind < health:
			c.show()
		ind += 1

func restart():
	get_tree().call_group("letters", "queue_free")
	get_tree().reload_current_scene()
