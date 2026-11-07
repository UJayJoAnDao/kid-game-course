extends Node
# 遊戲設定（全域，名稱 Game）：記住兩位玩家選了哪個武將、P2 是不是電腦。

# 可以選的武將。想加新武將，就把它的場景路徑加進來。
var 武將列表: Array[String] = [
	"res://scenes/generals/關羽.tscn",
	"res://scenes/generals/張飛.tscn",
	"res://scenes/generals/趙雲.tscn",
	"res://scenes/generals/呂布.tscn",
	"res://scenes/generals/我的武將.tscn",
]

var P1選擇: int = 0
var P2選擇: int = 3
var P2是電腦: bool = false
