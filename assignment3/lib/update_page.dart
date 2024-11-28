import 'package:flutter/material.dart';
import 'db_helper.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _foodItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  Map<String, dynamic>? _editingOrder;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic>? passedOrder = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (passedOrder != null) {
      _editingOrder = passedOrder;
      _dateController.text = passedOrder['date']; // Prefill the date field
      _costController.text = passedOrder['items']; // Prefill the item field
    }
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

  void _saveUpdatedOrder() async {
    final date = _dateController.text;
    final item = _costController.text;

    if (date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a valid date')));
      return;
    }

    final dbHelper = DBHelper.instance;
    if (_editingOrder != null) {
      // Update the existing order
      await dbHelper.update('order_plans', {
        'id': _editingOrder!['id'],
        'date': date,
        'items': item,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order updated successfully!')));
    Navigator.pop(context, true); // Return to the home screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Order')),
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
                    onChanged: (cost) {
                      // Filter food items based on target cost (optional)
                    },
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
                      onPressed: () => _saveUpdatedOrder(),
                      child: Text('Save Update'),
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Update Order'),
        ],
      ),
    );
  }
}
