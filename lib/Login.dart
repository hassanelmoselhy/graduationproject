import 'package:finalpro/register.dart';
import 'package:finalpro/train.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomePage(user: userCredential.user!)),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: ${e.message}")));
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String labelText,
    String validationMessage, {
    bool obscureText = false,
    bool emailValidator = false,
    Icon? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,  // Adding the icon to the field
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),  // Border radius adjustment
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        } else if (emailValidator && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
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
              // Adjusted the "Welcome Back" and "Sign in to your account" placement
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Text('Welcome Back 👋', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Sign in to your account', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Updated text fields with icons and border radius
              _buildTextField(
                _emailController, 
                'E-mail', 
                'Please enter a valid email', 
                emailValidator: true,
                prefixIcon: Icon(Icons.email, color: Colors.grey),
              ),
              SizedBox(height: 20),
              _buildTextField(
                _passwordController, 
                'Password', 
                'Please enter your password', 
                obscureText: true,
                prefixIcon: Icon(Icons.lock, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Log in'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50), backgroundColor: Color(0xFF00C779)),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage())),
                child: Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
