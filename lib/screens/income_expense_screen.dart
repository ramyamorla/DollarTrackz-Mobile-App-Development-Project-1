import 'package:flutter/material.dart';
import '../db_helper.dart';

class IncomeExpenseScreen extends StatefulWidget {
  final int userId;

  const IncomeExpenseScreen({super.key, required this.userId});

  @override
  _IncomeExpenseScreenState createState() => _IncomeExpenseScreenState();
}

class _IncomeExpenseScreenState extends State<IncomeExpenseScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String> categories = ['Income', 'Expense'];
  String selectedCategory = 'Expense';

  @override
  void initState() {
    super.initState();
    _loadBudgetCategories();
  }

  // Fetch budget categories to populate the dropdown and remove duplicates
  Future<void> _loadBudgetCategories() async {
    List<Map<String, dynamic>> budgets =
        await dbHelper.getUserBudgets(widget.userId);
    setState(() {
      categories.addAll(budgets.map((budget) => budget['category'].toString()));
      categories = categories.toSet().toList();
    });
  }

  // Add transaction to the database
  Future<void> _addTransaction() async {
    double amount = double.tryParse(amountController.text) ?? 0;
    String description = descriptionController.text;

    if (amount <= 0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount and description'),
        ),
      );
      return;
    }

    await dbHelper.addTransaction(
        widget.userId, amount, description, selectedCategory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction added successfully'),
      ),
    );

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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Add Income or Expense",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
                      "Enter Transaction Details",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: screenHeight * 0.03,
                            color: Colors.deepPurple,
                          ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Amount Input Field
                    _buildTextField(
                      "Amount",
                      amountController,
                      screenHeight,
                      inputType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Description Input Field
                    _buildTextField(
                      "Description",
                      descriptionController,
                      screenHeight,
                      inputType: TextInputType.text,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Category Dropdown
                    _buildCategoryDropdown(screenHeight),
                    SizedBox(height: screenHeight * 0.04),
                    // Add Transaction Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: TextStyle(fontSize: screenHeight * 0.022),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text("Add Transaction"),
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
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
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

  // Build a dropdown with consistent styling
  Widget _buildCategoryDropdown(double screenHeight) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Select Category",
        labelStyle: const TextStyle(color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
    );
  }
}
