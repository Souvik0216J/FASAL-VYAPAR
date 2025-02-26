import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../services/mongodb_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final cart = Provider.of<Cart>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('userEmail');

      if (userEmail == null) {
        throw Exception('User email not found');
      }

      final order = {
        'userEmail': userEmail,
        'items': cart.items.values.map((item) => {
          'productId': item.product.id,
          'name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
        }).toList(),
        'total': cart.totalAmount,
        'date': DateTime.now().toIso8601String(),
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
      };

      await MongoDBService.insertOrder(order);
      cart.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error processing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing order: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _processPayment(Cart cart, String? userEmail) async {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User email not found. Please login again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (cart.totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart amount must be greater than 0'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    var options = {
      'key': 'Your_precious_API_Key', // Replace with your actual test key
      'amount': (cart.totalAmount * 100).toInt(),
      'name': 'Fasal Vyapar',
      'description': 'Order Payment',
      'timeout': 180, // in seconds
      'prefill': {
        'email': userEmail,
      },
      'currency': 'INR',
      'theme': {
        'color': '#4CAF50',
      },
      'retry': {
        'enabled': true,
        'max_count': 1,
      },
      'send_sms_hash': true,
      'remember_customer': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Razorpay Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing payment: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _showConfirmDialog(BuildContext context, Cart cart) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total amount: ₹${cart.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Are you sure you want to proceed with the payment?'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: const Text('Confirm'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) => Column(
          children: [
            if (cart.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Clear Cart',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear Cart'),
                          content: const Text(
                              'Are you sure you want to remove all items from your cart?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        cart.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cart cleared successfully'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            Expanded(
              child: cart.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your cart is empty!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.items.length,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemBuilder: (ctx, i) {
                        final cartItem = cart.items.values.toList()[i];
                        return CartItemTile(cartItem: cartItem);
                      },
                    ),
            ),
            if (cart.items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '₹${cart.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () async {
                                final confirm = await _showConfirmDialog(context, cart);
                                if (confirm) {
                                  final prefs = await SharedPreferences.getInstance();
                                  final userEmail = prefs.getString('userEmail');
                                  await _processPayment(cart, userEmail);
                                }
                              },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  const CartItemTile({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    try {
      backgroundColor = Color(
        int.parse(cartItem.product.backgroundColor.replaceAll('#', '0xFF')),
      );
    } catch (_) {
      backgroundColor = Colors.white;
    }

    return Dismissible(
      key: ValueKey(cartItem.product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false)
            .removeItem(cartItem.product.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove Item'),
            content: const Text('Do you want to remove this item from the cart?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: const Text('Yes'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  cartItem.product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${cartItem.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ₹${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.grey,
                    ),
                    onPressed: cartItem.quantity > 1
                        ? () {
                            Provider.of<Cart>(context, listen: false).updateQuantity(
                              cartItem.product.id,
                              cartItem.quantity - 1,
                            );
                          }
                        : null,
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
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF4CAF50),
                    ),
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false).updateQuantity(
                        cartItem.product.id,
                        cartItem.quantity + 1,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}