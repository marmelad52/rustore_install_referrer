import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rustore_install_referrer/rustore_install_referrer_exception.dart';
import 'package:rustore_install_referrer/rustore_referrer_details.dart';

export 'package:rustore_install_referrer/rustore_referrer_details.dart';

/// Main class for working with RuStore Install Referrer API.
///
/// This class provides methods to get referrer information
/// that is passed during app installation through RuStore advertising links.
///
/// Example usage:
/// ```dart
/// try {
///   final details = await RustoreInstallReferrer.getInstallReferrer();
///   print('Referrer: ${details.referrerId}');
///   print('Install time: ${details.installAppTime}');
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
  /// - `REFERRER_NOT_FOUND`: Referrer not found (already requested,
  ///   app installed without referrer, or expired).
  /// - `RU_STORE_NOT_INSTALLED`: RuStore not installed on device.
  /// - `RU_STORE_OUTDATED`: RuStore version is outdated.
  /// - `RU_STORE_ERROR`: General RuStore SDK error.
  /// - `UNKNOWN_ERROR`: Unknown error.
  ///
  /// Important: Referrer can only be obtained once. Repeated calls
  /// will return `REFERRER_NOT_FOUND` error.
  static Future<RuStoreReferrerDetails> getInstallReferrer() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod(
        'getInstallReferrer',
      );

      if (result == null) {
        throw RuStoreInstallReferrerException(
          code: 'REFERRER_NOT_FOUND',
          message:
              'Referrer is null. It might have been already consumed or expired.',
        );
      }

      return RuStoreReferrerDetails.fromMap(result);
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

  /// Sends authentication event to VK Ads Full Stream Attribution.
  ///
  /// This method allows sending user phone number to VK Ads system for
  /// attribution purposes. Requires auth token from VK Ads manager.
  ///
  /// [phoneNumber] - User's phone number (digits only, e.g., "1234567890").
  /// [authToken] - Authorization token from VK Ads manager.
  ///
  /// Returns `true` on successful submission.
  ///
  /// Throws [RuStoreInstallReferrerException] on error:
  /// - `MISSING_PHONE_NUMBER`: Phone number not provided.
  /// - `MISSING_AUTH_TOKEN`: Auth token not provided.
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
  ///   await RuStoreInstallReferrer.sendAuthEvent(
  ///     phoneNumber: '1234567890',
  ///     authToken: 'your_auth_token_from_vk_ads',
  ///   );
  ///   print('Auth event sent successfully');
  /// } catch (e) {
  ///   print('Failed to send auth event: $e');
  /// }
  /// ```
  static Future<bool> sendAuthEvent({
    required String phoneNumber,
    required String authToken,
  }) async {
    try {
      final result = await _channel.invokeMethod('sendAuthEvent', {
        'phoneNumber': phoneNumber,
        'authToken': authToken,
      });
      return result == true;
    } on PlatformException catch (e) {
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

  /// Maps native exception class names to user-friendly error codes.
  static String _mapExceptionCode(String exceptionClassName) {
    switch (exceptionClassName) {
      case 'RuStoreNotInstalledException':
        return 'RU_STORE_NOT_INSTALLED';
      case 'RuStoreOutdatedException':
        return 'RU_STORE_OUTDATED';
      case 'RuStoreException':
        return 'RU_STORE_ERROR';
      case 'CLIENT_NOT_INITIALIZED':
      case 'MISSING_PHONE_NUMBER':
      case 'MISSING_AUTH_TOKEN':
      case 'INVALID_PHONE_NUMBER':
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
            '• Referrer was already requested before\n'
            '• More than 10 days have passed since referrer was received';
      case 'RU_STORE_NOT_INSTALLED':
        return 'RuStore is not installed on the device. '
            'Install RuStore to use Install Referrer API.';
      case 'RU_STORE_OUTDATED':
        return 'RuStore version is outdated and doesn\'t support Install Referrer API. '
            'Update RuStore to the latest version.';
      case 'RU_STORE_ERROR':
        return 'An error occurred in RuStore SDK. '
            'Try repeating the request later.';
      case 'MISSING_PHONE_NUMBER':
        return 'Phone number is required for sending auth event.';
      case 'MISSING_AUTH_TOKEN':
        return 'Auth token is required for sending auth event. '
            'Contact your VK Ads manager to obtain it.';
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
