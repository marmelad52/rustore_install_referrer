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