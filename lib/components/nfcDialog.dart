import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogFb2 extends StatefulWidget {
  const DialogFb2({super.key});

  @override
  _DialogFb2State createState() => _DialogFb2State();
}

class _DialogFb2State extends State<DialogFb2> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        height: MediaQuery.of(context).size.height / 4,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  "assets/images/nfcLogo.png",
                  width: 85,
                  height: 50,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Text(
              "Scan NFC en cours",
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).primary,
                    fontSize: 16.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 3.5),
            Consumer<FFAppState>(
              builder: (context, nfcProvider, child) {
                final nfcState = nfcProvider.nfcState;

                if (nfcState == 0) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      child: Text(
                        "Veuillez approcher votre PID",
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context).secondary,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  );
                }

                if (nfcState == 1) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary,
                    ),
                  );
                }

                if (nfcState == 2) {
                  // Show check icon while waiting for 2 seconds
                  Navigator.of(context).pop();
                }

                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
