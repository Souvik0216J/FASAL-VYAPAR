import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/cart.dart';
import '../models/product.dart';

class MongoDBService {
  static Db? _db;
  
  static String get _mongoUrl {
    final user = dotenv.env['MONGO_USER'];
    final pass = dotenv.env['MONGO_PASS'];
    final url = dotenv.env['MONGO_URL'];
    return 'mongodb+srv://$user:$pass@$url/?retryWrites=true&w=majority&appName=Cluster0';
  }

  static const String _cartCollection = 'carts';
  static const String _orderCollection = 'orders';

  /// **Connects to MongoDB**
  static Future<void> connect() async {
    try {
      if (_db == null || !_db!.isConnected) {
        _db = await Db.create(_mongoUrl);
        await _db!.open();
      }
    } catch (e) {
      debugPrint('MongoDB connection error: $e');
      rethrow;
    }
  }

  /// **Saves Cart to MongoDB**
  static Future<void> saveCart(Cart cart, String userEmail) async {
    try {
      await connect();
      final cartData = {
        '_id': userEmail, // Store cart uniquely per user
        'items': cart.items.values.map((item) => {
          'productId': item.product.id,
          'name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
          'serviceFee': item.product.serviceFee,
          'totalPrice': item.product.totalPrice,
        }).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _db!.collection(_cartCollection).update(
        where.eq('_id', userEmail),
        cartData,
        upsert: true,
      );
    } catch (e) {
      debugPrint('Error saving cart: $e');
      rethrow;
    }
  }

  /// **Loads Cart from MongoDB**
  static Future<Cart> loadCart(String userEmail) async {
    try {
      await connect();
      final cartData = await _db!
          .collection(_cartCollection)
          .findOne(where.eq('_id', userEmail));

      if (cartData == null) {
        return Cart();
      }

      final cart = Cart();
      final items = cartData['items'] as List<dynamic>;
      for (var item in items) {
        final product = Product(
          id: item['productId'],
          name: item['name'],
          price: item['price'],
          serviceFee: item['serviceFee'], // ✅ Service Fee Fixed
          imageUrl: '',
          backgroundColor: '#FFFFFF',
        );

        for (var i = 0; i < item['quantity']; i++) {
          cart.addItem(product);
        }
      }
      return cart;
    } catch (e) {
      debugPrint('Error loading cart: $e');
      return Cart();
    }
  }

  /// **Inserts an Order into MongoDB**
  static Future<void> insertOrder(Map<String, dynamic> order) async {
    try {
      await connect();
      await _db!.collection(_orderCollection).insert(order);
    } catch (e) {
      debugPrint('Error inserting order: $e');
      rethrow;
    }
  }
}
