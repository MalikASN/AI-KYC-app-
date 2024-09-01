package com.sga.prod;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import androidx.annotation.NonNull;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.List;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import java.security.Security;
import java.security.Provider;


public class SignDocUtilities implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "sign_doc_channel");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext(); // Store the context

       
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        try {
            if (call.method.equals("sign_doc")) {
                // Retrieve arguments from Flutter
                String docPath = call.argument("doc_path");
                int pageNo = call.argument("pageno");
                String Signer = call.argument("Signer");
                List<Integer> signatureList = call.argument("sigImg");

                Log.d("SignatureList",  String.valueOf(signatureList.size()));
                Log.d("listr2",docPath );
  
                // Copy the PK12 file from assets to internal storage
                String p12FilePath = copyAssetToInternalStorage("certificate.p12");
                

                //convert the signature to list of bytes
                byte[] signatureBytes = new byte[signatureList.size()];
                        
                for (int i = 0; i < signatureList.size(); i++) {
                    signatureBytes[i] = (byte) (int) signatureList.get(i);
                }


                Provider existingBC = Security.getProvider("BC");
                if (existingBC != null) {
                    Security.removeProvider("BC");
                    Log.d("SecurityProviders", "Removed existing BC provider: " + existingBC.getInfo());
                }
    
                // Insert your Bouncy Castle provider
                int position = Security.insertProviderAt(new BouncyCastleProvider(), 1);
                Log.d("SecurityProviders", "Bouncy Castle inserted at position: " + position);
    
                // Log the available security providers
                Provider[] providers = Security.getProviders();
                for (Provider provider : providers) {
                    Log.d("SecurityProviders", "Provider: " + provider.getName() + ", Version: " + provider.getVersion());
                }

                try {
                    System.load("/data/app/~~LHUEb94Nt8d1jJoJwdpnAg==/lib/libSPFreeImage_1.so");
                    Log.e("NativeLibrary", "loaded succes");
                } catch (UnsatisfiedLinkError e) {
                    Log.e("NativeLibrary", "Failed to load library from path: " + e.getMessage());
                }
                

                // Call the signDoc method
                SignDocSampleMain.signDoc(docPath, p12FilePath, "Malik2002", pageNo, "Signature Field", Signer, signatureBytes );

                // Return success to Flutter
                result.success("Document signed successfully.");
            } else {
                result.notImplemented();
            }
        } catch (Exception e) {
            result.error("ERROR", e.getMessage(), null);
        }
    }

    private String copyAssetToInternalStorage(String fileName) {
        File file = new File(context.getFilesDir(), fileName);
        try (InputStream inputStream = context.getAssets().open(fileName);
             OutputStream outputStream = new FileOutputStream(file)) {

            byte[] buffer = new byte[1024];
            int length;
            while ((length = inputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, length);
            }
            return file.getAbsolutePath();
        } catch (Exception e) {
            Log.e("SignDocUtilities", "Failed to copy asset file: " + fileName, e);
            return null;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
