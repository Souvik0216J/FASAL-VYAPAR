import 'package:auth/pages/caloridetection.dart';
import 'package:auth/pages/fruit_condition.dart';
import 'package:auth/pages/grocery_inventory.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'package:auth/pages/buy.dart';
import 'package:auth/pages/age.dart';
import 'package:auth/pages/disease.dart';
import 'package:auth/pages/farmer_market.dart';

class FarmerLandingPage extends StatefulWidget {
  const FarmerLandingPage({super.key});

  @override
  State<FarmerLandingPage> createState() => _FarmerLandingPageState();
}

class _FarmerLandingPageState extends State<FarmerLandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, dynamic>> features = [
    {
      'title': 'Inventory',
      'subtitle': 'Manage crops',
      'icon': Icons.shopping_basket_rounded,
      'color': const Color(0xFF8B5CF6),
      'bgColor': const Color(0xFFF3E8FF),
      'route': const InventoryPage()
    },

    {
      'title': 'Crop Detection',
      'subtitle': '& add to Inventory',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFECFDF5),
      'route': const FruitCondition()
    },
    {
      'title': 'Calories',
      'subtitle': 'Track Calories',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFF59E0B),
      'bgColor': const Color(0xFFFEF3C7),
      'route': const Caloridetection()
    },
    {
      'title': 'Buy',
      'subtitle': 'Purchase supplies',
      'icon': Icons.shopping_cart_rounded,
      'color': const Color(0xFF8B5CF6),
      'bgColor': const Color(0xFFF3E8FF),
      'route': BuyPage()
    },

    // {
    //   'title': 'Crop Condition',
    //   'subtitle': 'Track crop lifecycle',
    //   'icon': Icons.access_time_rounded,
    //   'color': const Color(0xFFEAB308),
    //   'bgColor': const Color(0xFFFEF9C3),
    //   'route': const AgePage()
    // },
    {
      'title': 'Disease',
      'subtitle': 'Monitor crop health',
      'icon': Icons.healing_rounded,
      'color': const Color(0xFFEF4444),
      'bgColor': const Color(0xFFFEE2E2),
      'route': const DiseasePage()
    },
    {
      'title': 'Soil',
      'subtitle': 'Soil Detection',
      'icon': Icons.landscape_rounded,
      'color': const Color(0xFF78350F),
      'bgColor': const Color(0xFFFDE68A),
      'route': const AgePage()
    },
    {
      'title': 'Market Place',
      'subtitle': 'Buy and sell crops',
      'icon': Icons.store_rounded,
      'color': const Color(0xFF4F46E5),
      'bgColor': const Color(0xFFE0E7FF),
      'route': const FarmerPage()
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            toolbarHeight: 70,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Farm Dashboard',
                  style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.black12,
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () => _showLogoutDialog(context),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Farmer! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your farm activities and resources',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: Tween<double>(begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                (index * 0.1).clamp(0.0, 1.0),
                                ((index + 1) * 0.1).clamp(0.0, 1.0),
                                curve: Curves.easeOutBack,
                              ),
                            ))
                            .value,
                        child: child,
                      );
                    },
                    child: _buildFeatureCard(context, features[index]),
                  );
                },
                childCount: features.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    return Material(
      color: feature['bgColor'],
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => feature['route'],
          ),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: feature['color'].withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  feature['icon'],
                  color: feature['color'],
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                feature['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature['subtitle'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ready to leave?'),
          content:
              const Text('You can always come back to check on your farm!'),
          actions: [
            TextButton(
              child: Text(
                'Stay',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Logout'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}