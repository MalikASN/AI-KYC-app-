import 'dart:io';
import 'dart:ui';

import 'package:cross_file/src/types/interface.dart';
import 'package:vibration/vibration.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'take_self_model.dart';
export 'take_self_model.dart';
import 'package:face_camera/face_camera.dart';
import '../../backend/schema/util/DermalogBridge.dart';
import 'package:image/image.dart' as img; // Add this import
import 'package:cross_file/cross_file.dart' as cross_file;

class TakeSelfWidget extends StatefulWidget {
  const TakeSelfWidget({super.key});

  @override
  State<TakeSelfWidget> createState() => _TakeSelfWidgetState();
}

class _TakeSelfWidgetState extends State<TakeSelfWidget> {
  int? _lastFaceProcessedTime;
  int _throttleDuration = 1000; // 1000ms = 1 second
  String frontPath = "";
  String rightPath = "";
  String leftPath = "";
  late TakeSelfModel _model;
  File? _capturedImage;
  late FaceCameraController controller;
  Map<String, bool> map = {
    "leftRotation": false,
    "rightRotation": false,
    "straight": false,
  };
  int faceProgression = 0;
  double livenessScore = 0.0;
 // DermalogBridge dermalogBridge = DermalogBridge();

  // Function to expand the bounding box by a factor
  Rect expandRect(Rect rect, double factor, Size imageSize) {
    final double widthIncrease = rect.width * factor;
    final double heightIncrease = rect.height * factor;

    final double left = (rect.left - widthIncrease).clamp(0.0, imageSize.width);
    final double top = (rect.top - heightIncrease).clamp(0.0, imageSize.height);
    final double right =
        (rect.right + widthIncrease).clamp(0.0, imageSize.width);
    final double bottom =
        (rect.bottom + heightIncrease).clamp(0.0, imageSize.height);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  void initState() {
    super.initState();
    //imageLiveness.loadModel();
    _model = createModel(context, () => TakeSelfModel());
    controller = FaceCameraController(
      imageResolution: ImageResolution.medium,
      enableAudio: false,
      autoCapture: false,
      defaultCameraLens: CameraLens.front,
      performanceMode: FaceDetectorMode.accurate,
      onFaceDetected: (face) async {
        if (face != null) {
          final int currentTime = DateTime.now().millisecondsSinceEpoch;

          // Throttle processing to only once per _throttleDuration
          if (_lastFaceProcessedTime == null ||
              currentTime - _lastFaceProcessedTime! >= _throttleDuration) {
            _lastFaceProcessedTime = currentTime;

            // Handle head pose: yaw, pitch, roll
            final double yaw = face.headEulerAngleY ?? 0.0;
            final double pitch = face.headEulerAngleX ?? 0.0;
            final double roll = face.headEulerAngleZ ?? 0.0;

            if (pitch <= 10 && roll <= 10 && pitch >= -10 && roll >= -10) {
              if (yaw < -60 && faceProgression == 0) {
                final cross_file.XFile? imageFile =
                    await controller.takePicture();
                //call liveness SDK
              //  dermalogBridge.checkLiveness(imageFile!.path.toString());
                setState(() {
                  map["leftRotation"] = true;
                  faceProgression++;
                  leftPath = imageFile!.path.toString();
                });

                Vibration.vibrate(duration: 300);
              } else if (yaw > 60 && faceProgression == 1) {
                final cross_file.XFile? imageFile =
                    await controller.takePicture();
              //  dermalogBridge.checkLiveness(imageFile!.path.toString());
                setState(() {
                  map["rightRotation"] = true;
                  faceProgression++;
                  rightPath = imageFile!.path.toString();
                });

                Vibration.vibrate(duration: 300);
              } else if (yaw <= 5 && yaw >= -5 && faceProgression == 2) {
                final cross_file.XFile? imageFile =
                    await controller.takePicture();
                //call liveness SDK
              //  double score = await dermalogBridge
                 //   .checkLiveness(imageFile!.path.toString());
                Vibration.vibrate(duration: 300);
                setState(() {
                  map["straight"] = true;
                  faceProgression++;
                  frontPath = imageFile!.path.toString();
                });
              }
            }

            // Take picture only after all conditions are met
            if (!map.containsValue(false) &&
                map.length == 3 &&
                faceProgression == 3) {
              final cross_file.XFile? imageFile =
                  await controller.takePicture() as cross_file.XFile?;

              if (imageFile != null) {
                // Load the image using the image package to get its size
                final img.Image originalImage =
                    img.decodeImage(File(imageFile.path).readAsBytesSync())!;
                final Size imageSize = Size(
                  originalImage.width.toDouble(),
                  originalImage.height.toDouble(),
                );

                // Assuming you already have a bounding box for the detected face
                final Rect boundingBox = face.boundingBox;

                // Expand the bounding box by 65%
                final Rect expandedBoundingBox =
                    expandRect(boundingBox, 0.99, imageSize);

                // Crop the expanded area from the image
                final img.Image croppedImage = img.copyCrop(
                  originalImage,
                  x: expandedBoundingBox.left.toInt(),
                  y: expandedBoundingBox.top.toInt(),
                  width: expandedBoundingBox.width.toInt(),
                  height: expandedBoundingBox.height.toInt(),
                );

                setState(() => _capturedImage = File(imageFile.path));

                // Call external service or perform other operations
               // DermalogBridge dermalogBridge = DermalogBridge();
              //  _performAsyncOperations(dermalogBridge, imageFile.path);

                // Reset state after processing
                setState(() {
                  map = {};
                  faceProgression = 0;
                });

                controller.stopImageStream();
                controller.dispose();
              }
            }
          }
        }
      },
      onCapture: (File? image) {},
    );
  }

  /*void _performAsyncOperations(
      DermalogBridge dermalogBridge, String path) async {
    await dermalogBridge.extractSelfieFaceML(path);
  }*/

  @override
  void dispose() {
    // Dispose of the camera controller properly
    controller.dispose();
    _model.maybeDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: 388.0,
        height: _capturedImage == null ? screenHeight * 0.75 : 350,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4.0,
              color: Color(0x34090F13),
              offset: Offset(
                0.0,
                2.0,
              ),
            )
          ],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _capturedImage != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 20.0, 0.0, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.file(
                          _capturedImage!,
                          width: 200.0,
                          height: 189.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 25.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          
                          setState(() {
                            _capturedImage = null;
                          });
                          // Restart the camera stream if you want to take another selfie
                          controller = FaceCameraController(
                            imageResolution: ImageResolution.medium,
                            enableAudio: false,
                            autoCapture: false,
                            defaultCameraLens: CameraLens.front,
                            performanceMode: FaceDetectorMode.accurate,
                            onFaceDetected: (face) async {
                              if (face != null) {
                                final int currentTime =
                                    DateTime.now().millisecondsSinceEpoch;

                                // Throttle processing to only once per _throttleDuration
                                if (_lastFaceProcessedTime == null ||
                                    currentTime - _lastFaceProcessedTime! >=
                                        _throttleDuration) {
                                  _lastFaceProcessedTime = currentTime;

                                  // Handle head pose: yaw, pitch, roll
                                  final double yaw =
                                      face.headEulerAngleY ?? 0.0;
                                  final double pitch =
                                      face.headEulerAngleX ?? 0.0;
                                  final double roll =
                                      face.headEulerAngleZ ?? 0.0;

                                  if (pitch <= 10 &&
                                      roll <= 10 &&
                                      pitch >= -10 &&
                                      roll >= -10) {
                                    if (yaw < -60 && faceProgression == 0) {
                                      setState(() {
                                        map["leftRotation"] = true;
                                        faceProgression++;
                                      });
                                      Vibration.vibrate(duration: 300);
                                    } else if (yaw > 60 &&
                                        faceProgression == 1) {
                                      setState(() {
                                        map["rightRotation"] = true;
                                        faceProgression++;
                                      });
                                      Vibration.vibrate(duration: 300);
                                    } else if (yaw <= 5 &&
                                        yaw >= -5 &&
                                        faceProgression == 2) {
                                      setState(() {
                                        map["straight"] = true;
                                        faceProgression++;
                                      });
                                      Vibration.vibrate(duration: 300);
                                    }
                                  }
                                  /* print(face.leftEyeOpenProbability!.toString() + "didyy");
            if (faceProgression == 3 &&
                face.leftEyeOpenProbability != null &&
                face.rightEyeOpenProbability != null &&
                face.leftEyeOpenProbability! > 0.7 &&
                face.rightEyeOpenProbability! > 0.7) {
              print("Both eyes are open, ready to capture the image...");
              setState(() {
                map["openedEyes"] = true;
                faceProgression++;
              });
            }*/

                                  // Take picture only after all conditions are met
                                  if (!map.containsValue(false) &&
                                      map.length == 3 &&
                                      faceProgression == 3) {
                                    final cross_file.XFile? imageFile =
                                        await controller.takePicture()
                                            as cross_file.XFile?;

                                    if (imageFile != null) {
                                      // Load the image using the image package to get its size
                                      final img.Image originalImage =
                                          img.decodeImage(File(imageFile.path)
                                              .readAsBytesSync())!;
                                      final Size imageSize = Size(
                                        originalImage.width.toDouble(),
                                        originalImage.height.toDouble(),
                                      );

                                      // Assuming you already have a bounding box for the detected face
                                      final Rect boundingBox = face.boundingBox;

                                      // Expand the bounding box by 65%
                                      final Rect expandedBoundingBox =
                                          expandRect(
                                              boundingBox, 0.99, imageSize);

                                      // Crop the expanded area from the image
                                      final img.Image croppedImage =
                                          img.copyCrop(
                                        originalImage,
                                        x: expandedBoundingBox.left.toInt(),
                                        y: expandedBoundingBox.top.toInt(),
                                        width:
                                            expandedBoundingBox.width.toInt(),
                                        height:
                                            expandedBoundingBox.height.toInt(),
                                      );

                                      setState(() => _capturedImage =
                                          File(imageFile.path));

                                      // Call external service or perform other operations
                                    /*  DermalogBridge dermalogBridge =
                                          DermalogBridge();*/
                                     /* _performAsyncOperations(
                                          dermalogBridge, imageFile.path);*/

                                      // Reset state after processing
                                      setState(() {
                                        // Set all values to false
                                        map.forEach((key, value) {
                                          map[key] = false;
                                        });
                                        faceProgression = 0;
                                      });

                                      controller.stopImageStream();
                                      controller.dispose();
                                    }
                                  }
                                }
                              }
                            },
                            onCapture: (File? image) {},
                          );
                          //  setState(() => _capturedImage = null);
                        },
                        text: 'Reprendre un selfie',
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
                  ],
                ),
              )
            : Column(
                children: [
                  Text(faceProgression.toString()),
                  Image.file(
                    File(frontPath),
                    width: 50,
                    height: 50,
                  ),
                  Image.file(
                    File(rightPath),
                    width: 50,
                    height: 50,
                  ),
                  Image.file(
                    File(leftPath),
                    width: 50,
                    height: 50,
                  ),
                  SmartFaceCamera(
                    showCaptureControl: false,
                    showCameraLensControl: false,
                    showFlashControl: false,
                    controller: controller,
                    messageBuilder: (context, face) {
                      if (faceProgression == 0) {
                        return _message('Tournez votre tête à droite.');
                      }
                      if (faceProgression == 1) {
                        return _message('Tournez votre tête à gauche.');
                      }
                      if (faceProgression == 2) {
                        return _message('Regardez tout droit');
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

Widget _message(String msg) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
    child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color.fromARGB(240, 173, 22, 22),
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w400)),
          Icon(
            msg == 'Tournez votre tête à droite.'
                ? Icons.arrow_circle_right_outlined
                : msg == 'Tournez votre tête à gauche.'
                    ? Icons.arrow_circle_left_outlined
                    : null,
            color: Color.fromARGB(240, 173, 22, 22),
          )
        ]));
