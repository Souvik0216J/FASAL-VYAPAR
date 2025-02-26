
// import 'package:flutter/material.dart';
// import 'package:mongo_dart/mongo_dart.dart' show Db, where, modify;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
// import 'user_landing_page.dart';
// import 'shopkeeper_landing_page.dart';
// import 'farmer_landing_page.dart';

// // Database helper class
// class MongoDatabase {
//   static var db, userCollection;
//   static connect() async {
//     const connectionString =
//         "mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

//     try {
//       db = await Db.create(connectionString);
//       await db.open();
//       userCollection = db.collection("users");
//       print('Connected to MongoDB Atlas');
//     } catch (e) {
//       print('Error connecting to MongoDB Atlas: $e');
//     }
//   }

//   static Future<String> insert(
//       String email, String username, String password, String role) async {
//     try {
//       var existingUser = await userCollection.findOne({"email": email});
//       if (existingUser != null) {
//         return "Email already exists";
//       }

//       // Check if username is already taken
//       existingUser = await userCollection.findOne({"username": username});
//       if (existingUser != null) {
//         return "Username already exists";
//       }

//       var result = await userCollection.insertOne({
//         "email": email,
//         "username": username,
//         "password": password,
//         "role": role,
//         "createdAt": DateTime.now(),
//         "lastLogin": DateTime.now()
//       });

//       if (result.isSuccess) {
//         return "success";
//       } else {
//         return "Failed to create user";
//       }
//     } catch (e) {
//       print('Error inserting user: $e');
//       return "Error: Database operation failed";
//     }
//   }

//   static Future<Map<String, String>> authenticate(String email, String password) async {
//     try {
//       var user = await userCollection.findOne({"email": email, "password": password});

//       if (user != null) {
//         await userCollection.update(
//             where.eq('email', email), modify.set('lastLogin', DateTime.now()));
//         return {
//           "status": "success",
//           "role": user['role'] ?? 'user',
//           "username": user['username'] ?? ''
//         };
//       }
//       return {"status": "Invalid credentials", "role": "", "username": ""};
//     } catch (e) {
//       print('Error authenticating user: $e');
//       return {"status": "Error: Authentication failed", "role": "", "username": ""};
//     }
//   }
// }

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   _AuthPageState createState() => _AuthPageState();
// }

// class _AuthPageState extends State<AuthPage> {
//   bool isLogin = true;
//   bool isLoading = false;
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   String selectedRole = 'user';

//   @override
//   void initState() {
//     super.initState();
//     _initializeDatabase();
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ));
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _initializeDatabase() async {
//     setState(() => isLoading = true);
//     try {
//       await MongoDatabase.connect();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to connect to database')));
//       }
//     }
//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _submitForm() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => isLoading = true);

//       try {
//         if (isLogin) {
//           // Handle login
//           Map<String, String> result = await MongoDatabase.authenticate(
//               _emailController.text, _passwordController.text);

//           if (!mounted) return;

//           if (result["status"] == "success") {
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.setBool('isLoggedIn', true);
//             await prefs.setString('userEmail', _emailController.text);
//             await prefs.setString('userRole', result["role"]!);
//             await prefs.setString('username', result["username"]!);

//             if (!mounted) return;

//             switch (result["role"]) {
//               case 'farmer':
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => FarmerLandingPage()),
//                   (route) => false,
//                 );
//                 break;
//               case 'shopkeeper':
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => ShopkeeperLandingPage()),
//                   (route) => false,
//                 );
//                 break;
//               case 'user':
//               default:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => UserLandingPage()),
//                   (route) => false,
//                 );
//                 break;
//             }
//           } else {
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(SnackBar(content: Text(result["status"]!)));
//           }
//         } else {
//           // Handle signup
//           String result = await MongoDatabase.insert(
//             _emailController.text,
//             _usernameController.text,
//             _passwordController.text,
//             selectedRole,
//           );

//           if (!mounted) return;

//           if (result == "success") {
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.setBool('isLoggedIn', true);
//             await prefs.setString('userEmail', _emailController.text);
//             await prefs.setString('username', _usernameController.text);
//             await prefs.setString('userRole', selectedRole);

//             if (!mounted) return;

//             switch (selectedRole) {
//               case 'farmer':
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => FarmerLandingPage()),
//                   (route) => false,
//                 );
//                 break;
//               case 'shopkeeper':
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => ShopkeeperLandingPage()),
//                   (route) => false,
//                 );
//                 break;
//               default:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => UserLandingPage()),
//                   (route) => false,
//                 );
//                 break;
//             }
//           } else {
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(SnackBar(content: Text(result)));
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(const SnackBar(content: Text('An error occurred')));
//         }
//       }

