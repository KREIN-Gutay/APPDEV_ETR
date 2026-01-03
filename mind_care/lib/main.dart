import 'package:flutter/material.dart';
import 'package:mind_care/screens/onboarding_screen1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// We use a ValueNotifier to hold the current ThemeMode.
// This is globally accessible so the Profile screen can update it.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the MaterialApp in a ValueListenableBuilder.
    // Whenever themeNotifier.value changes, this builder runs again.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mind Care',

          // Define the Light Theme
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFE0EAFC),
          ),

          // Define the Dark Theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          ),

          // This links the MaterialApp to our notifier
          themeMode: currentMode,

          home: const OnboardingScreen1(),
        );
      },
    );
  }
}
