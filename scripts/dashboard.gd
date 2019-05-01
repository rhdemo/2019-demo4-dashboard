extends Node2D

export var mechanic_count = 5
const MECHANIC_OFFSET = 21.5

var ws = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 5 # seconds
var urlStr: String = JavaScript.eval("window.location.hostname+'/dashboard-socket'") if OS.has_feature('JavaScript') else "ws://dashboard-web-game-demo.apps.live.openshift.redhatkeynote.com/dashboard-socket"

var url = urlStr if urlStr.length() > 0 else "ws://dashboard-web-game-demo.apps.live.openshift.redhatkeynote.com/dashboard-socket"

signal add_mechanic
signal dispatch_mechanic
signal update_future_visits
signal remove_mechanic
signal machine_health
signal repairing_machine
signal fixed_machine

onready var mechanicNode = preload("res://scenes/mechanic.tscn")
onready var nav : = $Navigation2D
onready var map : = $Navigation2D/TileMap

var path : PoolVector2Array
var goal : Vector2
var faded = false

func _init():
	self._connect()

func _ready():
	set_process(true)
	print(urlStr)
	#get_matrix()

func _process(delta: float):
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()

func _connect():
	ws.connect("connection_established", self, "_connection_established")
	ws.connect("connection_closed", self, "_connection_closed")
	ws.connect("connection_error", self, "_connection_error")
	ws.connect("data_received", self, "_handle_data_received")

	print("Connecting to " + url)
	ws.connect_to_url(url)
	
func fade(opt):
	$Fader/Fade.remove_all()
	var nodes = [$machines, $boxBelt, $canisterBelt, $static_assets]
	var alpha = 1 if !opt else 0.15
	for node in nodes:
		$Fader/Fade.interpolate_property(node, "modulate:a", null, alpha, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Fader/Fade.start()
	faded = !faded
	
func add_mechanic(data):
	var mechanic = mechanicNode.instance()
	var machine = $machines.get_child(data.value.mechanic.originalMachineIndex)
	var map_pos = machine.repair if machine.get('repair') else machine.position
	if data.value.mechanic.originalMachineIndex == $machines.get_children().size()-1:
		map_pos = $mechanic_spawn.position
	mechanic.position = map_pos
	mechanic.key = data.key
	mechanic.name = "mechanic-%s" % String(data.key)
	mechanic.connect("repairing_machine", self, "_repair_machine")
	mechanic.connect("fixed_machine", self, "_fix_machine")
	$Mechanics.add_child(mechanic, true)
	dispatch_mechanic(data)

func _repair_machine(machineIdx):
	emit_signal("repairing_machine", machineIdx)

func _fix_machine(machineIdx):
	emit_signal("fixed_machine", machineIdx)

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
			faded = res.data.dashboardTransparent
			fade(faded)
			#pass # res.data.state = active, paused, lobby, stopped

func _connection_established(protocol):
	ws.get_peer(1).set_write_mode(_write_mode)
	send('{"type":"init"}')
	print("Connection established with protocol: ", protocol)

func _connection_closed(clean):
	print("Connection closed, retrying in %ds" % retryTimeout)
	$connection.start()

func _connection_error():
	print("Connection error, retrying in %ds" % retryTimeout)
	$connection.start()

func send(data):
	ws.get_peer(1).set_write_mode(_write_mode)
	ws.get_peer(1).put_packet(data.to_utf8())

func get_matrix():
	var csv_array = []
	var headings = ["machine name", "x", "y", "machine-0", "machine-1", "machine-2", "machine-3", "machine-4", "machine-5", "machine-6", "machine-7", "machine-8", "machine-9", "gate"]
	csv_array.append(headings)
	for pt in $machines.get_children():
		var start = pt.get('repair') if pt.get('repair') else pt.position
		var ptDist = [pt['name'],start.x, start.y]
		for g in $machines.get_children():
			var goal = g.get('repair') if g.get('repair') else g.position
			var dist = 0
			var pth = nav.get_simple_path(start, goal)
			if start != goal:
				if pth.size() > 0:
					var strt = pth[0]
					for wp in pth:
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

#func encode_data(data, mode):
#	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)
	
func decode_data(data):
	return data.get_string_from_utf8()

func _on_connection_timeout():
	$connection.wait_time *= 2
	self._connect()


func _on_Fader_mouse_entered():
	fade(!faded)