import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rustore_install_referrer/rustore_fsa_event_type.dart';
import 'package:rustore_install_referrer/rustore_install_referrer_exception.dart';
import 'package:rustore_install_referrer/rustore_referrer_details.dart';
import 'package:rustore_install_referrer/rustore_referrer_details_v2.dart';

export 'package:rustore_install_referrer/rustore_fsa_event_type.dart';
export 'package:rustore_install_referrer/rustore_referrer_details.dart';
export 'package:rustore_install_referrer/rustore_referrer_details_v2.dart';

/// Main class for working with RuStore Install Referrer API.
///
/// This class provides methods to get referrer information
/// that is passed during app installation through RuStore advertising links.
///
/// Example usage:
/// ```dart
/// try {
///   final details = await RuStoreInstallReferrer.getInstallReferrerV2();
///   print('Referrer: ${details.installReferrer}');
///   print('Install time: ${details.installBeginTime}');
/// } catch (e) {
///   if (e is RuStoreInstallReferrerException) {
///     print('Error: ${e.code} - ${e.message}');
///   }
/// }
/// ```
class RuStoreInstallReferrer {
  static const MethodChannel _channel = MethodChannel(
    'rustore_install_referrer',
  );

  /// Gets installation details from RuStore.
  ///
  /// Returns [RuStoreReferrerDetails] on success.
  ///
  /// Throws [RuStoreInstallReferrerException] on error:
  /// - `REFERRER_NOT_FOUND`: Referrer not found (app installed without
  ///   referrer, referrer expired, or already consumed by an earlier request
  ///   when the installed RuStore deletes it after the first read).
  /// - `RU_STORE_NOT_INSTALLED`: RuStore not installed on device.
  /// - `RU_STORE_OUTDATED`: RuStore version is outdated.
  /// - `RU_STORE_ERROR`: General RuStore SDK error.
  /// - `CLIENT_NOT_CREATED`: Install Referrer client could not be created.
  /// - `UNKNOWN_ERROR`: Unknown error.
  ///
  /// See also [getInstallReferrerV2], which is the method recommended by the
  /// RuStore documentation.
  static Future<RuStoreReferrerDetails> getInstallReferrer() async {
    final result = await _invokeMap('getInstallReferrer');
    return RuStoreReferrerDetails.fromMap(result);
  }

  /// Gets installation details from RuStore using `getInstallReferrerV2()`.
  ///
  /// Returns [RuStoreReferrerDetailsV2] on success. Unlike [getInstallReferrer]
  /// it exposes click and install timestamps in seconds (device and server
  /// clocks) and the [RuStoreReferrerDetailsV2.isFromRuStore] flag.
  ///
  /// According to the RuStore documentation the referrer is stored for 90
  /// days after the click and is not deleted after the first read, so it can
  /// be requested repeatedly and independently by the app and an MMP SDK.
  ///
  /// Throws [RuStoreInstallReferrerException] on error, with the same codes as
  /// [getInstallReferrer].
  static Future<RuStoreReferrerDetailsV2> getInstallReferrerV2() async {
    final result = await _invokeMap('getInstallReferrerV2');
    return RuStoreReferrerDetailsV2.fromMap(result);
  }

  /// Checks whether the RuStore referrer service is available on the device.
  ///
  /// Can be called before [getInstallReferrer] / [getInstallReferrerV2].
  static Future<bool> isReferrerServiceAvailable() async {
    final result = await _invoke<bool>('isReferrerServiceAvailable');
    return result == true;
  }

  /// Returns a diagnostic string for debugging and support requests.
  static Future<String> getDebugInfo() async {
    final result = await _invoke<String>('getDebugInfo');
    return result ?? '';
  }

  /// Sends an event to VK Ads Full Stream Attribution.
  ///
  /// This method allows sending user phone number to VK Ads system for
  /// attribution purposes. Requires auth token from VK Ads manager.
  ///
  /// [phoneNumber] - User's phone number (digits only, e.g., "1234567890").
  /// [authToken] - Authorization token from VK Ads manager.
  /// [eventType] - Type of the event, [RuStoreFsaEventType.install] by default.
  /// [productId] - Product ID, required for every event type except
  /// [RuStoreFsaEventType.install].
  ///
  /// Returns `true` on successful submission.
  ///
  /// Throws [RuStoreInstallReferrerException] on error:
  /// - `MISSING_PHONE_NUMBER`: Phone number not provided.
  /// - `MISSING_AUTH_TOKEN`: Auth token not provided.
  /// - `MISSING_PRODUCT_ID`: Product ID not provided for the event type.
  /// - `INVALID_PHONE_NUMBER`: Phone number format is invalid.
  /// - `RU_STORE_NOT_INSTALLED`: RuStore not installed on device.
  /// - `RU_STORE_OUTDATED`: RuStore version is outdated.
  /// - `RU_STORE_ERROR`: General RuStore SDK error.
  ///
  /// Important: This feature is optional and requires explicit configuration.
  /// Contact your VK Ads manager to obtain the auth token.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await RuStoreInstallReferrer.sendFsaEvent(
  ///     phoneNumber: '1234567890',
  ///     authToken: 'your_auth_token_from_vk_ads',
  ///     eventType: RuStoreFsaEventType.purchase,
  ///     productId: 'product_id',
  ///   );
  ///   print('FSA event sent successfully');
  /// } catch (e) {
  ///   print('Failed to send FSA event: $e');
  /// }
  /// ```
  static Future<bool> sendFsaEvent({
    required String phoneNumber,
    required String authToken,
    RuStoreFsaEventType eventType = RuStoreFsaEventType.install,
    String? productId,
  }) async {
    final result = await _invoke<bool>('sendFsaEvent', {
      'phoneNumber': phoneNumber,
      'authToken': authToken,
      'eventType': eventType.value,
      'productId': productId,
    });
    return result == true;
  }

