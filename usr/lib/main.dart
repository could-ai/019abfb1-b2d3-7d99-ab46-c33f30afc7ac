import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart'; // Added missing import for CollisionCallbacks
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// MAIN ENTRY POINT
// ---------------------------------------------------------------------------
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set full screen and landscape for better gaming experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainMenuScreen(),
        '/game': (context) => const GamePlayScreen(),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// SCREENS (UI)
// ---------------------------------------------------------------------------

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)], // Sky blue gradient
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kids Adventure',
                style: GoogleFonts.chewy(
                  fontSize: 64,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'انطلق في عالم مليء بالمغامرات!',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              _buildMenuButton(context, 'Start Game', Icons.play_arrow_rounded, () {
                Navigator.pushNamed(context, '/game');
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSmallButton(context, Icons.store, Colors.purple, () {
                    _showMockDialog(context, "Shop", "شراء شخصيات جديدة (قريباً)");
                  }),
                  const SizedBox(width: 16),
                  _buildSmallButton(context, Icons.settings, Colors.grey, () {
                    _showMockDialog(context, "Settings", "إعدادات الصوت واللغة");
                  }),
                  const SizedBox(width: 16),
                  _buildSmallButton(context, Icons.video_library, Colors.red, () {
                    _showMockDialog(context, "Ads", "شاهد إعلان للحصول على عملات!");
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      label: Text(label, style: const TextStyle(fontSize: 28)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
      ),
    );
  }

  Widget _buildSmallButton(BuildContext context, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3))],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _showMockDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }
}

class GamePlayScreen extends StatefulWidget {
  const GamePlayScreen({super.key});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  late KidsAdventureGame _game;

