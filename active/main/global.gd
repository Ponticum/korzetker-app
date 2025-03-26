extends Node

enum{NONE, ONE_RES, MORE_SAME, MORE_DIFF, NO_RES, BAD_PIR, BAD_HSZ}

const CITIES: Dictionary = {
	0:	["Ajka",			"res://data/ajka.json"				],
	1:	["Baja",			"res://data/baja.json"				],
	2:	["Bicske",			"res://data/bicske.json"			],
	3:	["Budakeszi",		"res://data/budakeszi.json"			],
	4:	["Dabas",			"res://data/dabas.json"				],
	5:	["Debrecen",		"res://data/debrecen.json"			],
	6:	["Eger",			"res://data/eger.json"				],
	7:	["Érd",				"res://data/erd.json"				],
	8:	["Győr",			"res://data/gyor.json"				],
	9:	["Kecskemét",		"res://data/kecskemet.json"			],
	10:	["Miskolc",			"res://data/miskolc.json"			],
	11:	["Nyírbátor",		"res://data/nyirbator.json"			],
	12:	["Nyíregyháza",		"res://data/nyiregyhaza.json"		],
	13:	["Ózd",				"res://data/ozd.json"				],
	14:	["Pécs",			"res://data/pecs.json"				],
	15:	["Sopron",			"res://data/sopron.json"			],
	16:	["Szeged",			"res://data/szeged.json"			],
	17:	["Székesfehérvár",	"res://data/szekesfehervar.json"	],
	18:	["Veszprém",		"res://data/veszprem.json"			],
	
	19:	["Budapest I",		"res://data/budapest_i.json"		],
	20:	["Budapest II",		"res://data/budapest_ii.json"		],
	21:	["Budapest III",	"res://data/budapest_iii.json"		],
	22:	["Budapest IV",		"res://data/budapest_iv.json"		],
	23:	["Budapest IX",		"res://data/budapest_ix.json"		],
	24:	["Budapest VI",		"res://data/budapest_vi.json"		],
	25:	["Budapest VII",	"res://data/budapest_vii.json"		],
	26:	["Budapest XI",		"res://data/budapest_xi.json"		],
	27:	["Budapest XII",	"res://data/budapest_xii.json"		],
	28:	["Budapest XIV",	"res://data/budapest_xiv.json"		],
	29:	["Budapest XIX",	"res://data/budapest_xix.json"		],
	30:	["Budapest XXI",	"res://data/budapest_xxi.json"		],
	31: ["Budapest XXII",	"res://data/budapest_xxii.json"		],
}

var DATABASE: Dictionary = {}
var CITY_DATA: Array = []

var sel_name: Array = []
var sel_iranyito: String = ""
var sel_hazszam: String = ""

var debug_str: String = ""
var res_items: Array = []
var resolution: int = 0

var city: String = "" : set = _set_city
var first_time: bool = false
var strns_node: VBoxContainer = null

var street_names: Array = []
var gyors_mod: bool = false : set = _set_gyors_mod
var just_sel_utc: bool = false : set = _set_just_sel


func _set_gyors_mod(value: bool):
	gyors_mod = value
	save_game()


func _set_just_sel(value: bool):
	just_sel_utc = value
	await get_tree().create_timer(1.5).timeout
	just_sel_utc = false


func _ready() -> void:
	DATABASE = load_data(CITIES)
	create_strns_node()
	load_game()


func save() -> Dictionary:
	var save_dict: Dictionary = {
		"city" : city,
		"first_time" : first_time,
		"gyors_mod" : gyors_mod
	}
	return save_dict

func save_game():
	print("save")
	var savedata = FileAccess.open("user://savedata.save", FileAccess.WRITE)
	if savedata == null:
		print("Error: Unable to open file for writing")
		return
	
	var json_string = JSON.stringify(save())
	savedata.store_line(json_string)
	savedata.close()

