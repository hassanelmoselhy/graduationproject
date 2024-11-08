import 'package:finalpro/train.dart'; // قم بتعديل هذا وفقًا لصفحة الترحيب الخاصة بك
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // هذه الدالة تنفذ عند النقر على زر التسجيل
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 1. إنشاء مستخدم جديد باستخدام Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          // 2. إضافة بيانات المستخدم إلى Firestore
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
          });

          // 3. الانتقال إلى صفحة الترحيب بعد التسجيل
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage(user: userCredential.user!)),
          );
        }
      } on FirebaseAuthException catch (e) {
        // عرض رسالة خطأ عند فشل التسجيل
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed: ${e.message}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sign up', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Create account', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 40),
              // Adding icons and changing border radius
              _buildTextField(_nameController, 'Name', 'Please enter your name', icon: Icons.person),
              SizedBox(height: 20),
              _buildTextField(_phoneController, 'Phone', 'Please enter your phone number', icon: Icons.phone),
              SizedBox(height: 20),
              _buildTextField(_emailController, 'E-mail', 'Please enter a valid email', icon: Icons.email, emailValidator: true),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Password', 'Password must be at least 6 characters', obscureText: true, icon: Icons.lock),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Color(0xFF00C779)),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Already have an account? Log in"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String errorMessage, {
    bool obscureText = false,
    bool emailValidator = false,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null, // Add icon to the field
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), // Adjust border radius
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        } else if (emailValidator && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        } else if (obscureText && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}
