/*import 'package:flutter/material.dart';
import 'package:mind_care/screens/breathing_guides_screen.dart';
import 'package:mind_care/widgets/glass_card.dart';

class AIRecommendationsScreen extends StatelessWidget {
  const AIRecommendationsScreen({super.key});

  // ✅ Adapter function (THIS is the key fix)
  Widget buildGlassCard({required Widget child, EdgeInsets? margin}) {
    return GlassCard(margin: margin, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Recommendations")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _recommendationCard(
            context,
            title: "You seem stressed lately",
            action: "Try Box Breathing",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BreathingGuidesScreen(
                    buildGlassCard: buildGlassCard, // ✅ FIX
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _recommendationCard(
    BuildContext context, {
    required String title,
    required String action,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(action),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:mind_care/screens/breathing_guides_screen.dart';
import 'package:mind_care/screens/relaxation_widgets.dart';
import 'package:mind_care/screens/services/gemini_service.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';

class AIRecommendationsScreen extends StatefulWidget {
  const AIRecommendationsScreen({super.key});

  @override
  State<AIRecommendationsScreen> createState() =>
      _AIRecommendationsScreenState();
}

class _AIRecommendationsScreenState extends State<AIRecommendationsScreen> {
  JournalAnalysisResult? result;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    // 1️⃣ Get latest journal entry
    final entries = await DBHelper.getEntries();
    final lastJournal = entries
        .where((e) => e['type'] == 'journal')
        .toList()
        .reversed
        .firstOrNull;

    if (lastJournal == null) {
      setState(() => loading = false);
      return;
    }

    // 2️⃣ Analyze stress
    final analysis = await GeminiService.analyzeJournalStress(
      lastJournal['content'],
    );

    setState(() {
      result = analysis;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Recommendations")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : result == null
          ? const Center(
              child: Text("Write a journal entry to get suggestions"),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stress level: ${result!.stressLevel}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Recommended breathing:",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result!.suggestedExercise,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  /* const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BreathingGuidesScreen(
                            buildGlassCard: ({required child, margin}) => child,
                          ),
                        ),
                      );
                    },
                    child: const Text("View Relaxation Tools"),
                  ),*/
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    BreathingGuidesScreen(buildGlassCard: buildGlassCard),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "View Relaxation Tools",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
