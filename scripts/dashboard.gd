extends Node2D

export var mechanic_count = 5

var ws = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 2 # seconds
var url = JavaScript.eval("'window.location.hostname'+'/dashboard-socket'") if OS.has_feature('JavaScript') else "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"
#var url = "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"

#"ws://dashboard-web-game-demo.192.168.42.86.nip.io/dashboard-socket"

# {"type":"machine","data":{"id":"machine-6","value":1000000000000000000}}
# {"type":"optaplanner","data":{"key":"1","value":{"responseType":"DISPATCH_MECHANIC","mechanic":{"mechanicIndex":1,"originalMachineIndex":3,"focusMachineIndex":3,"focusTravelTimeMillis":8358000,"focusFixTimeMillis":8360000,"futureMachineIndexes":[3,2,1,0]}}}}
signal dispatch_mechanic
signal add_mechanic
signal remove_mechanic
signal machine_health

onready var mechanicNode = preload("res://mechanic.tscn")
#onready var machineNode = preload("res://machine.tscn")
onready var nav : = $Navigation2D
onready var map : = $Navigation2D/TileMap

var path : PoolVector2Array
var goal : Vector2
var lineColors = [Color.red, Color.green, Color.blue, Color.orange, Color.purple]
var mechanics = []
var machines = [
	{"name": "machine-1", "coords": Vector2(7,3), "color": Color.yellow},
	{"name": "machine-2", "coords": Vector2(16,-5), "color": Color.green},
	{"name": "machine-c", "coords": Vector2(16, -11), "color": Color.purple},
	{"name": "machine-d", "coords": Vector2(21,-15), "color": Color.pink},
	{"name": "machine-e", "coords": Vector2(22,-5), "color": Color.black},
	{"name": "machine-f", "coords": Vector2(28,-5), "color": Color.maroon},
	{"name": "machine-g", "coords": Vector2(29,1), "color": Color.blue},
	{"name": "machine-h", "coords": Vector2(19,9), "color": Color.lightblue},
	{"name": "machine-i", "coords": Vector2(23,16), "color": Color.orange},
	{"name": "machine-j", "coords": Vector2(15,9), "color": Color.red},
	{"name": "gate", "coords": Vector2(22,14), "color": Color.white}
	]
#var distance_matrix = "";

#func _input(event: InputEvent):
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			goal = event.position
#			path = nav.get_simple_path($Mechanic.position, goal, false)
#			$Line2D.points = PoolVector2Array(path)
#			$Line2D.show()
#			$Mechanic/Sprite/anim.play("walk-up-left")

func _init():
	self._connect()

func _ready():
	set_process(true)
	for i in range(mechanic_count):
		add_mechanic(i)
	#$AddMechanic.connect('pressed', self, "add_mechanic")
	#$GetMatrix.connect('pressed', self, "get_matrix")
#	var pts : PoolVector2Array
	for m in machines:
		var coords = m.coords #map.map_to_world(machines[m].coords)
		coords.y += .5
		m.coords = coords
	#get_matrix()

func get_matrix():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-1", "machine-2", "machine-3", "machine-4", "machine-5", "machine-6", "machine-7", "machine-8", "machine-9", "machine-10", "gate"]
	csv_array.append(headings)
	for pt in machines:
		var ptDist = [pt['name'],map.map_to_world(pt.coords).x, map.map_to_world(pt.coords).y]
		var start = map.map_to_world(pt.coords) #$TileMap.map_to_world(machines[pt]);
		for g in machines:
			var goal = map.map_to_world(g.coords) #$TileMap.map_to_world(machines[g])
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
		csv_array.append(ptDist)
	var prnt = ''
	for ln in csv_array:
		for v in ln:
			prnt += String(v)+", "
		prnt += "\n"
	print(prnt)

func add_mechanic(index):
	var mechanic = mechanicNode.instance()
	var map_pos = map.map_to_world(machines[machines.find("name='gate'")].coords)
	mechanic.position = map_pos
	mechanic.z_index = 5
	mechanic.key = index
	self.add_child(mechanic)
	mechanics.append(mechanic)
#	for pt in machines:
#		var mechanic = mechanicNode.instance()
#		var map_pos = map.map_to_world(machines[pt].coords)
#		map_pos.y += 21.5
#		mechanic.position = map_pos #$Navigation2D/TileMap.map_to_world(nav_points[nav_points.size()-1])
#		mechanic.z_index = 5
#		self.add_child(mechanic)
#		mechanics.append(mechanic)

func _process(delta: float):
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()
#	if !path:
#		$Line2D.hide()
#		return
#	if path.size() > 0:
#		var d: float = $Mechanic.position.distance_to(path[0])
#		if d > 10:
#			$Mechanic.position = $Mechanic.position.linear_interpolate(path[0], (speed * delta)/d)
#		else:
#			path.remove(0)
	
		#ws.poll()

func _connect():
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_handle_data_received")

	print("Connecting to " + url)
	ws.connect_to_url(url)
	
func _handle_data_received():
	var res = JSON.parse(decode_data(ws.get_peer(1).get_packet())).result
	#print(res)
	if res['type'] != "heartbeat":
		if res.type == "optaplanner":
			#print("OPTAPLANNER:",res)
			if res.action == "modify":
				if res.data.value.responseType == "DISPATCH_MECHANIC":
					emit_signal("dispatch_mechanic", res.data.value)
				if res.data.value.responseType == "ADD_MECHANIC":
					emit_signal("add_mechanic", res.data.value)
			if res.action == "remove":
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

#func encode_data(data, mode):
#	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)

func decode_data(data):
	return data.get_string_from_utf8()
