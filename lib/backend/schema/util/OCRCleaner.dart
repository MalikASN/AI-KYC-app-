import 'dart:io';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<String>> cleanOcr(String ocrContent) async {
  List<String> MRZContent = [];
  List<String> names = await readAndSplitFile();
  try {
    // Iterate through each character in the OCR content
    int i = 0;
    while (i < ocrContent.length) {
      // DL OR ID
      if (ocrContent.substring(i, i + 5) == "DLDZA" ||
          ocrContent.substring(i, i + 5) == "IDDZA") {
        ocrContent = ocrContent.substring(i);
        MRZContent = ocrContent.split("\n");

        //deleting additional lines
        if (MRZContent.length > 3) {
          for (int z = 3; z < MRZContent.length; z++) {
            MRZContent.removeAt(z);
          }
        }

        // Looping through list MRZ elements
        for (int j = 0; j < MRZContent.length; j++) {
          MRZContent[j] = MRZContent[j]
              .replaceAll(" ", "")
              .replaceAll("«", "<")
              .replaceAll("DZAK", "DZA<")
              .replaceAllMapped(
                RegExp(r'([A-Z])([Kk])(<[A-Z])'),
                (Match m) => '${m.group(1)}<${m.group(3)}',
              )
              .replaceAllMapped(
            RegExp(r'<([^<A-Z\s]+|[kK]+)<'),

            // Matches any characters between two '<' that are not '<'
            (match) {
     
              int nonLessThanCount = match.group(0)!.length -
                  2; // Subtract 2 for the surrounding `<`

              return '<${'<' * nonLessThanCount}<';
            },
          ).replaceAllMapped(
            RegExp(r'(<<|<)([A-Z]{3,})(K|k)<'),
            (match) {
            
              String prefix = match.group(1)!; // << or <
              String name =
                  match.group(2)!; // The sequence of uppercase letters
              String suffix = match.group(3)!; // The 'K' or 'k'
              String nameWithSuffix =
                  '$name$suffix'; // Combine the name and suffix

              // Check if 'NAMEk' (or similar) is not in the names list
              if (!names.contains(nameWithSuffix)) {
                return '$prefix$name<'; // Replace 'K' or 'k' with '<'
              }
              return '$prefix$name$suffix<'; // Leave 'K' or 'k' unchanged
            },
          );

          if (j == 1) {
            // Invert last two characters if second-to-last is a digit and last is '<'
            MRZContent[j] = MRZContent[j].replaceAllMapped(
              RegExp(r'(\d)<$'),
              (match) {
        
                return '${match.group(1)}<';
              },
            );
          }

          if (RegExp(r'[^<]$').hasMatch(MRZContent[j]) && j != 1) {
            // Replace the last character with "<" if it's not "<"
            MRZContent[j] =
                "${MRZContent[j].substring(0, MRZContent[j].length - 1)}<";
          }
        }

        // Filling remaining characters to ensure each line has at least 30 characters
        for (int z = 0; z < MRZContent.length; z++) {
          MRZContent[z] = MRZContent[z].toUpperCase();
          if ((z == 0 || z == 1) && MRZContent[z].length < 30) {
            // Fill remaining characters with '<'
            MRZContent[z] = MRZContent[z].padRight(30, '<');
          } else if (z == 2 && MRZContent[z].length < 30) {
            // For the second line, we need to handle the special case
            String buff = MRZContent[z][MRZContent[z].length - 1];
            // Replace the last character with '<'
            MRZContent[z] =
                '${MRZContent[z].substring(0, MRZContent[z].length - 1)}<';
            // Fill the remaining characters with '<'
            MRZContent[z] = MRZContent[z].padRight(30, '<');
          }
        }

        RegExp line1Regex =
            RegExp(r"(ID|DL)([A-Z]{3})([A-Z0-9<]{9})([0-9]{1})([A-Z0-9<]{15})");
        RegExp line2Regex = RegExp(
            r"([0-9]{6})([0-9]{1})([M|F|X|<]{1})([0-9]{6})([0-9]{1})([A-Z]{3})([A-Z0-9<]{11})([0-9]{1})");
        RegExp line3Regex = RegExp(r"([A-Z0-9<]{30})");

        if (line1Regex.hasMatch(MRZContent[0]) &&
            line2Regex.hasMatch(MRZContent[1]) &&
            line3Regex.hasMatch(MRZContent[2])) {
          //deleting additional lines
          if (MRZContent.length > 3) {
            for (int z = 3; z < MRZContent.length; z++) {
              MRZContent.removeAt(z);
            }
          }
          return MRZContent;
        } else {
          return MRZContent;
        }
      }
      // PASSPORT
      else if (ocrContent.substring(i, i + 4) == "P<DZ") {
        ocrContent = ocrContent.substring(i);
        MRZContent = ocrContent.split("\n");

        //deleting additional lines
        if (MRZContent.length > 2) {
          for (int z = 2; z < MRZContent.length; z++) {
            MRZContent.removeAt(z);
          }
        }

        //verifying length
        if (MRZContent.length > 3) {
          for (int z = 2; z < MRZContent.length; z++) {
            MRZContent[2] = MRZContent.elementAt(2) + MRZContent.elementAt(z);
          }
        }

        // Looping through list MRZ elements
        for (int j = 0; j < MRZContent.length; j++) {
          MRZContent[j] = MRZContent[j]
              .replaceAll(" ", "")
              .replaceAll("«", "<")
              .replaceAll("DZAK", "DZA<")
              .replaceAllMapped(
                RegExp(r'([A-Z])([Kk])(<[A-Z])'),
                (Match m) => '${m.group(1)}<${m.group(3)}',
              )
              .replaceAllMapped(
            RegExp(r'<([^<A-Z\s]+|[kK]+)<'),

            // Matches any characters between two '<' that are not '<'
            (match) {
              int nonLessThanCount = match.group(0)!.length -
                  2; // Subtract 2 for the surrounding `<`

              return '<${'<' * nonLessThanCount}<';
            },
          ).replaceAllMapped(
            RegExp(r'(<<|<)([A-Z]{3,})(K|k)<'),
            (match) {
           
              String prefix = match.group(1)!; // << or <
              String name =
                  match.group(2)!; // The sequence of uppercase letters
              String suffix = match.group(3)!; // The 'K' or 'k'
              String nameWithSuffix =
                  '$name$suffix'; // Combine the name and suffix

              // Check if 'NAMEk' (or similar) is not in the names list
              if (!names.contains(nameWithSuffix)) {
                return '$prefix$name<'; // Replace 'K' or 'k' with '<'
              }
              return '$prefix$name$suffix<'; // Leave 'K' or 'k' unchanged
            },
          );
          if (!MRZContent[j].endsWith("<") && j == 0) {
            // Replace the last character with "<"
            MRZContent[j] =
                "${MRZContent[j].substring(0, MRZContent[j].length - 1)}<";
          }
        }

        // Filling remaining characters to ensure each line has at least 30 characters
        for (int z = 0; z < MRZContent.length; z++) {
          MRZContent[z] = MRZContent[z].toUpperCase();
          if ((z == 0) && MRZContent[z].length < 44) {
            // Fill remaining characters with '<' until the length is 44
            MRZContent[z] = MRZContent[z].padRight(44, '<');
          } else if (z == 1 && MRZContent[z].length < 44) {
            // Save the last two characters in the buffer
            String buff = MRZContent[z].substring(MRZContent[z].length - 2);

            // Remove the last two characters and pad the string to length 42
            MRZContent[z] = MRZContent[z]
                .substring(0, MRZContent[z].length - 2)
                .padRight(42, '<');

            // Append the buffered last two characters
            MRZContent[z] = MRZContent[z] + buff;
          }
        }

        // Validate using passport regex
        RegExp line1Regex = RegExp(r"P[A-Z0-9<]{1}[A-Z]{3}[A-Z0-9<]{39}");
        RegExp line2Regex = RegExp(
            r"([A-Z0-9<]{9})([0-9]{1})([A-Z]{3})([0-9]{6})([0-9]{1})([M|F|X|<]{1})([0-9]{6})([0-9]{1})([A-Z0-9<]{14})([0-9]{1})([0-9]{1})");

        if (line1Regex.hasMatch(MRZContent[0]) &&
            line2Regex.hasMatch(MRZContent[1])) {
          return MRZContent;
        } else {
          return MRZContent;
          //throw Exception("Invalid matching for Passport");
        }
      }

      i++;
    }
  } catch (e) {
    return [e.toString()];
  }

  return [];
}

