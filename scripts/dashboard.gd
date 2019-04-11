extends Node2D

export var mechanic_count = 5
const MECHANIC_OFFSET = 21.5

var ws = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 2 # seconds
#var url = JavaScript.eval("'window.location.hostname'+'/dashboard-socket'") if OS.has_feature('JavaScript') else "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"
var url = "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"

#"ws://dashboard-web-game-demo.192.168.42.86.nip.io/dashboard-socket"

# {"type":"machine","data":{"id":"machine-6","value":1000000000000000000}}
# {"type":"optaplanner","data":{"key":"1","value":{"responseType":"DISPATCH_MECHANIC","mechanic":{"mechanicIndex":1,"originalMachineIndex":3,"focusMachineIndex":3,"focusTravelTimeMillis":8358000,"focusFixTimeMillis":8360000,"futureMachineIndexes":[3,2,1,0]}}}}
signal dispatch_mechanic
signal add_mechanic
signal remove_mechanic
signal machine_health
signal update_future_visits

onready var mechanicNode = preload("res://mechanic.tscn")
#onready var machineNode = preload("res://machine.tscn")
onready var nav : = $Navigation2D
onready var map : = $Navigation2D/TileMap

var path : PoolVector2Array
var goal : Vector2
var lineColors = [Color.red, Color.green, Color.blue, Color.orange, Color.purple]
var mechanics = []
var machines = [
	{"name": "machine-0", "coords": Vector2(180,290), "color": Color.yellow},
	{"name": "machine-1", "coords": Vector2(945,320), "color": Color.green},
	{"name": "machine-2", "coords": Vector2(1215,160), "color": Color.purple},
	{"name": "machine-3", "coords": Vector2(1620,180), "color": Color.pink},
	{"name": "machine-4", "coords": Vector2(1200,454), "color": Color.black},
	{"name": "machine-5", "coords": Vector2(1500,630), "color": Color.maroon},
	{"name": "machine-6", "coords": Vector2(1280,810), "color": Color.blue},
	{"name": "machine-7", "coords": Vector2(405,725), "color": Color.lightblue},
	{"name": "machine-8", "coords": Vector2(315,1035), "color": Color.orange},
	{"name": "machine-9", "coords": Vector2(270,624), "color": Color.red},
	{"name": "gate", "coords": Vector2(360,936), "color": Color.white}
	]

func _init():
	self._connect()

func _ready():
	set_process(true)
	$static_assets/toLeaderBoard/leaderboardBtn.connect("pressed", self, "show_leaderboard")
	for i in range(mechanic_count):
		add_mechanic(i)
	for m in machines:
		$MachineLine.add_point(m.coords)
	#get_matrix()

func _process(delta: float):
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()
	$MachineLine.hide()
	$MachineLine.points = []
	for m in machines:
		$MachineLine.add_point(m.coords)

func _connect():
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_handle_data_received")

	print("Connecting to " + url)
	ws.connect_to_url(url)
	
func get_matrix():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-0", "machine-1", "machine-2", "machine-3", "machine-4", "machine-5", "machine-6", "machine-7", "machine-8", "machine-9", "gate"]
	csv_array.append(headings)
	for pt in machines:
		var ptDist = [pt['name'],pt.coords.x, pt.coords.y]
		var start = pt.coords #$TileMap.map_to_world(machines[pt]);
		start.y += MECHANIC_OFFSET
		for g in machines:
			var goal = g.coords #$TileMap.map_to_world(machines[g])
			goal.y += MECHANIC_OFFSET
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
	var map_pos = machines[machines.find("name='gate'")].coords
	mechanic.position = map_pos
	mechanic.z_index = 5
	mechanic.key = index
	self.add_child(mechanic)
	mechanics.append(mechanic)


func _handle_data_received():
	var res = JSON.parse(decode_data(ws.get_peer(1).get_packet())).result
	#print(res)
	if res['type'] != "heartbeat":
		if res.type == "optaplanner":
			#print("OPTAPLANNER:",res)
			if res.action == "modify":
				if res.data.value.responseType == "DISPATCH_MECHANIC":
					emit_signal("dispatch_mechanic", res.data.value)
				if res.data.value.responseType == "UPDATE_FUTURE_VISITS":
					emit_signal("update_future_visits", res.data.value)
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
func show_leaderboard():
	#print("CLICKED")
	get_tree().change_scene("res://leaderboard.tscn")
	
func decode_data(data):
	return data.get_string_from_utf8()
