import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:facial_reco_p_o_c/backend/schema/util/NFCReaderBridge.dart';
import 'package:facial_reco_p_o_c/backend/schema/util/OCRCleaner.dart';
import 'package:facial_reco_p_o_c/components/nfcDialog.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:mrz_parser/mrz_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import '/components/field_item_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/others/add_field_bottom_sheet/add_field_bottom_sheet_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'm_r_z_scanner_model.dart';
export 'm_r_z_scanner_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class MRZScannerWidget extends StatefulWidget {
  const MRZScannerWidget({super.key});

  @override
  State<MRZScannerWidget> createState() => _MRZScannerWidgetState();
}

class _MRZScannerWidgetState extends State<MRZScannerWidget> {
  String _canShowOcr = "";
  bool _isConfirmed = false; // State variable to track confirmation
  late MRZScannerModel _model;
  String _docIdRecto = "";
  String _docIdVerso = "";
  final String _croped = "";
  Map<String, String> mrzMap = HashMap<String, String>();
  bool _isNFCAvail = false;
  Timer? _nfcCheckTimer; // Add a Timer variable

  Future<void> updateTextControllers(Map<String, dynamic> newMrzMap) async {
    final directory = await getApplicationDocumentsDirectory();

    if (FFAppState().nfcState == 2) {
      FFAppState().setNfcState(0);
    }

    // Define current values for comparison
    String currentFirstName = _model.textController1.text;
    String currentLastName = _model.textController2.text;
    String currentExpiryDate = _model.textController3.text;
    String currentDocNum = _model.textController4.text;

    // Check if there is a change before calling setState
    bool shouldUpdate = false;

    if (currentFirstName != newMrzMap["firstName"]?.toString()) {
      shouldUpdate = true;
    }
    if (currentLastName != newMrzMap["lastName"]?.toString()) {
      shouldUpdate = true;
    }
    if (currentExpiryDate !=
        convertDateRevert(newMrzMap["expiryDate"]!.toString())) {
      shouldUpdate = true;
    }
    if (currentDocNum != newMrzMap["docNum"]?.toString()) {
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      setState(() {
        _model.textController1.text = newMrzMap["firstName"]?.toString() ?? '';
        _model.textController2.text = newMrzMap["lastName"]?.toString() ?? '';
        _model.textController3.text =
            convertDateRevert(newMrzMap["expiryDate"]?.toString() ?? '');
        _model.textController4.text = newMrzMap["docNum"]?.toString() ?? '';
        if (newMrzMap["gender"] == "MALE") {
          _model.dropDownValueController?.value = "Homme";
        } else {
          _model.dropDownValueController?.value = "Femme";
        }
      });

      if (newMrzMap["identityImage"] != null) {
        // Decode the Base64 string into a Uint8List
        Uint8List imageBytes = base64Decode(
            newMrzMap["identityImage"].replaceAll(RegExp(r'\s+'), ''));

        // Use the image library to decode the image bytes into an image object
        img.Image? decodedImage = img.decodeImage(imageBytes);

        if (decodedImage != null) {
          // Get the directory path to save the image
          final path = '${directory.path}/detectedImage.jpeg';

          // Encode the image as a JPEG
          File imgFile = File(path);
          imgFile.writeAsBytesSync(img.encodeJpg(decodedImage));

          // Set the path in the FFAppState
          FFAppState().setExtractedPerson(path);
        } else {
          print("Failed to decode image.");
        }
      } else {
        print("Identity image not found.");
      }
    }
  }

