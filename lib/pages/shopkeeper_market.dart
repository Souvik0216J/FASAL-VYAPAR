import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class ShopkeeperPage extends StatefulWidget {
  const ShopkeeperPage({Key? key}) : super(key: key);

  @override
  _ShopkeeperPageState createState() => _ShopkeeperPageState();
}

class _ShopkeeperPageState extends State<ShopkeeperPage> {
  String? userEmail;
  List<Map<String, dynamic>> availableProducts = [];
  List<Map<String, dynamic>> purchasedProducts = [];
  bool isLoading = true;
  Timer? autoReloadTimer;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndProducts();
    _startAutoReload();
  }

  @override
  void dispose() {
    autoReloadTimer?.cancel();
    super.dispose();
  }

  void _startAutoReload() {
    autoReloadTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchAvailableProducts();
    });
  }

  Future<void> _loadUserDataAndProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString('userEmail');

      if (userEmail != null) {
        await _fetchAvailableProducts();
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

  Future<void> _fetchAvailableProducts() async {
    mongo.Db? db;
    try {
      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority');
      await db.open();

      final collection = db.collection('products');
      final allProducts = await collection.find().toList();

      setState(() {
        availableProducts =
            allProducts.where((product) => product['isSold'] == false).toList();
        purchasedProducts = allProducts
            .where((product) => product['buyerEmail'] == userEmail)
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar('Error fetching products: ${e.toString()}');
    } finally {
      await db?.close();
    }
  }

  Future<void> _purchaseProduct(Map<String, dynamic> product) async {
    mongo.Db? db;
    try {
      setState(() {
        isLoading = true;
      });

      db = await mongo.Db.create(
          'mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority');
      await db.open();

      final collection = db.collection('products');
      await collection.update(
        mongo.where.eq('_id', product['_id']),
        {
          '\$set': {
            'isSold': true,
            'buyerEmail': userEmail,
            'soldAt': DateTime.now().toIso8601String(),
          }
        },
      );

      final farmersCollection = db.collection('farmers');
      await farmersCollection.update(
        mongo.where.eq('email', product['farmerEmail']),
        {
          '\$inc': {'balance': product['price']}
        },
      );

      await _fetchAvailableProducts();
      _showSuccessSnackBar('Product purchased successfully!');
    } catch (e) {
      _showErrorSnackBar('Error purchasing product: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopkeeper Market')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableProducts.isEmpty && purchasedProducts.isEmpty
              ? _buildEmptyUI()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      if (availableProducts.isNotEmpty)
                        _buildProductList(
                            'Available Products', availableProducts, false),
                      if (purchasedProducts.isNotEmpty)
                        _buildProductList(
                            'Purchased Products', purchasedProducts, true),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text('No products available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Check back later for new listings.',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductList(
      String title, List<Map<String, dynamic>> products, bool isPurchased) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(product['name'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Price: ₹${product['price']} - Quantity: ${product['quantity']} ${product['unit']}'),
                trailing: isPurchased
                    ? Chip(
                        label: Text('Purchased'),
                        backgroundColor: Colors.green.shade100)
                    : ElevatedButton(
                        onPressed: () => _purchaseProduct(product),
                        child: const Text('Buy'),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class ShopkeeperPage extends StatefulWidget {
//   const ShopkeeperPage({Key? key}) : super(key: key);

//   @override
//   _ShopkeeperPageState createState() => _ShopkeeperPageState();
// }

// class _ShopkeeperPageState extends State<ShopkeeperPage> {
//   String? userEmail;
//   List<Map<String, dynamic>> availableProducts = [];
//   List<Map<String, dynamic>> purchasedProducts = [];
//   bool isLoading = true;
//   Timer? autoReloadTimer;
//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     _loadUserDataAndProducts();
//     _startAutoReload();
//   }

//   @override
//   void dispose() {
//     autoReloadTimer?.cancel();
//     _razorpay.clear();
//     super.dispose();
//   }

//   void _startAutoReload() {
//     autoReloadTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       _fetchAvailableProducts();
//     });
//   }

//   Future<void> _loadUserDataAndProducts() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       userEmail = prefs.getString('userEmail');

//       if (userEmail != null) {
//         await _fetchAvailableProducts();
//       }
//       setState(() {
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _showErrorSnackBar('Error loading data: ${e.toString()}');
//     }
//   }

//   Future<void> _fetchAvailableProducts() async {
//     mongo.Db? db;
//     try {
//       db = await mongo.Db.create('mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/marketplace?retryWrites=true&w=majority');
//       await db.open();

//       final collection = db.collection('products');
//       final allProducts = await collection.find().toList();

//       setState(() {
//         availableProducts = allProducts.where((product) => product['isSold'] == false).toList();
//         purchasedProducts = allProducts.where((product) => product['buyerEmail'] == userEmail).toList();
//       });
//     } catch (e) {
//       _showErrorSnackBar('Error fetching products: ${e.toString()}');
//     } finally {
//       await db?.close();
//     }
//   }

//   void _startPayment(Map<String, dynamic> product) {
//     var options = {
//       'key': 'PRecious api key from Banking KYC verification',
//       'amount': product['price'] * 100,
//       'currency': 'INR',
//       'name': 'Farmer Marketplace',
//       'description': product['name'],
//       'prefill': {'email': userEmail},
//     };
//     _razorpay.open(options);
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     _showSuccessSnackBar('Payment successful!');
//     _purchaseProduct();
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     _showErrorSnackBar('Payment failed: ${response.message}');
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     _showErrorSnackBar('External wallet selected: ${response.walletName}');
//   }

//   Future<void> _purchaseProduct() async {
//     await _fetchAvailableProducts();
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Shopkeeper Market')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : availableProducts.isEmpty && purchasedProducts.isEmpty
//               ? _buildEmptyUI()
//               : SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       if (availableProducts.isNotEmpty)
//                         _buildProductList('Available Products', availableProducts, false),
//                       if (purchasedProducts.isNotEmpty)
//                         _buildProductList('Purchased Products', purchasedProducts, true),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildEmptyUI() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey),
//           SizedBox(height: 20),
//           Text('No products available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           SizedBox(height: 10),
//           Text('Check back later for new listings.', style: TextStyle(fontSize: 14, color: Colors.grey)),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductList(String title, List<Map<String, dynamic>> products, bool isPurchased) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         ),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: NeverScrollableScrollPhysics(),
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             final product = products[index];
//             return Card(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               margin: const EdgeInsets.all(8.0),
//               child: ListTile(
//                 title: Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Text('Price: ₹${product['price']} - Quantity: ${product['quantity']} ${product['unit']}'),
//                 trailing: isPurchased
//                     ? Chip(label: Text('Purchased'), backgroundColor: Colors.green.shade100)
//                     : ElevatedButton(
//                         onPressed: () => _startPayment(product),
//                         child: const Text('Buy Now'),
//                       ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
