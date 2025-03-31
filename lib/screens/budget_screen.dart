import 'package:flutter/material.dart';
import '../db_helper.dart';

class BudgetScreen extends StatefulWidget {
  final int userId;

  const BudgetScreen({super.key, required this.userId});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget added successfully')),
      );

      // Return true to indicate data was added and refresh the dashboard
      Navigator.pop(context, true);
    } else {
      // Show error message if the input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Add Budget",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create Budget",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.03,
                            color: Colors.deepPurple,
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Amount Input
                    _buildTextField(
                      "Amount",
                      amountController,
                      screenHeight,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Category Input
                    _buildTextField(
                      "Category",
                      categoryController,
                      screenHeight,
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Add Budget Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addBudget,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: TextStyle(fontSize: screenHeight * 0.022),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text("Add Budget"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        labelStyle: const TextStyle(color: Colors.deepPurple),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0, vertical: screenHeight * 0.02),
      ),
    );
  }
}
