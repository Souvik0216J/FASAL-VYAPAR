// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_tflite/flutter_tflite.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:developer' as devtools;

// class FruitCondition extends StatefulWidget {
//   const FruitCondition({super.key});

//   @override
//   _FruitConditionState createState() => _FruitConditionState();
// }

// class _FruitConditionState extends State<FruitCondition> {
//   File? filePath;
//   String label = '';
//   double confidence = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _tfLiteInit();
//   }

//   @override
//   void dispose() {
//     Tflite.close();
//     super.dispose();
//   }

//   Future<void> _tfLiteInit() async {
//     try {
//       String? res = await Tflite.loadModel(
//         model: "assets/fruit_Condition_detection_90.tflite",
//         labels: "assets/fruit_condition.txt",
//         numThreads: 1,
//         isAsset: true,
//         useGpuDelegate: false
//       );
//       devtools.log("Model loaded: $res");
//     } catch (e) {
//       devtools.log("Error loading model: $e");
//     }
//   }

//   Future<void> processImage(String imagePath) async {
//     try {
//       var imageMap = File(imagePath);
//       setState(() {
//         filePath = imageMap;
//       });

//       var recognitions = await Tflite.runModelOnImage(
//         path: imagePath,
//         imageMean: 0.0,
//         imageStd: 255.0,
//         numResults: 8,
//         threshold: 0.2,
//         asynch: true
//       );

//       if (recognitions == null || recognitions.isEmpty) {
//         devtools.log("No recognitions found");
//         setState(() {
//           label = "No prediction";
//           confidence = 0.0;
//         });
//         return;
//       }

//       devtools.log("Recognition results: $recognitions");

//       double predictedConfidence = recognitions[0]['confidence'] * 100;
//       String predictedLabel = recognitions[0]['label'].toString();

//       if (predictedConfidence >= 90.0) {
//         setState(() {
//           confidence = predictedConfidence;
//           label = predictedLabel;
//         });
//       } else {
//         setState(() {
//           confidence = 0.0;
//           label = "Uncertain Prediction";
//         });
//       }
//     } catch (e) {
//       devtools.log("Error processing image: $e");
//       setState(() {
//         label = "Error processing image";
//         confidence = 0.0;
//       });
//     }
//   }

//   Future<void> pickImage(ImageSource source) async {
//     final ImagePicker picker = ImagePicker();
//     try {
//       final XFile? image = await picker.pickImage(
//         source: source,
//         maxWidth: 100,
//         maxHeight: 100,
//         imageQuality: 100
//       );

//       if (image == null) return;
      
//       devtools.log("Image picked from ${source == ImageSource.gallery ? "Gallery" : "Camera"}");
//       devtools.log("Image path: ${image.path}");
      
//       await processImage(image.path);
//     } catch (e) {
//       devtools.log("Error picking image: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fruit Classification'),
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

//           return SingleChildScrollView(
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       children: [
//                         if (userEmail != null) Text('Logged in as: $userEmail'),
//                         if (userRole != null) Text('Role: $userRole'),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                   Card(
//                     elevation: 20,
//                     clipBehavior: Clip.hardEdge,
//                     child: SizedBox(
//                       width: 300,
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 18),
//                           Container(
//                             height: 280,
//                             width: 280,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               image: const DecorationImage(
//                                 image: AssetImage('assets/upload.jpg'),
//                               ),
//                             ),
//                             child: filePath == null
//                                 ? const Text('')
//                                 : Image.file(
//                                     filePath!,
//                                     fit: BoxFit.cover,
//                                   ),
//                           ),
//                           const SizedBox(height: 12),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   label,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: label == "Uncertain Prediction"
//                                         ? Colors.red
//                                         : Colors.black,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 if (label != "Uncertain Prediction")
//                                   Text(
//                                     "The Accuracy is ${confidence.toStringAsFixed(0)}%",
//                                     style: const TextStyle(fontSize: 18),
//                                   ),
//                                 const SizedBox(height: 12),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () => pickImage(ImageSource.camera),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                       foregroundColor: Colors.black
//                     ),
//                     child: const Text("Take a Photo"),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () => pickImage(ImageSource.gallery),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(13),
//                       ),
//                       foregroundColor: Colors.black
//                     ),
//                     child: const Text("Pick from Gallery"),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer' as devtools;
import 'package:http/http.dart' as http;
import 'dart:convert';

