import 'package:flutter/material.dart';
import '../db_helper.dart';

class ContributeSavingsScreen extends StatefulWidget {
  final int userId;
  final String goalName;

  const ContributeSavingsScreen({super.key, required this.userId, required this.goalName});

  @override
  _ContributeSavingsScreenState createState() => _ContributeSavingsScreenState();
}

class _ContributeSavingsScreenState extends State<ContributeSavingsScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController contributionController = TextEditingController();

  void _addContribution() async {
    double contributionAmount = double.tryParse(contributionController.text) ?? 0;

    if (contributionAmount > 0) {
      await dbHelper.addSavingsContribution(widget.userId, widget.goalName, contributionAmount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contribution added successfully')),
      );

      // Return true to refresh the dashboard
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
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
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Contribute to Savings Goal',
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
                  children: [
                    Text(
                      'Add Contribution',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.03,
                            color: Colors.deepPurple,
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    _buildTextField(
                      'Contribution Amount',
                      contributionController,
                      screenHeight,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addContribution,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: TextStyle(fontSize: screenHeight * 0.022),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text('Contribute'),
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

  // Build text field with modern styling
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
