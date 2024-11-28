import 'package:flutter/material.dart';
import 'db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // Fetch all orders on load
  }

  // Fetch orders based on the query or show all if empty
  Future<void> _fetchOrders({String? date}) async {
    final dbHelper = DBHelper.instance;
    List<Map<String, dynamic>> results;

    if (date == null || date.isEmpty) {
      results = await dbHelper.query('order_plans'); // Fetch all orders
    } else {
      results = await dbHelper.queryByField('order_plans', 'date', date);
    }

    setState(() {
      _orders = results;
    });
  }

  // Navigate to the Order Page and refresh on return
  Future<void> _navigateToOrderPage() async {
    final result = await Navigator.pushNamed(context, '/order');
    if (result == true) {
      // If an order was added, reload the orders
      _fetchOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order Plans'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home is selected
        onTap: (index) {
          if (index == 1) {
            _navigateToOrderPage(); // Navigate and handle reload
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Order Plans'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Plan'),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _fetchOrders(date: value); // Fetch orders dynamically
              },
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? const Center(child: Text('No orders found.'))
                : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(order['date']),
                    subtitle: Text(order['items'] + " - \$" + order['price'].toString()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await DBHelper.instance.delete('order_plans', order['id']);
                            _fetchOrders(); // Refresh list after deletion
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Send the current order data to the OrderPage for editing
                            Navigator.pushNamed(context, '/update', arguments: order).then((result) {
                              if (result == true) {
                                _fetchOrders(); // Refresh list after editing
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
