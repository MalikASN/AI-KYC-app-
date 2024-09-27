import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List
import 'package:image/image.dart' as img; // Import the image package
import 'package:tflite_v2/tflite_v2.dart';

class ImageLivenessPredictor {
  Future<void> loadModel() async {
    await Tflite.loadModel(model: "assets/models/model.tflite");
  }

  Future<void> predictImageLiveness(String imagePath) async {
    await loadModel();

    // Load the image file
    File imageFile = File(imagePath);
    List<int> imageBytes = imageFile.readAsBytesSync();

    // Convert List<int> to Uint8List
    Uint8List uint8ImageBytes = Uint8List.fromList(imageBytes);

    // Decode the image
    img.Image image = img.decodeImage(uint8ImageBytes)!;

    // Resize the image to 150x150 (model input size)
    img.Image resizedImage = img.copyResize(image, width: 150, height: 150);

    // Save the resized image to a temporary file (optional, just for confirmation)
    File resizedImageFile =
        File("${Directory.systemTemp.path}/resized_image.png")
          ..writeAsBytesSync(img.encodePng(resizedImage));

    // Run the model on the resized image
    var recognitions = await Tflite.runModelOnImage(
      path: resizedImageFile.path, // Path to the resized image file
      imageMean: 127.5, // Mean of image normalization (rescaled from 0 to 1)
      imageStd: 127.5, // Std deviation of image normalization
      numResults: 2, // Number of results (binary: liveness/spoof)
      threshold:
          0.5, // Confidence threshold, 0.5 is reasonable for binary classification
      asynch: true, // Asynchronous execution
    );

    print("Recognition results: $recognitions");
  }
}
