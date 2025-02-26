// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'auth.dart';
// import 'pages/nutrient.dart';
// import 'pages/buy.dart';

// class UserLandingPage extends StatelessWidget {
//   final List<Map<String, dynamic>> features = [
//     {'title': 'Nutrient', 'icon': Icons.spa, 'color': Colors.green, 'route': const NutrientPage()},
//     {'title': 'Calories', 'icon': Icons.local_fire_department, 'color': Colors.orange, 'route': const CaloriesPage()},
//     {'title': 'Buy', 'icon': Icons.shopping_cart, 'color': Colors.purple, 'route': BuyPage()},
//   ];

//   UserLandingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(  // Add WillPopScope to handle back button
//       onWillPop: () async {
//         // Prevent going back
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('User Dashboard'),
//           automaticallyImplyLeading: false,  // Remove default back button
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: () => _showLogoutDialog(context),
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome, User!',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: GridView.builder(
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       childAspectRatio: 1.2,
//                     ),
//                     itemCount: features.length,
//                     itemBuilder: (context, index) {
//                       return _buildFeatureCard(context, features[index]);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: InkWell(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => feature['route']),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(feature['icon'], size: 48, color: feature['color']),
//               const SizedBox(height: 8),
//               Text(
//                 feature['title'],
//                 style: Theme.of(context).textTheme.titleLarge,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Logout'),
//           content: const Text('Are you sure you want to log out?'),
//           actions: [
//             TextButton(
//               child: const Text('Cancel'),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: const Text('Logout'),
//               onPressed: () async {
//                 final prefs = await SharedPreferences.getInstance();
//                 await prefs.clear();
//                 Navigator.pushAndRemoveUntil(  // Replace pushReplacement with pushAndRemoveUntil
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthPage()),
//                   (route) => false,  // Remove all previous routes
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
import 'package:auth/pages/caloridetection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';

import 'pages/buy.dart';

class UserLandingPage extends StatefulWidget {
  UserLandingPage({super.key});

  @override
  State<UserLandingPage> createState() => _UserLandingPageState();
}

class _UserLandingPageState extends State<UserLandingPage> {
  final List<Map<String, dynamic>> features = [

    {'title': 'Calories', 'icon': Icons.local_fire_department, 'color': Colors.orange, 'route': const Caloridetection()},
    {'title': 'Buy', 'icon': Icons.shopping_cart, 'color': Colors.purple, 'route': BuyPage()},
  ];

  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Dashboard'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $username!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, index) {
                      return _buildFeatureCard(context, features[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => feature['route']),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(feature['icon'], size: 48, color: feature['color']),
              const SizedBox(height: 8),
              Text(
                feature['title'],
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'auth.dart';
// import 'pages/caloridetection.dart';
// import 'pages/buy.dart';

// class UserLandingPage extends StatefulWidget {
//   const UserLandingPage({Key? key}) : super(key: key);

//   @override
//   State<UserLandingPage> createState() => _UserLandingPageState();
// }

// class _UserLandingPageState extends State<UserLandingPage> {
//   final List<Map<String, dynamic>> features = [
//     {'title': 'Calories', 'icon': Icons.local_fire_department, 'color': Colors.orange, 'route': const Caloridetection()},
//     {'title': 'Buy', 'icon': Icons.shopping_cart, 'color': Colors.purple, 'route': BuyPage()},
//   ];

//   String username = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadUsername();
//   }

//   Future<void> _loadUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       username = prefs.getString('username') ?? 'User';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: SafeArea(
//           child: CustomScrollView(
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: 200.0,
//                 floating: false,
//                 pinned: true,
//                 flexibleSpace: FlexibleSpaceBar(
//                   title: Text('Welcome, $username!',
//                       style: GoogleFonts.poppins(
//                         textStyle: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       )),
//                   background: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [Colors.blue.shade700, Colors.blue.shade900],
//                       ),
//                     ),
//                   ),
//                 ),
//                 actions: [
//                   IconButton(
//                     icon: const Icon(Icons.logout, color: Colors.white),
//                     onPressed: () => _showLogoutDialog(context),
//                   ),
//                 ],
//               ),
//               SliverPadding(
//                 padding: const EdgeInsets.all(16.0),
//                 sliver: SliverGrid(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 1,
//                   ),
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) => _buildFeatureCard(context, features[index]),
//                     childCount: features.length,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       child: InkWell(
//         onTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => feature['route']),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [feature['color'].withOpacity(0.7), feature['color']],
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(feature['icon'], size: 48, color: Colors.white),
//                 const SizedBox(height: 12),
//                 Text(
//                   feature['title'],
//                   style: GoogleFonts.poppins(
//                     textStyle: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//           content: Text('Are you sure you want to log out?', style: GoogleFonts.poppins()),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           actions: [
//             TextButton(
//               child: Text('Cancel', style: GoogleFonts.poppins()),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               ),
//               onPressed: () async {
//                 final prefs = await SharedPreferences.getInstance();
//                 await prefs.clear();
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthPage()),
//                   (route) => false,
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

