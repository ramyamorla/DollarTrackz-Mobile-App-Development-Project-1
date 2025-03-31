import 'package:flutter/material.dart';
import '../db_helper.dart';

class SavingsGoalScreen extends StatefulWidget {
  final int userId;

  SavingsGoalScreen({required this.userId});

  @override
  _SavingsGoalScreenState createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController goalController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // Add savings goal to the database
  void _addSavingsGoal() async {
    double goalAmount = double.tryParse(amountController.text) ?? 0;
    String goalName = goalController.text;

    if (goalAmount > 0 && goalName.isNotEmpty) {
      // Call the db_helper to add the savings goal
      await dbHelper.addSavingsGoal(widget.userId, goalName, goalAmount, 0.0);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Savings goal added successfully')));

      // Return true to indicate data was added and reload the dashboard
      Navigator.pop(context, true);
    } else {
      // Display an error message if the input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid goal name and amount')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Savings Goal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set Savings Goal",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03,
                  ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Goal Name Input
            _buildTextField("Goal Name", goalController, screenHeight),

            SizedBox(height: screenHeight * 0.02),

            // Goal Amount Input
            _buildTextField("Goal Amount", amountController, screenHeight,
                keyboardType: TextInputType.number), // Accept only numbers

            SizedBox(height: screenHeight * 0.05),

            // Add Button
            Center(
              child: ElevatedButton(
                onPressed: _addSavingsGoal,
                child: Text("Add Goal"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.3),
                  textStyle: TextStyle(fontSize: screenHeight * 0.02),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a text field with appropriate keyboard type
  Widget _buildTextField(
      String hint, TextEditingController controller, double screenHeight,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hint, // Using label text to make UI more formal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0, vertical: screenHeight * 0.015),
      ),
    );
  }
}
