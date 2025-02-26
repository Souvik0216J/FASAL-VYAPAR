import 'package:mongo_dart/mongo_dart.dart';

class InventoryItem {
  final String id;
  final String userEmail;
  final String fruitType;
  final String ripeness;
  final double quantity;
  final String storageLocation;
  final DateTime detectionDate;
  final String source;
  final String? notes;
  final double? price;

  InventoryItem({
    String? id,
    required this.userEmail,
    required this.fruitType,
    required this.ripeness,
    required this.quantity,
    required this.storageLocation,
    DateTime? detectionDate,
    required this.source,
    required this.notes,
    required this.price,
  }) : 
    this.id = id ?? ObjectId().toHexString(),
    this.detectionDate = detectionDate ?? DateTime.now();

  // Map<String, dynamic> toMap() {
  //   return {
  //     '_id': id,
  //     'userEmail': userEmail,
  //     'fruitType': fruitType,
  //     'ripeness': ripeness,
  //     'quantity': quantity,
  //     'storageLocation': storageLocation,
  //     'detectionDate': detectionDate.toIso8601String(),
  //     'source': source,
  //     'notes': notes,
  //   };
  // }

  // Map<String, dynamic> toMap() {
  // return {
  //   '_id': ObjectId.fromHexString(id), // Ensuring correct ObjectId format
  //   'userEmail': userEmail,
  //   'fruitType': fruitType,
  //   'ripeness': ripeness,
  //   'quantity': quantity,
  //   'storageLocation': storageLocation,
  //   'detectionDate': detectionDate.toIso8601String(),
  //   'source': source,
  //   'notes': notes,
  //   'price': price,
  // };

//   
Map<String, dynamic> toMap() {
  return {
    '_id': id.isNotEmpty ? ObjectId.parse(id) : ObjectId(), // Default new ObjectId if empty
    'userEmail': userEmail,
    'fruitType': fruitType,
    'ripeness': ripeness,
    'quantity': quantity, // Default to 0.0 if null
    'storageLocation': storageLocation,
    'detectionDate': detectionDate.toIso8601String(),
    'source': source,
    'notes': notes ?? '',
    'price': price ?? 0.0,
  };
}

factory InventoryItem.fromMap(Map<String, dynamic> map) {
  return InventoryItem(
    id: map['_id'] is ObjectId ? (map['_id'] as ObjectId).toHexString() : map['_id'].toString(), // Handle ObjectId safely
    userEmail: map['userEmail'] ?? '',
    fruitType: map['fruitType'] ?? '',
    ripeness: map['ripeness'] ?? '',
    quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
    storageLocation: map['storageLocation'] ?? '',
    detectionDate: map['detectionDate'] != null 
        ? DateTime.tryParse(map['detectionDate']) ?? DateTime.now() 
        : DateTime.now(), // Default to now if null or invalid
    source: map['source'] ?? '',
    notes: map['notes'] ?? '',
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
  );
}
}
