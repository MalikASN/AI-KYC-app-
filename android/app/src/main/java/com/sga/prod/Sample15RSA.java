package com.sga.prod;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.Exception;
import java.lang.System;
import java.security.KeyStore;
import java.security.Signature;
import java.security.cert.X509Certificate;
import java.security.interfaces.RSAPublicKey;
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
import java.security.Provider;
import java.security.Security;
import android.util.Log;

/**
 * @brief Sample implementation of the SignRSA interface.
 *
 * Used in phase one only.
 */
class Sample15RSA implements SignRSA
{
    /**
     * @brief Constructor.
     *
     * @param[in] aPath       Pathname of PKCS #12 file.
     * @param[in] aPassword   Password for PKCS #12 file.
     *
     * This method sets mKey, mCert, and mInitError.
     */
    Sample15RSA (String aPath, String aPassword)
    {
        try


        {
     
            /* Load certificate and private key from PKCS #12 file. */
            KeyStore ks = KeyStore.getInstance ("PKCS12","BC");
            FileInputStream fis = new FileInputStream (aPath);
            char[] pwd = aPassword.toCharArray ();
            ks.load (fis, pwd);
            fis.close ();
            if (ks.size () != 1)
                mInitError = "expected exactly one entry in PKCS #12 file, got " + ks.size ();
            else
            {
                String alias = ks.aliases().nextElement ();
                mCert = (X509Certificate)ks.getCertificate (alias);
                mKey = (RSAPrivateKey)ks.getKey (alias, pwd);
            }
        }
        catch (Throwable t)
        {
            mInitError = t.getMessage ();
            if (mInitError == null)
                mInitError = t.getClass().getName ();
        }
    }

    /**
     * @brief Compute an RSA signature.
     *
     * @param[in] aSource         An object providing data to be hashed
     *                            and signed.
     * @param[in] aSignatureScheme  The RSA signature scheme:
     *                              - "PKCS1": PKCS #1 1.5.
     *                              - "PSS": RSASSA-PSS (RSA 2.0), see also
     *                                @a aHashAlgorithm and @a aSaltLength
     *                              .
     * @param[in] aHashAlgorithm  The Hash algorithm to be used for the
     *                            signature and (for RSASSA-PSS) for mask
     *                            generation:
     *                            - "SHA-1"
     *                            - "SHA-256"
     *                            - "SHA-384"
     *                            - "SHA-512"
     *                            - "SHA3-256"
     *                            - "SHA3-384"
     *                            - "SHA3-512"
     *                            - "RIPEMD-160"
     *                            .
     * @param[in] aSaltLength   The salt length (in octets) for RSASSA-PSS,
     *                          to be ignored for the PKCS #1 signature scheme.
     *
     * @return With multi-phase signing, the return value is either an arbitrary
     *         array or null.
     */
    public byte[] sign (Source aSource, String aSignatureScheme,
                        String aHashAlgorithm, int aSaltLength)
    {
        if (mInitError != null)
        {
            mError = mInitError;
            return null;
        }

        String algo;
        if (aSignatureScheme.equals ("PKCS1") && aHashAlgorithm.equals ("SHA-1"))
            algo = "SHA1withRSA";
        else if (aSignatureScheme.equals ("PKCS1") && aHashAlgorithm.equals ("SHA-256"))
            algo = "SHA256withRSA";
        else if (aSignatureScheme.equals ("PSS"))
        {
            mError = "RSASSA-PSS not implemented";
            return null;
        }
        else
        {
            mError = "invalid argument";
            return null;
        }
        try
        {
            mSignature = Signature.getInstance (algo);
            mSignature.initSign (mKey);
            for (;;)
            {
                byte[] data = aSource.fetch (4096);
                if (data == null || data.length == 0)
                    break;
                mSignature.update (data);
            }
            /* Any non-null return value indicates success in phase one. */
            return new byte[0];
        }
        catch (Throwable e)
        {
            mError = e.getMessage ();
            if (mError == null)
                mError = e.getClass().getName ();
            return null;
        }
    }

    /**
     * @brief Get the size of the signature that will be computed
     *        by sign().
     *
     * No longer called.
     */
    public int getSignatureSize ()
    {
        return -1;
    }

    /**
     * @brief Get the signing certificate.
     *
     * @return The signing certificate (DER-encoded X.509) or null on error.
     */
    public byte[] getSigningCertificate ()
    {
        if (mInitError != null)
        {
            mError = mInitError;
            return null;
        }
        try
        {
            return mCert.getEncoded ();
        }
        catch (Throwable e)
        {
            mError = e.getMessage ();
            if (mError == null)
                mError = e.getClass().getName ();
            return null;
        }
    }

    /**
     * @brief Get the number of available intermediate certificates.
     *
     * This implementation of SignRSA does not provide intermediate
     * certificates.
     *
     * @return The number of available intermediate certificates.
     */
    public int getCertificateCount ()
    {
        return 0;
    }

    /**
     * @brief Get an intermediate certificate.
     *
     * This implementation of SignRSA does not provide intermediate
     * certificates.
     *
     * @param[in] aIndex      The zero-based index of the intermediate
     *                        certificate, see getCertificateCount().
     *
     * @return The requested intermediate certificate (DER-encoded X.509)
     *         or null on error.
     */
    public byte[] getCertificate (int aIndex)
    {
        mError = "index out of range";
        return null;
    }

    /**
     * @brief Get an error message for the last operation.
     *
     * After any method of this class has been called, you can retrieve
     * an error message by calling this method.
     *
     * @return An error message (empty if the last operation succeeded).
     */
    public String getErrorMessage ()
    {
        return mError;
    }

    /**
     * @brief Get the Signature object.
     *
     * @return The Signature object.
     */
    public Signature getSignature ()
    {
        return mSignature;
    }

    /**
     * @brief The error message that will be returned by getErrorMessage().
     */
    private String mError = "";

    /**
     * @brief The error message for errors detected by the constructor.
     *
     * null if the constructor succeeded.
     */
    private String mInitError;

    /**
     * @brief The certificate loaded by the constructor.
     */
    private X509Certificate mCert;

    /**
     * @brief The private key loaded by the constructor.
     */
    private RSAPrivateKey mKey;

    /**
     * @brief The Signature object initialized by sign() in phase one.
     */
    private Signature mSignature;
}