extends Node2D
# 訓練場：打木人，看木人在不同受傷 % 時會飛多遠。
# 按 1 / 2 / 3 把木人的受傷設成 0% / 50% / 100%，按 0 把木人放回原位。

const 木人起點 := Vector2(520, 560)
const 受傷警告 = preload("res://scripts/受傷警告.gd")
const 一公尺 := 50.0   ## 畫面上 50 像素算 1 公尺

var 玩家: CharacterBody2D
var 木人: CharacterBody2D
var 飛行中: bool = false
var 起飛x: float = 0.0
var 空中時間: float = 0.0

@onready var 結果: Label = $UI/結果
@onready var 木人受傷: Label = $UI/木人受傷

func _ready() -> void:
	玩家 = load(Game.武將列表[Game.P1選擇]).instantiate()
	玩家.玩家編號 = 1
	玩家.position = Vector2(420, 540)
	add_child(玩家)
	玩家.名牌.text = "P1"
	木人 = load("res://scenes/木人.tscn").instantiate()
	木人.是木人 = true
	木人.position = 木人起點
	add_child(木人)
	木人.名牌.text = ""
	木人.被打中.connect(_木人被打中)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
		return
	for 對 in [["dummy_0", 0.0], ["dummy_50", 50.0], ["dummy_100", 100.0]]:
		if Input.is_action_just_pressed(對[0]):
			放回木人()
			木人.受傷 = 對[1]
	if Input.is_action_just_pressed("dummy_reset"):
		放回木人()
	if Input.is_action_just_pressed("rage_full"):
		玩家.怒氣 = 玩家.怒氣上限     # 練習必殺技用
	if 玩家.global_position.y > 900:
		玩家.重生(Vector2(420, 400))

	if 飛行中:
		空中時間 += delta
		if 木人.global_position.x > 1300 or 木人.global_position.x < -20 or 木人.global_position.y > 900:
			結果.text = "飛出場外了！（超過 %d 公尺）" % int((1280 - 起飛x) / 一公尺)
			飛行中 = false
			get_tree().create_timer(0.8).timeout.connect(放回木人.bind(true))
		elif 空中時間 > 0.2 and 木人.is_on_floor() and abs(木人.velocity.x) < 30:
			var 公尺: float = abs(木人.global_position.x - 起飛x) / 一公尺
			結果.text = "木人飛了 %.1f 公尺" % 公尺
			飛行中 = false
	木人受傷.text = "木人受傷：%d%%" % int(木人.受傷)
	木人受傷.modulate = 受傷警告.顏色(木人.受傷)

func _木人被打中(_擊退: float) -> void:
	飛行中 = true
	空中時間 = 0.0
	起飛x = 木人.global_position.x
	結果.text = "飛呀飛…"

func 放回木人(保留受傷: bool = false) -> void:
	var 原本: float = 木人.受傷
	木人.重生(木人起點)
	木人.無敵 = 0.0
	if 保留受傷:
		木人.受傷 = 原本
	飛行中 = false
