extends Sprite2D
# 燈籠：每隔幾秒亮一下。亮燈的時間由大門決定（看大門的檢查器）。

var 每幾秒亮一次: float = 4.0
var 亮燈秒數: float = 0.5   ## 每次亮多久
var 亮著: bool = false

var 暗圖 := preload("res://assets/sprites/lantern_off.png")
var 亮圖 := preload("res://assets/sprites/lantern_on.png")

@onready var 標籤: Label = $標籤

func _process(_delta: float) -> void:
	var t: float = Clock.秒
	亮著 = t >= 每幾秒亮一次 and fmod(t, 每幾秒亮一次) < 亮燈秒數
	texture = 亮圖 if 亮著 else 暗圖
	var n := 每幾秒亮一次
	標籤.text = "每%s秒" % (str(int(n)) if n == int(n) else str(n))
