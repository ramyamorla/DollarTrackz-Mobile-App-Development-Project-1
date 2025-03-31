import 'package:flutter/material.dart';
import '../db_helper.dart';

class IncomeExpenseScreen extends StatefulWidget {
  final int userId;

  IncomeExpenseScreen({required this.userId});

  @override
  _IncomeExpenseScreenState createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String> categories = [
    'Income',
    'Expense'
  ]; // Default categories (Income and generic Expense)
  String selectedCategory = 'Expense'; // Default selected category

  @override
  void initState() {
    super.initState();
    _loadBudgetCategories();
  }

  // Fetch budget categories to populate the dropdown
  Future<void> _loadBudgetCategories() async {
    List<Map<String, dynamic>> budgets =
        await dbHelper.getUserBudgets(widget.userId);
    setState(() {
      // Avoid adding duplicate categories
      categories.addAll(
          budgets.map((budget) => budget['category'].toString()).toList());
    });
  }

  // Add transaction
  Future<void> _addTransaction() async {
    double amount = double.tryParse(amountController.text) ?? 0;
    String description = descriptionController.text;

    // Validate inputs
    if (amount <= 0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid amount and description')));
      return;
    }

    await dbHelper.addTransaction(
        widget.userId, amount, description, selectedCategory);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Transaction added successfully'),
    ));

    // Clear fields after submission
    amountController.clear();
    descriptionController.clear();

    Navigator.pop(context, true); // Return true to refresh dashboard
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Income or Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter Transaction Details",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03,
                  ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Amount input with number keyboard
            _buildTextField(
              "Amount",
              amountController,
              screenHeight,
              inputType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Description input with text keyboard
            _buildTextField(
              "Description",
              descriptionController,
              screenHeight,
              inputType: TextInputType.text,
            ),
            SizedBox(height: screenHeight * 0.02),

            // Dropdown for selecting category (Income, Expense, or budget categories)
            _buildCategoryDropdown(screenHeight),
            SizedBox(height: screenHeight * 0.05),
            Center(
              child: ElevatedButton(
                onPressed: _addTransaction,
                child: Text("Add Transaction"),
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

  // Build a text field with appropriate keyboard configuration
  Widget _buildTextField(
      String hint, TextEditingController controller, double screenHeight,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
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

  // Build category dropdown
  Widget _buildCategoryDropdown(double screenHeight) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      ),
      value: selectedCategory,
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          selectedCategory = newValue!;
        });
      },
      hint: Text("Select Category"),
    );
  }
}
