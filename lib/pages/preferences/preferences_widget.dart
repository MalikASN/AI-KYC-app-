import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/color_picker_dialog.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/others/dark_light_changer/dark_light_changer_widget.dart';
import 'package:flutter/material.dart';
import 'preferences_model.dart';
export 'preferences_model.dart';

class PreferencesWidget extends StatefulWidget {
  const PreferencesWidget({super.key});

  @override
  State<PreferencesWidget> createState() => _PreferencesWidgetState();
}

class _PreferencesWidgetState extends State<PreferencesWidget> {
  late PreferencesModel _model;
  Color currentColor = Color.fromARGB(255, 0, 0, 0);
  String? loginLogoPath;

  // Save the selected color to preferences
  Future<void> _saveColorToPreferences(Color color) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorTheme', "0x${color.toHexString()}");

    String? newColor = prefs.getString('colorTheme');
    if (newColor != null && newColor.isNotEmpty) {
      DarkModeTheme().updatePrimaryColor(Color(0xFFEE8B60));
      LightModeTheme().updatePrimaryColor(Color(int.parse(newColor)));
    }
  }

  Future<void> initColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? newColor = prefs.getString('colorTheme');
    if (newColor != null && newColor.isNotEmpty) {
      setState(() {
        currentColor = Color(int.parse(newColor));
      });
    }
  }

  // Load the saved logo path from SharedPreferences
  Future<void> _loadLogoPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginLogoPath = prefs.getString('loginLogo');
    });
  }

  // Save the selected file path to SharedPreferences
  Future<void> _saveLoginLogoPath(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginLogo', path);
    setState(() {
      loginLogoPath = path; // Update UI with new logo path
    });
  }

  // Method to handle color selection
  void onColorSelected(Color color) {
    setState(() {
      currentColor = color;
    });
    _saveColorToPreferences(color); // Save the selected color
  }

  // Save the picked file to a directory in the app and update the logo path in preferences
  Future<void> _pickAndSaveImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowCompression: true);

    if (result != null) {
      if (result.isSinglePick) {
        File file = File(result.files.single.path!);

        // Get the app's documents directory
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String savedFilePath =
            '${appDocDir.path}/${result.files.single.name}';

        // Save the file to the directory
        final File savedFile = await file.copy(savedFilePath);

        // Update the SharedPreferences with the new path
        await _saveLoginLogoPath(savedFile.path);
      }
    } else {
      // User canceled the picker
    }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PreferencesModel());
    _loadLogoPath();
    initColor();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void _toggleSwitch(bool value) {
    FFAppState().setGoogleML(value);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 46.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryText,
            size: 25.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Preferences',
          style: FlutterFlowTheme.of(context).headlineSmall.override(
                fontFamily: 'Outfit',
                letterSpacing: 0.0,
              ),
        ),
        actions: const [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: wrapWithModel(
                model: _model.darkLightChangerModel,
                updateCallback: () => setState(() {}),
                child: const DarkLightChangerWidget(),
              ),
            ),
          ),
          /*  Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
            child: SwitchListTile.adaptive(
              value: _model.switchListTileValue1 ??= true,
              onChanged: (newValue) async {
                setState(() => _model.switchListTileValue1 = newValue);
              },
              title: Text(
                'Facial recognition',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Readex Pro',
                      letterSpacing: 0.0,
                      lineHeight: 2.0,
                    ),
              ),
              tileColor: FlutterFlowTheme.of(context).secondaryBackground,
              activeColor: FlutterFlowTheme.of(context).primary,
              activeTrackColor: FlutterFlowTheme.of(context).accent1,
              dense: false,
              controlAffinity: ListTileControlAffinity.trailing,
              contentPadding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 5.0, 24.0, 5.0),
            ),
          ),*/
          SwitchListTile.adaptive(
            value: FFAppState().useGooleML,
            onChanged: _toggleSwitch,
            title: Text(
              'Use GoogleML Cropping',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0.0,
                    lineHeight: 2.0,
                  ),
            ),
            tileColor: FlutterFlowTheme.of(context).secondaryBackground,
            activeColor: FlutterFlowTheme.of(context).primary,
            activeTrackColor: FlutterFlowTheme.of(context).accent1,
            dense: false,
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding:
                const EdgeInsetsDirectional.fromSTEB(24.0, 5.0, 24.0, 5.0),
          ),
          ListTile(
              title: Text(
                'Change color theme',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Readex Pro',
                      letterSpacing: 0.0,
                      lineHeight: 2.0,
                    ),
              ),
              trailing: IconButton(
                onPressed: () {
                  showColorPickerDialog(context, currentColor, onColorSelected);
                },
                icon: Icon(
                  Icons.square_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              )),
          ListTile(
              title: Text(
                'Change login icon',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Readex Pro',
                      letterSpacing: 0.0,
                      lineHeight: 2.0,
                    ),
              ),
              trailing: IconButton(
                onPressed: () {
                  _pickAndSaveImage();
                },
                icon: Icon(
                  Icons.change_circle_rounded,
                  color: FlutterFlowTheme.of(context).primary,
                ),
              )),

          /* SwitchListTile.adaptive(
            value: _model.switchListTileValue2 ??= true,
            onChanged: (newValue) async {
              setState(() => _model.switchListTileValue2 = newValue);
            },
            title: Text(
              'Change color theme',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0.0,
                    lineHeight: 2.0,
                  ),
            ),
            tileColor: FlutterFlowTheme.of(context).secondaryBackground,
            activeColor: FlutterFlowTheme.of(context).primary,
            activeTrackColor: FlutterFlowTheme.of(context).accent1,
            dense: false,
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding:
                const EdgeInsetsDirectional.fromSTEB(24.0, 5.0, 24.0, 5.0),
          ),*/
          SwitchListTile.adaptive(
            value: _model.switchListTileValue3 ??= true,
            onChanged: (newValue) async {
              setState(() => _model.switchListTileValue3 = newValue);
            },
            title: Text(
              'Change logo Icon',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    letterSpacing: 0.0,
                    lineHeight: 2.0,
                  ),
            ),
            tileColor: FlutterFlowTheme.of(context).secondaryBackground,
            activeColor: FlutterFlowTheme.of(context).primary,
            activeTrackColor: FlutterFlowTheme.of(context).accent1,
            dense: false,
            controlAffinity: ListTileControlAffinity.trailing,
            contentPadding:
                const EdgeInsetsDirectional.fromSTEB(24.0, 5.0, 24.0, 5.0),
          ),
        ],
      ),
    );
  }
}
