extends Node

var peer = null

func host_game(port: int=12345):
	print("Hosting a game on port %s" % port)
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error:
		print("Failed to create a server: %s" % error_string(error))
		return false
	multiplayer.multiplayer_peer = peer
	return true


func join_game(address: String, port := 12345):
	print("Joining %s:%s" % [address, port])
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		print("Failed to connect: %s" % error_string(error))
		return false
	multiplayer.multiplayer_peer = peer
	return true
