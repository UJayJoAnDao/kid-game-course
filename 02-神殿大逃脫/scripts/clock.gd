extends Node
# 神殿時鐘（全域）：從關卡開始算起，過了幾秒。
# 陷阱、燈籠都看這個時鐘決定「現在要不要動」，所以它們的節奏會對得上。
# 任何地方都能用 Clock.秒 讀到現在的時間。

var 秒: float = 0.0      ## 關卡開始後經過的秒數
var 暫停: bool = false   ## 過關或時間到的時候，時鐘停下來

func 歸零() -> void:
	秒 = 0.0
	暫停 = false

func _process(delta: float) -> void:
	if not 暫停:
		秒 += delta
