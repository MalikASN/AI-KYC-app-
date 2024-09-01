@file:Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")

package com.sga.prod
import com.sga.prod.ImageUtil.decodeImage
import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.AsyncTask
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.Toast
import android.app.PendingIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import com.sga.prod.DermalogUtilities
import com.sga.prod.SignDocUtilities
import android.util.Base64
import net.sf.scuba.smartcards.CardService
import com.google.firebase.crashlytics.buildtools.reloc.org.apache.commons.io.IOUtils
import org.bouncycastle.asn1.ASN1InputStream
import org.bouncycastle.asn1.ASN1Primitive
import org.bouncycastle.asn1.ASN1Sequence
import org.bouncycastle.asn1.ASN1Set
import org.bouncycastle.asn1.x509.Certificate
import org.jmrtd.BACKey
import org.jmrtd.BACKeySpec
import org.jmrtd.PassportService
import org.jmrtd.lds.CardAccessFile
import org.jmrtd.lds.ChipAuthenticationPublicKeyInfo
import org.jmrtd.lds.PACEInfo
import android.util.Log
import org.jmrtd.lds.SODFile
import org.jmrtd.lds.SecurityInfo
import org.jmrtd.lds.icao.DG14File
import org.jmrtd.lds.icao.DG1File
import org.jmrtd.lds.icao.DG2File
import org.jmrtd.lds.iso19794.FaceImageInfo
import java.io.ByteArrayInputStream
import java.io.DataInputStream
import java.io.InputStream
import java.security.KeyStore
import java.security.MessageDigest
import java.security.Signature
import java.security.cert.CertPathValidator
import java.security.cert.CertificateFactory
import java.security.cert.PKIXParameters
import java.security.cert.X509Certificate
import java.security.spec.MGF1ParameterSpec
import java.security.spec.PSSParameterSpec
import java.util.ArrayList
import java.util.Arrays
import java.io.ByteArrayOutputStream


class MainActivity : FlutterActivity() {
    private val CHANNEL = "nfc_reader"
    private lateinit var methodChannel: MethodChannel


