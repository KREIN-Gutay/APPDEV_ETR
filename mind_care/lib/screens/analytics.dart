import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mind_care/screens/home.dart';
import 'package:mind_care/screens/notes.dart';
import 'package:mind_care/screens/profile.dart';
import 'package:mind_care/screens/lib/db/db_helper.dart';
import 'package:mind_care/screens/services/gemini_service.dart';

class Analytics extends StatefulWidget {
  final String userName;
  const Analytics({super.key, required this.userName});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  final int _currentIndex = 1;
  DateTime selectedMonth = DateTime.now();
  List<Map<String, dynamic>> entries = [];

  final Map<String, int> emojiScore = {
    "😄": 5,
    "🙂": 4,
    "😐": 3,
    "😟": 2,
    "😢": 1,
  };

  final Map<int, String> scoreEmoji = {
    5: "😄",
    4: "🙂",
    3: "😐",
    2: "😟",
    1: "😢",
  };

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    final data = await DBHelper.getEntries();
    if (!mounted) return; // Fix: Check if mounted before setState
    setState(() => entries = data);
  }

  // --- Glassmorphic Container Helper ---
  Widget buildGlassContainer({required Widget child, double? height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
  }

  List<BarChartGroupData> buildWeeklyBars() {
    DateTime now = DateTime.now();
    DateTime startWeek = now.subtract(Duration(days: now.weekday - 1));
    Map<int, List<int>> weekScores = {};

    for (var e in entries) {
      final date = DateTime.parse(e['date']);
      if (date.isAfter(startWeek.subtract(const Duration(days: 1)))) {
        final day = date.weekday;
        final score = emojiScore[e['emoji']] ?? 3;
        weekScores.putIfAbsent(day, () => []).add(score);
      }
    }

    return List.generate(7, (i) {
      final scores = weekScores[i + 1] ?? [];
      double avg = scores.isEmpty
          ? 0
          : scores.reduce((a, b) => a + b) / scores.length;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: avg,
            width: 18,
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(8),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 5,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  List<BarChartGroupData> buildMonthlyBars() {
    Map<int, List<int>> dailyScores = {};
    for (var e in entries) {
      final date = DateTime.parse(e['date']);
      if (date.month == selectedMonth.month &&
          date.year == selectedMonth.year) {
        final day = date.day;
        final score = emojiScore[e['emoji']] ?? 3;
        dailyScores.putIfAbsent(day, () => []).add(score);
      }
    }
    return dailyScores.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) / e.value.length;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: avg,
            width: 10,
            color: Colors.blueAccent.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget chart(List<BarChartGroupData> bars, bool weekly) {
    return BarChart(
      BarChartData(
        maxY: 5,
        minY: 0,
        barGroups: bars,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.black.withOpacity(0.05), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rod.toY == 0) return null;
              return BarTooltipItem(
                scoreEmoji[rod.toY.round().clamp(1, 5)]!,
                const TextStyle(fontSize: 20),
              );
            },
          ),
          handleBuiltInTouches: true,
          touchCallback: (event, response) {
            if (event is FlTapUpEvent &&
                response != null &&
                response.spot != null) {
              final value = response.spot!.touchedRodData.toY.round().clamp(
                1,
                5,
              );
              final emoji = scoreEmoji[value]!;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => EmojiAnalysisSheet(emoji: emoji),
              );
            }
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, _) => Text(
                val.toInt().toString(),
                style: const TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                if (weekly) {
                  const days = ["M", "T", "W", "T", "F", "S", "S"];
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  );
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.black38, fontSize: 10),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
              const Text(
                "Weekly Insights",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 15),
              buildGlassContainer(
                height: 250,
                child: chart(buildWeeklyBars(), true),
              ),
              const SizedBox(height: 15),
              AISuggestionCard(entries: entries, type: SuggestionType.weekly),
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Monthly Trends",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.blueAccent,
                      ),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedMonth,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && mounted) {
                        setState(() => selectedMonth = picked);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              buildGlassContainer(
                height: 250,
                child: chart(buildMonthlyBars(), false),
              ),
              const SizedBox(height: 15),
              AISuggestionCard(
                entries: entries,
                type: SuggestionType.monthly,
                targetMonth: selectedMonth,
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Home(userName: widget.userName),
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

enum SuggestionType { weekly, monthly }

class AISuggestionCard extends StatefulWidget {
  final List<Map<String, dynamic>> entries;
  final SuggestionType type;
  final DateTime? targetMonth;

  const AISuggestionCard({
    super.key,
    required this.entries,
    required this.type,
    this.targetMonth,
  });

  @override
  State<AISuggestionCard> createState() => _AISuggestionCardState();
}

class _AISuggestionCardState extends State<AISuggestionCard> {
  String suggestion = "Generating insights...";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    generateInsights();
  }

  @override
  void didUpdateWidget(AISuggestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetMonth != widget.targetMonth ||
        oldWidget.entries.length != widget.entries.length) {
      generateInsights();
    }
  }

  Future<void> generateInsights() async {
    if (!mounted) return;
    setState(() => loading = true);

    DateTime now = DateTime.now();
    String periodText = "";
    List<String> contents = [];

    if (widget.type == SuggestionType.weekly) {
      periodText = "this week";
      DateTime startWeek = now.subtract(Duration(days: now.weekday - 1));
      contents = widget.entries
          .where(
            (e) => DateTime.parse(
              e['date'],
            ).isAfter(startWeek.subtract(const Duration(days: 1))),
          )
          .map((e) => "[${e['emoji']}] ${e['content']}")
          .toList();
    } else {
      DateTime target = widget.targetMonth ?? now;
      periodText = "the month of ${target.month}/${target.year}";
      contents = widget.entries
          .where((e) {
            final date = DateTime.parse(e['date']);
            return date.month == target.month && date.year == target.year;
          })
          .map((e) => "[${e['emoji']}] ${e['content']}")
          .toList();
    }

    if (contents.isEmpty) {
      if (!mounted) return;
      setState(() {
        suggestion =
            "Not enough data for $periodText to provide AI suggestions.";
        loading = false;
      });
      return;
    }

    final prompt =
        "Based on these journal entries from $periodText, provide a brief summary of the overall emotional trend and 3 personalized wellness suggestions: \n${contents.join('\n')}";
    final result = await GeminiService.analyzeEmotion(prompt);

    if (!mounted) return; // Fix: Check if mounted after async call
    setState(() {
      suggestion = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.type == SuggestionType.weekly
                        ? "Weekly AI Summary"
                        : "Monthly AI Insights",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                )
              else
                Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmojiAnalysisSheet extends StatefulWidget {
  final String emoji;
  const EmojiAnalysisSheet({super.key, required this.emoji});
  @override
  State<EmojiAnalysisSheet> createState() => _EmojiAnalysisSheetState();
}

class _EmojiAnalysisSheetState extends State<EmojiAnalysisSheet> {
  String analysis = "Deeply analyzing your patterns...";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    analyze();
  }

  Future<void> analyze() async {
    final entries = await DBHelper.getEntries();
    final filtered = entries
        .where((e) => e['emoji'] == widget.emoji)
        .map((e) => e['content'])
        .join("\n");

    if (filtered.isEmpty) {
      if (!mounted) return;
      setState(() {
        analysis = "No entries found for this mood.";
        loading = false;
      });
      return;
    }

    final result = await GeminiService.analyzeEmotion(filtered);

    if (!mounted) return; // Fix: Check if mounted after async call
    setState(() {
      analysis = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(widget.emoji, style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 10),
              const Text(
                "Pattern Analysis",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 15),
              if (loading)
                const CircularProgressIndicator()
              else
                Text(
                  analysis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
