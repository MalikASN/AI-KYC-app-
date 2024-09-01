package com.sga.prod;

/*===============================================================*
 * Copyright Kofax Deutschland GmbH,                             *
 * Wilhelmstrasse 34, D-71034 Boeblingen                         *
 * All rights reserved.                                          *
 *                                                               *
 * This software is the confidential and proprietary information *
 * of Kofax Deutschland GmbH ("Confidential Information"). You   *
 * shall not disclose such Confidential Information and shall    *
 * use it only in accordance with the terms of the license       *
 * agreement you entered into with Kofax Deutschland GmbH.       *
 *==============================================================*/

/* This sample program demonstrates how to use SignRSA such that no
   SignDocDocument object exists for the PDF document while computing
   the signature (multi-phase signing).

   This sample reads the certificate and private key from sample.p12
   (see cert-and-key target of *.mak).

   This sample does not support signing TIFF documents.

   See also SignDocSample6.java. */

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.security.KeyStore;
import java.security.Signature;
import java.security.cert.X509Certificate;
import java.security.interfaces.RSAPrivateKey;
import de.softpro.doc.SignDocDocument;
import de.softpro.doc.SignDocDocumentLoader;
import de.softpro.doc.SignDocException;
import de.softpro.doc.SignDocField;
import de.softpro.doc.SignDocFieldNotFoundException;
import de.softpro.doc.SignDocInvalidArgumentException;
import de.softpro.doc.SignDocParameters;
import de.softpro.doc.SignDocSignatureParameters;
import de.softpro.doc.SignDocUnexpectedErrorException;
import de.softpro.doc.SignRSA;
import de.softpro.doc.Source;
import java.util.Date;
import java.util.List;
import android.util.Log;
import android.util.Base64; 
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;


/**
 * @brief Sample implementation of the SignRSA interface.
 *
 * Used in phase one only.
 */

public class SignDocSampleMain
{
    static private String mLicenseKey =
            "h:SPLM2 4.10\n" +
                    "i:ID:9923390\n" +
                    "i:Product:SignDocSDK\n" +
                    "i:Manufacturer:Kofax Deutschland AG\n" +
                    "i:Customer:Trial License - !!! NOT FOR PRODUCTION USAGE !!!\n" +
                    "i:Version:5.0\n" +
                    "i:OS:all\n" +
                    "a:product:unlimited\n" +
                    "a:signware:unlimited\n" +
                    "a:sign:2024-12-31\n" +
                    "a:capture:unlimited\n" +
                    "a:render:unlimited\n" +
                    "s:0ea47f22713260bd2dea741eda05433c058e2273890f202fdc200c66c550d357\n" +
                    "s:2acdf651245e410bb88271b7ec6f3c872d504421e4c005131ccecdc904e58d4c\n" +
                    "s:67011c47c5aa698f880ed406df778bd2f8fb4fd5d9f4a011048beb6f4c6201b0\n" +
                    "s:b31efeb72fcdf219046e0ba58708679d1d03d78f882e4c3fd086481ad1883749\n";


    /**
     * @brief Show how to run this program.
     *
     * The process will be terminated.
     */
    static private void usage ()
    {
        System.err.println ("Usage: java SignDocSample15 DOCUMENT [BIOMETRIC_DATA BIOMETRIC_KEY]");
        System.exit (1);
    }

    static private byte[] readFile (String path) throws java.io.IOException
    {
        java.io.File f = new java.io.File (path);
        java.io.FileInputStream fis = new java.io.FileInputStream (f);
        int n = (int)f.length ();
        byte[] a = new byte[n];
        if (fis.read (a) != n)
            throw new RuntimeException ("Short read");
        return a;
    }

