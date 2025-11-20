extends Node2D
var score: int = 0
var level: int = 3
var current_level_root: Node = null

@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var fade: ColorRect = $HUD/Fade


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Configurar el nivel
	fade.modulate.a = 1.0
	current_level_root = get_node("LevelRoot")
	await  _load_level(level, true, false)
#-------------------
# Gestión de niveles
#-------------------

func _load_level(level_number: int, first_load: bool, reset_score: bool) -> void:
	#Desvanecimiento de salida
	if not first_load:
		await  _fade(1.0)
	
	if reset_score:
		score = 0
		score_label.text = "SCORE: 0"
		
	if current_level_root:
		current_level_root.queue_free()
	
	#Cargar nivel
	var level_path = "res://scenes/levels/level%s.tscn" % level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	_setup_level(current_level_root)
	
	#Desvanecimiento de salida
	await _fade(0.0)
	
func _setup_level(level_root: Node) -> void:
	
	#Conectado con las salidas
	var salidas = level_root.get_node_or_null("Exit")
	if salidas:
		salidas.body_entered.connect(_on_exit_body_entered)
	
	#Conectado con las manzanas
	var manzanas = level_root.get_node_or_null("manzanas")
	if manzanas:
		for manzana in manzanas.get_children():
			manzana.collected.connect(_increment_score)
			
			
	#Conectado con los enemigos
	var enemies = level_root.get_node_or_null("caracoles")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)

#------------------------
#Controladores de señales
#------------------------

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		level += 1
		body.can_move = false
		await  _load_level(level, false, false)
	

func _on_player_died(body):
	body.die()
	await  _load_level(level, false, true)


#---------------------------
#Controladores de puntuación
#---------------------------

func _increment_score() -> void:
	score += 1
	score_label.text = "SCORE: %s"  %score

#--------------------------
#Control de desvanecimiento
#--------------------------
func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished
