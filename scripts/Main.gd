extends Node
class_name Main
var layer:CanvasLayer
var world:Node
func _ready()->void:
	Game.register_main(self); layer=CanvasLayer.new(); add_child(layer); world=Node.new(); add_child(world); _intro()
func _clear()->void:
	for n in layer.get_children(): n.queue_free()
func _intro()->void:
	_clear(); var s=IntroScreen.new(); layer.add_child(s); s.finished.connect(_after_intro)
func _after_intro()->void:
	if Game.has_profile(): lobby()
	else: login()
func login()->void:
	_clear(); var s=LoginScreen.new(); layer.add_child(s); s.logged_in.connect(func():chars(true))
func chars(initial:bool)->void:
	_clear(); var s=CharacterSelectScreen.new(); s.initial_setup=initial; layer.add_child(s); s.continue_pressed.connect(lobby)
func lobby()->void:
	_clear(); var s=LobbyScreen.new(); layer.add_child(s); s.play_pressed.connect(start_match); s.character_pressed.connect(func():chars(false)); s.settings_pressed.connect(settings); s.inventory_pressed.connect(inventory); s.shop_pressed.connect(shop)
func settings()->void:
	_clear(); var s=SettingsScreen.new(); layer.add_child(s); s.back_pressed.connect(lobby)
func inventory()->void:
	_clear(); var s=InventoryScreen.new(); layer.add_child(s); s.back_pressed.connect(lobby)
func shop()->void:
	_clear(); var s=ShopScreen.new(); layer.add_child(s); s.back_pressed.connect(lobby)
func start_match()->void:
	_clear(); for n in world.get_children(): n.queue_free(); var b=Battlefield3D.new(); world.add_child(b); var h=BattleHUD.new(); layer.add_child(h); b.finished.connect(end_match); h.attack_pressed.connect(b.player_attack); h.ability_pressed.connect(b.player_ability); h.quit_pressed.connect(lobby)
func end_match(summary:Dictionary)->void:
	_clear(); for n in world.get_children(): n.queue_free(); var s=MatchEndOverlay.new(); layer.add_child(s); s.setup(summary); s.continue_pressed.connect(lobby)
