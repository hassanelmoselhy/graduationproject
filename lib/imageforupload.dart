import 'package:finalpro/uploadvideo.dart';
import 'package:flutter/material.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 


final List<Map<String, dynamic>> exercises = [
    {'name': 'Push-up', 'time': '2m 26s', 'icon': FontAwesomeIcons.personPraying  },
    {'name': 'pull-up', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines },
    {'name': 'Squats', 'time': '3m 10s', 'icon': FontAwesomeIcons.personArrowDownToLine },
    {'name': 'jumping-jacks', 'time': '2m 15s', 'icon': FontAwesomeIcons.personWalking },
    {'name': 'sit-up', 'time': '4m 2s', 'icon': FontAwesomeIcons.personRunning },
     {'name': 'Straight leg raise', 'time': '2m 26s', 'icon': FontAwesomeIcons.personPraying },
    {'name': 'Bridging', 'time': '1m 30s', 'icon': FontAwesomeIcons.gripLines },
   
  ]; 


class ImageScreen9 extends StatelessWidget {
  final int index;

  ImageScreen9({required this.index}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sphinx Push-Up'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/sphinx-push-up.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ), 
            ),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ImageScreen10 extends StatelessWidget { 
  final int index;

  ImageScreen10({required this.index}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pull-up'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/Archer-Pull-up.webp'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ),),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class ImageScreen11 extends StatelessWidget { 
  final int index;

  ImageScreen11({required this.index}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sphinx squat'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/bodyweight-squat.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ),),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class ImageScreen12 extends StatelessWidget {
  final int index;

  ImageScreen12({required this.index}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sphinx jumping-jacks'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/content_blog_inner_E4B1CDF6.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ),),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class ImageScreen13 extends StatelessWidget {
  final int index;

  ImageScreen13({required this.index}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sphinx sit-Up'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/42bea75f7d4c5d944d6a6380ddfb4285.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ),),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class ImageScreen14 extends StatelessWidget {
  final int index;

  ImageScreen14({required this.index}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Straight leg raise'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/7e0a9ca809c5a41e6f525d4590eb05ae.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ),),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ImageScreen15 extends StatelessWidget {
  final int index;

  ImageScreen15({required this.index}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bridging'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Image.asset('assets/images/giphy.gif'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadPage(
                exerciseName: exercises[index]['name']!,
              ),),
          );
        },
        child: Text('Done'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

 