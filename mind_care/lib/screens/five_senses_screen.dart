import 'package:flutter/material.dart';

class FiveSensesScreen extends StatefulWidget {
  final Widget Function({required Widget child, EdgeInsets? margin})
  buildGlassCard;

  const FiveSensesScreen({super.key, required this.buildGlassCard});

  @override
  State<FiveSensesScreen> createState() => _FiveSensesScreenState();
}

class _FiveSensesScreenState extends State<FiveSensesScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      "count": "5",
      "action": "See",
      "desc": "Look around and name 5 things you can see right now.",
      "icon": Icons.visibility_rounded,
      "color": Colors.blueAccent,
    },
    {
      "count": "4",
      "action": "Touch",
      "desc":
          "Identify 4 things you can touch or feel (e.g., your hair, feet on floor).",
      "icon": Icons.back_hand_rounded,
      "color": Colors.orangeAccent,
    },
    {
      "count": "3",
      "action": "Hear",
      "desc":
          "Listen for 3 distinct sounds (e.g., birds, traffic, your breath).",
      "icon": Icons.hearing_rounded,
      "color": Colors.greenAccent,
    },
    {
      "count": "2",
      "action": "Smell",
      "desc":
          "Name 2 things you can smell. If you can't smell anything, name favorites.",
      "icon": Icons.air_rounded,
      "color": Colors.purpleAccent,
    },
    {
      "count": "1",
      "action": "Taste",
      "desc": "Notice 1 thing you can taste, or your favorite thing to taste.",
      "icon": Icons.restaurant_menu_rounded,
      "color": Colors.redAccent,
    },
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Grounded", textAlign: TextAlign.center),
        content: const Text(
          "You have successfully completed the grounding exercise.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to menu
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Step ${_currentStep + 1} of 5",
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              widget.buildGlassCard(
                child: Column(
                  children: [
                    Icon(step['icon'], size: 80, color: step['color']),
                    const SizedBox(height: 20),
                    Text(
                      "${step['count']} Things to ${step['action']}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      step['desc'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentStep == 4 ? "Done" : "Next Sense",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
