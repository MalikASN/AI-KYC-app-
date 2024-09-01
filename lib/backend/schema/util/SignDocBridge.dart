import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:flutter/services.dart';

class SignDocBridge {
  static const platform = MethodChannel('sign_doc_channel');

  Future<void> signDoc(
      String docPath, int pageNum, String signer, List<int> sigImg) async {
    try {

      await platform.invokeMethod('sign_doc', {
        'doc_path': docPath,
        'pageno': pageNum,
        'Signer': signer,
        'sigImg': sigImg
      });
    } on PlatformException catch (e) {
      throw "Failed to sign PDF: '${e.message}'.";
    }
  }
}
