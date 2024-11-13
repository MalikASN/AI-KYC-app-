import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:facial_reco_p_o_c/backend/schema/util/SignDocBridge.dart';
import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_theme.dart';
import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_util.dart';
import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_widgets.dart';
import 'package:facial_reco_p_o_c/form_components/signature_bottom_sheet/mail_sender.dart';
import 'package:facial_reco_p_o_c/form_components/signature_bottom_sheet/signature_bottom_sheet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SignatureBottomSheetWidget extends StatefulWidget {
  final void Function(String) onPDFUpdate;
  const SignatureBottomSheetWidget({super.key, required this.onPDFUpdate});

  @override
  State<SignatureBottomSheetWidget> createState() =>
      _SignatureBottomSheetWidgetState();
}

class _SignatureBottomSheetWidgetState
    extends State<SignatureBottomSheetWidget> {
  late SignatureBottomSheetModel _model;
  String showError = "null";
  Uint8List? signatureImageData;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignatureBottomSheetModel());
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<bool> _isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _sendSignatureToJava(BuildContext context) async {
    try {
      bool connected = await _isConnected();
      if (!connected) {
        setState(() {
          showError = "Pas de connexion internet";
        });
        return;
      }

      /*setState(() {
        showError = "null";
      });*/

      // Capture signature as image
      final ui.Image? image = await _model.signatureController?.toImage();
      final ByteData? byteData =
          await image?.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List uint8List = byteData!.buffer.asUint8List();

      // Convert Uint8List to List<int>
      List<int> signatureBytes = uint8List.toList();

      // Update the signature image data
      setState(() {
        signatureImageData = uint8List;
      });

      // Send signature data to Java side
      await SignDocBridge().signDoc(
          "/data/user/0/com.sga.prod/app_flutter/userPDF.pdf",
          4,
          FFAppState().nfcMap["lastName"],
          signatureBytes);

      FFAppState().setContractSigned(true);

      // Get external storage directory
      final directory = await getExternalStorageDirectory();
      // ignore: prefer_interpolation_to_compose_strings
      final filePath =
          // ignore: prefer_interpolation_to_compose_strings
          "${'${directory!.path}/signedContract_' + FFAppState().nfcMap["lastName"]}.pdf";

      final file = File(filePath);
      final localSignedPDF = File(
          // ignore: prefer_interpolation_to_compose_strings
          "${'/data/user/0/com.sga.prod/app_flutter/signedContract_' + FFAppState().nfcMap["lastName"]}.pdf");

      // Write PDF data to file
      try {
        await file.writeAsBytes(localSignedPDF.readAsBytesSync());
      } catch (e) {
        print('Failed to save PDF: $e');
      }
      try {
        await sendMail(filePath, FFAppState().formData['email']);
      } catch (e) {
        print('Failed send the pdf by mail: $e');
      }
      context.pop();
      final filePathUi =
          // ignore: prefer_interpolation_to_compose_strings
          "${'${directory!.path}/signedContract_' + FFAppState().nfcMap["lastName"]}.pdf";

      widget.onPDFUpdate(filePathUi);

      Vibration.vibrate();
    } on PlatformException catch (e) {
      Vibration.vibrate(repeat: 2, duration: 100);
      setState(() {
        showError = e.message!;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 450.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      thickness: 3.0,
                      indent: 150.0,
                      endIndent: 150.0,
                      color: FlutterFlowTheme.of(context).primaryBackground,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 4.0, 16.0, 5.0),
                            child: Text(
                              'Signez votre contrat',
                              style: FlutterFlowTheme.of(context)
                                  .headlineMedium
                                  .override(
                                    fontFamily: 'Outfit',
                                    color: FlutterFlowTheme.of(context).primary,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 406.0,
                        height: 226.0,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.0,
                              color: Color(0x33000000),
                              offset: Offset(
                                0.0,
                                2.0,
                              ),
                            )
                          ],
                        ),
                        child: ClipRect(
                          child: Signature(
                            controller: _model.signatureController ??=
                                SignatureController(
                              penStrokeWidth: 2.0,
                              penColor: Colors.black,
                              exportBackgroundColor: Colors.white,
                            ),
                            backgroundColor: Colors.white,
                            height: 150.0,
                          ),
                        ),
                      ),
                    ),
                    showError != 'null'
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                showError,
                                style: FlutterFlowTheme.of(context)
                                    .labelMedium
                                    .override(
                                      color: FlutterFlowTheme.of(context).error,
                                      fontSize: 15,
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 25.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          FFButtonWidget(
                            onPressed: () {
                              context.pop();
                            },
                            text: 'Annuler',
                            options: FFButtonOptions(
                              width: 150.0,
                              height: 50.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              textStyle: FlutterFlowTheme.of(context)
                                  .labelMedium
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                              elevation: 2.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                          ),
                          FFButtonWidget(
                            onPressed: () async {
                              await _sendSignatureToJava(context);
                            },
                            text: 'Confirmer',
                            options: FFButtonOptions(
                              width: 150.0,
                              height: 50.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).primary,
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Lexend Deca',
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                  ),
                              elevation: 2.0,
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
