import 'package:flutter/material.dart';
import '../db_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>
      transaction; // Passing the whole transaction object
  final int userId;

  EditTransactionScreen({required this.transaction, required this.userId});

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
    List<Map<String, dynamic>> budgets =
        await dbHelper.getUserBudgets(widget.userId);
    setState(() {
      // Add unique budget categories to the list
      categories.addAll(
          budgets.map((budget) => budget['category'].toString()).toList());
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transaction updated successfully'),
      ));

      Navigator.pop(context, true); // Return true to refresh dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please enter a valid amount and description')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Edit Transaction Details",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenHeight * 0.03,
                  ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Amount input field with numeric keyboard
            _buildTextField(
              "Amount",
              amountController,
              screenHeight,
              inputType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Description input field with text keyboard
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
                onPressed: _updateTransaction,
                child: Text("Update Transaction"),
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

  // Build a text field with proper keyboard type
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
