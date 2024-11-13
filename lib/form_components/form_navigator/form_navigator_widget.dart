import 'dart:collection';
import 'dart:io';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'form_navigator_model.dart';
export 'form_navigator_model.dart';

class FormNavigatorWidget extends StatefulWidget {
  const FormNavigatorWidget({
    super.key,
    required this.currentStep,
  });

  final int? currentStep;

  @override
  State<FormNavigatorWidget> createState() => _FormNavigatorWidgetState();
}

class _FormNavigatorWidgetState extends State<FormNavigatorWidget> {
  late FormNavigatorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormNavigatorModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  Future<void> clearMemory() async {
    FFAppState().matchingScore = 0.0;
    FFAppState().setMatchingRes(false);
    FFAppState().setuserPDF(false);
    FFAppState().FieldsToAddList = [];
    FFAppState().setFromData(HashMap<String, String>());
    FFAppState().setContractSigned(false);
    await File(FFAppState().documentImagePathRecto).delete();
    await File(FFAppState().documentImagePathVerso).delete();
    await File(FFAppState().extractedPerson).delete();
    await File(FFAppState().selfieImagePath).delete();
    await File("/data/user/0/com.sga.prod/app_flutter/userPDF.pdf").delete();
    await File(
            // ignore: prefer_interpolation_to_compose_strings
            "${'/data/user/0/com.sga.prod/app_flutter/signedContract_' + FFAppState().nfcMap["lastName"]}.pdf")
        .delete();
    FFAppState().setExtractedPerson("");
    FFAppState().setSelfie("");
    FFAppState().setNfcMap({});
    FFAppState().setdocumentImagePathRecto("");
    FFAppState().setdocumentImagePathVerso("");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        boxShadow: const [
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
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FlutterFlowIconButton(
            borderColor: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: 20.0,
            borderWidth: 1.0,
            buttonSize: 40.0,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            disabledColor: FlutterFlowTheme.of(context).secondaryBackground,
            disabledIconColor: FlutterFlowTheme.of(context).secondaryBackground,
            icon: Icon(
              Icons.arrow_back,
              color: FlutterFlowTheme.of(context).tertiary,
              size: 24.0,
            ),
            onPressed: (widget.currentStep == 0)
                ? null
                : () async {
                    FFAppState().multiStepState =
                        FFAppState().multiStepState - 1;
                    _model.updatePage(() {});
                  },
          ),
          Builder(
            builder: (context) {
              if (widget.currentStep! < 3) {
                return FlutterFlowIconButton(
                  borderColor: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: 20.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  disabledColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                  disabledIconColor:
                      FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.arrow_forward_sharp,
                    color: FlutterFlowTheme.of(context).primary,
                    size: 24.0,
                  ),
                  onPressed: (widget.currentStep == 4)
                      ? null
                      : () async {
                          if (widget.currentStep == 0 &&
                              FFAppState().selfieImagePath.isNotEmpty) {
                            FFAppState().multiStepState =
                                FFAppState().multiStepState + 1;
                          }
                          if (widget.currentStep == 1 &&
                              FFAppState().selfieImagePath.isNotEmpty &&
                              FFAppState().documentImagePathRecto.isNotEmpty &&
                              FFAppState().documentImagePathVerso.isNotEmpty &&
                              FFAppState().formData != null) {
                            FFAppState().multiStepState =
                                FFAppState().multiStepState + 1;
                          }
                          if (widget.currentStep == 2 &&
                              FFAppState().matchingRes) {
                            FFAppState().multiStepState =
                                FFAppState().multiStepState + 1;
                          }

                          _model.updatePage(() {});
                        },
                );
              } else if (FFAppState().contractSigned == true) {
                return FlutterFlowIconButton(
                  borderColor: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: 20.0,
                  borderWidth: 1.0,
                  buttonSize: 40.0,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  icon: Icon(
                    Icons.check,
                    color: FlutterFlowTheme.of(context).secondary,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    //clear memory
                    await clearMemory();
                    FFAppState().multiStepState = 0;
                    _model.updatePage(() {});
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
