import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:mind_care/screens/calendar_screen.dart';
import 'package:mind_care/screens/calendar_state.dart';
import 'package:mind_care/screens/entry.dart';
//import 'package:mind_care/screens/entry_act.dart';
import 'package:mind_care/screens/analytics.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';
import 'package:mind_care/screens/notes.dart';
import 'package:mind_care/screens/profile.dart';
import 'package:mind_care/screens/relaxation_screen1.dart';

class Home extends StatefulWidget {
  final String userName;

  const Home({super.key, required this.userName});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    String avatarLetter = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : "U";

    // Reusable Glassmorphic Card
    Widget buildCard({required Widget child}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4), // Glass effect translucency
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
    }

    Widget viewAllButton(VoidCallback onPressed) {
      return Align(
        alignment: Alignment.bottomRight,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent[700],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          ),
          child: const Text(
            "View All →",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      // Modern gradient background to make glass pop
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
              const SizedBox(height: 60),

              // Header
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        avatarLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              buildCard(
                child: const Text(
                  "How are you feeling today?",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mood Entry",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      "Quick Mood Check-In",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        EmojiChoice(emoji: "😄", label: "Estatic"),
                        EmojiChoice(emoji: "🙂", label: "Good"),
                        EmojiChoice(emoji: "😐", label: "Usual"),
                        EmojiChoice(emoji: "😟", label: "Bad"),
                        EmojiChoice(emoji: "😢", label: "Horrible"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    viewAllButton(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Entry(selectedEmoji: null),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Relaxation Tools",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Breathing Guides • Mindfulness • Meditation",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    viewAllButton(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Relaxation1(
                            currentIndex: 0,
                            userName: widget.userName,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Calendar Section
              ValueListenableBuilder<DateTime>(
                valueListenable: selectedDate,
                builder: (context, date, _) {
                  return buildWeekCalendar(
                    date,
                    viewAllButton(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Calendar()),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // Glassmorphic Bottom Navigation
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.white.withOpacity(0.7),
              elevation: 0,
              unselectedItemColor: Colors.black38,
              selectedItemColor: Colors.blueAccent[700],
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                if (index == _currentIndex) return;
                switch (index) {
                  case 0:
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Analytics(userName: widget.userName),
                      ),
                    );
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Notes(userName: widget.userName),
                      ),
                    );
                    break;
                  case 3:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Profile(userName: widget.userName),
                      ),
                    );
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_rounded),
                  label: "Analytics",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sticky_note_2_rounded),
                  label: "Notes",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===================== SUPPORTING WIDGETS ===================== */

Widget buildWeekCalendar(DateTime selectedDate, Widget viewAllButton) {
  DateTime startOfWeek = selectedDate.subtract(
    Duration(days: selectedDate.weekday % 7),
  );

  List<Widget> dayCards = List.generate(7, (index) {
    DateTime day = startOfWeek.add(Duration(days: index));
    bool isSelected =
        day.day == selectedDate.day &&
        day.month == selectedDate.month &&
        day.year == selectedDate.year;

    return Column(
      children: [
        Container(
          width: 42,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.blueAccent
                  : Colors.white.withOpacity(0.5),
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                ["S", "M", "T", "W", "T", "F", "S"][day.weekday % 7],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                day.day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  });

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Calendar",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: dayCards),
      const SizedBox(height: 8),
      viewAllButton,
    ],
  );
}

////////////////////////////////////
//emoji choice class
class EmojiChoice extends StatefulWidget {
  final String emoji;
  final String label;

  const EmojiChoice({super.key, required this.emoji, required this.label});

  @override
  State<EmojiChoice> createState() => _EmojiChoiceState();
}

class _EmojiChoiceState extends State<EmojiChoice> {
  double scale = 1.0;
  //
  Future<void> _saveMoodEntry() async {
    await DBHelper.insertEntry({
      'date': DateTime.now().toIso8601String(),
      'mood': _getMood(widget.emoji)['mood'],
      'mood_value': _getMood(widget.emoji)['value'],
      'emoji': widget.emoji,
      'content': '',
      'type': 'mood',
    });
  }

  Map<String, dynamic> _getMood(String emoji) {
    return {
      "😄": {"mood": "ecstatic", "value": 5},
      "🙂": {"mood": "good", "value": 4},
      "😐": {"mood": "usual", "value": 3},
      "😟": {"mood": "bad", "value": 2},
      "😢": {"mood": "horrible", "value": 1},
    }[emoji]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 1.2),
      onTapUp: (_) async {
        setState(() => scale = 1.0);

        await _saveMoodEntry(); // 👈 THIS saves to SQLite

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Entry(selectedEmoji: widget.emoji)),
        );
      },

      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Text(widget.emoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
