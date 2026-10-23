extends Node
# 音效播放器（全域）。任何地方都能用 SFX.播("jump") 來放音效。
# 音效檔放在 assets/sfx/，想換聲音就換那裡的 .ogg 檔。

var 音效庫 := {
	"jump": preload("res://assets/sfx/jump.ogg"),
	"coin": preload("res://assets/sfx/coin.ogg"),
	"win": preload("res://assets/sfx/win.ogg"),
	"stomp": preload("res://assets/sfx/stomp.ogg"),
	"bounce": preload("res://assets/sfx/bounce.ogg"),
}

func 播(名字: String) -> void:
	if not 音效庫.has(名字):
		return
	var 播放器 := AudioStreamPlayer.new()
	播放器.stream = 音效庫[名字]
	add_child(播放器)
	播放器.play()
	播放器.finished.connect(播放器.queue_free)   # 放完自己刪掉
