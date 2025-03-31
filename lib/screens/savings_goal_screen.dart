import 'package:flutter/material.dart';
import '../db_helper.dart';

class SavingsGoalScreen extends StatefulWidget {
  final int userId;

  const SavingsGoalScreen({super.key, required this.userId});

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
      await dbHelper.addSavingsGoal(widget.userId, goalName, goalAmount, 0.0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Savings goal added successfully')),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid goal name and amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Add Savings Goal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set Savings Goal",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.03,
                            color: Colors.deepPurple,
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildTextField("Goal Name", goalController, screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTextField(
                      "Goal Amount",
                      amountController,
                      screenHeight,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSavingsGoal,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: TextStyle(fontSize: screenHeight * 0.022),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Add Goal"),
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

  // Build a text field with consistent styling
  Widget _buildTextField(String hint, TextEditingController controller, double screenHeight,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: screenHeight * 0.02),
      ),
    );
  }
}
