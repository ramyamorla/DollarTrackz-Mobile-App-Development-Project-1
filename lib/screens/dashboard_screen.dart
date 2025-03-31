import 'package:flutter/material.dart';
import '../db_helper.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  DashboardScreen({required this.userId});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> budgets = [];
  List<Map<String, dynamic>> savingsGoals = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Load user data from DB based on userId
  void loadUserData() async {
    try {
      transactions = await dbHelper.getUserTransactions(widget.userId);
      budgets = await dbHelper.getUserBudgets(widget.userId);
      savingsGoals = await dbHelper.getUserSavingsGoals(widget.userId);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  // Function to delete a transaction
  void _deleteTransaction(int transactionId) async {
    await dbHelper.deleteTransaction(transactionId);
    loadUserData(); // Refresh the list after deletion
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Transaction deleted')));
  }

  // Function to edit a transaction
  void _editTransaction(Map<String, dynamic> transaction) {
    Navigator.pushNamed(context, '/edit_transaction', arguments: transaction)
        .then((value) {
      if (value == true) {
        loadUserData(); // Refresh the list after editing
      }
    });
  }

  // Function to show the add options (income/expense, budget, savings goal)
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Action",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text("Add Income or Expense"),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(
                      context, '/income_expense',
                      arguments: widget.userId);
                  if (result == true) {
                    loadUserData();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.pie_chart),
                title: Text("Add Budget"),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(context, '/budget',
                      arguments: widget.userId);
                  if (result == true) {
                    loadUserData();
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.savings),
                title: Text("Add Savings Goal"),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(
                      context, '/savings_goal',
                      arguments: widget.userId);
                  if (result == true) {
                    loadUserData();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/profile_settings',
                arguments: widget.userId),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionTitle('Transactions', screenHeight),
                    transactions.isEmpty
                        ? Center(child: Text('No transactions available.'))
                        : _buildTransactionList(transactions, screenHeight),
                    SizedBox(height: 20),
                    _buildSectionTitle('Budgets', screenHeight),
                    budgets.isEmpty
                        ? Center(child: Text('No budgets available.'))
                        : _buildBudgetList(budgets, screenHeight),
                    SizedBox(height: 20),
                    _buildSectionTitle('Savings Goals', screenHeight),
                    savingsGoals.isEmpty
                        ? Center(child: Text('No savings goals available.'))
                        : _buildSavingsGoalList(savingsGoals, screenHeight),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions, // Show add options when clicked
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenHeight * 0.03,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      List<Map<String, dynamic>> transactions, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        bool isIncome = transaction['category'] == 'Income';

        return Card(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(screenHeight * 0.02),
            leading: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: isIncome ? Colors.green : Colors.red,
            ),
            title: Text(
              '\$${transaction['amount']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.022,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            subtitle: Text(transaction['description']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_transaction',
                      arguments: {
                        'transaction':
                            transaction, // Passing the transaction object
                        'userId': widget.userId, // Passing the user ID
                      },
                    ).then((value) {
                      if (value == true) {
                        loadUserData(); // Refresh the data after editing
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTransaction(transaction['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBudgetList(
      List<Map<String, dynamic>> budgets, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(screenHeight * 0.02),
            title: Text(
              '${budget['category']} - \$${budget['budget_limit']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenHeight * 0.022,
              ),
            ),
            subtitle: Text('Spent: \$${budget['spent']}'),
          ),
        );
      },
    );
  }

  // Savings Goal List with "Contribute" button
  Widget _buildSavingsGoalList(
      List<Map<String, dynamic>> savingsGoals, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: savingsGoals.length,
      itemBuilder: (context, index) {
        final savings = savingsGoals[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(screenHeight * 0.02),
            title: Text(savings['goal_name']),
            subtitle: Text(
              'Goal: \$${savings['goal_amount']} Saved: \$${savings['saved_amount']}',
            ),
            trailing: ElevatedButton(
              child: Text('Contribute'),
              onPressed: () {
                // Navigate to ContributeSavingsScreen
                Navigator.pushNamed(context, '/contribute_savings', arguments: {
                  'userId': widget.userId,
                  'goalName': savings['goal_name'],
                }).then((result) {
                  if (result == true) {
                    loadUserData(); // Refresh after contribution
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }
}
