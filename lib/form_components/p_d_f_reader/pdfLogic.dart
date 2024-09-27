import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

void generateUserPDF(
    Map<String, String> userMap, String rectoPID, String versoPID) async {
  // Load the existing PDF document
  final ByteData data = await rootBundle.load('assets/pdfs/contract.pdf');
  final Uint8List bytes = data.buffer.asUint8List();

  // Creating a PdfDocument from bytes
  final PdfDocument document = PdfDocument(inputBytes: bytes);

  // Get the first page of the PDF
  PdfPage page = document.pages[0];

  // Create a PDF graphics object to draw on the page
  PdfGraphics graphics = page.graphics;

  // Define a list of positions for each entry (l, t, w, h)
  List<Rect> positionList = [
    Rect.fromLTWH(0, 0, 0, 0), // Position for first entry
    Rect.fromLTWH(0, 20, 0, 0), // Position for second entry
    Rect.fromLTWH(0, 40, 0, 0), // Position for third entry
    Rect.fromLTWH(0, 60, 0, 0), // Continue adding positions...
    Rect.fromLTWH(0, 80, 0, 0),
    Rect.fromLTWH(0, 100, 0, 0),
    Rect.fromLTWH(0, 120, 0, 0),
    Rect.fromLTWH(0, 140, 0, 0),
    Rect.fromLTWH(0, 160, 0, 0),
    Rect.fromLTWH(0, 180, 0, 0),
    Rect.fromLTWH(0, 200, 0, 0),
    Rect.fromLTWH(0, 220, 0, 0),
    Rect.fromLTWH(0, 240, 0, 0),
    Rect.fromLTWH(0, 260, 0, 0),
    Rect.fromLTWH(0, 280, 0, 0),
    Rect.fromLTWH(0, 300, 0, 0),
    Rect.fromLTWH(0, 320, 0, 0),
    Rect.fromLTWH(0, 340, 0, 0),
    Rect.fromLTWH(0, 360, 0, 0),
    Rect.fromLTWH(0, 380, 0, 0),
    Rect.fromLTWH(0, 400, 0, 0),
  ];

  // Iterate over the entries in the userMap
  int i = 0; // Index for positionList
  for (var entry in userMap.entries) {
    if (i < positionList.length) {
      graphics.drawString(
        '${entry.key}: ${entry.value}', // Format the string as "Key: Value"
        PdfStandardFont(PdfFontFamily.helvetica, 18),
        bounds: positionList[i], // Use the specific position from the list
      );
      i++; // Move to the next position for the next entry
    } else {
      // Handle the case where there are more entries than positions
      break; // Optionally break, or you can handle it as needed
    }
  }

  // Add a new page for Recto
  PdfPage rectoPage = document.pages.add();
  // Load recto image and draw it on the new page
  PdfBitmap rectoImage = PdfBitmap(File(rectoPID).readAsBytesSync());
  rectoPage.graphics.drawImage(
    rectoImage,
    Rect.fromLTWH(0, 0, rectoPage.getClientSize().width,
        rectoPage.getClientSize().height / 2),
  );

  // Add a new page for Verso
  PdfPage versoPage = document.pages.add();
  // Load verso image and draw it on the new page
  PdfBitmap versoImage = PdfBitmap(File(versoPID).readAsBytesSync());
  versoPage.graphics.drawImage(
    versoImage,
    Rect.fromLTWH(0, 0, versoPage.getClientSize().width,
        versoPage.getClientSize().height / 2),
  );

  // Save the modified PDF to a new file
  List<int> outputBytes = document.saveSync();
  // Get the application documents directory
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/userPDF.pdf';

  // Write the file to the documents directory
  final file = File(path);
  await file.writeAsBytes(outputBytes);

  FFAppState().setuserPDF(true);
  // Dispose the document
  document.dispose();
}
