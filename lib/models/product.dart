class Product {
  final String id;
  final String name;
  final double price;
  final double serviceFee;
  final String imageUrl;
  final String backgroundColor;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.serviceFee,
    required this.imageUrl,
    required this.backgroundColor,
  });

  double get totalPrice => price + serviceFee;
}
