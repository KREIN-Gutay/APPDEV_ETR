import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mind_care/screens/home.dart';
import 'package:mind_care/screens/analytics.dart';
import 'package:mind_care/screens/notes.dart';
import 'package:mind_care/screens/profile.dart';
import 'relaxation_widgets.dart';
import 'breathing_timer_screen.dart';
import 'breathing_guides_screen.dart';
import 'mindfulness_tips_screen.dart';
import 'short_meditation_screen.dart';
import 'quotes_screen.dart'; // NEW IMPORT
//import 'package:mind_care/widgets/glass_card.dart';

class Relaxation1 extends StatefulWidget {
  final int currentIndex;
  final String userName;

  const Relaxation1({
    super.key,
    required this.currentIndex,
    required this.userName,
  });

  @override
  State<Relaxation1> createState() => _Relaxation1State();
}

class _Relaxation1State extends State<Relaxation1> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, bottom: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.black87,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Relaxation Tools",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              SliverGrid(
                delegate: SliverChildListDelegate([
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BreathingGuidesScreen(
                          buildGlassCard: buildGlassCard,
                        ),
                      ),
                    ),
                    child: ToolCard(
                      title: "Breathing Guides",
                      subtitle: "Short guided breathing exercises...",
                      icon: Icons.air_rounded,
                      glassWrapper: buildGlassCard,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MindfulnessTipsScreen(
                          buildGlassCard: buildGlassCard,
                        ),
                      ),
                    ),
                    child: ToolCard(
                      title: "Mindfulness Tips",
                      subtitle: "Quick practices...",
                      icon: Icons.self_improvement_rounded,
                      glassWrapper: buildGlassCard,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShortMeditationScreen(
                          buildGlassCard: buildGlassCard,
                        ),
                      ),
                    ),
                    child: ToolCard(
                      title: "Short Meditations",
                      subtitle: "2–10 minutes rest.",
                      icon: Icons.spa_rounded,
                      glassWrapper: buildGlassCard,
                    ),
                  ),
                  // UPDATED: MOTIVATIONAL QUOTES NAVIGATION
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            QuotesScreen(buildGlassCard: buildGlassCard),
                      ),
                    ),
                    child: ToolCard(
                      title: "Motivational Quotes",
                      subtitle: "Uplifting messages...",
                      icon: Icons.format_quote_rounded,
                      glassWrapper: buildGlassCard,
                    ),
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
              const SliverToBoxAdapter(
                child: Text(
                  "Featured",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 15)),
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BreathingTimerScreen(
                        title: "Box Breathing",
                        durationSeconds: 180,
                        buildGlassCard: buildGlassCard,
                      ),
                    ),
                  ),
                  child: FeaturedCard(
                    title: "Box Breathing",
                    subtitle: "Square pattern for focus",
                    duration: "3 min",
                    glassWrapper: buildGlassCard,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              if (index == _currentIndex) return;
              Widget nextScreen;
              switch (index) {
                case 0:
                  nextScreen = Home(userName: widget.userName);
                  break;
                case 1:
                  nextScreen = Analytics(userName: widget.userName);
                  break;
                case 2:
                  nextScreen = Notes(userName: widget.userName);
                  break;
                default:
                  nextScreen = Profile(userName: widget.userName);
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => nextScreen),
              );
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
    );
  }
}
