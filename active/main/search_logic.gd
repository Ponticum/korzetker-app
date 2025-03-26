extends Node

var results: Array = []
var bad_pir: bool = false
var bad_hsz: bool = false

# --------------------------------------------------------------------------------------------------


func search() -> void:
	# Start with zero
	G.debug_str = ""
	results.clear()
	bad_pir = false
	bad_hsz = false
	
	# Make variables
	var sel_nev = G.sel_name[0]
	var sel_jel = ""
	if G.sel_name.size() == 2:
		sel_jel = G.sel_name[1]
	var sel_pir = int(G.sel_iranyito)
	var sel_hsz = get_user_hsz(G.sel_hazszam)
	
	# Initial debug
	G.debug_str += "- city: " + G.city + " - " + ProjectSettings.get_setting("application/config/version") + " (2024-ÖK)\n"
	G.debug_str += "- Searching for '" + sel_nev + "' + '" + sel_jel + "'\n"
	G.debug_str += "  (pir = " + str(sel_pir) + ") (hsz = " + G.sel_hazszam + ") -> " + str(sel_hsz) + "\n"
	# Search for nev and jel
	for item in G.CITY_DATA:
		if item["nev"] == sel_nev:
			if sel_jel == "":
				if not item.has("jel"):
					results.append(item)
			else:
				if item["jel"] == sel_jel:
					results.append(item)
	G.debug_str += "- Found " + str(results.size()) + " items\n"
	
	G.debug_str += "- Filtering by PIR\n"
	var initial_size = results.size()
	var index_1 = results.size() - 1
	while index_1 >= 0:
		if results[index_1]["pir"] != sel_pir:
			results.remove_at(index_1)
		index_1 -= 1
	if initial_size > 0 and results.size() == 0:
		bad_pir = true
	G.debug_str += "    done - " + str(results.size()) + " items\n"
	
	G.debug_str += "- Filtering by HSZ\n"
	initial_size = results.size()
	var proc_hsz_nums: Array = []
	for item in results:
		if item.has("hsz"):
			proc_hsz_nums.append(item["hsz"])
		else:
			proc_hsz_nums.append("")
	for i in range(proc_hsz_nums.size()):
		proc_hsz_nums[i] = processed_hsz(proc_hsz_nums[i])
	G.debug_str += "    hsz processed\n"
	var int_results: Array = []
	var flo_results: Array = []
	var index_2 = results.size() - 1
	while index_2 >= 0:
		
		if not sel_hsz in proc_hsz_nums[index_2]:
			if not is_equal_approx(sel_hsz, roundf(sel_hsz)):
				var int_hsz = float(int(sel_hsz))
				if int_hsz in proc_hsz_nums[index_2]:
					int_results.append(results[index_2])
			else:
				var flo_hsz = [sel_hsz + 0.01, sel_hsz + 0.02, sel_hsz + 0.03]
				for hsz in flo_hsz:
					if hsz in proc_hsz_nums[index_2]:
						flo_results.append(results[index_2])
			
			results.remove_at(index_2)
		index_2 -= 1
	if initial_size > 0 and (results.size() + int_results.size() + flo_results.size()) == 0:
		bad_hsz = true
	G.debug_str += "    done - " + str(results.size()) + " items\n"
	
	if results.size() == 0:
		if int_results.size() != 0:
			G.debug_str += "    int_results found\n"
		for item in int_results:
			results.append(item)
		if flo_results.size() != 0:
			G.debug_str += "    flo_results found\n"
		for item in flo_results:
			results.append(item)
	
	# Getting the results
	if results.size() == 1:
		G.resolution = G.ONE_RES; G.debug_str += "✔️ Only one result remains\n"
	elif results.size() > 1:
		var same_korzet: bool = true
		for item in results:
			if item["ker"] != results[0]["ker"]:
				same_korzet = false
		match same_korzet:
			true:
				G.resolution = G.MORE_SAME
				G.debug_str += "✔️ More results but 'TEVK' is same\n"
			false:
				G.resolution = G.MORE_DIFF
				G.debug_str += "❌ More results and 'TEVK' is different\n"
	else: # results.size() == 0
		if bad_pir == true:
			G.resolution = G.BAD_PIR
		elif bad_hsz == true:
			G.resolution = G.BAD_HSZ
		else:
			G.resolution = G.NO_RES
		G.debug_str += "❌ No result found\n"
	
	# Saving the results
	G.res_items = results


# --------------------------------------------------------------------------------------------------


func processed_hsz(input_str: String) -> Array:
	if input_str == "":
		return [0.0]
	var output: Array = []
	# Remove any non-alpha characters
	var cleaned_input = input_str.strip_edges()
	
	# Check if the string contains a hyphen
	if "-" in cleaned_input:
		output = cleaned_input.split("-")
	else:
		output.append(cleaned_input)
	
	# Check if the string contains a slash
	for i in range(output.size()):
		if "/" in output[i]:
			var parts = output[i].split("/")
			if parts.size() == 2:
				var integ_part = int(parts[0])
				var fract_part = lett_to_num(parts[1])
				output[i] = integ_part + fract_part
		else:
			output[i] = float(output[i])
	return output


func get_user_hsz(input_str: String) -> float:
	var split_array = split_hsz_string(input_str)
	var output: float = float(split_array[0])
	if split_array[1] != "":
		output += lett_to_num(split_array[1])
	return output


func split_hsz_string(input_str: String) -> Array:
	var pattern = "^(.*?)([a-zA-Z].*)$"
	var regex = RegEx.new()
	regex.compile(pattern)
	
	var mat = regex.search(input_str)
	if mat:
		var non_alpha = mat.get_string(1)
		var alpha_and_rem = mat.get_string(2)
		
		return [non_alpha, alpha_and_rem]
	return [input_str, ""]  # If no alphabetic character found


func lett_to_num(lett: String) -> float:
	match lett:
		"A", "a": return 0.01
		"B", "b": return 0.02
		"C", "c": return 0.03
		"D", "d": return 0.04
		"E", "e": return 0.05
		"F", "f": return 0.06
		"G", "g": return 0.07
		"H", "h": return 0.08
		"I", "i": return 0.09
		"J", "j": return 0.10
		"K", "k": return 0.11
		"L", "l": return 0.12
		"M", "m": return 0.13
		"N", "n": return 0.14
		"O", "o": return 0.15
		"P", "p": return 0.16
		"Q", "q": return 0.17
		"R", "r": return 0.18
		"S", "s": return 0.19
		"T", "t": return 0.20
		"U", "u": return 0.21
		"V", "v": return 0.22
		"W", "w": return 0.23
		"X", "x": return 0.24
		"Y", "y": return 0.25
		"Z", "z": return 0.26
		_: return 0.0
