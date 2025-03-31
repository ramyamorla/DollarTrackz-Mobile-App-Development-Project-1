import 'package:flutter/material.dart';
import '../db_helper.dart';

class BudgetScreen extends StatefulWidget {
  final int userId;

  BudgetScreen({required this.userId});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  // Add a new budget to the database
  void _addBudget() async {
    double amount = double.tryParse(amountController.text) ?? 0;
    String category = categoryController.text;

    if (amount > 0 && category.isNotEmpty) {
      // Call db_helper to add the new budget
      await dbHelper.addBudget(widget.userId, category, amount);

      // Show success message and close the screen
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Budget added successfully')));

      // Return true to indicate data was added and refresh the dashboard
      Navigator.pop(context, true);
    } else {
      // Show error message if the input is invalid
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter valid data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Budget"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Budget",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03,
                  ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Amount Input
            _buildTextField(
              "Amount",
              amountController,
              screenHeight,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Category Input
            _buildTextField(
              "Category",
              categoryController,
              screenHeight,
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: screenHeight * 0.05),

            // Add Budget Button
            Center(
              child: ElevatedButton(
                onPressed: _addBudget,
                child: Text("Add Budget"),
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

  // Build text field with proper keyboard type
  Widget _buildTextField(
      String hint, TextEditingController controller, double screenHeight,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0, vertical: screenHeight * 0.015),
      ),
    );
  }
}
