// FaceInfo.java
package com.sga.prod;

import com.dermalog.face.dataexchange.PointArray;

public class FaceInfo {
    public double yaw;
    public double pitch;
    public double roll;
    public PointArray facePoints;

    public FaceInfo(double yaw, double pitch, double roll, PointArray facePoints) {
        this.yaw = yaw;
        this.pitch = pitch;
        this.roll = roll;
        this.facePoints = facePoints;
    }
}
