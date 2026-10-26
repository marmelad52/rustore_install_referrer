## [2.1.0] - 2026-10-26

### Changed
- Updated RuStore Install Referrer SDK from 10.0.0 to 10.6.1
- RuStore Maven repository moved to `https://nexus-external.rustore.ru/repository/maven-rustore-exposed`
  (the old `artifactory-external.vkpartner.ru` no longer serves the SDK). Update the repository URL in your Android project
- Minimum Android SDK is now 23, as required by the RuStore SDK (the plugin previously declared 21)
- `sendAuthEvent()` is deprecated: SDK 10.6.1 removed `AuthEvent` in favour of typed FSA events. It still works and now sends an `install` FSA event

### Added
- `getInstallReferrerV2()` and `RuStoreReferrerDetailsV2` (timestamps in seconds, server timestamps, `isFromRuStore`)
- `sendFsaEvent()` and `RuStoreFsaEventType` (`install`, `viewOffer`, `addToCart`, `purchase`, `addToWishlist`)
- `isReferrerServiceAvailable()` and `getDebugInfo()`
- UTM fields in `RuStoreReferrerDetails` (`utmSource`, `utmMedium`, `utmCampaign`, `utmGroup`, `utmBanner`, `utmContent`, `utmTerm`)
- Error codes: `CLIENT_NOT_CREATED`, `MISSING_PRODUCT_ID`, `INVALID_EVENT_TYPE`

### Fixed
- `getInstallReferrer()` now throws `REFERRER_NOT_FOUND` when there is no referrer; previously the error was wrapped into `UNKNOWN_ERROR`
- SDK `InvalidPhoneNumberException` is mapped to `INVALID_PHONE_NUMBER`

---

## [2.0.1] - 2025-10-09

### Fixed
- Shortened `pubspec.yaml` description to meet pub.dev 180 character limit
- Fixed code formatting to comply with Dart style guide
- Achieved perfect 160/160 pub points score on pub.dev

---

## [2.0.0] - 2025-10-09

### Changed
- **Breaking**: Updated RuStore Install Referrer SDK from 7.0.0 to 10.0.0
- InstallReferrerClient now initialized once and reused

### Added
- `sendAuthEvent()` method for VK Ads Full Stream Attribution
- Support for sending user phone number to VK Ads attribution system
- New error codes: `MISSING_PHONE_NUMBER`, `MISSING_AUTH_TOKEN`, `INVALID_PHONE_NUMBER`, `CLIENT_NOT_INITIALIZED`
- Error descriptions for new error codes

### Notes
- All existing API (`getInstallReferrer()`) works without changes
- New functionality is optional
- No migration required for existing code

---

## [1.0.0] - 2025-01-08

### Added
- Initial release
- Support for RuStore SDK 7.0.0+
- `getInstallReferrer()` method
- `ReferrerDetails` class with install information
- `RuStoreInstallReferrerException` for error handling
- Error codes: `REFERRER_NOT_FOUND`, `RU_STORE_NOT_INSTALLED`, `RU_STORE_OUTDATED`, `RU_STORE_ERROR`, `UNKNOWN_ERROR`
- `getErrorDescription()` method
- Android platform support (minimum SDK 23)
- MIT License