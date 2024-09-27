import 'dart:async'; // Ajoutez cette importation
import 'dart:io';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:provider/provider.dart';

import '../../backend/schema/util/DermalogBridge.dart';
import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'verify_matching_model.dart';
export 'verify_matching_model.dart';

class VerifyMatchingWidget extends StatefulWidget {
  const VerifyMatchingWidget({super.key});

  @override
  State<VerifyMatchingWidget> createState() => _VerifyMatchingWidgetState();
}

class _VerifyMatchingWidgetState extends State<VerifyMatchingWidget>
    with TickerProviderStateMixin {
  late VerifyMatchingModel _model;
  int stateProgression = 0;
  bool comparaisonResult = false;
  final animationsMap = <String, AnimationInfo>{};
  bool _isNFCAvail = true;
  Timer? _nfcCheckTimer; // Ajoutez une variable Timer
  bool useGoogle = true;
  bool _showImage = false;
  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  Future<bool> isNFCAvailable() async {
    var availability = await FlutterNfcKit.nfcAvailability;
    return availability == NFCAvailability.available;
  }

  void checkNFCAvailability() async {
    final res = await isNFCAvailable();

    setState(() {
      _isNFCAvail = res;
    });

    // Ajoutez un court délai pour assurer que setState est terminé
    await Future.delayed(const Duration(milliseconds: 500));

    // Appelez _performAsyncOperations seulement après la mise à jour de l'état de disponibilité NFC
    if (stateProgression == 0) {
      _performAsyncOperations(DermalogBridge());
    }
  }

  void _performAsyncOperations(DermalogBridge dermalogBridge) async {
    if (_isNFCAvail == false) {
      if (FFAppState().useGooleML) {
        await dermalogBridge.ExtractFaceML();
      } else {
        await dermalogBridge.ExtractFace();
      }
    }

    setState(() {
      _showImage = true;
    });

    setState(() => stateProgression += 1);

    bool res = await dermalogBridge.CompareTwoFaces();
    setState(() => stateProgression += 1);
    setState(() => comparaisonResult = res);
  }

  void startNFCCheckTimer() {
    // Vérifiez périodiquement la disponibilité NFC toutes les 5 secondes
    _nfcCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkNFCAvailability();
    });
  }

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => VerifyMatchingModel());
    animationsMap.addAll({
      'iconOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });
    checkNFCAvailability(); // Vérification initiale
    startNFCCheckTimer(); // Démarrer les vérifications périodiques NFC
  }

  @override
  void dispose() {
    setState(() => stateProgression = 0);
    _nfcCheckTimer
        ?.cancel(); // Annuler le minuteur lorsque le widget est éliminé
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FFAppState>(builder: (context, ffAppState, child) {
      return Container(
        width: 390.0,
        height: 338.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Consumer<FFAppState>(
              builder: (context, ffAppState, child) {
                String extracted = ffAppState.extractedPerson;
                if (_showImage && extracted.isNotEmpty) {
                  return Image.file(
                    File(extracted),
                    width: 200,
                    height: 200,
                  );
                }
                return Container();
              },
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                child: Text(
                  stateProgression == 0
                      ? 'Vérification de la correspondance...'
                      : stateProgression == 1
                          ? "Détection de l'image de l'utilisateur"
                          : stateProgression == 2
                              ? 'Comparaison des images'
                              : stateProgression == 3
                                  ? "Résultat :"
                                  : "",
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
            comparaisonResult
                ? Icon(
                    Icons.check_circle_outline,
                    color: FlutterFlowTheme.of(context).secondary,
                    size: 120.0,
                  ).animateOnPageLoad(animationsMap['iconOnPageLoadAnimation']!)
                : Icon(
                    Icons.error_outline_outlined,
                    color: FlutterFlowTheme.of(context).error,
                    size: 120.0,
                  ).animateOnPageLoad(
                    animationsMap['iconOnPageLoadAnimation']!),
            FFAppState().matchingScore != 0.0
                ? Text(
                    "Le score de correspondance est : ${FFAppState().matchingScore}",
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          color: FlutterFlowTheme.of(context).primary,
                          fontSize: 15.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                : Container(),
          ],
        ),
      );
    });
  }
}
