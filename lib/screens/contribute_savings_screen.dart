import 'package:flutter/material.dart';
import '../db_helper.dart';

class ContributeSavingsScreen extends StatefulWidget {
  final int userId;
  final String goalName;

  ContributeSavingsScreen({required this.userId, required this.goalName});

  @override
  _ContributeSavingsScreenState createState() =>
      _ContributeSavingsScreenState();
}

class _ContributeSavingsScreenState extends State<ContributeSavingsScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController contributionController = TextEditingController();

  void _addContribution() async {
    double contributionAmount =
        double.tryParse(contributionController.text) ?? 0;

    if (contributionAmount > 0) {
      await dbHelper.addSavingsContribution(
          widget.userId, widget.goalName, contributionAmount);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contribution added successfully')));

      // Return true to refresh the dashboard
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contribute to Savings Goal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Contribution',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.03,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            TextField(
              controller: contributionController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter Contribution Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: screenHeight * 0.015),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Center(
              child: ElevatedButton(
                onPressed: _addContribution,
                child: Text('Contribute'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: MediaQuery.of(context).size.width * 0.3),
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
}
