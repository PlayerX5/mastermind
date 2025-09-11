import 'dart:async';
import 'package:flutter/material.dart';

void main() {
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
        child: SafeArea(
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
                    fontSize: 64,
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
              const SizedBox(height: 24),

              // First row (2 side by side)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildToolBox("Calculator", "assets/images/calculator.png"),
                  buildToolBox("Calendar", "assets/images/calendar.png"),
                ],
              ),
              const SizedBox(height: 20),

              // Second row (1 centered)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildToolBox("Expenses", "assets/images/bet.png"),
                ],
              ),
              const SizedBox(height: 20),

              // Third row (2 side by side again)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildToolBox("Notes", "assets/images/notes.png"),
                  buildToolBox("Coming Soon", "assets/images/coming_soon.png"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a square box with image and text below
  Widget buildToolBox(String title, String imagePath) {
    double boxSize = MediaQuery.of(context).size.width * 0.4;

    return Column(
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
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: boxSize * 0.12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
