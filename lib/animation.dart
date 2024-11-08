import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:finalpro/Login.dart';

import 'package:flutter/material.dart';


class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00C779),
      body: Center(
        child: AnimatedTextKit(
          animatedTexts: [
            TyperAnimatedText(
              'Therapuls',
              textStyle: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
              speed: Duration(milliseconds: 200),
            ),
            TyperAnimatedText(
              'More! healthy life...',
              textStyle: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
              speed: Duration(milliseconds: 200),
            ),
            TyperAnimatedText(
              'Helps! improve athletic performance...',
              textStyle: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
              speed: Duration(milliseconds: 200),
            ),
            TyperAnimatedText(
              'Assistant! Your treatment journey...',
              textStyle: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
              speed: Duration(milliseconds: 200),
            ),
          ],
          repeatForever: false,
          totalRepeatCount: 1, // عرض الأنيميشن مرة واحدة فقط
          pause: Duration(seconds: 2),
          onFinished: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
    );
  }
}