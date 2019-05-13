extends Node

var ws = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 5 # seconds
#var url = JavaScript.eval("'window.location.hostname'+'/dashboard-socket'") if OS.has_feature('JavaScript') else "ws://dashboard-web-game-demo.apps.dev.openshift.redhatkeynote.com/dashboard-socket"
var url = "ws://optaplanner-demo-optaplanner-demo.apps.dev.openshift.redhatkeynote.com/roster-websocket"

func _init():
	self._connect()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	#print('SUBSCRIBE\nid:sub-0\ndestination:/topic/roster\n\n')

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

func _connection_established(protocol):
	ws.get_peer(1).set_write_mode(_write_mode)
	send('[SUBSCRIBE\nid:sub-0\ndestination:/topic/roster\n\n\u0000]')
	print("Connection established with protocol: ", protocol)

func _connection_closed():
	print("Connection closed, retrying in %ds" % $optaplanner_connection.wait_time)
	$optaplanner_connection.start()

func _connection_error():
	print("Connection error, retrying in %ds" % $optaplanner_connection.wait_time)
	$optaplanner_connection.start()

func _handle_data_received():
	var res = JSON.parse(decode_data(ws.get_peer(1).get_packet())).result
	print(res)

func send(data):
	ws.get_peer(1).set_write_mode(_write_mode)
	ws.get_peer(1).put_packet(data.to_utf8())

#func encode_data(data, mode):
#	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)
	
func decode_data(data):
	return data.get_string_from_utf8()

func _on_optaplanner_connection_timeout():
	$optaplanner_connection.wait_time *= 2
	self._connect()