class FruitCondition extends StatefulWidget {
  const FruitCondition({super.key});

  @override
  _FruitConditionState createState() => _FruitConditionState();
}

class _FruitConditionState extends State<FruitCondition> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _tfLiteInit();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> _tfLiteInit() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/fruit_Condition_detection_90.tflite",
        labels: "assets/fruit_condition.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false
      );
      devtools.log("Model loaded: $res");
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  Future<void> processImage(String imagePath) async {
    try {
      var imageMap = File(imagePath);
      setState(() {
        filePath = imageMap;
      });

      var recognitions = await Tflite.runModelOnImage(
        path: imagePath,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 8,
        threshold: 0.2,
        asynch: true
      );

      if (recognitions == null || recognitions.isEmpty) {
        devtools.log("No recognitions found");
        setState(() {
          label = "No prediction";
          confidence = 0.0;
        });
        return;
      }

      devtools.log("Recognition results: $recognitions");

      double predictedConfidence = recognitions[0]['confidence'] * 100;
      String predictedLabel = recognitions[0]['label'].toString();

      if (predictedConfidence >= 90.0) {
        setState(() {
          confidence = predictedConfidence;
          label = predictedLabel;
        });
      } else {
        setState(() {
          confidence = 0.0;
          label = "Uncertain Prediction";
        });
      }
    } catch (e) {
      devtools.log("Error processing image: $e");
      setState(() {
        label = "Error processing image";
        confidence = 0.0;
      });
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 100,
        maxHeight: 100,
        imageQuality: 100
      );

      if (image == null) return;
      
      devtools.log("Image picked from ${source == ImageSource.gallery ? "Gallery" : "Camera"}");
      devtools.log("Image path: ${image.path}");
      
      await processImage(image.path);
    } catch (e) {
      devtools.log("Error picking image: $e");
    }
  }

  Future<void> sendToInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('userEmail');
    final String? role = prefs.getString('userRole');

    if (email == null || role == null || label.isEmpty || label == "Uncertain Prediction") {
      devtools.log("Missing data, cannot send to inventory.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot send data. Ensure prediction is valid and user info is available."))
      );
      return;
    }

    final Map<String, dynamic> requestData = {
      "email": email,
      "fruit_condition": label,
      "role": role,
    };

    try {
      final response = await http.post(
        Uri.parse("https://api-for-send-to-pc.vercel.app/send"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        devtools.log("Data sent successfully: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data successfully sent to inventory!"))
        );
      } else {
        devtools.log("Failed to send data. Status: ${response.statusCode}, Response: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send data. Try again."))
        );
      }
    } catch (e) {
      devtools.log("Error sending data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again."))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Condition & Detection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      filePath == null
                          ? Image.asset('assets/upload.jpg', height: 280, width: 280)
                          : Image.file(filePath!, fit: BoxFit.cover, height: 280, width: 280),
                      const SizedBox(height: 12),
                      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (label != "Uncertain Prediction")
                        Text("The Accuracy is ${confidence.toStringAsFixed(0)}%", style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () => pickImage(ImageSource.camera), child: const Text("Take a Photo")),
              ElevatedButton(onPressed: () => pickImage(ImageSource.gallery), child: const Text("Pick from Gallery")),
              ElevatedButton(onPressed: sendToInventory, child: const Text("Send to Inventory")),
            ],
          ),
        ),
      ),
    );
  }
}
