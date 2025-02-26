import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart.dart';

class CartButton extends StatelessWidget {
  const CartButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (_, cart, __) => Stack(
        children: [
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () => Navigator.of(context).pushNamed('/cart'),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
            ),
          ),
          if (cart.itemCount > 0)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  cart.itemCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

