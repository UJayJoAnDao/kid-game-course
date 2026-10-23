extends Area2D
# 尖刺陷阱：每隔幾秒，尖刺就會冒出來一下。尖刺冒出來的時候碰到會被送回檢查點。
# 下面兩個數字可以在「檢查器」裡改。

@export var 週期: float = 2.0       ## 每幾秒冒出來一次（2 = 在第 2、4、6、8…秒冒出來）
@export var 冒出秒數: float = 1.0   ## 每次冒出來停留幾秒

var 收起圖 := preload("res://assets/sprites/spike_down.png")
var 冒出圖 := preload("res://assets/sprites/spike_up.png")
var 冒出來了: bool = false

@onready var 圖: Sprite2D = $Sprite2D
@onready var 標籤: Label = $標籤

func _process(_delta: float) -> void:
	var t: float = Clock.秒
	# 從第「週期」秒開始，每過一個週期就冒出來一次，冒出來後停留「冒出秒數」
	冒出來了 = t >= 週期 and fmod(t, 週期) < 冒出秒數
	圖.texture = 冒出圖 if 冒出來了 else 收起圖
	標籤.text = "每%s秒" % 數字文字(週期)

func _physics_process(_delta: float) -> void:
	if not 冒出來了:
		return
	for 身體 in get_overlapping_bodies():
		if 身體.is_in_group("玩家"):
			身體.受傷()

func 數字文字(n: float) -> String:
	# 2.0 顯示成「2」，2.5 顯示成「2.5」
	return str(int(n)) if n == int(n) else str(n)
