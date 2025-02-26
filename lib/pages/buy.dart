// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/product.dart';
// import '../widgets/product_grid.dart';
// import '../widgets/cart_button.dart';

// class BuyPage extends StatelessWidget {
//   BuyPage({Key? key}) : super(key: key);

//   final List<Product> products = [
//   Product(
//     id: '1',
//     name: 'Mango',
//     price: 65.00, // 60 + 5
//     imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Mango-PNG.png',
//     backgroundColor: '#FFF8E1',
//   ),
//   Product(
//     id: '2',
//     name: 'Banana',
//     price: 35.00, // 30 + 5
//     imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Banana-PNG.png',
//     backgroundColor: '#FFF8E1',
//   ),
//   Product(
//     id: '3',
//     name: 'Tomato',
//     price: 30.00, // 25 + 5
//     imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Tomato-PNG.png',
//     backgroundColor: '#FFEBEE',
//   ),
//   Product(
//     id: '4',
//     name: 'Potato',
//     price: 25.00, // 20 + 5
//     imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Potato-PNG.png',
//     backgroundColor: '#E8F5E9',
//   ),
//   Product(
//     id: '5',
//     name: 'Onion',
//     price: 40.00, // 35 + 5
//     imageUrl: 'https://www.pngkit.com/png/detail/23-236093_onion-png-image-onion-png.png',
//     backgroundColor: '#F3E5F5',
//   ),
// ];


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Buy Page'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: FutureBuilder<SharedPreferences>(
//         future: SharedPreferences.getInstance(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return const Center(child: Text('Error loading user data'));
//           }

//           final prefs = snapshot.data!;
//           final userRole = prefs.getString('userRole');
//           final userEmail = prefs.getString('userEmail');

//           return SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Welcome, ${userRole ?? 'User'}!',
//                         style: const TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         "Let's order fresh\nitems for you",
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           height: 1.2,
//                         ),
//                       ),
//                       if (userEmail != null) 
//                         Text('Email: $userEmail', style: const TextStyle(fontSize: 14, color: Colors.grey)),
//                     ],
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20.0),
//                   child: Text(
//                     'Fresh Items',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: ProductGrid(products: products),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       floatingActionButton: const CartButton(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_button.dart';

class BuyPage extends StatelessWidget {
  BuyPage({Key? key}) : super(key: key);

  final List<Product> products = [
    Product(
      id: '1',
      name: 'Mango (1kg)',
      price: 60.00,
      serviceFee: 5.00,
      imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Mango-PNG.png',
      backgroundColor: '#FFF8E1',
    ),
    Product(
      id: '2',
      name: 'Banana (1kg)',
      price: 30.00,
      serviceFee: 5.00,
      imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Banana-PNG.png',
      backgroundColor: '#FFF8E1',
    ),
    Product(
      id: '3',
      name: 'Tomato (1kg)',
      price: 25.00,
      serviceFee: 5.00,
      imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Tomato-PNG.png',
      backgroundColor: '#FFEBEE',
    ),
    Product(
      id: '4',
      name: 'Potato (1kg)',
      price: 20.00,
      serviceFee: 5.00,
      imageUrl: 'https://www.pngall.com/wp-content/uploads/2016/04/Potato-PNG.png',
      backgroundColor: '#E8F5E9',
    ),
    Product(
      id: '5',
      name: 'Onion (1kg)',
      price: 35.00,
      serviceFee: 5.00,
      imageUrl: 'https://www.pngkit.com/png/detail/23-236093_onion-png-image-onion-png.png',
      backgroundColor: '#F3E5F5',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buy Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          final prefs = snapshot.data!;
          final userRole = prefs.getString('userRole');
          final userEmail = prefs.getString('userEmail');

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${userRole ?? 'User'}!',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Let's order fresh\nitems for you",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      if (userEmail != null)
                        Text('Email: $userEmail', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Fresh Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ProductGrid(products: products),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: const CartButton(),
    );
  }
}
