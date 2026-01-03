import 'package:flutter/material.dart';
import 'package:mind_care/screens/onboarding_screen2.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 120),
                Text(
                  'Reflect smarter, feel better',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 50),
                Image.asset('assets/logo.png', width: 200, fit: BoxFit.contain),
                SizedBox(height: 100),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // button color
                    foregroundColor: Colors.white,
                    minimumSize: Size(250, 50), // text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        5,
                      ), // removes round corners
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ), // height of button
                  ),
                  onPressed: getStarted,
                  child: Text('Get started', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By continuing, you agree to MindCare’s ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ), // normal text style
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(fontSize: 13, color: Colors.blue),
                        ),
                        TextSpan(
                          text: ' and ',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(fontSize: 13, color: Colors.blue),
                        ),
                        TextSpan(
                          text: '.',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getStarted() {
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen2()),
      );
    });
  }
}