  void startNFCCheckTimer() {
    // Periodically check NFC availability every 5 seconds
    _nfcCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkNFCAvailability();
    });
  }

  Future<bool> isNFCAvailable() async {
    var availability = await FlutterNfcKit.nfcAvailability;
    if (availability != NFCAvailability.available) {
      return false;
    }
    return true;
  }

  void checkNFCAvailability() async {
    final res = await isNFCAvailable();
    if (mounted) {
      setState(() {
        _isNFCAvail = res;
      });
    }
  }

  String convertDateToYYMMDD(String dateTimeStr) {
    // Parse the input string to DateTime
    DateTime dateTime = DateTime.parse(dateTimeStr);

    // Define the desired output format
    DateFormat formatter = DateFormat('yyMMdd');

    // Format the DateTime object to the desired string format
    String formattedDate = formatter.format(dateTime);
    return formattedDate; // Outputs: 310509
  }

  String convertDateRevert(String dateStr) {
    // Check if the input string is in the correct format
    if (dateStr.length != 6) {
      throw ArgumentError('Input date string must be in the format yyMMdd');
    }

    return "20${dateStr.substring(0, 2)}-${dateStr.substring(2, 4)}-${dateStr.substring(4, 6)}";
  }

  Future<void> requestPermissions() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  Map<String, String> mapForm = <String, String>{};

  void handleAdditionnalFormChange(String label, String textContent) {
    setState(() => mapForm[label] = textContent);
  }

  void showNfcDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents dialog from closing when tapping outside
      builder: (BuildContext context) {
        return const DialogFb2();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => MRZScannerModel());
    _model.textController1 ??= TextEditingController();
    // _model.textController1.text = mrzMap.entries.elementAt(2).value;
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    //  _model.textController2.text = mrzMap.entries.elementAt(3).value;
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    // _model.textController3.text = mrzMap.entries.elementAt(8).value;
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    // _model.textController4.text = mrzMap.entries.elementAt(4).value;
    _model.textFieldFocusNode4 ??= FocusNode();

    // Check NFC availability asynchronously after initState
    checkNFCAvailability();
    startNFCCheckTimer();
  }

  @override
  void dispose() {
    _model.maybeDispose();
    _model.cleanInputs();
    _nfcCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FFAppState>(builder: (context, ffAppState, child) {
      return Material(
        color: Colors.transparent,
        elevation: 5.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 900.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0),
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              //  Image.file(File(FFAppState().extractedPerson)),
              Consumer<FFAppState>(
                builder: (context, ffAppState, child) {
                  if (_isNFCAvail) {
                    final nfcMap = ffAppState.nfcMap;

                    if (nfcMap.isNotEmpty) {
                      // Execute your function when nfcMap is not empty
                      updateTextControllers(nfcMap);
                    }
                    // Return an empty container or a placeholder widget if you need to render something
                  }
                  return Container();
                },
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Document Capture',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                fontFamily: 'Outfit',
                                color: FlutterFlowTheme.of(context).primary,
                                letterSpacing: 0.0,
                              ),
                    ),
                    _isConfirmed
                        ? Container()
                        : FlutterFlowIconButton(
                            borderColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: 20.0,
                            borderWidth: 1.0,
                            buttonSize: 40.0,
                            fillColor: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            icon: Icon(
                              Icons.document_scanner_rounded,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              try {
                                // Perform the document scan
                                DocumentScannerOptions documentOptions =
                                    DocumentScannerOptions(
                                  documentFormat: DocumentFormat.jpeg,
                                  mode: ScannerMode.filter,
                                  pageLimit: 1,
                                  isGalleryImport: false,
                                );

                                final documentScanner =
                                    DocumentScanner(options: documentOptions);
                                List<String> pictures;

                                // First scan
                                DocumentScanningResult result =
                                    await documentScanner.scanDocument();
                                final pdf = result.pdf;
                                final images = result.images;
                                documentScanner.close();

                                setState(() {
                                  _docIdRecto = images.first;
                                });
                                FFAppState()
                                    .setdocumentImagePathRecto(images.first);

                                await Future.delayed(const Duration(
                                    seconds: 1)); // Fix MLKit bug

                                // Second scan
                                bool redo = true;
                                do {
                                  DocumentScanningResult result =
                                      await documentScanner.scanDocument();
                                  final pdf = result.pdf;
                                  final images = result.images;
                                  documentScanner.close();

                                  FFAppState()
                                      .setdocumentImagePathVerso(images.first);
                                  setState(() {
                                    _docIdVerso = images.first;
                                  });

                                  List<String> str;
                                  MRZResult mrzResult;
                                  final Directory fixedDir =
                                      await getApplicationDocumentsDirectory();
                                  await cropAndEnhanceMRZ(images.first);

                                  final textRecognizer = TextRecognizer(
                                      script: TextRecognitionScript.latin);
                                  final RecognizedText recognizedText =
                                      await textRecognizer.processImage(
                                    InputImage.fromFilePath(path.join(
                                        fixedDir.path, 'sharpened_mrz.jpg')),
                                  );

                                  str = await cleanOcr(recognizedText.text);
                                  setState(() => _canShowOcr = str.join("\n"));

                                  final mrz = str;
                                  try {
                                    mrzResult = MRZParser.parse(mrz);
                                    redo = false;

                                    if (!_isNFCAvail) {
                                      Map<String, dynamic> map =
                                          new HashMap<String, dynamic>();
                                      map["firstName"] =
                                          mrzResult.givenNames.toString();
                                      map["lastName"] = mrzResult.surnames;
                                      map["expiryDate"] = mrzResult.expiryDate
                                          .toIso8601String();
                                      map["docNum"] = mrzResult.documentNumber;
                                      if (mrzResult.sex.name == "male") {
                                        map["gender"] = "Homme";
                                      } else {
                                        map["gender"] = "Femme";
                                      }
                                      FFAppState().setNfcMap(map);

                                      setState(() {
                                        _model.textController1.text =
                                            mrzResult.givenNames;
                                        _model.textController2.text =
                                            mrzResult.surnames;
                                        _model.textController3.text = mrzResult
                                            .expiryDate
                                            .toIso8601String();
                                        if (mrzResult.sex.name == "male") {
                                          _model.dropDownValueController
                                              ?.value = "Homme";
                                        } else {
                                          _model.dropDownValueController
                                              ?.value = "Femme";
                                        }
                                        _model.textController4.text =
                                            mrzResult.documentNumber;
                                      });
                                    } else {
                                      Future.microtask(() {
                                        if (mounted) {
                                          showNfcDialog(context);
                                        }
                                      });

                                      NFCReaderBridge nfcrEaderBrige =
                                          NFCReaderBridge();
                                      await nfcrEaderBrige.readNFC(
                                          mrzResult.documentNumber,
                                          convertDateToYYMMDD(
                                              mrzResult.birthDate.toString()),
                                          convertDateToYYMMDD(
                                              mrzResult.expiryDate.toString()));
                                    }
                                  } on MRZException catch (e) {
                                    print(e);
                                  }

                                  await Future.delayed(const Duration(
                                      milliseconds: 500)); // Fix MLKit bug
                                } while (redo);
                              } catch (exception) {
                                print(exception.toString());
                              }
                            },
                          ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      20.0, 20.0, 20.0, 20.0),
                  child: SizedBox(
                    width: 400.0,
                    height: 400.0,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 40.0),
                          child: (_docIdRecto != "" && _docIdVerso != "")
                              ? PageView(
                                  controller: _model.pageViewController ??=
                                      PageController(initialPage: 0),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    /*   _croped.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.file(
                                              File(path.join(_croped)),
                                              width: 300.0,
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  1.0,
                                              fit: BoxFit.contain,
                                            ),
                                          )
                                        : Text(""),*/
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        File(_docIdRecto),
                                        width: 100.0,
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                1.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        File(_docIdVerso),
                                        width:
                                            MediaQuery.sizeOf(context).width *
                                                1.0,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(
                                  child: Text("Please capture documents first"),
                                ),
                        ),
                        Align(
                          alignment: const AlignmentDirectional(-1.0, 1.0),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 0.0, 16.0),
                            child: smooth_page_indicator.SmoothPageIndicator(
                              controller: _model.pageViewController ??=
                                  PageController(initialPage: 0),
                              count: 2,
                              axisDirection: Axis.horizontal,
                              onDotClicked: (i) async {
                                await _model.pageViewController!.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                                setState(() {});
                              },
                              effect: smooth_page_indicator.ExpandingDotsEffect(
                                expansionFactor: 3.0,
                                spacing: 8.0,
                                radius: 16.0,
                                dotWidth: 16.0,
                                dotHeight: 8.0,
                                dotColor: FlutterFlowTheme.of(context).accent1,
                                activeDotColor:
                                    FlutterFlowTheme.of(context).primary,
                                paintStyle: PaintingStyle.fill,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Text(_canShowOcr),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    20.0, 10.0, 20.0, 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 5.0, 8.0, 5.0),
                        child: TextFormField(
                          controller: _model.textController1,
                          focusNode: _model.textFieldFocusNode1,
                          autofocus: false,
                          obscureText: false,
                          enabled: !_isConfirmed,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'FirstName',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          maxLength: 20,
                          keyboardType: TextInputType.name,
                          validator: _model.textController1Validator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 5.0, 8.0, 5.0),
                        child: TextFormField(
                          controller: _model.textController2,
                          focusNode: _model.textFieldFocusNode2,
                          autofocus: false,
                          obscureText: false,
                          readOnly: true,
                          enabled: !_isConfirmed,
                          decoration: InputDecoration(
                            labelText: 'Lastname',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          maxLength: 20,
                          keyboardType: TextInputType.name,
                          validator: _model.textController2Validator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 5.0, 8.0, 5.0),
                        child: FlutterFlowDropDown<String>(
                          controller: _model.dropDownValueController ??=
                              FormFieldController<String>(null),
                          options: const ['Homme', 'Femme'],
                          onChanged: (val) =>
                              setState(() => _model.dropDownValue = val),
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: 56.0,
                          textStyle:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          hintText: 'Gender',
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 24.0,
                          ),
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          elevation: 2.0,
                          borderColor: FlutterFlowTheme.of(context).alternate,
                          borderWidth: 2.0,
                          borderRadius: 8.0,
                          margin: const EdgeInsetsDirectional.fromSTEB(
                              16.0, 4.0, 16.0, 4.0),
                          hidesUnderline: true,
                          isOverButton: true,
                          isSearchable: false,
                          isMultiSelect: false,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 5.0, 8.0, 5.0),
                        child: TextFormField(
                          controller: _model.textController3,
                          focusNode: _model.textFieldFocusNode3,
                          autofocus: false,
                          obscureText: false,
                          readOnly: true,
                          enabled: !_isConfirmed,
                          decoration: InputDecoration(
                            labelText: 'Expiry date',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          keyboardType: TextInputType.datetime,
                          validator: _model.textController3Validator
                              .asValidator(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            8.0, 5.0, 8.0, 5.0),
                        child: TextFormField(
                          controller: _model.textController4,
                          focusNode: _model.textFieldFocusNode4,
                          autofocus: false,
                          obscureText: false,
                          readOnly: true,
                          enabled: !_isConfirmed,
                          decoration: InputDecoration(
                            labelText: 'Doc num',
                            labelStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            hintStyle: FlutterFlowTheme.of(context)
                                .labelMedium
                                .override(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0.0,
                                ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).primary,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: FlutterFlowTheme.of(context).error,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Readex Pro',
                                    letterSpacing: 0.0,
                                  ),
                          keyboardType: TextInputType.number,
                          validator: _model.textController4Validator
                              .asValidator(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      30.0, 0.0, 15.0, 10.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: MediaQuery.viewInsetsOf(context),
                            child: const AddFieldBottomSheetWidget(),
                          );
                        },
                      ).then((value) => safeSetState(() {}));
                    },
                    text: 'Add field',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0.0,
                              ),
                      elevation: 3.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Builder(
                  builder: (context) {
                    final additionalField =
                        FFAppState().FieldsToAddList.toList();

                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(additionalField.length,
                          (additionalFieldIndex) {
                        final additionalFieldItem =
                            additionalField[additionalFieldIndex];
                        return wrapWithModel(
                          model: _model.fieldItemModels.getModel(
                            additionalFieldIndex.toString(),
                            additionalFieldIndex,
                          ),
                          updateCallback: () => setState(() {}),
                          child: FieldItemWidget(
                            handleAdditionnalFormChange:
                                handleAdditionnalFormChange,
                            key: Key(
                              'Keyy0d_${additionalFieldIndex.toString()}',
                            ),
                            field: additionalFieldItem,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 15.0, 10.0),
                child: FFButtonWidget(
                  onPressed: () {
                    if (_isConfirmed == true) {
                      setState(() {
                        _isConfirmed = false;
                      });
                    } else {
                      if (_model.textController1.text.isNotEmpty &&
                          _model.textController2.text.isNotEmpty &&
                          _model.textController3.text.isNotEmpty &&
                          _model.textController4.text.isNotEmpty &&
                          _model.dropDownValue != null) {
                        if ((FFAppState().FieldsToAddList.isNotEmpty &&
                                mrzMap.isNotEmpty) ||
                            FFAppState().FieldsToAddList.isEmpty) {
                          Map<String, String> map = {
                            "firstname": _model.textController1.text,
                            "lastname": _model.textController2.text,
                            "gender": "Homme",
                            "Expiry date": _model.textController3.text,
                            "Doc num": _model.textController4.text
                          };

                          for (int i = 0;
                              i < FFAppState().FieldsToAddList.toList().length;
                              i++) {
                            map[mapForm.entries.elementAt(i).key] =
                                mapForm.entries.elementAt(i).value;
                          }

                          FFAppState().setFromData(map);
                          setState(() {
                            _isConfirmed = true;
                          });
                        } else {
                          // Show error if any field is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill in all the fields')),
                          );
                        }
                      } else {
                        // Show error if any field is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill in all the fields')),
                        );
                      }
                    }
                  },
                  text: _isConfirmed ? 'Update' : 'Confirm',
                  options: FFButtonOptions(
                    width: 250,
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        24.0, 0.0, 24.0, 0.0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    color: _isConfirmed == false
                        ? FlutterFlowTheme.of(context).primary
                        : FlutterFlowTheme.of(context).alternate,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