  /// Sends authentication event to VK Ads Full Stream Attribution.
  ///
  /// RuStore SDK 10.6.1 replaced the auth event with typed FSA events, so this
  /// method now sends an [RuStoreFsaEventType.install] event.
  ///
  /// [phoneNumber] - User's phone number (digits only, e.g., "1234567890").
  /// [authToken] - Authorization token from VK Ads manager.
  ///
  /// Returns `true` on successful submission.
  ///
  /// Throws [RuStoreInstallReferrerException] on error, see [sendFsaEvent].
  @Deprecated('Use sendFsaEvent instead.')
  static Future<bool> sendAuthEvent({
    required String phoneNumber,
    required String authToken,
  }) async {
    final result = await _invoke<bool>('sendAuthEvent', {
      'phoneNumber': phoneNumber,
      'authToken': authToken,
    });
    return result == true;
  }

  /// Invokes a native method and maps platform errors to
  /// [RuStoreInstallReferrerException].
  static Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      // Map exception class names to user-friendly codes
      final mappedCode = _mapExceptionCode(e.code);
      throw RuStoreInstallReferrerException(
        code: mappedCode,
        message: e.message ?? 'Unknown platform error',
        details: e.details?.toString(),
      );
    } catch (e) {
      throw RuStoreInstallReferrerException(
        code: 'UNKNOWN_ERROR',
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Invokes a native method that returns a referrer map.
  /// A `null` result means that RuStore has no referrer for this install.
  static Future<Map<dynamic, dynamic>> _invokeMap(String method) async {
    final result = await _invoke<Map<dynamic, dynamic>>(method);
    if (result == null) {
      throw RuStoreInstallReferrerException(
        code: 'REFERRER_NOT_FOUND',
        message:
            'Referrer is null. App was installed without referrer, '
            'or it has expired or been consumed.',
      );
    }
    return result;
  }

  /// Maps native exception class names to user-friendly error codes.
  static String _mapExceptionCode(String exceptionClassName) {
    switch (exceptionClassName) {
      case 'RuStoreNotInstalledException':
        return 'RU_STORE_NOT_INSTALLED';
      case 'RuStoreOutdatedException':
        return 'RU_STORE_OUTDATED';
      case 'RuStoreException':
        return 'RU_STORE_ERROR';
      case 'ClientNotCreated':
        return 'CLIENT_NOT_CREATED';
      case 'InvalidPhoneNumberException':
        return 'INVALID_PHONE_NUMBER';
      case 'CLIENT_NOT_INITIALIZED':
      case 'MISSING_PHONE_NUMBER':
      case 'MISSING_AUTH_TOKEN':
      case 'MISSING_PRODUCT_ID':
      case 'INVALID_PHONE_NUMBER':
      case 'INVALID_EVENT_TYPE':
        return exceptionClassName;
      default:
        return exceptionClassName; // Keep original for unknown exceptions
    }
  }

  /// Returns a human-readable error description.
  static String getErrorDescription(String errorCode) {
    switch (errorCode) {
      case 'REFERRER_NOT_FOUND':
        return 'Referrer not found. Possible reasons:\n'
            '• App was installed without referrer\n'
            '• Referrer expired (90 days after the click)\n'
            '• Referrer was already consumed by an earlier request '
            '(older RuStore versions delete it after the first read)';
      case 'RU_STORE_NOT_INSTALLED':
        return 'RuStore is not installed on the device. '
            'Install RuStore to use Install Referrer API.';
      case 'RU_STORE_OUTDATED':
        return 'RuStore version is outdated and doesn\'t support Install Referrer API. '
            'Update RuStore to the latest version.';
      case 'RU_STORE_ERROR':
        return 'An error occurred in RuStore SDK. '
            'Try repeating the request later.';
      case 'CLIENT_NOT_CREATED':
        return 'Install Referrer client could not be created.';
      case 'MISSING_PHONE_NUMBER':
        return 'Phone number is required for sending FSA event.';
      case 'MISSING_AUTH_TOKEN':
        return 'Auth token is required for sending FSA event. '
            'Contact your VK Ads manager to obtain it.';
      case 'MISSING_PRODUCT_ID':
        return 'Product ID is required for this FSA event type.';
      case 'INVALID_EVENT_TYPE':
        return 'Unknown FSA event type.';
      case 'INVALID_PHONE_NUMBER':
        return 'Phone number format is invalid. '
            'Use digits only (e.g., "1234567890").';
      case 'CLIENT_NOT_INITIALIZED':
        return 'Install Referrer client is not initialized. '
            'This is an internal error, please report to the developer.';
      case 'UNKNOWN_ERROR':
        return 'An unknown error occurred. '
            'Contact the app developer.';
      default:
        return 'Unknown error: $errorCode';
    }
  }
}
