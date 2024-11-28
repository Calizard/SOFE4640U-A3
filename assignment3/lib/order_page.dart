import 'package:flutter/material.dart';
import 'db_helper.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _foodItems = [];
  List<Map<String, dynamic>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  void _fetchFoodItems() async {
    final dbHelper = DBHelper.instance;
    final data = await dbHelper.query('food_items');
    setState(() {
      _foodItems = data;
      _filteredItems = data;
    });
  }

  void _filterItems(String cost) {
    if (cost.isEmpty) {
      setState(() {
        _filteredItems = _foodItems;
      });
      return;
    }
    final maxCost = double.tryParse(cost) ?? 0;
    setState(() {
      _filteredItems = _foodItems.where((item) => item['cost'] <= maxCost).toList();
    });
  }

  void _addOrder(String date, String item, double cost) async {
    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid date')),
      );
      return;
    }
    final dbHelper = DBHelper.instance;
    await dbHelper.insert('order_plans', {'date': date, 'items': item, 'price': cost});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order added successfully!')),
    );
    Navigator.pop(context, true); // Return to the home screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Plan')),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _costController,
                    decoration: InputDecoration(labelText: 'Target Cost'),
                    keyboardType: TextInputType.number,
                    onChanged: _filterItems,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item['name']),
                    subtitle: Text('\$${item['cost']}'),
                    trailing: ElevatedButton(
                      onPressed: () => _addOrder(_dateController.text, item['name'], item['cost']),
                      child: Text('Add'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Order Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Plan'),
        ],
      ),
    );
  }
}