//       if (mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(32.0),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             isLogin ? 'Welcome Back' : 'Create Account',
//                             style: const TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF6A11CB),
//                             ),
//                           ),
//                           const SizedBox(height: 30),
//                           if (!isLogin) ...[
//                             DropdownButtonFormField<String>(
//                               value: selectedRole,
//                               decoration: InputDecoration(
//                                 labelText: 'Select Role',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 prefixIcon: const Icon(Icons.person_outline),
//                               ),
//                               items: <String>['farmer', 'user', 'shopkeeper']
//                                   .map<DropdownMenuItem<String>>((String value) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                               onChanged: (String? newValue) {
//                                 if (newValue != null) {
//                                   setState(() {
//                                     selectedRole = newValue;
//                                   });
//                                 }
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                             TextFormField(
//                               controller: _usernameController,
//                               decoration: InputDecoration(
//                                 labelText: 'Username',
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 prefixIcon: const Icon(Icons.person),
//                               ),
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter a username';
//                                 }
//                                 if (value.length < 3) {
//                                   return 'Username must be at least 3 characters';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                           TextFormField(
//                             controller: _emailController,
//                             decoration: InputDecoration(
//                               labelText: 'Email',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               prefixIcon: const Icon(Icons.email_outlined),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your email';
//                               }
//                               if (!value.contains('@')) {
//                                 return 'Please enter a valid email';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 20),
//                           TextFormField(
//                             controller: _passwordController,
//                             decoration: InputDecoration(
//                               labelText: 'Password',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               prefixIcon: const Icon(Icons.lock_outline),
//                             ),
//                             obscureText: true,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your password';
//                               }
//                               if (value.length < 6) {
//                                 return 'Password must be at least 6 characters';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 30),
//                           ElevatedButton(
//                             onPressed: isLoading ? null : _submitForm,
//                             style: ElevatedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               backgroundColor: const Color(0xFF2575FC),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               minimumSize: const Size(double.infinity, 50),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 15),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   if (isLoading)
//                                     const Padding(
//                                       padding: EdgeInsets.only(right: 10),
//                                       child: SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       ),
//                                     ),
//                                   Text(
//                                     isLogin ? 'Login' : 'Sign Up',
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           TextButton(
//                             onPressed: () {
//                               setState(() {
//                                 isLogin = !isLogin;
//                               });
//                             },
//                             child: Text(
//                               isLogin
//                                   ? 'Need an account? Sign Up'
//                                   : 'Already have an account? Login',
//                               style: const TextStyle(
//                                 color: Color(0xFF6A11CB),
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' show Db, where, modify;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'user_landing_page.dart';
import 'shopkeeper_landing_page.dart';
import 'farmer_landing_page.dart';

// Database helper class
class MongoDatabase {
  static var db, userCollection;
  static connect() async {
    const connectionString =
        "mongodb+srv://hackathon4bits:Souvik2005@cluster0.28tui.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

    try {
      db = await Db.create(connectionString);
      await db.open();
      userCollection = db.collection("users");
      print('Connected to MongoDB Atlas');
    } catch (e) {
      print('Error connecting to MongoDB Atlas: $e');
    }
  }

  static Future<String> insert(
      String email, String username, String password, String role) async {
    try {
      var existingUser = await userCollection.findOne({"email": email});
      if (existingUser != null) {
        return "Email already exists";
      }

      // Check if username is already taken
      existingUser = await userCollection.findOne({"username": username});
      if (existingUser != null) {
        return "Username already exists";
      }

      var result = await userCollection.insertOne({
        "email": email,
        "username": username,
        "password": password,
        "role": role,
        "createdAt": DateTime.now(),
        "lastLogin": DateTime.now()
      });

      if (result.isSuccess) {
        return "success";
      } else {
        return "Failed to create user";
      }
    } catch (e) {
      print('Error inserting user: $e');
      return "Error: Database operation failed";
    }
  }

  static Future<Map<String, String>> authenticate(String username, String password) async {
    try {
      var user = await userCollection.findOne({"username": username, "password": password});

      if (user != null) {
        await userCollection.update(
            where.eq('username', username), modify.set('lastLogin', DateTime.now()));
        return {
          "status": "success",
          "role": user['role'] ?? 'user',
          "email": user['email'] ?? '',
          "username": username
        };
      }
      return {"status": "Invalid credentials", "role": "", "email": "", "username": ""};
    } catch (e) {
      print('Error authenticating user: $e');
      return {"status": "Error: Authentication failed", "role": "", "email": "", "username": ""};
    }
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String selectedRole = 'user';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initializeDatabase() async {
    setState(() => isLoading = true);
    try {
      await MongoDatabase.connect();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to database')));
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        if (isLogin) {
          // Handle login with username instead of email
          Map<String, String> result = await MongoDatabase.authenticate(
              _usernameController.text, _passwordController.text);

          if (!mounted) return;

          if (result["status"] == "success") {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userEmail', result["email"]!);
            await prefs.setString('username', result["username"]!);
            await prefs.setString('userRole', result["role"]!);

            if (!mounted) return;

            switch (result["role"]) {
              case 'farmer':
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => FarmerLandingPage()),
                  (route) => false,
                );
                break;
              case 'shopkeeper':
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ShopkeeperLandingPage()),
                  (route) => false,
                );
                break;
              case 'user':
              default:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => UserLandingPage()),
                  (route) => false,
                );
                break;
            }
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(result["status"]!)));
          }
        } else {
          // Handle signup
          String result = await MongoDatabase.insert(
            _emailController.text,
            _usernameController.text,
            _passwordController.text,
            selectedRole,
          );

          if (!mounted) return;

          if (result == "success") {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userEmail', _emailController.text);
            await prefs.setString('username', _usernameController.text);
            await prefs.setString('userRole', selectedRole);

            if (!mounted) return;

            switch (selectedRole) {
              case 'farmer':
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => FarmerLandingPage()),
                  (route) => false,
                );
                break;
              case 'shopkeeper':
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ShopkeeperLandingPage()),
                  (route) => false,
                );
                break;
              default:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => UserLandingPage()),
                  (route) => false,
                );
                break;
            }
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(result)));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('An error occurred')));
        }
      }

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLogin ? 'Welcome Back' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A11CB),
                            ),
                          ),
                          const SizedBox(height: 30),
                          if (!isLogin) ...[
                            DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Select Role',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              items: <String>['farmer', 'user', 'shopkeeper']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedRole = newValue;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF2575FC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isLoading)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    isLogin ? 'Login' : 'Sign Up',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin
                                  ? 'Need an account? Sign Up'
                                  : 'Already have an account? Login',
                              style: const TextStyle(
                                color: Color(0xFF6A11CB),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}