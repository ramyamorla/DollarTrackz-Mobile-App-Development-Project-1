import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'finance_manager.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Create users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        // Create transactions table
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            amount REAL,
            description TEXT,
            category TEXT,
            date TEXT,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');

        // Create budgets table
        await db.execute('''
          CREATE TABLE budgets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            category TEXT,
            budget_limit REAL,
            spent REAL,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');

        // Create savings goals table
        await db.execute('''
          CREATE TABLE savings_goals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            goal_name TEXT,
            goal_amount REAL,
            saved_amount REAL,
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  // Register a user
  Future<void> registerUser(String email, String password) async {
    var dbClient = await db;
    await dbClient.insert('users', {'email': email, 'password': password});
  }

  // Login user
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  // Add a transaction and update budget spent amount if it's an expense
  Future<void> addTransaction(
      int userId, double amount, String description, String category) async {
    var dbClient = await db;

    // Insert the transaction into the transactions table
    await dbClient.insert('transactions', {
      'user_id': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'date': DateTime.now().toString()
    });

    // Update the 'spent' value in the budgets table only if it's an expense
    if (category != 'Income') {
      await _updateBudgetSpent(userId, category, amount, isAdd: true);
    }
  }

  // Delete a transaction and update budget spent if it's an expense
  Future<void> deleteTransaction(int transactionId) async {
    var dbClient = await db;

    // Fetch the transaction details (amount and category) before deleting
    List<Map<String, dynamic>> transaction = await dbClient.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (transaction.isNotEmpty) {
      String category = transaction.first['category'];
      double amount = transaction.first['amount'];
      int userId = transaction.first['user_id'];

      // Delete the transaction from the database
      await dbClient
          .delete('transactions', where: 'id = ?', whereArgs: [transactionId]);

      // Update the budget spent amount by subtracting the amount if it's an expense
      if (category != 'Income') {
        await _updateBudgetSpent(userId, category, amount, isAdd: false);
      }
    }
  }

  // Update a transaction and adjust the budget if needed
  Future<void> updateTransaction(int transactionId, double newAmount,
      String newCategory, String description) async {
    var dbClient = await db;

    // Fetch the old transaction details (amount and category)
    List<Map<String, dynamic>> transaction = await dbClient.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    if (transaction.isNotEmpty) {
      String oldCategory = transaction.first['category'];
      double oldAmount = transaction.first['amount'];
      int userId = transaction.first['user_id'];

      // Subtract the old amount from the old category if it's an expense
      if (oldCategory != 'Income') {
        await _updateBudgetSpent(userId, oldCategory, oldAmount, isAdd: false);
      }

      // Update the transaction with the new data
      await dbClient.update(
        'transactions',
        {
          'amount': newAmount,
          'description': description,
          'category': newCategory,
        },
        where: 'id = ?',
        whereArgs: [transactionId],
      );

      // Add the new amount to the new category if it's an expense
      if (newCategory != 'Income') {
        await _updateBudgetSpent(userId, newCategory, newAmount, isAdd: true);
      }
    }
  }

  // Update the budget spent amount based on the category and transaction type (add/remove)
  Future<void> _updateBudgetSpent(int userId, String category, double amount,
      {required bool isAdd}) async {
    var dbClient = await db;

    // Check if the category is part of the user's budget
    List<Map<String, dynamic>> budget = await dbClient.query(
      'budgets',
      where: 'user_id = ? AND category = ?',
      whereArgs: [userId, category],
    );

    if (budget.isNotEmpty) {
      double currentSpent = budget.first['spent'];

      // Adjust the spent value: add for expenses, subtract for deletions
      double newSpent = isAdd ? currentSpent + amount : currentSpent - amount;

      // Update the budget in the database
      await dbClient.update(
        'budgets',
        {'spent': newSpent},
        where: 'user_id = ? AND category = ?',
        whereArgs: [userId, category],
      );
    }
  }

  // Add budget
  Future<void> addBudget(int userId, String category, double limit) async {
    var dbClient = await db;
    await dbClient.insert('budgets', {
      'user_id': userId,
      'category': category,
      'budget_limit': limit,
      'spent': 0.0
    });
  }

  // Get budgets for a user
  Future<List<Map<String, dynamic>>> getUserBudgets(int userId) async {
    var dbClient = await db;
    return await dbClient
        .query('budgets', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Add a contribution to savings goals and update saved amount
  Future<void> addSavingsContribution(
      int userId, String goalName, double contributionAmount) async {
    var dbClient = await db;

    // Fetch the current saved amount for the goal
    List<Map<String, dynamic>> goal = await dbClient.query(
      'savings_goals',
      where: 'user_id = ? AND goal_name = ?',
      whereArgs: [userId, goalName],
    );

    if (goal.isNotEmpty) {
      double currentSavedAmount = goal.first['saved_amount'];

      // Update the saved amount by adding the contribution
      double newSavedAmount = currentSavedAmount + contributionAmount;

      // Update the savings goals table with the new saved amount
      await dbClient.update(
        'savings_goals',
        {'saved_amount': newSavedAmount},
        where: 'user_id = ? AND goal_name = ?',
        whereArgs: [userId, goalName],
      );
    }
  }

  // Add a new savings goal
  Future<void> addSavingsGoal(int userId, String goalName, double goalAmount,
      double savedAmount) async {
    var dbClient = await db;

    // Insert the new savings goal into the savings_goals table
    await dbClient.insert('savings_goals', {
      'user_id': userId,
      'goal_name': goalName,
      'goal_amount': goalAmount,
      'saved_amount': savedAmount, // Initialize with 0.0 if a new goal
    });
  }

  // Get savings goals for a user
  Future<List<Map<String, dynamic>>> getUserSavingsGoals(int userId) async {
    var dbClient = await db;
    return await dbClient
        .query('savings_goals', where: 'user_id = ?', whereArgs: [userId]);
  }

  // Get user transactions
  Future<List<Map<String, dynamic>>> getUserTransactions(int userId) async {
    var dbClient = await db;
    return await dbClient.query('transactions',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC' // Sorting by most recent
        );
  }
}
