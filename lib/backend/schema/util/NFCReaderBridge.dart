import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:flutter/services.dart';

class NFCReaderBridge {
  static const platform = MethodChannel('nfc_reader');

  NFCReaderBridge() {
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> readNFC(
      String documentNumber, String dateOfBirth, String dateOfExpiry) async {
    try {
      await platform.invokeMethod('readNFC', {
        'documentNumber': documentNumber,
        'dateOfBirth': dateOfBirth,
        'dateOfExpiry': dateOfExpiry,
      });
    } on PlatformException catch (e) {
      throw "Failed to read NFC: '${e.message}'.";
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onMRZStart":
        FFAppState().setNfcState(1);
        break; // Ensure you break after each case

      case "onMRZData":
        Map<String, dynamic> mrzData =
            Map<String, dynamic>.from(call.arguments);

        FFAppState().setNfcMap(mrzData);
        // Handle MRZ data
        FFAppState().setNfcState(2);
        break; // Ensure you break after each case

      case "onMRZError":
        FFAppState().setNfcState(3);
        break; // Ensure you break after each case

      default:
        throw MissingPluginException('notImplemented');
    }
  }
}
