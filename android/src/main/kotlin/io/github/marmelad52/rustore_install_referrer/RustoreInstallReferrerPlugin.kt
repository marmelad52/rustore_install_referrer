package io.github.marmelad52.rustore_install_referrer

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ru.rustore.sdk.install.referrer.model.InstallReferrer
import ru.rustore.sdk.install.referrer.InstallReferrerClient
import ru.rustore.sdk.install.referrer.model.AuthEvent
import ru.rustore.sdk.install.referrer.model.PhoneNumber

class RustoreInstallReferrerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var client: InstallReferrerClient? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "rustore_install_referrer")
        channel.setMethodCallHandler(this)
        
        // Создаем клиент один раз при инициализации
        client = InstallReferrerClient(context)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getInstallReferrer" -> getInstallReferrer(result)
            "sendAuthEvent" -> sendAuthEvent(call, result)
            else -> result.notImplemented()
        }
    }

    private fun getInstallReferrer(result: Result) {
        val referrerClient = client ?: run {
            result.error(
                "CLIENT_NOT_INITIALIZED",
                "InstallReferrerClient not initialized",
                null
            )
            return
        }

        referrerClient.getInstallReferrer()
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

    private fun sendAuthEvent(call: MethodCall, result: Result) {
        val referrerClient = client ?: run {
            result.error(
                "CLIENT_NOT_INITIALIZED",
                "InstallReferrerClient not initialized",
                null
            )
            return
        }

        // Получаем параметры из Dart
        val phoneNumberStr = call.argument<String>("phoneNumber")
        val authToken = call.argument<String>("authToken")

        if (phoneNumberStr == null) {
            result.error(
                "MISSING_PHONE_NUMBER",
                "Phone number is required",
                null
            )
            return
        }

        if (authToken == null) {
            result.error(
                "MISSING_AUTH_TOKEN",
                "Auth token is required",
                null
            )
            return
        }

        try {
            val phoneNumber = PhoneNumber(phoneNumberStr)
            val authEvent = AuthEvent(phoneNumber, authToken)

            referrerClient.sendAuthEvent(authEvent)
                .addOnSuccessListener {
                    result.success(true)
                }
                .addOnFailureListener { throwable ->
                    result.error(
                        throwable.javaClass.simpleName,
                        throwable.message,
                        null
                    )
                }
        } catch (e: Exception) {
            result.error(
                "INVALID_PHONE_NUMBER",
                "Failed to create PhoneNumber: ${e.message}",
                null
            )
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        client = null
    }
}