    /**
     * @brief Add a signature field to the document.
     *
     * The signature field will be centered on the specified page.
     *
     * @param[in] aDoc        The document.
     * @param[in] aPageNo     The 1-based page number.
     * @param[in] aFieldName  The name of the signature field.
     */
    static private void addSignatureField (SignDocDocument aDoc, int aPageNo,
                                           String aFieldName) throws SignDocException
    {
        /* Get the dimensions of the specified page. */
        double width = aDoc.getPageWidth (aPageNo);
        double height = aDoc.getPageHeight (aPageNo);

        /* Add a signature field. */
        SignDocField field = new SignDocField ();
        field.setName (aFieldName);
        field.setType (SignDocField.t_signature_digsig);
        field.setPage (aPageNo);
        field.setLeft (width / 4);
        field.setBottom (height / 8);
        field.setRight (field.getLeft () + width / 2);
        field.setTop (field.getBottom () + height / 4);
        aDoc.addField (field, 0);
    }

    /**
     * @brief Create a SignDocSignatureParameters object.
     *
     * @param[in] aDoc          The document.
     * @param[in] aFieldName    The name of the signature field.
     * @param[in] aProfile      The name of the profile.
     * @param[in] aBioPath      The pathname of the file containing the biometric
     *                          signature, can be null.
     * @param[in] aBioKeyPath   The pathname of the private key for the biometric
     *                          data, can be null unless aBioPath is non-null.
     *
     * @return The SignDocSignatureParameters object.
     */
    static private SignDocSignatureParameters createParams (SignDocDocument aDoc,
                                                            String aFieldName,
                                                            String aBioPath,
                                                            String aBioKeyPath
                                                          )
    {
        SignDocSignatureParameters params = aDoc.createSignatureParameters (aFieldName , "");
        params.setString ("Filter", "Adobe.PPKLite");

        if (aBioPath != null)
        {
            /* Load biometric data from the file. */
            byte[] bio = null;
            try
            {
                bio = readFile (aBioPath);
            }
            catch (IOException e)
            {
                e.printStackTrace (System.err);
                System.exit (2);
            }
            try
            {
                params.setBlob ("BiometricData", bio);
            }
            finally
            {
                clear (bio);
            }
            params.setInteger ("RenderSignature", SignDocSignatureParameters.rsf_gray);
            params.setInteger ("BiometricEncryption", SignDocSignatureParameters.be_rsa);
            params.setString ("BiometricKeyPath", aBioKeyPath);
        }
        return params;
    }

    /**
     * @brief Overwrite a byte array.
     *
     * @param[in] aData  The byte array to be overwritten.
     */
    static void clear (byte[] aData)
    {
        for (int i = 0; i < aData.length; ++i)
            aData[i] = 0;
    }

