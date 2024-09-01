/*import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mrz_scanner/flutter_mrz_scanner.dart';

class CameraPage extends StatefulWidget {
  final void Function(Map<String, String>) onUpdate;
  final void Function(Map<String, String>) updateTextControllers;
  const CameraPage({super.key, required this.onUpdate, required this.updateTextControllers});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool isParsed = false;
  MRZController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: MRZScanner(
        withOverlay: true,
        onControllerCreated: onControllerCreated,
      ),
    );
  }

  @override
  void dispose() {
    controller?.stopPreview();
    super.dispose();
  }

  void onControllerCreated(MRZController controller) {
    this.controller = controller;
    controller.onParsed = (result) async {
      if (isParsed) {
        return;
      }
      isParsed = true;

      // Create a map to hold MRZ data
      Map<String, String> mrzMap = {
        "Document type": result.documentType.toString(),
        "Country": result.countryCode,
        "Surnames": result.surnames,
        "Given names": result.givenNames,
        "Document number": result.documentNumber,
        "Nationality code": result.nationalityCountryCode,
        "Birthdate": result.birthDate.toString(),
        "Sex": result.sex.toString(),
        "Expiry date": result.expiryDate.toString(),
        "Personal number": result.personalNumber,
        "Personal number 2": result.personalNumber2.toString(),
      };
      print(result);
      widget.onUpdate(mrzMap); // Pass data to parent widget
      widget.updateTextControllers(mrzMap); // Update text fields
      FFAppState().setFromData(mrzMap);
      Navigator.pop(context, true);
    };

    controller.onError = (error) => print(error);

    controller.startPreview();
  }
}
*/