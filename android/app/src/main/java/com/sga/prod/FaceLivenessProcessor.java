package com.sga.prod;

import com.dermalog.face.common.exception.DermalogFaceSdkException;
import com.dermalog.face.dataexchange.*;
import com.dermalog.face.liveness.Enums;
import com.dermalog.face.liveness.YawRotationLivenessDetector;
import com.dermalog.face.detection.FaceDetectionSDK;
import com.dermalog.face.liveness.FaceLivenessSDK;
import com.dermalog.face.detection.FaceDetector;
import com.sga.prod.FaceInfo;
import com.dermalog.face.detection.Pose;
import android.util.Log;



public class FaceLivenessProcessor {
    private FaceDetector detector = null;
    private YawRotationLivenessDetector livenessDetector = null;
    private double yawCenterThrAngle;
    private double yawMaxThrAngle;
    private double yawMinThrAngle;
    private double maxPitchThr = 15.0;
    private double maxRollThr = 15.0;
    private boolean isCenterImageSet = false;
    private boolean isMinImageSet = false;
    private boolean isMaxImageSet = false;
    private double livenessScore = 0;


    public FaceLivenessProcessor(String licenseKey, Object context) throws DermalogFaceSdkException{
        
        FaceDetectionSDK.setLicense(licenseKey, context);
        FaceLivenessSDK.setLicense(licenseKey, context);

        Log.d("CheckLiveness", "activated");
        // Step 1: Instantiate the face detector and liveness detector
        detector = new FaceDetector();
        livenessDetector = new YawRotationLivenessDetector();

        
        Log.d("CheckLiveness", "instantiated");
        // Load face landmark detection data for pose finder
        detector.loadLandmarkDetectionData();
        // Step 2: Store the thresholds needed
        yawCenterThrAngle = livenessDetector.getCenterYawThrAngle();
        yawMaxThrAngle = livenessDetector.getMaxYawThrAngle();
        yawMinThrAngle = livenessDetector.getMinYawThrAngle();


        Log.d("CheckLiveness", "threshhold stored");

        livenessDetector.reset();
    }

    
    double getLivenessScore() {
        return livenessScore;
    }

    private FaceInfo getFaceInfo(Image currentImage) {
        try {
            FacePositionArray facePositions = detector.findFacePositions(currentImage);
            FacePosition facePosition = facePositions.getSpecificFacePosition(0);
            PointArray facePoints = detector.findFacePoints(currentImage, facePosition);
            Pose pose  = detector.findFacePose(currentImage.getWidth(), currentImage.getHeight(), facePoints);
            facePositions.dispose();
            facePosition.dispose();
            Log.d("CheckLiveness", String.valueOf(pose.getYaw()) + String.valueOf(pose.getPitch())  );
            return new FaceInfo(pose.getYaw(), pose.getPitch(), pose.getRoll(), facePoints);
        } catch (DermalogFaceSdkException e) {
            System.out.println("Face SDK Error:" + e.getMessage());
        }
        return null; // Return null or handle this case appropriately
    }

    public void process(Image currentImage) {
        try {
            // Step 3: Find the face points on the largest detected face
            FaceInfo faceInfo = getFaceInfo(currentImage);
            if (faceInfo == null) {
                Log.d("CheckLiveness", "Failed to retrieve face information.");
                System.out.println("Failed to retrieve face information.");
                return;
            }

            Log.d("CheckLiveness", "img dim" + String.valueOf(currentImage.getHeight()) + String.valueOf(currentImage.getWidth())  );

            // Step 4: Set the corresponding images on the liveness detector
            if (Math.abs(faceInfo.pitch) < maxPitchThr && Math.abs(faceInfo.roll) < maxRollThr) {
                double currentYaw = faceInfo.yaw;
                Log.d("CheckLiveness", "current yaw" + String.valueOf(currentYaw) );
                if (Math.abs(currentYaw) < yawCenterThrAngle) {
                    // Set the center image (frontal pose)
                    yawCenterThrAngle = Math.abs(currentYaw);
                    livenessDetector.setImage(currentImage, faceInfo.facePoints, Enums.InputImageType.CENTER_YAW_FACE);
                    isCenterImageSet = true;
                    Log.d("CheckLiveness", "center detected" );
                }
                if (currentYaw < yawMinThrAngle) { 
                    // Set the min. yaw image (pose sideways to the left)
                    yawMinThrAngle = currentYaw;
                    livenessDetector.setImage(currentImage, faceInfo.facePoints, Enums.InputImageType.MIN_YAW_FACE);
                    isMinImageSet = true;
                    Log.d("CheckLiveness", "left detected" );
                }

                if (currentYaw > yawMaxThrAngle) {
                    // Set the max. yaw image (pose sideways to the right)
                    yawMaxThrAngle = currentYaw;
                    livenessDetector.setImage(currentImage, faceInfo.facePoints, Enums.InputImageType.MAX_YAW_FACE);
                    isMaxImageSet = true;
                    Log.d("CheckLiveness", "right detected" );
                }
            }

            // Step 5: Dispose of all created objects
            faceInfo.facePoints.dispose();
            Log.d("CheckLiveness", " facePoints disposed" );

            // Step 6: Get the liveness score if all required images have been set
            if (isCenterImageSet && isMinImageSet && isMaxImageSet) {
    
                livenessScore = livenessDetector.getLivenessScore();
                livenessDetector.reset();

                //reset all parameters
                this.isMaxImageSet = false;
                this.isCenterImageSet =  false;
                this.isMinImageSet = false;
                this.livenessScore = 0;
            }else{
                Log.d("CheckLiveness" , "not yet");
            }
        } catch (DermalogFaceSdkException e) {
            Log.d("CheckLiveness" , e.getMessage());
            System.out.println("Face SDK Error:" + e.getMessage());
        } catch (Exception e) {
            Log.d("CheckLiveness" , e.getMessage());
            System.out.println("Error message:" + e.getMessage());
        }
    }
}
