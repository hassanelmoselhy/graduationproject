import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  final User user;

  WelcomePage({required this.user});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  DocumentSnapshot<Map<String, dynamic>>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // جلب بيانات المستخدم من Firestore باستخدام UID
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('users').doc(widget.user.uid).get();

      setState(() {
        userData = snapshot;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      // يمكنك عرض رسالة للمستخدم هنا في حال فشل جلب البيانات
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: userData != null
          ? userData!.exists // التحقق من وجود المستند قبل الوصول إلى البيانات
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome, ${userData!['name'] ?? ''}", style: TextStyle(fontSize: 24)),
                      Text("Phone: ${userData!['phone'] ?? ''}", style: TextStyle(fontSize: 18)),
                      Text("Email: ${userData!['email'] ?? ''}", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : Center(child: Text("User data not found."))
          : Center(child: CircularProgressIndicator()), // عرض مؤشر التحميل حتى يتم جلب البيانات
    );
  }
}
