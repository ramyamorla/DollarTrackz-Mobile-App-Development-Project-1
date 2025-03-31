import 'package:flutter/material.dart';
import '../db_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final int userId;

  const EditTransactionScreen({super.key, required this.transaction, required this.userId});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final DBHelper dbHelper = DBHelper();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  List<String> categories = ['Income', 'Expense'];
  String selectedCategory = 'Expense'; // Default category

  @override
  void initState() {
    super.initState();
    _loadBudgetCategories();
    _loadTransactionData(); // Load the data to edit
  }

  // Load the transaction data into the controllers
  void _loadTransactionData() {
    setState(() {
      amountController.text = widget.transaction['amount'].toString();
      descriptionController.text = widget.transaction['description'];
      selectedCategory = widget.transaction['category'];
    });
  }

  // Fetch budget categories to populate the dropdown
  Future<void> _loadBudgetCategories() async {
    List<Map<String, dynamic>> budgets = await dbHelper.getUserBudgets(widget.userId);
    setState(() {
      categories.addAll(budgets.map((budget) => budget['category'].toString()).toList());
      categories = categories.toSet().toList(); // Remove duplicates
    });
  }

  // Update the transaction
  Future<void> _updateTransaction() async {
    double newAmount = double.tryParse(amountController.text) ?? 0;
    String newDescription = descriptionController.text;
    String newCategory = selectedCategory;

    if (newAmount > 0 && newDescription.isNotEmpty) {
      await dbHelper.updateTransaction(
        widget.transaction['id'], // Transaction ID
        newAmount,
        newCategory,
        newDescription,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated successfully')),
      );

      Navigator.pop(context, true); // Return true to refresh dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount and description')),
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
          "Edit Transaction",
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
                      "Edit Transaction Details",
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
                      inputType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // Description Input
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
                    // Update Transaction Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: TextStyle(fontSize: screenHeight * 0.022),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text("Update Transaction"),
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

  // Build a text field with modern styling
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: screenHeight * 0.02),
      ),
    );
  }

  // Build category dropdown with modern styling
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
