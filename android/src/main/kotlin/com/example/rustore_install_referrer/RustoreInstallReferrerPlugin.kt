package com.example.rustore_install_referrer

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ru.rustore.sdk.install.referrer.model.InstallReferrer
import ru.rustore.sdk.install.referrer.InstallReferrerClient

class RustoreInstallReferrerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rustore_install_referrer")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getInstallReferrer") {
            getInstallReferrer(result)
        } else {
            result.notImplemented()
        }
    }

    private fun getInstallReferrer(result: Result) {
        val client = InstallReferrerClient(context)

        client.getInstallReferrer()
            .addOnSuccessListener { referrer ->
                if (referrer != null) {
                    // Return real fields from InstallReferrer
                    val referrerData = mapOf<String, Any?>(
                        "packageName" to referrer.packageName,
                        "referrerId" to referrer.referrerId,
                        "receivedTimestamp" to referrer.receivedTimestamp,
                        "installAppTimestamp" to referrer.installAppTimestamp,
                        "versionCode" to referrer.versionCode
                    )
                    result.success(referrerData)
                } else {
                    // Return null, let Dart handle it
                    result.success(null)
                }
            }
            .addOnFailureListener { throwable ->
                // Pass exception class name and message, let Dart handle it
                result.error(
                    throwable.javaClass.simpleName,
                    throwable.message,
                    null
                )
            }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}