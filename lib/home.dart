import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart'; // Importing AuthPage for navigation

// Simple home page after successful login
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
