import 'package:flutter/material.dart';
import '../db_helper.dart';

class LoginSignupScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const LoginSignupScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;
  String email = '';
  String password = '';
  String confirmPassword = '';
  final DBHelper dbHelper = DBHelper();
  final _formKey = GlobalKey<FormState>();

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (password == confirmPassword) {
        await dbHelper.registerUser(email, password);
        var user = await dbHelper.loginUser(email, password);
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/dashboard', arguments: user['id']);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
    }
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      var user = await dbHelper.loginUser(email, password);
      if (user != null && user['id'] != null) {
        int userId = user['id'] as int;
        Navigator.pushReplacementNamed(context, '/dashboard', arguments: userId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials or user not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define theme colors based on dark mode setting
    final bgColor = widget.isDarkMode ? Colors.black : Colors.grey[200]!;
    final appBarColor = widget.isDarkMode ? Colors.grey[900]! : Colors.deepPurple;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final inputFillColor = widget.isDarkMode ? Colors.grey[800]! : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        centerTitle: true,
        title: Text(
          isLogin ? "Login" : "Sign Up",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: (value) {
              widget.toggleTheme(value);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              children: [
                // Logo and Title
                Image.asset(
                  'images/appLogo.jpeg', // Adjust the path to your logo
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Personal Finance Manager',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),
                // Form within a Card for a modern look
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField("Email", false, (value) => email = value, textColor, inputFillColor),
                          const SizedBox(height: 20),
                          _buildTextField("Password", true, (value) => password = value, textColor, inputFillColor),
                          if (!isLogin) ...[
                            const SizedBox(height: 20),
                            _buildTextField("Confirm Password", true, (value) => confirmPassword = value, textColor, inputFillColor),
                          ],
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLogin ? loginUser : registerUser,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                textStyle: const TextStyle(fontSize: 18),
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(isLogin ? "Login" : "Sign Up"),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: toggleForm,
                            child: Text(
                              isLogin
                                  ? "Don't have an account? Sign Up"
                                  : "Already have an account? Login",
                              style: const TextStyle(color: Colors.deepPurple),
                            ),
                          ),
                        ],
                      ),
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

  // Build a TextFormField with modern styling and validation
  Widget _buildTextField(
      String hint, bool isPassword, Function(String) onChanged, Color textColor, Color fillColor) {
    return TextFormField(
      obscureText: isPassword,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.deepPurple),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$hint cannot be empty';
        }
        if (hint == "Email" && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}').hasMatch(value)) {
          return 'Enter a valid email';
        }
        if ((hint == "Password" || hint == "Confirm Password") && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
