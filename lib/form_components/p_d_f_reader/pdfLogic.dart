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

  // You can now use `bytes` to process the PDF file
  // For example, creating a PdfDocument from bytes:
  final PdfDocument document = PdfDocument(inputBytes: bytes);
  // Get the first page of the PDF
  PdfPage page = document.pages[0];

  // Create a PDF graphics object to draw on the page
  PdfGraphics graphics = page.graphics;

  // Draw text at specific X, Y positions
  graphics.drawString(
    userMap.entries.elementAt(0).value,
    PdfStandardFont(PdfFontFamily.helvetica, 18),
    bounds: const Rect.fromLTWH(0, 0, 0, 0),
  );
  graphics.drawString(
    userMap.entries.elementAt(1).value,
    PdfStandardFont(PdfFontFamily.helvetica, 18),
    bounds: const Rect.fromLTWH(0, 15, 0, 0),
  );

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
