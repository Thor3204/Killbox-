extends Node
class_name Main
var layer:CanvasLayer
var world:Node
func _ready():
 Game.register_main(self); layer=CanvasLayer.new(); add_child(layer); world=Node.new(); add_child(world); intro()
func clear_ui():
 for n in layer.get_children(): n.queue_free()
func intro():
 clear_ui(); var s=IntroScreen.new(); layer.add_child(s); s.finished.connect(after_intro)
func after_intro():
 if Game.has_profile(): lobby()
 else: login()
func login():
 clear_ui(); var s=LoginScreen.new(); layer.add_child(s); s.logged_in.connect(func():chars(true))
func chars(initial:bool):
 clear_ui(); var s=CharacterSelectScreen.new(); s.initial_setup=initial; layer.add_child(s); s.continue_pressed.connect(lobby)
func lobby():
 clear_ui(); var s=HubScreen.new(); layer.add_child(s); s.play_pressed.connect(start_match); s.character_pressed.connect(func():chars(false)); s.settings_pressed.connect(settings); s.inventory_pressed.connect(inventory); s.shop_pressed.connect(shop)
func settings():
 clear_ui(); var s=SettingsScreen.new(); layer.add_child(s); s.back_pressed.connect(lobby)
func inventory():
 clear_ui(); var s=InventoryScreen.new(); layer.add_child(s); s.back_pressed.connect(lobby)
func shop():
 clear_ui(); var s=ShopScreen.new(); layer.add_child(s); s.back_pressed.connect(lobby)
func start_match():
 clear_ui(); for n in world.get_children(): n.queue_free()
 var b=Battlefield3D.new(); world.add_child(b); var h=BattleHUD.new(); layer.add_child(h); b.finished.connect(end_match); h.attack_pressed.connect(b.player_attack); h.ability_pressed.connect(b.player_ability); h.quit_pressed.connect(lobby)
func end_match(summary:Dictionary):
 clear_ui(); for n in world.get_children(): n.queue_free(); var s=MatchEndOverlay.new(); layer.add_child(s); s.setup(summary); s.continue_pressed.connect(lobby)
