import 'dart:convert';

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
    Rect.fromLTWH(90, 215, 0, 0), //  firstname
    Rect.fromLTWH(120, 365, 0, 0), // adresse principale
    Rect.fromLTWH(80, 50, 0, 0), //nationnality
    Rect.fromLTWH(80, 203, 0, 0), // lastname
    Rect.fromLTWH(90, 433, 0, 0), //employeur
    Rect.fromLTWH(110, 527, 0, 0), //email
    Rect.fromLTWH(90, 420, 0, 0), //profession
    Rect.fromLTWH(90.5, 353.5, 0, 0), //statut martial
    Rect.fromLTWH(80, 576, 0, 0), // nom delivereur
    Rect.fromLTWH(160, 504, 0, 0), //phone Mobile
    Rect.fromLTWH(110, 552, 0, 0), //lieu deliverance
    Rect.fromLTWH(160, 480, 0, 0), //phone domicile
    Rect.fromLTWH(200, 275, 0, 0), // mere
    Rect.fromLTWH(120, 540, 0, 0), // doc id
    Rect.fromLTWH(80, 590, 0, 0), // montants revenus
    Rect.fromLTWH(170, 457, 0, 0), //tel professionel
    Rect.fromLTWH(140, 275, 0, 0), //pere
    Rect.fromLTWH(125, 240, 0, 0), //birthdate
    Rect.fromLTWH(80, 564, 0, 0), //date deliverance
    Rect.fromLTWH(120, 227, 0, 0), //jeune fille
    Rect.fromLTWH(120, 252, 0, 0), // lieu naissance
  ];

  // Iterate over the entries in the userMap
  int i = 0; // Index for positionList
  for (var entry in userMap.entries) {
    if (i < positionList.length) {
      if (entry.key == 'Nationalite') {
        graphics.drawString(
            entry.value == 'DZA'
                ? 'x'
                : entry.value, // Format the string as "Key: Value"
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            bounds: entry.value == 'DZA'
                ? const Rect.fromLTWH(95.5, 297.5, 0, 0)
                : const Rect.fromLTWH(191.5, 297.5, 0,
                    0) // Use the specific position from the list
            );
      } else if (entry.key == 'statusMartial') {
        if (entry.value == 'Marié(e)') {
          graphics.drawString(
            'x', // Format the string as "Key: Value"
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            bounds: const Rect.fromLTWH(
                101.5, 353.5, 0, 0), // Use the specific position from the list
          );
        } else if (entry.value == 'Séparé(e)') {
          graphics.drawString(
            'x', // Format the string as "Key: Value"
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            bounds: const Rect.fromLTWH(
                114, 345, 0, 0), // Use the specific position from the list
          );
        } else if (entry.value == 'Veuf/Veuve') {
          graphics.drawString(
            'x', // Format the string as "Key: Value"
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            bounds: const Rect.fromLTWH(
                60.5, 353.5, 0, 0), // Use the specific position from the list
            // Use the specific position from the list
          );
        } else if (entry.value == 'Divorcé(e)') {
          graphics.drawString(
            'x', // Format the string as "Key: Value"
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            bounds: const Rect.fromLTWH(
                149.5, 353.5, 0, 0), // Use the specific position from the list
          );
        } else if (entry.value == 'Célibataire') {
          graphics.drawString(
            'x', // Format the string as "Key: Value"
            PdfStandardFont(PdfFontFamily.helvetica, 10),
            bounds: const Rect.fromLTWH(
                68.5, 345, 0, 0), // Use the specific position from the list
          );
        }
      } else if (entry.key == 'montant') {
        Map<String, dynamic> restoredMap = json.decode(entry.value);

        //draw salaire
        graphics.drawString(
          restoredMap['Salaire']
              .toString(), // Format the string as "Key: Value"
          PdfStandardFont(PdfFontFamily.helvetica, 10),
          bounds: const Rect.fromLTWH(
              107, 612, 0, 0), // Use the specific position from the list
        );
        //draw revenus locatifs
        graphics.drawString(
          restoredMap['Revenus locatifs']
              .toString(), // Format the string as "Key: Value"
          PdfStandardFont(PdfFontFamily.helvetica, 10),
          bounds: const Rect.fromLTWH(
              135, 622, 0, 0), // Use the specific position from the list
        );
        // draw retraite
        graphics.drawString(
          restoredMap['Retraite']
              .toString(), // Format the string as "Key: Value"
          PdfStandardFont(PdfFontFamily.helvetica, 10),
          bounds: const Rect.fromLTWH(
              105, 633, 0, 0), // Use the specific position from the list
          // Use the specific position from the list
        );
        // draw revenus sur capitale
        graphics.drawString(
          restoredMap['Revenu sur le capital']
              .toString(), // Format the string as "Key: Value"
          PdfStandardFont(PdfFontFamily.helvetica, 10),
          bounds: const Rect.fromLTWH(
              155, 643, 0, 0), // Use the specific position from the list
        );
        // draw pension
        graphics.drawString(
          restoredMap['Pension']
              .toString(), // Format the string as "Key: Value"
          PdfStandardFont(PdfFontFamily.helvetica, 10),
          bounds: const Rect.fromLTWH(
              111, 655, 0, 0), // Use the specific position from the list
        );
      } else {
        print('${entry.key}:${entry.value.toString()}:index${i.toString()}');
        graphics.drawString(
          entry.value.toString(), // Format the string as "Key: Value"
          PdfStandardFont(PdfFontFamily.helvetica, 8),
          bounds: positionList[i], // Use the specific position from the list
        );
      }
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
