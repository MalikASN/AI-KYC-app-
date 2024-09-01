import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/form_components/form_navigator/form_navigator_widget.dart';
import '/form_components/m_r_z_scanner/m_r_z_scanner_widget.dart';
import '/form_components/operation_compeleted/operation_compeleted_widget.dart';
import '/form_components/p_d_f_reader/p_d_f_reader_widget.dart';
import '/form_components/take_self/take_self_widget.dart';
import '/form_components/verify_matching/verify_matching_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'multi_form_page_model.dart';

export 'multi_form_page_model.dart';

class MultiFormPageWidget extends StatefulWidget {
  const MultiFormPageWidget({super.key});

  @override
  State<MultiFormPageWidget> createState() => _MultiFormPageWidgetState();
}

class _MultiFormPageWidgetState extends State<MultiFormPageWidget>
    with TickerProviderStateMixin {
  late MultiFormPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MultiFormPageModel());

    animationsMap.addAll({
      'takeSelfOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'mRZScannerOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'verifyMatchingOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'pDFReaderOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'operationCompeletedOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'E-sim activi',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          actions: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
              child: FlutterFlowIconButton(
                borderColor: FlutterFlowTheme.of(context).primary,
                borderRadius: 20.0,
                borderWidth: 1.0,
                buttonSize: 40.0,
                fillColor: FlutterFlowTheme.of(context).accent1,
                icon: Icon(
                  Icons.settings,
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  size: 30.0,
                ),
                onPressed: () async {
                  context.pushNamed('Preferences');
                },
              ),
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                wrapWithModel(
                  model: _model.formNavigatorModel,
                  updateCallback: () => setState(() {}),
                  child: FormNavigatorWidget(
                    currentStep: valueOrDefault<int>(
                      FFAppState().multiStepState,
                      0,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 20.0, 0.0, 0.0),
                    child: Builder(
                      builder: (context) {
                        switch (FFAppState().multiStepState) {
                          case 0:
                            return wrapWithModel(
                              model: _model.takeSelfModel,
                              updateCallback: () => setState(() {}),
                              child: const TakeSelfWidget(),
                            ).animateOnPageLoad(
                                animationsMap['takeSelfOnPageLoadAnimation']!);
                          case 1:
                            return wrapWithModel(
                              model: _model.mRZScannerModel,
                              updateCallback: () => setState(() {}),
                              child: const MRZScannerWidget(),
                            ).animateOnPageLoad(animationsMap[
                                'mRZScannerOnPageLoadAnimation']!);
                          case 2:
                            return wrapWithModel(
                              model: _model.verifyMatchingModel,
                              updateCallback: () => setState(() {}),
                              child: const VerifyMatchingWidget(),
                            ).animateOnPageLoad(animationsMap[
                                'verifyMatchingOnPageLoadAnimation']!);
                          case 3:
                            return wrapWithModel(
                              model: _model.pDFReaderModel,
                              updateCallback: () => setState(() {}),
                              child: const PDFReaderWidget(),
                            ).animateOnPageLoad(
                                animationsMap['pDFReaderOnPageLoadAnimation']!);
                          case 4:
                            return wrapWithModel(
                              model: _model.operationCompeletedModel,
                              updateCallback: () => setState(() {}),
                              child: const OperationCompeletedWidget(),
                            ).animateOnPageLoad(animationsMap[
                                'operationCompeletedOnPageLoadAnimation']!);
                          default:
                            return const Center(
                              child: Text('Unknown step'),
                            );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
