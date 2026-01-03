import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:mind_care/ai_recommendations_screens.dart';
import 'package:mind_care/screens/home.dart';
import 'package:mind_care/screens/analytics.dart';
import 'package:mind_care/screens/notes.dart';
// Import main to access the global themeNotifier
import 'package:mind_care/main.dart';

class Profile extends StatefulWidget {
  final String userName;

  const Profile({super.key, required this.userName});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final int _currentIndex = 3; // Profile tab
  String _selectedLanguage = "English"; // State to track selected language

  // --- Theme Logic ---
  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Theme",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(
                    Icons.wb_sunny_rounded,
                    color: Colors.orange,
                  ),
                  title: const Text("Light Mode"),
                  onTap: () {
                    themeNotifier.value = ThemeMode.light;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.nightlight_round,
                    color: Colors.indigo,
                  ),
                  title: const Text("Dark Mode"),
                  onTap: () {
                    themeNotifier.value = ThemeMode.dark;
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.settings_brightness_rounded,
                    color: Colors.grey,
                  ),
                  title: const Text("System Default"),
                  onTap: () {
                    themeNotifier.value = ThemeMode.system;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Language Logic ---
  void _showLanguagePicker() {
    final List<Map<String, String>> languages = [
      {"name": "English", "code": "US"},
      {"name": "Spanish", "code": "ES"},
      {"name": "French", "code": "FR"},
      {"name": "German", "code": "DE"},
      {"name": "Hindi", "code": "IN"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Language",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...languages.map(
                  (lang) => ListTile(
                    leading: Text(
                      _getFlag(lang['code']!),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(lang['name']!),
                    trailing: _selectedLanguage == lang['name']
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.blueAccent,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang['name']!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Help & Support Logic ---
  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Help & Support",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.question_answer_rounded,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Frequently Asked Questions"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.email_rounded,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Email Support"),
                  subtitle: const Text("support@mindcare.com"),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Live Chat"),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Privacy Policy Logic ---
  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(25),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Privacy Policy",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Last updated: October 2023\n\n"
                  "1. Data Collection\nWe collect minimal data to provide personalized mental health insights. Your notes and mood data are encrypted.\n\n"
                  "2. Data Usage\nWe do not sell your personal data. Your information is used only to improve your experience within Mind Care.\n\n"
                  "3. Security\nWe implement industry-standard security measures to protect your data from unauthorized access.\n\n"
                  "4. Contact Us\nIf you have questions about this policy, please reach out via the Connect with Us section.",
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "I Understand",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Connect with Us Logic ---
  void _showConnectWithUs() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Connect with Us",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialIcon(Icons.language, "Website"),
                    _buildSocialIcon(Icons.camera_alt_outlined, "Instagram"),
                    _buildSocialIcon(Icons.facebook, "Facebook"),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.blueAccent[700], size: 30),
          onPressed: () {
            // Logic for opening links would go here
            Navigator.pop(context);
          },
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _getFlag(String countryCode) {
    return countryCode.toUpperCase().replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397),
    );
  }

  @override
  Widget build(BuildContext context) {
    String avatarLetter = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : "U";

    Widget buildOption(
      String title,
      IconData icon,
      VoidCallback onTap, {
      String? subtitle,
    }) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent[700], size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.black26,
          size: 14,
        ),
        onTap: onTap,
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
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
              Center(
                child: Column(
                  children: [
                    const Divider(color: Colors.white38, height: 1, indent: 50),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueAccent[700],
                        child: Text(
                          avatarLetter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 16,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.4),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
              buildOption(
                "AI Recommendations",
                Icons.auto_awesome_rounded,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AIRecommendationsScreen(),
                    ),
                  );
                },
                subtitle: "Based on your journal mood",
              ),

              const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  "Preferences",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        buildOption(
                          "Theme",
                          Icons.palette_rounded,
                          _showThemePicker,
                        ),
                        const Divider(
                          color: Colors.white38,
                          height: 1,
                          indent: 50,
                        ),
                        buildOption(
                          "Languages",
                          Icons.translate_rounded,
                          _showLanguagePicker,
                          subtitle: _selectedLanguage,
                        ),
                        const Divider(
                          color: Colors.white38,
                          height: 1,
                          indent: 50,
                        ),
                        buildOption(
                          "Help & Support",
                          Icons.help_outline_rounded,
                          _showHelpSupport,
                        ),
                        const Divider(
                          color: Colors.white38,
                          height: 1,
                          indent: 50,
                        ),
                        buildOption(
                          "Privacy Policy",
                          Icons.lock_outline_rounded,
                          _showPrivacyPolicy,
                        ),
                        const Divider(
                          color: Colors.white38,
                          height: 1,
                          indent: 50,
                        ),
                        buildOption(
                          "Connect with Us",
                          Icons.share_rounded,
                          _showConnectWithUs,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /*ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text("AI Recommendations"),
                subtitle: const Text("Based on your journal mood"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AIRecommendationsScreen(),
                    ),
                  );
                },
              ),*/
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
