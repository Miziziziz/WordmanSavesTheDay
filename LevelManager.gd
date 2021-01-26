extends Node


var levels = [
	"res://Start.tscn",
	"res://IntroCutscene.tscn",
	"res://World.tscn",
	"res://OutroCutscene.tscn"
]

var level_ind = 0
func load_next_level():
	level_ind += 1
	get_tree().call_group("instanced", "queue_free")
	get_tree().change_scene(levels[level_ind])
