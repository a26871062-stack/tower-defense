extends Node

var _sfx_players: Array = []
var _bgm_player: AudioStreamPlayer
var _sfx_volume: float = 0.0
var _bgm_volume: float = -10.0

var _sfx_paths: Dictionary = {
	"arrow_attack": "res://audio/sfx/arrow_attack.wav",
	"mage_attack": "res://audio/sfx/mage_attack.wav",
	"cannon_attack": "res://audio/sfx/cannon_attack.wav",
	"enemy_death": "res://audio/sfx/enemy_death.wav",
	"coin": "res://audio/sfx/coin.wav",
	"upgrade": "res://audio/sfx/upgrade.wav",
	"sell": "res://audio/sfx/sell.wav",
	"wave_start": "res://audio/sfx/wave_start.wav",
	"game_over": "res://audio/sfx/game_over.wav",
}

var _sfx_cache: Dictionary = {}

func _ready():
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Master"
	add_child(_bgm_player)
	_preload_sfx()

func _preload_sfx():
	for name in _sfx_paths:
		var path = _sfx_paths[name]
		if ResourceLoader.exists(path):
			_sfx_cache[name] = load(path)

func play_sfx(name: String):
	if not _sfx_cache.has(name):
		return
	var player = AudioStreamPlayer.new()
	player.stream = _sfx_cache[name]
	player.bus = "Master"
	add_child(player)
	_sfx_players.append(player)
	player.play()
	player.finished.connect(_on_sfx_finished.bind(player))

func _on_sfx_finished(player: AudioStreamPlayer):
	if player in _sfx_players:
		_sfx_players.erase(player)
	player.queue_free()

func play_bgm(name: String):
	var path = "res://audio/music/" + name + ".wav"
	if not ResourceLoader.exists(path):
		return
	_bgm_player.stream = load(path)
	_bgm_player.play()

func stop_bgm():
	_bgm_player.stop()

func set_sfx_volume(vol: float):
	_sfx_volume = vol

func set_bgm_volume(vol: float):
	_bgm_volume = vol
	_bgm_player.volume_db = vol
