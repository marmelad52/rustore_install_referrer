/// Install referrer details returned by `getInstallReferrerV2()`.
class RuStoreReferrerDetailsV2 {
  /// Referrer string from the advertising link.
  /// For example, for the link https://www.rustore.ru/catalog/app/com.example.app?referrer=campaign123
  /// this will contain "campaign123".
  final String installReferrer;

  /// Time of the referrer click (in seconds since Unix epoch).
  final int referrerClickTimestampSeconds;

  /// Time when the app installation began (in seconds since Unix epoch).
  final int installBeginTimestampSeconds;

  /// Server time of the referrer click (in seconds since Unix epoch).
  final int referrerClickTimestampServerSeconds;

  /// Server time when the app installation began (in seconds since Unix epoch).
  final int installBeginTimestampServerSeconds;

  /// Always `false` for RuStore.
  final bool googlePlayInstant;

  /// `true` if the data was received from RuStore.
  final bool isFromRuStore;

  const RuStoreReferrerDetailsV2({
    required this.installReferrer,
    required this.referrerClickTimestampSeconds,
    required this.installBeginTimestampSeconds,
    required this.referrerClickTimestampServerSeconds,
    required this.installBeginTimestampServerSeconds,
    required this.googlePlayInstant,
    required this.isFromRuStore,
  });

  /// Creates a [RuStoreReferrerDetailsV2] instance from a Map received from the native platform.
  factory RuStoreReferrerDetailsV2.fromMap(Map<dynamic, dynamic> map) {
    return RuStoreReferrerDetailsV2(
      installReferrer: map['installReferrer'] as String? ?? '',
      referrerClickTimestampSeconds: _safeLong(
        map['referrerClickTimestampSeconds'],
      ),
      installBeginTimestampSeconds: _safeLong(
        map['installBeginTimestampSeconds'],
      ),
      referrerClickTimestampServerSeconds: _safeLong(
        map['referrerClickTimestampServerSeconds'],
      ),
      installBeginTimestampServerSeconds: _safeLong(
        map['installBeginTimestampServerSeconds'],
      ),
      googlePlayInstant: map['googlePlayInstant'] as bool? ?? false,
      isFromRuStore: map['isFromRuStore'] as bool? ?? false,
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
      'installReferrer': installReferrer,
      'referrerClickTimestampSeconds': referrerClickTimestampSeconds,
      'installBeginTimestampSeconds': installBeginTimestampSeconds,
      'referrerClickTimestampServerSeconds':
          referrerClickTimestampServerSeconds,
      'installBeginTimestampServerSeconds': installBeginTimestampServerSeconds,
      'googlePlayInstant': googlePlayInstant,
      'isFromRuStore': isFromRuStore,
    };
  }

  /// Returns DateTime for the referrer click.
  DateTime get referrerClickTime =>
      DateTime.fromMillisecondsSinceEpoch(referrerClickTimestampSeconds * 1000);

  /// Returns DateTime for when the app installation began.
  DateTime get installBeginTime =>
      DateTime.fromMillisecondsSinceEpoch(installBeginTimestampSeconds * 1000);

  /// Returns DateTime for the referrer click according to the server clock.
  DateTime get referrerClickServerTime => DateTime.fromMillisecondsSinceEpoch(
    referrerClickTimestampServerSeconds * 1000,
  );

  /// Returns DateTime for when the app installation began according to the server clock.
  DateTime get installBeginServerTime => DateTime.fromMillisecondsSinceEpoch(
    installBeginTimestampServerSeconds * 1000,
  );

  /// Returns true if referrer contains data (not empty string).
  bool get hasReferrer => installReferrer.isNotEmpty;

  @override
  String toString() {
    return 'ReferrerDetailsV2('
        'installReferrer: $installReferrer, '
        'referrerClickTime: $referrerClickTime, '
        'installBeginTime: $installBeginTime, '
        'googlePlayInstant: $googlePlayInstant, '
        'isFromRuStore: $isFromRuStore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RuStoreReferrerDetailsV2 &&
        other.installReferrer == installReferrer &&
        other.referrerClickTimestampSeconds == referrerClickTimestampSeconds &&
        other.installBeginTimestampSeconds == installBeginTimestampSeconds &&
        other.referrerClickTimestampServerSeconds ==
            referrerClickTimestampServerSeconds &&
        other.installBeginTimestampServerSeconds ==
            installBeginTimestampServerSeconds &&
        other.googlePlayInstant == googlePlayInstant &&
        other.isFromRuStore == isFromRuStore;
  }

  @override
  int get hashCode {
    return Object.hash(
      installReferrer,
      referrerClickTimestampSeconds,
      installBeginTimestampSeconds,
      referrerClickTimestampServerSeconds,
      installBeginTimestampServerSeconds,
      googlePlayInstant,
      isFromRuStore,
    );
  }
}
