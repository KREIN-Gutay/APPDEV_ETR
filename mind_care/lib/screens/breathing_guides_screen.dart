import 'package:flutter/material.dart';
//import 'package:mind_care/screens/relaxation_widgets.dart';
import 'breathing_timer_screen.dart';
//import 'package:mind_care/widgets/glass_card.dart';

class BreathingGuidesScreen extends StatelessWidget {
  final Widget Function({required Widget child, EdgeInsets? margin})
  buildGlassCard;
  const BreathingGuidesScreen({super.key, required this.buildGlassCard});

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
          "Breathing",
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
              _buildGuideItem(
                context,
                "4-7-8 Relax",
                "Deep calming breath pattern.",
                "2 min",
                120,
                Colors.teal,
              ),
              const SizedBox(height: 10),
              _buildGuideItem(
                context,
                "Box Breathing",
                "Focus and regulate nervous system.",
                "3 min",
                180,
                Colors.indigo,
              ),
              const SizedBox(height: 10),
              _buildGuideItem(
                context,
                "Pepper Calm 4-4-2",
                "Quick reset breath.",
                "90 sec",
                90,
                Colors.deepOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    String title,
    String subtitle,
    String durationLabel,
    int seconds,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreathingTimerScreen(
            title: title,
            durationSeconds: seconds,
            buildGlassCard: buildGlassCard,
          ),
        ),
      ),
      child: buildGlassCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(subtitle),
              ],
            ),
            Text(
              durationLabel,
              style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
