import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_signup.dart';
import 'screens/dashboard_screen.dart';
import 'screens/income_expense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/savings_goal_screen.dart';
import 'screens/profile_settings.dart';
import 'screens/edit_transaction_screen.dart';
import 'package:expanse_management/screens/contribute_savings_screen.dart';

void main() {
  runApp(const FinanceManagerApp());
}

/// This widget handles theme state and passes it down to the rest of the app.
class FinanceManagerApp extends StatefulWidget {
  const FinanceManagerApp({super.key});

  @override
  State<FinanceManagerApp> createState() => _FinanceManagerAppState();
}

class _FinanceManagerAppState extends State<FinanceManagerApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Loads theme preference from shared preferences.
  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Toggle theme and save the new preference.
  Future<void> _toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
    });
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      // Using Material 3 theme for an updated UI look
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            )
          : ThemeData.light(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (context) => LoginSignupScreen(
                toggleTheme: _toggleTheme,
                isDarkMode: isDarkMode,
              ),
            );
          case '/dashboard':
            final int userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => DashboardScreen(userId: userId),
            );
          case '/income_expense':
            final int userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => IncomeExpenseScreen(userId: userId),
            );
          case '/budget':
            final int userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => BudgetScreen(userId: userId),
            );
          case '/savings_goal':
            final int userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => SavingsGoalScreen(userId: userId),
            );
          case '/profile_settings':
            final int userId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => ProfileSettingsScreen(
                toggleTheme: _toggleTheme,
                isDarkMode: isDarkMode,
                userId: userId,
              ),
            );
          case '/edit_transaction':
            final Map<String, dynamic> arguments =
                settings.arguments as Map<String, dynamic>;
            final Map<String, dynamic> transaction = arguments['transaction'];
            final int userId = arguments['userId'];
            return MaterialPageRoute(
              builder: (context) => EditTransactionScreen(
                transaction: transaction,
                userId: userId,
              ),
            );
          case '/contribute_savings':
            final Map<String, dynamic> args =
                settings.arguments as Map<String, dynamic>;
            final int userId = args['userId'];
            final String goalName = args['goalName'];
            return MaterialPageRoute(
              builder: (context) => ContributeSavingsScreen(
                userId: userId,
                goalName: goalName,
              ),
            );
          default:
            // Fallback route
            return MaterialPageRoute(
              builder: (context) => LoginSignupScreen(
                toggleTheme: _toggleTheme,
                isDarkMode: isDarkMode,
              ),
            );
        }
      },
    );
  }
}
