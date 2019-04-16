extends Node2D

export var mechanic_count = 5
const MECHANIC_OFFSET = 21.5

var ws = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 5 # seconds
#var url = JavaScript.eval("'window.location.hostname'+'/dashboard-socket'") if OS.has_feature('JavaScript') else "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"
var url = "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"

#"ws://dashboard-web-game-demo.192.168.42.86.nip.io/dashboard-socket"

# {"type":"machine","data":{"id":"machine-6","value":1000000000000000000}}
# {"type":"optaplanner","data":{"key":"1","value":{"responseType":"DISPATCH_MECHANIC","mechanic":{"mechanicIndex":1,"originalMachineIndex":3,"focusMachineIndex":3,"focusTravelTimeMillis":8358000,"focusFixTimeMillis":8360000,"futureMachineIndexes":[3,2,1,0]}}}}
signal add_mechanic
signal dispatch_mechanic
signal update_future_visits
signal remove_mechanic
signal machine_health


onready var mechanicNode = preload("res://scenes/mechanic.tscn")
#onready var machineNode = preload("res://machine.tscn")
onready var nav : = $Navigation2D
onready var map : = $Navigation2D/TileMap

var path : PoolVector2Array
var goal : Vector2
#var machines = [
#	{"name": "machine-0", "label": "A", "coords": Vector2(180,290), "color": Color.yellow, "distances": []},
#	{"name": "machine-1", "label": "B", "coords": Vector2(945,320), "color": Color.green, "distances": []},
#	{"name": "machine-2", "label": "C", "coords": Vector2(1215,160), "color": Color.purple, "distances": []},
#	{"name": "machine-3", "label": "D", "coords": Vector2(1620,180), "color": Color.pink, "distances": []},
#	{"name": "machine-4", "label": "E", "coords": Vector2(1200,454), "color": Color.black, "distances": []},
#	{"name": "machine-5", "label": "F", "coords": Vector2(1500,630), "color": Color.maroon, "distances": []},
#	{"name": "machine-6", "label": "G", "coords": Vector2(1280,810), "color": Color.blue, "distances": []},
#	{"name": "machine-7", "label": "H", "coords": Vector2(405,725), "color": Color.lightblue, "distances": []},
#	{"name": "machine-8", "label": "I", "coords": Vector2(200,1050), "color": Color.orange, "distances": []},
#	{"name": "machine-9", "label": "J", "coords": Vector2(210,610), "color": Color.red, "distances": []},
#	{"name": "gate", "label": "", "coords": Vector2(320,936), "color": Color.white, "distances": []}
#	]

func _init():
	self._connect()

func _ready():
	set_process(true)
	for m in $machines.get_children():
		$MachineLine.add_point(m.heal_coords if m.get('heal_coords') else m.position)
	#get_matrix()

func _process(delta: float):
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()
	$MachineLine.points = []
	for m in $machines.get_children():
		$MachineLine.add_point(m.heal_coords if m.get('heal_coords') else m.position )
	#$MachineLine.show()

func _connect():
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_handle_data_received")

	print("Connecting to " + url)
	ws.connect_to_url(url)
	
func add_mechanic(data):
	var mechanic = mechanicNode.instance()
	var machine = $machines.get_child(data.value.mechanic.originalMachineIndex)
	var map_pos = machine.heal_coords if machine.get('heal_coords') else machine.position
	if data.value.mechanic.originalMachineIndex == $machines.get_children().size()-1:
		map_pos = $mechanic_spawn.position
	mechanic.position = map_pos
	mechanic.key = data.key
	mechanic.name = "mechanic-%s" % String(data.key)
	$Mechanics.add_child(mechanic, true)
	#print("ADD: ", data)
	dispatch_mechanic(data)
	

func dispatch_mechanic(data):
	var mechExists = false
	for m in $Mechanics.get_children():
		if String(m.key) == String(data.key):
			mechExists = true
	if !mechExists:
		add_mechanic(data)
	emit_signal("dispatch_mechanic", data)

func _handle_data_received():
	var res = JSON.parse(decode_data(ws.get_peer(1).get_packet())).result
	#print(res)
	if res['type'] != "heartbeat":
		if res.type == "optaplanner":
			#print(res)
			#print("OPTAPLANNER:",res)
			if res.action == "modify":
				if res.data.value.responseType == "DISPATCH_MECHANIC":
					#print(res.data)
					dispatch_mechanic(res.data)
				if res.data.value.responseType == "UPDATE_FUTURE_VISITS":
					#print(res.data)
					emit_signal("update_future_visits", res.data.value)
			if res.action == "create":
				if res.data.value.responseType == "ADD_MECHANIC":
					add_mechanic(res.data)
			if res.action == "remove":
				#print(res)
				emit_signal("remove_mechanic", res.data)
		if res.type == "machine":
			emit_signal("machine_health", res.data)
			#print("MACHINE:",res) # res.data = {id:machine-#, value:100000000}
		if res.type == "game":
			pass # res.data.state = active, paused, lobby, stopped

func _connection_established(protocol):
	ws.get_peer(1).set_write_mode(_write_mode)
	send('{"type":"init"}')
	print("Connection established with protocol: ", protocol)

func _connection_closed():
	print("Connection closed, retrying in %ds" % retryTimeout)
	yield(get_tree().create_timer(retryTimeout), "timeout")
	retryTimeout *= 2
	self._connect()

func _connection_error():
	print("Connection error, retrying in %ds" % retryTimeout)
	yield(get_tree().create_timer(retryTimeout), "timeout")
	retryTimeout *= 2
	self._connect()

func send(data):
	ws.get_peer(1).set_write_mode(_write_mode)
	ws.get_peer(1).put_packet(data.to_utf8())

func get_matrix():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-0", "machine-1", "machine-2", "machine-3", "machine-4", "machine-5", "machine-6", "machine-7", "machine-8", "machine-9", "gate"]
	csv_array.append(headings)
	for pt in $machines.get_children():
		var coords = pt.heal_coords if pt.get('heal_coords') else pt.position
		var ptDist = [pt['name'],coords.x, coords.y]
		var start = coords #$TileMap.map_to_world(machines[pt]);
		start.y += MECHANIC_OFFSET
		for g in $machines.get_children():
			var gcoords = g.heal_coords if g.get('heal_coords') else g.position
			var goal = gcoords #$TileMap.map_to_world(machines[g])
			var dist = 0
			var pth = nav.get_simple_path(start, goal)
			if start != goal:
				if pth.size() > 0:
					var strt = pth[0] #map.map_to_world(pth[0])
					for wp in pth:
						#wp = map.map_to_world(wp)
						var diff = strt.distance_to(wp)
						dist += diff
						strt = wp
			ptDist.append(dist)
#			if pt.get('distances'):
#				pt.distances.append(dist)
#			else:
#				pt.set('distances', [dist])
		csv_array.append(ptDist)
	var prnt = ''
	for ln in csv_array:
		for v in ln:
			prnt += String(v)+", "
		prnt += "\n"
	print(prnt)

#func encode_data(data, mode):
#	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)
	
func decode_data(data):
	return data.get_string_from_utf8()
