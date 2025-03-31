import 'package:flutter/material.dart';
import '../db_helper.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;

  const DashboardScreen({super.key, required this.userId});

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted')),
    );
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.deepPurple),
                title: const Text("Add Income or Expense"),
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
                leading: const Icon(Icons.pie_chart, color: Colors.deepPurple),
                title: const Text("Add Budget"),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(
                      context, '/budget', arguments: widget.userId);
                  if (result == true) {
                    loadUserData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings, color: Colors.deepPurple),
                title: const Text("Add Savings Goal"),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.pushNamed(
                      context, '/savings_goal', arguments: widget.userId);
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(
                context, '/profile_settings',
                arguments: widget.userId),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionTitle('Transactions', screenHeight),
                    transactions.isEmpty
                        ? const Center(child: Text('No transactions available.'))
                        : _buildTransactionList(transactions, screenHeight),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Budgets', screenHeight),
                    budgets.isEmpty
                        ? const Center(child: Text('No budgets available.'))
                        : _buildBudgetList(budgets, screenHeight),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Savings Goals', screenHeight),
                    savingsGoals.isEmpty
                        ? const Center(child: Text('No savings goals available.'))
                        : _buildSavingsGoalList(savingsGoals, screenHeight),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
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
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      List<Map<String, dynamic>> transactions, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit_transaction',
                      arguments: {
                        'transaction': transaction,
                        'userId': widget.userId,
                      },
                    ).then((value) {
                      if (value == true) {
                        loadUserData();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
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
      physics: const NeverScrollableScrollPhysics(),
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

  Widget _buildSavingsGoalList(
      List<Map<String, dynamic>> savingsGoals, double screenHeight) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
            title: Text(
              savings['goal_name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenHeight * 0.022),
            ),
            subtitle: Text(
              'Goal: \$${savings['goal_amount']}  |  Saved: \$${savings['saved_amount']}',
            ),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/contribute_savings', arguments: {
                  'userId': widget.userId,
                  'goalName': savings['goal_name'],
                }).then((result) {
                  if (result == true) {
                    loadUserData();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Contribute'),
            ),
          ),
        );
      },
    );
  }
}
