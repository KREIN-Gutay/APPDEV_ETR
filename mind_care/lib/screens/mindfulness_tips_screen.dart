import 'package:flutter/material.dart';
import 'breathing_timer_screen.dart';
import 'five_senses_screen.dart'; // Import the new logic file
//import 'package:mind_care/widgets/glass_card.dart';

class MindfulnessTipsScreen extends StatelessWidget {
  final Widget Function({required Widget child, EdgeInsets? margin})
  buildGlassCard;

  const MindfulnessTipsScreen({super.key, required this.buildGlassCard});

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
          "Mindfulness",
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

              // 1-min Body Scan
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BreathingTimerScreen(
                      title: "1-min Body Scan",
                      durationSeconds: 60,
                      buildGlassCard: buildGlassCard,
                    ),
                  ),
                ),
                child: buildGlassCard(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "1-min Body Scan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text("Scan sensations from head to toe."),
                        ],
                      ),
                      Text(
                        "1 min",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 5 Senses Ground (Updated with Functionality)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        FiveSensesScreen(buildGlassCard: buildGlassCard),
                  ),
                ),
                child: buildGlassCard(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "5 Senses Ground",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text("Bring attention using senses."),
                        ],
                      ),
                      Text(
                        "2 min",
                        style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
