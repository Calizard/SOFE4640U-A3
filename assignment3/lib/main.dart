import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'order_page.dart';
import 'update_page.dart';
import 'db_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase(); // Ensure the database is initialized with dummy data
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/order': (context) => const OrderPage(),
        '/update': (context) => const UpdatePage(),
      },
    );
  }
}

Future<void> initializeDatabase() async {
  final dbHelper = DBHelper.instance;
  // Check if the database already has data
  final existingData = await dbHelper.query('food_items');
  if (existingData.isEmpty) {
    // Insert dummy data if no data exists
    List<Map<String, dynamic>> foodItems = [
      {'name': 'Pizza', 'cost': 10.0},
      {'name': 'Burger', 'cost': 5.0},
      {'name': 'Pasta', 'cost': 7.0},
      {'name': 'Salad', 'cost': 4.0},
      {'name': 'Sandwich', 'cost': 6.0},
      {'name': 'Sushi', 'cost': 12.0},
      {'name': 'Fries', 'cost': 3.0},
      {'name': 'Ice Cream', 'cost': 5.0},
      {'name': 'Steak', 'cost': 20.0},
      {'name': 'Tacos', 'cost': 8.0},
      {'name': 'Chicken Wings', 'cost': 9.0},
      {'name': 'Nachos', 'cost': 7.0},
      {'name': 'Curry', 'cost': 10.0},
      {'name': 'Rice Bowl', 'cost': 6.0},
      {'name': 'Soup', 'cost': 4.0},
      {'name': 'Smoothie', 'cost': 5.0},
      {'name': 'Coffee', 'cost': 3.0},
      {'name': 'Tea', 'cost': 2.0},
      {'name': 'Cake', 'cost': 6.0},
      {'name': 'Pancakes', 'cost': 8.0},
    ];
    for (var item in foodItems) {
      await dbHelper.insert('food_items', item);
    }
  }
}
