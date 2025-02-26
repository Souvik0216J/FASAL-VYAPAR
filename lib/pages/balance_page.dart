import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:shared_preferences/shared_preferences.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({Key? key}) : super(key: key);

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  double balance = 0.0;
  bool isLoading = true;
  String? userEmail;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndBalance();
  }

  Future<void> _loadUserDataAndBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail');
      if (userEmail != null) {
        await _fetchFarmerBalance();
        await _fetchTransactionHistory();
      }
    } catch (e) {
      _showErrorSnackBar('Error loading data: ${e.toString()}');
    }
  }

  Future<void> _fetchFarmerBalance() async {
    mongo.Db? db;
    try {
      setState(() {
        isLoading = true;
      });

      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
      await db.open();

      final collection = db.collection('farmers');
      final farmer = await collection.findOne(mongo.where.eq('email', userEmail));

      debugPrint('Fetched farmer data: $farmer');

      if (farmer != null && farmer.containsKey('balance')) {
        setState(() {
          balance = farmer['balance'].toDouble();
        });
        debugPrint('Updated balance to: $balance');
      } else {
        // If no balance field exists, initialize it to 0
        await collection.update(
          mongo.where.eq('email', userEmail),
          {'\$set': {'balance': 0.0}},
          upsert: true,
        );
        setState(() {
          balance = 0.0;
        });
        debugPrint('Initialized balance to 0.0');
      }
    } catch (e) {
      debugPrint('Error fetching balance: $e');
      _showErrorSnackBar('Error fetching balance: ${e.toString()}');
    } finally {
      await db?.close();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTransactionHistory() async {
    mongo.Db? db;
    try {
      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
      await db.open();

      final collection = db.collection('products');
      final query = mongo.where
          .eq('farmerEmail', userEmail)
          .eq('isSold', true)
          .sortBy('soldAt', descending: true);
      
      final cursor = collection.find(query);
      transactions = await cursor.toList();

      setState(() {});
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      _showErrorSnackBar('Error fetching transaction history: ${e.toString()}');
    } finally {
      await db?.close();
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(transaction['name'] ?? 'Unknown Product'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ₹${transaction['price']?.toString() ?? '0.0'}'),
                Text('Sold on: ${transaction['soldAt']?.toString().split('T')[0] ?? 'Date not available'}'),
              ],
            ),
            trailing: Chip(
              label: Text('₹${transaction['price']?.toString() ?? '0.0'}'),
              backgroundColor: Colors.green.shade100,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Balance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDataAndBalance,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserDataAndBalance,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                'Current Balance',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '₹${balance.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transaction History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTransactionList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}