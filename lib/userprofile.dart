import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  final String userEmail;
  final String selectedTarget;

  UserProfilePage({required this.userEmail, required this.selectedTarget});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadImage(); // استرجاع الصورة عند فتح الصفحة
  }

  // 🔹 تحميل الصورة المحفوظة عند فتح التطبيق
  Future<void> _loadImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image'); // استرجاع المسار المحفوظ
    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _selectedImage = File(imagePath);
      });
    }
  }

  // 🔹 اختيار صورة وحفظها بشكل دائم
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // حفظ الصورة في مجلد دائم داخل التطبيق
      String savedImagePath = await _saveImageToAppDirectory(imageFile);

      // تخزين المسار في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', savedImagePath);

      setState(() {
        _selectedImage = File(savedImagePath);
      });
    }
  }

  // 🔹 حفظ الصورة في التخزين الدائم
  Future<String> _saveImageToAppDirectory(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory(); // مجلد التطبيق الدائم
    final String newPath = '${directory.path}/profile_picture.png'; // تحديد اسم للصورة
    await imageFile.copy(newPath); // نسخ الصورة إلى المجلد
    return newPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black45,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Colors.green.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎭 صورة الملف الشخصي - زر لاختيار صورة
                GestureDetector(
                  onTap: _pickImage, // عند الضغط يفتح معرض الصور
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: _selectedImage == null
                          ? CircleAvatar(
                              radius: 90,
                              backgroundColor: Colors.green[700],
                              child: Icon(
                                Icons.person,
                                size: 90,
                                color: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(_selectedImage!), // عرض الصورة المختارة
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // 📜 كارد معلومات المستخدم
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black45,
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoTile(
                          icon: FontAwesomeIcons.envelope,
                          title: 'Email',
                          subtitle: widget.userEmail,
                        ),
                        Divider(thickness: 1, color: Colors.green.shade300),

                        buildInfoTile(
                          icon: FontAwesomeIcons.bullseye,
                          title: 'Selected Target',
                          subtitle: widget.selectedTarget,
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

  // 🔹 ويدجت لإعادة استخدام الـ ListTile مع تنسيق متناسق
  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green[100],
          shape: BoxShape.circle,
        ),
        child: FaIcon(icon, color: Colors.green[800], size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[900]),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
      ),
    );
  }
}
