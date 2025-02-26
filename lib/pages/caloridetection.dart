// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_tflite/flutter_tflite.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:developer' as devtools;

// class Caloridetection extends StatefulWidget {
//   const Caloridetection({super.key});

//   @override
//   _CaloridetectionState createState() => _CaloridetectionState();
// }

// class _CaloridetectionState extends State<Caloridetection> {
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
//         model: "assets/fruit_recognizer.tflite",
//         labels: "assets/fruit.txt",
//         numThreads: 1,
//         isAsset: true,
//         useGpuDelegate: false,
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
//         numResults: 5,
//         threshold: 0.2,
//         asynch: true,
       
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

//       if (predictedConfidence >= 80.0) {
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
//         maxWidth: 256, // Resize image before processing
//         maxHeight: 256,
//         imageQuality: 100,
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
//         title: const Text('Soil Classification'),
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
//                       foregroundColor: Colors.black,
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
//                       foregroundColor: Colors.black,
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
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:developer' as devtools;

class Caloridetection extends StatefulWidget {
  const Caloridetection({super.key});

  @override
  _CaloridetectionState createState() => _CaloridetectionState();
}

class _CaloridetectionState extends State<Caloridetection> {
  File? filePath;
  String label = '';
  double confidence = 0.0;

  final Map<String, String> fruitNutrition = {
    "Apple": "Calories: 52 kcal\nCarbohydrates: 13.8 g\nSugars: 10 g\nFiber: 2.4 g\nProtein: 0.3 g\nFat: 0.2 g\nVitamin C: 4.6 mg",
    "Banana": "Calories: 89 kcal\nCarbohydrates: 22.8 g\nSugars: 12.2 g\nFiber: 2.6 g\nProtein: 1.1 g\nFat: 0.3 g\nVitamin C: 8.7 mg\nPotassium: 358 mg",
    "Grape": "Calories: 69 kcal\nCarbohydrates: 18 g\nSugars: 15.5 g\nFiber: 0.9 g\nProtein: 0.7 g\nFat: 0.2 g\nVitamin C: 3.2 mg",
    "Mango": "Calories: 60 kcal\nCarbohydrates: 15 g\nSugars: 13.7 g\nFiber: 1.6 g\nProtein: 0.8 g\nFat: 0.4 g\nVitamin C: 36 mg",
    "Strawberry": "Calories: 32 kcal\nCarbohydrates: 7.7 g\nSugars: 4.9 g\nFiber: 2 g\nProtein: 0.7 g\nFat: 0.3 g\nVitamin C: 58.8 mg",
  };

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
        model: "assets/fruit_recognizer.tflite",
        labels: "assets/fruit.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
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
        numResults: 5,
        threshold: 0.2,
        asynch: true,
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

      if (predictedConfidence >= 80.0) {
        setState(() {
          confidence = predictedConfidence;
          label = predictedLabel;
        });

        if (fruitNutrition.containsKey(predictedLabel)) {
          _showNutritionDialog(predictedLabel, fruitNutrition[predictedLabel]!);
        }
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

  void _showNutritionDialog(String fruit, String nutrition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(fruit),
          content: Text(nutrition),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 100,
      );

      if (image == null) return;

      devtools.log("Image picked from ${source == ImageSource.gallery ? "Gallery" : "Camera"}");
      devtools.log("Image path: ${image.path}");

      await processImage(image.path);
    } catch (e) {
      devtools.log("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (filePath != null)
              Image.file(filePath!, height: 200, width: 200),
            const SizedBox(height: 20),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (label != "Uncertain Prediction")
              Text("Confidence: ${confidence.toStringAsFixed(2)}%", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.camera),
              child: const Text("Take a Photo"),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery),
              child: const Text("Pick from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}