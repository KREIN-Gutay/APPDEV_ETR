import 'package:flutter/material.dart';
import 'package:mind_care/screens/onboarding_screen3.dart';

import 'package:mind_care/widgets/onboarding_progress_bar.dart';

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> {
  final List<String> options = [
    "Managing stress",
    "Journaling",
    "Improving sleep",
    "Building healthy habits",
    "Improving focus",
    "Emotional awareness",
    "Boosting motivation",
    "Mindfulness & grounding",
    "I'm not sure",
    "Other",
  ];

  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF), // elegant soft blue

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
            padding: const EdgeInsets.only(bottom: 8.0),
            child: OnboardingProgressBar(currentStep: 1),
          ),
        ),
      ),

      body: Column(
        children: [
          /// ---- TOP TEXT ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: const [
                Text(
                  "What brings you here?",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  "Select all that apply",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// ---- SCROLLABLE LIST ----
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: options.length,
              itemBuilder: (context, index) {
                String item = options[index];
                bool isPicked = selected.contains(item);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPicked ? selected.remove(item) : selected.add(item);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isPicked ? Colors.blue : Colors.transparent,
                          width: isPicked ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPicked
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isPicked ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ---- FIXED BUTTON ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
          ),
        ],
      ),
    );
  }

  void next() {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white), // white circle !
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Please select at least one option to continue.",
                  style: TextStyle(color: Colors.white), // text also white
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent, // classic caution background
        ),
      );
      return;
    }

    // If at least one item is selected → proceed
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OnboardingScreen3()),
    );
  }
}
