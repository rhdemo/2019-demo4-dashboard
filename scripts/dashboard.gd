extends Node2D

export var mechanic_count = 5
const MECHANIC_OFFSET = 21.5

var ws = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 5 # seconds
#var url = JavaScript.eval("'window.location.hostname'+'/dashboard-socket'") if OS.has_feature('JavaScript') else "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"
var url = "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"

signal add_mechanic
signal dispatch_mechanic
signal update_future_visits
signal remove_mechanic
signal machine_health
signal machine_repair

onready var mechanicNode = preload("res://scenes/mechanic.tscn")
onready var nav : = $Navigation2D
onready var map : = $Navigation2D/TileMap

var path : PoolVector2Array
var goal : Vector2

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
	connect("repairing_machine", self, "_repair_machine")
	$Mechanics.add_child(mechanic, true)
	dispatch_mechanic(data)

func _repair_machine(machineIdx):
	emit_signal("machine_repair", machineIdx)

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
	if res['type'] != "heartbeat":
		if res.type == "optaplanner":
			if res.action == "modify":
				if res.data.value.responseType == "DISPATCH_MECHANIC":
					dispatch_mechanic(res.data)
				if res.data.value.responseType == "UPDATE_FUTURE_VISITS":
					emit_signal("update_future_visits", res.data.value)
			if res.action == "create":
				if res.data.value.responseType == "ADD_MECHANIC":
					add_mechanic(res.data)
			if res.action == "remove":
				emit_signal("remove_mechanic", res.data)
		if res.type == "machine":
			emit_signal("machine_health", res.data)
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
