import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide status + nav bar (immersive mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Make system bars transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(MyToolboxApp());
}

class MyToolboxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          ),
          child: child!,
        );
      },
      home: ToolboxHome(),
    );
  }
}

class ToolboxHome extends StatefulWidget {
  @override
  _ToolboxHomeState createState() => _ToolboxHomeState();
}

class _ToolboxHomeState extends State<ToolboxHome>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late String _backgroundImage;
  String _fact = "✨ Summoning a fact...";
  bool _isFetching = false;
  late ConfettiController _confettiController;

  // Finger trail particles
  late Ticker _ticker;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _backgroundImage = getBackgroundImage();

    // Change background every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _backgroundImage = getBackgroundImage();
      });
    });

    // Confetti setup
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Fetch first fact
    fetchRandomFact();

    // Shake detection
    userAccelerometerEvents.listen((event) {
      double gForce =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (gForce > 15) {
        _confettiController.play();
      }
    });

    // Ticker for particle animation
    _ticker = createTicker((elapsed) {
      setState(() {
        particles.removeWhere((p) => p.life <= 0);
        for (var p in particles) {
          p.update();
        }
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _timer.cancel();
    _confettiController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  String getBackgroundImage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'assets/images/morning.png';
    if (hour >= 12 && hour < 17) return 'assets/images/afternoon.png';
    if (hour >= 17 && hour < 20) return 'assets/images/evening.png';
    return 'assets/images/night.png';
  }

  Future<void> fetchRandomFact() async {
    if (_isFetching) return;
    setState(() {
      _isFetching = true;
      _fact = "✨ Summoning a fact...";
    });

    try {
      final response = await http.get(
        Uri.parse('https://uselessfacts.jsph.pl/random.json?language=en'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _fact = data['text']);
      } else {
        setState(() => _fact = "Failed to load fact ❌");
      }
    } catch (e) {
      setState(() => _fact = "Error fetching fact ⚡");
    } finally {
      setState(() => _isFetching = false);
    }
  }

  void addParticle(Offset position) {
    particles.add(Particle(
      position: position,
      velocity: Offset((Random().nextDouble() - 0.5) * 4,
          (Random().nextDouble() - 0.5) * 4),
      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          addParticle(details.localPosition);
        },
        onTapDown: (details) {
          addParticle(details.localPosition);
        },
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Scrollable content
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Pick Your Magic",
                      style: TextStyle(
                        fontFamily: "WinterSprinkle",
                        fontSize: screenSize.width * 0.12,
                        decoration: TextDecoration.underline,
                        decorationThickness: 0.75,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _fact,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 40),
                    // Toolbox rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildToolBox("Calculator",
                            "assets/images/calculator.png", CalculatorPage(),
                            screenSize.width),
                        buildToolBox("Calendar", "assets/images/calendar.png",
                            CalendarPage(), screenSize.width),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildToolBox("Expenses", "assets/images/bet.png",
                            ExpensesPage(), screenSize.width),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildToolBox("Notes", "assets/images/notes.png",
                            NotesPage(), screenSize.width),
                        buildToolBox("Coming Soon",
                            "assets/images/coming_soon.png", ComingSoonPage(),
                            screenSize.width),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Confetti + emoji explosion
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.purple,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.green
                ],
                createParticlePath: (_) => drawEmoji(),
              ),

              // 🎯 Finger trail overlay, but doesn't block taps
              IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(particles),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolBox(
      String title, String imagePath, Widget page, double screenWidth) {
    double boxSize = screenWidth * 0.4;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          Container(
            height: boxSize,
            width: boxSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(3, 3),
                ),
              ],
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            title,
            style: TextStyle(
              fontSize: boxSize * 0.12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Path drawEmoji() {
    final path = Path();
    final textPainter = TextPainter(
      text: TextSpan(
        text: ["🎉", "✨", "🔥", "🌟"][Random().nextInt(4)],
        style: const TextStyle(fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    path.addRect(Rect.fromLTWH(0, 0, textPainter.width, textPainter.height));
    return path;
  }
}

// Particle classes for finger trail
class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double life;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    this.life = 30,
  });

  void update() {
    position += velocity;
    life -= 1;
  }
}

class ParticlePainter extends CustomPainter {
  List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      paint.color = p.color.withOpacity(p.life / 30);
      canvas.drawCircle(p.position, 6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

// Dummy pages
class CalculatorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calculator")),
      body: Center(child: Text("This is the Calculator Page")),
    );
  }
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Calendar")),
      body: Center(child: Text("This is the Calendar Page")),
    );
  }
}

class ExpensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expenses Tracker")),
      body: Center(child: Text("This is the Expenses Tracker Page")),
    );
  }
}

class NotesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      body: Center(child: Text("This is the Notes Page")),
    );
  }
}

class ComingSoonPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Coming Soon")),
      body: Center(child: Text("Feature coming soon 🚀")),
    );
  }
}
