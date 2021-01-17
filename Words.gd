extends Node

# dictionary file source: https://github.com/dwyl/english-words

var all_words = {}

func _ready():
	var dictionary_file = File.new()
	dictionary_file.open("words_dictionary.json", File.READ)
	all_words = parse_json(dictionary_file.get_as_text())
	dictionary_file.close()

func is_word_valid(word: String):
	if word.length() <= 1:
		return false
	return word.to_lower() in all_words
