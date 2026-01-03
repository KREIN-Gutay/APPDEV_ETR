import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:mind_care/widgets/glass_card.dart';

enum BreathPhase { inhale, hold, exhale }

class BreathingTimerScreen extends StatefulWidget {
  final String title;
  final int durationSeconds;
  final Widget Function({required Widget child, EdgeInsets? margin})
  buildGlassCard;

  const BreathingTimerScreen({
    super.key,
    required this.title,
    required this.durationSeconds,
    required this.buildGlassCard,
  });

  @override
  State<BreathingTimerScreen> createState() => _BreathingTimerScreenState();
}

class _BreathingTimerScreenState extends State<BreathingTimerScreen> {
  BreathPhase _phase = BreathPhase.inhale;
  int _phaseSeconds = 0;
  bool _isRunning = false;

  bool _isAnimating = false;
  double _targetScale = 1.0;
  //String _statusText = "Ready";
  Timer? _timer;
  late int _secondsRemaining;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationSeconds;
  }

  String get phaseText {
    switch (_phase) {
      case BreathPhase.inhale:
        return "Inhale…";
      case BreathPhase.hold:
        return "Hold…";
      case BreathPhase.exhale:
        return "Exhale…";
    }
  }

  Map<BreathPhase, int> get breathingPattern {
    if (widget.title == "Box Breathing") {
      return {
        BreathPhase.inhale: 4,
        BreathPhase.hold: 4,
        BreathPhase.exhale: 4,
      };
    } else if (widget.title == "4-7-8 Relax") {
      return {
        BreathPhase.inhale: 4,
        BreathPhase.hold: 7,
        BreathPhase.exhale: 8,
      };
    } else if (widget.title == "Pepper Calm 4-4-2") {
      return {
        BreathPhase.inhale: 4,
        BreathPhase.hold: 4,
        BreathPhase.exhale: 2,
      };
    }

    return {BreathPhase.inhale: 4, BreathPhase.hold: 4, BreathPhase.exhale: 4};
  }

  int get currentPhaseDuration => breathingPattern[_phase]!;

  /*void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _showCompleteDialog();
      }
    });
  }*/
  //ito namodify ko
  void _startBreathing() {
    _isRunning = true;
    _phase = BreathPhase.inhale;
    _phaseSeconds = breathingPattern[_phase]!;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) return;

      setState(() {
        _phaseSeconds--;
      });

      if (_phaseSeconds <= 0) {
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    if (_phase == BreathPhase.inhale) {
      _phase = BreathPhase.hold;
    } else if (_phase == BreathPhase.hold) {
      _phase = BreathPhase.exhale;
    } else {
      _phase = BreathPhase.inhale;
    }

    _phaseSeconds = breathingPattern[_phase]!;
    _updateAnimationForPhase();
  }

  void _updateAnimationForPhase() {
    if (_phase == BreathPhase.inhale) {
      _targetScale = 1.4; // expand
    } else if (_phase == BreathPhase.exhale) {
      _targetScale = 1.0; // shrink
    }
    // HOLD = no scale change
  }

  void _showCompleteDialog() {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text("Well Done!")),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 20),
            Text("Relaxation session complete.", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetAnimation();
              },
              child: const Text(
                "Finish",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _targetScale = 1.2;
        _statusText = widget.title.contains("Scan") ? "Focus..." : "Inhale...";
        _startBreathing();
      } else {
        _targetScale = 1.0;
        _statusText = "Paused";
        _timer?.cancel();
      }
    });
  }*/
  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _targetScale = 1.4;
        _startBreathing();
      } else {
        _targetScale = 1.0;
        _isRunning = false;
        _timer?.cancel();
      }
    });
  }

  /* void _resetAnimation() {
    _timer?.cancel();
    setState(() {
      _isAnimating = false;
      _targetScale = 1.0;
      _secondsRemaining = widget.durationSeconds;
      _statusText = "Ready";
    });
  }*/
  void _resetAnimation() {
    _timer?.cancel();
    setState(() {
      _isAnimating = false;
      _isRunning = false;
      _phase = BreathPhase.inhale;
      _phaseSeconds = breathingPattern[_phase]!;
      _targetScale = 1.0;
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "$mins:${secs.toString().padLeft(2, '0')}";
  }

  /*int _getStepDuration() {
    if (!_isAnimating) return 1;
    if (widget.title.contains("Body Scan")) return 3;
    if (widget.title == "Box Breathing") {
      return 4;
    } else if (widget.title == "4-7-8 Relax") {
      if (_statusText == "Inhale...") return 4;
      if (_statusText == "Hold...") return 7;
      if (_statusText == "Exhale...") return 8;
    } else if (widget.title == "Pepper Calm 4-4-2") {
      if (_statusText == "Inhale...") return 4;
      if (_statusText == "Hold...") return 4;
      if (_statusText == "Exhale...") return 2;
    }
    return 4;
  }*/

  Color _getExerciseColor() {
    switch (widget.title) {
      case "Box Breathing":
        return Colors.indigoAccent;
      case "4-7-8 Relax":
        return Colors.teal;
      case "Pepper Calm 4-4-2":
        return Colors.deepOrange;
      case "1-min Body Scan":
        return Colors.blueGrey;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getExerciseColor();
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
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isAnimating
                ? [themeColor.withOpacity(0.2), themeColor.withOpacity(0.4)]
                : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: _targetScale),
              duration: Duration(seconds: currentPhaseDuration),
              curve: Curves.easeInOutSine,

              // ✅ NO onEnd anymore
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.2 * scale),
                          blurRadius: 40 * scale,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColor.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_secondsRemaining),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 60),
            /*Text(
              _statusText,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),*/
            Text(
              phaseText,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleAnimation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAnimating
                        ? Colors.red[200]
                        : Colors.orange[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 15,
                    ),
                  ),
                  child: Text(
                    _isAnimating ? "Stop" : "Start",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetAnimation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Reset",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
