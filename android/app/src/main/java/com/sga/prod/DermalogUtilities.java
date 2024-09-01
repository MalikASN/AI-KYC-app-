package com.sga.prod;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import com.dermalog.face.common.exception.DermalogFaceSdkException;
import com.dermalog.face.dataexchange.FaceDataExchangeSDK;
import com.dermalog.face.dataexchange.FacePosition;
import com.dermalog.face.dataexchange.FacePositionArray;
import com.dermalog.face.dataexchange.Image;
import com.dermalog.face.dataexchange.PointArray;
import com.dermalog.face.detection.FaceDetectionSDK;
import com.dermalog.face.detection.FaceDetector;
import com.dermalog.face.recognition.FaceEncoder;
import com.dermalog.face.recognition.FaceMatcher;
import com.dermalog.face.recognition.FaceRecognitionSDK;
import com.dermalog.face.recognition.FaceTemplate;
import com.sga.prod.BuildConfig;
import java.io.File;
import android.content.Context;
import android.util.Log;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import android.os.Handler;
import android.os.Looper;


public class DermalogUtilities implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "SDKChannel");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext(); // Store the context
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (call.method.equals("CompareTwoFaces")) {
                FaceDetectionSDK.setLicense(BuildConfig.LICENSE, context);
                FaceRecognitionSDK.setLicense(BuildConfig.LICENSE, context);
                // Your existing code
                FaceMatcher matcher = new FaceMatcher();
                FaceDetector detector = new FaceDetector();
                FaceEncoder encoder = new FaceEncoder();

                String arg1 = call.argument("Image01");
                FacePositionArray faces1 = null;
                FacePositionArray faces2 = null;
                FacePosition position1 = null, position2 = null;
                FaceTemplate template1, template2;
                PointArray facePoints1 = null, facePoints2 = null;
                double matchingScore = 0.0;
                String arg2 = call.argument("Image02");

                try {
                    Image image1 = new Image();
                    Image image2 = new Image();
                    image1.loadImageFromFile(arg1);
                    image2.loadImageFromFile(arg2);
                    faces1 = detector.findFacePositions(image1);
                    position1 = faces1.getSpecificFacePosition(0);
                    facePoints1 = detector.findFacePoints(image1, position1);
                    faces2 = detector.findFacePositions(image2);
                    position2 = faces2.getSpecificFacePosition(0);
                    facePoints2 = detector.findFacePoints(image2, position2);
                    template1 = encoder.encodeFace(image1, facePoints1);
                    template2 = encoder.encodeFace(image2, facePoints2);
                    matchingScore = matcher.verifyTemplates(template1, template2);
                    image1.dispose();
                    image2.dispose();
                    facePoints1.dispose();
                    facePoints2.dispose();
                    template1.dispose();
                    template2.dispose();
                } finally {
                    if (faces2 != null)
                        faces2.dispose();
                    if (faces1 != null)
                        faces1.dispose();
                    if (position2 != null)
                        position2.dispose();
                    if (position1 != null)
                        position1.dispose();
                }

                result.success(matchingScore);
            } else if (call.method.equals("ExtractFace")) {
                // Your existing code
                FaceDetectionSDK.setLicense(BuildConfig.LICENSE, context);
                FaceRecognitionSDK.setLicense(BuildConfig.LICENSE, context);

                FaceDetector faceDetector = new FaceDetector();
                String arg1 = call.argument("ImageToExtract");

                Image image = new Image();
                image.loadImageFromFile(arg1);
                FacePositionArray facePositionArray = faceDetector.findFacePositions(image, 50);
                FacePosition facePosition = facePositionArray.getSpecificFacePosition(0);
                PointArray pointArray = faceDetector.findFacePoints(image, facePosition);

                Image portraitImage = new Image();
                PointArray pointArray2 = new PointArray();
                faceDetector.getPortraitImage(image, portraitImage, facePosition, pointArray2);

                // Use the stored context

                File file = new File(context.getFilesDir(), "detectedImage.jpg");
                if (file.exists()) {
                    if (file.delete()) {
                        portraitImage.saveImageToFile(file.getAbsolutePath());
                    }
                } else {
                    portraitImage.saveImageToFile(file.getAbsolutePath());
                }
                portraitImage.dispose();
                pointArray.dispose();
                facePosition.dispose();
                facePositionArray.dispose();
                image.dispose();

                result.success(file.getAbsolutePath());
            } else if (call.method.equals("CheckLiveness")) {

                String arg1 = call.argument("ImageToExtract");
                Image image = new Image();
                image.loadImageFromFile(arg1);

                // call face liveness checker
                FaceLivenessProcessor aFaceLivenessProcessor = new FaceLivenessProcessor(BuildConfig.LICENSE, context);
                aFaceLivenessProcessor.process(image);
                image.dispose();

                // 0 if not completed xx.xx if not
                result.success(aFaceLivenessProcessor.getLivenessScore());

            }
        
            else {
                result.notImplemented();
            }
        } catch (DermalogFaceSdkException e) {
            // Handle the exception, e.g., send an error result back to Flutter
            result.error("DERMALOG_SDK_ERROR", e.getMessage(), null);
        } catch (Exception e) {
            // Handle any other exceptions
            result.error("UNEXPECTED_ERROR", e.getMessage(), null);
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
