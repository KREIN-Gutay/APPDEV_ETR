import 'package:flutter/material.dart';
import 'package:mind_care/screens/onboarding_screen4.dart';
import 'package:mind_care/widgets/onboarding_progress_bar.dart';

class OnboardingScreen3 extends StatefulWidget {
  const OnboardingScreen3({super.key});

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> {
  int distressLevel = -1; // -1 = no selection

  String getEmoji() {
    if (distressLevel == -1) return "❓";
    if (distressLevel <= 2) return "🙂";
    if (distressLevel <= 5) return "😐";
    if (distressLevel <= 7) return "😟";
    return "😢";
  }

  String getDescription() {
    if (distressLevel == -1) {
      return "Use the scale to tell us how distressed you feel right now. This helps us understand your current state.";
    }
    if (distressLevel <= 2) return "Feeling calm and in control.";
    if (distressLevel <= 5) return "Uncomfortable, but manageable.";
    if (distressLevel <= 7) return "Feeling quite distressed and tense.";
    return "Overwhelmed and struggling to cope.";
  }

  Color dotColor(int index) {
    if (index > distressLevel) return Colors.grey.shade300;

    double t = index / 10;
    return Color.lerp(const Color(0xFF3B82F6), const Color(0xFFF4C542), t)!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OnboardingProgressBar(currentStep: 2),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ CENTER THE MAIN CONTENT
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "How much distress are you experiencing right now?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 50),

                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Text(
                        getEmoji(),
                        key: ValueKey(
                          distressLevel,
                        ), // ✅ needed so animation triggers
                        style: const TextStyle(fontSize: 58),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Text(
                      getDescription(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: distressLevel == -1
                            ? Colors.black54
                            : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ SCALE (UNCHANGED VISUALLY — BUT NOW DESELECTABLE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                11,
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      // ✅ Tap again to unselect
                      distressLevel = (distressLevel == index) ? -1 : index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 10,
                    decoration: BoxDecoration(
                      color: dotColor(index),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "0\nLow",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
                Text(
                  "10\nHigh",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ✅ BUTTON — SAME AS SCREEN 2
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: distressLevel == -1
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OnboardingScreen4(),
                          ),
                        );
                        // Navigate to next screen
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
