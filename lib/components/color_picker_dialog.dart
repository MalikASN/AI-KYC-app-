import 'package:facial_reco_p_o_c/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog(
      {required this.currentColor, required this.onColorSelected, Key? key})
      : super(key: key);

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.currentColor; // initialize with the current color
  }

  // Callback when color is changed
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      title: Text(
        'Pick a theme color',
        style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontFamily: 'Readex Pro',
              letterSpacing: 0.0,
              lineHeight: 2.0,
            ),
      ),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: changeColor,
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(FlutterFlowTheme.of(
                    context)
                .primary), // Fix: Wrap the color with MaterialStateProperty.all
          ),
          child: Text(
            'Confirm',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                ),
          ),
          onPressed: () {
            widget.onColorSelected(pickerColor);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

// Function to show the color picker dialog
Future<void> showColorPickerDialog(
    BuildContext context, Color currentColor, Function(Color) onColorSelected) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return ColorPickerDialog(
        currentColor: currentColor,
        onColorSelected: onColorSelected,
      );
    },
  );
}