    /**
     * @brief Sign the document using provided parameters.
     *
     * @param[in] doc_path       The path to the document to be signed.
     * @param[in] p12_file       The path to the P12 file.
     * @param[in] p12_password   The password for the P12 file.
     * @param[in] pageno         The page number for the signature field.
     * @param[in] field_name     The name of the signature field.
     * @param[in] profile        The profile name for the signature.
     * @param[in] bio_path       The path to the biometric data file, can be null.
     * @param[in] bio_key_path   The path to the biometric key file, can be null.
     */
    static public void signDoc(String doc_path, String p12_file, String p12_password,
                               int pageno, String field_name, String Signer, byte[] signature
                            )
    {
        try
        {
            /* Set the license key. */
            SignDocDocumentLoader loader = new SignDocDocumentLoader ();
            loader.setLicenseKey (mLicenseKey.getBytes ("UTF-8"), null, null, null);

            /* Load the specified document. */
            SignDocDocument doc = loader.loadFromFile (doc_path, true);

            /* Add a signature field. */
            addSignatureField (doc, pageno, field_name);

            // Assuming signatureBytes contains the image data
           ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(signature);
           Bitmap signatureBitmap = BitmapFactory.decodeStream(byteArrayInputStream);
           ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
           signatureBitmap.compress(Bitmap.CompressFormat.PNG, 100, byteArrayOutputStream);
           byte[] signatureBytes = byteArrayOutputStream.toByteArray();
           signatureBitmap.recycle();

            /* Phase one. */

            /* Create phase one signature parameters. */
            Sample15RSA rsa = new Sample15RSA (p12_file, p12_password);
            SignDocSignatureParameters params = createParams (doc, field_name, null, null);
            params.setColor("SignatureColor", de.softpro.doc.SignDocColor.createRGB(0, 0, 255));
            params.setRSA (rsa);
            params.setBoolean ("MultiPhase", true);
            params.setBlob("Image", signatureBytes);
            params.setString("CommonName", "CaptureDoc");
            String signTime = new Date().toString();
            params.setString("SignTime", signTime);
            params.setString("Signer", Signer);
            params.setInteger("BiometricEncryption", SignDocSignatureParameters.be_rsa);
            params.setBlob("BiometricKey", Base64.decode("MIIBCQKCAQC5XgjxaeVpcUIUR+uBnQVkRtlrysNXRPdPPZVhSvidpjGNS9gaiFCgMPYHdiEpYbzwa2mJJ1BU81phlTcObuUE0fWZ/SApGWv1/V+js5qXmnAz5C6/ZNJn0NqROHtG2gmCeqm0Z4ipLvm2wiW+J33MVIW6kKQnNRhOuJXZEGqRfqJp8P7l3UR7j67dFhIj0NGeKlul5OPp3fHWS2s7XL1zD+V71B5Jf/XwweG02WAgDmJ5lAGW/7cKiYOX89BX7z16/rpu4uIezHXMLueXJHr22XlEkhMejHtiemTFE4y7/Ed7GVQjC6MFF1j+zdVjfkK9UAeMozxWORauaO98I+LfAgMBAAE=", 0));
            /* Phase one of signing the document. In this phase, the
              document is prepared for signing and SignRSA.sign() is
              called to trigger computation of the signature. The
              document is modified only in memory. */
            doc.addSignature (params, null);

           /* Create a blob from the document and destroy the
              SignDocDocument object. All flags are ignored during
              multi-phase signing. You should not overwrite the
              original document! You can use string parameter
              "OutputPath" to let addSignature() write to a file. */
            byte[] doc_blob = doc.saveToMemory (0);
            doc.close ();
            doc = null;

           /* Serialize the signature parameters, including secret
              values. Then, destroy the SignDocSignatureParameters
              object. */
            byte[] params_blob = params.saveToMemory (SignDocParameters.sf_secret);
            params.destroy ();
            params = null;

           /* Get the data recorded by our SignRSA implementation in
              phase one. */
            Signature sig = rsa.getSignature();
            rsa = null;

            /* End of phase one. */

           /* Now, we don't have any state except for sig, cert,
              doc_blob, and params_blob (and the command line
              parameters). */

           /* Compute the signature. In real-world code, this would be
              done in another process or on another machine. */
            byte[] sig_bytes = sig.sign ();

            /* Phase two. */

            /* Load the prepared document from the blob. */
            doc = loader.loadFromMemory (doc_blob);

           /* Create phase two signature parameters. The parameters must
              be exactly identical to those used for phase one, except
              for "MultiPhaseData", and "OutputPath". setRSA() isn't
              needed. */
            params = SignDocSignatureParameters.createFromMemory (params_blob, 0);
            params.setBlob ("MultiPhaseData", sig_bytes);

           /* Add the signature to the prepared document. We arrange for
              the signed document to be written to the file it was loaded
              from for phase one. If you want to obtain a blob, don't set
              "OutputPath" and use copyToMemory() after
              addSignature(). */
            params.setString ("OutputPath", "/data/user/0/com.sga.prod/app_flutter/signedContract_" + Signer + ".pdf");
            doc.addSignature (params, null);

            System.out.println ("Document signed.");

            /* SignDocDocument objects should be explicitely closed. */
            doc.close ();
            params.destroy ();
        }
        catch (Throwable e)
        {
            e.printStackTrace (System.err);
            System.exit (2);
        }
    }
}
