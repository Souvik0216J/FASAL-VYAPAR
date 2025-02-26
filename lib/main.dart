// import 'package:auth/pages/buy.dart';
// import 'package:auth/pages/cart_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'auth.dart';
// import 'farmer_landing_page.dart';
// import 'shopkeeper_landing_page.dart';
// import 'models/cart.dart';


// void main() async {
//   await dotenv.load(fileName: ".env");

//   runApp(const MyApp());
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<Widget> getLandingPage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     final userRole = prefs.getString('userRole');

//     if (isLoggedIn) {
//       switch (userRole) {
//         case 'farmer':
//           return FarmerLandingPage();
//         case 'user':
//           return BuyPage();
//         case 'shopkeeper':
//           return ShopkeeperLandingPage();
//         default:
//           return const AuthPage();
//       }
//     } else {
//       return const AuthPage();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (ctx) => Cart(),
//       child: MaterialApp(
//         title: 'Flutter App',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         routes: {
//           '/cart': (ctx) => const CartScreen(),
//         },

//         home: FutureBuilder<Widget>(
//           future: getLandingPage(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             } else {
//               return snapshot.data ?? const AuthPage();
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:auth/pages/buy.dart';
import 'package:auth/pages/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'farmer_landing_page.dart';
import 'shopkeeper_landing_page.dart';
import 'models/cart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getLandingPage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userRole = prefs.getString('userRole');

    if (isLoggedIn) {
      switch (userRole) {
        case 'farmer':
          return FarmerLandingPage();
        case 'user':
          return BuyPage();
        case 'shopkeeper':
          return ShopkeeperLandingPage();
        default:
          return const AuthPage();
      }
    } else {
      return const AuthPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Cart(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/cart': (ctx) => const CartScreen(),
        },
        home: FutureBuilder<Widget>(
          future: getLandingPage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return snapshot.data ?? const AuthPage();
            }
          },
        ),
      ),
    );
  }
}