  @override
  void initState() {
    super.initState();
    _game = KidsAdventureGame(
      onGameOver: () {
        // Handle game over logic here if needed
      },
      onLevelComplete: () {
        // Handle level complete
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Game Widget
          GameWidget(game: _game),
          
          // HUD (Heads Up Display)
          Positioned(
            top: 20,
            left: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: _game.scoreNotifier,
              builder: (context, score, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.yellow),
                      const SizedBox(width: 8),
                      Text(
                        '$score',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Pause Button
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 40),
              onPressed: () {
                _game.pauseEngine();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Paused"),
                    content: const Text("Game is paused."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx); // Close dialog
                          Navigator.pop(context); // Go to menu
                        },
                        child: const Text("Exit"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _game.resumeEngine();
                        },
                        child: const Text("Resume"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Controls (Touch Overlay)
          Positioned(
            bottom: 40,
            left: 40,
            child: Row(
              children: [
                _ControlBtn(
                  icon: Icons.arrow_back,
                  onDown: () => _game.player.moveLeft(),
                  onUp: () => _game.player.stopMoving(),
                ),
                const SizedBox(width: 20),
                _ControlBtn(
                  icon: Icons.arrow_forward,
                  onDown: () => _game.player.moveRight(),
                  onUp: () => _game.player.stopMoving(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: _ControlBtn(
              icon: Icons.arrow_upward,
              onDown: () => _game.player.jump(),
              onUp: () {}, // No action needed on release for jump usually
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Color color;

  const _ControlBtn({
    required this.icon,
    required this.onDown,
    required this.onUp,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: () => onUp(),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 35),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// GAME LOGIC (FLAME ENGINE)
// ---------------------------------------------------------------------------

class KidsAdventureGame extends FlameGame with HasCollisionDetection {
  final VoidCallback onGameOver;
  final VoidCallback onLevelComplete;
  
  late Player player;
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  
  // World properties
  double gravity = 1000.0;
  
  KidsAdventureGame({required this.onGameOver, required this.onLevelComplete});

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue background

  @override
  Future<void> onLoad() async {
    // Add Player
    player = Player();
    add(player);

    // Add Ground/Platforms
    // Floor
    add(Platform(position: Vector2(0, size.y - 50), size: Vector2(size.x * 5, 50)));
    
    // Floating Platforms
    add(Platform(position: Vector2(300, size.y - 150), size: Vector2(150, 20)));
    add(Platform(position: Vector2(550, size.y - 250), size: Vector2(150, 20)));
    add(Platform(position: Vector2(800, size.y - 180), size: Vector2(150, 20)));
    add(Platform(position: Vector2(1100, size.y - 300), size: Vector2(150, 20)));

    // Add Collectibles (Coins/Stars)
    add(Collectible(position: Vector2(350, size.y - 200)));
    add(Collectible(position: Vector2(600, size.y - 300)));
    add(Collectible(position: Vector2(850, size.y - 230)));
    add(Collectible(position: Vector2(1150, size.y - 350)));
    
    // Add Enemy
    add(Enemy(position: Vector2(600, size.y - 80), moveRange: 200));

    // Camera follow player
    camera.viewfinder.anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Simple camera follow
    camera.viewfinder.position = Vector2(player.position.x, size.y / 2);
    
    // Reset if fell off world
    if (player.position.y > size.y + 100) {
      player.position = Vector2(100, size.y - 200);
      player.velocity = Vector2.zero();
    }
  }

  void addScore(int amount) {
    scoreNotifier.value += amount;
  }
}

// ---------------------------------------------------------------------------
// GAME COMPONENTS
// ---------------------------------------------------------------------------

class Player extends PositionComponent with HasGameRef<KidsAdventureGame>, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  final double moveSpeed = 200;
  final double jumpForce = 550;
  int horizontalDirection = 0; // -1 left, 0 stop, 1 right
  bool isOnGround = false;

  Player() : super(position: Vector2(100, 200), size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual representation (Red Box for hero)
    // In a real game, use SpriteComponent
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.redAccent,
    ));
    // Eyes
    add(CircleComponent(radius: 4, position: Vector2(10, 10), paint: Paint()..color = Colors.white));
    add(CircleComponent(radius: 4, position: Vector2(26, 10), paint: Paint()..color = Colors.white));
    
    // Add Hitbox for collision detection
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Horizontal Movement
    velocity.x = horizontalDirection * moveSpeed;

    // Gravity
    velocity.y += gameRef.gravity * dt;

    // Apply movement
    position += velocity * dt;

    // Simple Collision Detection (AABB)
    // Note: We are doing manual collision checks here for platforming physics
    // The CollisionCallbacks mixin is available if we want to use onCollision events later
    isOnGround = false;
    for (final component in gameRef.children) {
      if (component is Platform) {
        if (toRect().overlaps(component.toRect())) {
          // Collision logic
          // Check if landing on top
          if (velocity.y > 0 && position.y + size.y / 2 > component.position.y - component.size.y / 2 && position.y < component.position.y) {
             velocity.y = 0;
             position.y = component.position.y - component.size.y / 2 - size.y / 2;
             isOnGround = true;
          }
        }
      } else if (component is Collectible) {
        if (toRect().overlaps(component.toRect())) {
          component.collect();
        }
      } else if (component is Enemy) {
        if (toRect().overlaps(component.toRect())) {
          // Hit enemy - reset position
          position = Vector2(100, 200);
        }
      }
    }
  }

  void moveLeft() {
    horizontalDirection = -1;
    scale.x = -1; // Flip sprite
  }

  void moveRight() {
    horizontalDirection = 1;
    scale.x = 1;
  }

  void stopMoving() {
    horizontalDirection = 0;
  }

  void jump() {
    if (isOnGround) {
      velocity.y = -jumpForce;
      isOnGround = false;
    }
  }
}

class Platform extends PositionComponent {
  Platform({required Vector2 position, required Vector2 size}) 
      : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.green,
    ));
    // Add a "grass" top
    add(RectangleComponent(
      size: Vector2(size.x, 5),
      position: Vector2(0, 0),
      paint: Paint()..color = Colors.lightGreenAccent,
    ));
    add(RectangleHitbox());
  }
}

class Collectible extends PositionComponent with HasGameRef<KidsAdventureGame> {
  Collectible({required Vector2 position}) 
      : super(position: position, size: Vector2(30, 30), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Gold Coin visual
    add(CircleComponent(
      radius: 15,
      paint: Paint()..color = Colors.amber,
    ));
    add(CircleComponent(
      radius: 10,
      position: Vector2(5, 5),
      paint: Paint()..color = Colors.yellow,
    ));
    add(CircleHitbox());
  }

  void collect() {
    gameRef.addScore(10);
    removeFromParent(); // Disappear
  }
}

class Enemy extends PositionComponent {
  final double moveRange;
  late double startX;
  double speed = 100;
  int direction = 1;

  Enemy({required Vector2 position, this.moveRange = 100}) 
      : super(position: position, size: Vector2(40, 40), anchor: Anchor.center) {
    startX = position.x;
  }

  @override
  Future<void> onLoad() async {
    // Purple Monster
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.purple,
    ));
    // Angry Eyes
    add(RectangleComponent(size: Vector2(10, 5), position: Vector2(5, 10), paint: Paint()..color = Colors.white));
    add(RectangleComponent(size: Vector2(10, 5), position: Vector2(25, 10), paint: Paint()..color = Colors.white));
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * direction * dt;

    if (position.x > startX + moveRange) {
      direction = -1;
    } else if (position.x < startX - moveRange) {
      direction = 1;
    }
  }
}
