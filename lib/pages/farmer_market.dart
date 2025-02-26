import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'balance_page.dart';

class FarmerPage extends StatefulWidget {
  const FarmerPage({Key? key}) : super(key: key);

  @override
  _FarmerPageState createState() => _FarmerPageState();
}

class _FarmerPageState extends State<FarmerPage> {
  final _formKey = GlobalKey<FormState>();
  String? userEmail;
  List<Map<String, dynamic>> allProducts = [];
  double balance = 0.0;
  bool isLoading = true;

  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  String selectedUnit = 'kg';
  DateTime expiryDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _loadUserDataAndItems();
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        await _fetchAllFarmerProducts();
        await _fetchFarmerBalance();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading data: ${e.toString()}');
    }
  }

  Future<void> _fetchAllFarmerProducts() async {
    mongo.Db? db;
    try {
      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
      await db.open();


      final collection = db.collection('products');
      final query = mongo.where.eq('farmerEmail', userEmail);
      final cursor = collection.find(query);
      allProducts = await cursor.toList();

      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Error fetching items: ${e.toString()}');
    } finally {
      await db?.close();
    }
  }

  Future<void> _fetchFarmerBalance() async {
    mongo.Db? db;
    try {
      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
      await db.open();

      final collection = db.collection('farmers');
      debugPrint('Fetching balance for user: $userEmail');
      final farmer = await collection.findOne(mongo.where.eq('email', userEmail));

      if (farmer == null) {
        debugPrint('Farmer not found in database');
        return;
      }

      if (farmer.containsKey('balance')) {
        debugPrint('Found balance: ${farmer['balance']}');
        setState(() {
          balance = farmer['balance'].toDouble();
        });
      } else {
        debugPrint('No balance field found, initializing to 0.0');
        setState(() {
          balance = 0.0;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching balance: ${e.toString()}');
    } finally {
      await db?.close();
    }
  }

  Future<void> _updateFarmerBalance(double amount) async {
    mongo.Db? db;
    try {
      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
      await db.open();

      final collection = db.collection('farmers');
      debugPrint('Updating balance for user: $userEmail with amount: $amount');
      
      // First, check if the farmer exists and has a balance field
      final farmer = await collection.findOne(mongo.where.eq('email', userEmail));
      
      if (farmer == null) {
        debugPrint('Farmer not found in database');
        _showErrorSnackBar('Farmer not found');
        return;
      }

      // If balance field doesn't exist, initialize it with the amount
      if (!farmer.containsKey('balance')) {
        debugPrint('Initializing new balance with amount: $amount');
        await collection.update(
          mongo.where.eq('email', userEmail),
          {'\$set': {'balance': amount}}
        );
      } else {
        debugPrint('Current balance: ${farmer['balance']}, adding amount: $amount');
        await collection.update(
          mongo.where.eq('email', userEmail),
          mongo.modify.inc('balance', amount)
        );
      }

      await _fetchFarmerBalance();
      debugPrint('Balance update completed successfully');
    } catch (e) {
      _showErrorSnackBar('Error updating balance: ${e.toString()}');
      debugPrint('Balance update error: $e');
    } finally {
      await db?.close();
    }
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      mongo.Db? db;
      try {
        setState(() {
          isLoading = true;
        });

        db = await mongo.Db.create(
            'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
        await db.open();

        final collection = db.collection('products');
        final product = {
          'name': productNameController.text,
          'price': double.parse(priceController.text),
          'quantity': double.parse(quantityController.text),
          'unit': selectedUnit,
          'expiryDate': expiryDate.toIso8601String(),
          'farmerEmail': userEmail,
          'createdAt': DateTime.now().toIso8601String(),
          'isSold': false,
          'soldDate': null,
        };

        await collection.insert(product);

        // Clear form
        productNameController.clear();
        priceController.clear();
        quantityController.clear();
        selectedUnit = 'kg';
        expiryDate = DateTime.now().add(const Duration(days: 7));

        await _fetchAllFarmerProducts();

        _showSuccessSnackBar('Product added successfully!');
      } catch (e) {
        _showErrorSnackBar('Error adding product: ${e.toString()}');
      } finally {
        await db?.close();
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _markProductAsSold(String productId) async {
    mongo.Db? db;
    try {
      setState(() {
        isLoading = true;
      });

      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority&appName=Cluster0');
      await db.open();

      final collection = db.collection('products');
      await collection.update(
        mongo.where.eq('_id', mongo.ObjectId.parse(productId)),
        {
          r'$set': {
            'isSold': true,
            'soldDate': DateTime.now().toIso8601String(),
          }
        },
      );

      // Find the product and update balance
      final product = allProducts.firstWhere((p) => p['_id'].toString() == productId);
      await _updateFarmerBalance(product['price'].toDouble());

      await _fetchAllFarmerProducts();
      _showSuccessSnackBar('Product marked as sold!');
    } catch (e) {
      _showErrorSnackBar('Error marking product as sold: ${e.toString()}');
    } finally {
      await db?.close();
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildProductForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: productNameController,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter product name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: priceController,
            decoration: const InputDecoration(
              labelText: 'Price (₹)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: quantityController,
            decoration: const InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter quantity';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedUnit,
            decoration: const InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            items: ['kg', 'quintal', 'pound']
                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedUnit = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: expiryDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  expiryDate = picked;
                });
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
                'Expiry Date: ${expiryDate.toIso8601String().split('T')[0]}'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableProducts =
        allProducts.where((item) => !item['isSold']).toList();
    final soldProducts = allProducts.where((item) => item['isSold']).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDataAndItems,
          ),
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BalancePage()),
              );
            },
            tooltip: 'View Balance',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${userEmail ?? "Farmer"}!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add New Product',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildProductForm(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Available Products (${availableProducts.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableProducts.length,
                    itemBuilder: (context, index) {
                      final item = availableProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text('Price: ₹${item['price']}'),

                              Text(
                                  'Quantity: ${item['quantity']} ${item['unit']}'),
                              Text(
                                  'Listed on: ${item['createdAt'].toString().split('T')[0]}'),
                              Text(
                                  'Expires on: ${item['expiryDate'].toString().split('T')[0]}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Chip(
                                label: Text('Available'),
                                backgroundColor: Colors.green,
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () =>
                                    _markProductAsSold(item['_id'].toString()),
                                tooltip: 'Mark as Sold',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sold Products (${soldProducts.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: soldProducts.length,
                    itemBuilder: (context, index) {
                      final item = soldProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text('Sold for: ₹${item['price']}'),

                              Text(
                                  'Quantity: ${item['quantity']} ${item['unit']}'),
                              Text(
                                  'Listed on: ${item['createdAt'].toString().split('T')[0]}'),
                              Text(
                                  'Sold on: ${item['soldDate']?.toString().split('T')[0] ?? 'Date not available'}'),
                            ],
                          ),
                          trailing: const Chip(
                            label: Text('Sold'),
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
