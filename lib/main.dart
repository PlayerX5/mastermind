import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide status + nav bar (immersive mode)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Make system bars transparent so background extends fully
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 👈 transparent status bar
      systemNavigationBarColor: Colors.transparent, // 👈 transparent nav bar
    ),
  );
  
  runApp(MyToolboxApp());
}

class MyToolboxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToolboxHome(),
    );
  }
}

class ToolboxHome extends StatefulWidget {
  @override
  _ToolboxHomeState createState() => _ToolboxHomeState();
}

class _ToolboxHomeState extends State<ToolboxHome> {
  late Timer _timer;
  late String _backgroundImage;

  @override
  void initState() {
    super.initState();
    _backgroundImage = getBackgroundImage();

    // update background every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _backgroundImage = getBackgroundImage();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // clean up when widget is destroyed
    super.dispose();
  }

  // Function to choose background image based on time
  String getBackgroundImage() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'assets/images/morning.png'; // 5AM - 11AM
    } else if (hour >= 12 && hour < 17) {
      return 'assets/images/afternoon.png'; // 12PM - 4PM
    } else if (hour >= 17 && hour < 20) {
      return 'assets/images/evening.png'; // 5PM - 7PM
    } else {
      return 'assets/images/night.png'; // 8PM - 4AM
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight, // 👈 ensures it fills full screen
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title closer to the top
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Pick Your Magic",
                        style: TextStyle(
                          fontFamily: "WinterSprinkle",
                          fontSize: screenWidth * 0.12, // 12% of screen width
                          decoration: TextDecoration.underline,
                          decorationThickness: 0.75,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.black45,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // First row (2 side by side)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildToolBox("Calculator", "assets/images/calculator.png",
                            CalculatorPage(), screenWidth),
                        buildToolBox("Calendar", "assets/images/calendar.png",
                            CalendarPage(), screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Second row (1 centered)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildToolBox("Expenses", "assets/images/bet.png",
                            ExpensesPage(), screenWidth),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.025),

                    // Third row (2 side by side again)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildToolBox("Notes", "assets/images/notes.png",
                            NotesPage(), screenWidth),
                        buildToolBox("Coming Soon",
                            "assets/images/coming_soon.png", ComingSoonPage(), screenWidth),
                      ],
                    ),
                  ],
                ),
              ),
              ),
              );
            },
          ),
      ),
    );
  }

  // Function to build a square box with image and text below + navigation
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
