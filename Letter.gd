extends KinematicBody2D

class_name LetterBullet

var letters = "AEIOUABCDEFGHIJKLMNOPQRSTUVWXYZ"
var letter = ""

var max_rotation = 5.0

signal destroyed

var move_speed = 50
var move_speed_when_selected = 35
var move_vec = Vector2.RIGHT
var destroyed = false

func _ready():
	letter = letters[randi() % letters.length()]
	$Label.text = letter
	rotation_degrees = rand_range(-max_rotation, max_rotation)

func _physics_process(delta):
	var speed = move_speed
	if selected:
		speed = move_speed_when_selected
	var coll = move_and_collide(move_vec * speed * delta)
	if coll:
		if coll.collider.has_method("hurt"):
			coll.collider.hurt()
		destroy()

var selected = false
func select():
	if selected:
		return false
	selected = true
	$Outline.color = Color.green
	$Label.modulate = Color.green
	return true

func unselect():
	if !selected:
		return false
	selected = false
	$Outline.color = Color.white
	$Label.modulate = Color.white
	return true

func destroy():
	destroyed = true
	queue_free()
	emit_signal("destroyed", self)
