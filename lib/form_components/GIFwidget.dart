import 'package:facial_reco_p_o_c/app_state.dart';
import 'package:flutter/material.dart';

class GIFwidget extends StatelessWidget {
  // Constructor for the widget
  const GIFwidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Container(
                width: 300.0,
                height: 600.0,
                child: Image.asset(
                  "assets/images/loading.gif",
                  height: 125.0,
                  width: 125.0,
                )),
            //  ElevatedButton (onPressed: (){FFAppState().multiStepState++;}, child: Text("Je comprends !"))
          ],
        ));
  }
}
