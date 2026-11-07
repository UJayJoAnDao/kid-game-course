extends Node
# 音效播放器（全域）。任何地方都能用 SFX.播("hit") 來放音效。

var 音效庫 := {
	"hit": preload("res://assets/sfx/stomp.ogg"),     # 普攻打中
	"heavy": preload("res://assets/sfx/bounce.ogg"),  # 重擊打中
	"jump": preload("res://assets/sfx/jump.ogg"),     # 跳
	"ko": preload("res://assets/sfx/coin.ogg"),       # 被打飛出場
	"win": preload("res://assets/sfx/win.ogg"),       # 分出勝負
}

func 播(名字: String) -> void:
	if not 音效庫.has(名字):
		return
	var 播放器 := AudioStreamPlayer.new()
	播放器.stream = 音效庫[名字]
	add_child(播放器)
	播放器.play()
	播放器.finished.connect(播放器.queue_free)
