import 'dart:io';
import 'dart:ui';

import 'package:cross_file/src/types/interface.dart';
import 'package:facial_reco_p_o_c/form_components/take_self/classifier.dart';
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
    "openedEyes": false
  };
  int faceProgression = 0;
  double livenessScore = 0.0;
  ImageLivenessPredictor imageLiveness = ImageLivenessPredictor();
  DermalogBridge dermalogBridge = DermalogBridge();

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
      imageResolution: ImageResolution.high,
      enableAudio: false,
      autoCapture: false,
      defaultCameraLens: CameraLens.front,
      performanceMode: FaceDetectorMode.accurate,
      onFaceDetected: (face) async {
        if (face != null) {
          final cross_file.XFile? imageFile =
              await controller.takePicture() as cross_file.XFile?;

          if (imageFile != null) {
            final FaceDetectorOptions options = FaceDetectorOptions(
              performanceMode: FaceDetectorMode.accurate,
              enableTracking: false,
              enableClassification: true,
            );

            final FaceDetector faceDetector = FaceDetector(options: options);
            final inputImage = InputImage.fromFilePath(imageFile.path);
            final List<Face> faces =
                await faceDetector.processImage(inputImage);

            if (faces.isNotEmpty) {
              final Face detectedFace = faces.first;

              // Assuming you are working with a Rect bounding box
              final Rect boundingBox = detectedFace.boundingBox;

              // Load the image using the image package to get its size
              final img.Image originalImage =
                  img.decodeImage(File(imageFile.path).readAsBytesSync())!;
              final Size imageSize = Size(originalImage.width.toDouble(),
                  originalImage.height.toDouble());

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

              // Save or use the cropped image as needed
              final File uncroppedImageFile =
                  File('${imageFile.path}_uncropped.jpg')
                    ..writeAsBytesSync(img.encodeJpg(croppedImage));
              //check for left / right /straight

              final double? yaw = face.headEulerAngleY;
              final double? pitch = detectedFace.headEulerAngleX;
              final double? Roll = detectedFace.headEulerAngleZ;
              if (pitch != null && Roll != null) {
                if (pitch <= 10 && Roll <= 10 && pitch >= -10 && Roll >= -10) {
                  if (yaw != null) {
                    if (yaw < -60) {
                      if (faceProgression == 0) {
                        setState(() {
                          map["leftRotation"] = true;
                          faceProgression++;
                        });

                        setState(() {
                          leftPath = uncroppedImageFile.path;
                        });

                        /*  imageLiveness
                            .predictImageLiveness(uncroppedImageFile.path);*/
                        //call liveness SDK
                        //  dermalogBridge.checkLiveness(uncroppedImageFile.path);

                        Vibration.vibrate(duration: 300);
                      }
                    } else if (yaw > 60) {
                      if (faceProgression == 1) {
                        setState(() {
                          map["rightRotation"] = true;
                          faceProgression++;
                        });

                        //call liveness SDK
                        setState(() {
                          rightPath = uncroppedImageFile.path;
                        });
                        /* imageLiveness
                            .predictImageLiveness(uncroppedImageFile.path);*/
                        //   dermalogBridge.checkLiveness(uncroppedImageFile.path);
                        Vibration.vibrate(duration: 300);
                      }
                    } else if (yaw <= 10 && yaw >= -10) {
                      if (faceProgression == 2) {
                        setState(() {
                          map["straight"] = true;
                          faceProgression++;
                        });
                        setState(() {
                          frontPath = uncroppedImageFile.path;
                        });

                        /*  imageLiveness
                            .predictImageLiveness(uncroppedImageFile.path);*/
                        //call liveness SDK
                        /*   double score = await dermalogBridge
                            .checkLiveness(uncroppedImageFile.path);
                        setState(() {
                          livenessScore = score;
                        });
*/
                        Vibration.vibrate(duration: 300);
                      }
                    }
                  }
                  if (faceProgression == 3) {
                    if (detectedFace.leftEyeOpenProbability != null &&
                        detectedFace.rightEyeOpenProbability != null &&
                        detectedFace.leftEyeOpenProbability! > 0.7 &&
                        detectedFace.rightEyeOpenProbability! > 0.7) {
                      print("Both eyes are open, capturing the image...");
                      setState(() {
                        map["openedEyes"] = true;
                        faceProgression++;
                      });
                    } else {
                      print(
                          "Eyes are not sufficiently open. Discarding the image.");
                    }
                  }

                  // Rest of your face detection and validation logic
                  // ...
                  //   } /* else {
                  Vibration.vibrate(duration: 100, repeat: 2);
                  // Reset parameters for another try
                  setState(() {
                    livenessScore = 0;
                    map = {};
                    faceProgression = 0;
                  });
                }

                // take picture if all conditions are met
                if (!map.containsValue(false) &&
                    map.length == 4 &&
                    faceProgression == 4) {
                  setState(() => _capturedImage = File(imageFile.path));
                  DermalogBridge dermalogBridge = DermalogBridge();
                  _performAsyncOperations(dermalogBridge, imageFile.path);

                  setState(() {
                    map = {};
                    faceProgression = 0;
                  });

                  controller.stopImageStream();
                  controller.dispose();
                  faceDetector.close();
                }
              }
            }
          }
        }
      },
      onCapture: (File? image) {},
    );
  }

  void _performAsyncOperations(
      DermalogBridge dermalogBridge, String path) async {
    await dermalogBridge.extractSelfieFaceML(path);
  }

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
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Text(
                        'Veuillez prendre un selfie',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
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
                          // Restart the camera stream if you want to take another selfie
                          controller = FaceCameraController(
                            imageResolution: ImageResolution.high,
                            enableAudio: false,
                            autoCapture: false,
                            defaultCameraLens: CameraLens.front,
                            performanceMode: FaceDetectorMode.accurate,
                            onFaceDetected: (face) async {
                              if (face != null) {
                                final cross_file.XFile? imageFile =
                                    await controller.takePicture()
                                        as cross_file.XFile?;

                                if (imageFile != null) {
                                  final FaceDetectorOptions options =
                                      FaceDetectorOptions(
                                    performanceMode: FaceDetectorMode.accurate,
                                    enableTracking: false,
                                    enableClassification: true,
                                  );

                                  final FaceDetector faceDetector =
                                      FaceDetector(options: options);
                                  final inputImage =
                                      InputImage.fromFilePath(imageFile.path);
                                  final List<Face> faces = await faceDetector
                                      .processImage(inputImage);

                                  if (faces.isNotEmpty) {
                                    final Face detectedFace = faces.first;

                                    // Assuming you are working with a Rect bounding box
                                    final Rect boundingBox =
                                        detectedFace.boundingBox;

                                    // Load the image using the image package to get its size
                                    final img.Image originalImage =
                                        img.decodeImage(File(imageFile.path)
                                            .readAsBytesSync())!;
                                    final Size imageSize = Size(
                                        originalImage.width.toDouble(),
                                        originalImage.height.toDouble());

                                    // Expand the bounding box by 65%
                                    final Rect expandedBoundingBox = expandRect(
                                        boundingBox, 0.99, imageSize);

                                    // Crop the expanded area from the image
                                    final img.Image croppedImage = img.copyCrop(
                                      originalImage,
                                      x: expandedBoundingBox.left.toInt(),
                                      y: expandedBoundingBox.top.toInt(),
                                      width: expandedBoundingBox.width.toInt(),
                                      height:
                                          expandedBoundingBox.height.toInt(),
                                    );

                                    // Save or use the cropped image as needed
                                    final File uncroppedImageFile =
                                        File('${imageFile.path}_uncropped.jpg')
                                          ..writeAsBytesSync(
                                              img.encodeJpg(croppedImage));
                                    //check for left / right /straight

                                    final double? yaw = face.headEulerAngleY;
                                    final double? pitch =
                                        detectedFace.headEulerAngleX;
                                    final double? Roll =
                                        detectedFace.headEulerAngleZ;
                                    if (pitch != null && Roll != null) {
                                      if (pitch <= 10 &&
                                          Roll <= 10 &&
                                          pitch >= -10 &&
                                          Roll >= -10) {
                                        if (yaw != null) {
                                          if (yaw < -60) {
                                            if (faceProgression == 0) {
                                              setState(() {
                                                map["leftRotation"] = true;
                                                faceProgression++;
                                              });

                                              setState(() {
                                                leftPath =
                                                    uncroppedImageFile.path;
                                              });

                                              /*  imageLiveness
                            .predictImageLiveness(uncroppedImageFile.path);*/
                                              //call liveness SDK
                                              //  dermalogBridge.checkLiveness(uncroppedImageFile.path);

                                              Vibration.vibrate(duration: 300);
                                            }
                                          } else if (yaw > 60) {
                                            if (faceProgression == 1) {
                                              setState(() {
                                                map["rightRotation"] = true;
                                                faceProgression++;
                                              });

                                              //call liveness SDK
                                              setState(() {
                                                rightPath =
                                                    uncroppedImageFile.path;
                                              });
                                              /* imageLiveness
                            .predictImageLiveness(uncroppedImageFile.path);*/
                                              //   dermalogBridge.checkLiveness(uncroppedImageFile.path);
                                              Vibration.vibrate(duration: 300);
                                            }
                                          } else if (yaw <= 10 && yaw >= -10) {
                                            if (faceProgression == 2) {
                                              setState(() {
                                                map["straight"] = true;
                                                faceProgression++;
                                              });
                                              setState(() {
                                                frontPath =
                                                    uncroppedImageFile.path;
                                              });

                                              /*  imageLiveness
                            .predictImageLiveness(uncroppedImageFile.path);*/
                                              //call liveness SDK
                                              /*   double score = await dermalogBridge
                            .checkLiveness(uncroppedImageFile.path);
                        setState(() {
                          livenessScore = score;
                        });
*/
                                              Vibration.vibrate(duration: 300);
                                            }
                                          }
                                        }
                                        if (faceProgression == 3) {
                                          if (detectedFace.leftEyeOpenProbability != null &&
                                              detectedFace
                                                      .rightEyeOpenProbability !=
                                                  null &&
                                              detectedFace
                                                      .leftEyeOpenProbability! >
                                                  0.7 &&
                                              detectedFace
                                                      .rightEyeOpenProbability! >
                                                  0.7) {
                                            print(
                                                "Both eyes are open, capturing the image...");
                                            setState(() {
                                              map["openedEyes"] = true;
                                              faceProgression++;
                                            });
                                          } else {
                                            print(
                                                "Eyes are not sufficiently open. Discarding the image.");
                                          }
                                        }

                                        // Rest of your face detection and validation logic
                                        // ...
                                        //   } /* else {
                                        Vibration.vibrate(
                                            duration: 100, repeat: 2);
                                        // Reset parameters for another try
                                        setState(() {
                                          livenessScore = 0;
                                          map = {};
                                          faceProgression = 0;
                                        });
                                      }

                                      // take picture if all conditions are met
                                      if (!map.containsValue(false) &&
                                          map.length == 4 &&
                                          faceProgression == 4) {
                                        setState(() => _capturedImage =
                                            File(imageFile.path));
                                        DermalogBridge dermalogBridge =
                                            DermalogBridge();
                                        _performAsyncOperations(
                                            dermalogBridge, imageFile.path);

                                        setState(() {
                                          map = {};
                                          faceProgression = 0;
                                        });

                                        controller.stopImageStream();
                                        controller.dispose();
                                        faceDetector.close();
                                      }
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
