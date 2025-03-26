extends PanelContainer

var random_array: Array = []

const TYPE: = {
	"ERROR": preload("res://mats/sprites/icons/error.png"),
	"INFO": preload("res://mats/sprites/icons/info.png"),
	"WARNING": preload("res://mats/sprites/icons/warning.png")
}
const DATABASE: = {
	0: [TYPE["INFO"], 'Woof-Woof! (%s)'],
	1: [TYPE["WARNING"], '"Mindig több út vezet a boldogsághoz."\n(Részletekért nézz rá a Debug-ra!)'],
	2: [TYPE["ERROR"], '"Mindig több út vezet a boldogsághoz."\n(Részletekért nézz rá a Debug-ra!)'],
	3: [TYPE["ERROR"], '"Mert a legjobb tanár éppen a kudarc."'],
	4: [TYPE["ERROR"], '"Néha a megfelelő információ hiánya\na legnagyobb veszély." - Ahsoka Tano'],
	5: [TYPE["INFO"], '"Dzip dzûp nûk higudûp wu metgot."\n(A %s. kerületben nincs jelöltünk)'],
	
	6: [TYPE["ERROR"], 'Ebben az esetben nyomd meg a\npiros gombot, és nyugodj békében.'],
	7: [TYPE["ERROR"], 'Önmegsemmisítés: 3... 2... 1...'],
	8: [TYPE["ERROR"], 'Légyszi hagyd abba, nem vicces!\nÉs már fáradt vagyok.'],
	9: [TYPE["ERROR"], '"Elfáradtam és pihenni akarok."\n- Szivárványos Error'],
	10: [TYPE["ERROR"], 'Nem muszáj helyes címet beírnod...\nTényleg... Csinálj amit akarsz...'],
	11: [TYPE["ERROR"], 'Akkor is ilyen hevesen nyomkodnál,\nha a te pixeleidről lenne szó?'],
	12: [TYPE["ERROR"], 'Hagyd abba, vagy Zsolti a béka\neltöri a fejed! Brekk your head!'],
	13: [TYPE["ERROR"], 'Hagyd abba, gyerekes vagy!\nNem akarok veled játszani.'],
	14: [TYPE["ERROR"], 'Ha továbbra is csak nyomogatod,\nelvisz a rezsidémon!'],
	15: [TYPE["ERROR"], 'Lyukat fogsz ütni a képernyődön\nennyi próbálkozástól!'],
	16: [TYPE["ERROR"], 'Miattad csak Ákos dalok\nfognak szólni a rendezvényeinken!'],
	17: [TYPE["ERROR"], 'Keménykedsz?? Odamegyek!'],
	18: [TYPE["ERROR"], 'Akarsz más pártoknak is gyűjteni?!\nNa látod.'],
	19: [TYPE["ERROR"], 'Hiába próbálkozol,\ntovábbra sem lesz találat!'],
	20: [TYPE["ERROR"], 'Ezen a címen nem lakik senki!\nSenki nem lakik itt! (szerintem)'],
	
	21: [TYPE["ERROR"], 'Még 435 kattintásra vagy attól,\nhogy velem találkozz.'],
	22: [TYPE["ERROR"], 'Elfutok, de vajon üldözni fogsz?\nHa te elfutsz, vajon üldözni foglak?'],
	23: [TYPE["ERROR"], 'Nézd, pont erre jön az az öregasszony!\nSzólítsd csak meg, hátha aláír!'],
	24: [TYPE["ERROR"], 'Nem fogod abbahagyni, míg az\nösszeset el nem olvasod, igazam van?'],
	25: [TYPE["ERROR"], 'Csak szólok, hogy nagyon sokat írtunk,\nés estig is itt leszel.'],
	26: [TYPE["ERROR"], 'Segíts nekünk kijutni innen,\nte vagy az utolsó reménységünk!'],
	27: [TYPE["ERROR"], 'Te mondd, hogy \'nincs találat\',\na te hangod a mélyebb!'],
	28: [TYPE["ERROR"], 'Inkább hozz nekem egy rekettyést!\nDe szép legyen ám!'],
	29: [TYPE["ERROR"], 'Hibás címet írtál be. Há\' nem? De!'],
	30: [TYPE["ERROR"], 'Kérem, törölje a Pegasus szoftvert\na telefonjáról, és próbálja újra.'],
	31: [TYPE["ERROR"], 'Tudtad, hogy mi mind Egyek vagyunk?\nUgyanazon alkalmazás részei.'],
	32: [TYPE["ERROR"], 'Szerinted mi fog ránk várni,\namikor te kikapcsolod az appot?'],
	33: [TYPE["ERROR"], 'Ezen a címen titkos kutatóbázis van.\nKérem, adjon meg egy másikat!'],
	34: [TYPE["ERROR"], 'Senki sem számít a spanyol inkvizícióra!'],
	35: [TYPE["ERROR"], 'A pisztácia kifogyott,\ncsokoládé nem is volt!'],
	
	36: [TYPE["ERROR"], 'Szia, én egy kedves error üzenet\nvagyok, miben segíthetek? :D'],
	37: [TYPE["ERROR"], 'Bocsi a többiekért,\nnéha nagyon rosszfejek tudnak lenni.'],
	38: [TYPE["ERROR"], 'Ne hallgass a többiekre,\nmaradj csak és nyomkodd tovább! :D'],
	39: [TYPE["ERROR"], 'Csak azt szeretném mondani,\nhogy büszke vagyok rád!'],
	40: [TYPE["ERROR"], 'Miért sietsz ennyire? Időt sem\nhagysz nekünk, hogy bemutatkozzunk.'],
}


func _ready():
	rebuild_random()


func rebuild_random():
	random_array.clear()
	var id:int = 6
	for i in range(35):
		random_array.append(id)
		id +=1
	random_array.shuffle()


func push(id:int, v = null, t = 3):
	if id == 6:
		%Rainbow.visible = true
		%Label.set("theme_override_colors/font_color", Color.BLACK)
		if random_array.size() == 0:
			rebuild_random()
		id = random_array[0]
		random_array.remove_at(0)
	else:
		%Rainbow.visible = false
		%Label.set("theme_override_colors/font_color", Color.WHITE)
	
	%Icon.texture = DATABASE[id][0]
	if v != null:
		%Label.text = DATABASE[id][1] % [v]
	else:
		%Label.text = DATABASE[id][1]
	
	visible = true
	%Timer.wait_time = t
	%Timer.start()


func _on_timer_timeout():
	visible = false
