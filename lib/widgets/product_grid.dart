import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ProductCard(product: products[i]),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(int.parse(product.backgroundColor.replaceAll('#', '0xFF'))),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.contain,
          ),

            ),
          ),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '₹${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false).updateQuantity(
                    product.id,
                    (Provider.of<Cart>(context, listen: false)
                            .items[product.id]
                            ?.quantity ??
                        1) -
                        1,
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  Provider.of<Cart>(context)
                      .items[product.id]
                      ?.quantity
                      .toString() ??
                      '0',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  final cart = Provider.of<Cart>(context, listen: false);
                  final currentQuantity = cart.items[product.id]?.quantity ?? 0;
                  if (currentQuantity == 0) {
                    cart.addItem(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product.name} to cart'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else {
                    cart.updateQuantity(product.id, currentQuantity + 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Increased ${product.name} quantity to ${currentQuantity + 1}'),
                        duration: const Duration(milliseconds: 800),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
