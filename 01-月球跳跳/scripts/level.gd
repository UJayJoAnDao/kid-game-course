extends Node2D
# 關卡的大腦：管分數、管「掉下去重來」、管過關。

@export var 掉落高度: float = 900.0   ## 玩家掉到這個高度以下就重來（數字越大越晚重來）

var 分數: int = 0
var 已過關: bool = false

@onready var 玩家: CharacterBody2D = $玩家
@onready var 分數標籤: Label = $UI/分數標籤
@onready var 提示標籤: Label = $UI/提示標籤

func _ready() -> void:
	# 把畫面上每一個金幣的「被吃掉」訊號接到「加分」
	for 金幣 in get_tree().get_nodes_in_group("金幣"):
		金幣.被吃掉.connect(加分)
	# 把終點旗的「到達終點」訊號接到「過關」
	for 旗子 in get_tree().get_nodes_in_group("終點"):
		旗子.到達終點.connect(過關)
	更新分數顯示()

func _process(_delta: float) -> void:
	# 掉出畫面就重來
	if 玩家.position.y > 掉落高度:
		get_tree().reload_current_scene()
	# 隨時可按 R 重新開始
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func 加分() -> void:
	分數 += 1
	更新分數顯示()

func 更新分數顯示() -> void:
	分數標籤.text = "分數：%d" % 分數

func 過關() -> void:
	if 已過關:
		return
	已過關 = true
	SFX.播("win")
	提示標籤.text = "你贏了！按 R 再玩一次"
