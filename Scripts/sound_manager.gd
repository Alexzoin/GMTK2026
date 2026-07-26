extends Node

func play(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.finished.connect(player.queue_free)
	add_child(player)
	player.bus = "SFX"
	player.play()