    private var passportNumber: String? = null
    private var expirationDate: String? = null
    private var birthDate: String? = null


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "readNFC" -> {
                    Log.d("NFCReader", "passing arguments" +  call.argument("documentNumber") )
                    passportNumber = call.argument("documentNumber")
                    birthDate = call.argument("dateOfBirth")
                    expirationDate = call.argument("dateOfExpiry")
                    result.success("sucess")
                }
                else -> result.notImplemented()
            }
        }

        flutterEngine.plugins.add(DermalogUtilities()) // Register your plugin here
        flutterEngine.plugins.add(SignDocUtilities())
    }

    override fun onResume() {
        super.onResume()
        val adapter = NfcAdapter.getDefaultAdapter(this)
        if (adapter != null) {
            val intent = Intent(applicationContext, this.javaClass)
            intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_MUTABLE)
            val filter = arrayOf(arrayOf("android.nfc.tech.IsoDep"))
            adapter.enableForegroundDispatch(this, pendingIntent, null, filter)
        }

    }

    fun convertBitmapToBase64(bitmap: Bitmap): String {
        val byteArrayOutputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 85, byteArrayOutputStream)
        val byteArray = byteArrayOutputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.DEFAULT)
    }

    override fun onPause() {
        super.onPause()
        val adapter = NfcAdapter.getDefaultAdapter(this)
        adapter?.disableForegroundDispatch(this)
    }

    public override fun onNewIntent(intent: Intent) {
        Log.d("NFCReader", "new intent")
        super.onNewIntent(intent)

        if (NfcAdapter.ACTION_TECH_DISCOVERED == intent.action) {
            val tag: Tag? = intent.extras?.getParcelable(NfcAdapter.EXTRA_TAG)
            if (tag?.techList?.contains("android.nfc.tech.IsoDep") == true) {

                if (!passportNumber.isNullOrEmpty() && !expirationDate.isNullOrEmpty() && !birthDate.isNullOrEmpty()) {
                    val bacKey: BACKeySpec = BACKey(passportNumber, birthDate, expirationDate)
                    ReadTask(IsoDep.get(tag), bacKey).execute()

                } else {
                    println("No data!")
                    //Snackbar.make(passportNumberView, R.string.error_input, Snackbar.LENGTH_SHORT).show()
                }
            }
        }
    }
    

    fun bitmapToBase64(bitmap: Bitmap): String {
    val outputStream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
    val byteArray = outputStream.toByteArray()
    return Base64.encodeToString(byteArray, Base64.NO_WRAP)
}
    
    // Your existing ReadTask implementation
    @SuppressLint("StaticFieldLeak")
    private inner class ReadTask(private val isoDep: IsoDep, private val bacKey: BACKeySpec) : AsyncTask<Void?, Void?, Exception?>() {
             private val mainHandler = Handler(Looper.getMainLooper())
            private lateinit var dg1File: DG1File
            private lateinit var dg2File: DG2File
            private lateinit var dg14File: DG14File
            private lateinit var sodFile: SODFile
            private var imageBase64: String? = null
            private var bitmap: Bitmap? = null
            private var chipAuthSucceeded = false
            private var passiveAuthSuccess = false
            private lateinit var dg14Encoded: ByteArray

            @Deprecated("Deprecated in Java")
            override fun doInBackground(vararg params: Void?): Exception? {
                               mainHandler.post {
                methodChannel.invokeMethod("onMRZStart", "")
            }
                try {
           
                     
                    isoDep.timeout = 10000
                    val cardService = CardService.getInstance(isoDep)
                    cardService.open()
                    val service = PassportService(
                        cardService,
                        PassportService.NORMAL_MAX_TRANCEIVE_LENGTH,
                        PassportService.DEFAULT_MAX_BLOCKSIZE,
                        false,
                        false,
                    )
                    service.open()
                    var paceSucceeded = false
                    try {
                        val cardAccessFile = CardAccessFile(service.getInputStream(PassportService.EF_CARD_ACCESS))
                        val securityInfoCollection = cardAccessFile.securityInfos
                        for (securityInfo: SecurityInfo in securityInfoCollection) {
                            if (securityInfo is PACEInfo) {
                                service.doPACE(
                                    bacKey,
                                    securityInfo.objectIdentifier,
                                    PACEInfo.toParameterSpec(securityInfo.parameterId),
                                    null,
                                )
                                paceSucceeded = true
                            }
                        }
                    } catch (e: Exception) {
                          mainHandler.post {
                methodChannel.invokeMethod("onMRZError", "")
            }
                        //  Log.w(TAG, e)
                    }
                    service.sendSelectApplet(paceSucceeded)
                    if (!paceSucceeded) {
                        try {
                            service.getInputStream(PassportService.EF_COM).read()
                        } catch (e: Exception) {
                            service.doBAC(bacKey)
                        }
                    }
                    val dg1In = service.getInputStream(PassportService.EF_DG1)
                    dg1File = DG1File(dg1In)
                    val dg2In = service.getInputStream(PassportService.EF_DG2)
                    dg2File = DG2File(dg2In)
                    val sodIn = service.getInputStream(PassportService.EF_SOD)
                    sodFile = SODFile(sodIn)
                    Log.d("NFCReader", "before autgh")

                    doChipAuth(service)
                    Log.d("NFCReader", "after first auth")

                    doPassiveAuth()

                    Log.d("NFCReaderzz", "after second auth")


                    val allFaceImageInfo: MutableList<FaceImageInfo> = ArrayList()
                    dg2File.faceInfos.forEach {
                        allFaceImageInfo.addAll(it.faceImageInfos)
                    }
                    if (allFaceImageInfo.isNotEmpty()) {
                        val faceImageInfo = allFaceImageInfo.first()
                        val imageLength = faceImageInfo.imageLength
                        val dataInputStream = DataInputStream(faceImageInfo.imageInputStream)
                        val buffer = ByteArray(imageLength)
                        dataInputStream.readFully(buffer, 0, imageLength)
                        val inputStream: InputStream = ByteArrayInputStream(buffer, 0, imageLength)
                        
                        Log.d("imagfe type", faceImageInfo.mimeType)
                        if (faceImageInfo.mimeType.equals("image/jp2", ignoreCase = true)) {
                        try {
                            // Attempt to decode the image and convert it to Base64
                            val bitmap = decodeImage(this@MainActivity, faceImageInfo.mimeType, inputStream)
                            imageBase64 = convertBitmapToBase64(bitmap)
                        } catch (e: Exception) {
                            // If decoding fails, log the error and fallback to encoding the buffer directly
                            Log.e("ImageDecoding", "Failed to decode image: ${e.message}")
                            imageBase64 = Base64.encodeToString(buffer, Base64.DEFAULT)
                        }
                    } else {
                        // For other image types, directly encode the buffer to Base64
                        imageBase64 = Base64.encodeToString(buffer, Base64.DEFAULT)
                    }
                      
                       
                        
                    }
                } catch (e: Exception) {
                   mainHandler.post {
                methodChannel.invokeMethod("onMRZError", "")
            }
                    return e
                }
                return null
            }

            private fun doChipAuth(service: PassportService) {
            
                try {
                    val dg14In = service.getInputStream(PassportService.EF_DG14)
                    dg14Encoded = IOUtils.toByteArray(dg14In)
                    val dg14InByte = ByteArrayInputStream(dg14Encoded)
                    dg14File = DG14File(dg14InByte)
                    val dg14FileSecurityInfo = dg14File.securityInfos
                    for (securityInfo: SecurityInfo in dg14FileSecurityInfo) {
                        if (securityInfo is ChipAuthenticationPublicKeyInfo) {
                            service.doEACCA(
                                securityInfo.keyId,
                                ChipAuthenticationPublicKeyInfo.ID_CA_ECDH_AES_CBC_CMAC_256,
                                securityInfo.objectIdentifier,
                                securityInfo.subjectPublicKey,
                            )
                            chipAuthSucceeded = true
                        }
                    }
                } catch (e: Exception) {
                 mainHandler.post {
                methodChannel.invokeMethod("onMRZError", "")
            }
                }
            }

            private fun doPassiveAuth() {
                try {
                    val digest = MessageDigest.getInstance(sodFile.digestAlgorithm)
                    val dataHashes = sodFile.dataGroupHashes
                    val dg14Hash = if (chipAuthSucceeded) digest.digest(dg14Encoded) else ByteArray(0)
                    val dg1Hash = digest.digest(dg1File.encoded)
                    val dg2Hash = digest.digest(dg2File.encoded)

                    if (Arrays.equals(dg1Hash, dataHashes[1]) && Arrays.equals(dg2Hash, dataHashes[2])
                        && (!chipAuthSucceeded || Arrays.equals(dg14Hash, dataHashes[14]))) {

                        val asn1InputStream = ASN1InputStream(assets.open("masterList"))
                        val keystore = KeyStore.getInstance(KeyStore.getDefaultType())
                        keystore.load(null, null)
                        val cf = CertificateFactory.getInstance("X.509")

                        var p: ASN1Primitive?
                        while (asn1InputStream.readObject().also { p = it } != null) {
                            val asn1 = ASN1Sequence.getInstance(p)
                            if (asn1 == null || asn1.size() == 0) {
                                throw IllegalArgumentException("Null or empty sequence passed.")
                            }
                            if (asn1.size() != 2) {
                                throw IllegalArgumentException("Incorrect sequence size: " + asn1.size())
                            }
                            val certSet = ASN1Set.getInstance(asn1.getObjectAt(1))
                            for (i in 0 until certSet.size()) {
                                val certificate = Certificate.getInstance(certSet.getObjectAt(i))
                                val pemCertificate = certificate.encoded
                                val javaCertificate = cf.generateCertificate(ByteArrayInputStream(pemCertificate))
                                keystore.setCertificateEntry(i.toString(), javaCertificate)
                            }
                        }

                        val docSigningCertificates = sodFile.docSigningCertificates
                        for (docSigningCertificate: X509Certificate in docSigningCertificates) {
                            docSigningCertificate.checkValidity()
                        }

                        val cp = cf.generateCertPath(docSigningCertificates)
                        val pkixParameters = PKIXParameters(keystore)
                        pkixParameters.isRevocationEnabled = false
                        val cpv = CertPathValidator.getInstance(CertPathValidator.getDefaultType())
                        cpv.validate(cp, pkixParameters)
                        var sodDigestEncryptionAlgorithm = sodFile.docSigningCertificate.sigAlgName
                        var isSSA = false
                        if ((sodDigestEncryptionAlgorithm == "SSAwithRSA/PSS")) {
                            sodDigestEncryptionAlgorithm = "SHA256withRSA/PSS"
                            isSSA = true
                        }
                        val sign = Signature.getInstance(sodDigestEncryptionAlgorithm)
                        if (isSSA) {
                            sign.setParameter(PSSParameterSpec("SHA-256", "MGF1", MGF1ParameterSpec.SHA256, 32, 1))
                        }
                        sign.initVerify(sodFile.docSigningCertificate)
                        sign.update(sodFile.eContent)
                        passiveAuthSuccess = sign.verify(sodFile.encryptedDigest)
                    }
                } catch (e: Exception) {
                    mainHandler.post {
                methodChannel.invokeMethod("onMRZError", "")
            }
                    // Log.w(TAG, e)
                }
            }



            override fun onPostExecute(result: Exception?) {

                if (result == null) {
                    val mrzInfo = dg1File.mrzInfo
                    val mrzData = mapOf(
                        "firstName" to mrzInfo.secondaryIdentifier.replace("<", " "),
                        "lastName" to mrzInfo.primaryIdentifier.replace("<", " "),
                        "gender" to mrzInfo.gender.toString(),
                        "state" to mrzInfo.issuingState,
                        "nationality" to mrzInfo.nationality,
                        "identityImage" to imageBase64,
                        "expiryDate" to mrzInfo.dateOfExpiry,
                        "docNum" to mrzInfo.documentNumber
                    )

                    Log.d("images is" , imageBase64!!)

                     // clear fields
                       passportNumber = null
                       expirationDate  = null
                       birthDate = null

                     // Notify Flutter with the result
                    methodChannel.invokeMethod("onMRZData", mrzData)
                } else {
                    //Snackbar.make(passportNumberView, result.toString(), Snackbar.LENGTH_LONG).show()
                }
            }
        }


    }

