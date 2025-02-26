import 'package:mongo_dart/mongo_dart.dart';

class InventoryDBService {
  static const String mongoUrl =
      "mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";
  static const String dbName = "inventory_db";

  late Db _db;
  bool _isConnected = false;

  // Singleton pattern
  static final InventoryDBService _instance = InventoryDBService._internal();

  factory InventoryDBService() => _instance;

  InventoryDBService._internal();

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;
    try {
      _db = await Db.create(mongoUrl);
      await _db.open();
      _isConnected = true;
      print('✅ Connected to MongoDB');
    } catch (e) {
      _isConnected = false;
      print('❌ MongoDB connection failed: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    if (!_isConnected) return;
    try {
      await _db.close();
      _isConnected = false;
      print('✅ MongoDB connection closed');
    } catch (e) {
      print('❌ Error closing MongoDB connection: $e');
      rethrow;
    }
  }

  DbCollection _getUserCollection(String userId) {
    if (!_isConnected)
      throw StateError('❌ Database connection not established');
    return _db.collection('user_$userId');
  }

  Future<void> addInventoryItem(
      String userId, Map<String, dynamic> item) async {
    try {
      final collection = _getUserCollection(userId);

      // Validate required fields
      if (!item.containsKey('name') || !item.containsKey('quantity')) {
        throw ArgumentError('❌ Item must contain name and quantity');
      }

      // Add metadata
      final timestamp = DateTime.now().toIso8601String();
      item.addAll(
          {'createdAt': timestamp, 'updatedAt': timestamp, 'isSold': false});

      await collection.insert(item);
      print('✅ Item added successfully');
    } catch (e) {
      print('❌ Error adding inventory item: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInventory(String userId) async {
    try {
      final collection = _getUserCollection(userId);
      return await collection.find().toList();
    } catch (e) {
      print('❌ Error fetching inventory: $e');
      rethrow;
    }
  }

  Future<void> markAsSold(String userId, String itemId) async {
    try {
      final collection = _getUserCollection(userId);
      final objectId = _parseObjectId(itemId);

      final timestamp = DateTime.now().toIso8601String();
      final result = await collection.updateOne(
          where.eq('_id', objectId),
          modify
              .set('isSold', true)
              .set('soldAt', timestamp)
              .set('updatedAt', timestamp));

      if (!result.isSuccess || result.nMatched == 0) {
        throw StateError('❌ Item not found or already sold');
      }
      print('✅ Item marked as sold');
    } catch (e) {
      print('❌ Error marking item as sold: $e');
      rethrow;
    }
  }

  Future<void> updateItem(
      String userId, String itemId, Map<String, dynamic> updates) async {
    try {
      final collection = _getUserCollection(userId);
      final objectId = _parseObjectId(itemId);

      // Remove null values & protected fields
      updates.removeWhere(
          (key, value) => key == '_id' || key == 'createdAt' || value == null);
      updates['updatedAt'] = DateTime.now().toIso8601String();

      // Debugging logs
      print('🔍 Updating Item with ID: $itemId');
      print('🔄 Update Data: $updates');

      final modifier = modify;
      updates.forEach((key, value) => modifier.set(key, value));

      final result =
          await collection.updateOne(where.eq('_id', objectId), modifier);

      if (!result.isSuccess || result.nMatched == 0) {
        print('❌ Item not found or no changes made');
        return;
      }
      print('✅ Item updated successfully');
    } catch (e) {
      print('❌ Error updating item: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getExpiringItems(String userId,
      {int thresholdDays = 2}) async {
    try {
      final collection = _getUserCollection(userId);
      final threshold =
          DateTime.now().add(Duration(days: thresholdDays)).toIso8601String();

      return await collection
          .find(where.lte('expiryDate', threshold).eq('isSold', false))
          .toList();
    } catch (e) {
      print('❌ Error fetching expiring items: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String userId, String itemId) async {
    try {
      final collection = _getUserCollection(userId);
      final objectId = _parseObjectId(itemId);

      final result = await collection.deleteOne(where.eq('_id', objectId));

      if (!result.isSuccess || result.nRemoved == 0) {
        throw StateError('❌ Item not found');
      }
      print('✅ Item deleted successfully');
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    }
  }

  // Utility function for ObjectId handling
  ObjectId _parseObjectId(String itemId) {
    try {
      final RegExp objectIdRegex = RegExp(r'ObjectId\("([a-fA-F0-9]{24})"\)');
      final match = objectIdRegex.firstMatch(itemId);
      return ObjectId.fromHexString(match?.group(1) ?? itemId);
    } catch (e) {
      throw FormatException('❌ Invalid item ID format: $itemId');
    }
  }
}
