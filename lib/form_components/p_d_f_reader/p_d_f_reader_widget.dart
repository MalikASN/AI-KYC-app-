import 'dart:io';

import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_icon_button.dart';
import 'package:facial_reco_p_o_c/form_components/p_d_f_reader/pdfLogic.dart';
import 'package:facial_reco_p_o_c/form_components/signature_bottom_sheet/signature_bottom_sheet_widget.dart';
import 'package:path_provider/path_provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';

class PDFReaderWidget extends StatefulWidget {
  const PDFReaderWidget({super.key});

  @override
  State<PDFReaderWidget> createState() => _PDFReaderWidgetState();
}

class _PDFReaderWidgetState extends State<PDFReaderWidget> {
  String pdfPath = "/data/user/0/com.sga.prod/app_flutter/userPDF.pdf";

  void updatePDFPath(String path) {
    setState(() {
      pdfPath = path;
    });
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
  }

  @override
  void initState() {
    super.initState();

    generateUserPDF(FFAppState().formData, FFAppState().documentImagePathRecto,
        FFAppState().documentImagePathVerso);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FFAppState>(
      builder: (context, ffAppState, child) {
        return Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      10.0, 15.0, 10.0, 20.0),
                  child: Text(
                    'Generated pdf contract',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: 444.0,
                  height: 504.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 860.0,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 40.0),
                          child: ffAppState.displayUserpdf == true
                              ? PdfViewer.file(pdfPath)
                              : const Center(
                                  child: Text("loading..."),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              pdfPath == "/data/user/0/com.sga.prod/app_flutter/userPDF.pdf"
                  ? Align(
                      alignment: AlignmentDirectional(0.93, 0.94),
                      child: FlutterFlowIconButton(
                        borderColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: 20.0,
                        borderWidth: 1.0,
                        buttonSize: 59.0,
                        fillColor:
                            FlutterFlowTheme.of(context).secondaryBackground,
                        icon: Icon(
                          Icons.pan_tool_alt_rounded,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 30.0,
                        ),
                        onPressed: () async {
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            enableDrag: false,
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: SignatureBottomSheetWidget(
                                    onPDFUpdate: updatePDFPath),
                              );
                            },
                          ).then((value) => safeSetState(() {}));
                        },
                      ),
                    )
                  : Container()
            ],
          ),
        );
      },
    );
  }
}
