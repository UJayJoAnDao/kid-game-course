extends Node
# 音效播放器（全域）。任何地方都能用 SFX.播("普攻") 來放音效。
#
# 🔊 想換成自己的音效？
#   把音效檔放進 assets/sfx/我的音效/ ，檔名取成下面「音效名字」其中一個，
#   例如「普攻.wav」「必殺.mp3」「KO.ogg」，遊戲就會改放你的。
#   找不到你的，才會放 assets/sfx/預設/ 裡面的預設音效。

const 我的資料夾 := "res://assets/sfx/我的音效/"
const 預設資料夾 := "res://assets/sfx/預設/"
const 音效名字 := ["普攻", "重擊", "上挑", "下劈", "衝刺斬", "跳", "必殺", "KO", "倒數", "開打", "勝利", "背景音樂"]

var 音效庫 := {}
var 背景播放器: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for 名字 in 音效名字:
		音效庫[名字] = 找音效(名字)
	背景播放器 = AudioStreamPlayer.new()
	背景播放器.volume_db = -8.0
	add_child(背景播放器)

func 找音效(名字: String) -> AudioStream:
	for 副檔名 in ["wav", "ogg", "mp3"]:
		var 路徑: String = 我的資料夾 + 名字 + "." + 副檔名
		if ResourceLoader.exists(路徑):
			print("🔊 使用你的音效：", 路徑)
			return load(路徑)
	var 預設: String = 預設資料夾 + 名字 + ".wav"
	if ResourceLoader.exists(預設):
		return load(預設)
	return null

func 播(名字: String) -> void:
	var 聲音: AudioStream = 音效庫.get(名字)
	if 聲音 == null:
		return
	var 播放器 := AudioStreamPlayer.new()
	播放器.stream = 聲音
	add_child(播放器)
	播放器.play()
	播放器.finished.connect(播放器.queue_free)

func 放背景音樂() -> void:
	var 音樂: AudioStream = 音效庫.get("背景音樂")
	if 音樂 == null or 背景播放器.playing:
		return
	if 音樂 is AudioStreamWAV:
		音樂.loop_mode = AudioStreamWAV.LOOP_FORWARD
		音樂.loop_end = int(音樂.get_length() * 音樂.mix_rate)
	elif "loop" in 音樂:
		音樂.loop = true
	背景播放器.stream = 音樂
	背景播放器.play()

func 停背景音樂() -> void:
	背景播放器.stop()
