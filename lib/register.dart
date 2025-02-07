import 'package:finalpro/welcomepage.dart';
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

  // دالة التسجيل
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          await firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': _nameController.text,
            'phone': _phoneController.text,
            'email': _emailController.text,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage(userEmail: _emailController.text,)),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed: ${e.message}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // تعديل حجم الواجهة لتجنب مشاكل لوحة المفاتيح
      body: SingleChildScrollView( // إضافة تمرير لتجنب التجاوز
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // تعديل الحشو
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // لجعل العناصر تأخذ كامل العرض
              children: [
                SizedBox(height: 50), // مساحة فارغة في الأعلى
                Text(
                  'Sign up',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Create account',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _buildTextField(_nameController, 'Name', 'Please enter your name', icon: Icons.person),
                SizedBox(height: 15),
                _buildTextField(
                  _phoneController,
                  'Phone',
                  'Please enter your phone number',
                  icon: Icons.phone,
                  phoneValidator: true,
                ),
                SizedBox(height: 15),
                _buildTextField(
                  _emailController,
                  'E-mail',
                  'Please enter a valid email',
                  icon: Icons.email,
                  emailValidator: true,
                ),
                SizedBox(height: 15),
                _buildTextField(
                  _passwordController,
                  'Password',
                  'Password must be at least 6 characters',
                  obscureText: true,
                  icon: Icons.lock,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xFF00C779),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Already have an account? Log in"),
                ),
                SizedBox(height: 20), // لإضافة مساحة قبل نهاية الشاشة
              ],
            ),
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
    bool phoneValidator = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return errorMessage;
        } else if (emailValidator && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        } else if (obscureText && value.length < 6) {
          return 'Password must be at least 6 characters';
        } else if (phoneValidator && value.length != 11) {
          return 'Phone number must be exactly 11 digits';
        }
        return null;
      },
    );
  }
}
