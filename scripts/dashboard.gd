extends Node2D

var ws = null
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 5 # seconds
const url = "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket" #"ws://dashboard-web-game-demo.192.168.42.86.nip.io/dashboard-socket"

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


var lines = []
var path : PoolVector2Array
var goal : Vector2
export var speed := 250
var mechanics = []
var machines = {
	"machine-1": { "coords": Vector2(7,3), "color": Color.yellow},
	"machine-2": { "coords": Vector2(16,-6), "color": Color.green},
	"machine-3": { "coords": Vector2(16, -11), "color": Color.purple},
	"machine-4": { "coords": Vector2(22,-17), "color": Color.pink},
	"machine-5": { "coords": Vector2(22,-6), "color": Color.black},
	"machine-6": { "coords": Vector2(28,-6), "color": Color.maroon},
	"machine-7": { "coords": Vector2(29,1), "color": Color.blue},
	"machine-8": { "coords": Vector2(19,9), "color": Color.lightblue},
	"machine-9": { "coords": Vector2(23,16), "color": Color.orange},
	"machine-10": { "coords": Vector2(13,9), "color": Color.red},
	"gate": { "coords": Vector2(20,14), "color": Color.white}
	}
#var distance_matrix = "";

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			goal = event.position
			path = nav.get_simple_path($Mechanic.position, goal, false)
			$Line2D.points = PoolVector2Array(path)
			$Line2D.show()

func _ready():
	self._connect()
	$AddMechanic.connect('pressed', self, "add_mechanic")
	$GetMatrix.connect('pressed', self, "get_matrix")
#	var pts : PoolVector2Array
	for m in machines:
		var coords = machines[m].coords #map.map_to_world(machines[m].coords)
		coords.y += .5
		machines[m].coords = coords

func get_matrix():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-1", "machine-2", "machine-3", "machine-4", "machine-5", "machine-6", "machine-7", "machine-8", "machine-9", "machine-10", "gate"]
	csv_array.append(headings)
	for pt in machines:
		var ptDist = [pt,map.map_to_world(machines[pt].coords).x, map.map_to_world(machines[pt].coords).y]
		var start = map.map_to_world(machines[pt].coords) #$TileMap.map_to_world(machines[pt]);
		for g in machines:
			var goal = map.map_to_world(machines[g].coords) #$TileMap.map_to_world(machines[g])
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

func add_mechanic():
	for pt in machines:
		var mechanic = mechanicNode.instance()
		var map_pos = map.map_to_world(machines[pt].coords)
		map_pos.y += 21.5
		mechanic.position = map_pos #$Navigation2D/TileMap.map_to_world(nav_points[nav_points.size()-1])
		self.add_child(mechanic)
		mechanics.append(mechanic)

func _process(delta: float) -> void:
	if !path:
		$Line2D.hide()
		return
	if path.size() > 0:
		var d: float = $Mechanic.position.distance_to(path[0])
		if d > 10:
			$Mechanic.position = $Mechanic.position.linear_interpolate(path[0], (speed * delta)/d)
		else:
			path.remove(0)
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()
	if ws.get_peer(1).is_connected_to_host():
		if ws.get_peer(1).get_available_packet_count() > 0 :
			var packet = ws.get_peer(1).get_packet()
			var res = JSON.parse(decode_data(packet)).result
			if res['type'] == "optaplanner":
				print(res['data'])
			#var test = ws.get_peer(1).get_var()
			#print('receive %s' % JSON.parse(test))

func _connect():
	ws = WebSocketClient.new()
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")

	print("Connecting to " + url)
	ws.connect_to_url(url)

func _connection_established(protocol):
	ws.get_peer(1).set_write_mode(_write_mode)
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
	ws.get_peer(1).put_packet(encode_data(data, _write_mode))

func encode_data(data, mode):
	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)

func decode_data(data):
	return data.get_string_from_utf8()
