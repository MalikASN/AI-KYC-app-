import 'dart:io';
import 'dart:math';

import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart'
    as img; // Add image package for image manipulation

class DermalogBridge {
  static const platform = MethodChannel('SDKChannel');

  Future<double> checkLiveness(String imgPath) async {
    try {
      // Creating a map of arguments to pass to the Java method
      final Map<String, dynamic> arguments = {
        'ImageToExtract': imgPath,
      };

      final double result =
          await platform.invokeMethod('CheckLiveness', arguments);

      return result;
    } on PlatformException catch (e) {
      print("Failed to call SDK method: '${e.message}'.");
      return -1;
    }
  }

  Future<String> ExtractFace() async {
    try {
      // Creating a map of arguments to pass to the Java method
      final Map<String, dynamic> arguments = {
        'ImageToExtract': FFAppState().documentImagePathRecto,
      };

      // Invoking the Java method and passing the arguments
      /*  if (FFAppState().extractedPerson != "") {
        await File(FFAppState().extractedPerson).delete();
      }*/

      final String result =
          await platform.invokeMethod('ExtractFace', arguments);

      //  FFAppState().setExtractedPerson("");
      FFAppState().setExtractedPerson(result);
      return result;
    } on PlatformException catch (e) {
      print("Failed to call SDK method: '${e.message}'.");
      return "Error";
    }
  }

  Future<void> ExtractFaceML() async {
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);

    // Process the image to detect faces
    final inputImage =
        InputImage.fromFilePath(FFAppState().documentImagePathRecto);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      print('No faces detected.');
      return;
    }

    // Get the largest face by comparing areas of bounding boxes
    Face largestFace = faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });

    // Load the image file
    final file = File(FFAppState().documentImagePathRecto);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      print('Failed to decode image.');
      return;
    }

    // Get the bounding box of the largest face
    Rect boundingBox = largestFace.boundingBox;

    // Expand the bounding box by 20%
    const double expansionFactor = 0.5;
    final double newWidth = boundingBox.width * (1 + expansionFactor);
    final double newHeight = boundingBox.height * (1 + expansionFactor);
    final double newLeft =
        boundingBox.left - (newWidth - boundingBox.width) / 2;
    final double newTop =
        boundingBox.top - (newHeight - boundingBox.height) / 2;

    // Ensure the new bounding box stays within image boundaries
    final int imageWidth = image.width;
    final int imageHeight = image.height;

    final adjustedLeft = newLeft.clamp(0, imageWidth - newWidth).toInt();
    final adjustedTop = newTop.clamp(0, imageHeight - newHeight).toInt();
    final adjustedWidth = newWidth.clamp(0, imageWidth - adjustedLeft).toInt();
    final adjustedHeight =
        newHeight.clamp(0, imageHeight - adjustedTop).toInt();

    // Crop the image based on the expanded bounding box
    final croppedImage = img.copyCrop(
      image,
      x: adjustedLeft,
      y: adjustedTop,
      width: adjustedWidth,
      height: adjustedHeight,
    );

    // Get the directory to save the cropped image
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/detectedImage.jpg';

    // Save the cropped image as a JPEG file
    if (await File(path).exists()) {
      await File(path).delete();
    }
    final jpgImage = img.encodeJpg(croppedImage);
    final jpgFile = File(path);
    await jpgFile.writeAsBytes(jpgImage);

    // Update state with the path to the cropped face image
    // FFAppState().setExtractedPerson("");
    FFAppState().setExtractedPerson(path);
  }

  Future<void> extractSelfieFaceML(String pathSelfie) async {
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);

    // Process the image to detect faces
    final inputImage = InputImage.fromFilePath(pathSelfie);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      return;
    }

    // Get the largest face by comparing areas of bounding boxes
    Face largestFace = faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });

    // Load the image file
    final file = File(pathSelfie);
    final imageBytes = await file.readAsBytes();
    final image = img.decodeImage(imageBytes);

    if (image == null) {
      print('Failed to decode image.');
      return;
    }

    // Get the bounding box of the largest face
    final Rect boundingBox = largestFace.boundingBox;

    // Expansion factor
    final double expansionFactor = 0.05;

    // Calculate the expanded width and height
    final int expandedWidth =
        (boundingBox.width * (1 + expansionFactor)).toInt();
    final int expandedHeight =
        (boundingBox.height * (1 + expansionFactor)).toInt();

    // Calculate the new top-left corner to keep the face centered
    final int centerX = (boundingBox.left + boundingBox.width / 2).toInt();
    final int centerY = (boundingBox.top + boundingBox.height / 2).toInt();

    final int newLeft = max(0, centerX - expandedWidth ~/ 2);
    final int newTop = max(0, centerY - expandedHeight ~/ 2);

    // Ensure the expanded box is within image bounds
    final int newWidth = min(expandedWidth, image.width - newLeft);
    final int newHeight = min(expandedHeight, image.height - newTop);

    // Crop the image based on the expanded bounding box
    final croppedImage = img.copyCrop(
      image,
      x: newLeft,
      y: newTop,
      width: newWidth,
      height: newHeight,
    );

    // Get the directory to save the cropped image
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/cropedSelfie.jpeg';

    // Save the cropped image as a JPEG file
    final jpgImage = img.encodeJpg(croppedImage);
    final jpgFile = File(path);
    await jpgFile.writeAsBytes(jpgImage);

    // Update state with the path to the cropped face image
    FFAppState().setSelfie(path);
  }

  Future<bool> CompareTwoFaces() async {
    try {
      // Creating a map of arguments to pass to the Java method
      final Map<String, dynamic> arguments = {
        'Image01': FFAppState().selfieImagePath,
        'Image02': FFAppState().extractedPerson
      };

      // Invoking the Java method and passing the arguments
      final double result =
          await platform.invokeMethod('CompareTwoFaces', arguments);
      FFAppState().matchingScore = result;
      if (result > 70.0) {
        FFAppState().setMatchingRes(true);
        return true;
      }

      FFAppState().setMatchingRes(false);
      return false;
    } on PlatformException catch (e) {
      print("Failed to call SDK method: '${e.message}'.");
      return false;
    }
  }
}
