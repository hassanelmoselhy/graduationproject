import 'package:finalpro/Login.dart';
import 'package:finalpro/coachordoctor.dart';
import 'package:finalpro/userprofile.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  final String userEmail;

  WelcomePage({required this.userEmail});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String selectedTarget = "Fitness"; 
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            if (index == 1) { 
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
            } else if (index == 2) { 
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
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          elevation: 10,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_forward, size: 28),
              label: 'Go',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28),
              label: 'Profile',
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Text(
          "Target 🎯",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 28),
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
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 25),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green.shade100,
                border: Border.all(color: Colors.green.shade700, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedTarget,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade800, size: 30),
                  iconSize: 24,
                  elevation: 16,
                  dropdownColor: Colors.green.shade50,
                  style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTarget = newValue!;
                    });
                  },
                  items: <String>['Fitness', 'Physical Therapy']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
