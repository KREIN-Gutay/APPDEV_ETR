import 'dart:async';
import 'package:flutter/material.dart';

class ShortMeditationScreen extends StatefulWidget {
  final Widget Function({required Widget child, EdgeInsets? margin})
  buildGlassCard;

  const ShortMeditationScreen({super.key, required this.buildGlassCard});

  @override
  State<ShortMeditationScreen> createState() => _ShortMeditationScreenState();
}

class _ShortMeditationScreenState extends State<ShortMeditationScreen> {
  Timer? _timer;
  int _secondsRemaining = 300; // Default 5 minutes
  bool _isRunning = false;

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          _showCompleteDialog();
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Well Done"),
        content: const Text("You have completed your short meditation."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Meditation",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120),
              const Text(
                "Relaxation Tools",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const Text(
                "Breathing • Mindfulness • Meditations",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 30),
              widget.buildGlassCard(
                child: Column(
                  children: [
                    const Text(
                      "Focus - 5 min",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "A short guided session to sharpen attention.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              _formatTime(_secondsRemaining),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Text(
                              "Time remaining",
                              style: TextStyle(color: Colors.black45),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _toggleTimer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRunning
                                    ? Colors.redAccent[100]
                                    : const Color(0xFFFFB74D),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                _isRunning ? "Pause" : "Start",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!_isRunning && _secondsRemaining < 300) ...[
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _secondsRemaining = 300),
                                child: const Text(
                                  "Reset",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
