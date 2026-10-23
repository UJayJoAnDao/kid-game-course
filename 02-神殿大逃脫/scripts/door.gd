extends StaticBody2D
# 雙燈籠大門：兩個燈籠「同時亮起來」的那一刻，大門才會打開一下子。
# 想讓門早點開？改下面兩個燈籠的數字試試看！

@export var 燈籠A每幾秒亮: float = 4.0   ## 上面那個燈籠，每幾秒亮一次
@export var 燈籠B每幾秒亮: float = 6.0   ## 下面那個燈籠，每幾秒亮一次
@export var 開門秒數: float = 3.0        ## 門打開後，開多久才關起來

var 關門圖 := preload("res://assets/sprites/door_closed.png")
var 開門圖 := preload("res://assets/sprites/door_open.png")
var 剩下開門時間: float = 0.0
var 開著: bool = false

@onready var 圖: Sprite2D = $Sprite2D
@onready var 擋路: CollisionShape2D = $CollisionShape2D
@onready var 門口: Area2D = $門口
@onready var 燈籠A: Sprite2D = $燈籠A
@onready var 燈籠B: Sprite2D = $燈籠B

func _process(delta: float) -> void:
	# 把檢查器裡的數字交給兩個燈籠
	燈籠A.每幾秒亮一次 = 燈籠A每幾秒亮
	燈籠B.每幾秒亮一次 = 燈籠B每幾秒亮

	# 兩個燈籠同時亮 → 門打開
	if 燈籠A.亮著 and 燈籠B.亮著:
		if not 開著:
			SFX.播("door")
		剩下開門時間 = 開門秒數

	剩下開門時間 -= delta
	# 有人正站在門口時，門不會關起來夾到人
	var 有人在門口 := false
	for 身體 in 門口.get_overlapping_bodies():
		if 身體.is_in_group("玩家"):
			有人在門口 = true
	開著 = 剩下開門時間 > 0 or (開著 and 有人在門口)

	圖.texture = 開門圖 if 開著 else 關門圖
	擋路.set_deferred("disabled", 開著)
