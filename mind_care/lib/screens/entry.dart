import 'dart:io';
import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mind_care/screens/breathing_guides_screen.dart';
import 'package:mind_care/screens/breathing_timer_screen.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';
import 'package:mind_care/screens/relaxation_widgets.dart';
import 'package:mind_care/screens/services/gemini_service.dart';
//import 'package:mind_care/screens/lib/models/entry_model.dart';
import 'package:mind_care/widgets/glass_card.dart';

class Entry extends StatefulWidget {
  final String? selectedEmoji;
  const Entry({super.key, this.selectedEmoji});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String emoji = "";
  File? image;
  /*Widget buildGlassCard({required Widget child, double? width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }*/

  @override
  void initState() {
    super.initState();
    if (widget.selectedEmoji != null) {
      emoji = widget.selectedEmoji!;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  /* Future<void> saveEntry() async {
    if (titleController.text.isEmpty && contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write something first"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final entry = EntryModel(
      emoji: emoji,
      title: titleController.text,
      content: contentController.text,
      imagePath: image?.path,
      date: DateTime.now().toString(),
    );

    await DBHelper.insertEntry({
  'date': DateTime.now().toIso8601String(),
  'mood': null,
  'mood_value': null,
  'emoji': selectedEmoji,
  'content': contentController.text,
  'type': 'journal',
});*/

  Future<void> saveEntry() async {
    if (contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please write something first"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 1️⃣ Save journal entry to SQLite
    await DBHelper.insertEntry({
      'date': DateTime.now().toIso8601String(),
      'mood': null,
      'mood_value': null,
      'emoji': emoji,
      'content': contentController.text,
      'type': 'journal',
    });

    // 2️⃣ Ask Gemini to analyze stress
    final result = await GeminiService.analyzeJournalStress(
      contentController.text,
    );

    // (Optional) Debug print
    debugPrint("Stress level: ${result.stressLevel}");
    debugPrint("Suggested exercise: ${result.suggestedExercise}");

    // 3️⃣ Ask user if they want to try breathing
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Need a breather?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.stressLevel == "high"
                  ? "It sounds like you’ve been carrying a lot today."
                  : result.stressLevel == "medium"
                  ? "There’s some tension showing up in your entry."
                  : "Your entry feels relatively calm, but a pause could still help.",
            ),

            const SizedBox(height: 8),
            const Text(
              "A short breathing exercise can help calm your nervous system.",
            ),
            const SizedBox(height: 12),
            Text(
              "Recommended: ${result.suggestedExercise}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close entry screen
            },
            child: const Text("Later"),
          ),

          // 👇 NEW BUTTON (THIS IS WHAT YOU WANTED)
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close entry screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BreathingGuidesScreen(buildGlassCard: buildGlassCard),
                ),
              );
            },
            child: const Text("See all relaxation tools"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _navigateToBreathing(result.suggestedExercise);
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  void _navigateToBreathing(String exercise) {
    if (exercise == "Box Breathing") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreathingTimerScreen(
            title: "Box Breathing",
            durationSeconds: 120,
            buildGlassCard: buildGlassCard,
          ),
        ),
      );
    } else if (exercise == "4-7-8 Relax") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreathingTimerScreen(
            title: "4-7-8 Relax",
            durationSeconds: 180,
            buildGlassCard: buildGlassCard,
          ),
        ),
      );
    } else if (exercise == "Pepper Calm 4-4-2") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BreathingTimerScreen(
            title: "Pepper Calm 4-4-2",
            durationSeconds: 120,
            buildGlassCard: buildGlassCard,
          ),
        ),
      );
    }
  }

  // --- Enhanced Glassmorphic Card ---
  /* Widget buildGlassCard({required Widget child, double? width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("New Entry"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: kToolbarHeight + 40),

              // Emoji Display
              Center(
                child: buildGlassCard(
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 50)),
                  ),
                ),
              ),

              // Title Input
              buildGlassCard(
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "Title",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Content Input
              buildGlassCard(
                child: TextField(
                  controller: contentController,
                  maxLines: 8,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: "How was your day? Write here...",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Image Picker Section
              buildGlassCard(
                child: Column(
                  children: [
                    if (image != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    TextButton.icon(
                      onPressed: pickImage,
                      icon: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        "Add a Photo",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Save Button
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Entry",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
