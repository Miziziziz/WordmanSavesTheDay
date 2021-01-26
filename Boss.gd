extends KinematicBody2D

var letter_bullet_obj = preload("res://Letter.tscn")

export var max_bullets_per_shot = 12
export var min_bullets_per_shot = 6

export var fire_rate = 1.0
var cur_fire_time = fire_rate

var health = 50
onready var health_bar = $CanvasLayer/HealthBar
var dead = false

func _ready():
	health_bar.max_value = health
	health_bar.value = health

func damage(amnt: int):
	if dead:
		return
	health -= amnt
	
	if health <= 0:
		dead = true
		get_tree().call_group("letters", "destroy")
		$Sprite/AnimationPlayer.play("die")
		$DieSound.play()
	else:
		$HurtSound.play()
	health_bar.value = health

func _physics_process(delta):
	if dead:
		return
	cur_fire_time -= delta
	if cur_fire_time <= 0.0:
		cur_fire_time = fire_rate
		spawn_bullets()

func spawn_bullets():
	var num_of_bullets_to_spawn = wrapi(randi(), min_bullets_per_shot, max_bullets_per_shot)
	var angle_between = 2*PI / num_of_bullets_to_spawn
	var rand_offset = rand_range(0.0, 2*PI)
	for i in range(num_of_bullets_to_spawn):
		spawn_bullet(Vector2.RIGHT.rotated(angle_between*i+rand_offset))

func spawn_bullet(dir: Vector2):
	var letter_bullet_inst = letter_bullet_obj.instance()
	letter_bullet_inst.move_vec = dir
	letter_bullet_inst.global_position = global_position
	get_tree().get_root().add_child(letter_bullet_inst)

func load_next_level():
	LevelManager.load_next_level()
