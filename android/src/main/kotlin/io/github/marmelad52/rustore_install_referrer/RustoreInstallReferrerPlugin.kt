package io.github.marmelad52.rustore_install_referrer

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import ru.rustore.sdk.install.referrer.InstallReferrerClient
import ru.rustore.sdk.install.referrer.model.FsaEvent
import ru.rustore.sdk.install.referrer.model.FsaEventType
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
            "getInstallReferrerV2" -> getInstallReferrerV2(result)
            "sendAuthEvent" -> sendAuthEvent(call, result)
            "sendFsaEvent" -> sendFsaEvent(call, result)
            "isReferrerServiceAvailable" -> isReferrerServiceAvailable(result)
            "getDebugInfo" -> getDebugInfo(result)
            else -> result.notImplemented()
        }
    }

    private fun getInstallReferrer(result: Result) {
        val referrerClient = client ?: return clientNotInitialized(result)

        referrerClient.getInstallReferrer()
            .addOnSuccessListener { referrer ->
                if (referrer != null) {
                    // Return real fields from InstallReferrer
                    val referrerData = mapOf<String, Any?>(
                        "packageName" to referrer.packageName,
                        "referrerId" to referrer.referrerId,
                        "receivedTimestamp" to referrer.receivedTimestamp,
                        "installAppTimestamp" to referrer.installAppTimestamp,
                        "versionCode" to referrer.versionCode,
                        "utmSource" to referrer.utmSource,
                        "utmMedium" to referrer.utmMedium,
                        "utmCampaign" to referrer.utmCampaign,
                        "utmGroup" to referrer.utmGroup,
                        "utmBanner" to referrer.utmBanner,
                        "utmContent" to referrer.utmContent,
                        "utmTerm" to referrer.utmTerm
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

    private fun getInstallReferrerV2(result: Result) {
        val referrerClient = client ?: return clientNotInitialized(result)

        referrerClient.getInstallReferrerV2()
            .addOnSuccessListener { referrer ->
                if (referrer != null) {
                    val referrerData = mapOf<String, Any?>(
                        "installReferrer" to referrer.installReferrer,
                        "referrerClickTimestampSeconds" to referrer.referrerClickTimestampSeconds,
                        "installBeginTimestampSeconds" to referrer.installBeginTimestampSeconds,
                        "referrerClickTimestampServerSeconds" to referrer.referrerClickTimestampServerSeconds,
                        "installBeginTimestampServerSeconds" to referrer.installBeginTimestampServerSeconds,
                        "googlePlayInstant" to referrer.googlePlayInstant,
                        "isFromRuStore" to referrer.isFromRuStore
                    )
                    result.success(referrerData)
                } else {
                    // Return null, let Dart handle it
                    result.success(null)
                }
            }
            .addOnFailureListener { throwable ->
                result.error(
                    throwable.javaClass.simpleName,
                    throwable.message,
                    null
                )
            }
    }

    /**
     * Legacy entry point. SDK 10.6.1 removed AuthEvent/sendAuthEvent in favour of
     * FsaEvent/sendFsaEvent, so the call is forwarded as an `install` FSA event.
     */
    private fun sendAuthEvent(call: MethodCall, result: Result) {
        dispatchFsaEvent(call, result, FsaEventType.Install)
    }

    private fun sendFsaEvent(call: MethodCall, result: Result) {
        val eventType = when (val eventTypeName = call.argument<String>("eventType") ?: "install") {
            "install" -> FsaEventType.Install
            "viewOffer", "addToCart", "purchase", "addToWishlist" -> {
                val productId = call.argument<String>("productId")
                if (productId.isNullOrEmpty()) {
                    result.error(
                        "MISSING_PRODUCT_ID",
                        "Product ID is required for event type '$eventTypeName'",
                        null
                    )
                    return
                }
                when (eventTypeName) {
                    "viewOffer" -> FsaEventType.ViewOffer(productId)
                    "addToCart" -> FsaEventType.AddToCart(productId)
                    "purchase" -> FsaEventType.Purchase(productId)
                    else -> FsaEventType.AddToWishlist(productId)
                }
            }
            else -> {
                result.error(
                    "INVALID_EVENT_TYPE",
                    "Unknown FSA event type: $eventTypeName",
                    null
                )
                return
            }
        }

        dispatchFsaEvent(call, result, eventType)
    }

    private fun dispatchFsaEvent(call: MethodCall, result: Result, eventType: FsaEventType) {
        val referrerClient = client ?: return clientNotInitialized(result)

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
            val fsaEvent = FsaEvent(phoneNumber, authToken, eventType)

            referrerClient.sendFsaEvent(fsaEvent)
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

    private fun isReferrerServiceAvailable(result: Result) {
        val referrerClient = client ?: return clientNotInitialized(result)

        try {
            result.success(referrerClient.isReferrerServiceAvailable())
        } catch (e: Exception) {
            result.error(e.javaClass.simpleName, e.message, null)
        }
    }

    private fun getDebugInfo(result: Result) {
        val referrerClient = client ?: return clientNotInitialized(result)

        try {
            result.success(referrerClient.getDebugInfo())
        } catch (e: Exception) {
            result.error(e.javaClass.simpleName, e.message, null)
        }
    }

    private fun clientNotInitialized(result: Result) {
        result.error(
            "CLIENT_NOT_INITIALIZED",
            "InstallReferrerClient not initialized",
            null
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        client = null
    }
}
