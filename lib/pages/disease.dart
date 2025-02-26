// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DiseasePage extends StatelessWidget {
//   const DiseasePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Disease Page'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context), // Simply pop back to previous page
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

//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Welcome to the Disease Page!',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   const SizedBox(height: 20),
//                   if (userEmail != null) Text('Logged in as: $userEmail'),
//                   if (userRole != null) Text('Role: $userRole'),
//                   // Add your buy page specific content here
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

class DiseasePage extends StatefulWidget {
  const DiseasePage({super.key});

  @override
  _DiseasePageState createState() => _DiseasePageState();
}

class _DiseasePageState extends State<DiseasePage> {
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
        model: "assets/2.tflite",
        labels: "assets/disease.txt",
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
        numResults: 3,
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

      if (predictedConfidence >= 50.0) {
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
        maxWidth: 256,
        maxHeight: 256,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Classification'),
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

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        if (userEmail != null) Text('Logged in as: $userEmail'),
                        if (userRole != null) Text('Role: $userRole'),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 20,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          Container(
                            height: 280,
                            width: 280,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage('assets/upload.jpg'),
                              ),
                            ),
                            child: filePath == null
                                ? const Text('')
                                : Image.file(
                                    filePath!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: label == "Uncertain Prediction"
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (label != "Uncertain Prediction")
                                  Text(
                                    "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      foregroundColor: Colors.black
                    ),
                    child: const Text("Take a Photo"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      foregroundColor: Colors.black
                    ),
                    child: const Text("Pick from Gallery"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}