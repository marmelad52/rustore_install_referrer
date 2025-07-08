/// Class containing install referrer details from RuStore.
class ReferrerDetails {
  /// Package name of the app.
  final String packageName;

  /// Referrer ID from the advertising link.
  /// For example, for the link https://www.rustore.ru/catalog/app/com.example.app?referrerId=campaign123
  /// this will contain "campaign123".
  final String referrerId;

  /// Timestamp when the referrer was received (in milliseconds since Unix epoch).
  final int receivedTimestamp;

  /// Timestamp when the app installation began (in milliseconds since Unix epoch).
  final int installAppTimestamp;

  /// Version code of the app for which the referrer was obtained.
  /// Can be null if the information is not available.
  final int? versionCode;

  const ReferrerDetails({
    required this.packageName,
    required this.referrerId,
    required this.receivedTimestamp,
    required this.installAppTimestamp,
    this.versionCode,
  });

  /// Creates a [ReferrerDetails] instance from a Map received from the native platform.
  factory ReferrerDetails.fromMap(Map<dynamic, dynamic> map) {
    return ReferrerDetails(
      packageName: map['packageName'] as String? ?? '',
      referrerId: map['referrerId'] as String? ?? '',
      receivedTimestamp: _safeLong(map['receivedTimestamp']),
      installAppTimestamp: _safeLong(map['installAppTimestamp']),
      versionCode: map['versionCode'] != null
          ? _safeLong(map['versionCode'])
          : null,
    );
  }

  /// Safely converts a value to int, handling various numeric types.
  static int _safeLong(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Converts to Map for debugging and serialization convenience.
  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'referrerId': referrerId,
      'receivedTimestamp': receivedTimestamp,
      'installAppTimestamp': installAppTimestamp,
      'versionCode': versionCode,
    };
  }

  /// Returns DateTime for when the referrer was received.
  DateTime get receivedTime =>
      DateTime.fromMillisecondsSinceEpoch(receivedTimestamp);

  /// Returns DateTime for when the app installation began.
  DateTime get installAppTime =>
      DateTime.fromMillisecondsSinceEpoch(installAppTimestamp);

  /// Returns true if referrer contains data (not empty string).
  bool get hasReferrer => referrerId.isNotEmpty;

  /// Returns the install referrer string (alias for referrerId for compatibility).
  String get installReferrer => referrerId;

  /// Returns the received timestamp in seconds (for compatibility).
  int get receivedTimestampSeconds => (receivedTimestamp / 1000).round();

  /// Returns the install timestamp in seconds (for compatibility).
  int get installTimestampSeconds => (installAppTimestamp / 1000).round();

  @override
  String toString() {
    return 'ReferrerDetails('
        'packageName: $packageName, '
        'referrerId: $referrerId, '
        'receivedTime: $receivedTime, '
        'installAppTime: $installAppTime, '
        'versionCode: $versionCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReferrerDetails &&
        other.packageName == packageName &&
        other.referrerId == referrerId &&
        other.receivedTimestamp == receivedTimestamp &&
        other.installAppTimestamp == installAppTimestamp &&
        other.versionCode == versionCode;
  }

  @override
  int get hashCode {
    return Object.hash(
      packageName,
      referrerId,
      receivedTimestamp,
      installAppTimestamp,
      versionCode,
    );
  }
}
