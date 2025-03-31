import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;
  final int userId;

  ProfileSettingsScreen({
    required this.toggleTheme,
    required this.isDarkMode,
    required this.userId,
  });

  void _logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile & Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text("Dark Mode"),
              value: isDarkMode,
              onChanged: (value) {
                toggleTheme(value);
              },
            ),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
