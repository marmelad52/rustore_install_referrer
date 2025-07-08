// lib/rustore_install_referrer.dart

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:rustore_install_referrer/referrer_details.dart';

export 'package:rustore_install_referrer/referrer_details.dart';

/// Exception that occurs when working with RuStore Install Referrer.
class RuStoreInstallReferrerException implements Exception {
  /// Error code.
  final String code;
  
  /// Error message.
  final String message;
  
  /// Additional error details.
  final String? details;

  RuStoreInstallReferrerException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'RuStoreInstallReferrerException($code): $message'
      '${details != null ? '\nDetails: $details' : ''}';
}

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
class RustoreInstallReferrer {
  static const MethodChannel _channel = MethodChannel('rustore_install_referrer');

  /// Gets installation details from RuStore.
  ///
  /// Returns [ReferrerDetails] on success.
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
  static Future<ReferrerDetails> getInstallReferrer() async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('getInstallReferrer');
      
      if (result == null) {
        throw RuStoreInstallReferrerException(
          code: 'REFERRER_NOT_FOUND',
          message: 'Referrer is null. It might have been already consumed or expired.',
        );
      }
      
      return ReferrerDetails.fromMap(result);
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

  /// Maps native exception class names to user-friendly error codes.
  static String _mapExceptionCode(String exceptionClassName) {
    switch (exceptionClassName) {
      case 'RuStoreNotInstalledException':
        return 'RU_STORE_NOT_INSTALLED';
      case 'RuStoreOutdatedException':
        return 'RU_STORE_OUTDATED';
      case 'RuStoreException':
        return 'RU_STORE_ERROR';
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
      case 'UNKNOWN_ERROR':
        return 'An unknown error occurred. '
            'Contact the app developer.';
      default:
        return 'Unknown error: $errorCode';
    }
  }
}