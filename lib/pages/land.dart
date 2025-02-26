import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandPage extends StatelessWidget {
  const LandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Simply pop back to previous page
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

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to the Land Page!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  if (userEmail != null) Text('Logged in as: $userEmail'),
                  if (userRole != null) Text('Role: $userRole'),
                  // Add your buy page specific content here
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}