import 'package:finalpro/Login.dart';
import 'package:finalpro/coachordoctor.dart';
import 'package:finalpro/userprofile.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  final String userEmail; // سيتم تمرير البريد الإلكتروني من صفحة تسجيل الدخول

  WelcomePage({required this.userEmail});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String selectedTarget = "Fitness"; // القيمة الافتراضية للقائمة
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) { // زر Go
            if (selectedTarget == "Fitness") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CoachesPage(title: 'coaches')),
              );
            } else if (selectedTarget == "Physical Therapy") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => doctorPage(title: 'doctor')),
              );
            }
          } else if (index == 2) { // زر Profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  userEmail: widget.userEmail,
                  selectedTarget: selectedTarget,
                ),
              ),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward),
            label: 'Go',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Target 🎯"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Target 🎯",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedTarget,
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.black, fontSize: 18),
              underline: Container(
                height: 2,
                color: Colors.green,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTarget = newValue!;
                });
              },
              items: <String>['Fitness', 'Physical Therapy']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}