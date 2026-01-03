import 'package:flutter/material.dart';
import 'package:mind_care/screens/home.dart';
import 'package:mind_care/screens/analytics.dart';
import 'package:mind_care/screens/notes.dart';
import 'package:mind_care/screens/profile.dart';

class Template extends StatefulWidget {
  final int currentIndex; // which bottom nav item is active
  final Widget child; // page-specific content
  final String userName; // pass userName to all screens

  const Template({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.userName,
  });

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FF),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 50),
            widget.child, // <-- show page-specific content here
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.blue,
        iconSize: 25,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == _currentIndex) return;

          switch (index) {
            case 0: // Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Home(userName: widget.userName),
                ),
              );
              break;
            case 1: // Analytics
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Analytics(userName: widget.userName),
                ),
              );
              break;
            case 2: // Notes
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Notes(userName: widget.userName),
                ),
              );
              break;
            case 3: // Profile
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
