import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Color(
                int.parse(cartItem.product.backgroundColor.replaceAll('#', '0xFF')),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              cartItem.product.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${cartItem.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false).updateQuantity(
                    cartItem.product.id,
                    cartItem.quantity - 1,
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  cartItem.quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  Provider.of<Cart>(context, listen: false).updateQuantity(
                    cartItem.product.id,
                    cartItem.quantity + 1,
                  );
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Provider.of<Cart>(context, listen: false)
                  .removeItem(cartItem.product.id);
            },
          ),
        ],
      ),
    );
  }
}

