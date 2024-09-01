import '/flutter_flow/flutter_flow_util.dart';
import '/others/dark_light_changer/dark_light_changer_widget.dart';
import 'preferences_widget.dart' show PreferencesWidget;
import 'package:flutter/material.dart';

class PreferencesModel extends FlutterFlowModel<PreferencesWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for darkLightChanger component.
  late DarkLightChangerModel darkLightChangerModel;
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue1;
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue2;
  // State field(s) for SwitchListTile widget.
  bool? switchListTileValue3;

  @override
  void initState(BuildContext context) {
    darkLightChangerModel = createModel(context, () => DarkLightChangerModel());
  }

  @override
  void dispose() {
    darkLightChangerModel.dispose();
  }
}
