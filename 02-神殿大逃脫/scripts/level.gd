extends Node2D
# 關卡的大腦：管時間、寶石、檢查點、過關和時間到。

@export var 時間限制: int = 90   ## 幾秒內要逃出神殿

var 寶石: int = 0
var 寶石總數: int = 0
var 重生點: Vector2
var 結束了: bool = false

@onready var 玩家: CharacterBody2D = $玩家
@onready var 時間標籤: Label = $UI/時間標籤
@onready var 剩餘標籤: Label = $UI/剩餘標籤
@onready var 寶石標籤: Label = $UI/寶石標籤
@onready var 提示標籤: Label = $UI/提示標籤

func _ready() -> void:
	Clock.歸零()                 # 時鐘從 0 秒開始
	重生點 = 玩家.global_position  # 一開始的重生點就是起點
	玩家.被打中.connect(被打中)
	for 一顆 in get_tree().get_nodes_in_group("寶石"):
		一顆.被撿到.connect(撿到寶石)
		寶石總數 += 1
	for 火把 in get_tree().get_nodes_in_group("檢查點"):
		火把.被點亮.connect(記住檢查點)
	for 出口 in get_tree().get_nodes_in_group("出口"):
		出口.到達出口.connect(逃出來了)
	更新寶石()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return
	var 經過 := int(Clock.秒)
	var 剩下 := 時間限制 - 經過
	時間標籤.text = "時間：%d 秒" % 經過
	剩餘標籤.text = "剩下：%d 秒" % max(剩下, 0)
	if 剩下 <= 0 and not 結束了:
		時間到()

func 撿到寶石() -> void:
	寶石 += 1
	更新寶石()

func 更新寶石() -> void:
	寶石標籤.text = "寶石：%d / %d" % [寶石, 寶石總數]

func 記住檢查點(位置: Vector2) -> void:
	重生點 = 位置
	提示標籤.text = "火把點亮了！被打到會從這裡重來"

func 被打中() -> void:
	SFX.播("hit")
	玩家.回到(重生點)

func 逃出來了() -> void:
	if 結束了:
		return
	結束了 = true
	Clock.暫停 = true
	玩家.可以動 = false
	SFX.播("win")
	var 用了 := int(Clock.秒)
	提示標籤.text = "逃出來了！用了 %d 秒，還剩 %d 秒。按 R 再玩一次" % [用了, 時間限制 - 用了]

func 時間到() -> void:
	結束了 = true
	Clock.暫停 = true
	玩家.可以動 = false
	提示標籤.text = "時間到！神殿關起來了…按 R 再試一次"