Future<String> cropAndEnhanceMRZ(String sourcePath) async {
  // Get the directory to save the processed image
  final Directory fixedDir = await getApplicationDocumentsDirectory();

  // Read the image
  final res = cv.imread(sourcePath);

  // Check if image was loaded correctly
  if (res.isEmpty) {
    throw Exception('Failed to load image from path: $sourcePath');
  }

  final grey = cv.cvtColor(res, cv.COLOR_BGR2GRAY);

  // Calculate the cropping region to preserve full width and crop the lower part
  int height = grey.height;
  int width = grey.width;
  int startY =
      (height * 0.60).toInt(); // Start cropping from 60% of the image height
  int croppedHeight = height - startY;

  // Define the center point for the ROI
  final center = cv.Point2f(width / 2, (startY + croppedHeight / 2).toDouble());

  // Crop the lower part of the image (MRZ area) while preserving full width
  final croppedImage = cv.getRectSubPix(grey, (width, croppedHeight), center);

  // Define a sharpening kernel
  final sharpeningKernel = cv.Mat.fromList(
      3, 3, cv.MatType.CV_8SC1, [0, -1, 0, -1, 5, -1, 0, -1, 0]);

  // Apply the sharpening filter
  final sharpenedImage = cv.filter2D(croppedImage, -1, sharpeningKernel);

  // Save the processed image to the specified output path
  final processedImagePath = path.join(fixedDir.path, 'sharpened_mrz.jpg');
  final success = cv.imwrite(processedImagePath, sharpenedImage);

  // Check if the image was saved successfully
  if (!success) {
    throw Exception('Failed to save image to path: $processedImagePath');
  }

  // Return the path of the saved image
  return processedImagePath;
}

Future<List<String>> readAndSplitFile() async {
  // Load the file content from the assets directory
  final String fileContent =
      await rootBundle.loadString('assets/txts/Knames.txt');

  // Convert the content to uppercase and split by whitespace
  return fileContent.toUpperCase().split(RegExp(r'\s+'));
}
