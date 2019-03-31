extends Node

var ws = null
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT
var retryTimeout = 1 # seconds
const url = "ws://dashboard-web-game-demo.192.168.42.86.nip.io/dashboard-socket"

func _ready():
	self._connect()

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

func _process(delta):
	if ws.get_connection_status() == ws.CONNECTION_CONNECTING || ws.get_connection_status() == ws.CONNECTION_CONNECTED:
		ws.poll()
	if ws.get_peer(1).is_connected_to_host():
		if ws.get_peer(1).get_available_packet_count() > 0 :
			var packet = ws.get_peer(1).get_packet()
			print(decode_data(packet))
			#var test = ws.get_peer(1).get_var()
			#print('receive %s' % JSON.parse(test))

func encode_data(data, mode):
	return data.to_utf8() if mode == WebSocketPeer.WRITE_MODE_TEXT else var2bytes(data)

func decode_data(data):
	return data.get_string_from_utf8()

# Signal handlers

func _on_Node2D_mechanic_arrived(data):
	self.send(data)
