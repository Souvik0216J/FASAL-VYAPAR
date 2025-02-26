// // pages/inventory_page.dart
// import 'package:auth/pages/add_edit_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/grocery_item.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../services/inventory_db_service.dart';
// import '../widgets/inventory_item_card.dart';

// class InventoryPage extends StatefulWidget {
//   const InventoryPage({super.key});

//   @override
//   State<InventoryPage> createState() => _InventoryPageState();
// }

// class _InventoryPageState extends State<InventoryPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final InventoryDBService _dbService = InventoryDBService();
//   List<GroceryItem> _items = [];
//   bool _isLoading = true;
//   bool _isProcessing = false;
//   String _searchQuery = "";

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _initializeInventory();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeInventory() async {
//     setState(() => _isLoading = true);
//     try {
//       // Get current user email
//       final prefs = await SharedPreferences.getInstance();
//       final userEmail = prefs.getString('userEmail');
//       if (userEmail == null) {
//         throw Exception('User email not found');
//       }
      
//       // Establish database connection
//       await _dbService.connect();
      
//       // Load inventory for current user
//       final items = await _dbService.getInventory(userEmail);

//       setState(() {
//         _items = items.map((item) => GroceryItem.fromMap(item)).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       _showError('Failed to initialize inventory: $e');
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _markAsSold(String itemId) async {
//     setState(() => _isProcessing = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userEmail = prefs.getString('userEmail');
//       if (userEmail == null) {
//         throw Exception('User email not found');
//       }
//       await _dbService.markAsSold(userEmail, itemId);
//       await _initializeInventory();
//     } catch (e) {
//       _showError('Failed to mark item as sold: $e');
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showAddEditDialog({GroceryItem? item}) {
//     showDialog(
//       context: context,
//       builder: (context) => AddEditDialog(
//         item: item,
//         onSave: _handleSaveItem,
//       ),
//     );
//   }

//   Future<void> _handleSaveItem(GroceryItem item) async {
//     setState(() => _isProcessing = true);
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userEmail = prefs.getString('userEmail');
//       if (userEmail == null) {
//         throw Exception('User email not found');
//       }
      
//       if (item.id.isEmpty) {
//         await _dbService.addInventoryItem(userEmail, item.toMap());
//       } else {
//         await _dbService.updateItem(userEmail, item.id, item.toMap());
//       }
//       await _initializeInventory();
//     } catch (e) {
//       _showError('Failed to save item: $e');
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   List<GroceryItem> get _filteredItems {
//     return _items.where((item) {
//       final matchesSearch = _searchQuery.isEmpty ||
//           item.name.toLowerCase().contains(_searchQuery.toLowerCase());
//       final matchesTab = _tabController.index == 0 ? !item.isSold : item.isSold;
//       return matchesSearch && matchesTab;
//     }).toList();
//   }

//   List<int> _calculateItemCounts() {
//     int soldCount = _items.where((item) => item.isSold).length;
//     int nearlyExpiredCount = _items.where((item) => item.isNearlyExpired).length;
//     int freshCount = _items.where((item) => !item.isSold && !item.isNearlyExpired).length;

//     return [soldCount, nearlyExpiredCount, freshCount];
//   }

//   @override
//   Widget build(BuildContext context) {
//     final itemCounts = _calculateItemCounts();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Inventory Management'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Available Items'),
//             Tab(text: 'Sold Items'),
//           ],
//           onTap: (_) => setState(() {}),
//         ),
//       ),
//       body: Column(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               height: 200,
//               child: PieChart(
//                 PieChartData(
//                   sections: [
//                     PieChartSectionData(
//                       value: itemCounts[0].toDouble(),
//                       title: 'Sold: ${itemCounts[0]}',
//                       color: Colors.red,
//                     ),
//                     PieChartSectionData(
//                       value: itemCounts[1].toDouble(),
//                       title: 'Nearly Expired: ${itemCounts[1]}',
//                       color: Colors.yellow,
//                     ),
//                     PieChartSectionData(
//                       value: itemCounts[2].toDouble(),
//                       title: 'Fresh: ${itemCounts[2]}',
//                       color: Colors.green,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: 'Search items...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[200],
//               ),
//               onChanged: (value) => setState(() => _searchQuery = value),
//             ),
//           ),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildInventoryList(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isProcessing ? null : () => _showAddEditDialog(),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildInventoryList() {
//     final items = _filteredItems;
//     if (items.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               _tabController.index == 0 ? Icons.inventory : Icons.shopping_cart,
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _tabController.index == 0
//                   ? 'No available items'
//                   : 'No sold items',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.grey,
//                   ),
//             ),
//           ],
//         ),
//       );
//     }

//     return TabBarView(
//       controller: _tabController,
//       children: [
//         _buildItemsList(items.where((item) => !item.isSold).toList()),
//         _buildItemsList(items.where((item) => item.isSold).toList()),
//       ],
//     );
//   }

//   Widget _buildItemsList(List<GroceryItem> items) {
//     return ListView.builder(
//       itemCount: items.length,
//       padding: const EdgeInsets.all(8),
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return InventoryItemCard(
//           item: item,
//           onMarkAsSold: _isProcessing ? null : () => _markAsSold(item.id),
//           onEdit: () => _showAddEditDialog(item: item),
//         );
//       },
//     );
//   }
// }


import 'package:auth/pages/add_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/inventory_db_service.dart';
import '../widgets/inventory_item_card.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InventoryDBService _dbService = InventoryDBService();
  List<GroceryItem> _items = [];
  bool _isLoading = true;
  bool _isProcessing = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeInventory() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail');
      if (userEmail == null) {
        throw Exception('User email not found');
      }
      
      await _dbService.connect();
      
      final items = await _dbService.getInventory(userEmail);

      setState(() {
        _items = items.map((item) => GroceryItem.fromMap(item)).toList();
        _isLoading = false;
      });
    } catch (e) {
      _showError('Failed to initialize inventory: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsSold(String itemId) async {
    setState(() => _isProcessing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail');
      if (userEmail == null) {
        throw Exception('User email not found');
      }
      await _dbService.markAsSold(userEmail, itemId);
      await _initializeInventory();
    } catch (e) {
      _showError('Failed to mark item as sold: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddEditDialog({GroceryItem? item}) {
    showDialog(
      context: context,
      builder: (context) => AddEditDialog(
        item: item,
        onSave: _handleSaveItem,
      ),
    );
  }

  Future<void> _handleSaveItem(GroceryItem item) async {
    setState(() => _isProcessing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail');
      if (userEmail == null) {
        throw Exception('User email not found');
      }
      
      if (item.id.isEmpty) {
        await _dbService.addInventoryItem(userEmail, item.toMap());
      } else {
        await _dbService.updateItem(userEmail, item.id, item.toMap());
      }
      await _initializeInventory();
    } catch (e) {
      _showError('Failed to save item: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  List<GroceryItem> get _filteredItems {
    return _items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesTab = _tabController.index == 0 ? !item.isSold : item.isSold;
      return matchesSearch && matchesTab;
    }).toList();
  }

  List<int> _calculateItemCounts() {
    int soldCount = _items.where((item) => item.isSold).length;
    int nearlyExpiredCount = _items.where((item) => item.isNearlyExpired).length;
    int freshCount = _items.where((item) => !item.isSold && !item.isNearlyExpired).length;

    return [soldCount, nearlyExpiredCount, freshCount];
  }

  @override
  Widget build(BuildContext context) {
    final itemCounts = _calculateItemCounts();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available Items'),
            Tab(text: 'Sold Items'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: itemCounts[0].toDouble(),
                      title: 'Sold: ${itemCounts[0]}',
                      color: Colors.red,
                    ),
                    PieChartSectionData(
                      value: itemCounts[1].toDouble(),
                      title: 'Nearly Expired: ${itemCounts[1]}',
                      color: Colors.yellow,
                    ),
                    PieChartSectionData(
                      value: itemCounts[2].toDouble(),
                      title: 'Fresh: ${itemCounts[2]}',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildInventoryList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryList() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0 ? Icons.inventory : Icons.shopping_cart,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _tabController.index == 0
                  ? 'No available items'
                  : 'No sold items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildItemsList(items.where((item) => !item.isSold).toList()),
        _buildItemsList(items.where((item) => item.isSold).toList()),
      ],
    );
  }

  Widget _buildItemsList(List<GroceryItem> items) {
    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = items[index];
        return InventoryItemCard(
          item: item,
          onMarkAsSold: _isProcessing ? null : () => _markAsSold(item.id),
          onEdit: () => _showAddEditDialog(item: item),
        );
      },
    );
  }
}
