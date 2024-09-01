import 'package:facial_reco_p_o_c/form_components/p_d_f_reader/p_d_f_reader_model.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/form_components/form_navigator/form_navigator_widget.dart';
import '/form_components/m_r_z_scanner/m_r_z_scanner_widget.dart';
import '/form_components/operation_compeleted/operation_compeleted_widget.dart';
import '/form_components/p_d_f_reader/p_d_f_reader_widget.dart';
import '/form_components/take_self/take_self_widget.dart';
import '/form_components/verify_matching/verify_matching_widget.dart';
import 'multi_form_page_widget.dart' show MultiFormPageWidget;
import 'package:flutter/material.dart';

class MultiFormPageModel extends FlutterFlowModel<MultiFormPageWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FormNavigator component.
  late FormNavigatorModel formNavigatorModel;
  // Model for TakeSelf component.
  late TakeSelfModel takeSelfModel;
  // Model for MRZScanner component.
  late MRZScannerModel mRZScannerModel;
  // Model for VerifyMatching component.
  late VerifyMatchingModel verifyMatchingModel;
  // Model for PDFReader component.
  late PDFReaderModel pDFReaderModel;
  // Model for OperationCompeleted component.
  late OperationCompeletedModel operationCompeletedModel;

  @override
  void initState(BuildContext context) {
    formNavigatorModel = createModel(context, () => FormNavigatorModel());
    takeSelfModel = createModel(context, () => TakeSelfModel());
    mRZScannerModel = createModel(context, () => MRZScannerModel());
    verifyMatchingModel = createModel(context, () => VerifyMatchingModel());
    pDFReaderModel = createModel(context, () => PDFReaderModel());
    operationCompeletedModel =
        createModel(context, () => OperationCompeletedModel());
  }

  @override
  void dispose() {
    formNavigatorModel.dispose();
    takeSelfModel.dispose();
    mRZScannerModel.dispose();
    verifyMatchingModel.dispose();
    pDFReaderModel.dispose();
    operationCompeletedModel.dispose();
  }
}
