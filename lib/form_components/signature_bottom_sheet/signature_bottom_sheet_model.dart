import '/flutter_flow/flutter_flow_util.dart';
import 'signature_bottom_sheet_widget.dart' show SignatureBottomSheetWidget;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureBottomSheetModel
    extends FlutterFlowModel<SignatureBottomSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Signature widget.
  SignatureController? signatureController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    signatureController?.dispose();
  }
}
