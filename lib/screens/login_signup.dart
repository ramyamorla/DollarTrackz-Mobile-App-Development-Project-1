import 'package:flutter/material.dart';
import '../db_helper.dart';

class LoginSignupScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  LoginSignupScreen({required this.toggleTheme, required this.isDarkMode});

  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;
  String email = '';
  String password = '';
  String confirmPassword = '';

  final DBHelper dbHelper = DBHelper();

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void registerUser() async {
    if (password == confirmPassword) {
      await dbHelper.registerUser(email, password);
      var user = await dbHelper.loginUser(email, password);
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Passwords do not match')));
    }
  }

  void loginUser() async {
    var user = await dbHelper.loginUser(email, password);

    // Check if user and user['id'] are valid
    if (user != null && user['id'] != null) {
      int userId = user['id'] as int; // Safe cast to int
      Navigator.pushReplacementNamed(context, '/dashboard', arguments: userId);
    } else {
      // Show error if the user is not found or the ID is null
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid credentials or user not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(isLogin ? "Login" : "Sign Up"),
        backgroundColor:
            widget.isDarkMode ? Colors.grey[900] : Colors.blueAccent,
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: (value) {
              widget.toggleTheme(value);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo at the top of the form
            Image.asset(
              'images/appLogo.png', // Adjust the path to your logo
              height: 100, // Adjust height for the logo
            ),
            SizedBox(height: 20),
            Text(
              'Personal Finance Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 40),
            _buildTextField("Email", false, (value) => email = value),
            SizedBox(height: 20),
            _buildTextField("Password", true, (value) => password = value),
            if (!isLogin)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: _buildTextField("Confirm Password", true,
                    (value) => confirmPassword = value),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isLogin) {
                  loginUser();
                } else {
                  registerUser();
                }
              },
              child: Text(isLogin ? "Login" : "Sign Up"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: toggleForm,
              child: Text(
                isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hint, bool isPassword, Function(String) onChanged) {
    return TextField(
      obscureText: isPassword,
      style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      onChanged: onChanged,
    );
  }
}
