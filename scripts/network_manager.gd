extends Node

var peer: ENetMultiplayerPeer
var ip_address := "127.0.0.1"
var port := 35353

func host_game():
	print("Hosting a game on port %s" % port)
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error:
		print("Failed to create a server: %s" % error_string(error))
		return false
	multiplayer.multiplayer_peer = peer
	return true

func join_game():
	print("Joining %s:%s" % [ip_address, port])
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip_address, port)
	if error:
		print("Failed to connect: %s" % error_string(error))
		return false
	multiplayer.multiplayer_peer = peer
	return true