func load_game():
	print("load")
	if not FileAccess.file_exists("user://savedata.save"):
		city = "Budapest I"
		first_time = true
		gyors_mod = false
		save_game()
		return
	
	var savedata = FileAccess.open("user://savedata.save", FileAccess.READ)
	if savedata == null:
		print("Error: Unable to open file for reading")
		return
	
	var json_string = savedata.get_as_text()
	var json = JSON.new() # Creating an instance of the JSON class
	var parse_result = json.parse(json_string) # Parsing the JSON data
	if parse_result != OK:
		print("Error: Unable to parse JSON data")
		return
	
	var node_data = json.get_data()
	if typeof(node_data) == TYPE_DICTIONARY:
		city = node_data["city"]
		first_time = node_data["first_time"]
		gyors_mod = node_data["gyors_mod"]
	else:
		print("Error: JSON data is not in expected format")


func _set_city(value):
	city = value; save_game()
	CITY_DATA = DATABASE[city]
	set_street_names()
	set_street_nodes()


func load_data(cities: Dictionary) -> Dictionary:
	var output: Dictionary = {}

	for key in cities:
		if FileAccess.file_exists(cities[key][1]):
			var city_name = cities[key][0]
			var city_data = FileAccess.open(cities[key][1], FileAccess.READ)
			var parsed_data = JSON.parse_string(city_data.get_as_text())
			
			if parsed_data is Array:
				output[city_name] = parsed_data
			else:
				print("Error reading file")
		else:
			print("File doesn't exist!")
	return output


func create_strns_node():
	var script: GDScript = load("res://main/strns_node.gd")
	strns_node = VBoxContainer.new()
	strns_node.set_script(script)


func set_street_names() -> void:
	street_names.clear()
	
	for item in CITY_DATA:
		var name_array: Array = []
		name_array.append(item["nev"])
		if item.has("jel"):
			name_array.append(item["jel"])
		street_names.append(name_array)
	# Remove duplicates
	street_names = array_unique(street_names)
	
	var no_accents: Array = []
	var new_names: Array = []
	for name_array in street_names:
		no_accents.append(name_array.duplicate())
	for i in range(street_names.size()):
		no_accents[i][0] = remove_accents(no_accents[i][0])
		if no_accents[i].size() > 1:
			no_accents[i][1] = i
		else:
			no_accents[i].append(i)
	no_accents.sort()
	for i in range(street_names.size()):
		var index: int = no_accents[i][1]
		new_names.append(street_names[index])

	street_names = new_names


func set_street_nodes() -> void:
	for button in strns_node.get_children():
		strns_node.remove_child(button)
		button.queue_free()

	for n in street_names:
		var button: Node = Button.new()
		button.text = n[0]
		if n.size() == 2:
			button.text += " " + n[1]
		button.mouse_filter = 1
		button.connect("pressed", strns_node._on_button_pressed.bind(n))
		strns_node.add_child(button)


func reset_selected() -> void:
	sel_name = []
	sel_iranyito = ""
	sel_hazszam = ""
	debug_str = ""
	res_items.clear()
	resolution = 0


# --------------------------------------------------------------------------------------------------


func number_to_roman(number: int) -> String:
	var result: String = ""
	var values: Array = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
	var numerals: Array = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
	
	var i: int = 0
	while number > 0:
		while number >= values[i]:
			number -= values[i]
			result += numerals[i]
		i += 1
	
	return result


func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique


func remove_accents(input_string: String) -> String:
	var accents = ["á", "é", "í", "ó", "ö", "ő", "ú", "ü", "ű", "Á", "É", "Í", "Ó", "Ö", "Ő", "Ú", "Ü", "Ű"]
	var replacements = ["a", "e", "i", "o", "o", "o", "u", "u", "u", "A", "E", "I", "O", "O", "O", "U", "U", "U"]
	
	var output_string = ""
	for c in input_string:
		var index = accents.find(c)
		if index >= 0:
			output_string += replacements[index]
		else:
			output_string += c
	
	return output_string
